# OpenClaw Nginx Docker

Nginx reverse proxy สำหรับ OpenClaw Gateway ที่ทำงานบน `127.0.0.1:18789`

## 🚀 Quick Start

```bash
cd /Users/lps/server/nginx

# Setup (ครั้งแรก)
./setup-nginx.sh

# Start
docker compose up -d

# View logs
docker compose logs -f

# Stop
docker compose down
```

## 📁 Structure

```
/Users/lps/server/nginx/
├── docker-compose.yml     # Docker config
├── nginx.conf             # Main nginx config
├── conf.d/
│   └── openclaw.conf      # OpenClaw proxy config
├── ssl/
│   ├── cert.pem           # SSL certificate
│   └── key.pem            # SSL private key
├── setup-nginx.sh         # Setup script
└── README.md              # This file
```

## 🔧 Configuration

- **Domain:** agents.ddns.net
- **Gateway:** 127.0.0.1:18789
- **Ports:** 80 (HTTP), 443 (HTTPS)
- **Network Mode:** host (เพื่อเข้าถึง localhost:18789)

## 📚 Documentation

- Full guide: `/Users/lps/.openclaw/workspace/OPENCLAW-NGINX.md`
- Router setup: `/Users/lps/.openclaw/workspace/ROUTER-SETUP.md`

## ⚙️ Next Steps

1. **Copy SSL certificates** from router
2. **Uninstall nginx** on router (58.136.234.96)
3. **Setup port forwarding** on router:
   - 80 → 192.168.1.152:80
   - 443 → 192.168.1.152:443

See workspace documentation for detailed instructions.

---
*Location: /Users/lps/server/nginx*
*Date: 2026-02-01*
