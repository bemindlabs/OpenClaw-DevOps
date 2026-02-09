#!/bin/bash

# Portainer Deployment Script for GCE
# Deploys Portainer and sets up Cloudflare DNS

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.env"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              PORTAINER DEPLOYMENT TO GCE                              ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Verify GCloud Authentication
echo -e "${YELLOW}Step 1: Verifying GCloud Authentication...${NC}"
echo ""

if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
    echo -e "${RED}Error: No active GCloud authentication found${NC}"
    echo "Please run: gcloud auth login"
    exit 1
fi

ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1)
echo -e "${GREEN}✓ Authenticated as: $ACTIVE_ACCOUNT${NC}"
echo ""

# Step 2: Push Latest Changes to Repository
echo -e "${YELLOW}Step 2: Pushing latest changes to repository...${NC}"
echo ""

cd "${SCRIPT_DIR}/../.."
CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo -e "${YELLOW}Warning: You're on branch '$CURRENT_BRANCH', not 'develop'${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Pushing to origin/$CURRENT_BRANCH..."
git push origin $CURRENT_BRANCH

echo -e "${GREEN}✓ Code pushed to repository${NC}"
echo ""

# Step 3: Deploy to GCE
echo -e "${YELLOW}Step 3: Deploying Portainer to GCE...${NC}"
echo ""

echo "Connecting to $GCP_INSTANCE..."

# Pull latest code on GCE
gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="
        set -e
        cd /home/info_bemind_tech/openclaw
        echo '==> Pulling latest code...'
        git fetch origin
        git checkout develop
        git pull origin develop
        echo '✓ Code updated'
    "

echo -e "${GREEN}✓ Code updated on GCE${NC}"
echo ""

# Copy Portainer nginx configuration
echo "Copying Portainer nginx configuration..."
cd "${SCRIPT_DIR}/../.."
gcloud compute scp nginx/conf.d/portainer.conf \
    $GCP_INSTANCE:/home/info_bemind_tech/openclaw/nginx/conf.d/ \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT

echo -e "${GREEN}✓ Nginx configuration copied${NC}"
echo ""

# Start Portainer container
echo "Starting Portainer container..."
gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="
        set -e
        cd /home/info_bemind_tech/openclaw
        echo '==> Pulling Portainer image...'
        docker-compose pull portainer
        echo '==> Starting Portainer...'
        docker-compose up -d portainer
        echo '==> Restarting nginx...'
        docker-compose restart nginx
        echo '✓ Portainer started'
    "

echo -e "${GREEN}✓ Portainer deployed and running${NC}"
echo ""

# Step 4: Setup Cloudflare DNS
echo -e "${YELLOW}Step 4: Setting up Cloudflare DNS...${NC}"
echo ""

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${RED}Error: CLOUDFLARE_API_TOKEN not set${NC}"
    echo "Please export CLOUDFLARE_API_TOKEN before running this script"
    exit 1
fi

if [ -z "$CLOUDFLARE_ZONE_ID" ]; then
    echo -e "${RED}Error: CLOUDFLARE_ZONE_ID not set${NC}"
    echo "Please export CLOUDFLARE_ZONE_ID before running this script"
    exit 1
fi

cd "${SCRIPT_DIR}"
./setup-cloudflare-dns.sh

echo -e "${GREEN}✓ DNS configured${NC}"
echo ""

# Step 5: Verify Deployment
echo -e "${YELLOW}Step 5: Verifying deployment...${NC}"
echo ""

echo "Checking container status..."
gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="docker ps | grep portainer"

echo ""
echo "Checking DNS resolution..."
sleep 5  # Wait for DNS propagation
dig +short $PORTAINER_DOMAIN @1.1.1.1 | head -n 1

echo ""
echo "Testing HTTPS access..."
sleep 10  # Wait a bit more for everything to be ready
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://$PORTAINER_DOMAIN/ || echo "000")

if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "302" ]; then
    echo -e "${GREEN}✓ HTTPS access successful (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${YELLOW}⚠ HTTPS returned HTTP $HTTP_CODE (may need a few minutes)${NC}"
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              PORTAINER DEPLOYMENT COMPLETE!                           ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Portainer is now accessible at:"
echo -e "  ${BLUE}https://$PORTAINER_DOMAIN${NC}"
echo ""
echo "Next steps:"
echo "  1. Open https://$PORTAINER_DOMAIN in your browser"
echo "  2. Create admin user (minimum 12 characters)"
echo "  3. Select 'Docker' environment and click 'Connect'"
echo "  4. Start managing your containers!"
echo ""
echo "All domains configured:"
echo "  • Landing:   https://$LANDING_DOMAIN"
echo "  • Gateway:   https://$GATEWAY_DOMAIN"
echo "  • Admin:     https://admin-agents.bemind.tech"
echo "  • Portainer: https://$PORTAINER_DOMAIN"
echo ""
