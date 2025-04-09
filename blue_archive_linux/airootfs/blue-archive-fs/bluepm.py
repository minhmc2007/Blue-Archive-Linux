import os
import subprocess
import argparse
import shutil

REPO_URL = "https://github.com/minhmc2007/Blue-Archive-Linux-Repo"
REPO_DIR = "Blue-Archive-Linux-Repo"
INSTALL_DIR = "/usr/bin"

def update_repo():
    """Update the package repository."""
    if not os.path.exists(REPO_DIR):
        subprocess.run(["git", "clone", REPO_URL], check=True)
    else:
        subprocess.run(["git", "-C", REPO_DIR, "pull"], check=True)
    print("Repository updated.")

def install_package(package_name, method="copy"):
    """Install a package via copy or alias."""
    print("Updating package repository...")
    update_repo()

    package_file = os.path.join(REPO_DIR, package_name)
    install_path = os.path.join(INSTALL_DIR, package_name)

    if not os.path.exists(package_file):
        print(f"❌ Error: Package '{package_name}' not found in the repository.")
        return

    if method == "alias":
        print("⚠ WARNING: --alias is under development and may not work correctly. Use at your own risk. ⚠")
        shell_rc_path = os.path.expanduser("~/.zshrc")

        with open(shell_rc_path, "a") as shellrc:
            shellrc.write(f"\nalias {package_name}='{package_file}'\n")

        print(f"✅ Alias '{package_name}' added. Run `source {shell_rc_path}` to apply changes.")

    else:  # Default: copy method
        shutil.copy2(package_file, install_path)
        os.chmod(install_path, 0o755)
        print(f"✅ '{package_name}' installed and made executable.")

def remove_package(package_name):
    """Remove a package (both copy and alias versions)."""
    executable = os.path.join(INSTALL_DIR, package_name)
    shell_rc_path = os.path.expanduser("~/.zshrc")
    alias_removed = False

    # Remove alias from .zshrc
    if os.path.exists(shell_rc_path):
        with open(shell_rc_path, "r") as shellrc:
            lines = shellrc.readlines()
        with open(shell_rc_path, "w") as shellrc:
            for line in lines:
                if not line.strip().startswith(f"alias {package_name}="):
                    shellrc.write(line)
                else:
                    alias_removed = True

    if alias_removed:
        print(f"✅ Alias '{package_name}' removed. Run `source {shell_rc_path}` to apply changes.")

    # Remove copied file
    if os.path.exists(executable):
        os.remove(executable)
        print(f"✅ '{package_name}' removed from {INSTALL_DIR}.")
    else:
        print(f"⚠ '{package_name}' not found in {INSTALL_DIR}.")

def main():
    parser = argparse.ArgumentParser(description="BluePM - Blue Archive Linux Package Manager")
    parser.add_argument("--install", help="Install a package", metavar="PACKAGE")
    parser.add_argument("--alias", action="store_true", help="Use alias instead of copying")
    parser.add_argument("--remove", help="Remove a package", metavar="PACKAGE")
    args = parser.parse_args()

    update_repo()

    if args.install:
        install_package(args.install, method="alias" if args.alias else "copy")
    elif args.remove:
        remove_package(args.remove)

if __name__ == "__main__":
    main()