# Contributing Guidelines

Thank you for your interest in contributing to Blue Archive Linux! To maintain the quality and focus of our minimal distribution, please follow these guidelines.

## Commit Message Requirements

### ❌ What NOT to do:
- `Updated script.sh`
- `Fixed stuff`
- `Changes`
- `Update`
- `Fixed bug`
- `Refactoring`

### ✅ What TO do:
Write clear, descriptive commit messages that explain **what** you changed and **why**.

**Format:**
```
[type]: Brief description of what you did

Optional longer explanation if needed
```

**Types:**
- `feat`: A new feature for the system or a package
- `fix`: A bug fix in a script, package, or system configuration
- `docs`: Documentation changes
- `style`: Code style changes (e.g., shell script formatting, comment improvements)
- `refactor`: Restructuring code without changing its functionality
- `test`: Adding or updating build tests or validation scripts
- `chore`: Maintenance tasks, package version bumps, build system tweaks

**Examples:**
```
feat: Add Realtek RTL8821CE WiFi driver to the default build
fix: Resolve incorrect permissions on /etc/skel/.bashrc
docs: Update README with instructions for building the ISO
style: Format all shell scripts with ShellCheck recommendations
refactor: Modularize the initramfs generation script
test: Add a validation script to check for essential binaries
chore: Update coreutils package to the latest stable version
```

## Pull Request Requirements

### Title Format
Your PR title should clearly describe what the pull request accomplishes:

**❌ Bad examples:**
- `Updates`
- `Fix`
- `Changes to the code`
- `Pull request`
- `Updated script.sh`
- `Fixed config`
- `Package changes`

**✅ Good examples:**
- `feat: Add support for btrfs filesystem in the installer`
- `fix: Correct GRUB configuration for UEFI boot on older systems`
- `refactor: Improve performance of the bluepm package manager`
- `docs: Add documentation for kernel module management`

### PR Description Template
Please include the following information in your PR description:

```markdown
## What does this PR do?
Brief description of the changes (e.g., "This PR updates the Linux kernel to version 6.5 and adds the necessary configs for...")

## Why is this change needed?
Explain the problem this solves or the feature this adds (e.g., "This is needed to support newer hardware and patch critical security vulnerabilities.")

## How was this tested?
Describe how you verified your changes work (e.g., "Successfully built the ISO and tested it on a VirtualBox VM and a Dell Latitude E7450. Boot, networking, and package management are all functional.")

## Screenshots (if applicable)
Add screenshots for changes to the installer or console output.

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Build and boot tests passed
- [ ] Documentation updated if needed
```

## Code Quality Standards

1.  **Write self-documenting code** - Use clear variable and function names in scripts and configuration files.
2.  **Add comments** for complex logic, especially in shell scripts or build system files.
3.  **Follow existing code style** - Maintain the formatting and patterns used in the existing codebase.
4.  **Write tests** - For new shell scripts or complex functionality, add validation or integration tests.
5.  **Update documentation** when adding new features or changing system configurations.

## Review Process

1.  All PRs require at least one approval before merging.
2.  Address all review comments before requesting a re-review.
3.  Keep PRs focused - one feature or fix per PR.
4.  Rebase your branch on the latest `main` before submitting to ensure a clean merge.

## Questions?

If you're unsure about anything related to Blue Archive Linux development, don't hesitate to ask in the issues or discussions section. Whether it's about maintaining minimalism, `bluepm` package management, or CLI-only configurations, we'd rather help you get it right than deal with unclear commits later!

Check the README for detailed information about using `bluepm` to install additional packages like GUI environments.

## Becoming a Core Maintainer

Want to become a core maintainer and help shape the future of Blue Archive Linux? Here's the path:

### Requirements
1.  **Make 5 successful Pull Requests** that get merged into the `main` branch.
2.  **Follow CONTRIBUTOR.md guidelines** - All your PRs must demonstrate you understand and follow our standards.
3.  **Show commitment to minimalism** - Your contributions should align with Blue Archive Linux's minimal philosophy.
4.  **Demonstrate technical competence** - Show you understand Debian-based systems, shell scripting, the Linux boot process, and `bluepm` development.

### Application Process
Once you've met the requirements:

1.  **Open a GitHub issue** with the title: `[MAINTAINER REQUEST] Your GitHub Username`
2.  **Include in your issue:**
    - Links to your 5 merged PRs
    - A brief explanation of what you contributed
    - Why you want to become a core maintainer
    - What areas you'd like to focus on (core system, `bluepm`, build system, kernel configuration, etc.)
3.  **Wait for approval** from the current core maintainer.
4.  **Be patient** - This is an important decision for the project's future.

### What Core Maintainers Do
- Review and approve Pull Requests
- Guide project direction and technical decisions
- Maintain the `bluepm` package repository
- Handle release management and ISO builds
- Mentor new contributors
- Ensure adherence to the minimal philosophy

### Tips for Success
- **Quality over quantity** - Make meaningful contributions, not just trivial changes.
- **Help others** - Answer questions and review other contributors' work.
- **Stay minimal** - Always ask "does this add unnecessary bloat?" before proposing changes.
- **Document well** - Your PRs should be examples for others to follow.

Join our community and help us create the ultimate minimal Blue Archive themed Linux distribution! 💙

---

**Remember:** Clear commit messages help us track what's changing in our minimal distro. Future contributors (including yourself) will thank you for descriptive commits that explain not just what changed, but why it matters for Blue Archive Linux's minimal philosophy
