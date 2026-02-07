#!/bin/bash
# Start only database services
# Includes: MongoDB, PostgreSQL, Redis

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}Starting Database Services...${NC}"
echo ""

cd "$PROJECT_ROOT"

# Check .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠${NC}  .env not found, using .env.example"
    cp .env.example .env
fi

# Start only database services
docker-compose -f docker-compose.full.yml up -d mongodb postgres redis

echo ""
echo -e "${GREEN}✓ Databases started${NC}"
echo ""
echo "Services:"
echo "  MongoDB:    localhost:27017"
echo "  PostgreSQL: localhost:5432"
echo "  Redis:      localhost:6379"
echo ""
echo "Check logs: docker-compose -f docker-compose.full.yml logs -f mongodb postgres redis"
