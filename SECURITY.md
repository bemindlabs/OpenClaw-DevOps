# Security Documentation

This document outlines security considerations, vulnerabilities addressed, and best practices for the OpenClaw DevOps platform.

## Security Fixes Applied

### 1. Docker Management API Authentication (HIGH)

**Vulnerability**: Unauthenticated Docker service control endpoints allowing anyone to start/stop/restart services.

**Fix Applied**:

- Added Bearer token authentication middleware (`apps/gateway/middleware/auth.js`)
- Protected all Docker management endpoints (`/api/services/:name/start`, `/stop`, `/restart`)
- Uses constant-time string comparison to prevent timing attacks
- Requires `GATEWAY_AUTH_TOKEN` environment variable

**Configuration**:

```bash
# Generate secure token
GATEWAY_AUTH_TOKEN=$(openssl rand -hex 32)

# Add to .env
GATEWAY_AUTH_TOKEN=your_generated_token_here
```

**Usage**:

```bash
# All Docker management API calls now require authentication
curl -X POST \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  https://openclaw.your-domain.com/api/services/nginx/restart
```

**Files Modified**:

- `apps/gateway/middleware/auth.js` (NEW)
- `apps/gateway/routes/services.js`
- `.env.example`

---

### 2. Command Injection Prevention (HIGH)

**Vulnerability**: `child_process.exec` with string interpolation allowed potential shell injection attacks.

**Fix Applied**:

- Replaced `exec()` with `spawn()` using argument arrays
- Added whitelist validation for allowed Docker Compose actions
- Removed hardcoded absolute paths (replaced with `process.cwd()`)
- Arguments passed as array elements (no shell interpretation)

**Before (Vulnerable)**:

```javascript
const cmd = `cd ${PROJECT_DIR} && docker-compose -f ${file} ${action} ${service}`;
exec(cmd, ...); // Shell interprets the entire command string
```

**After (Secure)**:

```javascript
const allowedActions = ['start', 'stop', 'restart', 'up', 'down'];
if (!allowedActions.includes(action)) throw new Error('Invalid action');

const args = ['-f', COMPOSE_FILE, action, serviceName];
spawn('docker-compose', args, { cwd: PROJECT_DIR }); // No shell interpolation
```

**Files Modified**:

- `apps/gateway/services/docker-manager.js`

---

### 3. OAuth Domain Whitelist (HIGH)

**Vulnerability**: `ALLOWED_OAUTH_DOMAINS` environment variable used but not defined, causing authentication bypass or denial of service.

**Fix Applied**:

- Added `ALLOWED_OAUTH_DOMAINS` to `.env.example` with clear documentation
- Default value: `your-domain.com` (must be changed for production)
- Comma-separated list format for multiple domains
- Proper handling in `auth.config.ts` already implemented

**Configuration**:

```bash
# Add to .env - only users with email from these domains can log in
ALLOWED_OAUTH_DOMAINS=your-domain.com,trusted-partner.com
```

**Files Modified**:

- `.env.example`

---

### 4. CORS Policy Hardening (MEDIUM)

**Vulnerability**: Default CORS policy of `origin: '*'` allowed requests from any origin, enabling CSRF attacks.

**Fix Applied**:

- Parse `CORS_ORIGIN` environment variable as comma-separated list of allowed origins
- Development default: `['http://localhost:3000', 'http://localhost:5555']`
- Production: Requires explicit configuration (no wildcard fallback)
- Applied to both Express CORS and Socket.IO

**Configuration**:

```bash
# Add to .env - list specific origins allowed to access the API
CORS_ORIGIN=https://assistant.your-domain.com,https://your-domain.com
```

**Before (Vulnerable)**:

```javascript
app.use(cors({ origin: '*' })); // Allows all origins
```

**After (Secure)**:

```javascript
const CORS_ORIGINS = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(',').map(origin => origin.trim())
  : (NODE_ENV === 'development' ? ['http://localhost:3000', ...] : []);

app.use(cors({
  origin: CORS_ORIGINS.length > 0 ? CORS_ORIGINS : false,
  credentials: true
}));
```

**Files Modified**:

- `apps/gateway/index.js`
- `.env.example`

---

### 5. Privileged Container Removal (MEDIUM)

**Vulnerability**: cAdvisor container ran with `privileged: true`, granting unnecessary full system access.

**Fix Applied**:

- Removed `privileged: true` flag
- Added specific capabilities: `SYS_ADMIN`, `SYS_PTRACE`
- Added security option: `apparmor:unconfined` (required for cgroup access)
- Principle of least privilege - only the capabilities cAdvisor needs

**Before (Vulnerable)**:

```yaml
cadvisor:
  privileged: true # Full system access
```

**After (Secure)**:

```yaml
cadvisor:
  cap_add:
    - SYS_ADMIN # Required for cgroup access only
    - SYS_PTRACE # Required for process monitoring only
  security_opt:
    - apparmor:unconfined # Required for cAdvisor
```

**Files Modified**:

- `docker-compose.full.yml`

---

## Security Configuration Checklist

### Pre-Deployment Security Steps

- [ ] **Generate Secure Passwords**

  ```bash
  cd /path/to/server
  ./scripts/generate-passwords.sh
  ```

- [ ] **Configure Authentication Tokens**

  ```bash
  # Gateway authentication
  GATEWAY_AUTH_TOKEN=$(openssl rand -hex 32)
  echo "GATEWAY_AUTH_TOKEN=$GATEWAY_AUTH_TOKEN" >> .env

  # NextAuth secret
  NEXTAUTH_SECRET=$(openssl rand -base64 32)
  echo "NEXTAUTH_SECRET=$NEXTAUTH_SECRET" >> .env
  ```

- [ ] **Configure CORS Origins**

  ```bash
  # Edit .env - replace with your actual domains
  CORS_ORIGIN=https://assistant.your-domain.com,https://your-domain.com
  ```

- [ ] **Configure OAuth Domain Whitelist**

  ```bash
  # Edit .env - only allow trusted email domains
  ALLOWED_OAUTH_DOMAINS=your-company.com,trusted-partner.com
  ```

- [ ] **Review File Permissions**

  ```bash
  chmod 600 .env
  chmod 700 scripts/*.sh
  ```

- [ ] **Enable Firewall Rules**
  - Only expose ports 80 (HTTP) and 443 (HTTPS) publicly
  - Keep all other ports (MongoDB, Redis, PostgreSQL, etc.) internal
  - Use VPC or private networks for inter-service communication

---

## API Authentication

### Gateway API Endpoints

All Docker service management endpoints now require authentication:

| Endpoint                      | Method | Auth Required | Description           |
| ----------------------------- | ------ | ------------- | --------------------- |
| `/api/services/status`        | GET    | No            | View service status   |
| `/api/services/list`          | GET    | No            | List valid services   |
| `/api/services/:name/status`  | GET    | No            | Single service status |
| `/api/services/:name/start`   | POST   | **Yes**       | Start service         |
| `/api/services/:name/stop`    | POST   | **Yes**       | Stop service          |
| `/api/services/:name/restart` | POST   | **Yes**       | Restart service       |

### Authentication Header Format

```http
Authorization: Bearer YOUR_GATEWAY_AUTH_TOKEN_HERE
```

### Example Authenticated Request

```bash
curl -X POST \
  -H "Authorization: Bearer $(grep GATEWAY_AUTH_TOKEN .env | cut -d '=' -f2)" \
  https://openclaw.your-domain.com/api/services/nginx/restart
```

### Response Codes

- `200 OK` - Request successful
- `401 Unauthorized` - Missing or invalid authentication token
- `400 Bad Request` - Invalid service name
- `500 Internal Server Error` - Docker command failed

---

## OAuth Configuration

### Allowed Email Domains

Only users with email addresses from whitelisted domains can authenticate:

```bash
# .env configuration
ALLOWED_OAUTH_DOMAINS=your-company.com,partner-company.com
```

### Google OAuth Setup

1. **Create OAuth Credentials**:
   - Visit: https://console.cloud.google.com/apis/credentials
   - Create OAuth 2.0 Client ID
   - Authorized redirect URIs: `https://assistant.your-domain.com/api/auth/callback/google`

2. **Configure Environment**:

   ```bash
   GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=your-client-secret
   ALLOWED_OAUTH_DOMAINS=your-company.com
   ```

3. **Test Authentication**:
   - Visit: `https://assistant.your-domain.com/login`
   - Click "Sign in with Google"
   - Only emails from allowed domains will succeed

---

## CORS Configuration

### Allowed Origins

Configure which web origins can access the Gateway API:

```bash
# .env - comma-separated list of allowed origins
CORS_ORIGIN=https://assistant.your-domain.com,https://your-domain.com
```

### Development Mode

In development (`NODE_ENV=development`), localhost origins are automatically allowed:

- `http://localhost:3000` (Landing)
- `http://localhost:5555` (Assistant)

### Production Mode

In production (`NODE_ENV=production`), you **must** explicitly configure `CORS_ORIGIN`. No wildcard or default origins are allowed.

---

## Container Security

### cAdvisor Capabilities

cAdvisor requires specific Linux capabilities to access container metrics:

| Capability   | Purpose                     | Risk Level |
| ------------ | --------------------------- | ---------- |
| `SYS_ADMIN`  | Access cgroup filesystem    | Medium     |
| `SYS_PTRACE` | Monitor process information | Low        |

**Note**: While still privileged, this is significantly more secure than full `privileged: true` mode.

### Security Best Practices

1. **Network Isolation**: Use Docker networks to isolate services
2. **Read-Only Volumes**: Mount volumes as `:ro` when possible
3. **Non-Root Users**: Run containers as non-root users where applicable
4. **Image Scanning**: Scan images for vulnerabilities before deployment
5. **Minimal Base Images**: Use Alpine or distroless base images

---

## Environment Variable Security

### Sensitive Variables

Never commit these to version control:

- `GATEWAY_AUTH_TOKEN`
- `NEXTAUTH_SECRET`
- `GOOGLE_CLIENT_SECRET`
- `MONGO_INITDB_ROOT_PASSWORD`
- `POSTGRES_PASSWORD`
- `REDIS_PASSWORD`
- `N8N_BASIC_AUTH_PASSWORD`
- `GF_SECURITY_ADMIN_PASSWORD`

### Secure Storage Options

1. **Local Development**: Use `.env` file (already gitignored)
2. **Production**:
   - **Google Secret Manager** (for GCE/Cloud Run)
   - **HashiCorp Vault**
   - **AWS Secrets Manager**
   - **Kubernetes Secrets**

---

## Monitoring Security Events

### Log Analysis

Monitor logs for suspicious activity:

```bash
# Check for authentication failures
docker-compose logs gateway | grep "Authentication failed"

# Check for unauthorized access attempts
docker-compose logs gateway | grep "401"

# Monitor Docker service control operations
docker-compose logs gateway | grep "service.*restart\|start\|stop"
```

### Prometheus Alerts

Configure alerts for security events:

```yaml
# prometheus/alerts/security.yml
groups:
  - name: security
    rules:
      - alert: UnauthorizedAPIAccess
        expr: rate(http_requests_total{status="401"}[5m]) > 10
        annotations:
          summary: 'High rate of unauthorized API access attempts'

      - alert: DockerServiceManipulation
        expr: rate(docker_service_operations_total[5m]) > 5
        annotations:
          summary: 'Unusual Docker service control activity'
```

---

## Security Scanning & Continuous Monitoring

### Automated Security Scanning

The project includes comprehensive security scanning with **Trivy** and **Semgrep**:

**Trivy** scans for:

- Vulnerabilities in dependencies (npm, Docker images)
- Configuration misconfigurations (Docker, Kubernetes, IaC)
- Secret leaks (API keys, credentials, tokens)
- License compliance issues

**Semgrep** analyzes code for:

- OWASP Top 10 vulnerabilities
- Security antipatterns (XSS, SQL injection, command injection)
- Code quality issues
- Framework-specific vulnerabilities (React, Next.js, Express.js)

### Quick Start

```bash
# Install security scanning tools
make security-install

# Run all security scans
make security-scan

# Run specific scans
make security-trivy      # Vulnerability scanning
make security-semgrep    # Code analysis
make security-docker     # Docker image scanning
```

### CI/CD Integration

Security scans run automatically:

- ✅ On every push to main/develop
- ✅ On every pull request
- ✅ Daily at 2 AM UTC
- ✅ Manual workflow dispatch

Results are uploaded to **GitHub Security > Code scanning alerts**.

### Configuration Files

- `trivy.yaml` - Trivy configuration
- `.trivy-secret.yaml` - Secret detection rules
- `.trivyignore` - Vulnerability exceptions
- `.semgrep.yml` - Semgrep rules and configuration
- `.semgrepignore` - Files to exclude from scanning

### Severity Handling

| Severity     | Action Required | Timeline        |
| ------------ | --------------- | --------------- |
| **CRITICAL** | Immediate fix   | Within 24 hours |
| **HIGH**     | Prioritize fix  | Within 7 days   |
| **MEDIUM**   | Schedule fix    | Within 30 days  |
| **LOW**      | Consider fix    | As time permits |

### Security Scanning Workflow

1. **Development**: Run `make security-scan` before committing major changes
2. **Pre-commit** (optional): Enable in `.husky/pre-commit` for secret scanning
3. **Pre-push** (optional): Enable in `.husky/pre-push` for vulnerability scanning
4. **CI/CD**: Automated scans on GitHub Actions
5. **Review**: Check GitHub Security tab for findings
6. **Remediate**: Fix or document exceptions

### Documentation

For comprehensive security scanning documentation, see:

- **[SECURITY-SCANNING.md](SECURITY-SCANNING.md)** - Complete scanning guide
- **[SECURITY-QUICKSTART.md](SECURITY-QUICKSTART.md)** - Quick reference

### Pre-commit Security Checks (Optional)

Enable security scanning in git hooks:

```bash
# Edit .husky/pre-commit and uncomment the security scan section
# This will scan for secrets before every commit

# Edit .husky/pre-push and uncomment the security scan section
# This will scan for vulnerabilities before every push
```

---

## Security Disclosure

If you discover a security vulnerability in this project, please:

1. **Do not** open a public GitHub issue
2. Email security concerns to: [your-security-email]
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if available)

---

## Security Audit History

| Date       | Auditor                           | Findings                             | Status         |
| ---------- | --------------------------------- | ------------------------------------ | -------------- |
| 2026-02-08 | Automated Security Scanning Setup | Trivy + Semgrep integration          | ✅ Implemented |
| 2026-02-07 | Claude Code Security Review       | 5 vulnerabilities (3 HIGH, 2 MEDIUM) | ✅ Fixed       |

---

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
- [Next.js Security Headers](https://nextjs.org/docs/advanced-features/security-headers)

---

**Last Updated**: 2026-02-07
**Version**: 1.0.0
**Status**: All critical vulnerabilities addressed ✅
