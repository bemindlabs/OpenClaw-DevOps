# Local Deployment

Configuration for local development and testing.

## 🚀 Quick Start

```bash
cd /Users/lps/server

# Start all services
./start-all.sh

# Or use docker-compose directly
docker-compose up -d

# Development mode (with hot reload)
cd apps/landing
npm run dev
```

## 📁 Files

```
deployments/local/
├── docker-compose.override.yml   # Local development overrides
├── README.md                     # This file
└── scripts/
    ├── dev.sh                    # Start dev environment
    ├── build.sh                  # Build all images
    └── clean.sh                  # Clean up containers/images
```

## 🔧 Development Workflow

### 1. Full Docker Stack

Use this for production-like testing:

```bash
# Build and start
cd /Users/lps/server
./start-all.sh

# View logs
docker-compose logs -f

# Access services
open http://localhost        # Landing via nginx
open http://localhost:3000   # Landing direct
```

### 2. Hybrid Mode (Recommended for Development)

Run nginx in Docker, Next.js locally with hot reload:

```bash
# Terminal 1: Start nginx only
cd /Users/lps/server
docker-compose up -d nginx

# Terminal 2: Run landing in dev mode
cd apps/landing
npm run dev

# Access at http://localhost:3000 (with hot reload)
```

### 3. Local Development (No Docker)

```bash
cd apps/landing
npm run dev

# Access at http://localhost:3000
# Note: Nginx routing won't work in this mode
```

## 🛠 Common Tasks

### Build Landing Image

```bash
cd apps/landing
docker build -t openclaw-landing:latest .
```

### Rebuild and Restart

```bash
cd /Users/lps/server
docker-compose down
cd apps/landing && docker build -t openclaw-landing:latest . && cd ../..
docker-compose up -d
```

### Clean Everything

```bash
# Stop containers
docker-compose down

# Remove volumes
docker-compose down -v

# Remove images
docker rmi openclaw-landing:latest

# Remove all unused Docker resources
docker system prune -a
```

### Test Production Build Locally

```bash
# Build production image
cd apps/landing
docker build -t openclaw-landing:latest .

# Run with production settings
cd /Users/lps/server
docker-compose up -d

# Test
curl http://localhost:3000
curl http://localhost/health
```

## 🐛 Debugging

### View Container Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f landing
docker-compose logs -f nginx

# Last 100 lines
docker-compose logs --tail=100 landing
```

### Exec into Container

```bash
# Landing container
docker-compose exec landing sh

# Nginx container
docker-compose exec nginx sh
```

### Check Container Health

```bash
docker-compose ps
docker inspect openclaw-landing
docker inspect openclaw-nginx
```

### Network Debugging

```bash
# Check if services can reach each other
docker-compose exec nginx ping -c 3 host.docker.internal

# Check ports
lsof -i :80
lsof -i :3000
lsof -i :18789

# Test endpoints
curl http://localhost/health
curl http://localhost:3000
curl http://localhost:18789
```

## 📦 Docker Compose Override

The `docker-compose.override.yml` in this directory extends the main `docker-compose.yml`:

- Sets `restart: unless-stopped` (instead of `always`)
- Adds development labels
- Can enable volume mounts for hot reload

To use it:

```bash
cd /Users/lps/server
docker-compose -f docker-compose.yml -f deployments/local/docker-compose.override.yml up -d
```

Or symlink it:

```bash
ln -s deployments/local/docker-compose.override.yml docker-compose.override.yml
```

## 🔄 Hot Reload Setup

For Next.js hot reload in Docker:

1. Uncomment volumes in `deployments/local/docker-compose.override.yml`
2. Restart: `docker-compose down && docker-compose up -d`
3. Changes in `apps/landing/` will trigger auto-reload

**Note:** This is slower than running `npm run dev` locally.

## 🧪 Testing

```bash
# Test landing page
curl http://localhost:3000

# Test nginx proxy
curl http://localhost

# Test health endpoint
curl http://localhost/health

# Test with actual domain (update /etc/hosts first)
echo "127.0.0.1 agents.ddns.net" | sudo tee -a /etc/hosts
curl http://agents.ddns.net
```

## 🚨 Troubleshooting

### Port Already in Use

```bash
# Find process using port 80
lsof -i :80
sudo lsof -i :80

# Kill it
sudo kill -9 <PID>

# Or use different ports in docker-compose.yml
```

### Container Won't Start

```bash
# Check logs
docker-compose logs landing

# Remove and recreate
docker-compose down
docker-compose up -d --force-recreate
```

### Image Build Fails

```bash
# Clean build cache
docker builder prune -a

# Rebuild without cache
cd apps/landing
docker build --no-cache -t openclaw-landing:latest .
```

---
*Last Updated: 2026-02-07*
