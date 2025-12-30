#!/bin/bash

# Stop script execution on errors
set -e

echo "=== [1/4] Installing Plymouth ==="
# We only install plymouth as requested.
# Ensure your base setup script handles other drivers/firmware if needed.
sudo pacman -S --noconfirm plymouth

echo "=== [2/4] Configuring mkinitcpio (Early KMS & Hooks) ==="
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# 1. Add 'i915' to MODULES
# This enables Early KMS (Kernel Mode Setting) for Intel GPUs.
# It allows the display driver to load before the root filesystem is mounted,
# preventing screen flickering during boot.
if ! grep -q "i915" "$MKINITCPIO_CONF"; then
    echo "-> Adding i915 to MODULES..."
    sudo sed -i 's/MODULES=(/MODULES=(i915 /' "$MKINITCPIO_CONF"
else
    echo "-> i915 module is already present."
fi

# 2. Add 'plymouth' to HOOKS
# The plymouth hook must be placed *after* 'udev' to work correctly.
if ! grep -q "plymouth" "$MKINITCPIO_CONF"; then
    echo "-> Adding plymouth to HOOKS..."
    sudo sed -i 's/\budev\b/udev plymouth/g' "$MKINITCPIO_CONF"
else
    echo "-> plymouth hook is already present."
fi

echo "=== [3/4] Applying Plymouth Theme ==="
# Set the 'spinner' theme (clean, no manufacturer logo).
# The -R flag automatically regenerates the initramfs (runs mkinitcpio -P).
sudo plymouth-set-default-theme -R spinner

echo "=== [4/4] Configuring Bootloader Arguments (Silent Boot) ==="
ENTRIES_DIR="/boot/loader/entries"

# Parameters explanation:
# quiet                   : Disables most log messages.
# splash                  : Enables the graphical splash screen.
# loglevel=3              : Shows only errors (hides info/warnings).
# rd.udev.log_level=3     : Hides udev messages (device detection).
# vt.global_cursor_default=0 : Hides the blinking console cursor.
PARAMS="quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0"

if [ -d "$ENTRIES_DIR" ]; then
    # Iterate through all .conf files in the loader entries
    for file in "$ENTRIES_DIR"/*.conf; do
        if [ -f "$file" ]; then
            echo "Processing file: $file"

            # Check if 'splash' already exists to prevent duplication
            if ! grep -q "splash" "$file"; then
                # Append parameters to the end of the 'options' line
                sudo sed -i "/^options/ s/$/ $PARAMS/" "$file"
                echo "-> Boot parameters added successfully."
            else
                echo "-> Boot parameters already exist. Skipping."
            fi
        fi
    done
else
    echo "WARNING: $ENTRIES_DIR not found. Please check your bootloader configuration."
fi

echo "=== Plymouth setup complete. Please reboot. ==="
