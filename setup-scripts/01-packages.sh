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
  qt6-5compat           # Qt6 compatibility for Qt5 apps (sddm theme requires this)

  # --- UI Components ---
  waybar                 # Status bar
  network-manager-applet # Wi-Fi tray icon for Waybar (Crucial for UX)
  swaync                 # Notifications
  nwg-look               # GTK Theme manager
  plymouth               # Boot splash
  sddm                   # Login manager
  rofi-wayland           # Launcher

  # --- Utilities ---
  slurp grim satty      # Screenshots
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

echo -e "${GREEN}=== Updating databases... ===${NC}"
sudo pacman -Syu --noconfirm

echo -e "${GREEN}=== Installing packages... ===${NC}"
sudo pacman -S "${packages[@]}" --noconfirm --needed


echo -e "${GREEN}=== Enabling system services... ===${NC}"
# Enable SDDM
sudo systemctl enable sddm || handle_warning "Failed to enable sddm"

# Enable Thermal Daemon for CPU performance
sudo systemctl enable thermald || handle_warning "Failed to enable thermald"

