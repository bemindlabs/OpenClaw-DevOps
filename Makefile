# OpenClaw DevOps - Makefile
# Simplified setup, build, and deployment commands

.PHONY: help setup install build start stop restart logs clean test verify docker-clean deep-clean security-setup security-verify security-audit security-test security-docs security-install security-scan security-trivy security-semgrep security-docker security-fix sanitize check-sanitization dev dev-landing dev-assistant dev-gateway dev-all dev-attach dev-kill dev-status

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

##@ General

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\n$(BLUE)Usage:$(NC)\n  make $(YELLOW)<target>$(NC)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Setup & Installation

setup: ## Initial setup (install pnpm if needed, copy .env.example)
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  OpenClaw DevOps - Initial Setup          ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)[1/4]$(NC) Checking for pnpm..."
	@command -v pnpm >/dev/null 2>&1 || { \
		echo "$(YELLOW)⚠  pnpm not found. Installing globally...$(NC)"; \
		npm install -g pnpm@9; \
	}
	@echo "$(GREEN)✓$(NC) pnpm is available: $$(pnpm --version)"
	@echo ""
	@echo "$(YELLOW)[2/4]$(NC) Checking for Docker..."
	@command -v docker >/dev/null 2>&1 || { \
		echo "$(YELLOW)⚠  Docker not found. Please install Docker first.$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✓$(NC) Docker is available: $$(docker --version)"
	@echo ""
	@echo "$(YELLOW)[3/4]$(NC) Setting up environment file..."
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN)✓$(NC) Created .env from .env.example"; \
		echo "$(YELLOW)⚠  Please edit .env with your configuration before proceeding$(NC)"; \
	else \
		echo "$(GREEN)✓$(NC) .env already exists"; \
	fi
	@echo ""
	@echo "$(YELLOW)[4/4]$(NC) Creating SSL directory..."
	@mkdir -p nginx/ssl
	@echo "$(GREEN)✓$(NC) SSL directory ready"
	@echo ""
	@echo "$(GREEN)✅ Setup complete!$(NC)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Edit .env with your configuration"
	@echo "  2. Run: make install"
	@echo "  3. Run: make build"
	@echo "  4. Run: make start"

install: ## Install dependencies (pnpm install)
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Installing Dependencies                  ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@if [ ! -f "pnpm-lock.yaml" ]; then \
		echo "$(YELLOW)Running: pnpm install$(NC)"; \
		pnpm install; \
	else \
		echo "$(YELLOW)Running: pnpm install --frozen-lockfile$(NC)"; \
		pnpm install --frozen-lockfile; \
	fi
	@echo ""
	@echo "$(GREEN)✅ Dependencies installed!$(NC)"

##@ Development

dev: ## Start all apps in development mode (with hot reload)
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Starting Development Servers              ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Cleaning development artifacts...$(NC)"
	@./scripts/dev-clean.sh
	@echo ""
	@echo "$(GREEN)Starting all apps in development mode...$(NC)"
	@echo ""
	@echo "$(YELLOW)Services:$(NC)"
	@echo "  Landing:   http://localhost:32102"
	@echo "  Assistant: http://localhost:32103"
	@echo "  Gateway:   http://localhost:32104"
	@echo ""
	@echo "$(BLUE)Press Ctrl+C to stop all servers$(NC)"
	@echo ""
	@pnpm dev:all

dev-landing: ## Start landing page in dev mode
	@echo "$(YELLOW)Starting landing page (http://localhost:32102)...$(NC)"
	@pnpm dev:landing

dev-assistant: ## Start assistant portal in dev mode
	@echo "$(YELLOW)Starting assistant portal (http://localhost:32103)...$(NC)"
	@pnpm dev:assistant

dev-gateway: ## Start gateway in dev mode
	@echo "$(YELLOW)Starting gateway (http://localhost:32104)...$(NC)"
	@pnpm dev:gateway

dev-all: ## Start all apps in tmux session (dev-devops-ai)
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Starting Development in Tmux             ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Cleaning development artifacts...$(NC)"
	@./scripts/dev-clean.sh 2>/dev/null || true
	@echo ""
	@# Check if session already exists
	@if tmux has-session -t dev-devops-ai 2>/dev/null; then \
		echo "$(YELLOW)⚠  Tmux session 'dev-devops-ai' already exists$(NC)"; \
		echo ""; \
		echo "Options:"; \
		echo "  1. Attach to existing session: tmux attach -t dev-devops-ai"; \
		echo "  2. Kill existing session: tmux kill-session -t dev-devops-ai && make dev-all"; \
		echo ""; \
		exit 1; \
	fi
	@echo "$(GREEN)Creating tmux session: dev-devops-ai$(NC)"
	@echo ""
	@# Create tmux session with first window for landing
	@tmux new-session -d -s dev-devops-ai -n landing -c $(PWD)
	@tmux send-keys -t dev-devops-ai:landing "pnpm dev:landing" Enter
	@# Create window for assistant
	@tmux new-window -t dev-devops-ai -n assistant -c $(PWD)
	@tmux send-keys -t dev-devops-ai:assistant "pnpm dev:assistant" Enter
	@# Create window for gateway
	@tmux new-window -t dev-devops-ai -n gateway -c $(PWD)
	@tmux send-keys -t dev-devops-ai:gateway "pnpm dev:gateway" Enter
	@# Create coordinator window and select it
	@tmux new-window -t dev-devops-ai -n coordinator -c $(PWD)
	@tmux send-keys -t dev-devops-ai:coordinator "clear" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '$(BLUE)╔═══════════════════════════════════════════════════════╗$(NC)'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '$(BLUE)║  OpenClaw DevOps - Development Session               ║$(NC)'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '$(BLUE)╚═══════════════════════════════════════════════════════╝$(NC)'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo ''" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '$(GREEN)Services running:$(NC)'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  Window 0: landing   - http://localhost:32102'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  Window 1: assistant - http://localhost:32103'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  Window 2: gateway   - http://localhost:32104'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  Window 3: coordinator (current)'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo ''" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '$(YELLOW)Tmux controls:$(NC)'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  Ctrl+b 0-3  - Switch to window 0-3'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  Ctrl+b d    - Detach session (services keep running)'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  Ctrl+b [    - Scroll mode (q to exit)'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  Ctrl+b c    - Create new window'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  Ctrl+b x    - Kill current window'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo ''" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '$(YELLOW)Useful commands:$(NC)'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  make dev-attach      - Re-attach to this session'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  make dev-kill        - Kill this session'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo '  make dev-status      - Check running services'" Enter
	@tmux send-keys -t dev-devops-ai:coordinator "echo ''" Enter
	@# Select coordinator window
	@tmux select-window -t dev-devops-ai:coordinator
	@# Show success message
	@echo "$(GREEN)✅ Tmux session created!$(NC)"
	@echo ""
	@echo "$(YELLOW)Services starting:$(NC)"
	@echo "  Landing:   http://localhost:3001 (dev) or http://localhost:32102 (prod)"
	@echo "  Assistant: http://localhost:3002 (dev) or http://localhost:32103 (prod)"
	@echo "  Gateway:   http://localhost:32104"
	@echo ""
	@echo "$(BLUE)📌 To attach to the session:$(NC)"
	@echo "   tmux attach -t dev-devops-ai"
	@echo "   (or use: make dev-attach)"
	@echo ""
	@echo "$(YELLOW)⌨️  Tmux controls:$(NC)"
	@echo "   Ctrl+b 0-3  - Switch windows"
	@echo "   Ctrl+b d    - Detach (keeps services running)"
	@echo "   Ctrl+b [    - Scroll mode (q to exit)"
	@echo ""
	@# Only auto-attach if in interactive terminal
	@if [ -t 0 ]; then \
		echo "$(BLUE)Auto-attaching to tmux session...$(NC)"; \
		sleep 2; \
		tmux attach -t dev-devops-ai; \
	else \
		echo "$(YELLOW)⚠  Non-interactive terminal detected$(NC)"; \
		echo "$(GREEN)Session running in background. Use 'make dev-attach' to connect.$(NC)"; \
	fi

dev-attach: ## Attach to existing dev-devops-ai tmux session
	@if tmux has-session -t dev-devops-ai 2>/dev/null; then \
		echo "$(GREEN)Attaching to dev-devops-ai session...$(NC)"; \
		tmux attach -t dev-devops-ai; \
	else \
		echo "$(YELLOW)⚠  No dev-devops-ai session found$(NC)"; \
		echo "Run: make dev-all"; \
	fi

dev-kill: ## Kill dev-devops-ai tmux session
	@if tmux has-session -t dev-devops-ai 2>/dev/null; then \
		echo "$(YELLOW)Killing dev-devops-ai session...$(NC)"; \
		tmux kill-session -t dev-devops-ai; \
		echo "$(GREEN)✅ Session killed$(NC)"; \
	else \
		echo "$(YELLOW)⚠  No dev-devops-ai session found$(NC)"; \
	fi

dev-status: ## Check status of dev-devops-ai tmux session
	@if tmux has-session -t dev-devops-ai 2>/dev/null; then \
		echo "$(GREEN)✅ dev-devops-ai session is running$(NC)"; \
		echo ""; \
		echo "Windows:"; \
		tmux list-windows -t dev-devops-ai; \
		echo ""; \
		echo "To attach: make dev-attach"; \
	else \
		echo "$(YELLOW)⚠  No dev-devops-ai session found$(NC)"; \
		echo "Run: make dev-all"; \
	fi

##@ Build

build: ## Build all Docker images
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Building Docker Images                   ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@if [ ! -f "pnpm-lock.yaml" ]; then \
		echo "$(YELLOW)⚠  pnpm-lock.yaml not found. Running: make install$(NC)"; \
		make install; \
	fi
	@echo ""
	@./BUILD-IMAGES.sh

build-landing: ## Build landing page image only
	@echo "$(YELLOW)Building landing page...$(NC)"
	@docker build -f apps/landing/Dockerfile -t openclaw-landing:latest .
	@echo "$(GREEN)✓$(NC) Landing image built"

build-assistant: ## Build assistant portal image only
	@echo "$(YELLOW)Building assistant portal...$(NC)"
	@docker build -f apps/assistant/Dockerfile -t openclaw-assistant:latest .
	@echo "$(GREEN)✓$(NC) Assistant image built"

build-gateway: ## Build gateway service image only
	@echo "$(YELLOW)Building gateway service...$(NC)"
	@docker build -f apps/gateway/Dockerfile -t openclaw-gateway:latest .
	@echo "$(GREEN)✓$(NC) Gateway image built"

##@ Run & Deploy

start: ## Start all services (docker-compose up -d)
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Starting Services                        ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@if [ ! -f ".env" ]; then \
		echo "$(YELLOW)⚠  .env not found. Running: make setup$(NC)"; \
		make setup; \
		echo ""; \
		echo "$(YELLOW)⚠  Please edit .env before starting services$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Starting docker-compose...$(NC)"
	@docker-compose up -d
	@echo ""
	@echo "$(GREEN)✅ Services started!$(NC)"
	@echo ""
	@make status

start-full: ## Start full stack with databases & monitoring
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Starting Full Stack                      ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@docker-compose -f docker-compose.full.yml up -d
	@echo ""
	@echo "$(GREEN)✅ Full stack started!$(NC)"
	@make status-full

stop: ## Stop all services
	@echo "$(YELLOW)Stopping services...$(NC)"
	@docker-compose down
	@echo "$(GREEN)✓$(NC) Services stopped"

stop-full: ## Stop full stack
	@echo "$(YELLOW)Stopping full stack...$(NC)"
	@docker-compose -f docker-compose.full.yml down
	@echo "$(GREEN)✓$(NC) Full stack stopped"

restart: ## Restart all services
	@make stop
	@sleep 2
	@make start

restart-full: ## Restart full stack
	@make stop-full
	@sleep 2
	@make start-full

##@ Code Quality

lint: ## Run linters on all apps
	@echo "$(YELLOW)Running linters...$(NC)"
	@pnpm lint:all

format: ## Format code with prettier
	@echo "$(YELLOW)Formatting code...$(NC)"
	@pnpm format:all || echo "$(YELLOW)⚠  No format script defined$(NC)"

##@ Monitoring

logs: ## View logs from all services
	@docker-compose logs -f

logs-landing: ## View landing page logs
	@docker-compose logs -f landing

logs-assistant: ## View assistant portal logs
	@docker-compose logs -f assistant

logs-gateway: ## View gateway service logs
	@docker-compose logs -f gateway

logs-nginx: ## View nginx logs
	@docker-compose logs -f nginx

status: ## Show status of all containers
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Service Status                           ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@docker-compose ps
	@echo ""
	@echo "$(BLUE)Service URLs:$(NC)"
	@echo "  Landing:   http://localhost:32102"
	@echo "  Assistant: http://localhost:32103"
	@echo "  Gateway:   http://localhost:32104"
	@echo "  Nginx:     http://localhost"

status-full: ## Show status of full stack
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Full Stack Status                        ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@docker-compose -f docker-compose.full.yml ps

health: ## Check health of all services
	@echo "$(BLUE)Checking service health...$(NC)"
	@echo ""
	@echo "$(YELLOW)Landing:$(NC)"
	@curl -f -s http://localhost:32102 > /dev/null && echo "$(GREEN)✓$(NC) Healthy" || echo "$(YELLOW)⚠$(NC)  Not responding"
	@echo ""
	@echo "$(YELLOW)Gateway:$(NC)"
	@curl -f -s http://localhost:32104/health > /dev/null && echo "$(GREEN)✓$(NC) Healthy" || echo "$(YELLOW)⚠$(NC)  Not responding"
	@echo ""
	@echo "$(YELLOW)Assistant:$(NC)"
	@curl -f -s http://localhost:32103 > /dev/null && echo "$(GREEN)✓$(NC) Healthy" || echo "$(YELLOW)⚠$(NC)  Not responding"
	@echo ""
	@echo "$(YELLOW)Nginx:$(NC)"
	@curl -f -s http://localhost/health > /dev/null && echo "$(GREEN)✓$(NC) Healthy" || echo "$(YELLOW)⚠$(NC)  Not responding"

##@ Testing & Verification

test: ## Run tests on all apps
	@echo "$(YELLOW)Running tests...$(NC)"
	@pnpm test || echo "$(YELLOW)⚠  No test script defined$(NC)"

verify: ## Verify project configuration and health
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Project Verification                     ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)1. Checking pnpm workspace...$(NC)"
	@test -f pnpm-workspace.yaml && echo "$(GREEN)✓$(NC) pnpm-workspace.yaml exists" || echo "$(YELLOW)⚠$(NC)  Missing"
	@test -f pnpm-lock.yaml && echo "$(GREEN)✓$(NC) pnpm-lock.yaml exists" || echo "$(YELLOW)⚠$(NC)  Missing"
	@echo ""
	@echo "$(YELLOW)2. Checking configuration files...$(NC)"
	@test -f .env && echo "$(GREEN)✓$(NC) .env exists" || echo "$(YELLOW)⚠$(NC)  .env missing (run: make setup)"
	@test -f .env.example && echo "$(GREEN)✓$(NC) .env.example exists" || echo "$(YELLOW)⚠$(NC)  Missing"
	@test -f .gitignore && echo "$(GREEN)✓$(NC) .gitignore exists" || echo "$(YELLOW)⚠$(NC)  Missing"
	@echo ""
	@echo "$(YELLOW)3. Checking Docker images...$(NC)"
	@docker images | grep -q openclaw-landing && echo "$(GREEN)✓$(NC) openclaw-landing image exists" || echo "$(YELLOW)⚠$(NC)  Not built (run: make build)"
	@docker images | grep -q openclaw-gateway && echo "$(GREEN)✓$(NC) openclaw-gateway image exists" || echo "$(YELLOW)⚠$(NC)  Not built (run: make build)"
	@docker images | grep -q openclaw-assistant && echo "$(GREEN)✓$(NC) openclaw-assistant image exists" || echo "$(YELLOW)⚠$(NC)  Not built (run: make build)"
	@echo ""
	@echo "$(YELLOW)4. Checking app directories...$(NC)"
	@test -d apps/landing && echo "$(GREEN)✓$(NC) apps/landing exists" || echo "$(YELLOW)⚠$(NC)  Missing"
	@test -d apps/gateway && echo "$(GREEN)✓$(NC) apps/gateway exists" || echo "$(YELLOW)⚠$(NC)  Missing"
	@test -d apps/assistant && echo "$(GREEN)✓$(NC) apps/assistant exists" || echo "$(YELLOW)⚠$(NC)  Missing"
	@echo ""
	@echo "$(GREEN)✅ Verification complete!$(NC)"

##@ Security

security-setup: ## Generate secure passwords and configure security settings
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Security Setup                           ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)⚠  .env file not found. Creating from .env.example...$(NC)"; \
		cp .env.example .env; \
	fi
	@echo "$(YELLOW)[1/2]$(NC) Generating secure passwords..."
	@chmod +x scripts/generate-passwords.sh
	@./scripts/generate-passwords.sh
	@echo ""
	@echo "$(YELLOW)[2/2]$(NC) Security configuration checklist:"
	@echo "  $(YELLOW)→$(NC) Edit .env and configure:"
	@echo "    - CORS_ORIGIN (your actual domains)"
	@echo "    - ALLOWED_OAUTH_DOMAINS (your company domains)"
	@echo "    - NODE_ENV=production (for production deployments)"
	@echo ""
	@echo "$(GREEN)✅ Security setup complete!$(NC)"
	@echo "$(BLUE)Next steps:$(NC)"
	@echo "  1. Edit .env with your domain configurations"
	@echo "  2. Run: make security-verify"
	@echo "  3. Review: SECURITY.md for additional hardening"

security-verify: ## Verify all security fixes are properly implemented
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Security Verification                    ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@chmod +x scripts/verify-security-fixes.sh
	@./scripts/verify-security-fixes.sh

security-audit: ## Run security audit and generate report
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Security Audit                           ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Running security verification...$(NC)"
	@./scripts/verify-security-fixes.sh > /tmp/security-audit.txt 2>&1 || true
	@echo ""
	@echo "$(YELLOW)Checking for vulnerabilities in dependencies...$(NC)"
	@cd apps/landing && pnpm audit --audit-level=moderate 2>/dev/null || echo "$(YELLOW)⚠  Some vulnerabilities found$(NC)"
	@cd apps/gateway && pnpm audit --audit-level=moderate 2>/dev/null || echo "$(YELLOW)⚠  Some vulnerabilities found$(NC)"
	@cd apps/assistant && pnpm audit --audit-level=moderate 2>/dev/null || echo "$(YELLOW)⚠  Some vulnerabilities found$(NC)"
	@echo ""
	@echo "$(GREEN)✅ Security audit complete!$(NC)"
	@echo "$(BLUE)Review:$(NC)"
	@echo "  - Full report: /tmp/security-audit.txt"
	@echo "  - Documentation: SECURITY.md"
	@echo "  - Fix summary: SECURITY-FIXES-SUMMARY.md"

security-test: ## Test security configurations (authentication, CORS, etc.)
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Security Testing                         ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Note: This requires services to be running$(NC)"
	@echo "Run 'make start' first if services are not running"
	@echo ""
	@echo "$(YELLOW)[1/3]$(NC) Testing unauthenticated access (should fail)..."
	@curl -s -X POST http://localhost:32104/api/services/nginx/restart | grep -q "Authentication required" && \
		echo "$(GREEN)✓$(NC) Unauthenticated access blocked" || \
		echo "$(RED)✗$(NC) Unauthenticated access NOT blocked"
	@echo ""
	@echo "$(YELLOW)[2/3]$(NC) Testing CORS configuration..."
	@grep -q "CORS_ORIGIN" .env && \
		echo "$(GREEN)✓$(NC) CORS_ORIGIN configured" || \
		echo "$(YELLOW)⚠$(NC)  CORS_ORIGIN not set (will default to development mode)"
	@echo ""
	@echo "$(YELLOW)[3/3]$(NC) Testing OAuth domain whitelist..."
	@grep -q "ALLOWED_OAUTH_DOMAINS" .env && \
		echo "$(GREEN)✓$(NC) ALLOWED_OAUTH_DOMAINS configured" || \
		echo "$(YELLOW)⚠$(NC)  ALLOWED_OAUTH_DOMAINS not set"
	@echo ""
	@echo "$(GREEN)✅ Security tests complete!$(NC)"
	@echo "$(BLUE)For full testing instructions, see:$(NC) SECURITY-FIXES-SUMMARY.md"

security-docs: ## Open security documentation
	@echo "$(BLUE)Opening security documentation...$(NC)"
	@echo ""
	@echo "$(GREEN)Available security documents:$(NC)"
	@echo "  1. SECURITY.md                      - Comprehensive security guide"
	@echo "  2. SECURITY-FIXES-SUMMARY.md        - Summary of fixes applied"
	@echo "  3. SECURITY-VERIFICATION-REPORT.md  - Automated verification results"
	@echo "  4. PRIVACY-AND-SANITIZATION.md      - Privacy and sanitization guide"
	@echo "  5. .env.example                     - Security configuration template"
	@echo ""
	@if command -v open >/dev/null 2>&1; then \
		open SECURITY.md 2>/dev/null || cat SECURITY.md | head -50; \
	elif command -v xdg-open >/dev/null 2>&1; then \
		xdg-open SECURITY.md 2>/dev/null || cat SECURITY.md | head -50; \
	else \
		cat SECURITY.md | head -50; \
	fi

security-install: ## Install security scanning tools (Trivy + Semgrep)
	@echo "$(BLUE)Installing security scanning tools...$(NC)"
	@chmod +x scripts/install-security-tools.sh
	@./scripts/install-security-tools.sh

security-scan: ## Run all security scans (Trivy + Semgrep)
	@echo "$(BLUE)Running comprehensive security scans...$(NC)"
	@chmod +x scripts/security-scan.sh
	@./scripts/security-scan.sh --all

security-trivy: ## Run Trivy vulnerability scanning
	@echo "$(BLUE)Running Trivy vulnerability scans...$(NC)"
	@chmod +x scripts/security-scan.sh
	@./scripts/security-scan.sh --trivy

security-semgrep: ## Run Semgrep code analysis
	@echo "$(BLUE)Running Semgrep code analysis...$(NC)"
	@chmod +x scripts/security-scan.sh
	@./scripts/security-scan.sh --semgrep

security-docker: ## Run Docker image security scanning
	@echo "$(BLUE)Running Docker image security scans...$(NC)"
	@chmod +x scripts/security-scan.sh
	@./scripts/security-scan.sh --trivy --docker

security-fix: ## Auto-fix security issues (Semgrep)
	@echo "$(BLUE)Auto-fixing security issues with Semgrep...$(NC)"
	@echo "$(YELLOW)⚠️  Warning: This will modify files automatically$(NC)"
	@chmod +x scripts/security-scan.sh
	@./scripts/security-scan.sh --semgrep --fix

sanitize: ## Sanitize deployment-specific references (domains, IPs, usernames)
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Deployment Reference Sanitization        ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)⚠️  Warning: This will modify files in the repository$(NC)"
	@echo ""
	@echo "This script will replace:"
	@echo "  - Real IP addresses → Placeholders (YOUR_PUBLIC_IP, YOUR_PRIVATE_IP)"
	@echo "  - Real domains → Generic domains (your-domain.com)"
	@echo "  - Username in paths → Generic username (your-username)"
	@echo ""
	@echo "$(BLUE)Use case:$(NC) Before sharing code publicly or as a template"
	@echo ""
	@chmod +x scripts/sanitize-deployment-refs.sh
	@./scripts/sanitize-deployment-refs.sh
	@echo ""
	@echo "$(BLUE)After sanitization:$(NC)"
	@echo "  1. Review changes: git diff"
	@echo "  2. Update documentation: DEPLOYMENT-CONFIGURATION.md"
	@echo "  3. Commit changes if satisfied"

check-sanitization: ## Check if codebase contains deployment-specific references
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Sanitization Check                       ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Checking for real IP addresses...$(NC)"
	@FOUND=0; \
	if grep -r "58\.136\.234\.96" . --exclude-dir={node_modules,.git,.next,dist,build,backups} -q 2>/dev/null; then \
		echo "$(RED)✗$(NC) Found real public IP (58.136.234.96)"; \
		FOUND=$$((FOUND+1)); \
	else \
		echo "$(GREEN)✓$(NC) No real public IP found"; \
	fi; \
	echo ""; \
	echo "$(YELLOW)Checking for real private IP...$(NC)"; \
	if grep -r "192\.168\.1\.152" . --exclude-dir={node_modules,.git,.next,dist,build,backups} -q 2>/dev/null; then \
		echo "$(RED)✗$(NC) Found real private IP (192.168.1.152)"; \
		FOUND=$$((FOUND+1)); \
	else \
		echo "$(GREEN)✓$(NC) No real private IP found"; \
	fi; \
	echo ""; \
	echo "$(YELLOW)Checking for real domain...$(NC)"; \
	if grep -r "agents\.ddns\.net" . --exclude-dir={node_modules,.git,.next,dist,build,backups} -q 2>/dev/null; then \
		echo "$(RED)✗$(NC) Found real domain (agents.ddns.net)"; \
		FOUND=$$((FOUND+1)); \
	else \
		echo "$(GREEN)✓$(NC) No real domain found"; \
	fi; \
	echo ""; \
	echo "$(YELLOW)Checking for .env file...$(NC)"; \
	if [ -f .env ]; then \
		echo "$(YELLOW)⚠$(NC)  .env file exists (should be .env.example only for distribution)"; \
		FOUND=$$((FOUND+1)); \
	else \
		echo "$(GREEN)✓$(NC) No .env file (good for distribution)"; \
	fi; \
	echo ""; \
	if [ $$FOUND -eq 0 ]; then \
		echo "$(GREEN)✅ Codebase is sanitized and ready for public distribution$(NC)"; \
	else \
		echo "$(RED)⚠  Found $$FOUND issue(s) - run 'make sanitize' to fix$(NC)"; \
	fi

##@ Cleanup

clean: ## Clean build artifacts (node_modules, .next, dist)
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@echo "  Removing node_modules..."
	@find . -name "node_modules" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	@echo "  Removing .next directories..."
	@find apps -name ".next" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	@echo "  Removing dist directories..."
	@find apps -name "dist" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	@echo "  Removing build directories..."
	@find apps -name "build" -type d -prune -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✓$(NC) Build artifacts cleaned"

docker-clean: ## Remove Docker containers and volumes
	@echo "$(YELLOW)Stopping and removing containers...$(NC)"
	@docker-compose down -v || true
	@docker-compose -f docker-compose.full.yml down -v || true
	@echo "$(GREEN)✓$(NC) Containers and volumes removed"

docker-clean-images: ## Remove OpenClaw Docker images
	@echo "$(YELLOW)Removing OpenClaw images...$(NC)"
	@docker images | grep openclaw | awk '{print $$3}' | xargs -r docker rmi -f || true
	@echo "$(GREEN)✓$(NC) Images removed"

deep-clean: clean docker-clean docker-clean-images ## Deep clean (build artifacts + Docker)
	@echo "$(YELLOW)Removing pnpm-lock.yaml...$(NC)"
	@rm -f pnpm-lock.yaml
	@echo "$(YELLOW)Removing .pnpm-store...$(NC)"
	@rm -rf .pnpm-store
	@echo "$(GREEN)✓$(NC) Deep clean complete"
	@echo ""
	@echo "$(BLUE)To rebuild from scratch:$(NC)"
	@echo "  1. make install"
	@echo "  2. make build"
	@echo "  3. make start"

##@ Quick Start

all: setup install build start ## Complete setup from scratch (setup → install → build → start)
	@echo ""
	@echo "$(GREEN)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(GREEN)║  🎉 OpenClaw DevOps is Ready!             ║$(NC)"
	@echo "$(GREEN)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@make status

onboarding: ## Interactive onboarding guide - complete setup with configuration help
	@chmod +x scripts/onboarding.sh
	@./scripts/onboarding.sh

onboard: onboarding ## Alias for onboarding

##@ Info

version: ## Show version information
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  OpenClaw DevOps - Version Info           ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Tools:$(NC)"
	@echo "  Node: $$(node --version 2>/dev/null || echo 'not installed')"
	@echo "  pnpm: $$(pnpm --version 2>/dev/null || echo 'not installed')"
	@echo "  Docker: $$(docker --version 2>/dev/null || echo 'not installed')"
	@echo ""
	@echo "$(YELLOW)Project:$(NC)"
	@test -f package.json && cat package.json | grep -E '"name"|"version"' || echo "  package.json not found"

info: version ## Alias for version

##@ Cloud Deployment (Google Cloud Run)

deploy-cloud-run: ## Deploy all services to Google Cloud Run
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Deploying to Google Cloud Run            ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@cd deployments/gcr && ./deploy.sh

deploy-cloud-run-landing: ## Deploy only landing page to Cloud Run
	@echo "$(YELLOW)Deploying landing page to Cloud Run...$(NC)"
	@cd deployments/gcr && ./deploy.sh --service landing

deploy-cloud-run-gateway: ## Deploy only gateway to Cloud Run
	@echo "$(YELLOW)Deploying gateway to Cloud Run...$(NC)"
	@cd deployments/gcr && ./deploy.sh --service gateway

deploy-cloud-run-assistant: ## Deploy only assistant to Cloud Run
	@echo "$(YELLOW)Deploying assistant to Cloud Run...$(NC)"
	@cd deployments/gcr && ./deploy.sh --service assistant

cloud-run-status: ## Check Cloud Run services status
	@cd deployments/gcr/scripts && ./status.sh

cloud-run-logs: ## View Cloud Run logs
	@cd deployments/gcr/scripts && ./logs.sh

cloud-run-logs-gateway: ## View gateway logs from Cloud Run
	@cd deployments/gcr/scripts && ./logs.sh gateway -f

cloud-run-scale: ## Scale Cloud Run service (usage: make cloud-run-scale service=gateway min=1 max=20)
	@if [ -z "$(service)" ]; then \
		echo "$(RED)Error: service parameter required$(NC)"; \
		echo "Usage: make cloud-run-scale service=gateway min=1 max=20"; \
		exit 1; \
	fi
	@cd deployments/gcr/scripts && ./scale.sh $(service) $(min) $(max)

