#!/bin/bash

# allocate-port.sh
# Allocate a new port for a service in the OpenClaw DevOps platform
# Usage: ./allocate-port.sh <service-name> <category> [old-port]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PORTS_FILE="$PROJECT_ROOT/ports.json"

# Function to print colored messages
print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_error "jq is required but not installed. Install it with: brew install jq"
    exit 1
fi

# Check if ports.json exists
if [ ! -f "$PORTS_FILE" ]; then
    print_error "ports.json not found at $PORTS_FILE"
    exit 1
fi

# Usage information
usage() {
    echo "Usage: $0 <service-name> <category> [old-port]"
    echo ""
    echo "Arguments:"
    echo "  service-name    Unique service identifier (e.g., 'ollama', 'mlflow')"
    echo "  category        Port category (core, databases, messaging, monitoring, optional, reserved)"
    echo "  old-port        Optional: Previous port number (for migration tracking)"
    echo ""
    echo "Examples:"
    echo "  $0 ollama optional 11434"
    echo "  $0 mlflow monitoring"
    echo ""
    echo "Available categories:"
    jq -r '.categories | to_entries[] | "  - \(.key): \(.value.range) - \(.value.description)"' "$PORTS_FILE"
    exit 1
}

# Check arguments
if [ $# -lt 2 ]; then
    usage
fi

SERVICE_NAME="$1"
CATEGORY="$2"
OLD_PORT="${3:-}"

# Validate category
VALID_CATEGORIES=$(jq -r '.categories | keys[]' "$PORTS_FILE")
if ! echo "$VALID_CATEGORIES" | grep -q "^${CATEGORY}$"; then
    print_error "Invalid category: $CATEGORY"
    echo ""
    echo "Valid categories:"
    echo "$VALID_CATEGORIES" | sed 's/^/  - /'
    exit 1
fi

# Check if service already exists
if jq -e ".services.\"$SERVICE_NAME\"" "$PORTS_FILE" > /dev/null 2>&1; then
    print_error "Service '$SERVICE_NAME' already exists in ports.json"
    EXISTING_PORT=$(jq -r ".services.\"$SERVICE_NAME\".port" "$PORTS_FILE")
    print_info "Existing port: $EXISTING_PORT"
    exit 1
fi

# Get next available port for category
NEXT_PORT=$(jq -r ".portAllocation.nextAvailable.\"$CATEGORY\"" "$PORTS_FILE")

if [ "$NEXT_PORT" = "null" ]; then
    print_error "Could not determine next available port for category: $CATEGORY"
    exit 1
fi

# Get category range to validate
CATEGORY_RANGE=$(jq -r ".categories.\"$CATEGORY\".range" "$PORTS_FILE")
RANGE_END=$(echo "$CATEGORY_RANGE" | cut -d'-' -f2)

# Check if we've exceeded the category range
if [ "$NEXT_PORT" -gt "$RANGE_END" ]; then
    print_error "Category '$CATEGORY' has no available ports (range: $CATEGORY_RANGE)"
    exit 1
fi

# Create service name for display (capitalize and format)
SERVICE_DISPLAY_NAME=$(echo "$SERVICE_NAME" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

# Generate environment variable name
ENV_VAR="${SERVICE_NAME^^}_PORT"
ENV_VAR=$(echo "$ENV_VAR" | tr '-' '_')

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Port Allocation for: ${SERVICE_DISPLAY_NAME}${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

print_info "Service: $SERVICE_NAME"
print_info "Category: $CATEGORY"
print_info "Allocated port: $NEXT_PORT"
print_info "Environment variable: $ENV_VAR"
if [ -n "$OLD_PORT" ]; then
    print_info "Old port: $OLD_PORT"
fi

echo ""
read -p "Confirm allocation? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Allocation cancelled"
    exit 0
fi

# Create backup
cp "$PORTS_FILE" "${PORTS_FILE}.backup"

# Add new service to ports.json
TMP_FILE=$(mktemp)

jq --arg name "$SERVICE_NAME" \
   --arg display "$SERVICE_DISPLAY_NAME" \
   --arg category "$CATEGORY" \
   --arg port "$NEXT_PORT" \
   --arg old_port "$OLD_PORT" \
   --arg env_var "$ENV_VAR" \
   '.services[$name] = {
      "name": $display,
      "category": $category,
      "port": ($port | tonumber),
      "oldPort": (if $old_port != "" then ($old_port | tonumber) else null end),
      "envVar": $env_var,
      "protocol": "http",
      "healthCheck": null,
      "description": "Auto-allocated service",
      "configFiles": [],
      "dependencies": [],
      "externalFacing": false
    } |
    .portAllocation.nextAvailable[$category] = (($port | tonumber) + 1)' \
   "$PORTS_FILE" > "$TMP_FILE"

# Validate JSON
if jq empty "$TMP_FILE" 2>/dev/null; then
    mv "$TMP_FILE" "$PORTS_FILE"
    print_success "Port allocated successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Edit ports.json to add service details (description, health check, config files)"
    echo "  2. Add $ENV_VAR to .env.example"
    echo "  3. Update docker-compose files"
    echo "  4. Run: ./scripts/update-ports.js"
    echo "  5. Validate: ./scripts/validate-ports.sh"
else
    print_error "Failed to update ports.json (invalid JSON generated)"
    rm "$TMP_FILE"
    exit 1
fi
