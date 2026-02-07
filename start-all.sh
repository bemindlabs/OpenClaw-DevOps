#!/bin/bash
# Start all OpenClaw services (pnpm monorepo)
# Run from project root directory

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Starting OpenClaw Services               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Change to script directory
cd "$(dirname "$0")"

# Check for pnpm-lock.yaml
if [ ! -f "pnpm-lock.yaml" ]; then
    echo -e "${RED}Error: pnpm-lock.yaml not found${NC}"
    echo "Run 'pnpm install' first to generate the lockfile"
    exit 1
fi

# Check for .env
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Warning: .env not found, copying from .env.example${NC}"
    cp .env.example .env
fi

echo -e "${YELLOW}[1/3]${NC} Building Docker images..."
# Use make command for building
make build
echo ""

echo -e "${YELLOW}[2/3]${NC} Starting Docker containers..."
# Use make command for starting
make start
echo ""

echo -e "${YELLOW}[3/3]${NC} Testing services..."
echo ""

# Test services
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Service Status${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""

if curl -f -s http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Landing Page: http://localhost:3000"
else
    echo -e "${YELLOW}⚠${NC}  Landing Page: Not ready yet"
fi

if curl -f -s http://localhost:5555 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Assistant: http://localhost:5555"
else
    echo -e "${YELLOW}⚠${NC}  Assistant: Not ready yet"
fi

if curl -f -s http://localhost/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Nginx: http://localhost/health"
else
    echo -e "${YELLOW}⚠${NC}  Nginx: Not ready yet"
fi

if curl -f -s http://127.0.0.1:18789 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Gateway: http://127.0.0.1:18789"
else
    echo -e "${YELLOW}⚠${NC}  Gateway: Not running"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Services started successfully!${NC}"
echo ""
echo "URLs:"
echo "  Landing:   http://your-domain.com"
echo "  Assistant: http://assistant.your-domain.com"
echo "  Gateway:   http://openclaw.your-domain.com"
echo ""
echo "Commands:"
echo "  make logs                      # View logs"
echo "  make restart                   # Restart all"
echo "  make stop                      # Stop all"
echo "  make health                    # Health check"
echo "  make help                      # Show all commands"
echo ""
echo "Development:"
echo "  make dev                       # Start all apps in dev mode"
echo "  make dev-landing               # Start landing dev server"
echo "  make dev-assistant             # Start assistant dev server"
echo "  make dev-gateway               # Start gateway dev server"
echo ""
