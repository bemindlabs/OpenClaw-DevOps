# DNS Setup for openclaw.agents.ddns.net

## 🎯 Overview

ตั้งค่า subdomain `openclaw.agents.ddns.net` ให้ชี้มาที่เครื่อง Mac (192.168.1.152)

## 📋 DNS Configuration

### Option 1: DDNS Provider Web Interface

1. **เข้า DDNS Provider** (ตาม service ที่คุณใช้):
   - No-IP: https://www.noip.com
   - DynDNS: https://account.dyn.com
   - Duck DNS: https://www.duckdns.org
   - หรือ provider อื่นๆ

2. **เพิ่ม Subdomain Record:**
   ```
   Type:     A Record
   Name:     openclaw
   Domain:   agents.ddns.net
   Full:     openclaw.agents.ddns.net
   Value:    58.136.234.96 (Public IP)
   TTL:      300 (5 minutes)
   ```

3. **Save และรอ DNS Propagation** (~5-15 นาที)

### Option 2: DDNS Update API (Automated)

ถ้า DDNS provider รองรับ API สามารถใช้ command line:

#### No-IP Example:
```bash
curl "http://username:password@dynupdate.no-ip.com/nic/update?hostname=openclaw.agents.ddns.net&myip=58.136.234.96"
```

#### Duck DNS Example:
```bash
curl "https://www.duckdns.org/update?domains=openclaw.agents&token=YOUR_TOKEN&ip=58.136.234.96"
```

## ✅ Verify DNS Setup

### 1. ตรวจสอบ DNS Record
```bash
# ใช้ nslookup
nslookup openclaw.agents.ddns.net

# ควรได้:
# Name:   openclaw.agents.ddns.net
# Address: 58.136.234.96
```

```bash
# ใช้ dig
dig openclaw.agents.ddns.net +short

# ควรได้: 58.136.234.96
```

### 2. ทดสอบการเชื่อมต่อ
```bash
# Test ping
ping openclaw.agents.ddns.net

# Test HTTP (ก่อน setup nginx)
curl -I http://openclaw.agents.ddns.net

# Test HTTPS (หลัง setup nginx + SSL)
curl -I https://openclaw.agents.ddns.net
```

## 🔐 SSL Certificate Setup

หลังจาก DNS พร้อมแล้ว ขอ SSL certificate สำหรับ subdomain:

### Method 1: Certbot (Let's Encrypt)

```bash
# ติดตั้ง certbot (ถ้ายังไม่มี)
brew install certbot  # macOS
# หรือ
sudo apt install certbot  # Ubuntu/Debian

# ขอ certificate สำหรับ subdomain
sudo certbot certonly --standalone \
  -d openclaw.agents.ddns.net \
  --preferred-challenges http

# คัดลอก certificate
sudo cp /etc/letsencrypt/live/openclaw.agents.ddns.net/fullchain.pem \
  /Users/lps/server/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/openclaw.agents.ddns.net/privkey.pem \
  /Users/lps/server/nginx/ssl/key.pem
sudo chown $USER:$USER /Users/lps/server/nginx/ssl/*.pem
chmod 600 /Users/lps/server/nginx/ssl/key.pem
chmod 644 /Users/lps/server/nginx/ssl/cert.pem
```

### Method 2: Copy from Router (ถ้ามี wildcard cert)

ถ้า router มี wildcard certificate สำหรับ `*.agents.ddns.net`:

```bash
# คัดลอกจาก router
scp root@58.136.234.96:/etc/letsencrypt/live/agents.ddns.net/fullchain.pem \
  /Users/lps/server/nginx/ssl/cert.pem
scp root@58.136.234.96:/etc/letsencrypt/live/agents.ddns.net/privkey.pem \
  /Users/lps/server/nginx/ssl/key.pem

chmod 600 /Users/lps/server/nginx/ssl/key.pem
chmod 644 /Users/lps/server/nginx/ssl/cert.pem
```

### Method 3: Self-Signed (ทดสอบเท่านั้น)

```bash
cd /Users/lps/server/nginx

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem \
  -out ssl/cert.pem \
  -subj "/C=TH/ST=Bangkok/L=Bangkok/O=OpenClaw/CN=openclaw.agents.ddns.net"

chmod 600 ssl/key.pem
chmod 644 ssl/cert.pem
```

## 🔀 Router Port Forwarding

ตั้งค่า router (58.136.234.96) ให้ forward traffic มาที่เครื่อง Mac:

### Port Forwarding Rules:

| Service | Protocol | External Port | Internal IP | Internal Port |
|---------|----------|---------------|-------------|---------------|
| HTTP    | TCP      | 80            | 192.168.1.152 | 80          |
| HTTPS   | TCP      | 443           | 192.168.1.152 | 443         |

### วิธีตั้งค่า:

1. เข้า router admin panel: `http://192.168.1.1`
2. หา **NAT / Port Forwarding / Virtual Server**
3. เพิ่ม 2 rules ตามตารางด้านบน
4. Save และ apply

## 🧪 Testing Checklist

```bash
# 1. ตรวจสอบ DNS
nslookup openclaw.agents.ddns.net
# Expected: 58.136.234.96

# 2. ตรวจสอบ OpenClaw Gateway
curl http://127.0.0.1:18789
# Expected: HTML content

# 3. ตรวจสอบ Nginx (local)
docker compose -f /Users/lps/server/nginx/docker-compose.yml ps
# Expected: openclaw-nginx running

# 4. ทดสอบ HTTP (local)
curl -I http://localhost
# Expected: 301 Redirect to HTTPS

# 5. ทดสอบ HTTPS (local)
curl -I -k https://localhost/health
# Expected: 200 OK

# 6. ทดสอบ subdomain (external)
curl -I https://openclaw.agents.ddns.net/health
# Expected: 200 OK, "healthy"
```

## 📊 Network Flow

```
Internet
    ↓
DNS: openclaw.agents.ddns.net → 58.136.234.96
    ↓
Router (58.136.234.96)
    ├─ Port 80  → 192.168.1.152:80
    └─ Port 443 → 192.168.1.152:443
         ↓
    Mac (192.168.1.152)
         ├─ Nginx Docker (80, 443)
         │   └─ proxy_pass → 127.0.0.1:18789
         └─ OpenClaw Gateway ✅ (18789)
```

## 🚨 Troubleshooting

### DNS ไม่ทำงาน
```bash
# ล้าง DNS cache
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# ใช้ Google DNS ทดสอบ
nslookup openclaw.agents.ddns.net 8.8.8.8
```

### SSL Certificate Error
```bash
# ตรวจสอบ certificate
openssl x509 -in /Users/lps/server/nginx/ssl/cert.pem -text -noout

# ตรวจสอบ Common Name
openssl x509 -in /Users/lps/server/nginx/ssl/cert.pem -noout -subject

# ควรเห็น: CN=openclaw.agents.ddns.net
```

### Port Forwarding ไม่ทำงาน
```bash
# SSH เข้า router
ssh root@58.136.234.96

# ตรวจสอบ NAT rules (OpenWrt)
iptables -t nat -L -n -v | grep 192.168.1.152

# ตรวจสอบ port
netstat -an | grep LISTEN | grep -E ':80|:443'
```

## 📝 Summary

- [x] ตั้งค่า DNS record: `openclaw.agents.ddns.net → 58.136.234.96`
- [x] ขอ SSL certificate สำหรับ subdomain
- [x] ตั้งค่า nginx ใช้ `server_name openclaw.agents.ddns.net`
- [x] Setup port forwarding บน router
- [x] ทดสอบการเชื่อมต่อ

---
*Created: 2026-02-01*
*Subdomain: openclaw.agents.ddns.net*
*Gateway: 127.0.0.1:18789*
