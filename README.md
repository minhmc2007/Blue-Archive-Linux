2<div align="center">
  <img src="/kivotos.png" alt="KivotOS" />
  
  [![Status](https://img.shields.io/badge/Status-Work%20in%20Progress-yellow?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/minhmc2007/Blue-Archive-Linux)
 [![Architecture](https://img.shields.io/badge/Architecture-x86__64-ff6b6b?style=for-the-badge&logo=debian&logoColor=white)](#)
  [![License](https://img.shields.io/badge/License-GPL3-4ecdc4?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](#)
  [![Contributors](https://img.shields.io/github/contributors/minhmc2007/Blue-Archive-Linux?style=for-the-badge&logo=github&logoColor=white&color=purple)](#contributors)
  
  **A minimal, Blue Archive-themed Linux distribution built by Senseis, for Senseis**
  
  *Now featuring `bluepm` - our custom package manager for a seamless BA experience*
</div>

---

## 🛑 Development Status

<div align="center">

### 💙 Blue Archive Linux – Current Status

**Blue Archive Linux has been my most popular project, and I'm proud of how far it came:**

🎨 A themed Linux distro inspired by Blue Archive  
📦 bluepm, an AUR-style package manager alongside apt  
🖥️ Multiple desktop options (bal-xfce, bal-gnome, bal-kde-plasma)  
🛠️ Built and maintained across 100+ commits  

</div>

> **Note:** As of now, I've started preparing the Debian 13 base update, but it is still in debug/testing and not a final polished release. This will be my last major contribution to Blue Archive Linux.
>
> Over the past year (2025), I've made 635 commits across my repos, with 705 total since 2022 — and most of that work was packed into the past few months. Because of that heavy activity, I'm taking a break to avoid burnout.

**What's Next:**
- ✅ The repo will stay public
- ✅ Community forks are welcome  
- ✅ A friend of mine may continue active development
- ❌ I won't be pushing regular updates anymore

---

## 🚀 What Makes BAL Special?

<table>
<tr>
<td width="50%">

### 🎯 **Arch Philosophy, Debian Power**
- **Minimal CLI base** - Start with nothing, build everything
- **Zero bloat** - Install only what you need
- **Full control** - Your system, your rules
- **Stable foundation** - Debian's reliability meets customization freedom

</td>
<td width="50%">

### 💎 **Blue Archive Experience**
- **Stunning Shiroko wallpapers** (XFCE/GNOME/KDE)
- **bluepm** - An BA-focused package manager
- **Clean BA branding** throughout the system
- **More BA goodies coming soon** - SDDM themes, sounds, icons

</td>
</tr>
</table>

---

## 🎮 For the Senseis

> *"This isn't just another Linux distro with anime wallpapers. This is a complete Blue Archive computing experience."*

**Perfect for:**
- 🎌 **Blue Archive fans** who want their desktop to match their passion
- 🛠️ **Power users** who love minimal, customizable systems  
- 🧑‍💻 **Developers** who want a clean, distraction-free environment
- 🎨 **Enthusiasts** who appreciate attention to detail

---

## 🔧 bluepm Package Manager

Meet `bluepm` - our custom package manager designed specifically for Blue Archive Linux!

```bash
# Install BA-specific packages
bluepm install bal-xfce bal-kde-plasma

# Search for themes
bluepm search bal-gnome

# Multiple package installation
bluepm install pkg1 pkg2 pkg3

# Keep your system updated
bluepm update-cache
```

**Features:**
- 🚀 **Lightning fast** - GitHub-based repository
- 🎯 **BA-focused** - Curated packages for the perfect experience
- 🛡️ **Dependency smart** - Automatic dependency resolution

---

## 🎨 Visual Experience

<details>
<summary>🖼️ <strong>Click to see screenshots</strong></summary>

<div align="center">

**KDE Plasma**
<img src="docs/Screenshot_KDE.png" alt="KDE Screenshot" width="400"/>

**XFCE**
<img src="docs/Screenshot_XFCE.png" alt="XFCE Screenshot" width="400"/>

**GNOME**
<img src="docs/Screenshot_GNOME.png" alt="GNOME Screenshot" width="400"/>

</div>

**What's included:**
- 🌸 **Shiroko wallpaper**
- 🎭 **Custom SDDM login themes** - *Coming soon*
- 🎨 **Coordinated color schemes** - *In development*
- 🔊 **BA system sounds** - *Planned*
- 📱 **Custom icons** - *Planned*

</details>

---

## 🚀 Quick Start

### 🔥 **Method 1: ISO Installation** (Recommended)

#### Download the latest ISO in release
[Download latest release](https://github.com/minhmc2007/Blue-Archive-Linux/releases/latest)
#### Flash to USB (Linux)
```bash
sudo dd if=Blue_Archive_Linux*.iso of=/dev/sdX bs=4M status=progress
```
#### Flash on Windows 
Use Rufus or balenaEtcher or drag'n'drop to Ventoy

#### Boot and follow the installer or try the live environment

### 🛠️ **Method 2: Manual Build** (Advanced)
```bash
# Clone the repository
git clone https://github.com/minhmc2007/Blue-Archive-Linux.git
cd Blue-Archive-Linux && cd blue_archive_linux

# Run the build script
sudo bash build.sh

# Or using Makefile
sudo apt install docker && sudo systemctl start docker
make menuconfig
make (you might need to run it as root)

# Flash the generated ISO
```

### 🎯 **Post-Install Setup**
```bash
# Install your preferred desktop
bluepm install bal-kde-plasma  # or bal-xfce, bal-gnome

# Set up bluepm
bluepm update-cache
```

---

## 🎯 System Requirements

<div align="center">

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| 🧠 **CPU** | 64-bit x86_64 | Multi-core |
| 🧮 **RAM** | 512MB | 4GB+ |
| 💾 **Storage** | 10GB | 20GB+ |
| 📀 **Boot** | USB 2.0 | USB 3.0+ |

</div>

---

## 🧪 Community Forks Welcome

<div align="center">

### 🫡 **Calling All Senseis!**

**While active development has slowed, the community can keep BAL alive!**

<a href="https://github.com/minhmc2007/Blue-Archive-Linux/fork">
  <img src="https://img.shields.io/badge/Fork%20The%20Project-4ecdc4?style=for-the-badge&logo=github&logoColor=white" alt="Fork The Project"/>
</a>

**What you can do:**
- 🍴 Fork and continue development
- 💬 Join community discussions
- 🏆 Maintain your own version
- 🎁 Share improvements back to the community

**Current status:**
- 🐞 Limited bug fix support
- 💡 Community-driven development encouraged
- 📸 Original repo remains as reference
- 🤝 Community forks are the future

</div>

---

## 🤝 Contributing

<div align="center">

| Area | How to Help | Skills Needed |
|------|-------------|---------------|
| 🛠️ **Development** | Core system, bluepm features | Python, Bash, Linux |
| 🎨 **Design** | Themes, wallpapers, icons | Photoshop, GIMP, Figma |
| 📖 **Documentation** | Guides, tutorials, wiki | Writing, Markdown |
| 🧪 **Testing** | Beta testing, bug reports | Linux experience |
| 🌐 **Community** | GitHub discussions | Communication |

</div>

### 💻 **Development Setup**
```bash
# Fork the repository
git clone https://github.com/YourUsername/Blue-Archive-Linux.git
cd Blue-Archive-Linux

# Set up development environment
sudo apt update && sudo apt install live-build

# Make your changes and submit a PR!
```

---

## 👥 Our Amazing Team

<div align="center">

### 🧠 **Core Developers**
<table>
<tr>
<td align="center">
<a href="https://github.com/minhmc2007">
<img src="https://github.com/minhmc2007.png" width="100px;" alt="minhmc2007"/>
<br /><sub><b>@minhmc2007</b></sub>
</a>
<br />Creator & Lead Dev (Taking a break)
</td>
<td align="center">
<a href="https://github.com/dungdinhmanh">
<img src="https://github.com/dungdinhmanh.png" width="100px;" alt="dungdinhmanh"/>
<br /><sub><b>@dungdinhmanh</b></sub>
</a>
<br />Co-Developer
</td>
</tr>
</table>

### 🧪 **Beta Heroes**
<table>
<tr>
<td align="center">
<a href="https://github.com/WatashiFuzzy">
<img src="https://github.com/WatashiFuzzy.png" width="80px;" alt="WatashiFuzzy"/>
<br /><sub><b>@WatashiFuzzy</b></sub>
</a>
<br />Beta Testing Lead (no longer testing)
</td>
<td align="center">
<a href="https://github.com/minhmc2007/Blue-Archive-Linux/fork">
<img src="https://via.placeholder.com/80x80/4ecdc4/ffffff?text=You" width="80px;" alt="Fork Us"/>
<br /><sub><b>You?</b></sub>
</a>
<br />Fork & Continue!
</td>
</tr>
</table>

</div>

---

## 💬 Community & Support

<div align="center">

**Get Help & Stay Connected**

[![GitHub Issues](https://img.shields.io/badge/GitHub-Issues-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/minhmc2007/Blue-Archive-Linux/issues)
[![Telegram](https://img.shields.io/badge/Telegram-Official%20Group-0088cc?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/blue_archive_linux)
[![Email](https://img.shields.io/badge/Email-quangminh21072010@gmail.com-red?style=for-the-badge&logo=gmail&logoColor=white)](mailto:quangminh21072010@gmail.com)

**Join our official Telegram group:** [https://t.me/blue_archive_linux](https://t.me/blue_archive_linux)

</div>

---

## 📄 License & Credits

<div align="center">

**Blue Archive Linux** is licensed under the GPL 3 License.

**Special Thanks:**
- 🎮 **Nexon** - For creating Blue Archive
- 🐧 **Debian Project** - For the solid foundation  
- 🎨 **Blue Archive Community** - For inspiration and support
- 💻 **Open Source Community** - For the tools that make this possible
- Read CREDIT.md for more information

---

## 💙 Final Words

<div align="center">

**To everyone who starred, forked, or just downloaded Blue Archive Linux — thank you.**

Even if this project ends with a debug release, it remains my most popular repo and a highlight of what I've built so far.

**— Quang Minh (minhmc2007)**

*635 commits in 2025 • 705 total commits since 2022*

</div>

---

<div align="center">
  <img src="logo.png" alt="Blue Archive Linux" width="100"/>
  
  **Made with 💙 by Senseis, for Senseis**
  
  *"A minimal system with maximum Blue Archive vibes"*
  
  ⭐ **Star us on GitHub** if you're excited about BAL!
</div>

</div>
