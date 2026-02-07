---
title: Frequently Asked Questions
tags: [faq, questions, help]
created: 2026-02-07
updated: 2026-02-07
---

# Frequently Asked Questions (FAQ)

Common questions and answers about OpenClaw DevOps platform.

## 🚀 Getting Started

### Q: What is OpenClaw DevOps?

**A:** OpenClaw DevOps is a full-stack DevOps platform built with Docker, featuring:
- Next.js landing page and admin portal
- Express.js API gateway
- Multiple databases (MongoDB, PostgreSQL, Redis)
- Monitoring stack (Prometheus, Grafana)
- Workflow automation (n8n)
- Event streaming (Kafka)

### Q: What are the system requirements?

**A:** Minimum requirements:
- **OS**: macOS, Linux, or Windows with WSL2
- **Docker**: 24.0+ with Docker Compose
- **Node.js**: 20.0+
- **pnpm**: 9.0+
- **RAM**: 8GB minimum, 16GB recommended
- **Disk**: 20GB free space

### Q: How do I get started quickly?

**A:**
```bash
# Clone repository
git clone https://github.com/openclaw/devops.git
cd devops

# Install dependencies
pnpm install

# Start basic stack
./start-all.sh
```

See [Quick Start Guide](../setup/Quick-Start-Guide.md) for details.

## 🐳 Docker & Containers

### Q: Why are containers showing "unhealthy"?

**A:** Health checks have a 40-second start period. Wait 40-60 seconds after starting containers. If still unhealthy:
```bash
# Check logs
docker-compose logs [service-name]

# Manually test health check
docker exec [container] wget --quiet --tries=1 --spider http://localhost:[port]
```

### Q: Port already in use error?

**A:** Find and stop the process using the port:
```bash
# Find process
lsof -i :[port]

# Kill process (if safe)
kill -9 [PID]

# Or change port in docker-compose.yml
```

### Q: Containers keep restarting?

**A:** Check logs for errors:
```bash
# View container logs
docker-compose logs -f [service]

# Check exit code
docker inspect [container] | grep ExitCode
```

Common causes:
- Missing environment variables
- Database connection failures
- Port conflicts
- Insufficient memory

### Q: How do I clean up Docker resources?

**A:**
```bash
# Stop all containers
docker-compose down

# Remove volumes (⚠️ deletes data)
docker-compose down -v

# Clean up unused images
docker image prune -a

# Clean up everything (⚠️ nuclear option)
docker system prune -a --volumes
```

## 🔧 Configuration

### Q: Where do I configure environment variables?

**A:** Create `.env` file from template:
```bash
cp .env.example .env
# Edit .env with your values
```

Never commit `.env` to git!

### Q: How do I change default passwords?

**A:** Edit `.env` file:
```env
MONGODB_ROOT_PASSWORD=your-strong-password
POSTGRES_PASSWORD=your-strong-password
REDIS_PASSWORD=your-strong-password
```

Then restart services:
```bash
docker-compose down
docker-compose up -d
```

### Q: Can I use different ports?

**A:** Yes! Edit `docker-compose.yml`:
```yaml
services:
  landing:
    ports:
      - "3001:3000"  # Change left side only
```

## 🌐 Networking

### Q: Can't access services from browser?

**A:** Check:
1. **Container running**: `docker-compose ps`
2. **Port mapping**: `docker ps --format "table {{.Names}}\t{{.Ports}}"`
3. **Nginx config**: `docker-compose exec nginx nginx -t`
4. **Firewall**: Allow ports 80, 443, 3000, etc.

### Q: 502 Bad Gateway error?

**A:** Nginx can't reach upstream service:
```bash
# 1. Check service is running
docker-compose ps

# 2. Test direct service access
curl http://localhost:3000  # Landing
curl http://localhost:18789 # Gateway

# 3. Check nginx config
docker-compose exec nginx nginx -t

# 4. Reload nginx
docker-compose restart nginx
```

### Q: WebSocket connections failing?

**A:** Ensure nginx config includes WebSocket headers:
```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

See `nginx/conf.d/*.conf` files.

## 💾 Databases

### Q: How do I connect to databases?

**A:**

**MongoDB:**
```bash
docker-compose exec mongodb \
  mongosh -u admin -p [password]
```

**PostgreSQL:**
```bash
docker-compose exec postgres \
  psql -U postgres_admin -d openclaw
```

**Redis:**
```bash
docker-compose exec redis \
  redis-cli -a [password]
```

### Q: Database connection refused?

**A:** Common issues:
1. **Service not running**: `docker-compose ps`
2. **Wrong credentials**: Check `.env` file
3. **Wrong host**: Use service name (e.g., `mongodb:27017`)
4. **Not on same network**: Services must use same Docker network

### Q: How do I backup databases?

**A:** See [Database Backup Guide](../guides/Database-Backup.md)

Quick backup:
```bash
# MongoDB
docker-compose exec mongodb mongodump --out /backup

# PostgreSQL
docker-compose exec postgres pg_dump openclaw > backup.sql
```

## 📦 pnpm Workspace

### Q: `pnpm install` fails?

**A:**
```bash
# Clear cache
pnpm store prune

# Remove lock file
rm pnpm-lock.yaml

# Reinstall
pnpm install
```

### Q: How do I add a dependency to a specific app?

**A:**
```bash
# Add to specific workspace
pnpm --filter @openclaw/landing add [package]

# Add to all workspaces
pnpm -r add [package]

# Add to root only
pnpm add -w [package]
```

### Q: Workspace not found error?

**A:** Check `pnpm-workspace.yaml`:
```yaml
packages:
  - 'apps/*'
```

Ensure your app is in `apps/` directory with proper `package.json`.

## 🏗️ Building & Development

### Q: Build fails with TypeScript errors?

**A:**
```bash
# Type check
pnpm typecheck

# Check specific app
cd apps/landing
pnpm exec tsc --noEmit
```

Fix TypeScript errors before building.

### Q: Hot reload not working?

**A:**
```bash
# Ensure dev mode
pnpm dev:landing

# Check if running in container (may need volume mounts)
docker-compose.yml:
  volumes:
    - ./apps/landing:/app
    - /app/node_modules
```

### Q: How do I build Docker images?

**A:**
```bash
# Build specific service
cd apps/landing
docker build -t openclaw-landing:latest .

# Or use build script
./BUILD-IMAGES.sh
```

## 🚀 Deployment

### Q: How do I deploy to production?

**A:** See [GCE Deployment Guide](../deployment/GCE.md)

Quick deploy:
```bash
cd deployments/gce
./deploy.sh
```

### Q: How do I setup SSL certificates?

**A:** See [SSL Setup Guide](../guides/SSL-Setup.md)

For Let's Encrypt:
```bash
# Using certbot
certbot certonly --nginx -d yourdomain.com
```

### Q: DNS not working?

**A:** Ensure DNS points to your server:
```bash
# Check DNS
nslookup yourdomain.com

# Should return your server IP
```

Update DNS A records at your domain registrar.

## 🔐 Security

### Q: How do I secure my deployment?

**A:**
1. **Change default passwords** in `.env`
2. **Use SSL certificates** for HTTPS
3. **Configure firewall** rules
4. **Enable authentication** on all services
5. **Regular updates** of dependencies

See [Security Best Practices](../SECURITY.md)

### Q: Found a security vulnerability?

**A:** **DO NOT** open public issue. Email: security@openclaw.dev

See [Security Policy](../SECURITY.md)

## 📊 Monitoring

### Q: How do I access Grafana?

**A:**
```
URL: http://localhost:3001
Default credentials:
  Username: admin
  Password: admin (change on first login!)
```

### Q: Prometheus not scraping metrics?

**A:** Check:
1. **Targets in Prometheus**: http://localhost:9090/targets
2. **Exporters running**: `docker-compose ps`
3. **Firewall rules**: Allow scraping ports
4. **Service discovery**: Check `prometheus/prometheus.yml`

### Q: No metrics showing?

**A:** Ensure exporters are configured:
```yaml
# docker-compose.full.yml
services:
  node-exporter:
    # Should be present and running
```

Check Prometheus targets: http://localhost:9090/targets

## 🛠️ Troubleshooting

### Q: Service won't start?

**A:** Debug steps:
```bash
# 1. Check logs
docker-compose logs -f [service]

# 2. Inspect container
docker inspect [container]

# 3. Try manual start
docker-compose up [service]

# 4. Rebuild if needed
docker-compose build [service]
docker-compose up -d [service]
```

### Q: Everything is broken, how do I reset?

**A:**
```bash
# ⚠️ NUCLEAR OPTION - Deletes all data

# Stop everything
docker-compose -f docker-compose.full.yml down -v

# Clean Docker
docker system prune -a --volumes

# Reinstall dependencies
pnpm clean
pnpm install

# Start fresh
./start-all.sh
```

### Q: Where can I find more help?

**A:**
- [Troubleshooting Guide](Common-Issues.md)
- [GitHub Discussions](https://github.com/openclaw/devops/discussions)
- [Support Policy](../SUPPORT.md)

## 💡 Best Practices

### Q: What's the recommended development workflow?

**A:**
1. **Local development**: Use `pnpm dev:[app]`
2. **Test changes**: Use git hooks (auto-configured)
3. **Docker testing**: Build and test in containers
4. **Commit**: Pre-commit hooks run lint/type-check
5. **Push**: Pre-push hooks run builds
6. **Deploy**: Use deployment scripts

### Q: How often should I update dependencies?

**A:**
```bash
# Check for updates
pnpm outdated

# Update (test thoroughly!)
pnpm update

# Check for security issues
pnpm audit
```

Recommended: Monthly dependency updates, immediate security patches.

## 🤝 Contributing

### Q: How can I contribute?

**A:** See [Contributing Guide](../CONTRIBUTING.md) and [Community Guidelines](../COMMUNITY.md)

Ways to contribute:
- Report bugs
- Fix issues
- Improve documentation
- Add features
- Help others

### Q: I found a bug, what should I do?

**A:**
1. **Search existing issues**: Might already be reported
2. **Gather information**: Logs, environment, steps to reproduce
3. **Create issue**: Use bug report template
4. **Provide details**: The more info, the faster we can fix

---

## 📞 Still Have Questions?

- **Search**: [All Documentation](../Home.md)
- **Ask**: [GitHub Discussions](https://github.com/openclaw/devops/discussions)
- **Support**: [Getting Support](../SUPPORT.md)

---

**Last Updated:** 2026-02-07

*Don't see your question? [Ask in Discussions](https://github.com/openclaw/devops/discussions/new?category=q-a)*
