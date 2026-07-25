<p align="center">
  <img src="src/airootfs/usr/share/pixmaps/bal.png" alt="Blue Archive Linux Logo" width="200">
</p>

<h1 align="center">Blue Archive Linux</h1>

<p align="center">
  A specialized Arch-based distribution meticulously crafted to bring the aesthetic and atmosphere of the Blue Archive universe to your desktop.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white" alt="Arch Linux">
  <img src="https://img.shields.io/badge/KDE_Plasma-27ae60?style=for-the-badge&logo=kde&logoColor=white" alt="KDE Plasma">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge" alt="License">
</p>

---

## Project Overview

Blue Archive Linux provides a "Schale-inspired" workstation experience. It combines the rolling-release nature of Arch Linux with a heavily customized KDE Plasma environment. The project focuses on visual consistency, high-performance animations, and a clean user interface.

### Key Features

*   **Arch Linux Base:** Reliable, lightweight, and always up-to-date.
*   **Custom KDE Plasma:** A bespoke desktop environment featuring custom color schemes.
*   **Dart-Powered Utilities:** Built-in system tools designed with Dart/Flutter for high-fidelity animations and a premium feel.

---

## Custom Applications & Utilities

This distribution includes open-source custom tools built specifically to interface between the user and the system:

*   **BAL Welcome:** A first-boot utility built using Dart/Flutter to guide you through system initialization and basic configuration with smooth UI transitions.
*   **BAL Helper:** A specialized management tool built with Dart/Flutter for quick system adjustments and thematic settings.
*   **Chimera:** A lightweight, offline-first universal Linux installer framework designed for deterministic, modular, and rootfs-based system deployment.

### Development Documentation
If you are looking for the source code, build instructions, or development guides for these applications, please navigate to their respective repositories:

*   [Welcome App Source & Guide](https://github.com/minhmc2007/bal-welcome)
*   [Helper App Source & Guide](https://github.com/minhmc2007/bal-helper)
*   [Chimera Installer Framework](https://github.com/minhmc2007/Chimera)

---

## Package Repository

For a complete list of pre-built custom packages, PKGBUILDs, and repository metadata, visit the official custom repository:

*   [Blue Archive Linux Repository](https://github.com/minhmc2007/Blue-Archive-Linux-Repo)

---

## Installation

1.  **Download:** Get the latest ISO from the [Releases](#) page.
2.  **Flash:** Write the ISO to a USB drive using `dd`, [balenaEtcher](https://etcher.balena.io/) or [ventoy](https://www.ventoy.net/en/index.html) to just drag'n'drop.
3.  **Boot:**  Restart your PC, access the BIOS and choose your USB drive, remember to turn off Secure Boot in BIOS setting (if this is the first time you install more than 1 OS).
4.  **Install:** Follow the graphical installation process. Upon the first login, the **Welcome Screen** will launch automatically to finish the setup.

---

## Build Instructions

You can build the Blue Archive Linux ISO manually using the provided `Makefile`.

### Prerequisites

*   **Arch Linux host** (recommended)
*   `archiso` package installed
*   `qemu-desktop` (for running the ISO)
*   `docker` (optional, for containerized builds)

### Using Makefile

*   **Standard Build:** Build the production ISO with full compression.
    ```bash
    make build
    ```
*   **Debug Build:** Build the ISO without compression for much faster iteration.
    ```bash
    make debug
    ```
*   **Run in QEMU:** Test your built ISO with hardware acceleration (KVM) and optimized graphics (`virtio-vga-gl`).
    ```bash
    make run
    ```
*   **Clean Artifacts:** Remove build and work directories.
    ```bash
    make clean
    ```

### Containerized Build

If you prefer to build in a clean environment, use Docker:
```bash
make docker-build
