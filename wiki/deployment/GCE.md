---
title: GCE Deployment
tags: [deployment, gce, production, google-cloud]
created: 2026-02-07
related: [[Local Development]], [[Production Checklist]], [[CI/CD Pipeline]]
---

# GCE Deployment

Deploy OpenClaw DevOps to Google Compute Engine.

## Instance Details

- **Project:** bemind-technology
- **Instance:** bmt-staging-research
- **Zone:** asia-southeast1-a
- **Region:** asia-southeast1

## Prerequisites

### Local Machine
- gcloud CLI installed
- Authenticated with GCP
- SSH access to instance

```bash
# Verify authentication
gcloud auth list

# Set project
gcloud config set project bemind-technology
```

### GCE Instance
- Ubuntu/Debian OS
- 4+ CPU cores
- 8+ GB RAM
- 50+ GB disk

## Initial Setup

### 1. Setup Docker on Instance

```bash
cd $(pwd)/deployments/gce
./quick-setup.sh
```

This installs:
- Docker Engine
- Docker Compose
- Required dependencies
- Configures firewall

**What it does:**
- Updates system packages
- Installs Docker from official repository
- Installs Docker Compose standalone
- Adds user to docker group
- Configures Docker daemon
- Opens required ports (22, 80, 443, 3000, 18789)

### 2. Configure Secrets

**Update GCE config:**
```bash
cd deployments/gce

# Edit OpenClaw Gateway config
nano config/openclaw-gateway.json

# Update these values:
# - channels.telegram.botToken
# - gateway.auth.token
```

**Generate secure tokens:**
```bash
# Generate gateway auth token
openssl rand -hex 32

# Copy to config file
```

### 3. Deploy Application

```bash
./deploy.sh --build
```

**Flags:**
- `--build` - Build images locally before deploying
- `--setup` - Run instance setup (first time only)

**Deployment Steps:**
1. Checks GCP authentication
2. Verifies instance exists
3. Builds images locally (if --build)
4. Runs setup on instance (if --setup)
5. Syncs project files to instance
6. Builds images on instance
7. Starts all services

## Management Commands

### Start Services

```bash
cd deployments/gce

# Start all services
./scripts/start.sh

# Start specific service
./scripts/start.sh landing
```

### Stop Services

```bash
# Stop all services
./scripts/stop.sh

# Stop specific service
./scripts/stop.sh gateway
```

### Restart Services

```bash
# Restart all
./scripts/restart.sh

# Restart specific
./scripts/restart.sh mongodb
```

### View Logs

```bash
# All services
./scripts/logs.sh -f

# Specific service
./scripts/logs.sh landing -f

# Without following
./scripts/logs.sh gateway
```

### Check Status

```bash
# Container status + health checks
./scripts/status.sh
```

## Direct SSH Access

### Connect to Instance

```bash
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology
```

### Run Commands

```bash
# Check containers
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --command="cd /home/lps/server && docker-compose ps"

# View logs
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --command="cd /home/lps/server && docker-compose logs -f landing"
```

### Copy Files

```bash
# Copy TO instance
gcloud compute scp local-file.txt bmt-staging-research:~/remote-file.txt \
  --zone=asia-southeast1-a \
  --project=bemind-technology

# Copy FROM instance
gcloud compute scp bmt-staging-research:~/remote-file.txt ./local-file.txt \
  --zone=asia-southeast1-a \
  --project=bemind-technology

# Copy directory
gcloud compute scp --recurse ./local-dir/ bmt-staging-research:~/remote-dir/ \
  --zone=asia-southeast1-a \
  --project=bemind-technology
```

## Network Configuration

### External IP

```bash
# Get external IP
gcloud compute instances describe bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

### Firewall Rules

```bash
# List rules
gcloud compute firewall-rules list --project=bemind-technology

# Create HTTP rule
gcloud compute firewall-rules create allow-http \
  --project=bemind-technology \
  --allow=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --description="Allow HTTP traffic"

# Create HTTPS rule
gcloud compute firewall-rules create allow-https \
  --project=bemind-technology \
  --allow=tcp:443 \
  --source-ranges=0.0.0.0/0 \
  --description="Allow HTTPS traffic"
```

### DNS Configuration

Point your domain to the instance external IP:

```
A Record: your-domain.com → <EXTERNAL_IP>
A Record: openclaw.your-domain.com → <EXTERNAL_IP>
```

## SSL/TLS Setup

### 1. Generate Certificates

Using Let's Encrypt:

```bash
# On GCE instance
sudo apt-get install certbot
sudo certbot certonly --standalone -d your-domain.com -d openclaw.your-domain.com
```

### 2. Copy to Project

```bash
# Copy certificates
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem \
  /home/lps/server/nginx/ssl/cert.pem

sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem \
  /home/lps/server/nginx/ssl/key.pem

# Fix permissions
sudo chown lps:lps /home/lps/server/nginx/ssl/*.pem
```

### 3. Update Nginx Config

Edit nginx configs to enable SSL:
- Enable `listen 443 ssl`
- Add `ssl_certificate` directives
- Set up HTTP → HTTPS redirect

### 4. Reload Nginx

```bash
cd /home/lps/server
docker-compose exec nginx nginx -s reload
```

## Monitoring

### Access Dashboards

Forward ports via SSH tunnel:

```bash
# Grafana
ssh -L 3001:localhost:3001 bmt-staging-research

# Prometheus
ssh -L 9090:localhost:9090 bmt-staging-research

# Then access at:
# http://localhost:3001 (Grafana)
# http://localhost:9090 (Prometheus)
```

Or access directly via external IP (if firewall allows):
```
http://<EXTERNAL_IP>:3001  # Grafana
http://<EXTERNAL_IP>:9090  # Prometheus
```

### Resource Usage

```bash
# Check container resource usage
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --command="docker stats --no-stream"
```

## Backup & Restore

See [[Backup & Restore]] guide for detailed procedures.

### Quick Backup

```bash
# SSH to instance
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology

# On instance
cd /home/lps/server

# Backup MongoDB
docker-compose exec mongodb mongodump -u admin -p <password> -o /backup

# Backup PostgreSQL
docker-compose exec postgres pg_dump -U postgres_admin openclaw > backup.sql
```

## Troubleshooting

### Services Won't Start

```bash
# Check logs
./scripts/logs.sh

# Check disk space
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --command="df -h"

# Check memory
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --command="free -h"
```

### Can't Connect to Instance

```bash
# Check instance is running
gcloud compute instances list --project=bemind-technology

# Start instance if stopped
gcloud compute instances start bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology

# Check firewall rules
gcloud compute firewall-rules list --project=bemind-technology
```

### Port Issues

```bash
# Check what's listening
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --command="sudo lsof -i :80"
```

## Production Checklist

Before going to production:

- [ ] SSL certificates installed
- [ ] Firewall rules configured
- [ ] DNS records updated
- [ ] Monitoring configured
- [ ] Backup strategy implemented
- [ ] All passwords changed from defaults
- [ ] Log rotation configured
- [ ] Alert rules tested
- [ ] Disaster recovery plan documented

See [[Production Checklist]] for complete list.

## Related Documentation

- [[Local Development]] - Local development guide
- [[Production Checklist]] - Pre-production checklist
- [[Backup & Restore]] - Backup procedures
- [[Monitoring & Alerts]] - Monitoring setup
- [[SSL Setup|guides/SSL-Setup]] - SSL configuration

---

#deployment #gce #production #google-cloud
