#!/usr/bin/env bash
set -e

# Change to the directory where the script is located
cd "$(dirname "$0")"

PROFILE_DEF="profiledef.sh"
# Using a temp file to safely handle restoration
TMP_PROFILE_DEF="profiledef.sh.bak"

# Handle debug flag
if [[ "$1" == "--debug" ]]; then
    echo "Enabling debug mode (no compression)..."
    cp "$PROFILE_DEF" "$TMP_PROFILE_DEF"
    sed -i "s/airootfs_image_tool_options=.*/airootfs_image_tool_options=('-no-compression')/" "$PROFILE_DEF"
    
    # Ensure we restore on exit
    trap 'echo "Restoring original profiledef.sh..."; mv "$TMP_PROFILE_DEF" "$PROFILE_DEF"' EXIT
fi

# Run mkarchiso
sudo rm -rf work out
sudo mkarchiso -v -w work -o out .
