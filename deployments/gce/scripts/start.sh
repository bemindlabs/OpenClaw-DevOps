#!/bin/bash
# Start OpenClaw services on GCE instance
# Usage: ./start.sh [service_name]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.env"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SERVICE=$1

if [ -z "$SERVICE" ]; then
    echo -e "${YELLOW}Starting all services...${NC}"
    gcloud compute ssh $GCP_INSTANCE \
        --zone=$GCP_ZONE \
        --project=$GCP_PROJECT \
        --command="cd $SERVER_DIR && docker-compose up -d"
    echo -e "${GREEN}✓ All services started${NC}"
else
    echo -e "${YELLOW}Starting $SERVICE...${NC}"
    gcloud compute ssh $GCP_INSTANCE \
        --zone=$GCP_ZONE \
        --project=$GCP_PROJECT \
        --command="cd $SERVER_DIR && docker-compose up -d $SERVICE"
    echo -e "${GREEN}✓ $SERVICE started${NC}"
fi
