# Icons
echo "-> Installing and applying icon theme..."
USER_ICONS_DIR="$HOME/.icons"

# Create directory and unpack theme
mkdir -p "$USER_ICONS_DIR" || handle_warning "Failed to create icon directory"
tar -xf "$SCRIPT_DIR/themes/icons/Reversal-orange.tar.xz" -C "$USER_ICONS_DIR" || handle_warning "Failed to unpack icon theme"

# Set the icon theme
gsettings set org.gnome.desktop.interface icon-theme "Reversal-orange" || handle_warning "Failed to set icon theme (is gsettings installed?)"

# Cursor
echo "-> Installing and applying cursor theme..."
ICONS_DIR="/usr/share/icons"
sudo mkdir -p "$ICONS_DIR" || handle_warning "Failed to create icon directory"
sudo tar -xf "$SCRIPT_DIR/themes/icons/Future-cursors.tar.gz" -C "$ICONS_DIR" || handle_warning "Failed to unpack icon theme"

# Set cursor theme system-wide
echo "-> Setting cursor theme system-wide..."
{
    echo "XCURSOR_THEME=Future-cursors"
    echo "XCURSOR_SIZE=24"
} | sudo tee -a /etc/environment
