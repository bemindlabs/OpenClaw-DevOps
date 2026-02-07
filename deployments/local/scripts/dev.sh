#!/bin/bash
# Start local development environment

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Starting Local Development               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

cd "$(dirname "$0")/../../.."

echo -e "${YELLOW}[1/2]${NC} Starting nginx..."
docker-compose up -d nginx
echo -e "${GREEN}✓${NC} Nginx started"
echo ""

echo -e "${YELLOW}[2/2]${NC} Starting Next.js in dev mode..."
echo ""
echo "Run the following in a new terminal:"
echo ""
echo -e "${BLUE}  cd apps/landing && npm run dev${NC}"
echo ""
echo "Services will be available at:"
echo "  http://localhost:3000   (Next.js with hot reload)"
echo "  http://localhost        (via Nginx)"
echo ""
