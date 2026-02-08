# OpenClaw DevOps Platform - Onboarding Guide

Welcome to OpenClaw! This guide will help you get started with the platform in under 10 minutes.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Detailed Setup](#detailed-setup)
4. [Configuration](#configuration)
5. [Accessing Services](#accessing-services)
6. [Common Operations](#common-operations)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **Docker** (v20.10+) - [Install Docker Desktop](https://www.docker.com/products/docker-desktop)
- **Docker Compose** (v2.0+) - Included with Docker Desktop
- **Git** - For cloning the repository
- **pnpm** (v9.0+) - Node.js package manager

### System Requirements

- **macOS/Linux/Windows** with WSL2
- **RAM**: 8GB minimum, 16GB recommended
- **Disk**: 20GB free space
- **CPU**: 4 cores recommended

### Check Your Setup

```bash
# Verify installations
docker --version          # Should show v20.10+
docker-compose --version  # Should show v2.0+
pnpm --version           # Should show v9.0+
git --version            # Any recent version
```

---

## Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd server
```

### 2. Initial Setup

```bash
# Install pnpm globally (if not already installed)
npm install -g pnpm@9

# Install dependencies
pnpm install

# Setup environment
cp .env.example .env
```

### 3. Start All Services

```bash
# Quick start - builds images and starts all services
./start-all.sh

# Or using make
make start
```

**That's it!** 🎉 OpenClaw is now running.

---

## Detailed Setup

### Step 1: Environment Configuration

Edit the `.env` file to configure your deployment:

```bash
# Edit environment variables
nano .env  # or your preferred editor
```

**Critical Variables to Update:**

```bash
# Domain Configuration
DOMAIN=your-domain.com
LANDING_DOMAIN=your-domain.com
GATEWAY_DOMAIN=openclaw.your-domain.com
ASSISTANT_DOMAIN=assistant.your-domain.com

# Authentication (REQUIRED for assistant portal)
AUTH_SECRET=<generate-with-openssl-rand-base64-32>
GOOGLE_CLIENT_ID=<from-google-cloud-console>
GOOGLE_CLIENT_SECRET=<from-google-cloud-console>
ALLOWED_OAUTH_DOMAINS=your-domain.com

# Gateway Authentication
GATEWAY_AUTH_TOKEN=<generate-with-openssl-rand-hex-32>

# Database Passwords (change from defaults!)
MONGO_INITDB_ROOT_PASSWORD=<secure-password>
POSTGRES_PASSWORD=<secure-password>
REDIS_PASSWORD=<secure-password>

# LLM Configuration (optional - add your API keys)
LLM_PROVIDER=openai  # or anthropic, google, etc.
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_AI_API_KEY=...
```

### Step 2: Generate Secure Passwords

```bash
# Auto-generate all passwords
./scripts/generate-passwords.sh

# Or manually generate individual secrets
openssl rand -base64 32  # For AUTH_SECRET
openssl rand -hex 32     # For GATEWAY_AUTH_TOKEN
```

### Step 3: Google OAuth Setup (for Assistant Portal)

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create a new OAuth 2.0 Client ID
3. Add authorized redirect URIs:
   - `http://localhost:5555/api/auth/callback/google` (development)
   - `https://assistant.your-domain.com/api/auth/callback/google` (production)
4. Copy Client ID and Secret to `.env`

### Step 4: Build Docker Images

```bash
# Build all images
./BUILD-IMAGES.sh

# Or build individually
docker build -t openclaw-landing:latest -f apps/landing/Dockerfile .
docker build -t openclaw-assistant:latest -f apps/assistant/Dockerfile .
docker build -t openclaw-gateway:latest -f apps/gateway/Dockerfile .
```

### Step 5: Start Services

Choose your stack:

**Basic Stack** (nginx + landing + assistant + gateway):
```bash
docker-compose up -d
```

**Full Stack** (all services + databases + monitoring):
```bash
docker-compose -f docker-compose.full.yml up -d
```

**Quick Start Script** (recommended):
```bash
./start-all.sh
```

---

## Configuration

### LLM API Keys

OpenClaw supports 15+ LLM providers. Add your API keys to `.env`:

```bash
# Primary Provider
LLM_PROVIDER=openai  # openai, anthropic, google, mistral, etc.

# API Keys (add the ones you want to use)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_AI_API_KEY=...
MISTRAL_API_KEY=...
GROQ_API_KEY=gsk_...
OPENROUTER_API_KEY=sk-or-...

# Model Selection by Task
LLM_CHAT_MODEL=openai/gpt-4o
LLM_CODE_MODEL=anthropic/claude-3-5-sonnet-20241022
LLM_REASONING_MODEL=openai/gpt-4o

# Fallback Chain
LLM_ENABLE_FALLBACK=true
LLM_FALLBACK_PROVIDERS=anthropic,google,mistral

# Rate Limiting & Cost Control
LLM_RATE_LIMIT_RPM=60
LLM_MONTHLY_BUDGET_USD=100
```

### Domain Configuration

For local development:
```bash
AUTH_URL=http://localhost:5555
NEXTAUTH_URL=http://localhost:5555
```

For production:
```bash
AUTH_URL=https://assistant.your-domain.com
NEXTAUTH_URL=https://assistant.your-domain.com
```

---

## Accessing Services

Once services are running, access them at:

| Service | URL | Description |
|---------|-----|-------------|
| **Landing Page** | http://localhost:3000 | Public landing page |
| **Assistant Portal** | http://localhost:5555 | Admin portal (requires OAuth) |
| **Gateway API** | http://localhost:18789 | REST API & WebSocket |
| **Prometheus** | http://localhost:9090 | Metrics collection |
| **Grafana** | http://localhost:3001 | Monitoring dashboards |
| **n8n** | http://localhost:5678 | Workflow automation |

### Login to Assistant Portal

1. Go to http://localhost:5555/login
2. Click "Sign in with Google"
3. Use an email from `ALLOWED_OAUTH_DOMAINS`
4. Access dashboard at http://localhost:5555/dashboard

---

## Common Operations

### Development Mode

Run apps with hot reload:

```bash
# Start all in dev mode
make dev

# Or individual apps
pnpm dev:landing    # Port 3000
pnpm dev:assistant  # Port 5555
pnpm dev:gateway    # Port 18789
```

### Docker Commands

```bash
# View logs
make logs              # All services
make logs-landing      # Landing only
docker-compose logs -f # Follow logs

# Restart services
make restart
docker-compose restart gateway

# Stop services
make stop
docker-compose down

# Clean up
docker-compose down -v  # Remove volumes too
```

### Health Checks

```bash
# Check all services
make health

# Individual health checks
curl http://localhost:3000          # Landing
curl http://localhost:5555          # Assistant
curl http://localhost:18789/health  # Gateway
```

### Rebuild After Code Changes

```bash
# Rebuild specific service
docker build -t openclaw-assistant:latest -f apps/assistant/Dockerfile .
docker-compose restart assistant

# Or rebuild all
./BUILD-IMAGES.sh
docker-compose up -d --force-recreate
```

---

## Troubleshooting

### Port Conflicts

```bash
# Check what's using a port
lsof -i :3000
lsof -i :5555
lsof -i :18789

# Kill process if needed
kill -9 <PID>
```

### Container Not Starting

```bash
# Check container logs
docker logs openclaw-gateway
docker logs openclaw-assistant

# Check container status
docker ps -a

# Restart container
docker-compose restart <service-name>
```

### Assistant 404 on /dashboard

Clear browser cache or use incognito mode:
```bash
# Hard refresh
Cmd+Shift+R (Mac)
Ctrl+Shift+R (Windows)
```

### Health Check Failures

Wait 60 seconds after starting containers - health checks have a start period:
```bash
docker ps  # Check status column
```

### Database Connection Issues

```bash
# Check database containers are healthy
docker ps | grep -E "mongodb|postgres|redis"

# Test connections
docker exec openclaw-mongodb mongosh --eval "db.adminCommand('ping')"
docker exec openclaw-postgres pg_isready
docker exec openclaw-redis redis-cli ping
```

### OAuth Login Issues

1. Verify `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` in `.env`
2. Check redirect URI in Google Cloud Console matches:
   - `http://localhost:5555/api/auth/callback/google`
3. Verify email domain in `ALLOWED_OAUTH_DOMAINS`
4. Check `AUTH_SECRET` is set and not default value

### Permission Denied (Docker)

```bash
# Make scripts executable
chmod +x start-all.sh BUILD-IMAGES.sh

# Fix Docker permissions (Linux)
sudo usermod -aG docker $USER
newgrp docker
```

---

## Next Steps

### 1. Configure LLM Integration

Add your preferred LLM API keys to `.env` and test:

```bash
# Test gateway with LLM
curl -X POST http://localhost:18789/api/chat/message \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, OpenClaw!"}'
```

### 2. Explore the Platform

- Browse the landing page: http://localhost:3000
- Login to assistant portal: http://localhost:5555
- Check service status: http://localhost:18789/api/services/status
- View metrics: http://localhost:9090

### 3. Customize Configuration

- Update domain settings for production
- Configure monitoring alerts in Prometheus
- Create custom Grafana dashboards
- Set up n8n workflows

### 4. Deploy to Production

See [DEPLOYMENT.md](./DEPLOYMENT.md) for production deployment guides:
- GCE deployment
- Custom domain setup
- SSL/TLS configuration
- Firewall rules

### 5. Development Workflow

- Read [CLAUDE.md](./CLAUDE.md) for architecture details
- Check [CONTRIBUTING.md](./CONTRIBUTING.md) for contribution guidelines
- Explore the monorepo structure in `apps/`

---

## Getting Help

- **Documentation**: Check `wiki/` directory
- **Issues**: Open an issue on GitHub
- **Community**: Join our Discord/Slack
- **Email**: support@openclaw.io

---

## Summary

**You're now onboarded! 🎉**

```bash
# Your platform is running at:
Landing:   http://localhost:3000
Assistant: http://localhost:5555/dashboard
Gateway:   http://localhost:18789/health

# Common commands:
make dev      # Development mode
make stop     # Stop all services
make restart  # Restart services
make logs     # View logs
make health   # Health check
```

Welcome to the OpenClaw community! 🚀

---

*Last Updated: 2026-02-07*
*Version: 1.0.0*
