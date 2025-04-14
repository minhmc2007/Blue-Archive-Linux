import os
import subprocess
import argparse
import shutil
import json
import logging

# Constants
REPO_DIR = "/blue_archive_fs"  # Local repository directory
INSTALL_DIR = "/usr/bin"        # Installation directory for packages
TRACKING_FILE = os.path.join(REPO_DIR, "installed_packages.json")  # File to track installed packages
EXIT_CODES = {
    "general_error": 1,         # General failure
    "permission_error": 2,      # Insufficient permissions
    "invalid_input": 3,         # Invalid user input
    "package_not_found": 4,     # Package not found in BluePM or Pacman
    "not_installed_by_bluepm": 5  # Package not installed by BluePM
}

# ANSI color codes for terminal output
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
RESET = "\033[0m"

def setup_logging():
    """Configure logging to write to bluepm.log."""
    logging.basicConfig(
        filename="bluepm.log",
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s"
    )

def sanitize_package_name(package_name):
    """Validate and sanitize package name to ensure it's alphanumeric."""
    if not package_name.isalnum():
        raise ValueError(f"Invalid package name: '{package_name}'. Only alphanumeric characters allowed.")
    return package_name

def get_shell_rc_path():
    """Determine the user's shell configuration file path (e.g., .bashrc or .zshrc)."""
    user = os.environ.get("SUDO_USER") or os.environ["USER"]
    user_home = os.path.expanduser(f"~{user}")
    shell = os.environ.get("SHELL", "/bin/bash")
    if "zsh" in shell:
        return os.path.join(user_home, ".zshrc")
    elif "bash" in shell:
        return os.path.join(user_home, ".bashrc")
    else:
        raise NotImplementedError(f"Unsupported shell: {shell}")

def update_repo():
    """Update the local repository by running git pull."""
    if not os.path.exists(REPO_DIR):
        print(f"{RED}❌ Error: Repository directory '{REPO_DIR}' does not exist.{RESET}")
        exit(EXIT_CODES["general_error"])
    try:
        subprocess.run(["git", "-C", REPO_DIR, "pull"], check=True, text=True, capture_output=True)
        print(f"{GREEN}Repository updated successfully.{RESET}")
    except FileNotFoundError:
        print(f"{RED}❌ Error: 'git' command not found. Please install git.{RESET}")
        exit(EXIT_CODES["general_error"])
    except subprocess.CalledProcessError as e:
        print(f"{RED}❌ Error: Failed to update repository. {e.stderr}{RESET}")
        exit(EXIT_CODES["general_error"])

def backup_shell_config(shell_rc_path):
    """Create a backup of the shell configuration file before modification."""
    if os.path.exists(shell_rc_path):
        backup_path = f"{shell_rc_path}.bak"
        try:
            shutil.copy2(shell_rc_path, backup_path)
            print(f"{GREEN}✅ Backed up '{shell_rc_path}' to '{backup_path}'.{RESET}")
        except Exception as e:
            print(f"{RED}❌ Error: Failed to create backup of '{shell_rc_path}': {e}{RESET}")
            exit(EXIT_CODES["general_error"])

def parse_info_txt(package_dir):
    """Parse info.txt in the package directory to extract metadata like dependencies."""
    info_path = os.path.join(package_dir, "info.txt")
    info = {}
    if not os.path.exists(info_path):
        return info
    try:
        with open(info_path, "r") as file:
            for line in file:
                line = line.strip()
                if line and ":" in line:
                    key, value = line.split(":", 1)
                    info[key.strip()] = value.strip()
    except IOError as e:
        print(f"{YELLOW}⚠ Warning: Failed to read '{info_path}': {e}. Ignoring metadata.{RESET}")
    return info

def load_installed_packages():
    """Load the list of installed packages from the tracking file."""
    if not os.path.exists(TRACKING_FILE):
        return []
    try:
        with open(TRACKING_FILE, "r") as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError) as e:
        print(f"{YELLOW}⚠ Warning: Failed to read tracking file '{TRACKING_FILE}': {e}. Starting with empty list.{RESET}")
        return []

def save_installed_packages(packages):
    """Save the list of installed packages to the tracking file."""
    try:
        os.makedirs(os.path.dirname(TRACKING_FILE), exist_ok=True)
        with open(TRACKING_FILE, "w") as f:
            json.dump(packages, f, indent=2)
    except IOError as e:
        print(f"{RED}❌ Error: Failed to write to tracking file '{TRACKING_FILE}': {e}{RESET}")
        exit(EXIT_CODES["general_error"])

def install_package(package_name, method="copy", use_pacman=False):
    """Install a package either by copying it or creating an alias, with optional pacman fallback."""
    package_name = sanitize_package_name(package_name)
    package_dir = os.path.join(REPO_DIR, "rolling", package_name)
    package_file = os.path.join(package_dir, package_name)
    
    # Check if package exists in local repository
    if not os.path.exists(package_file):
        if method == "alias":
            print(f"{RED}❌ Error: Package '{package_name}' not found in local repo. Cannot create alias.{RESET}")
            exit(EXIT_CODES["package_not_found"])
        elif use_pacman:
            print(f"{YELLOW}⚠ Package '{package_name}' not found in local repo. Attempting to install with pacman...{RESET}")
            try:
                subprocess.run(["pacman", "-S", package_name], check=True)
                print(f"{GREEN}✅ Package '{package_name}' installed via pacman.{RESET}")
                return  # Do not track pacman-installed packages
            except subprocess.CalledProcessError:
                print(f"{RED}❌ Error: Package '{package_name}' not found in BluePM or Pacman.{RESET}")
                exit(EXIT_CODES["package_not_found"])
        else:
            print(f"{RED}❌ Error: Package '{package_name}' not found in local repo. Use --pacman to try pacman.{RESET}")
            exit(EXIT_CODES["package_not_found"])
    
    # Handle dependencies from info.txt
    info = parse_info_txt(package_dir)
    dep_command = info.get("dependencies")
    if dep_command:
        print(f"{YELLOW}⚠ Running dependency command for '{package_name}': {dep_command}{RESET}")
        try:
            result = subprocess.run(dep_command, shell=True, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"{RED}❌ Error: Dependency command failed with code {result.returncode}{RESET}")
                print(f"Output: {result.stdout}")
                print(f"Error: {result.stderr}")
                exit(EXIT_CODES["general_error"])
        except Exception as e:
            print(f"{RED}❌ Error: Failed to run dependency command: {e}{RESET}")
            exit(EXIT_CODES["general_error"])
    
    # Proceed with package installation
    install_path = os.path.join(INSTALL_DIR, package_name)
    installed_packages = load_installed_packages()
    
    if method == "alias":
        print(f"{YELLOW}⚠ WARNING: --alias is a test feature and may not work correctly.{RESET}")
        shell_rc_path = get_shell_rc_path()
        backup_shell_config(shell_rc_path)
        try:
            with open(shell_rc_path, "a") as shell_config:
                shell_config.write(f"\nalias {package_name}='{package_file}'\n")
            print(f"{GREEN}✅ Alias '{package_name}' added. Run `source {shell_rc_path}` to apply.{RESET}")
            # Track alias installation
            installed_packages.append({
                "name": package_name,
                "method": "alias",
                "shell_rc_path": shell_rc_path
            })
        except IOError as e:
            print(f"{RED}❌ Error: Failed to write to '{shell_rc_path}': {e}{RESET}")
            exit(EXIT_CODES["general_error"])
    else:
        try:
            shutil.copy2(package_file, install_path)
            os.chmod(install_path, 0o755)
            print(f"{GREEN}✅ '{package_name}' installed to {INSTALL_DIR}.{RESET}")
            # Track copy installation
            installed_packages.append({
                "name": package_name,
                "method": "copy",
                "shell_rc_path": None
            })
        except PermissionError:
            print(f"{RED}❌ Error: Insufficient permissions to install to '{install_path}'.{RESET}")
            exit(EXIT_CODES["permission_error"])
        except IOError as e:
            print(f"{RED}❌ Error: Failed to copy '{package_file}' to '{install_path}': {e}{RESET}")
            exit(EXIT_CODES["general_error"])
    
    save_installed_packages(installed_packages)

def remove_package(package_name):
    """Remove a package, but only if it was installed by BluePM."""
    package_name = sanitize_package_name(package_name)
    installed_packages = load_installed_packages()
    package_info = next((pkg for pkg in installed_packages if pkg["name"] == package_name), None)
    
    if not package_info:
        print(f"{YELLOW}⚠ Package '{package_name}' was not installed by BluePM.{RESET}")
        exit(EXIT_CODES["not_installed_by_bluepm"])
    
    # Remove based on installation method
    if package_info["method"] == "alias":
        shell_rc_path = package_info["shell_rc_path"]
        if os.path.exists(shell_rc_path):
            try:
                with open(shell_rc_path, "r") as shell_config:
                    lines = shell_config.readlines()
                with open(shell_rc_path, "w") as shell_config:
                    for line in lines:
                        if line.strip() != f"alias {package_name}='{os.path.join(REPO_DIR, 'rolling', package_name, package_name)}'":
                            shell_config.write(line)
                print(f"{GREEN}✅ Alias '{package_name}' removed from '{shell_rc_path}'. Run `source {shell_rc_path}` to apply.{RESET}")
            except IOError as e:
                print(f"{RED}❌ Error: Failed to modify '{shell_rc_path}': {e}{RESET}")
                exit(EXIT_CODES["general_error"])
        else:
            print(f"{YELLOW}⚠ Shell config '{shell_rc_path}' not found; alias may already be removed.{RESET}")
    
    elif package_info["method"] == "copy":
        executable = os.path.join(INSTALL_DIR, package_name)
        if os.path.exists(executable):
            try:
                os.remove(executable)
                print(f"{GREEN}✅ '{package_name}' removed from {INSTALL_DIR}.{RESET}")
            except PermissionError:
                print(f"{RED}❌ Error: Insufficient permissions to remove '{executable}'.{RESET}")
                exit(EXIT_CODES["permission_error"])
        else:
            print(f"{YELLOW}⚠ '{package_name}' not found in {INSTALL_DIR}; may already be removed.{RESET}")
    
    # Update tracking file
    installed_packages = [pkg for pkg in installed_packages if pkg["name"] != package_name]
    save_installed_packages(installed_packages)

def main():
    """Parse command-line arguments and execute the appropriate actions."""
    setup_logging()
    parser = argparse.ArgumentParser(description="BluePM - Blue Archive Linux Package Manager")
    parser.add_argument("--install", help="Install a package", metavar="PACKAGE")
    parser.add_argument("--alias", action="store_true", help="Use alias instead of copying (test feature)")
    parser.add_argument("--remove", help="Remove a package", metavar="PACKAGE")
    parser.add_argument("--pacman", action="store_true", help="Try pacman if package not in local repo")
    args = parser.parse_args()

    # Check for root privileges when needed
    if (args.install and not args.alias) or args.remove:
        if os.geteuid() != 0:
            print(f"{RED}❌ This operation requires root privileges. Run with sudo.{RESET}")
            exit(EXIT_CODES["permission_error"])

    logging.info(f"Running BluePM with args: {args}")
    if args.install:
        update_repo()
        install_package(args.install, method="alias" if args.alias else "copy", use_pacman=args.pacman)
    elif args.remove:
        remove_package(args.remove)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()