# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**OpenClaw DevOps** is a full-stack DevOps platform with Next.js landing page, Nginx reverse proxy, AI gateway, databases, messaging, and monitoring infrastructure.

### Architecture

```
Internet
    ↓
DNS
    ├─ your-domain.com → Landing Page (Next.js)
    ├─ openclaw.your-domain.com → Gateway (OpenClaw)
    └─ assistant.your-domain.com → Admin Portal (Next.js)
    ↓
Nginx (Port 80/443)
    ├─ / → Landing (Port 3000)
    ├─ openclaw. → Gateway (Port 18789)
    └─ assistant. → Assistant (Port 5555)
```

### Monorepo Structure

This project uses **pnpm workspaces** for monorepo management.

**Package Manager:** pnpm v9+

**Workspace Apps:**
- `@openclaw/landing` - Landing page (Next.js)
- `@openclaw/assistant` - Admin portal (Next.js)
- `@openclaw/gateway` - API gateway (Express.js)

### Core Services

**Basic Stack:**
- **Nginx** (port 80/443): Reverse proxy with rate limiting and WebSocket support
- **Landing Page** (port 3000): Next.js 16 standalone application
- **Gateway** (port 18789): OpenClaw AI gateway service

**Full Stack (docker-compose.full.yml):**

*Databases:*
- **MongoDB** (port 27017): Document database for application data
- **PostgreSQL** (port 5432): Relational database for structured data and n8n
- **Redis** (port 6379): Cache, session store, and message broker

*Messaging & Workflows:*
- **Kafka** (port 9092): Event streaming platform
- **Zookeeper** (port 2181): Kafka coordination service
- **n8n** (port 5678): Workflow automation platform

*Monitoring:*
- **Prometheus** (port 9090): Metrics collection and alerting
- **Grafana** (port 3001): Metrics visualization and dashboards
- **Exporters**: Node, cAdvisor, Redis, PostgreSQL, MongoDB metrics

### Domain Routing

- `your-domain.com` → Landing Page (Next.js on port 3000)
- `openclaw.your-domain.com` → Gateway service (port 18789)
- `assistant.your-domain.com` → Admin Assistant Portal (port 5555)

## Project Structure

```
$(pwd)/
├── apps/
│   ├── landing/              # Next.js landing page
│   ├── assistant/            # Admin portal (Next.js)
│   └── openclaw-gateway/     # Express.js API gateway
├── nginx/
│   ├── nginx.conf            # Main nginx config
│   ├── conf.d/               # Site-specific configs
│   │   ├── landing.conf      # Landing proxy
│   │   ├── openclaw.conf     # Gateway proxy
│   │   └── assistant.conf    # Assistant proxy
│   └── ssl/                  # SSL certificates
├── monitoring/
│   ├── prometheus/           # Prometheus configs
│   └── grafana/              # Grafana dashboards
├── deployments/
│   ├── gce/                  # GCE deployment scripts
│   └── local/                # Local dev configs
├── docker-compose.yml        # Basic stack
├── docker-compose.full.yml   # Full stack with all services
└── start-all.sh              # Quick start script
```

## Development Commands

### Quick Start

```bash
# Install dependencies (first time)
cd $(pwd)
pnpm install

# Start basic stack (nginx + landing + gateway)
./start-all.sh

# Or manually
docker-compose up -d
```

### pnpm Workspace Commands

```bash
# Install all dependencies
pnpm install

# Development servers
pnpm dev:landing      # Start landing dev server (port 3000)
pnpm dev:assistant    # Start assistant dev server (port 5555)
pnpm dev:gateway      # Start gateway dev server (port 18789)

# Build apps
pnpm build:landing    # Build landing for production
pnpm build:assistant  # Build assistant for production
pnpm build:all        # Build all apps

# Linting
pnpm lint:landing     # Lint landing app
pnpm lint:assistant   # Lint assistant app
pnpm lint:all         # Lint all apps

# Clean
pnpm clean            # Remove all node_modules and build artifacts
```

### Full Stack

```bash
# Setup environment
cp .env.example .env
./scripts/generate-passwords.sh

# Start all services
docker-compose -f docker-compose.full.yml up -d

# Start specific services
docker-compose -f docker-compose.full.yml up -d mongodb postgres redis
```

### Building Services

```bash
# Build landing page
cd apps/landing
docker build -t openclaw-landing:latest .

# Build gateway
cd apps/gateway
docker build -t openclaw-gateway:latest .

# Build assistant
cd apps/assistant
docker build -t openclaw-assistant:latest .
```

### Development Mode

```bash
# Landing page (with hot reload)
cd apps/landing
npm run dev
# Visit http://localhost:3000

# Gateway
cd apps/gateway
npm run dev
# API available at http://localhost:18789

# Assistant portal
cd apps/assistant
npm run dev
# Portal at http://localhost:5555
```

## Docker Operations

### Container Management

```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs -f
docker-compose logs -f landing
docker-compose logs -f nginx

# Restart services
docker-compose restart
docker-compose restart landing

# Stop all
docker-compose down

# Clean up
docker-compose down -v
docker image prune -a
```

### Health Checks

```bash
# Check service health
curl http://localhost/health        # Nginx
curl http://localhost:3000          # Landing
curl http://localhost:18789         # Gateway

# Full stack health checks
curl http://localhost:9090/-/healthy # Prometheus
curl http://localhost:3001/api/health # Grafana
```

## Architecture Notes

### Docker Networking

**macOS/Windows (Development):**
- Uses **bridge networking** with port mappings
- Services communicate via Docker service names (e.g., `landing:3000`, `gateway:18789`)
- Ports exposed: `80:80`, `3000:3000`, `18789:18789`

**Linux (Production):**
- Can use **host networking** for better performance
- Services communicate via `localhost` or `127.0.0.1`
- No port mapping needed (direct host network access)

**Current Configuration:**
The project is configured for bridge networking (macOS compatible). To switch to host mode for Linux deployments:
1. Remove `ports:` sections from docker-compose.yml
2. Add `network_mode: "host"` to each service
3. Update nginx upstream servers to use `127.0.0.1` instead of service names

### Next.js Standalone Build

Landing page uses `output: "standalone"` in `next.config.ts`:
- Optimized production build in `.next/standalone/`
- Multi-stage Dockerfile for minimal image size
- Faster cold starts
- Self-contained: runs with `node server.js`

### Nginx Configuration

```
nginx/conf.d/
├── landing.conf      # agents.ddns.net → landing:3000
├── openclaw.conf     # openclaw.agents.ddns.net → gateway:18789
└── assistant.conf    # assistant.agents.ddns.net → assistant:5555
```

Each config includes:
- Rate limiting (100 req/min for landing, 60 req/min for gateway)
- WebSocket support (Upgrade headers)
- Health check endpoint at `/health`
- Proper proxy headers and timeouts

## Common Workflows

### Updating a Service

1. Make code changes in `apps/<service>/`
2. Rebuild Docker image:
   ```bash
   cd apps/<service>
   docker build -t openclaw-<service>:latest .
   ```
3. Restart container:
   ```bash
   docker-compose restart <service>
   ```

### Modifying Nginx Configuration

1. Edit `nginx/nginx.conf` or `nginx/conf.d/*.conf`
2. Test configuration:
   ```bash
   docker-compose exec nginx nginx -t
   ```
3. Reload nginx:
   ```bash
   docker-compose exec nginx nginx -s reload
   ```

### Database Operations

```bash
# MongoDB
docker-compose -f docker-compose.full.yml exec mongodb \
  mongosh -u admin -p <password>

# PostgreSQL
docker-compose -f docker-compose.full.yml exec postgres \
  psql -U postgres_admin -d openclaw

# Redis
docker-compose -f docker-compose.full.yml exec redis \
  redis-cli -a <password>

# Kafka topics
docker-compose -f docker-compose.full.yml exec kafka \
  kafka-topics --list --bootstrap-server localhost:9092
```

## Troubleshooting

### Service Not Accessible

```bash
# 1. Check if container is running
docker-compose ps

# 2. Check container logs
docker-compose logs <service>

# 3. Check port binding
docker ps --format "table {{.Names}}\t{{.Ports}}"

# 4. Test direct service access
curl http://localhost:<port>
```

### Nginx 502 Error

```bash
# 1. Verify upstream services are running
curl http://localhost:3000   # Landing
curl http://localhost:18789  # Gateway

# 2. Check nginx configuration
docker-compose exec nginx nginx -t

# 3. View nginx error logs
docker-compose logs nginx

# 4. Check nginx upstream configuration
docker-compose exec nginx cat /etc/nginx/conf.d/landing.conf
```

### Port Conflicts

```bash
# Check which process is using a port
lsof -i :80
lsof -i :3000
lsof -i :18789

# Kill process using port (if needed)
kill -9 <PID>
```

### Health Check Failures

Health checks have a 40-second start period. If showing "unhealthy":
1. Wait 40-60 seconds after container start
2. Check if wget is available in container: `docker exec <container> which wget`
3. Test health check manually: `docker exec <container> wget --quiet --tries=1 --spider http://localhost:<port>`

## Deployment

### Production (GCE)

```bash
# Deploy to Google Compute Engine
cd deployments/gce
./deploy.sh

# First time setup
./quick-setup.sh
./deploy.sh --setup --build
```

**Management Scripts:**
- `deployments/gce/scripts/start.sh [service]` - Start services
- `deployments/gce/scripts/stop.sh [service]` - Stop services
- `deployments/gce/scripts/restart.sh [service]` - Restart services
- `deployments/gce/scripts/logs.sh [service] [-f]` - View logs
- `deployments/gce/scripts/status.sh` - Check health

### Local Development

```bash
# Full stack
./start-all.sh

# Hybrid mode (Nginx + Next.js dev server)
cd deployments/local
./scripts/dev.sh
```

See `DEPLOYMENT.md` for comprehensive deployment documentation.

## Important Notes

### Security
- Change all default passwords in `.env` before production
- Use SSL certificates in production (place in `nginx/ssl/`)
- Configure firewall rules for production servers
- Monitor access logs regularly

### Performance
- Containers have health checks with 40s start period
- Wait for services to become healthy before testing
- Use `docker-compose logs` to debug startup issues

### DNS Configuration
Domain names must point to server IP:
- `agents.ddns.net` → Server IP
- `openclaw.agents.ddns.net` → Server IP
- `assistant.agents.ddns.net` → Server IP

### Environment Variables
Critical environment variables in `.env`:
- Database passwords (MongoDB, PostgreSQL, Redis)
- Google OAuth credentials (for assistant portal)
- NextAuth secret
- Service ports

## Documentation Standards

### docs/ Directory Structure

The `/Users/lps/server/docs` directory contains technical documentation following these standards:

**Directory Layout:**
```
docs/
├── README.md                # Documentation index
├── ARCHITECTURE.md          # System architecture and design
├── API-REFERENCE.md         # API documentation
└── backup/                  # Archived documentation versions
```

### Documentation Rules

#### File Organization

1. **Primary Documentation**: Keep in root `docs/` directory
   - `README.md` - Documentation index and navigation
   - `ARCHITECTURE.md` - System architecture, diagrams, design decisions
   - `API-REFERENCE.md` - Complete API documentation
   - Add new primary docs as needed

2. **Backup/Archive**: Use `docs/backup/` for:
   - Old versions of updated documents
   - Deprecated documentation
   - Historical reference material
   - Migration from root to organized structure

#### Documentation Standards

**Format Requirements:**
- All documentation MUST be in Markdown (.md)
- Use GitHub-flavored Markdown syntax
- Include table of contents for documents > 200 lines
- Use code blocks with language specification
- Include examples for all concepts

**Naming Conventions:**
- UPPERCASE for root-level docs (e.g., `ARCHITECTURE.md`, `API-REFERENCE.md`)
- Descriptive, hyphenated names (e.g., `deployment-guide.md`)
- Prefix with category for grouped docs (e.g., `api-gateway.md`, `api-services.md`)

**Content Standards:**
- **Headers**: Use ATX-style headers (`#`, `##`, `###`)
- **Code Examples**: Always include working examples with proper syntax highlighting
- **Links**: Use relative paths for internal documentation
- **Diagrams**: Use ASCII art, Mermaid, or linked images
- **Dates**: Include "Last Updated: YYYY-MM-DD" at bottom of each document
- **Version**: Include version number if applicable

**Required Sections:**
1. Title and brief description
2. Table of contents (if > 200 lines)
3. Quick start or overview
4. Detailed content
5. Examples (where applicable)
6. Related documentation links
7. Last updated date

#### API Documentation Standards

**API-REFERENCE.md Structure:**
```markdown
# API Reference

## Overview
Brief description of the API

## Base URL
Production and development URLs

## Authentication
How to authenticate

## Endpoints

### GET /endpoint
- Description
- Parameters
- Request example
- Response example
- Error codes

## Error Handling
Standard error format

## Rate Limiting
Rate limit policies
```

**API Examples:**
- Include curl examples
- Show request headers
- Show full response body
- Include error scenarios
- Document all query parameters

#### Architecture Documentation Standards

**ARCHITECTURE.md Structure:**
```markdown
# Architecture

## System Overview
High-level description

## Architecture Diagram
Visual representation

## Components
Detailed component descriptions

## Data Flow
How data flows through the system

## Technology Stack
Technologies used

## Design Decisions
Why certain choices were made

## Scalability
How system scales

## Security Considerations
Security architecture
```

**Diagrams:**
- Use ASCII art for simple diagrams
- Use Mermaid for complex diagrams
- Include both logical and physical architecture
- Show component interactions
- Document network topology

#### Writing Style

**Technical Writing:**
- Be concise and precise
- Use active voice
- Write in present tense
- Avoid jargon where possible
- Define technical terms on first use
- Use bullet points for lists
- Use numbered lists for sequences

**Code Examples:**
```bash
# Always include:
# 1. Comment explaining what the code does
# 2. Expected output
# 3. Error handling examples

# Good example
$ curl -H "Authorization: Bearer token" https://api.example.com/status
# Expected: {"status": "healthy"}

# Error case
$ curl https://api.example.com/status
# Error: {"error": "Authentication required"}
```

**Best Practices:**
- ✅ Include working examples
- ✅ Show both success and error cases
- ✅ Link to related documentation
- ✅ Keep examples up-to-date
- ✅ Test examples before committing
- ❌ Don't include outdated information
- ❌ Don't use broken links
- ❌ Don't duplicate content (use links instead)

#### Documentation Maintenance

**When to Update:**
- After adding new features
- When APIs change
- After architecture changes
- When fixing bugs that affect documented behavior
- During security updates

**Update Process:**
1. Update relevant documentation
2. Move old version to `docs/backup/` if major changes
3. Update "Last Updated" date
4. Update version number if applicable
5. Test all examples
6. Update links in other docs

**Review Checklist:**
- [ ] All code examples tested
- [ ] All links work
- [ ] Screenshots/diagrams current
- [ ] No placeholder content
- [ ] Grammar and spelling checked
- [ ] Table of contents updated (if applicable)
- [ ] Related docs linked
- [ ] Date updated

#### Special Documentation

**Security Documentation:**
- Store in root directory (e.g., `SECURITY.md`)
- Include vulnerability disclosure policy
- Document authentication/authorization
- Include security best practices
- List known limitations

**Migration Guides:**
- Store in root or `docs/` directory
- Include version information
- Provide step-by-step instructions
- Document breaking changes
- Include rollback procedures

**Deployment Documentation:**
- Store in root or `docs/` directory
- Environment-specific instructions
- Configuration examples
- Troubleshooting guides
- Health check procedures

#### Documentation Tools

**Markdown Linters:**
```bash
# Install markdownlint
npm install -g markdownlint-cli

# Lint documentation
markdownlint docs/**/*.md
```

**Link Checkers:**
```bash
# Check for broken links
npx markdown-link-check docs/**/*.md
```

**Table of Contents Generation:**
```bash
# Generate TOC
npx markdown-toc -i docs/ARCHITECTURE.md
```

### Documentation Index

The `docs/README.md` serves as the central index:

**Required Sections:**
1. **Overview** - What's documented
2. **Quick Links** - Most commonly used docs
3. **By Category** - Organized documentation list
4. **For Different Audiences** - Grouped by user type (developer, ops, manager)
5. **Contributing** - How to update documentation

**Example Structure:**
```markdown
# Documentation

## Quick Links
- [Architecture](ARCHITECTURE.md) - System design
- [API Reference](API-REFERENCE.md) - API documentation

## By Category

### Development
- Development workflow
- Testing guides
- Debugging

### Deployment
- Production deployment
- Environment configuration
- Monitoring

### Operations
- Troubleshooting
- Backup/restore
- Scaling
```

### Documentation Workflow

**Creating New Documentation:**
1. Determine if it's primary (root/docs) or reference (docs/backup)
2. Create file with proper naming convention
3. Follow template for document type
4. Include all required sections
5. Add to docs/README.md index
6. Test all examples
7. Submit for review

**Updating Existing Documentation:**
1. Read current version
2. Archive to docs/backup/ if major changes
3. Make updates
4. Test examples
5. Update date and version
6. Update related docs if needed

**Archiving Old Documentation:**
```bash
# Move to backup with timestamp
mv docs/OLD-GUIDE.md docs/backup/OLD-GUIDE-20260207.md

# Or keep generic name if it's the canonical old version
mv docs/OLD-GUIDE.md docs/backup/OLD-GUIDE.md
```

## Additional Resources

### Root-Level Documentation
- **README.md** - Project overview and quick start
- **SECURITY.md** - Security guide and vulnerability fixes
- **DEPLOYMENT-CONFIGURATION.md** - Deployment configuration guide
- **PRIVACY-AND-SANITIZATION.md** - Privacy and sanitization guide
- **FINAL-CONFIGURATION-SUMMARY.md** - Complete configuration summary

### Technical Documentation
- **docs/ARCHITECTURE.md** - System architecture and design
- **docs/API-REFERENCE.md** - Complete API documentation
- **docs/README.md** - Documentation index

### Deployment
- **DEPLOYMENT.md** - Deployment guide
- **deployments/gce/README.md** - GCE deployment
- **deployments/local/README.md** - Local development

### Other Resources
- **CLAUDE.md** - This file (developer guide)
- **CONTRIBUTING.md** - Contributing guidelines
- **SERVICES.md** - Services documentation
- **wiki/** - Additional wiki content

---

*Project: OpenClaw DevOps*
*Location: /Users/lps/server*
*Updated: 2026-02-07*
