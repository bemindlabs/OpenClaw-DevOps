#!/bin/bash
# Complete Deployment Script for bmt-staging-research
# This script handles the full deployment process

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
GCP_PROJECT="bemind-technology"
GCP_ZONE="asia-southeast1-a"
GCP_INSTANCE="bmt-staging-research"

# Auto-detect remote user (will be set after instance verification)
SERVER_USER=""
SERVER_DIR=""

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║   OpenClaw DevOps - Complete GCE Deployment              ║"
echo "║   Instance: bmt-staging-research                         ║"
echo "║   Zone: asia-southeast1-a                                ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Step 1: Check Prerequisites
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}[1/10]${NC} Checking Prerequisites..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check gcloud
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}✗${NC} gcloud CLI not found"
    echo "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi
echo -e "${GREEN}✓${NC} gcloud CLI installed"

# Check authentication
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo -e "${RED}✗${NC} Not authenticated with GCP"
    echo "Run: gcloud auth login"
    exit 1
fi
ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1)
echo -e "${GREEN}✓${NC} Authenticated as: ${CYAN}${ACCOUNT}${NC}"

# Set project
gcloud config set project $GCP_PROJECT --quiet 2>/dev/null || {
    echo -e "${YELLOW}⚠${NC} Could not set project (might need re-auth)"
    echo "Run: gcloud auth login --update-adc"
}

echo ""

# Step 2: Verify Instance
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}[2/10]${NC} Verifying GCE Instance..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

INSTANCE_STATUS=$(gcloud compute instances describe $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --format="get(status)" 2>/dev/null || echo "NOT_FOUND")

if [ "$INSTANCE_STATUS" = "NOT_FOUND" ]; then
    echo -e "${RED}✗${NC} Instance not found: $GCP_INSTANCE"
    exit 1
fi

echo -e "${GREEN}✓${NC} Instance: ${CYAN}${GCP_INSTANCE}${NC}"
echo -e "${GREEN}✓${NC} Status: ${CYAN}${INSTANCE_STATUS}${NC}"

EXTERNAL_IP=$(gcloud compute instances describe $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null)
echo -e "${GREEN}✓${NC} External IP: ${CYAN}${EXTERNAL_IP}${NC}"

# Detect remote user
SERVER_USER=$(gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="whoami" --quiet 2>/dev/null | tr -d '\r\n')
SERVER_DIR="/home/${SERVER_USER}/openclaw"
echo -e "${GREEN}✓${NC} Remote User: ${CYAN}${SERVER_USER}${NC}"
echo -e "${GREEN}✓${NC} Deploy Directory: ${CYAN}${SERVER_DIR}${NC}"

echo ""

# Step 3: Build Docker Images Locally
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}[3/10]${NC} Building Docker Images..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

cd "$(dirname "$0")/../.."

echo -e "${CYAN}→${NC} Building landing page..."
docker build -t openclaw-landing:latest -f apps/landing/Dockerfile . --quiet && \
    echo -e "${GREEN}✓${NC} Landing page built" || \
    echo -e "${YELLOW}⚠${NC} Landing build failed (will build on server)"

echo -e "${CYAN}→${NC} Building assistant portal..."
docker build -t openclaw-assistant:latest -f apps/assistant/Dockerfile . --quiet && \
    echo -e "${GREEN}✓${NC} Assistant portal built" || \
    echo -e "${YELLOW}⚠${NC} Assistant build failed (will build on server)"

echo -e "${CYAN}→${NC} Building gateway..."
docker build -t openclaw-gateway:latest -f apps/gateway/Dockerfile . --quiet && \
    echo -e "${GREEN}✓${NC} Gateway built" || \
    echo -e "${YELLOW}⚠${NC} Gateway build failed (will build on server)"

echo ""

# Step 4: Create Deployment Package
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}[4/10]${NC} Creating Deployment Package..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

DEPLOY_PKG="/tmp/openclaw-deploy-$(date +%Y%m%d-%H%M%S).tar.gz"

echo -e "${CYAN}→${NC} Packaging project files..."
tar czf $DEPLOY_PKG \
    --exclude='node_modules' \
    --exclude='.next' \
    --exclude='.git' \
    --exclude='*.log' \
    --exclude='dist' \
    --exclude='build' \
    apps/ \
    nginx/ \
    monitoring/ \
    docker-compose.yml \
    docker-compose.full.yml \
    .env.example \
    Makefile \
    package.json \
    pnpm-*.yaml \
    .npmrc \
    tsconfig.json \
    README.md \
    2>/dev/null

echo -e "${GREEN}✓${NC} Package created: ${CYAN}$(basename $DEPLOY_PKG)${NC}"
echo -e "${GREEN}✓${NC} Size: ${CYAN}$(du -h $DEPLOY_PKG | cut -f1)${NC}"

echo ""

# Step 5: Upload Package to Instance
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}[5/10]${NC} Uploading to Instance..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

gcloud compute scp $DEPLOY_PKG \
    ${GCP_INSTANCE}:/tmp/openclaw-deploy.tar.gz \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --quiet

echo -e "${GREEN}✓${NC} Package uploaded"

echo ""

# Step 6: Setup Instance
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}[6/10]${NC} Setting Up Instance..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="
        set -e
        echo '→ Creating directory structure...'
        mkdir -p $SERVER_DIR
        cd $SERVER_DIR

        echo '→ Extracting deployment package...'
        tar xzf /tmp/openclaw-deploy.tar.gz

        echo '→ Checking Docker installation...'
        if ! command -v docker &> /dev/null; then
            echo '✗ Docker not installed. Installing...'
            curl -fsSL https://get.docker.com | sh
            sudo usermod -aG docker \$USER
        fi

        echo '→ Checking Docker Compose...'
        if ! command -v docker-compose &> /dev/null; then
            echo '✗ Docker Compose not installed. Installing...'
            sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        fi

        echo '✓ Instance setup complete'
    " --quiet

echo -e "${GREEN}✓${NC} Instance configured"

echo ""

# Step 7: Configure Environment
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}[7/10]${NC} Configuring Environment..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Copy .env if it exists
if [ -f .env ]; then
    echo -e "${CYAN}→${NC} Uploading .env file..."
    gcloud compute scp .env \
        ${GCP_INSTANCE}:${SERVER_DIR}/.env \
        --zone=$GCP_ZONE \
        --project=$GCP_PROJECT \
        --quiet
    echo -e "${GREEN}✓${NC} Environment configured"
else
    echo -e "${YELLOW}⚠${NC} No .env file found locally"
    echo -e "${CYAN}→${NC} Creating .env from example on server..."
    gcloud compute ssh $GCP_INSTANCE \
        --zone=$GCP_ZONE \
        --project=$GCP_PROJECT \
        --command="cd $SERVER_DIR && cp .env.example .env" \
        --quiet
    echo -e "${YELLOW}⚠${NC} Please update .env on server with actual values"
fi

echo ""

# Step 8: Build Images on Instance
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}[8/10]${NC} Building Images on Instance..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="
        cd $SERVER_DIR
        echo '→ Building landing page...'
        docker build -t openclaw-landing:latest -f apps/landing/Dockerfile .
        echo '→ Building assistant portal...'
        docker build -t openclaw-assistant:latest -f apps/assistant/Dockerfile .
        echo '→ Building gateway...'
        docker build -t openclaw-gateway:latest -f apps/gateway/Dockerfile .
        echo '✓ All images built'
    " --quiet

echo -e "${GREEN}✓${NC} Images built successfully"

echo ""

# Step 9: Deploy Services
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}[9/10]${NC} Deploying Services..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="
        cd $SERVER_DIR
        echo '→ Stopping old containers...'
        docker-compose down 2>/dev/null || true
        echo '→ Starting services...'
        docker-compose up -d
        echo '→ Waiting for services to be healthy...'
        sleep 10
        echo '✓ Services deployed'
    " --quiet

echo -e "${GREEN}✓${NC} Services started"

echo ""

# Step 10: Verify Deployment
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}[10/10]${NC} Verifying Deployment..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="
        cd $SERVER_DIR
        docker-compose ps
    " --quiet

echo ""
echo -e "${GREEN}✓${NC} Deployment verification complete"

# Final Summary
echo ""
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║   🎉  Deployment Complete!                                ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}Services deployed to:${NC}"
echo -e "  🌐 Landing:   http://${EXTERNAL_IP}:3000"
echo -e "  🌐 Landing:   https://devops-agents.bemind.tech"
echo -e "  🚀 Gateway:   http://${EXTERNAL_IP}:18789"
echo -e "  🚀 Gateway:   https://openclaw-agents.bemind.tech"
echo -e "  👤 Assistant: http://${EXTERNAL_IP}:5555"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Update DNS records to point to: ${CYAN}${EXTERNAL_IP}${NC}"
echo -e "  2. Configure SSL certificates for domains"
echo -e "  3. Update .env with production values"
echo -e "  4. Monitor logs: ${CYAN}gcloud compute ssh $GCP_INSTANCE --zone=$GCP_ZONE --command='cd $SERVER_DIR && docker-compose logs -f'${NC}"
echo ""
echo -e "${GREEN}✓${NC} Deployment package saved: ${CYAN}${DEPLOY_PKG}${NC}"
echo ""
