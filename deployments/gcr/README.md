# Google Cloud Run Deployment Guide

Deploy OpenClaw DevOps platform to Google Cloud Run - a fully managed serverless platform that automatically scales your containers.

## 🚀 Quick Start (5 minutes)

```bash
# 1. Configure your GCP project
cd deployments/gcr
cp config.env config.env.local
# Edit config.env.local with your GCP_PROJECT_ID

# 2. Authenticate with GCP
gcloud auth login
gcloud auth configure-docker

# 3. Deploy everything
./deploy.sh
```

## 📋 Prerequisites

### Required Tools
- **gcloud CLI** - [Install](https://cloud.google.com/sdk/docs/install)
- **Docker** - For local image builds (optional with Cloud Build)
- **pnpm** - For building Node.js apps

```bash
# Verify installations
gcloud --version   # Should be latest version
docker --version   # Optional
pnpm --version    # Should be 9.x
```

### GCP Setup
1. **Create GCP Project** - [Console](https://console.cloud.google.com/projectcreate)
2. **Enable Billing** - Cloud Run requires billing enabled
3. **Set up Authentication**:
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

---

## 🏗️ Architecture

### Cloud Run Services

```
Internet (HTTPS)
    ↓
Cloud Load Balancer (optional)
    ↓
├─ Landing Service (openclaw-landing)
│  • Auto-scales 0-10 instances
│  • Next.js standalone build
│  • CPU: 1 core, Memory: 512Mi
│
├─ Gateway Service (openclaw-gateway)
│  • Auto-scales 1-20 instances
│  • AI gateway with agent orchestration
│  • CPU: 2 cores, Memory: 1Gi
│
└─ Assistant Service (openclaw-assistant)
   • Auto-scales 0-10 instances
   • Admin portal with NextAuth
   • CPU: 1 core, Memory: 512Mi
```

### Managed Services (Recommended)
- **Cloud SQL** - PostgreSQL database
- **Memorystore** - Redis cache
- **Secret Manager** - Credential storage
- **Cloud CDN** - Content delivery network
- **Cloud Monitoring** - Logging and metrics

---

## 📁 Project Structure

```
deployments/gcr/
├── config.env              # Configuration template
├── deploy.sh               # Main deployment script
├── cloudbuild-*.yaml       # Cloud Build configs
├── config/
│   ├── landing-service.yaml    # Cloud Run service definitions
│   ├── gateway-service.yaml
│   └── assistant-service.yaml
├── scripts/
│   ├── logs.sh            # View service logs
│   ├── status.sh          # Check service status
│   ├── scale.sh           # Scale services
│   └── rollback.sh        # Rollback deployments
└── terraform/             # Infrastructure as Code (optional)
```

---

## ⚙️ Configuration

### 1. Basic Configuration

Edit `config.env`:

```bash
# GCP Project
GCP_PROJECT_ID=your-project-id  # REQUIRED
GCP_REGION=us-central1

# Service Names (must be unique in your project)
LANDING_SERVICE_NAME=openclaw-landing
GATEWAY_SERVICE_NAME=openclaw-gateway
ASSISTANT_SERVICE_NAME=openclaw-assistant

# Resource Limits
LANDING_CPU=1
LANDING_MEMORY=512Mi
LANDING_MAX_INSTANCES=10

GATEWAY_CPU=2
GATEWAY_MEMORY=1Gi
GATEWAY_MAX_INSTANCES=20
```

### 2. Database Configuration

**Option A: MongoDB Atlas (Recommended)**
```bash
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/openclaw
```

**Option B: Cloud SQL**
```bash
CLOUD_SQL_INSTANCE=openclaw-sql
CLOUD_SQL_CONNECTION_NAME=project:region:instance
```

### 3. Secrets Management

**Using Secret Manager (Recommended for Production):**

```bash
# Create secrets
gcloud secrets create nextauth-secret --data-file=- <<< "your-secret-here"
gcloud secrets create google-oauth-secret --data-file=- <<< "your-oauth-secret"

# Update config.env
USE_SECRET_MANAGER=true
NEXTAUTH_SECRET_NAME=nextauth-secret
GOOGLE_CLIENT_SECRET_NAME=google-oauth-secret
```

---

## 🚢 Deployment

### Deploy All Services

```bash
# Full deployment (build + deploy)
./deploy.sh

# Skip building (use existing images)
./deploy.sh --skip-build

# Build only (don't deploy)
./deploy.sh --only-build
```

### Deploy Single Service

```bash
# Deploy only gateway service
./deploy.sh --service gateway

# Options: landing, gateway, assistant
```

### Using Cloud Build (Faster)

Cloud Build runs in GCP and is typically faster than local builds:

```bash
# Build using Cloud Build
gcloud builds submit \
  --config=cloudbuild-landing.yaml \
  --substitutions=_IMAGE_TAG=v1.0.0

# Deploy the built image
gcloud run deploy openclaw-landing \
  --image=gcr.io/PROJECT_ID/openclaw-landing:v1.0.0 \
  --region=us-central1
```

---

## 📊 Monitoring & Operations

### View Service Status

```bash
# Check all services
./scripts/status.sh

# Output:
# === openclaw-landing ===
#   Status: True
#   URL: https://openclaw-landing-abc123-uc.a.run.app
#   Traffic: 100%
#   Health: ✓ Healthy
```

### View Logs

```bash
# Recent logs for all services
./scripts/logs.sh

# Logs for specific service
./scripts/logs.sh gateway

# Stream logs in real-time
./scripts/logs.sh gateway -f
```

### Scale Services

```bash
# Scale gateway: min 2, max 50 instances
./scripts/scale.sh gateway 2 50

# Scale to zero (serverless)
./scripts/scale.sh landing 0 10
```

### Rollback Deployment

```bash
# Rollback to previous revision
./scripts/rollback.sh gateway

# This shifts 100% traffic to the previous revision
```

---

## 🌐 Custom Domains

### 1. Map Domain to Service

```bash
# Map your domain
gcloud run domain-mappings create \
  --service=openclaw-landing \
  --domain=your-domain.com \
  --region=us-central1
```

### 2. Configure DNS

Add the DNS records shown in the mapping command output:

```
your-domain.com.     A     216.239.32.21
your-domain.com.     A     216.239.34.21
your-domain.com.     A     216.239.36.21
your-domain.com.     A     216.239.38.21
```

### 3. SSL Certificate

Cloud Run automatically provisions and manages SSL certificates for custom domains.

---

## 💰 Cost Optimization

### Pricing Model

Cloud Run charges for:
- **vCPU** - Per second while processing requests
- **Memory** - Per second while processing requests
- **Requests** - $0.40 per million requests
- **Networking** - Egress data

### Optimization Tips

1. **Scale to Zero** - Set min-instances=0 for services with intermittent traffic
   ```bash
   LANDING_MIN_INSTANCES=0  # Scales to zero when idle
   ```

2. **CPU Throttling** - Use `CPU_ALWAYS_ALLOCATED=0` to only allocate CPU during requests
   ```bash
   CPU_ALWAYS_ALLOCATED=0  # Only charged during request processing
   ```

3. **Use Gen2 Environment** - More efficient resource usage
   ```bash
   EXECUTION_ENVIRONMENT=gen2
   ```

4. **Right-size Resources** - Start small and scale up as needed
   ```bash
   LANDING_CPU=1
   LANDING_MEMORY=512Mi
   ```

5. **Use Cloud CDN** - Cache static content closer to users
   ```bash
   # Enable via Load Balancer configuration
   ```

### Estimated Monthly Costs

**Low Traffic (< 100k requests/month):**
- Landing: ~$5-10/month
- Gateway: ~$20-30/month (min-instances=1)
- Assistant: ~$5-10/month
- **Total: ~$30-50/month**

**Medium Traffic (1M requests/month):**
- Landing: ~$20-30/month
- Gateway: ~$100-150/month
- Assistant: ~$20-30/month
- **Total: ~$140-210/month**

---

## 🔒 Security

### Best Practices

1. **Use Secret Manager** for sensitive data
   ```bash
   USE_SECRET_MANAGER=true
   ```

2. **IAM Permissions** - Use least-privilege service accounts
   ```bash
   SERVICE_ACCOUNT=openclaw-runner@project.iam.gserviceaccount.com
   ```

3. **VPC Connector** - For private database access
   ```bash
   VPC_CONNECTOR=projects/PROJECT/locations/REGION/connectors/vpc-connector
   ```

4. **Ingress Control** - Restrict access if needed
   ```bash
   INGRESS=internal-and-cloud-load-balancing
   ```

5. **Authentication** - Require IAM authentication for internal services
   ```bash
   ALLOW_UNAUTHENTICATED=false  # Requires IAM token
   ```

### Security Checklist

- [ ] Enable Secret Manager
- [ ] Configure service account with minimal permissions
- [ ] Use VPC Connector for database connections
- [ ] Enable Cloud Armor (DDoS protection)
- [ ] Set up Cloud Audit Logs
- [ ] Configure Binary Authorization (optional)
- [ ] Enable Container Analysis for vulnerability scanning

---

## 🐛 Troubleshooting

### Deployment Fails

**Error: "Permission denied"**
```bash
# Grant required permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/run.admin
```

**Error: "Revision failed"**
```bash
# Check logs
./scripts/logs.sh gateway

# Common causes:
# - Port mismatch (container must listen on $PORT)
# - Startup timeout (increase timeoutSeconds)
# - Missing environment variables
```

### Service Not Responding

```bash
# 1. Check service status
./scripts/status.sh

# 2. View recent logs
./scripts/logs.sh gateway

# 3. Check container port
# Container must listen on port specified by $PORT env var

# 4. Verify health check path
# Default: / for Next.js, /health for Gateway
```

### Slow Cold Starts

```bash
# Set minimum instances to keep warm
./scripts/scale.sh gateway 1 20

# Or in config.env:
GATEWAY_MIN_INSTANCES=1
```

### High Costs

```bash
# 1. Check current usage
gcloud logging read "resource.type=cloud_run_revision" \
  --limit=1000 \
  --format=json | \
  jq '.[] | .protoPayload.request.spec.template.spec.containers[0].resources.limits'

# 2. Reduce resources
./scripts/scale.sh gateway 0 10  # Scale to zero
GATEWAY_CPU=1  # Reduce CPU
GATEWAY_MEMORY=512Mi  # Reduce memory

# 3. Enable CPU throttling
CPU_ALWAYS_ALLOCATED=0
```

---

## 📈 Monitoring

### Cloud Console

**View Services:**
https://console.cloud.google.com/run?project=PROJECT_ID

**Metrics Dashboard:**
- Request count
- Request latency
- Container instance count
- CPU utilization
- Memory utilization

### Cloud Logging

```bash
# Query logs
gcloud logging read "resource.type=cloud_run_revision" \
  --limit=50 \
  --format="table(timestamp,severity,textPayload)"

# Set up log-based metrics
gcloud logging metrics create error_rate \
  --description="Error rate for Cloud Run services" \
  --log-filter='resource.type="cloud_run_revision" AND severity="ERROR"'
```

### Cloud Monitoring

```bash
# Create uptime check
gcloud monitoring uptime-checks create \
  --display-name="Landing Page" \
  --resource-type=uptime-url \
  --monitored-resource="https://openclaw-landing-abc123-uc.a.run.app"
```

---

## 🔄 CI/CD Integration

### GitHub Actions

```yaml
name: Deploy to Cloud Run

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      
      - name: Set up Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
      
      - name: Deploy to Cloud Run
        run: |
          cd deployments/gcr
          ./deploy.sh
```

### GitLab CI

```yaml
deploy:
  image: google/cloud-sdk:alpine
  script:
    - echo $GCP_SA_KEY | base64 -d > key.json
    - gcloud auth activate-service-account --key-file key.json
    - cd deployments/gcr
    - ./deploy.sh
  only:
    - main
```

---

## 📚 Additional Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud Run Pricing](https://cloud.google.com/run/pricing)
- [Cloud Run Best Practices](https://cloud.google.com/run/docs/best-practices)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)

---

## 🆘 Getting Help

### Quick Commands Reference

```bash
# Deploy
./deploy.sh                          # Full deployment
./deploy.sh --service gateway        # Single service
./deploy.sh --skip-build             # Use existing images

# Monitor
./scripts/status.sh                  # Service status
./scripts/logs.sh gateway            # View logs
./scripts/logs.sh gateway -f         # Stream logs

# Manage
./scripts/scale.sh gateway 1 20      # Scale service
./scripts/rollback.sh gateway        # Rollback

# GCP Console
open "https://console.cloud.google.com/run?project=$GCP_PROJECT_ID"
```

### Support Channels

- **Issues**: Create GitHub issue
- **Documentation**: See /docs directory
- **GCP Support**: https://cloud.google.com/support

---

**Last Updated:** 2026-02-07  
**Cloud Run Region:** us-central1  
**Deployment Type:** Fully Managed
