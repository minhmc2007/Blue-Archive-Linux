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
pacman_conf="pacman.conf" # Make sure this pacman.conf is suitable for building the airootfs
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')

# --- Boot Modes ---
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')

# --- File Permissions ---
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
_prepare_airootfs() {
    # 1. Set the default Plymouth theme and rebuild the initramfs to include it.
    # This rebuilds the initramfs *within the airootfs*.
    # The ISO's *boot* initramfs is handled separately by mkarchiso.
    arch-chroot "${airootfs_dir}" plymouth-set-default-theme -R blue-archive-plymouth

    # 2. Enable essential services
    arch-chroot "${airootfs_dir}" systemctl enable sddm.service
    arch-chroot "${airootfs_dir}" systemctl enable systemd-networkd.service
    arch-chroot "${airootfs_dir}" systemctl enable systemd-resolved.service
    # Potentially enable other services like bluetooth, cups, etc. if needed by default

    # 3. Set default target to graphical
    arch-chroot "${airootfs_dir}" systemctl set-default graphical.target

    # 4. Optional: Clean up pacman cache to reduce ISO size
    arch-chroot "${airootfs_dir}" pacman -Scc --noconfirm

    # 5. Optional: Other customizations (e.g., adding users, setting locale)
    # arch-chroot "${airootfs_dir}" useradd -m -G wheel -s /bin/bash liveuser
    # arch-chroot "${airootfs_dir}" passwd -d liveuser # Remove password for live user
    # echo "liveuser ALL=(ALL) NOPASSWD: ALL" > "${airootfs_dir}/etc/sudoers.d/liveuser"
    # chmod 440 "${airootfs_dir}/etc/sudoers.d/liveuser"
    # arch-chroot "${airootfs_dir}" ln -sf /usr/share/zoneinfo/Your/Timezone /etc/localtime
    # echo "en_US.UTF-8 UTF-8" > "${airootfs_dir}/etc/locale.gen"
    # echo "LANG=en_US.UTF-8" > "${airootfs_dir}/etc/locale.conf"
    # arch-chroot "${airootfs_dir}" locale-gen
}
