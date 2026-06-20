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

##########################################################################
section "IMPROVE BOOT TIME AND REMOVE UNUSED PACKAGES"

info "Disable unused services"

systemctl disable --now NetworkManager-wait-online.service

info "Remove unused packages"

apt purge cloud-init -y
apt autoremove --purge -y

ok "Done."
##########################################################################



##########################################################################
section "SYSTEM UPDATE AND PACKAGES INSTALLATION"

info "Updating system and package installation"

apt -y update
apt -y upgrade
apt -y install raspi-utils libpio-dev git build-essential dfu-programmer fbi

ok "Done."
##########################################################################



##########################################################################
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
##########################################################################


##########################################################################
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
Description=Start DPI csync before display use
DefaultDependencies=no
After=local-fs.target
Before=sysinit.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/dpi_csync-start
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
##########################################################################


##########################################################################
section "ENSURE VOLUME IS SET AT BOOT"

info "Create script"

cat <<'EOF' >/usr/local/bin/set-usb-codec-volume.sh
#!/bin/bash
set -euo pipefail

VOLUME="100%"
MATCH="CODEC"

CARD_ID="$(aplay -l | awk -v needle="$MATCH" '
  $1 == "card" && index($0, needle) {
    gsub(":", "", $2)
    print $2
    exit
  }
')"

if [ -z "$CARD_ID" ]; then
  echo "USB audio CODEC card not found"
  exit 1
fi

echo "Found USB audio CODEC on ALSA card $CARD_ID"

amixer -c "$CARD_ID" sset "Speaker" "$VOLUME" unmute
exit 0
EOF

chmod 755 /usr/local/bin/set-usb-codec-volume.sh

info "Create systemd service: codec_volume.service"

cat <<'EOF' >/etc/systemd/system/codec_volume.service

[Unit]
Description=Set USB audio CODEC volume
After=sound.target
Wants=sound.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/set-usb-codec-volume.sh
EOF

info "Create systemd timer: codec_volume.timer"

cat <<'EOF' >/etc/systemd/system/codec_volume.timer

[Unit]
Description=Run USB audio CODEC volume setter after boot

[Timer]
OnStartupSec=5s
Unit=codec_volume.service

[Install]
WantedBy=timers.target
EOF


info "Enable and start codec_volume.timer"

sudo systemctl daemon-reload
sudo systemctl enable codec_volume.timer
sudo systemctl start codec_volume.timer

ok "Done."
##########################################################################


##########################################################################
CONFIG_FILE="/boot/firmware/config.txt"

section "CREATE DPI CONFIG"

# Only add if not already present
if ! grep -q "dtoverlay=vc4-kms-dpi-generic" "$CONFIG_FILE" 2>/dev/null; then

    info "Add dpi config to $CONFIG_FILE for 400*240 resolution"
    cat <<'EOF' >>"$CONFIG_FILE"

dtoverlay=vc4-kms-dpi-generic

# Pixel Clock
dtparam=clock-frequency=7985760

# Horizontal: 400 active, 8 fp, 40 sync, 60 bp = 508 => pixel_clock/508 => 15.72 kHz
dtparam=hactive=400,hfp=8,hsync=40,hbp=60

# Vertical: 240 active, 3 fp, 3 sync, 16 bp = 262 => 15.72/262 => 60.0 Hz
dtparam=vactive=240,vfp=3,vsync=3,vbp=16

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
##########################################################################



##########################################################################
SPLASH_PATH="/usr/local/share/splash"
SPLASH_FILE="$SPLASH_PATH/splash.png"
CMDLINE_FILE="/boot/firmware/cmdline.txt"
OPTS="quiet loglevel=3 logo.nologo vt.global_cursor_default=0 splash consoleblank=0"

section "SLPASH SCREEN"

info "Download the default splash screen"

mkdir $SPLASH_PATH
chmod 775 $SPLASH_PATH

wget -O $SPLASH_FILE https://raw.githubusercontent.com/DrZedEau/CM5_NavBridge/refs/heads/dev/images/splash/splash.png
chmod 664 $SPLASH_FILE



info "Create systemd service: splash_custom.service"

cat <<'EOF' >/etc/systemd/system/splash_custom.service
[Unit]
Description=Custom splash screen
DefaultDependencies=no
After=local-fs.target systemd-vconsole-setup.service
Before=getty@tty1.service multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/fbi -T 1 -d /dev/fb0 --noverbose -a /usr/local/share/splash/splash.png
StandardInput=tty
StandardOutput=tty
TTYPath=/dev/tty1
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

info "Enable splash_custom.service"

systemctl daemon-reload
systemctl enable splash_custom.service


info "Enable splash screen in /boot/firmware/cmdline.txt"


sudo cp "$CMDLINE_FILE" "$CMDLINE_FILE.bak"

sudo sed -i -E \
  's/(^|[[:space:]])console=tty1([[:space:]]|$)/ /g; s/[[:space:]]+/ /g; s/^ //; s/ $//' \
  "$CMDLINE_FILE"

for opt in $OPTS; do
  if ! grep -qw "$opt" "$CMDLINE_FILE"; then
    sudo sed -i "s/$/ $opt/" "$CMDLINE_FILE"
  fi
done

ok "Done."
##########################################################################


##########################################################################
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

ok "Done."
##########################################################################


section "SETUP COMPLETE"
warn "Reboot system to apply changes"
echo ""