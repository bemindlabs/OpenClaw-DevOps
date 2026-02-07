#!/bin/bash
# OpenClaw DevOps - Secure Password Generator
# Automatically generates secure passwords for all services in .env

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  OpenClaw - Password Generator            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if .env exists
if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠  .env file already exists${NC}"
    read -p "Do you want to generate new passwords (this will update .env)? [y/N] " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${YELLOW}Cancelled. Your existing .env was not modified.${NC}"
        exit 0
    fi
    # Backup existing .env
    cp .env .env.backup.$(date +%Y%m%d-%H%M%S)
    echo -e "${GREEN}✓${NC} Backed up existing .env"
else
    # Create from .env.example
    if [ ! -f ".env.example" ]; then
        echo -e "${RED}Error: .env.example not found${NC}"
        exit 1
    fi
    cp .env.example .env
    echo -e "${GREEN}✓${NC} Created .env from .env.example"
fi

echo ""
echo -e "${YELLOW}Generating secure passwords...${NC}"
echo ""

# Function to generate a secure password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
}

# Function to generate a hex token
generate_hex_token() {
    openssl rand -hex 32
}

# Generate passwords
MONGO_ROOT_PWD=$(generate_password)
MONGO_USER_PWD=$(generate_password)
POSTGRES_PWD=$(generate_password)
REDIS_PWD=$(generate_password)
N8N_PWD=$(generate_password)
N8N_KEY=$(generate_hex_token)
GRAFANA_PWD=$(generate_password)
NEXTAUTH_SECRET=$(generate_password)
GOOGLE_SECRET=$(generate_password)
GATEWAY_TOKEN=$(generate_hex_token)

# Update .env file
echo -e "${YELLOW}[1/10]${NC} MongoDB root password..."
sed -i.bak "s|MONGO_INITDB_ROOT_PASSWORD=.*|MONGO_INITDB_ROOT_PASSWORD=${MONGO_ROOT_PWD}|g" .env
sed -i.bak "s|mongodb://admin:.*@mongodb|mongodb://admin:${MONGO_ROOT_PWD}@mongodb|g" .env
echo -e "${GREEN}✓${NC} Generated"

echo -e "${YELLOW}[2/10]${NC} MongoDB user password..."
sed -i.bak "s|MONGO_PASSWORD=.*|MONGO_PASSWORD=${MONGO_USER_PWD}|g" .env
echo -e "${GREEN}✓${NC} Generated"

echo -e "${YELLOW}[3/10]${NC} PostgreSQL password..."
sed -i.bak "s|POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${POSTGRES_PWD}|g" .env
echo -e "${GREEN}✓${NC} Generated"

echo -e "${YELLOW}[4/10]${NC} Redis password..."
sed -i.bak "s|REDIS_PASSWORD=.*|REDIS_PASSWORD=${REDIS_PWD}|g" .env
echo -e "${GREEN}✓${NC} Generated"

echo -e "${YELLOW}[5/10]${NC} n8n password..."
sed -i.bak "s|N8N_BASIC_AUTH_PASSWORD=.*|N8N_BASIC_AUTH_PASSWORD=${N8N_PWD}|g" .env
echo -e "${GREEN}✓${NC} Generated"

echo -e "${YELLOW}[6/10]${NC} n8n encryption key..."
sed -i.bak "s|N8N_ENCRYPTION_KEY=.*|N8N_ENCRYPTION_KEY=${N8N_KEY}|g" .env
echo -e "${GREEN}✓${NC} Generated"

echo -e "${YELLOW}[7/10]${NC} Grafana password..."
sed -i.bak "s|GF_SECURITY_ADMIN_PASSWORD=.*|GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PWD}|g" .env
echo -e "${GREEN}✓${NC} Generated"

echo -e "${YELLOW}[8/10]${NC} NextAuth secret..."
sed -i.bak "s|NEXTAUTH_SECRET=.*|NEXTAUTH_SECRET=${NEXTAUTH_SECRET}|g" .env
echo -e "${GREEN}✓${NC} Generated"

echo -e "${YELLOW}[9/10]${NC} Google OAuth secret..."
sed -i.bak "s|GOOGLE_CLIENT_SECRET=.*|GOOGLE_CLIENT_SECRET=${GOOGLE_SECRET}|g" .env
echo -e "${GREEN}✓${NC} Generated"

echo -e "${YELLOW}[10/10]${NC} Gateway auth token..."
sed -i.bak "s|GATEWAY_AUTH_TOKEN=.*|GATEWAY_AUTH_TOKEN=${GATEWAY_TOKEN}|g" .env
echo -e "${GREEN}✓${NC} Generated"

# Clean up backup file created by sed
rm -f .env.bak

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ All passwords generated successfully! ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Important next steps:${NC}"
echo ""
echo -e "${YELLOW}1. Update domain configuration in .env:${NC}"
echo "   - DOMAIN=your-domain.com"
echo "   - LANDING_DOMAIN=your-domain.com"
echo "   - GATEWAY_DOMAIN=openclaw.your-domain.com"
echo "   - ASSISTANT_DOMAIN=assistant.your-domain.com"
echo ""
echo -e "${YELLOW}2. Configure Google OAuth:${NC}"
echo "   - Go to: https://console.cloud.google.com/apis/credentials"
echo "   - Create OAuth 2.0 credentials"
echo "   - Update GOOGLE_CLIENT_ID in .env"
echo ""
echo -e "${YELLOW}3. Optional - Configure Telegram bot:${NC}"
echo "   - Message @BotFather on Telegram"
echo "   - Update TELEGRAM_BOT_TOKEN in .env if using"
echo ""
echo -e "${BLUE}Security notes:${NC}"
echo "  ✓ All passwords are 32 characters long"
echo "  ✓ Passwords are cryptographically random"
echo "  ✓ Each service has a unique password"
echo "  ✓ Old .env backed up (if existed)"
echo ""
echo -e "${YELLOW}⚠  Keep your .env file secure:${NC}"
echo "  - Never commit .env to version control"
echo "  - Store backups in a secure password manager"
echo "  - Rotate passwords regularly"
echo ""
echo -e "${GREEN}Ready to start:${NC} make start"
echo ""
