# Security Scanning Quick Start

Quick reference for running security scans on the OpenClaw DevOps platform.

## Install Security Tools

```bash
# Option 1: Use the script
./scripts/install-security-tools.sh

# Option 2: Use Make
make security-install

# Option 3: Use pnpm
pnpm security:install
```

## Run Security Scans

### All Scans (Recommended)

```bash
./scripts/security-scan.sh --all
# or
make security-scan
# or
pnpm security:scan
```

### Specific Scans

```bash
# Trivy only (vulnerability scanning)
make security-trivy

# Semgrep only (code analysis)
make security-semgrep

# Docker images
make security-docker

# With autofix (Semgrep)
make security-fix
```

## Quick Commands

| Command                 | Description                   |
| ----------------------- | ----------------------------- |
| `make security-install` | Install Trivy and Semgrep     |
| `make security-scan`    | Run all security scans        |
| `make security-trivy`   | Run Trivy vulnerability scans |
| `make security-semgrep` | Run Semgrep code analysis     |
| `make security-docker`  | Scan Docker images            |
| `make security-fix`     | Auto-fix issues (Semgrep)     |

## View Results

- **Terminal:** Results display during scan
- **Reports:** Saved to `./security-reports/`
- **GitHub:** Security > Code scanning alerts (CI/CD)

## Common Options

```bash
# Custom severity
./scripts/security-scan.sh --all --severity CRITICAL,HIGH

# Custom report directory
./scripts/security-scan.sh --all --report ./my-reports

# Help
./scripts/security-scan.sh --help
```

## CI/CD Integration

Security scans run automatically on:

- ✅ Push to main/develop
- ✅ Pull requests
- ✅ Daily at 2 AM UTC
- ✅ Manual workflow dispatch

## Configuration Files

- `trivy.yaml` - Trivy configuration
- `.trivy-secret.yaml` - Secret scanning rules
- `.trivyignore` - Ignore specific vulnerabilities
- `.semgrep.yml` - Semgrep configuration
- `.semgrepignore` - Exclude files from scanning

## Need Help?

See [SECURITY-SCANNING.md](./SECURITY-SCANNING.md) for comprehensive documentation.
