#!/bin/bash
# Check status of services on GCE instance

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.env"

BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Service Status - $GCP_INSTANCE${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""

echo "Container Status:"
gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="cd $SERVER_DIR && docker-compose ps"

echo ""
echo "Health Checks:"
gcloud compute ssh $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --command="curl -s http://localhost/health && echo -e '\n✓ Nginx: healthy' || echo '✗ Nginx: unhealthy'; \
               curl -s http://localhost:3000 > /dev/null && echo '✓ Landing: healthy' || echo '✗ Landing: unhealthy'; \
               curl -s http://localhost:18789 > /dev/null && echo '✓ Gateway: healthy' || echo '✗ Gateway: unhealthy'"
