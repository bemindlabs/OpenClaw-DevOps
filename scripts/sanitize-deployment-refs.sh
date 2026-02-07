#!/bin/bash
#
# sanitize-deployment-refs.sh
#
# Sanitizes deployment-specific references from the codebase:
# - Replaces real public IP with placeholder
# - Replaces real private IP with placeholder
# - Replaces real domain with generic domain
# - Replaces username in file paths with generic placeholder
#
# This prepares the codebase for public distribution or template usage.
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Sanitization mappings
PUBLIC_IP="58.136.234.96"
PUBLIC_IP_PLACEHOLDER="YOUR_PUBLIC_IP"

PRIVATE_IP="192.168.1.152"
PRIVATE_IP_PLACEHOLDER="YOUR_PRIVATE_IP"

DOMAIN="agents.ddns.net"
DOMAIN_PLACEHOLDER="your-domain.com"

GATEWAY_DOMAIN="openclaw.agents.ddns.net"
GATEWAY_DOMAIN_PLACEHOLDER="openclaw.your-domain.com"

ASSISTANT_DOMAIN="assistant.agents.ddns.net"
ASSISTANT_DOMAIN_PLACEHOLDER="assistant.your-domain.com"

USERNAME="lps"
USERNAME_PLACEHOLDER="your-username"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   OpenClaw DevOps - Deployment Reference Sanitization     ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Confirm with user
echo -e "${YELLOW}⚠️  WARNING: This will modify files in the current directory${NC}"
echo ""
echo "The following replacements will be made:"
echo -e "  ${RED}$PUBLIC_IP${NC} → ${GREEN}$PUBLIC_IP_PLACEHOLDER${NC}"
echo -e "  ${RED}$PRIVATE_IP${NC} → ${GREEN}$PRIVATE_IP_PLACEHOLDER${NC}"
echo -e "  ${RED}$DOMAIN${NC} → ${GREEN}$DOMAIN_PLACEHOLDER${NC}"
echo -e "  ${RED}$GATEWAY_DOMAIN${NC} → ${GREEN}$GATEWAY_DOMAIN_PLACEHOLDER${NC}"
echo -e "  ${RED}$ASSISTANT_DOMAIN${NC} → ${GREEN}$ASSISTANT_DOMAIN_PLACEHOLDER${NC}"
echo -e "  ${RED}/Users/$USERNAME/${NC} → ${GREEN}/Users/$USERNAME_PLACEHOLDER/${NC}"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${BLUE}Creating backup...${NC}"

# Create backup directory
BACKUP_DIR="backups/pre-sanitization-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Files to sanitize (excluding node_modules, .git, etc.)
FILES_TO_SANITIZE=$(find . \
    -type f \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/.next/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" \
    -not -path "*/backups/*" \
    -not -name "*.log" \
    -not -name "pnpm-lock.yaml" \
    -not -name "package-lock.json" \
    -not -name "*.png" \
    -not -name "*.jpg" \
    -not -name "*.jpeg" \
    -not -name "*.gif" \
    -not -name "*.ico" \
    -not -name "*.woff*" \
    -not -name "*.ttf" \
    -not -name "*.eot" \
)

# Backup modified files
echo "Backing up files to: $BACKUP_DIR"
for FILE in $FILES_TO_SANITIZE; do
    if grep -l -E "$PUBLIC_IP|$PRIVATE_IP|$DOMAIN|/Users/$USERNAME/" "$FILE" 2>/dev/null; then
        BACKUP_PATH="$BACKUP_DIR/$(dirname $FILE)"
        mkdir -p "$BACKUP_PATH"
        cp "$FILE" "$BACKUP_DIR/$FILE"
    fi
done

echo -e "${GREEN}✓ Backup created${NC}"
echo ""

# Sanitization counters
COUNT_PUBLIC_IP=0
COUNT_PRIVATE_IP=0
COUNT_DOMAIN=0
COUNT_GATEWAY_DOMAIN=0
COUNT_ASSISTANT_DOMAIN=0
COUNT_USERNAME=0

echo -e "${BLUE}Sanitizing files...${NC}"
echo ""

# Function to sanitize a file
sanitize_file() {
    local FILE="$1"
    local CHANGES=0

    # Skip binary files
    if file "$FILE" | grep -q "text"; then
        # Public IP
        if grep -q "$PUBLIC_IP" "$FILE" 2>/dev/null; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/$PUBLIC_IP/$PUBLIC_IP_PLACEHOLDER/g" "$FILE"
            else
                sed -i "s/$PUBLIC_IP/$PUBLIC_IP_PLACEHOLDER/g" "$FILE"
            fi
            CHANGES=$((CHANGES + 1))
            COUNT_PUBLIC_IP=$((COUNT_PUBLIC_IP + 1))
        fi

        # Private IP
        if grep -q "$PRIVATE_IP" "$FILE" 2>/dev/null; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/$PRIVATE_IP/$PRIVATE_IP_PLACEHOLDER/g" "$FILE"
            else
                sed -i "s/$PRIVATE_IP/$PRIVATE_IP_PLACEHOLDER/g" "$FILE"
            fi
            CHANGES=$((CHANGES + 1))
            COUNT_PRIVATE_IP=$((COUNT_PRIVATE_IP + 1))
        fi

        # Gateway Domain (must come before main domain)
        if grep -q "$GATEWAY_DOMAIN" "$FILE" 2>/dev/null; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/$GATEWAY_DOMAIN/$GATEWAY_DOMAIN_PLACEHOLDER/g" "$FILE"
            else
                sed -i "s/$GATEWAY_DOMAIN/$GATEWAY_DOMAIN_PLACEHOLDER/g" "$FILE"
            fi
            CHANGES=$((CHANGES + 1))
            COUNT_GATEWAY_DOMAIN=$((COUNT_GATEWAY_DOMAIN + 1))
        fi

        # Assistant Domain (must come before main domain)
        if grep -q "$ASSISTANT_DOMAIN" "$FILE" 2>/dev/null; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/$ASSISTANT_DOMAIN/$ASSISTANT_DOMAIN_PLACEHOLDER/g" "$FILE"
            else
                sed -i "s/$ASSISTANT_DOMAIN/$ASSISTANT_DOMAIN_PLACEHOLDER/g" "$FILE"
            fi
            CHANGES=$((CHANGES + 1))
            COUNT_ASSISTANT_DOMAIN=$((COUNT_ASSISTANT_DOMAIN + 1))
        fi

        # Main Domain
        if grep -q "$DOMAIN" "$FILE" 2>/dev/null; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/$DOMAIN/$DOMAIN_PLACEHOLDER/g" "$FILE"
            else
                sed -i "s/$DOMAIN/$DOMAIN_PLACEHOLDER/g" "$FILE"
            fi
            CHANGES=$((CHANGES + 1))
            COUNT_DOMAIN=$((COUNT_DOMAIN + 1))
        fi

        # Username in paths
        if grep -q "/Users/$USERNAME/" "$FILE" 2>/dev/null; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s|/Users/$USERNAME/|/Users/$USERNAME_PLACEHOLDER/|g" "$FILE"
            else
                sed -i "s|/Users/$USERNAME/|/Users/$USERNAME_PLACEHOLDER/|g" "$FILE"
            fi
            CHANGES=$((CHANGES + 1))
            COUNT_USERNAME=$((COUNT_USERNAME + 1))
        fi

        if [ $CHANGES -gt 0 ]; then
            echo -e "  ${GREEN}✓${NC} $FILE ($CHANGES changes)"
        fi
    fi
}

# Process all files
for FILE in $FILES_TO_SANITIZE; do
    sanitize_file "$FILE"
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Sanitization Complete${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Summary:"
echo -e "  Public IP replacements:    ${GREEN}$COUNT_PUBLIC_IP${NC} files"
echo -e "  Private IP replacements:   ${GREEN}$COUNT_PRIVATE_IP${NC} files"
echo -e "  Main domain replacements:  ${GREEN}$COUNT_DOMAIN${NC} files"
echo -e "  Gateway domain:            ${GREEN}$COUNT_GATEWAY_DOMAIN${NC} files"
echo -e "  Assistant domain:          ${GREEN}$COUNT_ASSISTANT_DOMAIN${NC} files"
echo -e "  Username paths:            ${GREEN}$COUNT_USERNAME${NC} files"
echo ""
echo -e "Backup location: ${BLUE}$BACKUP_DIR${NC}"
echo ""
echo -e "${YELLOW}⚠️  Next steps:${NC}"
echo "  1. Review changes: git diff"
echo "  2. Test the application to ensure nothing broke"
echo "  3. Commit changes if satisfied"
echo "  4. To restore: cp -r $BACKUP_DIR/* ."
echo ""
echo -e "${GREEN}✓ Done!${NC}"
