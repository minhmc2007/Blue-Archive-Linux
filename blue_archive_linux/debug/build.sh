#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

echo "--- [build.sh] Cleaning previous live-build state thoroughly..."
sudo lb clean --all # Use --all to remove *all* artifacts, including config/

echo "--- [build.sh] Explicitly configuring live-build for Trixie..."
sudo lb config noauto \
    --mode debian \
    --system live \
    --architecture amd64 \
    --distribution trixie \
    --archive-areas "main contrib non-free non-free-firmware" \
    --debian-installer live \
    --debian-installer-gui false \
    --iso-application "Blue Archive Linux" \
    --iso-volume "Blue Archive Linux" \
    --iso-publisher "minhmc2007" \
    --memtest memtest86+ \
    --bootappend-live "boot=live" \
    --binary-images iso-hybrid

echo "--- [build.sh] Starting live-build process for Trixie..."
sudo lb build

echo "--- [build.sh] Moving generated ISO..."
mv live-image-amd64.hybrid.iso "Blue_Archive_Linux_amd64_debug_$(date +'%I-%M%p_%d-%m-%Y').iso"
echo "--- [build.sh] ISO build complete."
