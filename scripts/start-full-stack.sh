#!/bin/bash
# Start full OpenClaw stack with all services
# Includes: nginx, landing, databases, messaging, monitoring

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Starting OpenClaw Full Stack             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if .env exists
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo -e "${RED}✗${NC} .env file not found"
    echo ""
    echo "Please create .env file from .env.example:"
    echo -e "${YELLOW}  cp .env.example .env${NC}"
    echo ""
    echo "Then update the passwords in .env file"
    exit 1
fi

# Load environment variables
source "$PROJECT_ROOT/.env"

# Check required variables
REQUIRED_VARS=(
    "MONGO_INITDB_ROOT_PASSWORD"
    "POSTGRES_PASSWORD"
    "REDIS_PASSWORD"
    "N8N_BASIC_AUTH_PASSWORD"
    "GF_SECURITY_ADMIN_PASSWORD"
)

MISSING_VARS=()
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo -e "${RED}✗${NC} Missing required environment variables:"
    printf '  - %s\n' "${MISSING_VARS[@]}"
    echo ""
    echo "Please update your .env file"
    exit 1
fi

# Build images if needed
echo -e "${YELLOW}[1/3]${NC} Checking Docker images..."

if ! docker images | grep -q "openclaw-landing"; then
    echo "Building landing image..."
    cd "$PROJECT_ROOT/apps/landing"
    docker build -t openclaw-landing:latest .
fi

if ! docker images | grep -q "openclaw-gateway"; then
    echo "Building gateway image..."
    cd "$PROJECT_ROOT/apps/gateway"
    docker build -t openclaw-gateway:latest .
fi

cd "$PROJECT_ROOT"
echo -e "${GREEN}✓${NC} Images ready"
echo ""

# Start services
echo -e "${YELLOW}[2/3]${NC} Starting all services..."
cd "$PROJECT_ROOT"
docker-compose -f docker-compose.full.yml up -d
echo -e "${GREEN}✓${NC} Services started"
echo ""

# Wait for services
echo -e "${YELLOW}[3/3]${NC} Waiting for services to be ready..."
sleep 10
echo ""

# Check status
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Service Status${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
docker-compose -f docker-compose.full.yml ps
echo ""

# Display access information
echo -e "${GREEN}✅ Full stack started successfully!${NC}"
echo ""
echo -e "${BLUE}Access URLs:${NC}"
echo ""
echo "📱 Applications:"
echo "  Landing Page:    http://localhost:3000"
echo "  OpenClaw Gateway: http://localhost:18789"
echo "  n8n Workflows:   http://localhost:5678"
echo ""
echo "📊 Monitoring:"
echo "  Grafana:         http://localhost:3001"
echo "  Prometheus:      http://localhost:9090"
echo ""
echo "🗄️  Databases:"
echo "  MongoDB:         localhost:27017"
echo "  PostgreSQL:      localhost:5432"
echo "  Redis:           localhost:6379"
echo ""
echo "📨 Messaging:"
echo "  Kafka:           localhost:9092"
echo "  Zookeeper:       localhost:2181"
echo ""
echo -e "${YELLOW}Login Credentials (from .env):${NC}"
echo "  n8n:             ${N8N_BASIC_AUTH_USER} / ${N8N_BASIC_AUTH_PASSWORD}"
echo "  Grafana:         ${GF_SECURITY_ADMIN_USER} / ${GF_SECURITY_ADMIN_PASSWORD}"
echo ""
echo "Commands:"
echo "  View logs:       docker-compose -f docker-compose.full.yml logs -f"
echo "  Stop all:        docker-compose -f docker-compose.full.yml down"
echo "  Restart:         docker-compose -f docker-compose.full.yml restart"
echo ""
