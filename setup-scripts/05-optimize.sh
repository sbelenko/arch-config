read -p "Enable ZRAM (ram / 2)? (y/N): " answer
if [[ "$answer" =~ ^[Yy] ]]; then
    ZRAM_CONF="/etc/systemd/zram-generator.conf"
    
    echo "-> Configuring ZRAM..."
    # Create or overwrite the config file with the optimal settings
    echo "[zram0]
zram-size = ram / 2
compression-algorithm = zstd" | sudo tee "$ZRAM_CONF" > /dev/null

    # Reload and restart service
    sudo systemctl daemon-reload
    sudo systemctl restart systemd-zram-setup@zram0.service 2>/dev/null || handle_warning "Failed to start ZRAM"
    echo "-> ZRAM enabled."
fi
