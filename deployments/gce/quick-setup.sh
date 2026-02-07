#!/bin/bash
# Quick setup Docker & Docker Compose on GCE instance
# Run from local machine

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Quick Setup - Docker on GCE              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check authentication
echo -e "${YELLOW}[1/3]${NC} Checking GCP authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo -e "${RED}✗${NC} Not authenticated"
    echo "Run: gcloud auth login"
    exit 1
fi
echo -e "${GREEN}✓${NC} Authenticated"
echo ""

# Upload setup script
echo -e "${YELLOW}[2/3]${NC} Uploading Docker setup script..."
gcloud compute scp "$SCRIPT_DIR/scripts/setup-docker.sh" \
    $GCP_INSTANCE:~/setup-docker.sh \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT
echo -e "${GREEN}✓${NC} Script uploaded"
echo ""

# Run setup
echo -e "${YELLOW}[3/3]${NC} Running Docker setup on instance..."
echo ""
gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="chmod +x ~/setup-docker.sh && ~/setup-docker.sh"

echo ""
echo -e "${GREEN}✅ Docker setup completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Deploy application: ./deploy.sh"
echo "2. View status: ./scripts/status.sh"
echo ""
