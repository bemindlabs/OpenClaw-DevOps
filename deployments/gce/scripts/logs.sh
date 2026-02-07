#!/bin/bash
# View logs from GCE instance
# Usage: ./logs.sh [service_name] [-f]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.env"

SERVICE=""
FOLLOW=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        -f|--follow)
            FOLLOW="-f"
            shift
            ;;
        *)
            SERVICE=$arg
            shift
            ;;
    esac
done

if [ -z "$SERVICE" ]; then
    gcloud compute ssh $GCP_INSTANCE \
        --zone=$GCP_ZONE \
        --project=$GCP_PROJECT \
        --command="cd $SERVER_DIR && docker-compose logs $FOLLOW"
else
    gcloud compute ssh $GCP_INSTANCE \
        --zone=$GCP_ZONE \
        --project=$GCP_PROJECT \
        --command="cd $SERVER_DIR && docker-compose logs $FOLLOW $SERVICE"
fi
