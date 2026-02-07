#!/bin/bash
# Setup Nginx Docker for OpenClaw
# Author: Kla
# Date: 2026-02-01

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  OpenClaw Nginx Docker Setup              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Create directories
echo -e "${YELLOW}[1/6]${NC} สร้าง directories..."
mkdir -p nginx/ssl nginx/conf.d /var/www/certbot
echo -e "${GREEN}✓${NC} Directories created"
echo ""

# Step 2: Copy SSL certificates from router
echo -e "${YELLOW}[2/6]${NC} คัดลอก SSL certificates จาก router..."
echo ""
echo "เนื่องจากคุณมี SSL certificate อยู่แล้วบน router (58.136.234.96)"
echo "ให้คัดลอกมาใช้บนเครื่อง Mac นี้:"
echo ""
echo -e "${GREEN}# SSH เข้า router และหา certificate${NC}"
echo "ssh root@58.136.234.96"
echo "find /etc -name '*agents.ddns.net*' -o -name '*letsencrypt*'"
echo ""
echo -e "${GREEN}# คัดลอกมาที่เครื่อง Mac${NC}"
echo "scp root@58.136.234.96:/etc/letsencrypt/live/agents.ddns.net/fullchain.pem ./nginx/ssl/cert.pem"
echo "scp root@58.136.234.96:/etc/letsencrypt/live/agents.ddns.net/privkey.pem ./nginx/ssl/key.pem"
echo ""
echo -e "${YELLOW}หรือใช้ self-signed cert ชั่วคราว? (y/n)${NC}"
read -r USE_SELFSIGNED

if [[ $USE_SELFSIGNED == "y" ]]; then
    echo "กำลังสร้าง self-signed certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ./nginx/ssl/key.pem \
        -out ./nginx/ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=OpenClaw/CN=your-domain.com"
    chmod 600 ./nginx/ssl/key.pem
    chmod 644 ./nginx/ssl/cert.pem
    echo -e "${GREEN}✓${NC} Self-signed certificate created"
else
    echo -e "${YELLOW}⚠${NC}  กรุณาคัดลอก SSL certificates ก่อนดำเนินการต่อ"
    echo "กด Enter เมื่อพร้อม..."
    read
fi
echo ""

# Step 3: Test nginx config
echo -e "${YELLOW}[3/6]${NC} ทดสอบ nginx configuration..."
docker-compose run --rm nginx nginx -t || {
    echo -e "${RED}✗${NC} Nginx config error!"
    exit 1
}
echo -e "${GREEN}✓${NC} Nginx config OK"
echo ""

# Step 4: Start nginx docker
echo -e "${YELLOW}[4/6]${NC} เริ่มต้น nginx docker..."
docker-compose up -d
echo -e "${GREEN}✓${NC} Nginx started"
echo ""

# Step 5: Check status
echo -e "${YELLOW}[5/6]${NC} ตรวจสอบสถานะ..."
sleep 3
docker-compose ps
echo ""

# Test local access
if curl -f -s -k https://localhost/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Local HTTPS working (https://localhost/health)"
else
    echo -e "${YELLOW}⚠${NC}  Local HTTPS not working yet"
fi

if curl -f -s http://127.0.0.1:18789 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} OpenClaw Gateway running (http://127.0.0.1:18789)"
else
    echo -e "${RED}✗${NC} OpenClaw Gateway not running!"
fi
echo ""

# Step 6: Next steps
echo -e "${YELLOW}[6/6]${NC} ขั้นตอนถัดไป - ตั้งค่า Router Port Forwarding:"
echo ""
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Router Configuration Required${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""
echo "1️⃣  Uninstall nginx บน router (58.136.234.96):"
echo ""
echo "   SSH เข้า router:"
echo -e "   ${GREEN}ssh root@58.136.234.96${NC}"
echo ""
echo "   Uninstall nginx:"
echo -e "   ${GREEN}# สำหรับ Debian/Ubuntu${NC}"
echo "   systemctl stop nginx"
echo "   systemctl disable nginx"
echo "   apt remove nginx nginx-common"
echo ""
echo -e "   ${GREEN}# สำหรับ OpenWrt${NC}"
echo "   /etc/init.d/nginx stop"
echo "   /etc/init.d/nginx disable"
echo "   opkg remove nginx"
echo ""
echo "2️⃣  ตั้งค่า Port Forwarding บน router:"
echo ""
echo "   Forward ports จาก WAN ไปที่เครื่อง Mac:"
echo "   • Port 80 (HTTP)  → 192.168.1.152:80"
echo "   • Port 443 (HTTPS) → 192.168.1.152:443"
echo ""
echo "   วิธีตั้งค่า:"
echo "   - เข้า router web interface (ปกติ http://192.168.1.1)"
echo "   - หา NAT / Port Forwarding / Virtual Server"
echo "   - เพิ่ม rules ตามด้านบน"
echo ""
echo "3️⃣  ทดสอบจากภายนอก:"
echo ""
echo "   หลังตั้งค่า port forwarding เสร็จ ทดสอบด้วย:"
echo -e "   ${GREEN}curl https://agents.ddns.net/health${NC}"
echo ""
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}✅ Nginx Docker setup complete!${NC}"
echo ""
echo "Useful commands:"
echo "  docker-compose logs -f         # ดู logs"
echo "  docker-compose restart         # Restart"
echo "  docker-compose down            # Stop"
echo "  docker-compose up -d           # Start"
echo ""
