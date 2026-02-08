# Security Scanning Agents

This document describes the automated security scanning agents used in the OpenClaw DevOps platform.

## Overview

The project uses two primary security scanning agents:

1. **Trivy** - Comprehensive vulnerability scanner
2. **Semgrep** - Static code analysis tool

These agents work together to provide multi-layered security analysis across the entire application stack.

## Trivy Agent

### Description

[Trivy](https://github.com/aquasecurity/trivy) is an all-in-one security scanner developed by Aqua Security. It's a comprehensive tool that finds vulnerabilities, misconfigurations, secrets, and license issues.

### Capabilities

**Vulnerability Detection:**

- Operating system packages (Alpine, RHEL, CentOS, Ubuntu, Debian, etc.)
- Application dependencies (npm, pip, gem, maven, go modules, etc.)
- Language libraries (Node.js, Python, Ruby, Java, Go, Rust, etc.)

**Secret Detection:**

- API keys (AWS, Google, GitHub, etc.)
- Private keys and certificates
- Database credentials
- OAuth tokens
- Generic secrets

**Configuration Scanning:**

- Dockerfile best practices
- Kubernetes manifests
- Terraform/IaC files
- Docker Compose configurations

**SBOM Generation:**

- CycloneDX format
- SPDX format
- Software Bill of Materials

### Configuration

**Location:** `trivy.yaml`, `.trivy-secret.yaml`, `.trivyignore`

**Key Settings:**

```yaml
# Severity levels
severity: [CRITICAL, HIGH, MEDIUM, LOW]

# Scan types
scanner: [vuln, secret, misconfig]

# Skip patterns
skip-files:
  - node_modules/**
  - .next/**
  - dist/**
```

### Usage Patterns

**Filesystem Scan:**

```bash
trivy fs --config trivy.yaml .
```

**Docker Image Scan:**

```bash
trivy image openclaw-landing:latest
```

**Secret Scan:**

```bash
trivy fs --scanners secret .
```

**Configuration Scan:**

```bash
trivy config .
```

### Integration Points

1. **CI/CD Pipeline:**
   - `.github/workflows/security.yml`
   - Runs on push, PR, and daily schedule
   - Uploads SARIF to GitHub Security

2. **Local Development:**
   - `scripts/security-scan.sh`
   - `make security-trivy`
   - `pnpm security:trivy`

3. **Pre-commit Hooks (Optional):**
   - `.husky/pre-commit` (secret scanning)
   - `.husky/pre-push` (vulnerability scanning)

### Output Formats

- **Table** - Human-readable terminal output
- **JSON** - Machine-readable for automation
- **SARIF** - GitHub Security integration
- **CycloneDX/SPDX** - SBOM formats

### Performance

- **Database Updates:** Automatic on first run, cached locally
- **Scan Speed:** Fast (seconds for most repos)
- **Parallel Scanning:** Supports concurrent scans
- **Incremental:** Can scan only changed files

---

## Semgrep Agent

### Description

[Semgrep](https://semgrep.dev/) is a fast, open-source static analysis tool that finds bugs, detects security vulnerabilities, and enforces code standards. It uses pattern matching with a simple syntax that feels like grep but for code.

### Capabilities

**Security Analysis:**

- OWASP Top 10 vulnerabilities
- XSS (Cross-Site Scripting)
- SQL Injection
- Command Injection
- Path Traversal
- Authentication bypasses
- Insecure cryptography

**Framework-Specific Rules:**

- JavaScript/TypeScript patterns
- React/Next.js security
- Node.js best practices
- Express.js vulnerabilities
- Docker security

**Code Quality:**

- Antipatterns
- Performance issues
- Best practice violations
- Code smells

**Secret Detection:**

- Hardcoded credentials
- API keys in code
- Tokens and passwords
- Environment variable leaks

### Configuration

**Location:** `.semgrep.yml`, `.semgrepignore`

**Rule Sets:**

```yaml
rules:
  - https://semgrep.dev/p/security-audit
  - https://semgrep.dev/p/secrets
  - https://semgrep.dev/p/owasp-top-ten
  - https://semgrep.dev/p/javascript
  - https://semgrep.dev/p/typescript
  - https://semgrep.dev/p/react
  - https://semgrep.dev/p/nextjs
  - https://semgrep.dev/p/nodejs
  - https://semgrep.dev/p/express
  - https://semgrep.dev/p/docker
```

### Usage Patterns

**Security Audit:**

```bash
semgrep scan --config auto --config p/security-audit
```

**Specific Vulnerability Types:**

```bash
# XSS detection
semgrep scan --config p/xss

# SQL injection
semgrep scan --config p/sql-injection

# Secret detection
semgrep scan --config p/secrets
```

**Auto-fix:**

```bash
semgrep scan --config auto --autofix
```

### Integration Points

1. **CI/CD Pipeline:**
   - `.github/workflows/security.yml`
   - Runs comprehensive rule sets
   - Uploads SARIF to GitHub Security

2. **Local Development:**
   - `scripts/security-scan.sh`
   - `make security-semgrep`
   - `pnpm security:semgrep`

3. **IDE Integration:**
   - VS Code extension available
   - Real-time code analysis
   - Inline fix suggestions

### Output Formats

- **Text** - Terminal-friendly output
- **JSON** - Structured findings
- **SARIF** - GitHub Security integration
- **GitLab SAST** - GitLab integration
- **JUnit XML** - CI integration

### Performance

- **Speed:** Very fast (optimized parser)
- **Incremental:** Scans only changed files in CI
- **Language Support:** 30+ languages
- **Custom Rules:** Easy to write custom patterns

---

## Agent Coordination

### Complementary Strengths

**Trivy excels at:**

- Dependency vulnerabilities
- Container image scanning
- IaC misconfigurations
- License compliance
- SBOM generation

**Semgrep excels at:**

- Custom code patterns
- Framework-specific issues
- Complex security logic
- API misuse
- Business logic flaws

### Combined Workflow

```
┌─────────────────────────────────────────┐
│         Developer Commits Code          │
└─────────────┬───────────────────────────┘
              │
              ▼
    ┌─────────────────────┐
    │  Pre-commit Hooks   │
    │  (Optional)         │
    │  • Trivy secrets    │
    └─────────┬───────────┘
              │
              ▼
    ┌─────────────────────┐
    │    Git Push         │
    └─────────┬───────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│         GitHub Actions Trigger          │
└─────────┬───────────────────┬───────────┘
          │                   │
          ▼                   ▼
    ┌──────────┐        ┌──────────┐
    │  Trivy   │        │ Semgrep  │
    │  Agent   │        │  Agent   │
    └────┬─────┘        └─────┬────┘
         │                    │
         ├─ Filesystem        ├─ Code Analysis
         ├─ Secrets           ├─ OWASP Top 10
         ├─ Config            ├─ Best Practices
         └─ Docker Images     └─ Secrets
              │                    │
              ▼                    ▼
    ┌──────────────────────────────────┐
    │    SARIF Upload to GitHub        │
    └──────────┬───────────────────────┘
               │
               ▼
    ┌──────────────────────┐
    │  Security Alerts     │
    │  • Critical          │
    │  • High              │
    │  • Medium            │
    │  • Low               │
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │  Developer Review    │
    │  & Remediation       │
    └──────────────────────┘
```

### Scanning Schedule

| Event            | Trivy              | Semgrep         | Scope              |
| ---------------- | ------------------ | --------------- | ------------------ |
| **Local Dev**    | Manual             | Manual          | Developer choice   |
| **Pre-commit**   | Optional (secrets) | -               | Changed files      |
| **Pre-push**     | Optional           | Optional        | Full repo          |
| **Pull Request** | ✅ Full scan       | ✅ Full scan    | All files          |
| **Push to Main** | ✅ + Docker        | ✅ Full scan    | All files + images |
| **Daily**        | ✅ + Docker        | ✅ Full scan    | Complete audit     |
| **Release**      | ✅ + SBOM          | ✅ + compliance | Full + artifacts   |

---

## Agent Configuration Reference

### Trivy Configuration Files

**trivy.yaml:**

- Main configuration file
- Scanner settings
- Severity levels
- Skip patterns
- Output formats

**.trivy-secret.yaml:**

- Custom secret detection rules
- API key patterns
- Token formats
- Exception patterns

**.trivyignore:**

- CVE exceptions
- False positive suppressions
- Temporary ignores
- Package-specific rules

### Semgrep Configuration Files

**.semgrep.yml:**

- Rule set configuration
- Path includes/excludes
- Output settings
- Performance tuning

**.semgrepignore:**

- File exclusions
- Directory exclusions
- Pattern matching
- Test file exclusions

---

## Best Practices

### For Developers

1. **Run locally before pushing:**

   ```bash
   make security-scan
   ```

2. **Review findings:**
   - Address CRITICAL and HIGH immediately
   - Schedule MEDIUM for next sprint
   - Evaluate LOW based on context

3. **Document exceptions:**
   - Add to `.trivyignore` with comments
   - Add to `.semgrepignore` with reason
   - Update security docs

4. **Keep tools updated:**

   ```bash
   # Update Trivy
   brew upgrade trivy

   # Update Semgrep
   pip3 install --upgrade semgrep
   ```

### For Security Teams

1. **Review GitHub Security tab weekly**
2. **Audit ignored vulnerabilities monthly**
3. **Update rule sets quarterly**
4. **Generate compliance reports for releases**

### For DevOps

1. **Monitor CI/CD scan performance**
2. **Tune scan timeouts if needed**
3. **Archive scan reports for compliance**
4. **Integrate with alerting systems**

---

## Troubleshooting

### Trivy Issues

**Problem:** Database update fails

```bash
# Solution: Clear cache and retry
rm -rf ~/.cache/trivy
trivy image --download-db-only
```

**Problem:** False positives

```bash
# Solution: Add to .trivyignore
echo "CVE-2024-12345  # Not applicable: feature not used" >> .trivyignore
```

**Problem:** Scan timeout

```yaml
# Solution: Increase timeout in trivy.yaml
timeout: 20m
```

### Semgrep Issues

**Problem:** Installation fails

```bash
# Solution: Use alternative method
brew install semgrep
# or
pip3 install --user semgrep
```

**Problem:** Too many findings

```bash
# Solution: Filter by severity
semgrep scan --config auto --severity ERROR
```

**Problem:** Performance issues

```yaml
# Solution: Adjust in .semgrep.yml
performance:
  max-memory: 8000
  jobs: 8
```

---

## Resources

### Official Documentation

- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Semgrep Documentation](https://semgrep.dev/docs/)

### Rule Registries

- [Trivy Policies](https://github.com/aquasecurity/trivy-policies)
- [Semgrep Registry](https://semgrep.dev/r)

### Community

- [Trivy GitHub](https://github.com/aquasecurity/trivy)
- [Semgrep Slack](https://go.semgrep.dev/slack)

### Project Documentation

- [SECURITY-SCANNING.md](SECURITY-SCANNING.md) - Complete scanning guide
- [SECURITY-QUICKSTART.md](SECURITY-QUICKSTART.md) - Quick reference
- [SECURITY.md](SECURITY.md) - Security documentation

---

**Last Updated:** 2026-02-08

**Version:** 1.0.0

**Maintained By:** OpenClaw DevOps Security Team
