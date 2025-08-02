#!/bin/bash

# List of packages
packages=(
  nano # Console text editor
  kitty # Terminal
  hyprland # Tiling Wayland compositor
  hyprpaper # Wallpaper utility
  hyprlock # Screen locker
  xdg-desktop-portal-hyprland # XDG portal for Wayland apps
  sddm # Display manager
  flatpak # Package manager for sandboxed apps
  waybar # Wayland status bar
  nautilus # File manager
  wofi # Application launcher
  mako # Notification daemon
  git # Version control system
)

# Update the system
sudo pacman -Syu --noconfirm

# Install the packages
sudo pacman -S "${packages[@]}" --noconfirm

# Enable the display manager to start on boot
sudo systemctl enable sddm # Enable sddm

# -------- Locale --------
# Find and uncomment the line for ru_UA.UTF-8 in /etc/locale.gen
sudo sed -i '/^#\s*ru_UA\.UTF-8/s/^#\s*//' /etc/locale.gen

# Generate the locales
sudo locale-gen
# -------- End Locale --------

# Display a message before the Hyprland setup
echo "Starting Hyprland setup..."

