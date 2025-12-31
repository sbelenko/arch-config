#!/bin/bash

echo ""
read -p "Do you want to zram setup? (y/N): " answer

if [[ "$answer" =~ ^[Yy] ]]; then
    # Verify
    echo "Verifying configuration..."
    if sudo NetworkManager --print-config | grep -q "[zram0]"; then
        printf "[zram0]\nwzram-size = ram / 2\n" | sudo tee /etc/systemd/zram-generator.conf > /dev/null
        echo "Zram configuration applied successfully."
    else
        echo "ERROR: Configuration failed to apply."
    fi
else
    echo "Skipping iwd configuration."
fi
