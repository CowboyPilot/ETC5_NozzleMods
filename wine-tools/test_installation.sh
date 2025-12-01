#!/bin/bash
################################################################################
# Test Script for ETC R5 VARA Tools
#
# This script tests that all files are accessible from GitHub and validates
# basic functionality. Run this AFTER deploying to GitHub.
#
# Usage:
#   bash test_installation.sh
################################################################################

set -euo pipefail

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

REPO_URL="https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main"
PASSED=0
FAILED=0

echo
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}║           ETC R5 VARA Tools - Test Suite                  ║${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo

################################################################################
# Test Functions
################################################################################

pass() {
  echo -e "${GREEN}✓ PASS${NC}: $1"
  ((PASSED++))
}

fail() {
  echo -e "${RED}✗ FAIL${NC}: $1"
  ((FAILED++))
}

info() {
  echo -e "${BLUE}→ INFO${NC}: $1"
}

test_file_exists() {
  local file="$1"
  local url="${REPO_URL}/${file}"
  
  info "Testing: ${file}"
  
  if curl -fsSL --head "${url}" > /dev/null 2>&1; then
    pass "${file} is accessible"
    return 0
  else
    fail "${file} is NOT accessible"
    return 1
  fi
}

test_file_syntax() {
  local file="$1"
  local url="${REPO_URL}/${file}"
  
  info "Testing syntax: ${file}"
  
  local tmpfile=$(mktemp)
  if curl -fsSL "${url}" -o "${tmpfile}" 2>/dev/null; then
    if bash -n "${tmpfile}" 2>/dev/null; then
      pass "${file} has valid bash syntax"
      rm "${tmpfile}"
      return 0
    else
      fail "${file} has syntax errors"
      rm "${tmpfile}"
      return 1
    fi
  else
    fail "Could not download ${file}"
    rm "${tmpfile}"
    return 1
  fi
}

test_file_executable_marker() {
  local file="$1"
  local url="${REPO_URL}/${file}"
  
  info "Testing shebang: ${file}"
  
  local tmpfile=$(mktemp)
  if curl -fsSL "${url}" -o "${tmpfile}" 2>/dev/null; then
    if head -n 1 "${tmpfile}" | grep -q "^#!/bin/bash"; then
      pass "${file} has valid shebang"
      rm "${tmpfile}"
      return 0
    else
      fail "${file} missing or invalid shebang"
      rm "${tmpfile}"
      return 1
    fi
  else
    fail "Could not download ${file}"
    rm "${tmpfile}"
    return 1
  fi
}

################################################################################
# Tests
################################################################################

echo "═══════════════════════════════════════════════════════════"
echo "Test 1: File Accessibility"
echo "═══════════════════════════════════════════════════════════"
echo

test_file_exists "README.md"
test_file_exists "install.sh"
test_file_exists "10-install_all.sh"
test_file_exists "etc-vara"
test_file_exists "fix_sources.sh"
test_file_exists "CONTRIBUTING.md"
test_file_exists "CHANGELOG.md"
test_file_exists "QUICKREF.md"

echo
echo "═══════════════════════════════════════════════════════════"
echo "Test 2: Bash Script Syntax"
echo "═══════════════════════════════════════════════════════════"
echo

test_file_syntax "install.sh"
test_file_syntax "10-install_all.sh"
test_file_syntax "etc-vara"
test_file_syntax "fix_sources.sh"

echo
echo "═══════════════════════════════════════════════════════════"
echo "Test 3: Script Shebangs"
echo "═══════════════════════════════════════════════════════════"
echo

test_file_executable_marker "install.sh"
test_file_executable_marker "10-install_all.sh"
test_file_executable_marker "etc-vara"
test_file_executable_marker "fix_sources.sh"

echo
echo "═══════════════════════════════════════════════════════════"
echo "Test 4: One-Line Installer"
echo "═══════════════════════════════════════════════════════════"
echo

info "Testing one-line installer URL"
if curl -fsSL "${REPO_URL}/install.sh" | head -n 20 | grep -q "ETC R5 VARA Tools"; then
  pass "One-line installer is accessible and valid"
else
  fail "One-line installer failed to download or is invalid"
fi

echo
echo "═══════════════════════════════════════════════════════════"
echo "Test 5: Documentation"
echo "═══════════════════════════════════════════════════════════"
echo

info "Testing README content"
if curl -fsSL "${REPO_URL}/README.md" | grep -q "Quick Start"; then
  pass "README.md contains expected content"
else
  fail "README.md missing expected content"
fi

info "Testing QUICKREF content"
if curl -fsSL "${REPO_URL}/QUICKREF.md" | grep -q "Installation Commands"; then
  pass "QUICKREF.md contains expected content"
else
  fail "QUICKREF.md missing expected content"
fi

################################################################################
# Results
################################################################################

echo
echo "═══════════════════════════════════════════════════════════"
echo "Test Results"
echo "═══════════════════════════════════════════════════════════"
echo
echo -e "Tests Passed: ${GREEN}${PASSED}${NC}"
echo -e "Tests Failed: ${RED}${FAILED}${NC}"
echo -e "Total Tests:  $((PASSED + FAILED))"
echo

if [ ${FAILED} -eq 0 ]; then
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                                                            ║${NC}"
  echo -e "${GREEN}║                  ALL TESTS PASSED! ✓                       ║${NC}"
  echo -e "${GREEN}║                                                            ║${NC}"
  echo -e "${GREEN}║   Your repository is ready for users!                     ║${NC}"
  echo -e "${GREEN}║                                                            ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo
  echo "Users can now install with:"
  echo "  curl -fsSL ${REPO_URL}/install.sh | bash"
  echo
  exit 0
else
  echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║                                                            ║${NC}"
  echo -e "${RED}║                  SOME TESTS FAILED! ✗                      ║${NC}"
  echo -e "${RED}║                                                            ║${NC}"
  echo -e "${RED}║   Please fix the issues above before sharing              ║${NC}"
  echo -e "${RED}║                                                            ║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
  echo
  exit 1
fi
