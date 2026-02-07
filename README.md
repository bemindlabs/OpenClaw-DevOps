# OpenClaw DevOps

Full-stack OpenClaw DevOps platform with Next.js landing page, Nginx reverse proxy, AI gateway, databases, messaging, and monitoring infrastructure.

## 🏗️ Architecture

```
Internet
    ↓
DNS
    ├─ your-domain.com → Landing Page (Next.js)
    ├─ openclaw.your-domain.com → Gateway (OpenClaw)
    └─ assistant.your-domain.com → Admin Portal
    ↓
Nginx (Port 80/443)
    ├─ / → Landing (Port 3000)
    ├─ openclaw. → Gateway (Port 18789)
    └─ assistant. → Admin Portal (Port 5555)
```

## 📁 Project Structure

```
./
├── apps/
│   ├── landing/              # Next.js landing page
│   ├── assistant/            # Admin portal (Next.js)
│   └── openclaw-gateway/     # Express.js API gateway
├── nginx/
│   ├── nginx.conf            # Main nginx config
│   ├── conf.d/
│   │   ├── landing.conf      # Landing proxy (your-domain.com)
│   │   ├── openclaw.conf     # Gateway proxy (openclaw.your-domain.com)
│   │   └── assistant.conf    # Assistant proxy (assistant.your-domain.com)
│   └── ssl/                  # SSL certificates
├── monitoring/
│   ├── prometheus/           # Metrics collection
│   └── grafana/              # Dashboards
├── deployments/
│   ├── gce/                  # GCE deployment scripts
│   └── local/                # Local dev configs
├── docker-compose.yml        # Basic stack (nginx + landing + gateway)
├── docker-compose.full.yml   # Full stack (all services)
└── start-all.sh              # Quick start script
```

## 🚀 Quick Start

### Start Basic Stack

```bash
cd .
./start-all.sh

# Or manually
docker-compose up -d
```

### Start Full Stack

```bash
# Setup environment
cp .env.example .env
./scripts/generate-passwords.sh

# Start all services (databases, monitoring, etc.)
docker-compose -f docker-compose.full.yml up -d
```

## 🛠️ Development

### Build Services

```bash
# Build landing page
cd apps/landing
docker build -t openclaw-landing:latest .

# Build gateway
cd apps/openclaw-gateway
docker build -t openclaw-gateway:latest .

# Build assistant portal
cd apps/assistant
docker build -t openclaw-assistant:latest .
```

### Development Mode (Hot Reload)

```bash
# Landing page
cd apps/landing
npm run dev
# Visit http://localhost:3000

# Gateway
cd apps/openclaw-gateway
npm run dev
# API: http://localhost:18789

# Assistant portal
cd apps/assistant
npm run dev
# Portal: http://localhost:5555
```

## 🌐 Services

### Basic Stack

| Domain                    | Service   | Port  | Description          |
| ------------------------- | --------- | ----- | -------------------- |
| your-domain.com           | Landing   | 3000  | Next.js landing page |
| openclaw.your-domain.com  | Gateway   | 18789 | AI gateway service   |
| assistant.your-domain.com | Assistant | 5555  | Admin portal         |

### Full Stack (docker-compose.full.yml)

**Databases:**

- MongoDB (27017) - Document database
- PostgreSQL (5432) - Relational database
- Redis (6379) - Cache & session store

**Messaging:**

- Kafka (9092) - Event streaming
- Zookeeper (2181) - Kafka coordination
- n8n (5678) - Workflow automation

**Monitoring:**

- Prometheus (9090) - Metrics collection
- Grafana (3001) - Dashboards
- Exporters - Node, cAdvisor, Redis, PostgreSQL, MongoDB

## 🐋 Docker Commands

```bash
# View running containers
docker-compose ps
docker-compose -f docker-compose.full.yml ps

# View logs
docker-compose logs -f
docker-compose logs -f landing
docker-compose logs -f nginx

# Restart services
docker-compose restart
docker-compose restart landing

# Stop all
docker-compose down

# Rebuild and restart
cd apps/landing && docker build -t openclaw-landing:latest . && cd ../..
docker-compose up -d landing

# Clean up
docker-compose down -v
docker image prune -a
```

## 📊 Health Checks

```bash
# Basic services
curl http://localhost/health        # Nginx
curl http://localhost:3000          # Landing
curl http://localhost:18789         # Gateway

# Full stack
curl http://localhost:9090/-/healthy # Prometheus
curl http://localhost:3001/api/health # Grafana
```

## 📝 Configuration

### Nginx

**Main Config:** `nginx/nginx.conf`
**Site Configs:** `nginx/conf.d/*.conf`

Each site config includes:

- Rate limiting
- WebSocket support
- Health check endpoint
- Proper proxy headers

### Environment Variables

Create `.env` from template:

```bash
cp .env.example .env
./scripts/generate-passwords.sh
```

Critical variables:

- Database passwords
- Google OAuth credentials
- NextAuth secret
- Service ports

### SSL Certificates

For production, place certificates in `nginx/ssl/`:

- `cert.pem` - Certificate
- `key.pem` - Private key

## 🔧 Common Operations

### Update a Service

1. Make changes in `apps/<service>/`
2. Rebuild:
   ```bash
   cd apps/<service>
   docker build -t openclaw-<service>:latest .
   ```
3. Restart:
   ```bash
   docker-compose restart <service>
   ```

### Update Nginx Configuration

1. Edit `nginx/nginx.conf` or `nginx/conf.d/*.conf`
2. Test config:
   ```bash
   docker-compose exec nginx nginx -t
   ```
3. Reload:
   ```bash
   docker-compose exec nginx nginx -s reload
   ```

### Database Access

```bash
# MongoDB
docker-compose -f docker-compose.full.yml exec mongodb \
  mongosh -u admin -p <password>

# PostgreSQL
docker-compose -f docker-compose.full.yml exec postgres \
  psql -U postgres_admin -d openclaw

# Redis
docker-compose -f docker-compose.full.yml exec redis \
  redis-cli -a <password>
```

## 🚨 Troubleshooting

### Service Not Accessible

```bash
# 1. Check container status
docker-compose ps

# 2. Check logs
docker-compose logs <service>

# 3. Check port binding
docker ps --format "table {{.Names}}\t{{.Ports}}"

# 4. Test direct access
curl http://localhost:<port>
```

### Nginx 502 Error

```bash
# Check upstream services
curl http://localhost:3000   # Landing
curl http://localhost:18789  # Gateway

# Verify nginx config
docker-compose exec nginx nginx -t

# Check nginx logs
docker-compose logs nginx
```

### Port Conflicts

```bash
# Check what's using a port
lsof -i :80
lsof -i :3000
lsof -i :18789

# Kill process if needed
kill -9 <PID>
```

### Health Check Failures

Health checks have a 40-second start period. If showing "unhealthy":

1. Wait 40-60 seconds after container start
2. Check logs: `docker-compose logs <service>`
3. Test health check manually:
   ```bash
   docker exec <container> wget --quiet --tries=1 --spider http://localhost:<port>
   ```

## 🔐 Security

- Change all default passwords in `.env`
- Use SSL certificates in production
- Configure firewall rules
- Regular security updates
- Monitor access logs
- Implement rate limiting (already configured in Nginx)

## 📦 Production Deployment

### Quick Deploy (GCE)

```bash
cd deployments/gce
./deploy.sh
```

### First Time Setup

```bash
# 1. Setup Docker on instance
./deployments/gce/quick-setup.sh

# 2. Deploy with build
./deployments/gce/deploy.sh --setup --build

# 3. Configure DNS
# Point domains to server IP:
#   - agents.ddns.net
#   - openclaw.agents.ddns.net
#   - assistant.agents.ddns.net

# 4. Setup SSL
# Copy certificates to nginx/ssl/

# 5. Verify deployment
curl http://agents.ddns.net
curl http://openclaw.agents.ddns.net/health
```

### Management Scripts

Located in `deployments/gce/scripts/`:

- `start.sh [service]` - Start services
- `stop.sh [service]` - Stop services
- `restart.sh [service]` - Restart services
- `logs.sh [service] [-f]` - View logs
- `status.sh` - Check health

## 📚 Documentation

- **Developer Guide:** `CLAUDE.md`
- **Deployment Guide:** `DEPLOYMENT.md`
- **Services Overview:** `SERVICES.md`
- **Contributing:** `CONTRIBUTING.md`
- **Wiki:** `wiki/` directory

## 🏛️ Architecture Notes

### Docker Networking

**Current Setup (macOS/Windows):**

- Bridge networking with port mappings
- Services communicate via Docker service names
- Compatible with Docker Desktop

**Linux Production:**

- Can use host networking for better performance
- Direct host network access
- See `CLAUDE.md` for configuration details

### Technology Stack

- **Frontend:** Next.js 16, React 19, Tailwind CSS 4
- **Gateway:** Express.js, Node.js
- **Proxy:** Nginx with rate limiting
- **Databases:** MongoDB, PostgreSQL, Redis
- **Messaging:** Kafka, Zookeeper
- **Monitoring:** Prometheus, Grafana
- **Deployment:** Docker, Docker Compose

---

**Project:** OpenClaw DevOps
**Location:** `.`
**Updated:** 2026-02-07

For detailed technical documentation, see `CLAUDE.md`.
