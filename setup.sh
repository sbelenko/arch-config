#!/bin/bash

# ==========================================
# Arch Linux Unified Installation Script
# Target: Intel N150 (Alder Lake-N)
# Environment: Hyprland (Wayland)
# ==========================================

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Stop script execution on critical errors
set -e

# Error handling function
handle_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# --- SMART CHECKS ---
# 1. Check Internet
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${RED}[ERROR] No internet connection.${NC}"
    exit 1
fi

# 2. Keep Sudo Alive (background loop)
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Get the directory where this script is located
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo -e "${GREEN}=== [1/7] Preparing Package List ===${NC}"

packages=(
  # --- System Core & Drivers (Critical for N150) ---
  linux-firmware        # REQUIRED: GPU firmware for Plymouth/Early KMS
  intel-ucode           # REQUIRED: CPU Microcode (Stability & Errata Fixes)
  thermald              # CRITICAL: Prevents throttling
  nano                  # Console text editor
  unzip                 # Archive tools (Extract)
  zip                   # Archive tools (Create)
  xdg-user-dirs         # REQUIRED: To generate standard folders
  flatpak               # Package manager for sandboxed apps

  # --- Drivers (Intel GPU) ---
  vulkan-intel          # Vulkan
  intel-media-driver    # VA-API (Video Acceleration)

  # --- Hyprland Ecosystem ---
  hyprland
  hyprpaper             # Wallpapers
  hypridle              # Idle daemon
  hyprlock              # Lock screen
  hyprpolkitagent       # Auth agent (GUI sudo)

  # --- Portals (Crucial for interaction) ---
  xdg-desktop-portal-hyprland # Screen sharing & Hyprland specifics
  xdg-desktop-portal-gtk      # File picker dialogs & Dark theme sync

  # --- Qt Support ---
  qt5-wayland           # Qt5 Wayland support (Crucial for UI consistency)
  qt6-wayland           # Qt6 Wayland support

  # --- UI Components ---
  waybar                 # Status bar
  network-manager-applet # Wi-Fi tray icon for Waybar (Crucial for UX)
  swaync                 # Notifications
  nwg-look               # GTK Theme manager
  plymouth               # Boot splash
  sddm                   # Login manager
  rofi-wayland           # Launcher
  wlogout                # Logout menu

  # --- Utilities ---
  slurp grim            # Screenshots
  wl-clipboard          # Clipboard (Essential)
  kitty                 # Terminal
  nautilus              # File manager
  loupe                 # Image viewer
  evince                # Document viewer
  zed                   # Code editor

  # --- Audio & Bluetooth ---
  pavucontrol           # GUI Volume mixer
  blueman               # GUI Bluetooth manager

  # --- Fonts ---
  noto-fonts
  noto-fonts-emoji
  inter-font
  ttf-jetbrains-mono-nerd
)

echo -e "${GREEN}=== [2/7] Installing Packages ===${NC}"
# Update databases and install
if ! sudo pacman -Syu --noconfirm; then
    echo -e "${RED}System update failed.${NC}"
    exit 1
fi

if ! sudo pacman -S "${packages[@]}" --noconfirm --needed; then
    echo -e "${RED}Package installation failed.${NC}"
    exit 1
fi

# Enable services
echo "-> Enabling system services..."
sudo systemctl enable sddm || handle_warning "Failed to enable sddm"

# Enable Thermal Daemon for CPU performance
sudo systemctl enable thermald || handle_warning "Failed to enable thermald"

echo -e "${GREEN}=== [3/7] Applying Configuration (Dotfiles) ===${NC}"
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

echo -e "${GREEN}=== [4/7] Installing Flatpak Apps ===${NC}"
# Smart fix: Add repo first
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || handle_warning "Failed to add flathub repo"

flatpak install -y flathub com.google.Chrome || handle_warning "Failed to install Chrome"
flatpak install -y flathub com.slack.Slack || handle_warning "Failed to install Slack"

echo -e "${GREEN}=== [5/7] Configuring Perfect Boot (Plymouth & Early KMS) ===${NC}"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

if [ -f "$MKINITCPIO_CONF" ]; then
    # 1. Add i915 module (Intel Early KMS) - Critical for Plymouth
    if ! grep -q "i915" "$MKINITCPIO_CONF"; then
        echo "-> Adding i915 to MODULES..."
        sudo sed -i 's/MODULES=(/MODULES=(i915 /' "$MKINITCPIO_CONF" || handle_warning "Failed to add i915"
    fi

    # 2. Add plymouth hook
    if ! grep -q "plymouth" "$MKINITCPIO_CONF"; then
        echo "-> Adding plymouth to HOOKS..."
        sudo sed -i 's/\budev\b/udev plymouth/g' "$MKINITCPIO_CONF" || handle_warning "Failed to add plymouth hook"
    fi

    # 3. Apply Theme & Rebuild Initramfs
    CUSTOM_THEME_NAME="arch-theme"
    SOURCE_THEME="$SCRIPT_DIR/themes/plymouth/$CUSTOM_THEME_NAME"
    DEST_THEME="/usr/share/plymouth/themes/$CUSTOM_THEME_NAME"

    if [ -d "$SOURCE_THEME" ]; then
        echo "-> Installing custom theme: $CUSTOM_THEME_NAME..."
        sudo mkdir -p "$DEST_THEME"
        sudo cp -r "$SOURCE_THEME/"* "$DEST_THEME/"

        echo "-> Building initramfs with $CUSTOM_THEME_NAME..."
        sudo plymouth-set-default-theme -R "$CUSTOM_THEME_NAME" || handle_warning "Failed to set custom theme"
    else
        handle_warning "Custom theme not found at $SOURCE_THEME"
        echo "-> Falling back to standard spinner..."
        sudo plymouth-set-default-theme -R spinner || handle_warning "Failed to build initramfs"
    fi
else
    handle_warning "$MKINITCPIO_CONF not found"
fi

# 4. Silent Boot Params
ENTRIES_DIR="/boot/loader/entries"
BOOT_PARAMS="quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0"

if [ -d "$ENTRIES_DIR" ]; then
    for file in "$ENTRIES_DIR"/*.conf; do
        [ -f "$file" ] || continue
        if ! grep -q "splash" "$file"; then
            echo "-> Updating bootloader: $file"
            sudo sed -i "/^options/ s/$/ $BOOT_PARAMS/" "$file" || handle_warning "Failed to update $file"
        fi
    done
else
    handle_warning "Bootloader config not found (checked $ENTRIES_DIR)"
fi

echo -e "${GREEN}=== [6/7] Network Configuration (Optional) ===${NC}"
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

echo -e "${GREEN}=== [7/7] ZRAM Configuration (Memory Optimization) ===${NC}"
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

echo ""
echo -e "${GREEN}=== INSTALLATION COMPLETE ===${NC}"
echo "Please reboot your system."
