# OpenClaw DevOps

Full-stack OpenClaw DevOps platform with Next.js landing page, AI-powered gateway, admin portal, databases, messaging, and monitoring infrastructure.

**✨ New Features:**

- 🤖 **Multi-Provider LLM Chat** - OpenAI, Anthropic, Google AI, Moonshot support
- 💬 **AI Assistant** - Built-in chat interface with command & assistant modes
- 🔄 **Automatic Fallback** - Seamless provider switching on failures
- 📊 **Real-time Monitoring** - Prometheus & Grafana dashboards
- 🔐 **Secure by Default** - OAuth authentication, rate limiting, health checks

## ✅ Current Status

**Working Services:**

- ✅ Landing Page (http://localhost:3000)
- ✅ Assistant Portal (http://localhost:5555) - **NEW!**
- ✅ Gateway API (http://localhost:18789)
- ✅ MongoDB Database
- ✅ PostgreSQL Database
- ✅ Redis Cache
- ✅ Prometheus Monitoring
- ✅ cAdvisor Metrics

**AI/LLM Features:**

- ✅ OpenAI Integration (GPT-4o)
- ⚠️ Anthropic (no credits)
- ⚠️ Google AI (configuration needed)
- ⚠️ Moonshot (authentication issue)

**Health Score: 67%** (8/12 services operational)

## 🏗️ Architecture

```
Internet
    ↓
DNS
    ├─ your-domain.com → Landing Page (Next.js)
    ├─ openclaw.your-domain.com → Gateway (OpenClaw AI)
    └─ assistant.your-domain.com → Admin Portal (AI Chat)
    ↓
Nginx (Port 80/443) - Optional Reverse Proxy
    ├─ / → Landing (Port 3000)
    ├─ openclaw. → Gateway (Port 18789)
    └─ assistant. → Admin Portal (Port 5555)

Gateway (Port 18789)
    ├─ REST API (chat, health, docker)
    ├─ WebSocket Support
    ├─ LLM Service (Multi-Provider)
    │   ├─ OpenAI (Primary)
    │   ├─ Anthropic (Fallback)
    │   ├─ Google AI (Fallback)
    │   └─ Moonshot (Fallback)
    └─ Service Orchestration

Assistant Portal (Port 5555)
    ├─ Next.js 16 App Router
    ├─ Google OAuth Authentication
    ├─ AI Chat Interface (Command & Assistant modes)
    └─ Admin Dashboard

Databases
    ├─ MongoDB (Port 27017) - Document Store
    ├─ PostgreSQL (Port 5432) - Relational DB
    └─ Redis (Port 6379) - Cache & Sessions

Monitoring
    ├─ Prometheus (Port 9090) - Metrics Collection
    ├─ Grafana (Port 3001) - Dashboards (optional)
    └─ cAdvisor (Port 8080) - Container Metrics
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

### Prerequisites

- Docker & Docker Compose
- pnpm (for development mode)
- 8GB+ RAM recommended
- 10GB+ free disk space

### Option 1: Docker (Production Mode - Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/bemindlabs/OpenClaw-DevOps.git
cd OpenClaw-DevOps

# 2. Setup environment (creates .env from example)
cp .env.example .env

# 3. Add your API keys to .env
nano .env  # Add OPENAI_API_KEY, etc.

# 4. Start all services with make
make

# This will:
# - Build all Docker images
# - Start containers (gateway, databases, monitoring)
# - Verify health checks
# - Show service URLs

# 5. Access services
# Landing: http://localhost:3000
# Assistant: http://localhost:5555
# Gateway: http://localhost:18789
```

### Option 2: Development Mode (Hot Reload)

```bash
# 1. Install dependencies
pnpm install

# 2. Start services
pnpm dev:landing      # http://localhost:3000
pnpm dev:assistant    # http://localhost:5555
pnpm dev:gateway      # http://localhost:18789

# Or start all in one command
make dev
```

### Option 3: Quick Start Script

```bash
# Automated setup with interactive prompts
make

# Or use the traditional script
./start-all.sh
```

### Development Mode

```bash
# Start all apps in development mode (hot reload)
make dev

# Or individually:
make dev-landing      # Landing page (port 3000)
make dev-assistant    # Assistant portal (port 5555)
make dev-gateway      # Gateway service (port 18789)
```

### Production Deployment

```bash
# Setup environment
make security-setup

# Verify security
make security-verify

# Deploy
make build
make start

# Check status
make status
```

## 🛠️ Development

### Build Services

```bash
# Build landing page
cd apps/landing
docker build -t openclaw-landing:latest .

# Build gateway
cd apps/gateway
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
cd apps/gateway
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

## 🤖 AI/LLM Features

### Multi-Provider LLM Support

The gateway includes a sophisticated LLM service with automatic fallback support:

**Supported Providers:**

- ✅ **OpenAI** (GPT-4, GPT-4o, GPT-3.5) - Primary provider
- ✅ **Anthropic** (Claude 3.5 Sonnet, Claude 3 Opus)
- ✅ **Google AI** (Gemini Pro, Gemini Flash)
- ✅ **Moonshot/Kimi** (Chinese LLM with OpenAI-compatible API)

**Features:**

- **Automatic Fallback** - If primary provider fails, automatically tries alternative providers
- **Session Management** - Maintains conversation history per session (last 20 messages)
- **Provider Selection** - Configure primary and fallback providers via environment variables
- **Model Routing** - Route different tasks to different models (chat, completion, code, reasoning)

### Chat API

**Endpoint:** `POST http://localhost:18789/api/chat/message`

**Request:**

```json
{
  "message": "Your message here",
  "mode": "assistant",
  "sessionId": "optional-session-id"
}
```

**Response:**

```json
{
  "success": true,
  "response": "AI response here",
  "provider": "openai",
  "sessionId": "session-id",
  "id": "message-id",
  "timestamp": "2026-02-08T02:00:00.000Z"
}
```

**Example:**

```bash
curl -X POST http://localhost:18789/api/chat/message \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello, how can you help?","mode":"assistant"}'
```

### Assistant Portal

Access the AI-powered admin portal at **http://localhost:5555**

**Features:**

- 💬 Dual-mode chat interface (Command mode & Assistant mode)
- 🔐 Google OAuth authentication
- 📊 Real-time service monitoring
- 🎨 Modern dark theme UI with shadcn/ui components
- 🔄 Proxy to gateway for secure API access

### Configuration

Add your API keys to `.env`:

```bash
# OpenAI (Primary)
OPENAI_API_KEY=sk-proj-your-key-here

# Anthropic (Fallback)
ANTHROPIC_API_KEY=sk-ant-your-key-here

# Google AI (Fallback)
GOOGLE_AI_API_KEY=AIza-your-key-here

# Moonshot/Kimi (Optional)
MOONSHOT_API_KEY=sk-kimi-your-key-here

# Provider Configuration
LLM_PROVIDER=openai
LLM_FALLBACK_PROVIDERS=anthropic,google,moonshot
```

### Model Configuration

Route different tasks to optimal models:

```bash
LLM_CHAT_MODEL=openai/gpt-4o
LLM_COMPLETION_MODEL=anthropic/claude-3-5-sonnet-20241022
LLM_EMBEDDING_MODEL=openai/text-embedding-3-small
LLM_CODE_MODEL=openai/gpt-4o
LLM_REASONING_MODEL=anthropic/claude-3-5-sonnet-20241022
```

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

### Quick Health Check

```bash
# Check all core services
make health
```

### Manual Service Checks

```bash
# Core Services
curl http://localhost:3000                    # Landing (Next.js)
curl http://localhost:5555                    # Assistant Portal
curl http://localhost:18789/health | jq .    # Gateway Health

# Databases
docker exec openclaw-mongodb mongosh --quiet --eval "db.adminCommand('ping')"
docker exec openclaw-postgres pg_isready -U postgres_admin
docker exec openclaw-redis redis-cli -a "${REDIS_PASSWORD}" ping

# Monitoring
curl http://localhost:9090/-/healthy         # Prometheus
docker exec openclaw-cadvisor wget -qO- http://localhost:8080/healthz

# AI/LLM Chat
curl -X POST http://localhost:18789/api/chat/message \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello","mode":"assistant"}' | jq .
```

### Service Status Dashboard

```bash
# View all running containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check container health
docker ps --filter "health=healthy"

# View resource usage
docker stats --no-stream
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

### AI/LLM Chat Issues

#### "All LLM providers failed"

```bash
# 1. Check API keys are set in .env
grep "API_KEY" .env | grep -v "CHANGE_ME"

# 2. Check gateway logs for specific provider errors
docker-compose logs gateway | grep "LLM\|Error with provider"

# 3. Test individual providers
curl -X POST http://localhost:18789/api/chat/message \
  -H "Content-Type: application/json" \
  -d '{"message":"test","mode":"assistant"}' | jq .

# Common fixes:
# - OpenAI: Remove or empty OPENAI_ORG_ID if not using organization
# - Anthropic: Add credits to account (https://console.anthropic.com/settings/billing)
# - Google: Use correct model name (gemini-1.5-flash, not gemini-flash-latest)
# - Moonshot: Verify API key is valid
```

#### Assistant Portal Not Accessible (http://localhost:5555)

```bash
# 1. Check if container is running
docker ps | grep assistant

# 2. Verify port mapping
docker port openclaw-assistant

# 3. Restart with port mapping
docker-compose down assistant
docker-compose up -d assistant

# 4. Check logs
docker-compose logs assistant

# 5. Wait for health check (can take 40 seconds)
docker ps --filter "name=assistant"
```

#### "fetch failed" in Assistant

This usually means the assistant can't reach the gateway:

```bash
# 1. Verify gateway is accessible from assistant container
docker exec openclaw-assistant wget -qO- http://host.docker.internal:18789/health

# 2. If running in dev mode (not Docker), use localhost instead
# The route.ts auto-detects Docker vs host environment

# 3. Check GATEWAY_URL environment variable
docker exec openclaw-assistant printenv | grep GATEWAY
```

## 🔐 Security

**⚠️ IMPORTANT**: Before deploying to production, review and apply all security configurations.

### Quick Security Setup

```bash
# 1. Generate secure passwords and tokens
./scripts/generate-passwords.sh

# 2. Configure authentication and CORS
# Edit .env and set:
#   - GATEWAY_AUTH_TOKEN (auto-generated by script above)
#   - CORS_ORIGIN (your actual domains)
#   - ALLOWED_OAUTH_DOMAINS (your company domains)

# 3. Review security documentation
cat SECURITY.md
```

### Security Features

✅ **Authentication**: Bearer token authentication on Docker management API
✅ **Command Injection Protection**: Safe spawn-based command execution
✅ **OAuth Domain Whitelist**: Restrict admin portal access by email domain
✅ **CORS Restrictions**: Only allow trusted origins
✅ **Container Security**: Minimal capabilities, no privileged containers
✅ **Rate Limiting**: Nginx rate limiting on all endpoints

### Security Documentation

- **[SECURITY.md](SECURITY.md)** - Comprehensive security guide (authentication, configuration, monitoring)
- **[SECURITY-FIXES-SUMMARY.md](SECURITY-FIXES-SUMMARY.md)** - Security audit results and fixes applied
- **.env.example** - All required security configurations documented

### Security Checklist

- [ ] Run `./scripts/generate-passwords.sh` to generate secure credentials
- [ ] Configure `GATEWAY_AUTH_TOKEN` in .env (Bearer token for API access)
- [ ] Configure `CORS_ORIGIN` with your actual domains (no wildcards in production)
- [ ] Configure `ALLOWED_OAUTH_DOMAINS` with your company email domains
- [ ] Change all default passwords (done automatically by generate-passwords.sh)
- [ ] Use SSL certificates in production (place in `nginx/ssl/`)
- [ ] Configure firewall rules (only expose ports 80/443 publicly)
- [ ] Enable monitoring alerts for unauthorized access attempts
- [ ] Regular security updates for base images and dependencies
- [ ] Review access logs regularly: `docker-compose logs nginx | grep 401`

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

### Core Documentation

- **[API Reference](docs/API-REFERENCE.md)** - Complete Gateway API documentation
- **[Architecture Guide](docs/ARCHITECTURE.md)** - System architecture and diagrams
- **[Documentation Index](docs/README.md)** - Complete documentation directory

### Quick Guides

- **Developer Guide:** `CLAUDE.md` - AI developer instructions
- **Deployment Guide:** `DEPLOYMENT.md` - Production deployment
- **Services Overview:** `SERVICES.md` - All services reference
- **Contributing:** `CONTRIBUTING.md` - Contribution workflow
- **Onboarding:** `ONBOARDING.md` - Developer setup
- **Security:** `SECURITY.md` - Security best practices
- **Wiki:** `wiki/` directory - Additional resources

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
