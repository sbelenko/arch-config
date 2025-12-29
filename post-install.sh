#!/bin/bash

# Define dependencies
packages=(
  iwd # iwd network
)

# Update the system
sudo pacman -Syu --noconfirm

# Install the packages
sudo pacman -S "${packages[@]}" --noconfirm --needed

# Create config file
# Using 'tee' ensures root permissions. '> /dev/null' keeps the terminal output clean.
printf "[device]\nwifi.backend=iwd\n" | sudo tee /etc/NetworkManager/conf.d/iwd.conf > /dev/null

# Restart NetworkManager to apply changes
sudo systemctl restart NetworkManager

# Verify
echo "Verifying configuration..."
if sudo NetworkManager --print-config | grep -q "backend=iwd"; then
    echo "SUCCESS: NetworkManager is now using iwd backend."
else
    echo "ERROR: Configuration failed to apply."
fi
