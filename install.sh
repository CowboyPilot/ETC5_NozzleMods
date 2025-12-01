#!/bin/bash
################################################################################
# ETC R5 VARA Tools Installer
#
# This script downloads and installs all VARA tools for EmComm Tools R5:
#   - 10-install-all.sh → ~/add-ons/wine/
#   - vara-downloader.sh → ~/add-ons/wine/
#   - etc-vara → /opt/emcomm-tools/bin/
#   - fix-sources.sh → ~/
#   - update-g90-config.sh → ~/
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/install.sh | bash
#
# Or download and run:
#   wget https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/install.sh
#   chmod +x install.sh
#   ./install.sh
################################################################################

set -euo pipefail

# GitHub repository
REPO_URL="https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main"

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Installation paths
WINE_ADDONS_DIR="${HOME}/add-ons/wine"
ETC_BIN_DIR="/opt/emcomm-tools/bin"
HOME_DIR="${HOME}"

################################################################################
# Helper Functions
################################################################################

print_header() {
  echo
  echo -e "${GREEN}================================================================${NC}"
  echo -e "${GREEN}  $1${NC}"
  echo -e "${GREEN}================================================================${NC}"
  echo
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}! $1${NC}"
}

print_info() {
  echo -e "${BLUE}→ $1${NC}"
}

check_command() {
  if ! command -v "$1" &> /dev/null; then
    print_error "Required command '$1' not found"
    return 1
  fi
  return 0
}

################################################################################
# Pre-flight Checks
################################################################################

preflight_checks() {
  print_header "Pre-flight Checks"
  
  local missing_deps=0
  
  # Check for required commands
  for cmd in wget curl chmod; do
    if check_command "$cmd"; then
      print_success "$cmd found"
    else
      missing_deps=1
    fi
  done
  
  if [ $missing_deps -eq 1 ]; then
    print_error "Missing required dependencies"
    echo
    echo "Please install missing packages and try again:"
    echo "  sudo apt update"
    echo "  sudo apt install wget curl coreutils"
    exit 1
  fi
  
  # Check if running as root
  if [ "$EUID" -eq 0 ]; then
    print_error "Do NOT run this script as root"
    echo
    echo "Run as your normal user:"
    echo "  ./install.sh"
    exit 1
  fi
  
  # Verify we can access GitHub
  print_info "Checking GitHub connectivity..."
  if curl -fsSL --connect-timeout 10 "${REPO_URL}/README.md" > /dev/null 2>&1; then
    print_success "GitHub accessible"
  else
    print_error "Cannot reach GitHub repository"
    echo
    echo "Please check your internet connection and try again"
    exit 1
  fi
  
  echo
  print_success "All pre-flight checks passed"
}

################################################################################
# Installation Functions
################################################################################

install_10_install-all() {
  print_header "Installing 10-install-all.sh"
  
  # Create directory if it doesn't exist
  print_info "Creating directory: ${WINE_ADDONS_DIR}"
  mkdir -p "${WINE_ADDONS_DIR}"
  
  # Download main script
  print_info "Downloading 10-install-all.sh from GitHub..."
  if curl -fsSL "${REPO_URL}/10-install-all.sh" -o "${WINE_ADDONS_DIR}/10-install-all.sh"; then
    print_success "Downloaded 10-install-all.sh"
  else
    print_error "Failed to download 10-install-all.sh"
    return 1
  fi

  # Make executable
  print_info "Setting executable permissions..."
  chmod +x "${WINE_ADDONS_DIR}/10-install-all.sh"
  chmod +x "${WINE_ADDONS_DIR}/vara-downloader.sh" 2>/dev/null || true
  print_success "Set executable: ${WINE_ADDONS_DIR}/10-install-all.sh"
  
  echo
  print_success "10-install-all.sh installed successfully"
}

install_etc_vara() {
  print_header "Installing etc-vara"
  
  # Check if we can write to /opt/emcomm-tools/bin
  if [ ! -d "${ETC_BIN_DIR}" ]; then
    print_warning "Directory ${ETC_BIN_DIR} does not exist"
    print_info "This is normal if EmComm Tools is not fully set up"
    print_info "You can install etc-vara manually later with:"
    echo "  sudo wget -O /opt/emcomm-tools/bin/etc-vara ${REPO_URL}/etc-vara"
    echo "  sudo chmod +x /opt/emcomm-tools/bin/etc-vara"
    return 0
  fi
  
  if [ ! -w "${ETC_BIN_DIR}" ]; then
    print_warning "Cannot write to ${ETC_BIN_DIR} (need sudo)"
    print_info "Attempting to install with sudo..."
    
    # Try with sudo
    if sudo wget -O "${ETC_BIN_DIR}/etc-vara" "${REPO_URL}/etc-vara" 2>/dev/null && \
       sudo chmod +x "${ETC_BIN_DIR}/etc-vara" 2>/dev/null; then
      print_success "Installed etc-vara with sudo"
    else
      print_error "Failed to install etc-vara"
      print_info "You can install it manually later with:"
      echo "  sudo wget -O /opt/emcomm-tools/bin/etc-vara ${REPO_URL}/etc-vara"
      echo "  sudo chmod +x /opt/emcomm-tools/bin/etc-vara"
      return 1
    fi
  else
    # Can write without sudo
    print_info "Downloading etc-vara from GitHub..."
    if wget -O "${ETC_BIN_DIR}/etc-vara" "${REPO_URL}/etc-vara" 2>/dev/null && \
       chmod +x "${ETC_BIN_DIR}/etc-vara" 2>/dev/null; then
      print_success "Installed etc-vara"
    else
      print_error "Failed to install etc-vara"
      return 1
    fi
  fi
  
  echo
  print_success "etc-vara installed successfully"
}

install_fix-sources() {
  print_header "Installing fix-sources.sh"
  
  print_info "Downloading fix-sources.sh from GitHub..."
  if curl -fsSL "${REPO_URL}/fix-sources.sh" -o "${HOME_DIR}/fix-sources.sh"; then
    print_success "Downloaded fix-sources.sh"
  else
    print_error "Failed to download fix-sources.sh"
    return 1
  fi
  
  print_info "Setting executable permissions..."
  chmod +x "${HOME_DIR}/fix-sources.sh"
  print_success "Set executable: ${HOME_DIR}/fix-sources.sh"
  
  echo
  print_success "fix-sources.sh installed successfully"
}

install_fix-varac13() {
  print_header "Installing fix-varac-13.sh"
  
  print_info "Downloading fix-varac-13.sh from GitHub..."
  if curl -fsSL "${REPO_URL}/fix-varac-13.sh" -o "${HOME_DIR}/fix-varac-13.sh"; then
    print_success "Downloaded fix-varac-13.sh"
  else
    print_error "Failed to download fix-varac-13.sh"
    return 1
  fi
  
  print_info "Setting executable permissions..."
  chmod +x "${HOME_DIR}/fix-varac-13.sh"
  print_success "Set executable: ${HOME_DIR}/fix-varac-13.sh"
  
  echo
  print_success "fix-varac-13.sh installed successfully"
}

install_update_g90() {
  print_header "Installing update-g90-config.sh"
  
  print_info "Downloading update-g90-config.sh from GitHub..."
  if curl -fsSL "${REPO_URL}/update-g90-config.sh" -o "${HOME_DIR}/update-g90-config.sh"; then
    print_success "Downloaded update-g90-config.sh"
  else
    print_error "Failed to download update-g90-config.sh"
    return 1
  fi
  
  print_info "Setting executable permissions..."
  chmod +x "${HOME_DIR}/update-g90-config.sh"
  print_success "Set executable: ${HOME_DIR}/update-g90-config.sh"
  
  echo
  print_success "update-g90-config.sh installed successfully"
}

################################################################################
# Post-Installation Instructions
################################################################################

show_next_steps() {
  print_header "Installation Complete!"
  
  echo "All scripts have been installed:"
  echo
  echo -e "${GREEN}1. 10-install-all.sh${NC}"
  echo "   Location: ${WINE_ADDONS_DIR}/10-install-all.sh"
  echo "   Purpose:  Install Winlink, VarAC, and VARA HF/FM"
  echo
  echo -e "${GREEN}2. etc-vara${NC}"
  echo "   Location: ${ETC_BIN_DIR}/etc-vara"
  echo "   Purpose:  Launch VARA applications with smart port management"
  echo
  echo -e "${GREEN}3. fix-sources.sh${NC}"
  echo "   Location: ${HOME_DIR}/fix-sources.sh"
  echo "   Purpose:  Fix APT repository issues (if needed)"
  echo
  echo -e "${GREEN}4. update-g90-config.sh${NC}"
  echo "   Location: ${HOME_DIR}/update-g90-config.sh"
  echo "   Purpose:  Configure Xiegu G90 DigiRig PTT options"
  echo
  
  print_header "Next Steps"
  
  echo -e "${YELLOW}Before continuing, ensure you have:${NC}"
  echo "  • Run 'et-user' to set your callsign"
  echo "  • Run 'et-audio' to configure audio"
  echo "  • Run 'et-radio' to configure your radio"
  echo
  
  echo -e "${YELLOW}Download required installers:${NC}"
  echo "  • VarAC installer (VarAC_Installer*.exe)"
  echo "  • VARA HF installer (optional)"
  echo "  • VARA FM installer (optional)"
  echo
  echo "  Place them in: ${WINE_ADDONS_DIR}/"
  echo "             or: ${HOME}/Downloads/"
  echo
  
  echo -e "${BLUE}To install VARA applications:${NC}"
  echo "  cd ${WINE_ADDONS_DIR}"
  echo "  ./10-install-all.sh"
  echo
  echo -e "${GREEN}Note:${NC} The first run may patch your environment and require"
  echo "      you to log out and back in. After re-logging, run it again."
  echo
  
  echo -e "${BLUE}To launch VARA applications:${NC}"
  echo "  etc-vara"
  echo
  
  echo -e "${BLUE}If you have APT/repository issues:${NC}"
  echo "  sudo ~/fix-sources.sh"
  echo
  
  echo -e "${BLUE}If you have a Xiegu G90 with DigiRig:${NC}"
  echo "  sudo ~/update-g90-config.sh"
  echo
  
  print_header "Installation Summary"
  echo "For detailed documentation, visit:"
  echo "  https://github.com/CowboyPilot/ETCR5_VARA_TOOLS"
  echo
  echo "73!"
  echo
}

################################################################################
# Main Installation Flow
################################################################################

main() {
  clear
  echo
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                                                            ║${NC}"
  echo -e "${GREEN}║           ETC R5 VARA Tools Installer                      ║${NC}"
  echo -e "${GREEN}║                                                            ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo
  
  # Run pre-flight checks
  preflight_checks
  
  # Install components
  echo
  install_10_install-all || {
    print_error "Failed to install 10-install-all.sh"
    echo "Continuing with other installations..."
  }
  
  echo
  install_etc_vara || {
    print_error "Failed to install etc-vara"
    echo "Continuing with other installations..."
  }
  
  echo
  install_fix-sources || {
    print_error "Failed to install fix-sources.sh"
    echo "Continuing..."
  }
  
  echo
  install_update_g90 || {
    print_error "Failed to install update-g90-config.sh"
    echo "Continuing..."
  }
  
  # Show next steps
  echo
  show_next_steps
}

# Run main installation
main
