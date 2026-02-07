---
title: Quick Start Guide
tags: [setup, quickstart, guide]
created: 2026-02-07
related: [[Installation]], [[Configuration]], [[First Deployment]]
---

# Quick Start Guide

Get OpenClaw DevOps up and running in minutes.

## Prerequisites

- Docker & Docker Compose installed
- 8GB+ RAM available
- 50GB+ disk space
- macOS or Linux

## 1. Clone Repository

```bash
cd /Users/lps/server
```

## 2. Configure Environment

### Generate Passwords
```bash
./scripts/generate-passwords.sh
```

This generates secure passwords for:
- MongoDB
- PostgreSQL
- Redis
- n8n
- Grafana
- OpenClaw Gateway

### Create .env File
```bash
cp .env.example .env
nano .env
```

Copy the generated passwords into your `.env` file.

**Required Variables:**
- `MONGO_INITDB_ROOT_PASSWORD`
- `POSTGRES_PASSWORD`
- `REDIS_PASSWORD`
- `N8N_BASIC_AUTH_PASSWORD`
- `GF_SECURITY_ADMIN_PASSWORD`
- `GATEWAY_AUTH_TOKEN`

## 3. Build Images

```bash
./BUILD-IMAGES.sh
```

This builds:
- `openclaw-landing:latest`
- `openclaw-gateway:latest`

## 4. Start Services

### Basic Stack (Nginx + Landing + Gateway)
```bash
./start-all.sh
```

### Full Stack (All Services)
```bash
./scripts/start-full-stack.sh
```

## 5. Verify Services

### Check Status
```bash
docker-compose -f docker-compose.full.yml ps
```

### Test Endpoints
```bash
# Landing page
curl http://localhost:3000

# OpenClaw Gateway
curl http://localhost:18789/health

# Nginx
curl http://localhost/health

# Grafana
curl http://localhost:3001/api/health

# Prometheus
curl http://localhost:9090/-/healthy
```

### Web Access
```bash
# Open in browser
open http://localhost:3000        # Landing
open http://localhost:18789       # Gateway
open http://localhost:3001        # Grafana
open http://localhost:5678        # n8n
open http://localhost:9090        # Prometheus
```

## 6. Login Credentials

### Grafana
- URL: http://localhost:3001
- Username: `$GF_SECURITY_ADMIN_USER` (from .env)
- Password: `$GF_SECURITY_ADMIN_PASSWORD` (from .env)

### n8n
- URL: http://localhost:5678
- Username: `$N8N_BASIC_AUTH_USER` (from .env)
- Password: `$N8N_BASIC_AUTH_PASSWORD` (from .env)

### Database Access
See [[Database Connection]] for connection strings.

## 7. View Logs

```bash
# All services
docker-compose -f docker-compose.full.yml logs -f

# Specific service
docker-compose -f docker-compose.full.yml logs -f landing
docker-compose -f docker-compose.full.yml logs -f gateway
docker-compose -f docker-compose.full.yml logs -f mongodb
```

## Next Steps

- [[Configuration|Configure services]]
- [[Monitoring Setup|guides/Monitoring-Setup|Set up monitoring]]
- [[SSL Setup|guides/SSL-Setup|Configure SSL]]
- [[GCE Deployment|Deploy to GCE]]

## Troubleshooting

Having issues? Check:
- [[Common Issues|troubleshooting/Common-Issues]]
- [[Port Conflicts|troubleshooting/Port-Conflicts]]
- [[Container Problems|troubleshooting/Container-Problems]]

---

**See Also:** [[Installation]], [[First Deployment]], [[Service Management]]

#quickstart #setup #guide
