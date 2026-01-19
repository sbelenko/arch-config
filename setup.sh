#!/bin/bash
# ==========================================
# Arch Linux Unified Installation Script
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

echo -e "${GREEN}=== [1] Preparing Package List ===${NC}"
source "$SCRIPT_DIR/setup-scripts/01-packages.sh"

echo -e "${GREEN}=== [2] Applying Configuration (Dotfiles) ===${NC}"
source "$SCRIPT_DIR/setup-scripts/02-dotfiles.sh"

echo -e "${GREEN}=== [3] Installing Flatpak Apps ===${NC}"
source "$SCRIPT_DIR/setup-scripts/03-flatpak.sh"

echo -e "${GREEN}=== [4] Configuring Perfect Boot (Plymouth & Early KMS) ===${NC}"
source "$SCRIPT_DIR/setup-scripts/04-plymouth.sh"

echo -e "${GREEN}=== [5] Optimizations (ZRAM) ===${NC}"
source "$SCRIPT_DIR/setup-scripts/05-optimize.sh"

echo -e "${GREEN}=== [6] SDDM (Theme Setup) ===${NC}"
source "$SCRIPT_DIR/setup-scripts/06-sddm-theme.sh"

echo -e "${GREEN}=== [7] Appearance (Icons) ===${NC}"
source "$SCRIPT_DIR/setup-scripts/07-appearance.sh"

echo ""
echo -e "${GREEN}=== INSTALLATION COMPLETE ===${NC}"
echo "Please reboot your system."
