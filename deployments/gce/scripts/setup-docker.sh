#!/bin/bash
# Setup Docker and Docker Compose on GCE instance
# This runs ON the GCE instance (remotely or via SSH)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Docker & Docker Compose Setup            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}✗${NC} Don't run this script as root"
    exit 1
fi

# Check OS
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}✗${NC} Cannot detect OS"
    exit 1
fi

source /etc/os-release
echo "OS: $NAME $VERSION_ID"
echo ""

# 1. Update system
echo -e "${YELLOW}[1/5]${NC} Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
echo -e "${GREEN}✓${NC} System updated"
echo ""

# 2. Install Docker
echo -e "${YELLOW}[2/5]${NC} Installing Docker..."

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓${NC} Docker already installed: $DOCKER_VERSION"
else
    # Install prerequisites
    sudo apt-get install -y -qq \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Setup repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt-get update -qq
    sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add current user to docker group
    sudo usermod -aG docker $USER

    echo -e "${GREEN}✓${NC} Docker installed"
    docker --version
fi
echo ""

# 3. Install Docker Compose (standalone)
echo -e "${YELLOW}[3/5]${NC} Installing Docker Compose standalone..."

if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    echo -e "${GREEN}✓${NC} Docker Compose already installed: $COMPOSE_VERSION"
else
    # Get latest version
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

    # Download and install
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose

    sudo chmod +x /usr/local/bin/docker-compose

    echo -e "${GREEN}✓${NC} Docker Compose installed: $COMPOSE_VERSION"
    docker-compose --version
fi
echo ""

# 4. Configure Docker daemon
echo -e "${YELLOW}[4/5]${NC} Configuring Docker daemon..."

sudo mkdir -p /etc/docker

cat <<EOF | sudo tee /etc/docker/daemon.json > /dev/null
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart Docker to apply config
sudo systemctl restart docker
echo -e "${GREEN}✓${NC} Docker configured"
echo ""

# 5. Enable Docker service
echo -e "${YELLOW}[5/5]${NC} Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl enable containerd
echo -e "${GREEN}✓${NC} Docker service enabled"
echo ""

# Verify installation
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Setup completed!${NC}"
echo ""
echo "Installed versions:"
docker --version
docker-compose --version
echo ""
echo "Docker status:"
sudo systemctl status docker --no-pager -l | head -5
echo ""
echo -e "${YELLOW}⚠  Important:${NC} Logout and login again to use Docker without sudo"
echo ""
echo "Test Docker:"
echo "  docker run hello-world"
echo ""
