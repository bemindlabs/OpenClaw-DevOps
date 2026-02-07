#!/bin/bash
# Rollback Cloud Run service to previous revision

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.env"

SERVICE=$1

if [ -z "$SERVICE" ]; then
    echo "Usage: $0 <service>"
    echo ""
    echo "Services: landing, gateway, assistant"
    exit 1
fi

SERVICE_NAME_VAR="${SERVICE^^}_SERVICE_NAME"
SERVICE_NAME=${!SERVICE_NAME_VAR}

echo "Rolling back $SERVICE_NAME to previous revision..."

# Get previous revision
PREVIOUS_REVISION=$(gcloud run revisions list \
    --service="$SERVICE_NAME" \
    --region="$GCP_REGION" \
    --project="$GCP_PROJECT_ID" \
    --format='value(metadata.name)' \
    --limit=2 | tail -1)

if [ -z "$PREVIOUS_REVISION" ]; then
    echo "Error: No previous revision found"
    exit 1
fi

echo "Previous revision: $PREVIOUS_REVISION"
read -p "Proceed with rollback? [y/N] " confirm

if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
    gcloud run services update-traffic "$SERVICE_NAME" \
        --region="$GCP_REGION" \
        --project="$GCP_PROJECT_ID" \
        --to-revisions="$PREVIOUS_REVISION=100"
    
    echo "✓ Rollback complete"
else
    echo "Rollback cancelled"
fi
