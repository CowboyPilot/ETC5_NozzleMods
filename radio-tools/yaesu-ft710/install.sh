#!/bin/bash
# Yaesu FT-710 Support Installer for Emcomm Tools R5
# Author: Generated for FT-710 support
# Date: November 30, 2025
#
# ⚠️  USE AT YOUR OWN RISK ⚠️
# This script modifies system files and udev configuration.
# While tested, it may cause issues with your Emcomm Tools installation.
# Always ensure you have backups before proceeding.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directories
ET_HOME="/opt/emcomm-tools"
RADIOS_DIR="${ET_HOME}/conf/radios.d"
SBIN_DIR="${ET_HOME}/sbin"
UDEV_RULES_DIR="/etc/udev/rules.d"
BACKUP_DIR="${HOME}/.ft710-backup"
BACKUP_FILE="${BACKUP_DIR}/udev-tester.sh.backup"

# Script directory (where the downloaded files are)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${RED}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    ⚠️  WARNING - USE AT YOUR OWN RISK ⚠️        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "This script will modify system files for Emcomm Tools R5 to add"
echo "support for the Yaesu FT-710 amateur radio transceiver."
echo ""
echo "Changes to be made:"
echo "  • Install udev rules to ${UDEV_RULES_DIR}"
echo "  • Install radio configuration to ${RADIOS_DIR}"
echo "  • Patch udev-tester.sh script in ${SBIN_DIR}"
echo "  • Reload udev to activate changes"
echo ""
echo "A backup of the original udev-tester.sh will be saved to:"
echo "  ${BACKUP_FILE}"
echo ""

# Check for existing backup and offer restore
if [ -f "${BACKUP_FILE}" ]; then
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗"
    echo "║           BACKUP FOUND - RESTORE OPTION AVAILABLE             ║"
    echo "╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "A backup of udev-tester.sh was found from a previous installation:"
    echo "  ${BACKUP_FILE}"
    echo ""
    read -p "Do you want to RESTORE the backup and exit? (y/N): " restore_choice
    
    if [[ "$restore_choice" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Restoring backup..."
        sudo cp "${BACKUP_FILE}" "${SBIN_DIR}/udev-tester.sh"
        sudo chmod +x "${SBIN_DIR}/udev-tester.sh"
        echo -e "${GREEN}✓ Backup restored successfully!${NC}"
        echo ""
        echo "Reloading udev..."
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        echo -e "${GREEN}✓ udev reloaded${NC}"
        echo ""
        echo "Restore complete. Exiting."
        exit 0
    fi
fi

read -p "Do you want to proceed with installation? (y/N): " choice
if [[ ! "$choice" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "Starting installation..."
echo ""

# Check if running as root for initial check
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}✗ Please do not run this script as root directly.${NC}"
    echo "  The script will ask for sudo privileges when needed."
    exit 1
fi

# Verify required files exist
echo "Checking required files..."
required_files=(
    "yaesu-ft710.json"
    "78-et-ft710.rules"
    "udev-tester.patch"
)

for file in "${required_files[@]}"; do
    if [ ! -f "${SCRIPT_DIR}/${file}" ]; then
        echo -e "${RED}✗ Required file not found: ${file}${NC}"
        echo "  Please ensure all files are downloaded to the same directory."
        exit 1
    fi
done
echo -e "${GREEN}✓ All required files found${NC}"

# Verify Emcomm Tools installation
echo "Verifying Emcomm Tools installation..."
if [ ! -d "${ET_HOME}" ]; then
    echo -e "${RED}✗ Emcomm Tools installation not found at ${ET_HOME}${NC}"
    exit 1
fi
if [ ! -d "${RADIOS_DIR}" ]; then
    echo -e "${RED}✗ Radios directory not found at ${RADIOS_DIR}${NC}"
    exit 1
fi
if [ ! -f "${SBIN_DIR}/udev-tester.sh" ]; then
    echo -e "${RED}✗ udev-tester.sh not found at ${SBIN_DIR}/udev-tester.sh${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Emcomm Tools installation verified${NC}"

# Create backup directory
echo "Creating backup directory..."
mkdir -p "${BACKUP_DIR}"
echo -e "${GREEN}✓ Backup directory created${NC}"

# Backup original udev-tester.sh
echo "Backing up original udev-tester.sh..."
cp "${SBIN_DIR}/udev-tester.sh" "${BACKUP_FILE}"
echo -e "${GREEN}✓ Backup saved to ${BACKUP_FILE}${NC}"

# Install radio configuration
echo "Installing radio configuration..."
sudo cp "${SCRIPT_DIR}/yaesu-ft710.json" "${RADIOS_DIR}/"
sudo chown root:et-data "${RADIOS_DIR}/yaesu-ft710.json"
sudo chmod 644 "${RADIOS_DIR}/yaesu-ft710.json"
echo -e "${GREEN}✓ Radio configuration installed${NC}"

# Install udev rules
echo "Installing udev rules..."
sudo cp "${SCRIPT_DIR}/78-et-ft710.rules" "${UDEV_RULES_DIR}/"
sudo chown root:root "${UDEV_RULES_DIR}/78-et-ft710.rules"
sudo chmod 644 "${UDEV_RULES_DIR}/78-et-ft710.rules"
echo -e "${GREEN}✓ udev rules installed${NC}"

# Patch udev-tester.sh
echo "Patching udev-tester.sh..."
sudo patch "${SBIN_DIR}/udev-tester.sh" < "${SCRIPT_DIR}/udev-tester.patch"
sudo chmod +x "${SBIN_DIR}/udev-tester.sh"
echo -e "${GREEN}✓ udev-tester.sh patched${NC}"

# Verify the patch worked
echo "Verifying patch..."
if grep -q "test_yaesu_ft710" "${SBIN_DIR}/udev-tester.sh" && \
   grep -q "yaesu-ft710)" "${SBIN_DIR}/udev-tester.sh"; then
    echo -e "${GREEN}✓ Patch verified successfully${NC}"
else
    echo -e "${RED}✗ Patch verification failed!${NC}"
    echo "  Restoring backup..."
    sudo cp "${BACKUP_FILE}" "${SBIN_DIR}/udev-tester.sh"
    sudo chmod +x "${SBIN_DIR}/udev-tester.sh"
    echo -e "${YELLOW}⚠ Backup restored. Installation failed.${NC}"
    exit 1
fi

# Reload udev
echo "Reloading udev configuration..."
sudo udevadm control --reload-rules
sudo udevadm trigger
echo -e "${GREEN}✓ udev configuration reloaded${NC}"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗"
echo "║                  ✓ INSTALLATION COMPLETE ✓                     ║"
echo "╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. Select the Yaesu FT-710 in Emcomm Tools (using et-radio or GUI)"
echo "  2. Connect your FT-710 via USB"
echo "  3. Verify the devices were created:"
echo "       ls -la /dev/et-cat /dev/et-audio"
echo ""
echo "Radio configuration notes:"
echo "  • Set CAT RATE to 38400bps (menu 031)"
echo "  • Set DATA MODE to OTHERS (menu 062)"
echo "  • See README.md for complete menu settings"
echo ""
echo "Troubleshooting:"
echo "  • Monitor udev: sudo udevadm monitor"
echo "  • Test script: /opt/emcomm-tools/sbin/udev-tester.sh yaesu-ft710"
echo "  • Check logs in /var/log/syslog"
echo ""
echo "Backup location: ${BACKUP_FILE}"
echo "  Run this script again and choose 'restore' to revert changes"
echo ""
