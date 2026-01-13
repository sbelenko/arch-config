# Install the custom SDDM theme to the system themes directory
sudo cp -rf "$SCRIPT_DIR/themes/sddm/material-lite" "/usr/share/sddm/themes/" || handle_warning "Failed to copy SDDM theme"

# Create /etc/sddm.conf and set the active theme
echo -e "[Theme]\nCurrent=material-lite" | sudo tee /etc/sddm.conf > /dev/null || handle_warning "Failed to create sddm.conf"
