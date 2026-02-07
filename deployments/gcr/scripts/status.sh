#!/bin/bash
# Check Cloud Run services status

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.env"

echo "╔════════════════════════════════════════════╗"
echo "║  Cloud Run Services Status                ║"
echo "╚════════════════════════════════════════════╝"
echo ""

for service in "$LANDING_SERVICE_NAME" "$GATEWAY_SERVICE_NAME" "$ASSISTANT_SERVICE_NAME"; do
    echo "=== $service ==="
    
    # Get service details
    if gcloud run services describe "$service" --region="$GCP_REGION" --project="$GCP_PROJECT_ID" &>/dev/null; then
        URL=$(gcloud run services describe "$service" \
            --region="$GCP_REGION" \
            --project="$GCP_PROJECT_ID" \
            --format='value(status.url)')
        
        STATUS=$(gcloud run services describe "$service" \
            --region="$GCP_REGION" \
            --project="$GCP_PROJECT_ID" \
            --format='value(status.conditions[0].status)')
        
        TRAFFIC=$(gcloud run services describe "$service" \
            --region="$GCP_REGION" \
            --project="$GCP_PROJECT_ID" \
            --format='value(status.traffic[0].percent)')
        
        echo "  Status: $STATUS"
        echo "  URL: $URL"
        echo "  Traffic: ${TRAFFIC}%"
        
        # Health check
        if curl -sf "$URL" > /dev/null 2>&1; then
            echo "  Health: ✓ Healthy"
        else
            echo "  Health: ✗ Not responding"
        fi
    else
        echo "  Status: Not deployed"
    fi
    echo ""
done
