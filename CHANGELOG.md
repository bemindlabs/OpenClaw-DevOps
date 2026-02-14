# Changelog

All notable changes to the OpenClaw DevOps platform will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Container privacy implementation - only Nginx exposes ports externally
- Centralized port management system (32100-32199 range)
- Automated port migration scripts (validate-ports.sh, update-ports.js, allocate-port.sh)
- Comprehensive validation and testing reports
- CODE_OF_CONDUCT.md in root directory for GitHub standards
- .vscode workspace configurations
- .github/CODEOWNERS file

### Changed
- Migrated all services from scattered ports to 32100-32199 range
- Updated docker-compose.yml to use internal network with bridge driver
- All services except Nginx now use `expose:` instead of `ports:`
- Updated nginx upstream configurations for new port scheme

### Security
- Implemented container isolation - only Nginx accessible externally
- Added openclaw-internal Docker network for service communication
- Enhanced security documentation with firewall requirements

## [0.0.1] - 2026-02-09

### Added
- Automated Portainer deployment script
- Portainer domain configuration to GCE deployment
- Portainer to base Docker Compose stack
- Portainer setup and usage guide
- Cloudflare DNS setup automation
- Sprint 01 planning artifacts and story files
- Product backlog registry with user stories US-001 to US-020
- Epic files for OpenClaw DevOps features
- Comprehensive GCE deployment guide in wiki
- Tech stack badges to README
- AI/LLM features documentation
- Security scanning with Trivy and Semgrep
- GitHub Actions workflows (Claude Code Review, PR Assistant)
- Monitoring stories (US-018, US-019, US-020)

### Changed
- Updated GCE configuration with domain settings
- Updated README with AI/LLM features and comprehensive documentation
- Updated landing page startup command display
- Updated pnpm lockfile for LLM dependencies

### Fixed
- ESLint config for Next.js 16 compatibility
- PR check failures with enhanced security hooks
- CI/CD pipeline issues

### Removed
- Obsolete configuration summary files

## [0.0.0] - 2026-02-07

### Added
- Initial project structure
- Next.js landing page application
- Next.js assistant portal application
- Express.js API gateway
- Nginx reverse proxy configuration
- Docker Compose setup (basic and full stack)
- MongoDB, PostgreSQL, Redis database services
- Kafka and Zookeeper messaging services
- n8n workflow automation
- Prometheus and Grafana monitoring stack
- Monitoring exporters (Node, cAdvisor, Redis, PostgreSQL, MongoDB)
- pnpm workspace monorepo structure
- Environment configuration system
- Security scanning setup
- Basic documentation (README, SECURITY, CONTRIBUTING)
- Wiki structure with guides and documentation

### Infrastructure
- GCE deployment scripts
- Local development setup
- Makefile with common commands
- Git hooks for pre-commit and pre-push validation
- CI/CD workflows

---

## Version History

- **[Unreleased]** - Container privacy & port migration
- **[0.0.1]** - 2026-02-09 - Portainer, DNS automation, sprint planning
- **[0.0.0]** - 2026-02-07 - Initial release with core infrastructure

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Security

See [SECURITY.md](SECURITY.md) for security policies and vulnerability reporting.

---

**Last Updated:** 2026-02-14
