read -p "Switch NetworkManager backend to iwd (Recommended)? (y/N): " answer
if [[ "$answer" =~ ^[Yy] ]]; then
    sudo pacman -S --noconfirm --needed iwd || handle_warning "Failed to install iwd"

    if [ -d "/etc/NetworkManager/conf.d" ]; then
        printf "[device]\nwifi.backend=iwd\n" | sudo tee /etc/NetworkManager/conf.d/iwd.conf > /dev/null
        sudo systemctl restart NetworkManager || handle_warning "Failed to restart NetworkManager"
        sudo systemctl stop wpa_supplicant 2>/dev/null || true
        sudo systemctl disable wpa_supplicant 2>/dev/null || true
        echo "-> NetworkManager switched to iwd."
    else
        handle_warning "NetworkManager conf dir not found"
    fi
fi

read -p "Enable ZRAM (ram / 2)? (y/N): " answer
if [[ "$answer" =~ ^[Yy] ]]; then
    ZRAM_CONF="/etc/systemd/zram-generator.conf"

    # Check if config file exists
    if [ -f "$ZRAM_CONF" ]; then
        # Ensure Header exists
        grep -q "^\[zram0\]" "$ZRAM_CONF" || echo "[zram0]" | sudo tee -a "$ZRAM_CONF" > /dev/null

        # Configure Size (Update or Append)
        grep -q "zram-size" "$ZRAM_CONF" \
            && sudo sed -i 's|^zram-size.*|zram-size = ram / 2|' "$ZRAM_CONF" \
            || echo "zram-size = ram / 2" | sudo tee -a "$ZRAM_CONF" > /dev/null

        # Configure Algorithm (Update or Append) - CRITICAL for Performance
        grep -q "compression-algorithm" "$ZRAM_CONF" \
            && sudo sed -i 's|^compression-algorithm.*|compression-algorithm = zstd|' "$ZRAM_CONF" \
            || echo "compression-algorithm = zstd" | sudo tee -a "$ZRAM_CONF" > /dev/null

        # Reload and restart service
        sudo systemctl daemon-reload
        sudo systemctl restart systemd-zram-setup@zram0.service 2>/dev/null || handle_warning "Failed to start ZRAM"
        echo "-> ZRAM enabled."

    else
        handle_warning "$ZRAM_CONF not found! Skipping ZRAM setup."
    fi
fi
