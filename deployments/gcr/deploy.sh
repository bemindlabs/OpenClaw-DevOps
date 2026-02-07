#!/bin/bash
# OpenClaw DevOps - Google Cloud Run Deployment Script
# Deploys all services to Cloud Run with zero downtime

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  OpenClaw - Cloud Run Deployment          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Load configuration
if [ -f "$SCRIPT_DIR/config.env" ]; then
    source "$SCRIPT_DIR/config.env"
    echo -e "${GREEN}✓${NC} Loaded configuration from config.env"
else
    echo -e "${RED}Error: config.env not found${NC}"
    exit 1
fi

# Validate required variables
if [ -z "$GCP_PROJECT_ID" ] || [ "$GCP_PROJECT_ID" == "your-gcp-project-id" ]; then
    echo -e "${RED}Error: GCP_PROJECT_ID not configured in config.env${NC}"
    exit 1
fi

# Parse command line arguments
BUILD_IMAGES=true
DEPLOY_SERVICES=true
SERVICE_TO_DEPLOY="all"

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build)
            BUILD_IMAGES=false
            shift
            ;;
        --only-build)
            DEPLOY_SERVICES=false
            shift
            ;;
        --service)
            SERVICE_TO_DEPLOY="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-build       Skip building Docker images"
            echo "  --only-build       Only build images, don't deploy"
            echo "  --service <name>   Deploy only specific service (landing|gateway|assistant)"
            echo "  --help             Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Set GCP project
echo ""
echo -e "${YELLOW}[1/6]${NC} Setting GCP project..."
gcloud config set project "$GCP_PROJECT_ID"
echo -e "${GREEN}✓${NC} Project set to: $GCP_PROJECT_ID"

# Enable required APIs
echo ""
echo -e "${YELLOW}[2/6]${NC} Checking required APIs..."
REQUIRED_APIS=(
    "run.googleapis.com"
    "cloudbuild.googleapis.com"
    "containerregistry.googleapis.com"
)

for api in "${REQUIRED_APIS[@]}"; do
    if gcloud services list --enabled --filter="name:$api" --format="value(name)" | grep -q "$api"; then
        echo -e "${GREEN}✓${NC} $api is enabled"
    else
        echo -e "${YELLOW}⚠${NC}  Enabling $api..."
        gcloud services enable "$api"
    fi
done

# Build Docker images
if [ "$BUILD_IMAGES" = true ]; then
    echo ""
    echo -e "${YELLOW}[3/6]${NC} Building Docker images..."
    cd "$PROJECT_ROOT"
    
    if [ ! -f "pnpm-lock.yaml" ]; then
        echo -e "${RED}Error: pnpm-lock.yaml not found. Run 'pnpm install' first.${NC}"
        exit 1
    fi
    
    # Determine which services to build
    SERVICES_TO_BUILD=()
    if [ "$SERVICE_TO_DEPLOY" == "all" ]; then
        SERVICES_TO_BUILD=("landing" "gateway" "assistant")
    else
        SERVICES_TO_BUILD=("$SERVICE_TO_DEPLOY")
    fi
    
    for service in "${SERVICES_TO_BUILD[@]}"; do
        echo ""
        echo -e "${BLUE}Building $service...${NC}"
        
        # Build using Cloud Build for faster builds
        if command -v gcloud builds submit &> /dev/null; then
            gcloud builds submit \
                --config=deployments/gcr/cloudbuild-${service}.yaml \
                --substitutions=_IMAGE_TAG=${REVISION_TAG:-latest} \
                --timeout=${BUILD_TIMEOUT:-1200}s \
                .
        else
            # Fallback to local build + push
            IMAGE_NAME="${REGISTRY_TYPE}/${GCP_PROJECT_ID}/openclaw-${service}:${REVISION_TAG:-latest}"
            docker build -f apps/${service}/Dockerfile -t "$IMAGE_NAME" .
            docker push "$IMAGE_NAME"
        fi
        
        echo -e "${GREEN}✓${NC} $service image built and pushed"
    done
fi

# Deploy to Cloud Run
if [ "$DEPLOY_SERVICES" = true ]; then
    echo ""
    echo -e "${YELLOW}[4/6]${NC} Deploying services to Cloud Run..."
    
    # Helper function to deploy a service
    deploy_service() {
        local SERVICE=$1
        local SERVICE_NAME_VAR="${SERVICE^^}_SERVICE_NAME"
        local SERVICE_NAME=${!SERVICE_NAME_VAR}
        local IMAGE_TAG_VAR="${SERVICE^^}_IMAGE_TAG"
        local IMAGE_TAG=${!IMAGE_TAG_VAR:-latest}
        local CPU_VAR="${SERVICE^^}_CPU"
        local CPU=${!CPU_VAR:-1}
        local MEMORY_VAR="${SERVICE^^}_MEMORY"
        local MEMORY=${!MEMORY_VAR:-512Mi}
        local MIN_INSTANCES_VAR="${SERVICE^^}_MIN_INSTANCES"
        local MIN_INSTANCES=${!MIN_INSTANCES_VAR:-0}
        local MAX_INSTANCES_VAR="${SERVICE^^}_MAX_INSTANCES"
        local MAX_INSTANCES=${!MAX_INSTANCES_VAR:-10}
        local CONCURRENCY_VAR="${SERVICE^^}_CONCURRENCY"
        local CONCURRENCY=${!CONCURRENCY_VAR:-80}
        local TIMEOUT_VAR="${SERVICE^^}_TIMEOUT"
        local TIMEOUT=${!TIMEOUT_VAR:-300}
        
        echo ""
        echo -e "${BLUE}Deploying $SERVICE_NAME...${NC}"
        
        IMAGE_URL="${REGISTRY_TYPE}/${GCP_PROJECT_ID}/openclaw-${SERVICE}:${IMAGE_TAG}"
        
        # Deploy using gcloud run deploy
        gcloud run deploy "$SERVICE_NAME" \
            --image="$IMAGE_URL" \
            --region="$GCP_REGION" \
            --platform=managed \
            --cpu="$CPU" \
            --memory="$MEMORY" \
            --min-instances="$MIN_INSTANCES" \
            --max-instances="$MAX_INSTANCES" \
            --concurrency="$CONCURRENCY" \
            --timeout="${TIMEOUT}s" \
            --ingress="$INGRESS" \
            --execution-environment="$EXECUTION_ENVIRONMENT" \
            --allow-unauthenticated \
            --quiet
        
        echo -e "${GREEN}✓${NC} $SERVICE_NAME deployed successfully"
        
        # Get service URL
        SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
            --region="$GCP_REGION" \
            --format='value(status.url)')
        
        echo -e "${BLUE}   URL:${NC} $SERVICE_URL"
    }
    
    # Deploy services
    if [ "$SERVICE_TO_DEPLOY" == "all" ]; then
        deploy_service "landing"
        deploy_service "gateway"
        deploy_service "assistant"
    else
        deploy_service "$SERVICE_TO_DEPLOY"
    fi
fi

# Get service URLs
echo ""
echo -e "${YELLOW}[5/6]${NC} Retrieving service URLs..."
echo ""

LANDING_URL=$(gcloud run services describe "${LANDING_SERVICE_NAME}" \
    --region="$GCP_REGION" \
    --format='value(status.url)' 2>/dev/null || echo "Not deployed")

GATEWAY_URL=$(gcloud run services describe "${GATEWAY_SERVICE_NAME}" \
    --region="$GCP_REGION" \
    --format='value(status.url)' 2>/dev/null || echo "Not deployed")

ASSISTANT_URL=$(gcloud run services describe "${ASSISTANT_SERVICE_NAME}" \
    --region="$GCP_REGION" \
    --format='value(status.url)' 2>/dev/null || echo "Not deployed")

# Health checks
echo -e "${YELLOW}[6/6]${NC} Running health checks..."
echo ""

check_health() {
    local NAME=$1
    local URL=$2
    local PATH=$3
    
    if [ "$URL" != "Not deployed" ]; then
        if curl -sf "${URL}${PATH}" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $NAME is healthy"
        else
            echo -e "${YELLOW}⚠${NC}  $NAME is deployed but not responding (may still be starting)"
        fi
    fi
}

check_health "Landing" "$LANDING_URL" "/"
check_health "Gateway" "$GATEWAY_URL" "/health"
check_health "Assistant" "$ASSISTANT_URL" "/"

# Summary
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Deployment Complete!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Service URLs:${NC}"
echo "  Landing:   $LANDING_URL"
echo "  Gateway:   $GATEWAY_URL"
echo "  Assistant: $ASSISTANT_URL"
echo ""
echo -e "${BLUE}GCP Console:${NC}"
echo "  https://console.cloud.google.com/run?project=$GCP_PROJECT_ID"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Configure custom domains (optional)"
echo "  2. Set up Cloud CDN for landing page (optional)"
echo "  3. Configure Cloud SQL or MongoDB Atlas for databases"
echo "  4. Set up Secret Manager for sensitive credentials"
echo "  5. Configure Cloud Monitoring and Logging"
echo ""
