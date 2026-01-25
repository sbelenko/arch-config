# Arch Linux Configuration

![Arch Linux](https://archlinux.org/static/logos/archlinux-logo-dark-90dpi.png)

Personal scripts and configuration files for automating an Arch Linux desktop setup.

---

## Arch Linux Base Installation

These are the choices made during the `archinstall` process before running the setup scripts.

*   **Disk configuration:**
    *   Filesystem: `ext4`
    *   Partitioning: Wipe all selected drives and use a best-effort default partition layout (no separate `/home`).
*   **Bootloader:** `Systemd-boot`
*   **Authentication:**
    *   Root Password: `None` (leave empty).
    *   User Account: Create a user and promote to `sudo`.
*   **Applications:**
    *   Bluetooth: `Enabled`
    *   Audio: `pipewire`
*   **Network configuration:** `NetworkManager`
*   **Timezone:** `Europe/Kyiv`

## Pre-Setup Steps

After rebooting into the new Arch Linux installation:

1.  **Connect to the network** (if using Wi-Fi):
    ```bash
    nmtui
    ```

2.  **Install `git` and clone the repository:**
    ```bash
    sudo pacman -S git
    git clone https://github.com/sbelenko/arch-config.git
    cd arch-config
    ```

## Running the Setup

Once the repository is cloned, make the script executable and run it:

```bash
chmod +x setup.sh
./setup.sh
```

After the script finishes, a reboot is required.

```bash
reboot
```
