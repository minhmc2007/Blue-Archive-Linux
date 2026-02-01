#!/usr/bin/env bash

# === 1. KERNEL PARAMETER HANDLER ===
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

# === 2. STARTUP LOGIC ===
if [[ $(tty) == "/dev/tty1" ]]; then

    # Run the original automated script logic if present
    automated_script

    echo "--- Preparing Blue Archive Linux GUI ---"

    # A. Setup Autostart for the Welcome App
    # This ensures the app opens as soon as Plasma loads
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

    # B. Start Xorg and Plasma
    # The Flutter app will handle setting the wallpaper once it's open
    echo "Handing over to Plasma X11..."
    exec startx /usr/bin/startplasma-x11
    kwriteconfig6 --file plasmarc --group PlasmaWelcome --key Enabled false

fi
