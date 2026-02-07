#!/bin/bash
# Setup GCE instance for OpenClaw DevOps
# This script runs on the GCE instance

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Setting up GCE Instance                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Update system
echo -e "${YELLOW}[1/6]${NC} Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
echo -e "${GREEN}✓${NC} System updated"
echo ""

# Install Docker
echo -e "${YELLOW}[2/6]${NC} Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✓${NC} Docker installed"
else
    echo -e "${GREEN}✓${NC} Docker already installed"
fi
echo ""

# Install Docker Compose
echo -e "${YELLOW}[3/6]${NC} Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓${NC} Docker Compose installed"
else
    echo -e "${GREEN}✓${NC} Docker Compose already installed"
fi
echo ""

# Install required tools
echo -e "${YELLOW}[4/6]${NC} Installing required tools..."
sudo apt-get install -y -qq curl wget git lsof net-tools
echo -e "${GREEN}✓${NC} Tools installed"
echo ""

# Configure firewall
echo -e "${YELLOW}[5/6]${NC} Configuring firewall..."
if command -v ufw &> /dev/null; then
    sudo ufw allow 22/tcp     # SSH
    sudo ufw allow 80/tcp     # HTTP
    sudo ufw allow 443/tcp    # HTTPS
    sudo ufw allow 3000/tcp   # Landing
    sudo ufw allow 18789/tcp  # Gateway
    echo -e "${GREEN}✓${NC} Firewall configured"
else
    echo -e "${YELLOW}⚠${NC}  UFW not available, skip firewall config"
fi
echo ""

# Create directories
echo -e "${YELLOW}[6/6]${NC} Creating directories..."
mkdir -p ~/server/nginx/ssl
mkdir -p ~/server/nginx/conf.d
mkdir -p ~/server/apps/landing
echo -e "${GREEN}✓${NC} Directories created"
echo ""

echo -e "${GREEN}✅ Setup completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Deploy code: Run ./deploy.sh from local machine"
echo "2. Configure DNS to point to this instance"
echo "3. Add SSL certificates to ~/server/nginx/ssl/"
echo ""
echo "Logout and login again to apply Docker group membership"
