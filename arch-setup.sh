#!/bin/bash

# Current script directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# List of packages
packages=(
  # --- System & Utilities ---
  nano # Console text editor
  flatpak # Package manager for sandboxed apps
  unzip # Archive tools

  # --- Hyprland & Wayland Core ---
  hyprland # Tiling Wayland compositor
  hyprpaper # Wallpaper utility
  hypridle # Idle screen manager
  hyprlock # Screen locker
  hyprpolkitagent # It is required for GUI applications to be able to request elevated privileges
  xdg-desktop-portal-hyprland # XDG portal for Wayland apps
  waybar # Wayland status bar
  mako # Notification daemon
  slurp grim # Screenshot tools
  rofi # Application launcher

  # --- Terminal & File Manager ---
  kitty # Terminal
  nautilus # File manager

  # --- Audio (completing the base install) ---
  pavucontrol     # GUI mixer for audio

  # --- Bluetooth ---
  blueman # GUI

  # --- Drivers ---
  vulkan-intel
  intel-media-driver

  # --- Fonts ---
  noto-fonts # Base fonts for wide language support
  noto-fonts-emoji # Emoji support

  # --- Appearance ---
  nwg-look # GTK theme switcher

  # --- Display Manager ---
  sddm # Display manager
)

# Update the system
sudo pacman -Syu --noconfirm

# Install the packages
sudo pacman -S "${packages[@]}" --noconfirm

# Enable the display manager to start on boot
sudo systemctl enable sddm

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
