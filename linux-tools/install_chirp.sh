#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://archive.chirpmyradio.com/chirp_next/"

echo "[*] Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y python3-wxgtk4.0 pipx curl wget

echo "[*] Finding latest CHIRP-next folder..."
LATEST_DIR="$(
  curl -fsSL "$BASE_URL" \
    | grep -oE 'next-[0-9]{8}/' \
    | sort -u \
    | sort \
    | tail -n 1
)"

if [[ -z "${LATEST_DIR}" ]]; then
  echo "[!] Could not find any next-YYYYMMDD/ folders at $BASE_URL" >&2
  exit 1
fi

FOLDER_URL="${BASE_URL}${LATEST_DIR}"
echo "[*] Latest folder: $FOLDER_URL"

echo "[*] Finding wheel file in latest folder..."
WHL_FILE="$(
  curl -fsSL "$FOLDER_URL" \
    | grep -oE 'chirp-[0-9]{8}-py3-none-any\.whl' \
    | head -n 1
)"

if [[ -z "${WHL_FILE}" ]]; then
  echo "[!] Could not find a chirp-YYYYMMDD-py3-none-any.whl in $FOLDER_URL" >&2
  exit 1
fi

echo "[*] Wheel: $WHL_FILE"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "[*] Downloading wheel..."
wget -q --show-progress "${FOLDER_URL}${WHL_FILE}" -O "${TMPDIR}/${WHL_FILE}"

echo "[*] Installing/updating CHIRP with pipx..."
pipx install --system-site-packages --force "${TMPDIR}/${WHL_FILE}"

echo
echo "[✓] Done."
echo "Run it with:"
echo "  ~/.local/bin/chirp"
~/.local/bin/chirp
