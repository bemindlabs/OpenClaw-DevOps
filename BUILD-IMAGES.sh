#!/bin/bash
# Build all Docker images for OpenClaw DevOps (pnpm monorepo)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Building OpenClaw Docker Images          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

cd "$(dirname "$0")"

# Check for pnpm-lock.yaml
if [ ! -f "pnpm-lock.yaml" ]; then
    echo -e "${RED}Error: pnpm-lock.yaml not found${NC}"
    echo "Run 'pnpm install' first to generate the lockfile"
    exit 1
fi

# Build Landing Page (with root context for monorepo)
echo -e "${YELLOW}[1/3]${NC} Building Landing Page image..."
docker build -f apps/landing/Dockerfile -t openclaw-landing:latest .
echo -e "${GREEN}✓${NC} Landing image built"
echo ""

# Build Assistant Portal
echo -e "${YELLOW}[2/3]${NC} Building Assistant Portal image..."
docker build -f apps/assistant/Dockerfile -t openclaw-assistant:latest .
echo -e "${GREEN}✓${NC} Assistant image built"
echo ""

# Build OpenClaw Gateway
echo -e "${YELLOW}[3/3]${NC} Building OpenClaw Gateway image..."
docker build -f apps/gateway/Dockerfile -t openclaw-gateway:latest .
echo -e "${GREEN}✓${NC} Gateway image built"
echo ""

echo -e "${GREEN}✅ All images built successfully!${NC}"
echo ""
echo "Images:"
docker images | grep openclaw
echo ""
