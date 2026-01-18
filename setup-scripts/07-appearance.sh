#!/bin/bash
# Exit on error
set -e

echo "Setting up appearance..."

# Define and create user icons directory
USER_ICONS_DIR="$HOME/.local/share/icons"
mkdir -p "$USER_ICONS_DIR"

# Unpack icon theme to user directory
tar -xf $(pwd)/themes/icons/Reversal-orange.tar.xz -C "$USER_ICONS_DIR"

# Apply icon theme if gsettings command is available
gsettings set org.gnome.desktop.interface icon-theme "Reversal-orange"

echo "Appearance setup complete."
