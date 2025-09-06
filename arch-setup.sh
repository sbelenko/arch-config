#!/bin/bash

# Current script directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# List of packages
packages=(
  nano # Console text editor
  kitty # Terminal
  hyprland # Tiling Wayland compositor
  hyprpaper # Wallpaper utility
  hypridle # Idle screen manager
  hyprlock # Screen locker
  xdg-desktop-portal-hyprland # XDG portal for Wayland apps
  sddm # Display manager
  flatpak # Package manager for sandboxed apps
  waybar # Wayland status bar
  nautilus # File manager
  wofi # Application launcher
  mako # Notification daemon
  git # Version control system
  bluez bluez-utils blueman #bluetooth
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
sed -i 's/#ru_UA.UTF-8/ru_UA.UTF-8/' /etc/locale.gen

# Generate the locales
sudo locale-gen
# -------- End Locale --------

# -------- Hyprland setup --------
rm -r "$HOME/.config/hypr/"
cp -r "$SCRIPT_DIR/hypr/" "$HOME/.config/hypr/"

# Hyprpaper
cp -r "$SCRIPT_DIR/wallpapers/" "$HOME/.config/wallpapers/"
sed -i "s|-USERNAME-|$USER|g" ~/.config/hypr/hyprpaper.conf

# -------- Waybar setup --------
rm -r "$HOME/.config/waybar/"
cp -r "$SCRIPT_DIR/waybar/" "$HOME/.config/waybar/"

# -------- Enable bluetooth service --------
sudo systemctl enable --now bluetooth.service