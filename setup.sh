#!/bin/bash

# ==========================================
# Arch Linux Unified Installation Script
# Target: Intel N100/N150 (Alder Lake-N)
# Environment: Hyprland (Wayland)
# ==========================================

# Stop script execution on any error
set -e

# Get the directory where this script is located
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "=== [1/7] Preparing Package List ==="

packages=(
  # --- System Core & Drivers (Critical for N150) ---
  linux-firmware        # REQUIRED: GPU firmware for Plymouth/Early KMS
  base-devel            # Build tools
  nano                  # Console text editor
  unzip                 # Archive tools
  flatpak               # Package manager for sandboxed apps

  # --- Drivers (Intel GPU) ---
  vulkan-intel          # Vulkan
  intel-media-driver    # VA-API (Video Acceleration)
  mesa

  # --- Hyprland Ecosystem ---
  hyprland
  hyprpaper             # Wallpapers
  hypridle              # Idle daemon
  hyprlock              # Lock screen
  hyprpolkitagent       # Auth agent (GUI sudo)
  hyprlauncher          # Launcher (Native Hyprland tool)
  xdg-desktop-portal-hyprland

  # --- UI Components ---
  waybar                # Status bar
  mako                  # Notifications
  nwg-look              # GTK Theme manager
  plymouth              # Boot splash
  sddm                  # Login manager

  # --- Utilities ---
  slurp grim            # Screenshots
  wl-clipboard          # Clipboard (Essential)
  kitty                 # Terminal
  nautilus              # File manager
  loupe                 # Image viewer
  evince                # Document viewer
  zed                   # Code editor

  # --- Audio & Bluetooth ---
  pavucontrol
  blueman

  # --- Fonts ---
  noto-fonts
  noto-fonts-emoji
  inter-font
  ttf-jetbrains-mono-nerd # Nerd Font (Standard Repo)
)

echo "=== [2/7] Installing Packages ==="
# Update databases and install
sudo pacman -Syu --noconfirm
sudo pacman -S "${packages[@]}" --noconfirm --needed

# Enable services
echo "-> Enabling system services..."
sudo systemctl enable sddm

echo "=== [3/7] Applying Configuration (Dotfiles) ==="

# Hyprland
echo "-> Configuring Hyprland..."
rm -rf "$HOME/.config/hypr/"
cp -r "$SCRIPT_DIR/hypr/" "$HOME/.config/hypr/" 2>/dev/null || echo "WARNING: hypr folder missing"

# Wallpapers
echo "-> Configuring Wallpapers..."
cp -r "$SCRIPT_DIR/wallpapers/" "$HOME/.config/wallpapers/" 2>/dev/null || echo "WARNING: wallpapers folder missing"
# Inject username
sed -i "s|-USERNAME-|$USER|g" ~/.config/hypr/hyprpaper.conf 2>/dev/null || true

# Waybar
echo "-> Configuring Waybar..."
rm -rf "$HOME/.config/waybar/"
cp -r "$SCRIPT_DIR/waybar/" "$HOME/.config/waybar/" 2>/dev/null || echo "WARNING: waybar folder missing"

# Locale (ru_UA)
echo "-> Setting Locale..."
sudo sed -i '/^#\s*ru_UA\.UTF-8/s/^#\s*//' /etc/locale.gen
sudo locale-gen

# Fonts & GTK
echo "-> Setting Fonts..."
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'

# User Dirs
LC_ALL=C xdg-user-dirs-update --force

echo "=== [4/7] Installing Flatpak Apps ==="
flatpak install -y flathub com.google.Chrome
flatpak install -y flathub com.visualstudio.code
flatpak install -y flathub com.slack.Slack

echo "=== [5/7] Configuring Perfect Boot (Plymouth & Early KMS) ==="
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# 1. Add i915 module (Intel Early KMS) - Critical for Plymouth
if ! grep -q "i915" "$MKINITCPIO_CONF"; then
    echo "-> Adding i915 to MODULES..."
    sudo sed -i 's/MODULES=(/MODULES=(i915 /' "$MKINITCPIO_CONF"
fi

# 2. Add plymouth hook
if ! grep -q "plymouth" "$MKINITCPIO_CONF"; then
    echo "-> Adding plymouth to HOOKS..."
    sudo sed -i 's/\budev\b/udev plymouth/g' "$MKINITCPIO_CONF"
fi

# 3. Apply Theme & Rebuild Initramfs
echo "-> Building initramfs with spinner theme..."
# This runs mkinitcpio -P automatically
sudo plymouth-set-default-theme -R spinner

# 4. Silent Boot Params
ENTRIES_DIR="/boot/loader/entries"
BOOT_PARAMS="quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0"

if [ -d "$ENTRIES_DIR" ]; then
    for file in "$ENTRIES_DIR"/*.conf; do
        [ -f "$file" ] || continue
        if ! grep -q "splash" "$file"; then
            echo "-> Updating bootloader: $file"
            sudo sed -i "/^options/ s/$/ $BOOT_PARAMS/" "$file"
        fi
    done
else
    echo "WARNING: Bootloader config not found (checked $ENTRIES_DIR)"
fi

echo "=== [6/7] Network Configuration (Optional) ==="
read -p "Switch NetworkManager backend to iwd (Recommended)? (y/N): " answer
if [[ "$answer" =~ ^[Yy] ]]; then
    sudo pacman -S --noconfirm --needed iwd
    printf "[device]\nwifi.backend=iwd\n" | sudo tee /etc/NetworkManager/conf.d/iwd.conf > /dev/null
    sudo systemctl restart NetworkManager
    sudo systemctl stop wpa_supplicant 2>/dev/null || true
    sudo systemctl disable wpa_supplicant 2>/dev/null || true
    echo "-> NetworkManager switched to iwd."
fi

echo "=== [7/7] ZRAM Configuration (Memory Optimization) ==="
read -p "Enable ZRAM (ram / 2)? (y/N): " answer
if [[ "$answer" =~ ^[Yy] ]]; then
    sudo pacman -S --noconfirm --needed zram-generator
    ZRAM_CONF="/etc/systemd/zram-generator.conf"

    # Check if config file exists
    if [ ! -f "$ZRAM_CONF" ]; then
        echo "WARNING: $ZRAM_CONF not found! Skipping ZRAM setup."
        echo "Please ensure the zram-generator package created the default config."
    else
        # File exists, proceed with configuration
        if grep -q "zram-size" "$ZRAM_CONF"; then
            echo "-> ZRAM is already configured. Skipping."
        else
            # If [zram0] exists, append parameters after it
            if grep -q "\[zram0\]" "$ZRAM_CONF"; then
                echo "-> Appending settings to existing [zram0] section..."
                sudo sed -i '/^\[zram0\]/a zram-size = ram / 2\ncompression-algorithm = zstd' "$ZRAM_CONF"
            else
                # If file exists but no [zram0] section, append it
                echo "-> Appending [zram0] section..."
                printf "\n[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\n" | sudo tee -a "$ZRAM_CONF" > /dev/null
            fi

            # Reload and start
            sudo systemctl daemon-reload
            sudo systemctl start systemd-zram-setup@zram0.service 2>/dev/null || true
            echo "-> ZRAM enabled."
        fi
    fi
fi

echo ""
echo "=== INSTALLATION COMPLETE ==="
echo "Please reboot your system."
