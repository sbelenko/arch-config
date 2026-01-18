echo "-> Installing and applying icon theme..."

USER_ICONS_DIR="$HOME/.icons"
ICON_THEME_NAME="Reversal-orange"

# Create directory and unpack theme
mkdir -p "$USER_ICONS_DIR" || handle_warning "Failed to create icon directory"
tar -xf "$SCRIPT_DIR/themes/icons/Reversal-orange.tar.xz" -C "$USER_ICONS_DIR" || handle_warning "Failed to unpack icon theme"

# Set the icon theme
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME_NAME" || handle_warning "Failed to set icon theme (is gsettings installed?)"
