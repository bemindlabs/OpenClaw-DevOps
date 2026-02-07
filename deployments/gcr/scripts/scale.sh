#!/bin/bash
# Scale Cloud Run service

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.env"

SERVICE=$1
MIN_INSTANCES=$2
MAX_INSTANCES=$3

if [ -z "$SERVICE" ] || [ -z "$MIN_INSTANCES" ] || [ -z "$MAX_INSTANCES" ]; then
    echo "Usage: $0 <service> <min-instances> <max-instances>"
    echo ""
    echo "Example: $0 gateway 1 20"
    exit 1
fi

SERVICE_NAME_VAR="${SERVICE^^}_SERVICE_NAME"
SERVICE_NAME=${!SERVICE_NAME_VAR}

echo "Scaling $SERVICE_NAME..."
echo "  Min instances: $MIN_INSTANCES"
echo "  Max instances: $MAX_INSTANCES"

gcloud run services update "$SERVICE_NAME" \
    --region="$GCP_REGION" \
    --project="$GCP_PROJECT_ID" \
    --min-instances="$MIN_INSTANCES" \
    --max-instances="$MAX_INSTANCES"

echo "✓ Scaling updated"
