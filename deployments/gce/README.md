# GCE Deployment

Deployment configuration and scripts for Google Compute Engine.

## 📋 Instance Details

- **Project:** bemind-technology
- **Instance:** bmt-staging-research
- **Zone:** asia-southeast1-a
- **Region:** asia-southeast1

## 🚀 Quick Deploy

### First Time Setup

```bash
cd /Users/lps/server/deployments/gce

# Setup instance (install Docker, dependencies)
./deploy.sh --setup

# Deploy code and start services
./deploy.sh --build
```

### Regular Deployment

```bash
# Deploy without rebuilding locally
./deploy.sh

# Deploy with local build
./deploy.sh --build
```

## 📁 Files

```
deployments/gce/
├── config.env                    # GCE configuration
├── deploy.sh                     # Main deployment script
├── setup-instance.sh             # Instance setup script
├── docker-compose.override.yml   # GCE-specific overrides
├── README.md                     # This file
└── scripts/
    ├── start.sh                  # Start services
    ├── stop.sh                   # Stop services
    ├── restart.sh                # Restart services
    └── logs.sh                   # View logs
```

## 🔧 Deployment Scripts

### deploy.sh

Main deployment script with options:

```bash
# Full deployment with setup
./deploy.sh --setup --build

# Deploy only (assumes instance is setup)
./deploy.sh

# Deploy with local build
./deploy.sh --build
```

**What it does:**
1. Checks GCP authentication
2. Verifies instance exists
3. (Optional) Builds image locally
4. (Optional) Runs setup on instance
5. Syncs files to instance
6. Builds image on instance
7. Starts services

### setup-instance.sh

Prepares GCE instance:
- Updates system packages
- Installs Docker & Docker Compose
- Configures firewall (ports 22, 80, 443, 3000, 18789)
- Creates necessary directories

## 🌐 Accessing Services

After deployment, services are available at:

```
http://<INSTANCE_IP>         # Landing page (via nginx)
http://<INSTANCE_IP>:3000    # Landing page (direct)
http://<INSTANCE_IP>:18789   # Gateway
http://<INSTANCE_IP>/health  # Nginx health check
```

### Get Instance IP

```bash
gcloud compute instances describe bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

## 📊 Management Commands

### SSH to Instance

```bash
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology
```

### View Logs

```bash
# All services
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --command="cd /home/lps/server && docker-compose logs -f"

# Specific service
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --command="cd /home/lps/server && docker-compose logs -f landing"
```

### Restart Services

```bash
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --command="cd /home/lps/server && docker-compose restart"
```

### Check Service Status

```bash
gcloud compute ssh bmt-staging-research \
  --zone=asia-southeast1-a \
  --project=bemind-technology \
  --command="cd /home/lps/server && docker-compose ps"
```

## 🔐 SSL Setup

### 1. Copy SSL Certificates

```bash
# From local machine
gcloud compute scp nginx/ssl/cert.pem bmt-staging-research:~/server/nginx/ssl/ \
  --zone=asia-southeast1-a --project=bemind-technology

gcloud compute scp nginx/ssl/key.pem bmt-staging-research:~/server/nginx/ssl/ \
  --zone=asia-southeast1-a --project=bemind-technology
```

### 2. Update Nginx Config

SSH to instance and update nginx configs to use SSL:
- Enable listen 443 ssl
- Add ssl_certificate and ssl_certificate_key directives
- Reload nginx: `docker-compose exec nginx nginx -s reload`

## 🔧 Firewall Rules

Ensure GCP firewall rules allow traffic:

```bash
# Check existing rules
gcloud compute firewall-rules list --project=bemind-technology

# Create HTTP/HTTPS rules if needed
gcloud compute firewall-rules create allow-http \
  --project=bemind-technology \
  --allow=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --description="Allow HTTP traffic"

gcloud compute firewall-rules create allow-https \
  --project=bemind-technology \
  --allow=tcp:443 \
  --source-ranges=0.0.0.0/0 \
  --description="Allow HTTPS traffic"

gcloud compute firewall-rules create allow-landing \
  --project=bemind-technology \
  --allow=tcp:3000 \
  --source-ranges=0.0.0.0/0 \
  --description="Allow Landing page direct access"

gcloud compute firewall-rules create allow-gateway \
  --project=bemind-technology \
  --allow=tcp:18789 \
  --source-ranges=0.0.0.0/0 \
  --description="Allow Gateway access"
```

## 🐛 Troubleshooting

### Deployment Fails

```bash
# Check instance is running
gcloud compute instances list --project=bemind-technology

# Check SSH access
gcloud compute ssh bmt-staging-research --zone=asia-southeast1-a --project=bemind-technology

# Check Docker is running
gcloud compute ssh bmt-staging-research --zone=asia-southeast1-a --project=bemind-technology \
  --command="docker ps"
```

### Services Not Accessible

```bash
# Check containers
gcloud compute ssh bmt-staging-research --zone=asia-southeast1-a --project=bemind-technology \
  --command="docker ps"

# Check firewall
gcloud compute firewall-rules list --project=bemind-technology

# Test from instance
gcloud compute ssh bmt-staging-research --zone=asia-southeast1-a --project=bemind-technology \
  --command="curl http://localhost:3000 && curl http://localhost:18789"
```

### DNS Not Working

1. Verify DNS records point to instance external IP
2. Wait for DNS propagation (can take up to 48 hours)
3. Test with IP address first: `http://<INSTANCE_IP>`

## 📝 Configuration

Edit `config.env` to customize:
- Instance details (project, zone, instance name)
- Server settings (user, directory)
- Application settings (ports, domains)
- Docker images

## 🔄 CI/CD Integration

For automated deployments, use the deploy script in CI/CD:

```bash
# In GitHub Actions, Cloud Build, etc.
gcloud auth activate-service-account --key-file=$KEY_FILE
cd deployments/gce
./deploy.sh
```

---
*Last Updated: 2026-02-07*
