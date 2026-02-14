#!/bin/bash
# Get Let's Encrypt SSL Certificate for openclaw.your-domain.com

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="openclaw.your-domain.com"
EMAIL="${1:-admin@your-domain.com}"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Let's Encrypt SSL Setup                  ║${NC}"
echo -e "${BLUE}║  Domain: $DOMAIN      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check certbot
if ! command -v certbot &> /dev/null; then
    echo -e "${RED}✗${NC} certbot not found!"
    echo ""
    echo "Install certbot:"
    echo "  macOS:  brew install certbot"
    echo "  Ubuntu: sudo apt install certbot"
    exit 1
fi

echo -e "${YELLOW}[1/4]${NC} ตรวจสอบ DNS..."
DNS_IP=$(dig +short $DOMAIN | tail -1)
if [ -z "$DNS_IP" ]; then
    echo -e "${RED}✗${NC} DNS not configured for $DOMAIN"
    echo ""
    echo "Please setup DNS first:"
    echo "  Type: A Record"
    echo "  Name: openclaw"
    echo "  Value: YOUR_PUBLIC_IP"
    exit 1
fi
echo -e "${GREEN}✓${NC} DNS: $DOMAIN → $DNS_IP"
echo ""

echo -e "${YELLOW}[2/4]${NC} หยุด nginx ชั่วคราว (certbot ต้องใช้ port 80)..."
docker compose down
sleep 2
echo -e "${GREEN}✓${NC} Nginx stopped"
echo ""

echo -e "${YELLOW}[3/4]${NC} ขอ SSL certificate จาก Let's Encrypt..."
echo "Email: $EMAIL"
echo "Domain: $DOMAIN"
echo ""

sudo certbot certonly --standalone \
    -d "$DOMAIN" \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --preferred-challenges http

echo -e "${GREEN}✓${NC} Certificate obtained"
echo ""

echo -e "${YELLOW}[4/4]${NC} คัดลอก certificate..."
sudo cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ssl/cert.pem
sudo cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" ssl/key.pem
sudo chown $USER:$USER ssl/*.pem
chmod 600 ssl/key.pem
chmod 644 ssl/cert.pem
echo -e "${GREEN}✓${NC} Certificates copied"
echo ""

echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ SSL Certificate installed!${NC}"
echo ""
echo "Certificate details:"
openssl x509 -in ssl/cert.pem -noout -subject -issuer -dates
echo ""

echo "Starting nginx..."
docker compose up -d
sleep 3
echo ""

echo -e "${GREEN}✓${NC} Nginx started with SSL"
echo ""
echo "Test:"
echo "  curl https://$DOMAIN/health"
echo ""

# Auto-renewal reminder
echo -e "${YELLOW}💡 Tip:${NC} Setup auto-renewal cron job:"
echo "  sudo crontab -e"
echo ""
echo "  Add this line:"
echo "  0 3 * * * certbot renew --quiet --deploy-hook 'cd /Users/lps/server/nginx && ./get-letsencrypt.sh'"
echo ""
