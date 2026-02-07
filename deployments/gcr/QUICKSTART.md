# Google Cloud Run - Quick Start Guide

Get OpenClaw DevOps running on Cloud Run in 10 minutes.

## Prerequisites

- Google Cloud account with billing enabled
- gcloud CLI installed
- Project root configured with pnpm

## Step 1: Install gcloud CLI (if needed)

```bash
# macOS
brew install --cask google-cloud-sdk

# Linux
curl https://sdk.cloud.google.com | bash

# Windows
# Download from: https://cloud.google.com/sdk/docs/install

# Verify
gcloud --version
```

## Step 2: Authenticate & Setup Project

```bash
# Login to GCP
gcloud auth login

# Login for Docker (to push images)
gcloud auth configure-docker

# Create new project (or use existing)
gcloud projects create openclaw-devops --name="OpenClaw DevOps"

# Set active project
gcloud config set project openclaw-devops

# Enable billing (REQUIRED)
# Visit: https://console.cloud.google.com/billing
```

## Step 3: Configure Deployment

```bash
cd deployments/gcr

# Copy configuration
cp config.env config.env.local

# Edit config.env.local
# Required changes:
#   - GCP_PROJECT_ID=openclaw-devops
#   - MONGODB_URI=your-mongodb-connection-string
#   - REDIS_HOST=your-redis-host (or use Memorystore)
```

## Step 4: Deploy

```bash
# One-command deployment
./deploy.sh

# This will:
# 1. Enable required GCP APIs
# 2. Build Docker images using Cloud Build
# 3. Push images to Container Registry
# 4. Deploy to Cloud Run
# 5. Display service URLs
```

## Step 5: Verify Deployment

```bash
# Check status
./scripts/status.sh

# View logs
./scripts/logs.sh

# Test services
curl https://openclaw-landing-HASH-uc.a.run.app
curl https://openclaw-gateway-HASH-uc.a.run.app/health
```

## Using Makefile (Alternative)

```bash
# From project root
make deploy-cloud-run

# Check status
make cloud-run-status

# View logs
make cloud-run-logs
```

## Next Steps

### 1. Configure Custom Domains

```bash
# Map domain
gcloud run domain-mappings create \
  --service=openclaw-landing \
  --domain=your-domain.com \
  --region=us-central1

# Add DNS records as shown in output
```

### 2. Set Up Managed Databases

**MongoDB Atlas:**
```bash
# Get connection string
# Update config.env.local:
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/openclaw
```

**Cloud SQL (PostgreSQL):**
```bash
# Create instance
gcloud sql instances create openclaw-db \
  --database-version=POSTGRES_14 \
  --region=us-central1 \
  --tier=db-f1-micro

# Create database
gcloud sql databases create openclaw \
  --instance=openclaw-db
```

**Memorystore (Redis):**
```bash
# Create instance
gcloud redis instances create openclaw-redis \
  --region=us-central1 \
  --tier=basic \
  --size=1
```

### 3. Use Secret Manager

```bash
# Create secrets
echo -n "your-nextauth-secret" | gcloud secrets create nextauth-secret --data-file=-
echo -n "your-google-oauth-secret" | gcloud secrets create google-oauth-secret --data-file=-

# Grant access to Cloud Run
gcloud secrets add-iam-policy-binding nextauth-secret \
  --member=serviceAccount:PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --role=roles/secretmanager.secretAccessor

# Update config.env.local:
USE_SECRET_MANAGER=true
NEXTAUTH_SECRET_NAME=nextauth-secret
```

### 4. Enable Cloud CDN (Optional)

```bash
# Create load balancer with CDN
gcloud compute backend-services create openclaw-backend \
  --global \
  --enable-cdn
```

## Cost Estimates

**Minimal Setup (Low Traffic):**
- Cloud Run: ~$30/month
- MongoDB Atlas Free Tier: $0
- Total: **~$30/month**

**Production Setup (Medium Traffic):**
- Cloud Run: ~$150/month
- Cloud SQL: ~$30/month
- Memorystore: ~$40/month
- Total: **~$220/month**

## Troubleshooting

**"Permission denied" error:**
```bash
# Enable Cloud Build API
gcloud services enable cloudbuild.googleapis.com

# Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/run.admin
```

**Services not responding:**
```bash
# Check logs
./scripts/logs.sh gateway

# Common issues:
# - Container not listening on $PORT
# - Missing environment variables
# - Database connection failed
```

**High costs:**
```bash
# Scale down min instances
./scripts/scale.sh gateway 0 10

# Check current usage
gcloud monitoring dashboards list
```

## Useful Commands

```bash
# Deploy
./deploy.sh                    # All services
./deploy.sh --service gateway  # Single service
./deploy.sh --skip-build       # Skip building

# Monitor
./scripts/status.sh            # Check status
./scripts/logs.sh gateway -f   # Stream logs

# Manage
./scripts/scale.sh gateway 1 20    # Scale
./scripts/rollback.sh gateway      # Rollback

# Clean up (delete everything)
gcloud run services delete openclaw-landing --region=us-central1
gcloud run services delete openclaw-gateway --region=us-central1
gcloud run services delete openclaw-assistant --region=us-central1
```

## Support

- **Documentation**: See [README.md](README.md)
- **GCP Console**: https://console.cloud.google.com/run
- **Issues**: GitHub issues
- **Cloud Run Docs**: https://cloud.google.com/run/docs

---

**Ready to deploy?**
```bash
cd deployments/gcr && ./deploy.sh
```
