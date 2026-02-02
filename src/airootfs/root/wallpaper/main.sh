#!/bin/bash
# --- CONFIG ---
IMG="img.png"
# Ensure we get the absolute path, otherwise KDE might fail to find the file
ABS_IMG=$(readlink -f "$IMG")

echo "--- STARTING NATIVE THEME SYNC ---"

# 1. THEME CHECK
# Avoid reloading if already set to save time.
CURRENT_THEME=$(kreadconfig6 --group General --key LookAndFeelPackage 2>/dev/null || echo "unknown")

if [[ "$CURRENT_THEME" != "org.kde.breezedark.desktop" ]]; then
    echo "Switching to Breeze Dark..."
    plasma-apply-lookandfeel -a org.kde.breezedark.desktop
    sleep 2
fi

# 2. SET WALLPAPER
echo "Setting Wallpaper to $ABS_IMG..."

# KDE 6 / KDE 5 Dual Support
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allDesktops = desktops();
    for (i=0;i<allDesktops.length;i++) {
        d = allDesktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
        d.writeConfig('Image', 'file://$ABS_IMG');
    }
" 2>/dev/null || \
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allDesktops = desktops();
    for (i=0;i<allDesktops.length;i++) {
        d = allDesktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
        d.writeConfig('Image', 'file://$ABS_IMG');
    }
"

# 3. ENABLE NATIVE AUTO-COLOR
echo "Enabling Native Accent Color Engine..."
kwriteconfig6 --file kdeglobals --group General --key AccentColorFromWallpaper "true" 2>/dev/null || \
kwriteconfig5 --file kdeglobals --group General --key AccentColorFromWallpaper "true"

kwriteconfig6 --file kdeglobals --group General --key AccentColor "" 2>/dev/null || \
kwriteconfig5 --file kdeglobals --group General --key AccentColor ""

# 4. RESTART PLASMASHELL (DETACHED)
echo "Restarting Plasma Shell..."

# Kill the existing instance first to ensure a clean restart
kquitapp6 plasmashell 2>/dev/null || killall plasmashell 2>/dev/null

# Wait briefly for it to close
sleep 0.5

# Start it completely detached so Dart doesn't hang waiting for it
# nohup + >/dev/null 2>&1 is the critical fix here
nohup plasmashell >/dev/null 2>&1 &

echo "Done."
exit 0
