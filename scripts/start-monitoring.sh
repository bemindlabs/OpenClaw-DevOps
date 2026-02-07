#!/bin/bash
# Start monitoring stack
# Includes: Prometheus, Grafana, Exporters

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}Starting Monitoring Stack...${NC}"
echo ""

cd "$PROJECT_ROOT"

# Check .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠${NC}  .env not found, using .env.example"
    cp .env.example .env
fi

# Start monitoring services
docker-compose -f docker-compose.full.yml up -d \
    prometheus \
    grafana \
    node-exporter \
    cadvisor

echo ""
echo -e "${GREEN}✓ Monitoring started${NC}"
echo ""
echo "Access URLs:"
echo "  Grafana:    http://localhost:3001"
echo "  Prometheus: http://localhost:9090"
echo ""
echo "Default credentials (check .env):"
echo "  Grafana: \$GF_SECURITY_ADMIN_USER / \$GF_SECURITY_ADMIN_PASSWORD"
