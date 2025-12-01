#!/bin/bash
# Script to configure Xiegu G90 radio for DigiRig with PTT options
# Allows selection between CAT PTT and RTS PTT

set -euo pipefail

CONFIG_FILE="/opt/emcomm-tools/conf/radios.d/xiegu-g90.json"
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

echo "============================================================="
echo "   Xiegu G90 DigiRig Configuration"
echo "============================================================="
echo

# Check if running as root
if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: This script must be run with sudo"
  echo "Usage: sudo $0"
  exit 1
fi

# Check if config file exists
if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "ERROR: Configuration file not found: ${CONFIG_FILE}"
  exit 1
fi

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed"
  echo "Install with: sudo apt install jq"
  exit 1
fi

# Show menu
echo "Select PTT configuration:"
echo
echo "  1) DigiRig with CAT PTT"
echo "  2) DigiRig with RTS PTT (Original)"
echo
read -p "Enter choice [1-2]: " choice

case "${choice}" in
  1)
    MODEL_NAME="G90 (DR-CAT)"
    PTT_VALUE="RIG --set-conf=rts_state=OFF,stop_bits=2"
    echo
    echo "Selected: DigiRig with CAT PTT"
    ;;
  2)
    MODEL_NAME="G90 (DigiRig)"
    PTT_VALUE="RTS"
    echo
    echo "Selected: DigiRig with RTS PTT (Original)"
    ;;
  *)
    echo "ERROR: Invalid choice"
    exit 1
    ;;
esac

# Create backup
echo "[*] Creating backup: ${BACKUP_FILE}"
cp "${CONFIG_FILE}" "${BACKUP_FILE}"

# Update the configuration using jq
echo "[*] Updating configuration..."

jq --arg model "${MODEL_NAME}" --arg ptt "${PTT_VALUE}" \
  '.model = $model | .rigctrl.ptt = $ptt' \
  "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp"

# Replace original with updated version
mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

echo "[*] Configuration updated successfully"
echo
echo "Changes made:"
echo "  Model: ${MODEL_NAME}"
echo "  PTT:   ${PTT_VALUE}"
echo
echo "Backup saved to: ${BACKUP_FILE}"
echo
echo "To revert changes:"
echo "  sudo cp ${BACKUP_FILE} ${CONFIG_FILE}"
echo
echo "Done!"
