# Changelog

All notable changes to the OpenClaw DevOps project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.1] - 2026-02-08

### Added

- Security scanning integration with Trivy and Semgrep
- GitHub Actions workflow for automated security scans
- Security scanning scripts (`scripts/security-scan.sh`, `scripts/install-security-tools.sh`)
- Makefile with convenient targets for development and security
- Comprehensive security documentation (`SECURITY-SCANNING.md`, `SECURITY-QUICKSTART.md`)
- AGENTS.md documenting security scanning agents
- Product backlog with 19 identified issues and improvements
- Pre-commit/pre-push hooks with optional security scanning

### Changed

- Updated README.md with security scanning section
- Updated SECURITY.md with continuous monitoring section
- Updated CLAUDE.md with security scanning workflow
- Updated .gitignore to exclude security reports
- Enhanced .husky hooks with security scanning options
- Reorganized documentation structure

### Fixed

- Documented authentication bypass vulnerability (pending fix)
- Documented API key exposure in logs (pending fix)
- Documented NextAuth configuration mismatch (pending fix)
- Identified 47 code quality and security issues in codebase scan

### Security

- Added Trivy for vulnerability scanning (dependencies, Docker images, secrets)
- Added Semgrep for static code analysis (OWASP Top 10, code patterns)
- Configured SARIF output for GitHub Security integration
- Implemented secret detection rules for API keys and credentials

---

## [0.0.1-beta] - 2026-02-07

### Added

- Multi-provider LLM support (OpenAI, Anthropic, Google AI, Moonshot)
- AI-powered Assistant Portal with chat interface
- Google OAuth authentication for admin portal
- Real-time service monitoring dashboard
- Docker Compose configurations for basic and full stack
- Nginx reverse proxy with rate limiting
- Prometheus and Grafana monitoring integration
- cAdvisor container metrics
- Landing page with Next.js 16 and React 19
- Gateway service with Express.js
- MongoDB, PostgreSQL, and Redis database support
- Kafka and Zookeeper messaging infrastructure
- n8n workflow automation integration
- GCE deployment scripts
- Interactive onboarding wizard (`make onboarding`)

### Changed

- Migrated to pnpm workspace monorepo structure
- Updated to Next.js 16 standalone build
- Implemented unified green & black design system
- Enhanced configuration documentation

### Security

- Added Bearer token authentication for Docker management API
- Implemented command injection prevention using spawn
- Added OAuth domain whitelist configuration
- Hardened CORS policy configuration
- Documented security best practices

---

## [0.1.0] - 2026-01-15

### Added

- Initial project structure
- Basic Docker Compose setup
- Landing page skeleton
- Gateway API foundation
- Database container configurations

---

## Release Notes

### Versioning Strategy

- **Major (X.0.0)**: Breaking changes, major architecture updates
- **Minor (0.X.0)**: New features, backward-compatible additions
- **Patch (0.0.X)**: Bug fixes, security patches, documentation updates

### Branch Strategy

- `main`: Stable releases
- `develop`: Active development
- `feature/*`: Feature branches
- `hotfix/*`: Critical fixes

### Migration Guides

Migration guides for breaking changes will be documented in the `docs/migrations/` directory when applicable.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on submitting changes.

When adding changelog entries:

1. Add entries under `[Unreleased]` section
2. Use categories: Added, Changed, Deprecated, Removed, Fixed, Security
3. Reference issue/PR numbers where applicable
4. Keep descriptions concise but informative

---

**Project:** OpenClaw DevOps
**Repository:** https://github.com/bemindlabs/OpenClaw-DevOps
**Last Updated:** 2026-02-08
