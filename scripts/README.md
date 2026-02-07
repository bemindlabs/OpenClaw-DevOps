# OpenClaw DevOps - Scripts

This directory contains utility scripts for managing the OpenClaw DevOps platform.

## Available Scripts

### 🎯 onboarding.sh
**Interactive setup wizard for first-time configuration**

Guides users through complete system setup including:
- Prerequisites validation
- Environment configuration
- Domain setup
- Security & password generation
- OAuth configuration
- Optional services
- Installation & startup

**Usage:**
```bash
# Via Makefile (recommended)
make onboarding

# Direct execution
./scripts/onboarding.sh
```

**Features:**
- ✅ Step-by-step guided setup
- ✅ Input validation
- ✅ Smart defaults
- ✅ Automatic backups
- ✅ Colored terminal UI
- ✅ Skip options for each step

---

### 🔐 generate-passwords.sh
**Secure password generator for all services**

Automatically generates cryptographically secure passwords for:
- MongoDB (root and user)
- PostgreSQL
- Redis
- n8n (password and encryption key)
- Grafana
- NextAuth secret
- Gateway authentication token
- Google OAuth secret

**Usage:**
```bash
# Via Makefile (recommended)
make security-setup

# Direct execution
./scripts/generate-passwords.sh
```

**Features:**
- 32+ character passwords
- Base64 and hex token generation
- Automatic .env backup
- Updates .env in-place

---

### 🚀 start-databases.sh
**Start database services only**

Starts MongoDB, PostgreSQL, and Redis containers without other services.

**Usage:**
```bash
./scripts/start-databases.sh
```

---

### 📊 start-monitoring.sh
**Start monitoring stack only**

Starts Prometheus, Grafana, and related exporters.

**Usage:**
```bash
./scripts/start-monitoring.sh
```

---

### 🏗️ start-full-stack.sh
**Start all services including databases and monitoring**

Convenience script to start the complete platform.

**Usage:**
```bash
./scripts/start-full-stack.sh
```

---

### ✅ verify-security-fixes.sh
**Verify security configurations**

Checks all security fixes are properly implemented:
- Authentication endpoints
- CORS configuration
- OAuth domain whitelist
- Password strength
- Environment variables

**Usage:**
```bash
# Via Makefile (recommended)
make security-verify

# Direct execution
./scripts/verify-security-fixes.sh
```

---

### 🧹 sanitize-deployment-refs.sh
**Sanitize deployment-specific references**

Removes real IP addresses, domains, and usernames from code before sharing.

**Usage:**
```bash
# Via Makefile (recommended)
make sanitize

# Direct execution
./scripts/sanitize-deployment-refs.sh
```

**Use Cases:**
- Before sharing code publicly
- Creating templates
- Open source releases
- Documentation examples

---

### 🧼 dev-clean.sh
**Clean development artifacts**

Removes temporary files and caches from development:
- `.next` directories
- `dist` directories
- Build caches
- Temporary files

**Usage:**
```bash
# Via Makefile (recommended)
make dev

# Direct execution (automatically called by make dev)
./scripts/dev-clean.sh
```

---

## Script Conventions

### Exit Codes
- `0` - Success
- `1` - General error
- Other codes may be used for specific errors

### Colors
All scripts use consistent color coding:
- 🔵 **Blue** - Headers and sections
- 🟢 **Green** - Success messages
- 🟡 **Yellow** - Warnings and prompts
- 🔴 **Red** - Errors
- 🔷 **Cyan** - Information
- 🟣 **Magenta** - Special highlights

### Backup Strategy
Scripts that modify files create backups:
- Format: `<filename>.backup.<timestamp>`
- Location: `backups/` directory (if applicable)
- Timestamp: `YYYYMMDD-HHMMSS`

### Environment Variables
Scripts read from `.env` file and may set:
- `NODE_ENV` - Runtime environment
- Service-specific credentials
- Feature flags

### Error Handling
All scripts use `set -e` for automatic error handling:
- Any command failure stops execution
- Errors are clearly reported
- Safe rollback when possible

## Development Guidelines

### Adding New Scripts

1. **Create the script:**
   ```bash
   touch scripts/new-script.sh
   chmod +x scripts/new-script.sh
   ```

2. **Use the template:**
   ```bash
   #!/bin/bash
   # OpenClaw DevOps - Script Name
   # Brief description

   set -e

   # Colors
   BLUE='\033[0;34m'
   GREEN='\033[0;32m'
   YELLOW='\033[1;33m'
   RED='\033[0;31m'
   NC='\033[0m'

   # Your script logic here
   ```

3. **Add to Makefile:**
   ```makefile
   new-command: ## Description of command
       @chmod +x scripts/new-script.sh
       @./scripts/new-script.sh
   ```

4. **Document it:**
   - Add section to this README
   - Update CLAUDE.md if relevant
   - Add usage examples

### Best Practices

**DO:**
- ✅ Use consistent color coding
- ✅ Validate inputs
- ✅ Provide helpful error messages
- ✅ Create backups before modifications
- ✅ Use `set -e` for error handling
- ✅ Add usage examples in comments
- ✅ Test on macOS and Linux

**DON'T:**
- ❌ Modify files without backup
- ❌ Use destructive operations without confirmation
- ❌ Hardcode passwords or secrets
- ❌ Assume file locations
- ❌ Skip error checking
- ❌ Use platform-specific commands without alternatives

### Testing Scripts

```bash
# Test script syntax
bash -n scripts/script-name.sh

# Dry run (if supported)
DRY_RUN=1 ./scripts/script-name.sh

# Test with sample data
# Create test environment
mkdir -p test-env
cp .env.example test-env/.env
cd test-env
../scripts/script-name.sh
```

## Troubleshooting

### Script Won't Execute
```bash
# Make executable
chmod +x scripts/script-name.sh

# Check shebang
head -1 scripts/script-name.sh
# Should output: #!/bin/bash
```

### Permission Denied
```bash
# Check ownership
ls -la scripts/script-name.sh

# Fix ownership
sudo chown $USER:$USER scripts/script-name.sh
```

### Command Not Found
```bash
# Check if command exists
which command-name

# Install missing dependencies
# macOS
brew install command-name

# Linux
apt-get install command-name
```

### .env Not Found
```bash
# Create from example
cp .env.example .env

# Or run onboarding
make onboarding
```

## Related Documentation

- [CLAUDE.md](/CLAUDE.md) - Developer guide
- [DEPLOYMENT.md](/DEPLOYMENT.md) - Deployment instructions
- [SECURITY.md](/SECURITY.md) - Security best practices
- [Makefile](/Makefile) - Build automation

---

*Last Updated: 2026-02-07*
