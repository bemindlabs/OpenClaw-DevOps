---
title: Development Environment Setup
tags: [guide, development, setup]
created: 2026-02-07
updated: 2026-02-07
---

# Development Environment Setup

Complete guide for setting up your local development environment for OpenClaw DevOps.

## Prerequisites

### Required Software

| Tool | Version | Purpose |
|------|---------|---------|
| **Git** | Latest | Version control |
| **Node.js** | 20.0+ | JavaScript runtime |
| **pnpm** | 9.0+ | Package manager |
| **Docker** | 24.0+ | Containerization |
| **Docker Compose** | 2.0+ | Multi-container orchestration |

### Optional Tools

| Tool | Purpose |
|------|---------|
| **VS Code** | Recommended IDE |
| **Postman/Insomnia** | API testing |
| **MongoDB Compass** | MongoDB GUI |
| **pgAdmin** | PostgreSQL GUI |
| **RedisInsight** | Redis GUI |

## Installation

### 1. Install Node.js

**macOS (using Homebrew):**
```bash
brew install node@20
```

**Ubuntu/Debian:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Windows:**
Download from [nodejs.org](https://nodejs.org/)

**Verify:**
```bash
node --version  # Should show v20.x.x
npm --version
```

### 2. Install pnpm

```bash
# Using npm
npm install -g pnpm@9

# Or using standalone script
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Verify
pnpm --version  # Should show 9.x.x
```

### 3. Install Docker

**macOS:**
Download [Docker Desktop](https://www.docker.com/products/docker-desktop)

**Ubuntu:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**Windows:**
Download [Docker Desktop](https://www.docker.com/products/docker-desktop)

**Verify:**
```bash
docker --version
docker-compose --version
```

### 4. Configure Docker Resources

**Docker Desktop Settings:**
- **Memory**: Minimum 8GB, recommended 12GB
- **CPUs**: Minimum 4, recommended 6
- **Disk**: 20GB+

## Project Setup

### Clone Repository

```bash
# Clone
git clone https://github.com/openclaw/devops.git
cd devops

# Or with SSH
git clone git@github.com:openclaw/devops.git
cd devops
```

### Install Dependencies

```bash
# Install all workspace dependencies
pnpm install

# This will:
# - Install root dependencies
# - Install dependencies for all workspaces
# - Set up git hooks (husky)
```

### Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit with your values
nano .env  # or vim, code, etc.
```

**Required Variables:**
```env
# Databases
MONGODB_ROOT_PASSWORD=your-secure-password
POSTGRES_PASSWORD=your-secure-password
REDIS_PASSWORD=your-secure-password

# Application
NODE_ENV=development
```

**Generate Secure Passwords:**
```bash
./scripts/generate-passwords.sh
```

## Development Modes

### Mode 1: Full Stack (Docker)

Run everything in Docker containers:

```bash
# Start all services
docker-compose -f docker-compose.full.yml up -d

# View logs
docker-compose -f docker-compose.full.yml logs -f

# Stop all services
docker-compose -f docker-compose.full.yml down
```

**Ports:**
- Nginx: 80
- Landing: 3000
- Gateway: 18789
- MongoDB: 27017
- PostgreSQL: 5432
- Redis: 6379
- Grafana: 3001
- Prometheus: 9090

### Mode 2: Hybrid (Docker + Local Dev)

Run infrastructure in Docker, apps locally:

**Terminal 1 - Infrastructure:**
```bash
# Start databases & monitoring
docker-compose -f docker-compose.full.yml up -d \
  mongodb postgres redis prometheus grafana
```

**Terminal 2 - Landing Page:**
```bash
pnpm dev:landing
# Runs on http://localhost:3000 with hot reload
```

**Terminal 3 - Gateway:**
```bash
pnpm dev:gateway
# Runs on http://localhost:18789 with hot reload
```

**Terminal 4 - Assistant:**
```bash
pnpm dev:assistant
# Runs on http://localhost:5555 with hot reload
```

### Mode 3: Minimal (Basic Services)

Run only essential services:

```bash
# Start basic stack
./start-all.sh

# Includes:
# - Nginx
# - Landing
# - Gateway
```

## IDE Setup

### VS Code (Recommended)

**Install Extensions:**
```bash
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-azuretools.vscode-docker
```

**Workspace Settings** (`.vscode/settings.json`):
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"]
  ]
}
```

**Debug Configuration** (`.vscode/launch.json`):
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Landing",
      "cwd": "${workspaceFolder}/apps/landing",
      "runtimeExecutable": "pnpm",
      "runtimeArgs": ["dev"],
      "console": "integratedTerminal"
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Gateway",
      "cwd": "${workspaceFolder}/apps/openclaw-gateway",
      "runtimeExecutable": "pnpm",
      "runtimeArgs": ["dev"],
      "console": "integratedTerminal"
    }
  ]
}
```

## Development Workflow

### 1. Start Development

```bash
# Update main branch
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Start development servers
pnpm dev:landing  # or dev:gateway, dev:assistant
```

### 2. Make Changes

```bash
# Code changes trigger hot reload automatically
# Check console for errors
```

### 3. Test Changes

```bash
# Lint code
pnpm lint:all

# Type check
pnpm typecheck

# Build to verify
pnpm build:all
```

### 4. Commit Changes

```bash
# Stage changes
git add .

# Commit (pre-commit hooks run automatically)
git commit -m "feat: add new feature"

# If pre-commit fails, fix issues and try again
```

### 5. Push Changes

```bash
# Push (pre-push hooks run build validation)
git push origin feature/your-feature-name

# Create pull request on GitHub
```

## Useful Commands

### pnpm Workspace Commands

```bash
# Install dependency to specific app
pnpm --filter @openclaw/landing add [package]

# Run command in all workspaces
pnpm -r [command]

# Run command in specific workspace
pnpm --filter @openclaw/landing [command]

# List all workspaces
pnpm list -r --depth 0
```

### Docker Commands

```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs -f [service]

# Restart service
docker-compose restart [service]

# Rebuild service
docker-compose build [service]

# Shell access
docker-compose exec [service] sh

# Clean up
docker-compose down -v
docker system prune -a
```

### Database Access

```bash
# MongoDB
docker-compose exec mongodb mongosh -u admin -p [password]

# PostgreSQL
docker-compose exec postgres psql -U postgres_admin -d openclaw

# Redis
docker-compose exec redis redis-cli -a [password]
```

## Troubleshooting

### Port Already in Use

```bash
# Find process using port
lsof -i :3000

# Kill process
kill -9 [PID]
```

### Dependencies Out of Sync

```bash
# Clean and reinstall
pnpm clean
pnpm install
```

### Docker Issues

```bash
# Restart Docker Desktop
# Or restart Docker daemon

# Clean Docker
docker system prune -a --volumes
```

### Hot Reload Not Working

```bash
# Ensure watching is enabled
# Check package.json scripts include --watch or equivalent

# For Docker volumes, ensure bind mounts configured:
volumes:
  - ./apps/landing:/app
  - /app/node_modules
```

## Performance Tips

### Speed Up pnpm

```bash
# Use local cache
pnpm config set store-dir ~/.pnpm-store

# Enable shamefully-hoist for faster installs
pnpm config set shamefully-hoist true
```

### Speed Up Docker

```bash
# Use BuildKit
export DOCKER_BUILDKIT=1

# Prune regularly
docker system prune -a --volumes --filter "until=24h"
```

## Next Steps

- Read [Contributing Guide](../CONTRIBUTING.md)
- Review [Architecture Overview](../Architecture-Overview.md)
- Check [Community Guidelines](../COMMUNITY.md)
- Explore [Wiki Documentation](../Home.md)

---

**Last Updated:** 2026-02-07
