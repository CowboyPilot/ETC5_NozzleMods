#!/bin/bash
# Fix APT sources on Ubuntu 22.x (especially 22.10 kinetic)
# and install alsa-utils.

set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script with sudo:"
  echo "  sudo $0"
  exit 1
fi

# Detect codename (kinetic, jammy, etc.)
CODENAME=""
if command -v lsb_release >/dev/null 2>&1; then
  CODENAME="$(lsb_release -cs)"
else
  CODENAME="$(awk -F= '/VERSION_CODENAME/{print $2}' /etc/os-release 2>/dev/null || echo "")"
fi

if [[ -z "${CODENAME}" ]]; then
  echo "Could not detect Ubuntu codename. Aborting."
  exit 1
fi

echo "Detected codename: ${CODENAME}"

MIRROR="http://archive.ubuntu.com/ubuntu"

# For kinetic (22.10, EOL) we must use old-releases
if [[ "${CODENAME}" == "kinetic" ]]; then
  MIRROR="http://old-releases.ubuntu.com/ubuntu"
fi

echo "Using mirror: ${MIRROR}"

# Backup existing sources.list
BACKUP="/etc/apt/sources.list.bak.$(date +%Y%m%d%H%M%S)"
echo "Backing up /etc/apt/sources.list to ${BACKUP}"
cp /etc/apt/sources.list "${BACKUP}"

# Write a clean sources.list
cat > /etc/apt/sources.list <<EOF
deb ${MIRROR} ${CODENAME} main restricted universe multiverse
deb ${MIRROR} ${CODENAME}-updates main restricted universe multiverse
deb ${MIRROR} ${CODENAME}-security main restricted universe multiverse
deb ${MIRROR} ${CODENAME}-backports main restricted universe multiverse
EOF

echo "New /etc/apt/sources.list written:"
cat /etc/apt/sources.list

echo
echo "Running apt update..."
apt update

echo
echo "Installing alsa-utils..."
apt install -y alsa-utils

echo
echo "Done. If something fails, you can restore:"
echo "  sudo cp ${BACKUP} /etc/apt/sources.list"
