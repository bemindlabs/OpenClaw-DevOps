# Contributing to OpenClaw DevOps

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

1. Check existing issues to avoid duplicates
2. Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md)
3. Include as much detail as possible:
   - Environment (OS, Docker version, Node.js version)
   - Steps to reproduce
   - Expected vs actual behavior
   - Logs and screenshots

### Suggesting Features

1. Check existing issues and discussions
2. Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md)
3. Explain the use case and benefits

### Pull Requests

1. **Fork** the repository
2. **Create a branch** from `develop`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following our coding standards
4. **Test** your changes locally
5. **Commit** with clear, descriptive messages:
   ```bash
   git commit -m "feat: add user authentication to assistant"
   ```
6. **Push** to your fork
7. **Open a Pull Request** against `develop`

## Development Setup

### Prerequisites

- Node.js 20+
- Docker & Docker Compose
- Git

### Local Development

```bash
# Clone the repository
git clone https://github.com/YOUR_ORG/openclaw-devops.git
cd openclaw-devops

# Copy environment template
cp .env.example .env

# Install dependencies for all apps
cd apps/landing && npm install
cd ../assistant && npm install
cd ../openclaw-gateway && npm install

# Start development servers
# Option 1: Full stack with Docker
docker compose -f docker-compose.full.yml up -d

# Option 2: Individual apps in dev mode
cd apps/landing && npm run dev
```

### Project Structure

```
openclaw-devops/
├── apps/
│   ├── landing/         # Next.js landing page
│   ├── assistant/       # Admin portal (Next.js)
│   └── openclaw-gateway/# Express.js API gateway
├── nginx/               # Nginx configuration
├── monitoring/          # Prometheus & Grafana configs
├── scripts/             # Utility scripts
└── deployments/         # Environment-specific configs
```

## Coding Standards

### JavaScript/TypeScript

- Use TypeScript for new code
- Follow ESLint configuration
- Use Prettier for formatting
- Prefer functional components in React

### Git Commits

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

### Documentation

- Update README if adding new features
- Add JSDoc comments for public APIs
- Keep CLAUDE.md updated for AI assistance

## Testing

```bash
# Run linting
npm run lint

# Run type checking
npm run type-check

# Build production
npm run build
```

## Review Process

1. All PRs require at least one approval
2. CI checks must pass
3. Code coverage should not decrease
4. Documentation must be updated

## Getting Help

- Open a [Discussion](../../discussions) for questions
- Join our community chat (if applicable)
- Check the [documentation](./docs/)

## Recognition

Contributors are listed in our [CONTRIBUTORS.md](CONTRIBUTORS.md) file. Thank you for helping make this project better!
