#!/bin/bash

###############################################################################
# Security Scan Script
#
# Runs Trivy and Semgrep security scans locally
#
# Usage:
#   ./scripts/security-scan.sh [--trivy|--semgrep|--all] [--severity LEVEL]
#
# Options:
#   --trivy         Run only Trivy scans
#   --semgrep       Run only Semgrep scans
#   --all           Run all security scans (default)
#   --severity      Minimum severity level (CRITICAL, HIGH, MEDIUM, LOW)
#   --fix           Apply automatic fixes where possible (Semgrep only)
#   --docker        Include Docker image scanning
#   --report DIR    Save reports to directory (default: ./security-reports)
#   --help          Show this help message
#
# Examples:
#   ./scripts/security-scan.sh --all
#   ./scripts/security-scan.sh --trivy --severity HIGH
#   ./scripts/security-scan.sh --semgrep --fix
#   ./scripts/security-scan.sh --docker
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SCAN_TYPE="all"
SEVERITY="CRITICAL,HIGH,MEDIUM"
APPLY_FIX=false
SCAN_DOCKER=false
REPORT_DIR="./security-reports"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --trivy)
      SCAN_TYPE="trivy"
      shift
      ;;
    --semgrep)
      SCAN_TYPE="semgrep"
      shift
      ;;
    --all)
      SCAN_TYPE="all"
      shift
      ;;
    --severity)
      SEVERITY="$2"
      shift 2
      ;;
    --fix)
      APPLY_FIX=true
      shift
      ;;
    --docker)
      SCAN_DOCKER=true
      shift
      ;;
    --report)
      REPORT_DIR="$2"
      shift 2
      ;;
    --help)
      head -n 30 "$0" | tail -n +3 | sed 's/^# //'
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Create report directory
mkdir -p "$REPORT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Security Scan - OpenClaw DevOps   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

###############################################################################
# Helper Functions
###############################################################################

check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "${RED}✗ $1 is not installed${NC}"
    return 1
  else
    echo -e "${GREEN}✓ $1 is installed${NC}"
    return 0
  fi
}

install_trivy() {
  echo -e "${YELLOW}Installing Trivy...${NC}"

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v brew &> /dev/null; then
      brew install trivy
    else
      echo -e "${RED}Please install Homebrew first: https://brew.sh${NC}"
      exit 1
    fi
  else
    echo -e "${RED}Unsupported OS. Please install Trivy manually: https://aquasecurity.github.io/trivy/latest/getting-started/installation/${NC}"
    exit 1
  fi
}

install_semgrep() {
  echo -e "${YELLOW}Installing Semgrep...${NC}"

  if command -v pip3 &> /dev/null; then
    pip3 install semgrep
  elif command -v brew &> /dev/null; then
    brew install semgrep
  else
    echo -e "${RED}Please install pip3 or Homebrew to install Semgrep${NC}"
    exit 1
  fi
}

###############################################################################
# Trivy Scans
###############################################################################

run_trivy_scans() {
  echo -e "\n${BLUE}═══ Running Trivy Scans ═══${NC}\n"

  if ! check_command trivy; then
    echo -e "${YELLOW}Trivy not found. Install it? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      install_trivy
    else
      echo -e "${RED}Skipping Trivy scans${NC}"
      return 1
    fi
  fi

  # Update Trivy database
  echo -e "${YELLOW}Updating Trivy database...${NC}"
  trivy image --download-db-only

  # Filesystem scan
  echo -e "\n${YELLOW}▶ Scanning filesystem for vulnerabilities...${NC}"
  trivy fs \
    --config trivy.yaml \
    --severity "$SEVERITY" \
    --format json \
    --output "$REPORT_DIR/trivy-fs-$TIMESTAMP.json" \
    .

  trivy fs \
    --config trivy.yaml \
    --severity "$SEVERITY" \
    --format table \
    .

  # Config scan
  echo -e "\n${YELLOW}▶ Scanning configuration files...${NC}"
  trivy config \
    --severity "$SEVERITY" \
    --format json \
    --output "$REPORT_DIR/trivy-config-$TIMESTAMP.json" \
    .

  trivy config \
    --severity "$SEVERITY" \
    --format table \
    .

  # Secret scan
  echo -e "\n${YELLOW}▶ Scanning for secrets...${NC}"
  trivy fs \
    --scanners secret \
    --format json \
    --output "$REPORT_DIR/trivy-secrets-$TIMESTAMP.json" \
    .

  trivy fs \
    --scanners secret \
    --format table \
    .

  # Docker image scans
  if [ "$SCAN_DOCKER" = true ]; then
    echo -e "\n${YELLOW}▶ Scanning Docker images...${NC}"

    for app in landing assistant gateway; do
      if docker images | grep -q "openclaw-$app"; then
        echo -e "${YELLOW}  Scanning openclaw-$app...${NC}"
        trivy image \
          --severity "$SEVERITY" \
          --format json \
          --output "$REPORT_DIR/trivy-docker-$app-$TIMESTAMP.json" \
          "openclaw-$app:latest"

        trivy image \
          --severity "$SEVERITY" \
          --format table \
          "openclaw-$app:latest"
      else
        echo -e "${YELLOW}  Image openclaw-$app not found, skipping...${NC}"
      fi
    done
  fi

  echo -e "\n${GREEN}✓ Trivy scans completed${NC}"
  echo -e "${BLUE}Reports saved to: $REPORT_DIR${NC}"
}

###############################################################################
# Semgrep Scans
###############################################################################

run_semgrep_scans() {
  echo -e "\n${BLUE}═══ Running Semgrep Scans ═══${NC}\n"

  if ! check_command semgrep; then
    echo -e "${YELLOW}Semgrep not found. Install it? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      install_semgrep
    else
      echo -e "${RED}Skipping Semgrep scans${NC}"
      return 1
    fi
  fi

  # Base command
  SEMGREP_CMD="semgrep scan"

  # Add fix flag if requested
  if [ "$APPLY_FIX" = true ]; then
    SEMGREP_CMD="$SEMGREP_CMD --autofix"
    echo -e "${YELLOW}⚠ Autofix enabled - changes will be applied${NC}"
  fi

  # Run comprehensive scan
  echo -e "${YELLOW}▶ Running security audit...${NC}"
  $SEMGREP_CMD \
    --config auto \
    --config p/security-audit \
    --config p/secrets \
    --config p/owasp-top-ten \
    --config p/javascript \
    --config p/typescript \
    --config p/react \
    --config p/nextjs \
    --config p/nodejs \
    --config p/express \
    --config p/docker \
    --json \
    --output "$REPORT_DIR/semgrep-$TIMESTAMP.json" \
    || true

  # Generate human-readable report
  echo -e "\n${YELLOW}▶ Generating readable report...${NC}"
  $SEMGREP_CMD \
    --config auto \
    --config p/security-audit \
    --config p/secrets \
    --config p/owasp-top-ten \
    --output "$REPORT_DIR/semgrep-$TIMESTAMP.txt" \
    || true

  # Display results
  cat "$REPORT_DIR/semgrep-$TIMESTAMP.txt"

  echo -e "\n${GREEN}✓ Semgrep scans completed${NC}"
  echo -e "${BLUE}Reports saved to: $REPORT_DIR${NC}"
}

###############################################################################
# Main Execution
###############################################################################

echo -e "${YELLOW}Scan Configuration:${NC}"
echo -e "  Type: $SCAN_TYPE"
echo -e "  Severity: $SEVERITY"
echo -e "  Apply Fix: $APPLY_FIX"
echo -e "  Docker Scan: $SCAN_DOCKER"
echo -e "  Report Directory: $REPORT_DIR"
echo ""

# Run scans based on type
case $SCAN_TYPE in
  trivy)
    run_trivy_scans
    ;;
  semgrep)
    run_semgrep_scans
    ;;
  all)
    run_trivy_scans
    run_semgrep_scans
    ;;
esac

# Generate summary
echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Security Scan Summary          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Security scans completed successfully${NC}"
echo -e "${BLUE}📊 Reports available at: $REPORT_DIR${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Review the generated reports"
echo -e "  2. Address CRITICAL and HIGH severity findings"
echo -e "  3. Update dependencies with known vulnerabilities"
echo -e "  4. Add false positives to .trivyignore or .semgrepignore"
echo ""
echo -e "${BLUE}For detailed results, check:${NC}"
ls -lh "$REPORT_DIR"/*"$TIMESTAMP"* 2>/dev/null || echo "  No reports generated"
echo ""
