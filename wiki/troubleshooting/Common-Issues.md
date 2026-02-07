---
title: Common Issues & Solutions
tags: [troubleshooting, issues, debugging]
created: 2026-02-07
updated: 2026-02-07
---

# Common Issues & Solutions

Quick reference for common problems and their solutions.

## 🐳 Docker Issues

### Container Health Check Failing

**Symptom:** Container shows as "unhealthy" in `docker ps`

**Causes:**
- Container just started (health checks have 40s start period)
- Application not responding on health check port
- `wget` not available in container

**Solutions:**
```bash
# 1. Wait 40-60 seconds after container start

# 2. Check if application is running
docker-compose logs [service]

# 3. Manually test health endpoint
curl http://localhost:[port]/health

# 4. Check health check command
docker inspect [container] | grep -A 10 Healthcheck
```

---

### Port Already in Use

**Symptom:** Error: "bind: address already in use"

**Solutions:**
```bash
# Find process using port
lsof -i :[port]

# Example output:
# COMMAND  PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# node    1234  user   20u  IPv4 0x...      0t0  TCP *:3000

# Option 1: Kill the process (if safe)
kill -9 [PID]

# Option 2: Change port in docker-compose.yml
services:
  landing:
    ports:
      - "3001:3000"  # Change 3000 to 3001
```

---

### Container Keeps Restarting

**Symptom:** Container status shows "Restarting"

**Diagnosis:**
```bash
# View logs
docker-compose logs -f [service]

# Check exit code
docker inspect [container] | grep ExitCode

# Common exit codes:
# 0 - Success (check why it's exiting)
# 1 - Application error
# 137 - Out of memory (killed by system)
# 139 - Segmentation fault
```

**Common Causes:**
1. **Missing environment variables**
   ```bash
   # Check .env file exists
   ls -la .env

   # Verify required variables
   grep -E 'MONGODB_|POSTGRES_|REDIS_' .env
   ```

2. **Database connection failure**
   ```bash
   # Ensure database is running first
   docker-compose up -d mongodb postgres redis

   # Wait a few seconds, then start app
   docker-compose up -d landing
   ```

3. **Insufficient memory**
   ```bash
   # Check Docker resource limits
   docker stats

   # Increase Docker memory (Docker Desktop > Settings > Resources)
   ```

---

### Out of Disk Space

**Symptom:** "no space left on device"

**Solutions:**
```bash
# Check Docker disk usage
docker system df

# Remove unused images
docker image prune -a

# Remove stopped containers
docker container prune

# Remove unused volumes (⚠️ deletes data)
docker volume prune

# Clean everything (⚠️ nuclear option)
docker system prune -a --volumes
```

---

## 🌐 Network Issues

### 502 Bad Gateway (Nginx)

**Symptom:** Nginx returns 502 error

**Causes:**
- Upstream service not running
- Upstream service not ready
- Wrong upstream configuration
- Service crashed

**Solutions:**
```bash
# 1. Check upstream service is running
docker-compose ps

# 2. Test direct access to service
curl http://localhost:3000      # Landing
curl http://localhost:18789     # Gateway

# 3. Check nginx configuration
docker-compose exec nginx nginx -t

# 4. View nginx error logs
docker-compose logs nginx | grep error

# 5. Check upstream configuration
docker-compose exec nginx cat /etc/nginx/conf.d/landing.conf

# 6. Restart nginx
docker-compose restart nginx

# 7. If service name resolution fails, check network
docker network inspect devops_default
```

**Common Nginx Config Issues:**
```nginx
# ❌ Wrong - won't work in Docker
upstream landing {
    server localhost:3000;
}

# ✅ Correct - use service name
upstream landing {
    server landing:3000;
}
```

---

### Cannot Access Service from Browser

**Symptom:** Browser can't connect to http://localhost:3000

**Checklist:**
```bash
# 1. Verify container is running
docker-compose ps
# Should show "Up" status

# 2. Verify port binding
docker ps --format "table {{.Names}}\t{{.Ports}}"
# Should show: 0.0.0.0:3000->3000/tcp

# 3. Test from host
curl http://localhost:3000

# 4. Check if firewall is blocking
# macOS:
sudo pfctl -s all | grep 3000

# Linux:
sudo ufw status

# 5. Try 127.0.0.1 instead of localhost
curl http://127.0.0.1:3000
```

---

### WebSocket Connection Failed

**Symptom:** WebSocket connections drop or fail to establish

**Nginx Configuration Fix:**
```nginx
# Add to location block
location / {
    proxy_pass http://upstream_service;

    # WebSocket support
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    # Timeouts
    proxy_read_timeout 86400;
    proxy_send_timeout 86400;
}
```

**Test WebSocket:**
```bash
# Using wscat
npm install -g wscat
wscat -c ws://localhost:3000/socket
```

---

## 💾 Database Issues

### Connection Refused

**Symptom:** "ECONNREFUSED" or "Connection refused"

**Solutions:**
```bash
# 1. Check database container is running
docker-compose ps | grep -E 'mongodb|postgres|redis'

# 2. Check logs for errors
docker-compose logs mongodb
docker-compose logs postgres
docker-compose logs redis

# 3. Verify connection string
# ❌ Wrong (from inside container)
mongodb://localhost:27017

# ✅ Correct (use service name)
mongodb://admin:password@mongodb:27017

# 4. Test connection
# MongoDB
docker-compose exec mongodb mongosh --eval "db.runCommand({ ping: 1 })"

# PostgreSQL
docker-compose exec postgres pg_isready

# Redis
docker-compose exec redis redis-cli ping
```

---

### Authentication Failed

**Symptom:** "Authentication failed" or "Access denied"

**Solutions:**
```bash
# 1. Check .env file has correct credentials
cat .env | grep -E 'MONGODB_|POSTGRES_|REDIS_'

# 2. Verify environment variables are loaded
docker-compose exec landing env | grep MONGODB

# 3. Reset database (⚠️ deletes data)
docker-compose down -v
docker-compose up -d mongodb postgres redis
```

---

### Database Out of Space

**Symptom:** "No space left" or "Disk full"

**Solutions:**
```bash
# Check volume usage
docker system df -v

# For MongoDB - compact database
docker-compose exec mongodb mongosh
> use admin
> db.runCommand({ compact: 'collectionName' })

# For PostgreSQL - vacuum
docker-compose exec postgres psql -U postgres_admin openclaw
> VACUUM FULL;

# Clean up old data (if applicable)
```

---

## 📦 pnpm Issues

### Installation Fails

**Symptom:** `pnpm install` fails with errors

**Solutions:**
```bash
# 1. Clear pnpm cache
pnpm store prune

# 2. Remove lock file and node_modules
rm pnpm-lock.yaml
rm -rf node_modules apps/*/node_modules

# 3. Clear global cache
rm -rf ~/.pnpm-store

# 4. Reinstall
pnpm install

# 5. If still fails, check Node version
node --version  # Should be 20.0+
```

---

### Workspace Not Found

**Symptom:** "No projects matched the filters"

**Solutions:**
```bash
# 1. Check pnpm-workspace.yaml exists
cat pnpm-workspace.yaml

# 2. Verify workspace structure
ls apps/
# Should show: landing/ assistant/ openclaw-gateway/

# 3. Check package.json in each workspace
ls apps/*/package.json

# 4. Verify package names match
grep '"name":' apps/*/package.json
```

---

### Build Fails

**Symptom:** `pnpm build` fails with errors

**Common Issues:**

**TypeScript Errors:**
```bash
# Type check
pnpm typecheck

# Check specific app
cd apps/landing
pnpm exec tsc --noEmit
```

**Missing Dependencies:**
```bash
# Install dependencies
pnpm install

# Install for specific workspace
pnpm --filter @openclaw/landing install
```

**Out of Memory:**
```bash
# Increase Node memory
export NODE_OPTIONS="--max-old-space-size=4096"
pnpm build
```

---

## 🔧 Configuration Issues

### Environment Variables Not Loaded

**Symptom:** Application can't find environment variables

**Solutions:**
```bash
# 1. Check .env file exists
ls -la .env

# 2. Verify .env format (no spaces around =)
# ❌ Wrong
MONGODB_PASSWORD = mypassword

# ✅ Correct
MONGODB_PASSWORD=mypassword

# 3. Restart containers to reload env
docker-compose down
docker-compose up -d

# 4. Verify env vars in container
docker-compose exec landing env | grep MONGODB
```

---

### SSL Certificate Issues

**Symptom:** "SSL certificate problem" or "certificate verify failed"

**Solutions:**
```bash
# Development: Use self-signed certs
cd nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout key.pem -out cert.pem

# Production: Use Let's Encrypt
certbot certonly --nginx -d yourdomain.com

# Verify certificate
openssl x509 -in nginx/ssl/cert.pem -text -noout
```

---

## 🚀 Deployment Issues

### GCE Deployment Fails

**Symptom:** Deploy script fails on GCE

**Solutions:**
```bash
# 1. Check SSH connection
ssh -i deployments/gce/keys/id_rsa user@your-server

# 2. Verify config
cat deployments/gce/config.env

# 3. Check deployment logs
tail -f /var/log/openclaw-deploy.log

# 4. Manual deployment steps
cd deployments/gce
./deploy.sh --dry-run  # Test without executing
```

---

### DNS Not Resolving

**Symptom:** Domain doesn't point to server

**Solutions:**
```bash
# 1. Check DNS records
nslookup yourdomain.com
dig yourdomain.com

# 2. Verify A records point to server IP
# Should return your server's public IP

# 3. Wait for DNS propagation (up to 48 hours)
# Check propagation status:
# https://www.whatsmydns.net/

# 4. Test with server IP directly
curl http://YOUR_SERVER_IP
```

---

## 📊 Monitoring Issues

### Prometheus Not Scraping

**Symptom:** No metrics in Prometheus

**Solutions:**
```bash
# 1. Check Prometheus targets
# Visit: http://localhost:9090/targets

# 2. Verify exporters are running
docker-compose ps | grep exporter

# 3. Test exporter endpoints
curl http://localhost:9100/metrics  # Node exporter
curl http://localhost:9121/metrics  # Redis exporter

# 4. Check Prometheus config
docker-compose exec prometheus cat /etc/prometheus/prometheus.yml

# 5. Reload Prometheus config
docker-compose exec prometheus kill -HUP 1
```

---

### Grafana Dashboards Empty

**Symptom:** Grafana shows no data

**Solutions:**
```bash
# 1. Check Prometheus data source
# Grafana > Configuration > Data Sources
# URL should be: http://prometheus:9090

# 2. Test query in Prometheus first
# http://localhost:9090/graph

# 3. Check time range in Grafana
# Default: Last 6 hours

# 4. Verify metrics exist
# Prometheus > Graph > Enter metric name
```

---

## 🔐 Security Issues

### Exposed Credentials

**Symptom:** Accidentally committed secrets to git

**Immediate Action:**
```bash
# 1. Remove from current commit
git rm --cached .env
git commit --amend

# 2. Rotate all exposed credentials immediately

# 3. Update .gitignore
echo ".env" >> .gitignore

# 4. For already pushed commits, use BFG Repo-Cleaner
# https://rtyley.github.io/bfg-repo-cleaner/
```

---

### Weak Default Passwords

**Symptom:** Still using default passwords

**Solution:**
```bash
# Generate strong passwords
./scripts/generate-passwords.sh

# Or manually in .env
MONGODB_ROOT_PASSWORD=$(openssl rand -base64 32)
POSTGRES_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
```

---

## 🛠️ General Debugging

### Enable Debug Logging

```bash
# Set environment variable
export DEBUG=*

# Or in .env
DEBUG=*
NODE_ENV=development

# Restart services
docker-compose restart
```

---

### Container Shell Access

```bash
# Access container shell
docker-compose exec landing sh

# Or bash if available
docker-compose exec landing bash

# For exited containers
docker run -it --rm openclaw-landing:latest sh
```

---

### View All Logs

```bash
# All services
docker-compose -f docker-compose.full.yml logs -f

# Specific service
docker-compose logs -f landing

# Last 100 lines
docker-compose logs --tail=100 landing

# Since timestamp
docker-compose logs --since 2026-02-07T10:00:00 landing
```

---

## 📞 Still Stuck?

If you can't resolve your issue:

1. **Search** [GitHub Issues](https://github.com/openclaw/devops/issues)
2. **Ask** in [Discussions](https://github.com/openclaw/devops/discussions)
3. **Check** [FAQ](FAQ.md)
4. **Review** [Support Guide](../SUPPORT.md)

When asking for help, include:
- Operating system and version
- Docker version (`docker --version`)
- Node version (`node --version`)
- Error messages (full output)
- Steps to reproduce
- What you've already tried

---

**Last Updated:** 2026-02-07
