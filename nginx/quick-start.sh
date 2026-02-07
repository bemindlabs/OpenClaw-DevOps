#!/bin/bash
# Quick Start for OpenClaw Nginx
# Subdomain: openclaw.agents.ddns.net

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  OpenClaw Nginx - Quick Start             ║${NC}"
echo -e "${BLUE}║  Subdomain: openclaw.agents.ddns.net      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Change to script directory
cd "$(dirname "$0")"

echo -e "${YELLOW}[1/5]${NC} สร้าง SSL certificate (self-signed สำหรับทดสอบ)..."
if [ ! -f "ssl/cert.pem" ] || [ ! -f "ssl/key.pem" ]; then
    mkdir -p ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/key.pem \
        -out ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=OpenClaw/CN=openclaw.your-domain.com" 2>/dev/null
    chmod 600 ssl/key.pem
    chmod 644 ssl/cert.pem
    echo -e "${GREEN}✓${NC} Self-signed certificate created"
    echo -e "${YELLOW}⚠${NC}  สำหรับ production ใช้ Let's Encrypt: ./get-letsencrypt.sh"
else
    echo -e "${GREEN}✓${NC} SSL certificates exist"
fi
echo ""

echo -e "${YELLOW}[2/5]${NC} ทดสอบ nginx configuration..."
docker compose run --rm nginx nginx -t || {
    echo -e "${RED}✗${NC} Nginx config error!"
    exit 1
}
echo -e "${GREEN}✓${NC} Config OK"
echo ""

echo -e "${YELLOW}[3/5]${NC} เริ่มต้น nginx docker..."
docker compose up -d
echo -e "${GREEN}✓${NC} Nginx started"
echo ""

echo -e "${YELLOW}[4/5]${NC} รอ nginx พร้อม..."
sleep 3
echo ""

echo -e "${YELLOW}[5/5]${NC} ตรวจสอบสถานะ..."
docker compose ps
echo ""

# Test
echo "Testing..."
if curl -f -s -k https://localhost/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} HTTPS working (https://localhost/health)"
else
    echo -e "${RED}✗${NC} HTTPS not working"
fi

if curl -f -s http://127.0.0.1:18789 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Gateway running (http://127.0.0.1:18789)"
else
    echo -e "${RED}✗${NC} Gateway not running!"
fi
echo ""

echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Nginx Docker is running!${NC}"
echo ""
echo "Next steps:"
echo "  1. Setup DNS: openclaw.agents.ddns.net → 58.136.234.96"
echo "  2. Setup port forwarding on router"
echo "  3. Get Let's Encrypt SSL: ./get-letsencrypt.sh"
echo ""
echo "Commands:"
echo "  docker compose logs -f    # View logs"
echo "  docker compose down       # Stop"
echo "  docker compose restart    # Restart"
echo ""
echo "Test URLs:"
echo "  Local:    https://localhost/health"
echo "  External: https://openclaw.agents.ddns.net/health"
echo ""
