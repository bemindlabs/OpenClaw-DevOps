#!/bin/bash
# Deploy OpenClaw DevOps to GCE
# Usage: ./deploy.sh [--build] [--setup]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load configuration
source "$SCRIPT_DIR/config.env"

# Parse arguments
BUILD_IMAGE=false
RUN_SETUP=false

for arg in "$@"; do
    case $arg in
        --build)
            BUILD_IMAGE=true
            shift
            ;;
        --setup)
            RUN_SETUP=true
            shift
            ;;
        *)
            ;;
    esac
done

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Deploying to GCE: $GCP_INSTANCE${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check GCP authentication
echo -e "${YELLOW}[1/7]${NC} Checking GCP authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo -e "${RED}✗${NC} Not authenticated with GCP"
    echo "Run: gcloud auth login"
    exit 1
fi
echo -e "${GREEN}✓${NC} Authenticated as $(gcloud config get-value account)"
echo ""

# Step 2: Verify instance exists
echo -e "${YELLOW}[2/7]${NC} Verifying GCE instance..."
if ! gcloud compute instances describe $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT &>/dev/null; then
    echo -e "${RED}✗${NC} Instance $GCP_INSTANCE not found"
    exit 1
fi
echo -e "${GREEN}✓${NC} Instance found: $GCP_INSTANCE"
echo ""

# Step 3: Build Docker image locally (optional)
if [ "$BUILD_IMAGE" = true ]; then
    echo -e "${YELLOW}[3/7]${NC} Building Docker image locally..."
    cd "$PROJECT_ROOT/apps/landing"
    docker build -t $LANDING_IMAGE .
    echo -e "${GREEN}✓${NC} Image built: $LANDING_IMAGE"
    echo ""
else
    echo -e "${YELLOW}[3/7]${NC} Skipping local build (use --build to enable)"
    echo ""
fi

# Step 4: Run setup script on instance (optional)
if [ "$RUN_SETUP" = true ]; then
    echo -e "${YELLOW}[4/7]${NC} Running setup on instance..."
    gcloud compute scp "$SCRIPT_DIR/setup-instance.sh" \
        $GCP_INSTANCE:~/setup-instance.sh \
        --zone=$GCP_ZONE \
        --project=$GCP_PROJECT

    gcloud compute ssh $GCP_INSTANCE \
        --zone=$GCP_ZONE \
        --project=$GCP_PROJECT \
        --command="chmod +x ~/setup-instance.sh && ~/setup-instance.sh"
    echo -e "${GREEN}✓${NC} Setup completed"
    echo ""
else
    echo -e "${YELLOW}[4/7]${NC} Skipping instance setup (use --setup to enable)"
    echo ""
fi

# Step 5: Sync project files to instance
echo -e "${YELLOW}[5/7]${NC} Syncing files to instance..."

# Create directories on instance
gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="mkdir -p $SERVER_DIR/config"

# Sync files (excluding node_modules, .next, etc.)
gcloud compute scp --recurse \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    "$PROJECT_ROOT"/* \
    $GCP_INSTANCE:$SERVER_DIR/ \
    2>&1 | grep -v "node_modules" | grep -v ".next" || true

# Sync GCE-specific config
gcloud compute scp \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    "$SCRIPT_DIR/config/openclaw-gateway.json" \
    $GCP_INSTANCE:$SERVER_DIR/config/

echo -e "${GREEN}✓${NC} Files synced to $SERVER_DIR"
echo ""

# Step 6: Build images on instance
echo -e "${YELLOW}[6/7]${NC} Building Docker images on instance..."
gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="cd $SERVER_DIR/apps/landing && docker build -t openclaw-landing:latest . && cd ../openclaw-gateway && docker build -t openclaw-gateway:latest ."
echo -e "${GREEN}✓${NC} Images built on instance"
echo ""

# Step 7: Start services
echo -e "${YELLOW}[7/7]${NC} Starting services on instance..."
gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="cd $SERVER_DIR && docker-compose down && docker-compose up -d"
echo -e "${GREEN}✓${NC} Services started"
echo ""

# Get instance IP
INSTANCE_IP=$(gcloud compute instances describe $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Deployment completed!${NC}"
echo ""
echo "Instance: $GCP_INSTANCE"
echo "External IP: $INSTANCE_IP"
echo ""
echo "Services:"
echo "  Landing:  http://$INSTANCE_IP (http://$LANDING_DOMAIN)"
echo "  Gateway:  http://$INSTANCE_IP:$GATEWAY_PORT (http://$GATEWAY_DOMAIN)"
echo "  Nginx:    http://$INSTANCE_IP/health"
echo ""
echo "SSH to instance:"
echo "  gcloud compute ssh $GCP_INSTANCE --zone=$GCP_ZONE --project=$GCP_PROJECT"
echo ""
echo "View logs:"
echo "  gcloud compute ssh $GCP_INSTANCE --zone=$GCP_ZONE --project=$GCP_PROJECT \\"
echo "    --command=\"cd $SERVER_DIR && docker-compose logs -f\""
echo ""
