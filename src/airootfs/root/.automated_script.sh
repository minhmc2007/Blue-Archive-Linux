#!/usr/bin/env bash

# === 1. ORIGINAL KERNEL PARAMETER LOGIC ===
script_cmdline() {
    local param
    for param in $(</proc/cmdline); do
        case "${param}" in
            script=*)
                echo "${param#*=}"
                return 0
                ;;
        esac
    done
}

automated_script() {
    local script rt
    script="$(script_cmdline)"
    if [[ -n "${script}" && ! -x /tmp/startup_script ]]; then
        if [[ "${script}" =~ ^((http|https|ftp|tftp)://) ]]; then
            printf '%s: Waiting for network...\n' "$0"
            until systemctl --quiet is-active network-online.target; do
                sleep 1
            done
            curl "${script}" --location --retry-connrefused --retry 10 --fail -s -o /tmp/startup_script
            rt=$?
        else
            cp "${script}" /tmp/startup_script
            rt=$?
        fi
        if [[ ${rt} -eq 0 ]]; then
            chmod +x /tmp/startup_script
            /tmp/startup_script
        fi
    fi
}

# === 2. MAIN STARTUP LOGIC ===
if [[ $(tty) == "/dev/tty1" ]]; then

    automated_script

    echo "--- Preparing Blue Archive Linux GUI ---"

    # A. Setup bal-welcome Autostart
    mkdir -p /etc/xdg/autostart
    cat <<EOF > /etc/xdg/autostart/bal-welcome.desktop
[Desktop Entry]
Type=Application
Name=Blue Archive Linux Welcome
Exec=/usr/bin/bal-welcome
Icon=bal-welcome
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

    # B. WALLPAPER LOGIC (The Fix)
    # 1. Pick a random wallpaper
    RAND_WP=$(find /usr/share/backgrounds -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n 1)

    # 2. Create a dedicated script to apply this specific wallpaper
    # We use 'plasma-apply-wallpaperimage' which talks to the running desktop
    cat <<EOF > /usr/local/bin/bal-wallpaper-setup
#!/bin/bash
# Wait a few seconds for Plasma to be fully ready
sleep 5
if [ -f "$RAND_WP" ]; then
    # Try the standard command
    plasma-apply-wallpaperimage "$RAND_WP"
fi
EOF
    chmod +x /usr/local/bin/bal-wallpaper-setup

    # 3. Create an Autostart entry for this wallpaper script
    cat <<EOF > /etc/xdg/autostart/bal-wallpaper.desktop
[Desktop Entry]
Type=Application
Name=Set Wallpaper
Exec=/usr/local/bin/bal-wallpaper-setup
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

    # C. Launch GUI
    echo "Handing over to Plasma X11..."
    exec startx /usr/bin/startplasma-x11
fi
