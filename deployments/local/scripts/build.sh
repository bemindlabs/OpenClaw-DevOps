#!/bin/bash
# Build all Docker images locally

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd "$(dirname "$0")/../../.."

echo -e "${YELLOW}Building landing page image...${NC}"
cd apps/landing
docker build -t openclaw-landing:latest .

echo -e "${YELLOW}Building gateway image...${NC}"
cd ../openclaw-gateway
docker build -t openclaw-gateway:latest .
cd ../..

echo ""
echo -e "${GREEN}✓ All images built${NC}"
echo ""
echo "Images:"
docker images | grep openclaw
