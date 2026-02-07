#!/bin/bash
# Clean up Docker containers and images

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

cd "$(dirname "$0")/../../.."

echo -e "${YELLOW}Stopping containers...${NC}"
docker-compose down

echo -e "${YELLOW}Removing volumes...${NC}"
docker-compose down -v

echo -e "${YELLOW}Removing images...${NC}"
docker rmi openclaw-landing:latest 2>/dev/null || true

echo -e "${YELLOW}Pruning Docker system...${NC}"
docker system prune -f

echo ""
echo -e "${GREEN}✓ Cleanup complete${NC}"
