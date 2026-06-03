#!/bin/bash

# Prepare RPI5 to output RGsB signal with DPI CSYNC on GPIO 22 (with PIO) using dedicated Pi HAT
# This bash script:
# 1. Installs packages
# 2. Builds and installs dpi_csync from rpi utils repo
# 3. Creates wrapper script /usr/local/sbin/dpi_csync-start
# 4. Creates systemd service dpi_csync.service
# 5. Add DPI config to /boot/firmware/config.txt

# Color formatting
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

info()    { echo -e "${CYAN}${BOLD}➡  $1${RESET}"; }
ok()      { echo -e "${GREEN}${BOLD}✓ $1${RESET}"; }
warn()    { echo -e "${YELLOW}${BOLD}! $1${RESET}"; }
error()   { echo -e "${RED}${BOLD}✗ $1${RESET}"; }

section() {
    echo -e "\n${BOLD}${CYAN}================================================================${RESET}"
    echo -e "${BOLD}${CYAN}$1${RESET}"
    echo -e "${BOLD}${CYAN}================================================================${RESET}\n"
}

if [[ "$EUID" -ne 0 ]]; then
    error "Run this script as root or with sudo."
    exit 1
fi

section "SYSTEM UPDATE AND PACKAGE INSTALLATION"

info "Updating system and package installation"

apt -y update
apt -y upgrade
apt -y install raspi-utils libpio-dev git build-essential dfu-programmer

ok "Done."


WORKDIR=/opt/raspi-utils
REPO_URL="https://github.com/raspberrypi/utils.git"

section "CLONING AND COMPILING dpi_csync"

info "Clone $REPO_URL"

git clone "$REPO_URL" "$WORKDIR"

info "Build dpi_csync.c"

cd "$WORKDIR/piolib/examples"
gcc -O2 dpi_csync.c -o dpi_csync -I /usr/include/piolib -l pio

info "Install dpi_csync to /usr/local/bin"

install -m 755 ./dpi_csync /usr/local/bin/dpi_csync

ok "Done."


section "ADD dpi_csync SCRIPT TO SYSTEMD"

info "Create Wrapper script"

cat <<'EOF' >/usr/local/sbin/dpi_csync-start
#!/bin/bash
# dpi_csync with 400x240@8MHz timings
# Configured for output on GPIO 1 (DE not used)

# HSync width => hsync_pixels / pixel_clock => 40 / 8 => 5.0 microseconds
# Line period => total lines / pixel_clock => 508 / 8 => 63.5 microseconds

exec /usr/local/bin/dpi_csync -h -v -c -s 5.0 -t 63.5 -o 1
EOF

chmod 755 /usr/local/sbin/dpi_csync-start

info "Create systemd service: dpi_csync.service"

cat <<'EOF' >/etc/systemd/system/dpi_csync.service
[Unit]
Description=Generate DPI csync using PIO
After=sysinit.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/dpi_csync-start
User=root
Group=root
Restart=on-failure
RestartSec=2

[Install]
WantedBy=sysinit.target
EOF

info "Enable and start dpi_csync.service"

systemctl daemon-reload
systemctl enable dpi_csync.service
systemctl start dpi_csync.service

ok "Done."


CONFIG_FILE="/boot/firmware/config.txt"

section "CREATE DPI CONFIG"

# Only add if not already present
if ! grep -q "dtoverlay=vc4-kms-dpi-generic" "$CONFIG_FILE" 2>/dev/null; then

    info "Add dpi config to $CONFIG_FILE for 400*240 resolution"
    cat <<'EOF' >>"$CONFIG_FILE"

dtoverlay=vc4-kms-dpi-generic

# Pixel Clock
dtparam=clock-frequency=7985760

# Horizontal: 400 active, 12 fp, 40 sync, 56 bp = 508 => pixel_clock/508 => 15.72 kHz
dtparam=hactive=400,hfp=12,hsync=40,hbp=56

# Vertical: 240 active, 1 fp, 3 sync, 18 bp = 262 => 15.72/262 => 60.0 Hz
dtparam=vactive=240,vfp=1,vsync=3,vbp=18

# 24 bits RGB signal
dtparam=rgb888

# invert HSYNC and VSYNC for the CSYNC generator
dtparam=hsync-invert,vsync-invert

dtparam=pixclk-invert
EOF

ok "Done."

else
    info "DPI Config already present in $CONFIG_FILE"
    info "Skipping"
fi

section "IMPROVE BOOT TIME AND PERFORMANCES"

# Before
# Startup finished in 1.704s (kernel) + 11.887s (userspace) = 13.591s

# After
# Startup finished in 1.672s (kernel) + 4.433s (userspace) = 6.105s

info "Disable unused services"

systemctl disable --now cloud-config.service
systemctl disable --now cloud-final.service
systemctl disable --now cloud-init-local.service
systemctl disable --now cloud-init-main.service
systemctl disable --now cloud-init-network.service
systemctl disable --now avahi-daemon.socket
systemctl disable --now cups.socket
systemctl disable --now NetworkManager-wait-online.service
systemctl disable --now nfs-blkmap.service
systemctl disable --now rpcbind.socket

info "Remove unused packages"

apt purge cloud-init -y
apt autoremove --purge -y



section "FLASH MCU FIRMWARE"

info "Ensure MCU is in DFU mode"


if lsusb | grep -q 'DFU'; then
    info "DFU device found"
else
    status=$?
    error "Error: DFU device not found, reset the MCU with the onboard push button (RESET)" >&2
    exit "$status"
fi

info "Download latest firmware"

wget -O /tmp/main.ino.hex https://raw.githubusercontent.com/DrZedEau/CM5_NavBridge/dev/software/firmware/main/build/arduino.avr.micro/main.ino.hex

info "Flashing Atmega32u4"

dfu-programmer atmega32u4 erase
dfu-programmer atmega32u4 flash /tmp/main.ino.hex
dfu-programmer atmega32u4 reset

section "SETUP COMPLETE"
warn "Reboot system to apply changes"
echo ""