#!/bin/bash

###############################################################################
# Install Security Tools
#
# Installs Trivy and Semgrep for local security scanning
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Installing Security Scanning Tools  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

###############################################################################
# Check if tools are already installed
###############################################################################

check_tool() {
  if command -v "$1" &> /dev/null; then
    echo -e "${GREEN}✓ $1 is already installed${NC}"
    $1 --version | head -n 1
    return 0
  else
    echo -e "${YELLOW}✗ $1 is not installed${NC}"
    return 1
  fi
}

###############################################################################
# Install Trivy
###############################################################################

install_trivy() {
  echo -e "\n${YELLOW}Installing Trivy...${NC}"

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo -e "${BLUE}Detected Linux system${NC}"
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo -e "${BLUE}Detected macOS system${NC}"

    if command -v brew &> /dev/null; then
      brew install trivy
    else
      echo -e "${RED}Homebrew not found. Installing via curl...${NC}"
      curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
    fi

  else
    echo -e "${RED}Unsupported OS${NC}"
    echo -e "${YELLOW}Please install Trivy manually:${NC}"
    echo -e "  https://aquasecurity.github.io/trivy/latest/getting-started/installation/"
    return 1
  fi

  if check_tool trivy; then
    echo -e "${GREEN}✓ Trivy installed successfully${NC}"

    # Update database
    echo -e "${YELLOW}Updating Trivy vulnerability database...${NC}"
    trivy image --download-db-only
    echo -e "${GREEN}✓ Database updated${NC}"

    return 0
  else
    echo -e "${RED}✗ Trivy installation failed${NC}"
    return 1
  fi
}

###############################################################################
# Install Semgrep
###############################################################################

install_semgrep() {
  echo -e "\n${YELLOW}Installing Semgrep...${NC}"

  # Try pip3 first
  if command -v pip3 &> /dev/null; then
    echo -e "${BLUE}Installing via pip3...${NC}"
    pip3 install --user semgrep

    # Add user pip bin to PATH if not already
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
      export PATH="$HOME/.local/bin:$PATH"
      echo -e "${YELLOW}Added ~/.local/bin to PATH${NC}"
      echo -e "${YELLOW}Add this to your shell profile:${NC}"
      echo -e "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi

  # Try brew for macOS
  elif [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
    echo -e "${BLUE}Installing via Homebrew...${NC}"
    brew install semgrep

  # Try python3 -m pip
  elif command -v python3 &> /dev/null; then
    echo -e "${BLUE}Installing via python3 -m pip...${NC}"
    python3 -m pip install --user semgrep

    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
      export PATH="$HOME/.local/bin:$PATH"
    fi

  else
    echo -e "${RED}No suitable package manager found${NC}"
    echo -e "${YELLOW}Please install one of the following:${NC}"
    echo -e "  - Python 3 with pip3"
    echo -e "  - Homebrew (macOS)"
    echo ""
    echo -e "${YELLOW}Then run:${NC}"
    echo -e "  pip3 install semgrep"
    return 1
  fi

  # Verify installation
  if check_tool semgrep; then
    echo -e "${GREEN}✓ Semgrep installed successfully${NC}"

    # Login to Semgrep (optional)
    echo -e "\n${YELLOW}Would you like to login to Semgrep? (y/n)${NC}"
    echo -e "${BLUE}This enables additional features like:${NC}"
    echo -e "  - Cloud scanning"
    echo -e "  - Team collaboration"
    echo -e "  - Historical data"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
      semgrep login
    else
      echo -e "${YELLOW}Skipping Semgrep login${NC}"
    fi

    return 0
  else
    echo -e "${RED}✗ Semgrep installation failed${NC}"
    return 1
  fi
}

###############################################################################
# Main Installation
###############################################################################

echo -e "${YELLOW}Checking current installation status...${NC}\n"

TRIVY_INSTALLED=false
SEMGREP_INSTALLED=false

if check_tool trivy; then
  TRIVY_INSTALLED=true
fi

if check_tool semgrep; then
  SEMGREP_INSTALLED=true
fi

echo ""

# Install missing tools
if [ "$TRIVY_INSTALLED" = false ]; then
  install_trivy || echo -e "${RED}Failed to install Trivy${NC}"
else
  echo -e "${GREEN}Trivy is already installed, skipping...${NC}"
fi

if [ "$SEMGREP_INSTALLED" = false ]; then
  install_semgrep || echo -e "${RED}Failed to install Semgrep${NC}"
else
  echo -e "${GREEN}Semgrep is already installed, skipping...${NC}"
fi

###############################################################################
# Summary
###############################################################################

echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Installation Summary          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

TRIVY_STATUS="${RED}✗ Not Installed${NC}"
SEMGREP_STATUS="${RED}✗ Not Installed${NC}"

if command -v trivy &> /dev/null; then
  TRIVY_STATUS="${GREEN}✓ Installed${NC}"
  TRIVY_VERSION=$(trivy --version | head -n 1)
fi

if command -v semgrep &> /dev/null; then
  SEMGREP_STATUS="${GREEN}✓ Installed${NC}"
  SEMGREP_VERSION=$(semgrep --version)
fi

echo -e "Trivy:   $TRIVY_STATUS"
if [ -n "$TRIVY_VERSION" ]; then
  echo -e "         $TRIVY_VERSION"
fi

echo -e "\nSemgrep: $SEMGREP_STATUS"
if [ -n "$SEMGREP_VERSION" ]; then
  echo -e "         Version $SEMGREP_VERSION"
fi

echo ""

if command -v trivy &> /dev/null && command -v semgrep &> /dev/null; then
  echo -e "${GREEN}✓ All security tools installed successfully!${NC}"
  echo ""
  echo -e "${YELLOW}Next Steps:${NC}"
  echo -e "  1. Run a security scan:"
  echo -e "     ${BLUE}./scripts/security-scan.sh --all${NC}"
  echo ""
  echo -e "  2. Review the security scan reports"
  echo ""
  echo -e "  3. Add exceptions to .trivyignore or .semgrepignore if needed"
  echo ""
else
  echo -e "${YELLOW}⚠ Some tools failed to install${NC}"
  echo -e "Please install them manually or check error messages above"
fi
