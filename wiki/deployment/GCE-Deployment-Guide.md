# GCE Deployment Guide

Complete guide for deploying OpenClaw DevOps to Google Compute Engine.

## Overview

This guide covers deploying the full OpenClaw DevOps stack to a GCE instance using the automated deployment script.

**Last Updated:** 2026-02-08
**Instance:** bmt-staging-research
**Region:** asia-southeast1-a
**External IP:** 34.158.49.120

## Prerequisites

### 1. GCP Setup

- **GCP Project:** bemind-technology
- **Active GCE Instance:** bmt-staging-research
- **Authentication:** `gcloud auth login`
- **Firewall Rules:** Ports 80, 443 open (http-server, https-server tags)

### 2. Local Requirements

```bash
# Install gcloud CLI
brew install google-cloud-sdk  # macOS
# or visit: https://cloud.google.com/sdk/docs/install

# Authenticate
gcloud auth login
gcloud config set project bemind-technology
```

### 3. Domain Configuration

Update DNS records to point to instance IP:
- `devops-agents.bemind.tech` → 34.158.49.120
- `openclaw-agents.bemind.tech` → 34.158.49.120

## Automated Deployment

### Quick Deploy

```bash
cd /Users/lps/server/deployments/gce
./DEPLOY-NOW.sh
```

### Deployment Steps (Automated)

The script handles all 10 steps:

1. ✅ **Prerequisites Check** - Verify gcloud CLI and authentication
2. ✅ **Instance Verification** - Check instance status and get external IP
3. ✅ **Local Build** - Build Docker images locally (landing, assistant, gateway)
4. ✅ **Package Creation** - Create tar.gz with all necessary files
5. ✅ **Upload** - Transfer package to GCE instance
6. ✅ **Instance Setup** - Install Docker & Docker Compose if needed
7. ✅ **Environment Config** - Upload .env file or create from example
8. ✅ **Remote Build** - Build images on the instance
9. ✅ **Service Deployment** - Start all services with docker-compose
10. ✅ **Verification** - Check container status

### What Gets Deployed

**Services:**
- **Landing Page** (Next.js) - Port 3000
- **Gateway** (Express.js) - Port 18789
- **Assistant Portal** (Next.js) - Port 5555
- **Nginx** (Reverse Proxy) - Ports 80/443

**Infrastructure:**
- Docker containers with health checks
- Nginx with domain-based routing
- Persistent volumes for logs
- Network isolation with Docker bridge

## Configuration

### Environment Variables

Required in `/home/info_bemind_tech/openclaw/.env`:

```bash
# Node Environment
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1

# Service Ports
LANDING_PORT=3000
GATEWAY_PORT=18789
ASSISTANT_PORT=5555

# Domains
LANDING_DOMAIN=devops-agents.bemind.tech
GATEWAY_DOMAIN=openclaw-agents.bemind.tech

# Authentication (Assistant Portal)
NEXTAUTH_URL=https://assistant.devops-agents.bemind.tech
NEXTAUTH_SECRET=<generate-random-secret-32chars>
GOOGLE_CLIENT_ID=<your-oauth-client-id>
GOOGLE_CLIENT_SECRET=<your-oauth-client-secret>
ALLOWED_OAUTH_DOMAINS=bemind.tech

# LLM API Keys (Gateway)
OPENAI_API_KEY=<your-openai-key>
ANTHROPIC_API_KEY=<your-anthropic-key>
GOOGLE_AI_API_KEY=<your-google-ai-key>
MOONSHOT_API_KEY=<your-moonshot-key>

# Database Connections (if using full stack)
MONGODB_URI=mongodb://admin:password@localhost:27017/openclaw
POSTGRES_URI=postgresql://user:password@localhost:5432/openclaw
REDIS_URL=redis://:password@localhost:6379
```

### Nginx Configuration

Domain routing configured in `/home/info_bemind_tech/openclaw/nginx/conf.d/`:

- **default.conf** - Health checks and catch-all redirect
- **landing.conf** - Landing page routing
- **openclaw.conf** - Gateway API routing
- **assistant.conf** - Assistant portal routing

## Post-Deployment

### 1. Update Environment Variables

```bash
# SSH to instance
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology

# Edit environment file
cd /home/info_bemind_tech/openclaw
nano .env

# Restart services to apply changes
docker-compose restart
```

### 2. Configure SSL Certificates

#### Option A: Let's Encrypt (Recommended)

```bash
# Install certbot on instance
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Generate certificates
sudo certbot --nginx \
  -d devops-agents.bemind.tech \
  -d openclaw-agents.bemind.tech

# Auto-renewal is configured automatically
```

#### Option B: Manual Certificates

```bash
# Copy certificates to instance
gcloud compute scp \
  ./ssl/fullchain.pem \
  ./ssl/privkey.pem \
  bmt-staging-research:/home/info_bemind_tech/openclaw/nginx/ssl/ \
  --zone=asia-southeast1-a

# Update nginx configs to use SSL
# Then restart: docker-compose restart nginx
```

### 3. Verify Deployment

```bash
# Check all containers
docker-compose ps

# Expected output:
# openclaw-landing    - Up (healthy)
# openclaw-gateway    - Up (healthy)
# openclaw-assistant  - Up (healthy)
# openclaw-nginx      - Up (healthy)

# Test endpoints
curl http://34.158.49.120/health
curl http://34.158.49.120:3000
curl http://34.158.49.120:18789/health
curl http://34.158.49.120:5555
```

### 4. Monitor Services

```bash
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f landing
docker-compose logs -f gateway
docker-compose logs -f assistant

# Check resource usage
docker stats
```

## Troubleshooting

### Assistant Shows Unhealthy

**Symptom:** `openclaw-assistant` container status is "unhealthy"

**Cause:** Missing NEXTAUTH_URL or NEXTAUTH_SECRET environment variables

**Fix:**
```bash
cd /home/info_bemind_tech/openclaw
echo "NEXTAUTH_URL=https://assistant.devops-agents.bemind.tech" >> .env
echo "NEXTAUTH_SECRET=$(openssl rand -hex 32)" >> .env
docker-compose restart assistant
```

### Nginx Returns 502 Bad Gateway

**Symptom:** Nginx accessible but returns 502 error

**Cause:** Backend service not running or not healthy

**Fix:**
```bash
# Check which service is down
docker-compose ps

# View logs of problematic service
docker-compose logs [service-name]

# Restart the service
docker-compose restart [service-name]
```

### Domain Redirects to Old Domain

**Symptom:** Accessing IP redirects to `agents.ddns.net`

**Cause:** Old domain in nginx default.conf

**Fix:**
```bash
cd /home/info_bemind_tech/openclaw
sed -i 's/agents.ddns.net/devops-agents.bemind.tech/g' nginx/conf.d/default.conf
docker-compose exec nginx nginx -s reload
```

### Cannot Connect to Instance

**Symptom:** SSH or HTTP requests timeout

**Cause:** Firewall rules not configured

**Fix:**
```bash
# Check instance tags
gcloud compute instances describe bmt-staging-research \
  --zone=asia-southeast1-a \
  --format="get(tags.items)"

# Should include: http-server, https-server

# Add tags if missing
gcloud compute instances add-tags bmt-staging-research \
  --zone=asia-southeast1-a \
  --tags=http-server,https-server
```

## Management Commands

### Service Control

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart [service]

# View status
docker-compose ps

# Scale service (not applicable with host networking)
docker-compose up -d --scale landing=2
```

### Updates and Redeployment

```bash
# Quick redeploy (from local machine)
cd /Users/lps/server/deployments/gce
./DEPLOY-NOW.sh

# Manual update on instance
cd /home/info_bemind_tech/openclaw
git pull  # if using git
docker-compose build
docker-compose up -d
```

### Cleanup

```bash
# Stop and remove containers
docker-compose down

# Remove all volumes (WARNING: deletes data)
docker-compose down -v

# Clean up images
docker image prune -a

# Full cleanup
docker system prune -a --volumes
```

## Security Considerations

### 1. Environment Variables

- ✅ Never commit `.env` files to git
- ✅ Use strong random secrets for NEXTAUTH_SECRET
- ✅ Rotate API keys regularly
- ✅ Limit ALLOWED_OAUTH_DOMAINS to your organization

### 2. Firewall Rules

- ✅ Ports 80/443 open for HTTP/HTTPS
- ✅ Port 22 open for SSH (restrict to known IPs in production)
- ❌ Do NOT expose database ports (27017, 5432, 6379) externally

### 3. SSL/TLS

- ✅ Always use HTTPS in production
- ✅ Enforce HSTS headers
- ✅ Use strong cipher suites
- ✅ Enable automatic certificate renewal

### 4. Container Security

- ✅ Run containers as non-root users
- ✅ Use minimal base images (alpine)
- ✅ Regular security updates
- ✅ Scan images for vulnerabilities

## Monitoring

### Health Checks

All services have built-in health checks:

```yaml
healthcheck:
  test: ['CMD', 'wget', '--quiet', '--tries=1', '--spider', 'http://localhost:3000']
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Metrics

Consider adding Prometheus + Grafana for production:

```bash
# Use full stack deployment
docker-compose -f docker-compose.full.yml up -d

# Access Grafana: http://34.158.49.120:3001
# Access Prometheus: http://34.158.49.120:9090
```

## Cost Optimization

### Instance Sizing

Current instance: `e2-medium` (2 vCPUs, 4GB RAM)

**Recommendations:**
- Development: `e2-small` (2 vCPUs, 2GB RAM) - ~$25/month
- Staging: `e2-medium` (2 vCPUs, 4GB RAM) - ~$50/month
- Production: `e2-standard-2` (2 vCPUs, 8GB RAM) - ~$75/month

### Cost Reduction Tips

1. Use preemptible instances for dev/test (60-91% discount)
2. Set up auto-shutdown for non-production instances
3. Use committed use discounts for production
4. Monitor with GCP Cost Management tools

## Backup and Recovery

### Configuration Backup

```bash
# Backup environment file
gcloud compute scp \
  bmt-staging-research:/home/info_bemind_tech/openclaw/.env \
  ./backups/.env.$(date +%Y%m%d) \
  --zone=asia-southeast1-a

# Backup nginx configs
gcloud compute scp --recurse \
  bmt-staging-research:/home/info_bemind_tech/openclaw/nginx/conf.d \
  ./backups/nginx/ \
  --zone=asia-southeast1-a
```

### Data Backup (Full Stack)

```bash
# MongoDB
docker-compose exec mongodb mongodump --out=/backup
docker cp openclaw-mongodb:/backup ./mongodb-backup-$(date +%Y%m%d)

# PostgreSQL
docker-compose exec postgres pg_dump -U postgres_admin openclaw > postgres-backup-$(date +%Y%m%d).sql

# Redis
docker-compose exec redis redis-cli --rdb /data/dump.rdb
```

## Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [GCP Compute Engine](https://cloud.google.com/compute/docs)
- [Nginx Configuration](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/docs/)

## Support

For issues or questions:
- GitHub Issues: https://github.com/bemindlabs/OpenClaw-DevOps/issues
- Documentation: `/Users/lps/server/DEPLOYMENT.md`
- Wiki: `/Users/lps/server/wiki/`

---

**Last Deployment:** 2026-02-08 13:28 UTC
**Deployed By:** Claude Sonnet 4.5
**Status:** ✅ All Services Running
