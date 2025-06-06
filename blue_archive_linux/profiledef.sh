#!/usr/bin/env bash
# shellcheck disable=SC2034

# --- General ISO Settings ---
iso_name="Blue-Archive-Linux"
iso_label="BLUE_ARCH_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="minhmc2007 <https://github.com/minhmc2007/Blue-Archive-Linux>"
iso_application="Blue Archive Linux Install Medium"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"

# --- Build Configuration ---
install_dir="arch"
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')

# --- Boot Modes ---
# These are the boot methods your ISO will support.
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')

# --- File Permissions ---
# This sets specific permissions for files inside the final ISO.
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)


# --- Custom Build Function ---
# This special function (_prepare_airootfs) is run by archiso after installing packages.
# It's the perfect place for final system configuration.

_prepare_airootfs() {
    # The 'arch-chroot' command runs the command *inside* the filesystem being built.
    
    # 1. Set the default Plymouth theme and rebuild the initramfs to include it.
    arch-chroot "${airootfs_dir}" plymouth-set-default-theme -R blue-archive-plymouth

    # 2. Enable the graphical login manager (SDDM) to start on boot.
    arch-chroot "${airootfs_dir}" systemctl enable sddm.service

    # 3. Enable networking services to start on boot.
    arch-chroot "${airootfs_dir}" systemctl enable systemd-networkd.service
    arch-chroot "${airootfs_dir}" systemctl enable systemd-resolved.service
}
