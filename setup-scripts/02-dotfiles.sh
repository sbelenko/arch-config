mkdir -p "$HOME/.config"

echo "-> Copying configs from 'dots'..."
cp -rf "$SCRIPT_DIR/dots/"* "$HOME/.config/" || handle_warning "Failed to copy config files"

# Locale (ru_UA)
echo "-> Setting Locale..."
sudo sed -i '/^#\s*ru_UA\.UTF-8/s/^#\s*//' /etc/locale.gen || handle_warning "Failed to edit locale.gen"
sudo locale-gen || handle_warning "Failed to generate locale"

# Fonts & GTK
echo "-> Setting Fonts..."
gsettings set org.gnome.desktop.interface font-name 'Inter 11' || handle_warning "Failed to set font"
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11' || handle_warning "Failed to set monospace"
fc-cache -f >/dev/null 2>&1 || true

# User Dirs
LC_ALL=C xdg-user-dirs-update --force || handle_warning "Failed to update user dirs"
