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
BOOT_PARAMS="quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0 i915.fastboot=1"

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
