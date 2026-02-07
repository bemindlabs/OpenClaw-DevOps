#!/bin/bash
# View Cloud Run service logs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.env"

SERVICE=${1:-all}
FOLLOW=${2:-false}

if [ "$SERVICE" == "all" ]; then
    echo "Fetching logs for all services..."
    echo ""
    
    for svc in "$LANDING_SERVICE_NAME" "$GATEWAY_SERVICE_NAME" "$ASSISTANT_SERVICE_NAME"; do
        echo "=== $svc ==="
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$svc" \
            --limit=20 \
            --format="table(timestamp,severity,textPayload)" \
            --project="$GCP_PROJECT_ID"
        echo ""
    done
else
    SERVICE_NAME_VAR="${SERVICE^^}_SERVICE_NAME"
    SERVICE_NAME=${!SERVICE_NAME_VAR}
    
    if [ "$FOLLOW" == "-f" ] || [ "$FOLLOW" == "--follow" ]; then
        echo "Streaming logs for $SERVICE_NAME (Ctrl+C to stop)..."
        gcloud logging tail "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" \
            --project="$GCP_PROJECT_ID"
    else
        echo "Recent logs for $SERVICE_NAME:"
        gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" \
            --limit=50 \
            --format="table(timestamp,severity,textPayload)" \
            --project="$GCP_PROJECT_ID"
    fi
fi
