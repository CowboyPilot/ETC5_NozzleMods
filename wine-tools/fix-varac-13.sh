#!/bin/bash
# fix-varac-v13.sh
#
# Fixes .NET CLR issues with VarAC V13 in Wine
#
# The error 0xe0434352 is a CLR exception indicating missing or
# incompatible .NET components

set -euo pipefail

WINEPREFIX="${HOME}/.wine32"
export WINEPREFIX
export WINEARCH="win32"

echo "============================================================="
echo "  VarAC V13 .NET Fix Script"
echo "============================================================="
echo
echo "This will install/reinstall .NET components for VarAC V13"
echo

if [[ "${EUID}" -eq 0 ]]; then
  echo "ERROR: Do NOT run this script as root."
  exit 1
fi

if ! command -v winetricks >/dev/null 2>&1; then
  echo "ERROR: winetricks is required but not found."
  echo "       Please install winetricks and try again."
  exit 1
fi

echo "[*] Wine prefix: ${WINEPREFIX}"
echo

# Kill any running Wine processes
echo "[*] Stopping any running Wine processes..."
WINEPREFIX="${WINEPREFIX}" wineserver -k 2>/dev/null || true
sleep 2

# Option 1: Try reinstalling .NET 4.8 (VarAC V13 may need this)
echo
echo "============================================================="
echo "  Option 1: Install .NET Framework 4.8"
echo "============================================================="
echo "VarAC V13 may require .NET 4.8 instead of 4.6"
echo
read -r -p "Install .NET 4.8? This will take several minutes. (Y/n): " INSTALL_48
INSTALL_48=${INSTALL_48:-Y}

if [[ "${INSTALL_48}" =~ ^[Yy]$ ]]; then
  echo
  echo "[*] Installing .NET Framework 4.8 via winetricks..."
  echo "    This may take 10-15 minutes and will show several windows."
  echo "    Please be patient and accept any prompts."
  echo
  
  env -u WINEARCH WINEPREFIX="${WINEPREFIX}" winetricks -q dotnet48
  
  echo "[*] .NET 4.8 installation complete"
fi

# Option 2: Install additional Visual C++ runtimes
echo
echo "============================================================="
echo "  Option 2: Install Visual C++ Runtimes"
echo "============================================================="
echo "VarAC V13 may need additional VC++ runtimes"
echo
read -r -p "Install VC++ runtimes (2017, 2019)? (Y/n): " INSTALL_VC
INSTALL_VC=${INSTALL_VC:-Y}

if [[ "${INSTALL_VC}" =~ ^[Yy]$ ]]; then
  echo
  echo "[*] Installing Visual C++ 2017..."
  env -u WINEARCH WINEPREFIX="${WINEPREFIX}" winetricks -q vcrun2017 || true
  
  echo "[*] Installing Visual C++ 2019..."
  env -u WINEARCH WINEPREFIX="${WINEPREFIX}" winetricks -q vcrun2019 || true
  
  echo "[*] VC++ runtime installation complete"
fi

# Option 3: Reinstall VarAC
echo
echo "============================================================="
echo "  Option 3: Reinstall VarAC V13"
echo "============================================================="
echo

VARAC_INSTALLER=""
# Look for VarAC installer
for dir in "${HOME}/Downloads" "$(pwd)"; do
  if [[ -f "${dir}/VarAC_Installer_v13.exe" ]] || [[ -f "${dir}/VarAC_Installer"*".exe" ]]; then
    VARAC_INSTALLER=$(ls -1t "${dir}"/VarAC_Installer*.exe 2>/dev/null | head -n 1 || true)
    break
  fi
done

if [[ -n "${VARAC_INSTALLER}" ]]; then
  echo "Found VarAC installer: ${VARAC_INSTALLER}"
  echo
  read -r -p "Reinstall VarAC V13? (Y/n): " REINSTALL
  REINSTALL=${REINSTALL:-Y}
  
  if [[ "${REINSTALL}" =~ ^[Yy]$ ]]; then
    echo "[*] Running VarAC installer..."
    env -u WINEARCH WINEPREFIX="${WINEPREFIX}" wine "${VARAC_INSTALLER}"
    echo "[*] VarAC reinstallation complete"
  fi
else
  echo "[!] VarAC installer not found in Downloads or current directory"
  echo "    If you want to reinstall, download the installer and run:"
  echo "    env -u WINEARCH WINEPREFIX=~/.wine32 wine VarAC_Installer_v13.exe"
fi

# Option 4: Check Wine version
echo
echo "============================================================="
echo "  Wine Version Check"
echo "============================================================="
WINE_VERSION=$(wine --version 2>/dev/null || echo "unknown")
echo "Current Wine version: ${WINE_VERSION}"
echo

if [[ "${WINE_VERSION}" == "wine-7.0"* ]]; then
  echo "WARNING: You are running Wine 7.0"
  echo "         VarAC V13 may work better with Wine 8.0 or newer"
  echo
  echo "To upgrade Wine on Ubuntu:"
  echo "  1. Add WineHQ repository:"
  echo "     sudo dpkg --add-architecture i386"
  echo "     sudo mkdir -pm755 /etc/apt/keyrings"
  echo "     sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key"
  echo "     sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources"
  echo
  echo "  2. Install Wine 8.0 or 9.0:"
  echo "     sudo apt update"
  echo "     sudo apt install --install-recommends winehq-stable"
  echo
  echo "After upgrading Wine, you may need to recreate the prefix or run this fix script again."
fi

echo
echo "============================================================="
echo "  Fix Script Complete"
echo "============================================================="
echo
echo "Try running VarAC again using etc-vara"
echo
echo "If problems persist:"
echo "  1. Check VarAC changelog for V13 requirements"
echo "  2. Consider upgrading Wine to 8.0 or newer"
echo "  3. Join VarAC support groups for V13-specific issues"
echo