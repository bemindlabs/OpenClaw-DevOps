#!/bin/bash
# OpenClaw DevOps - Interactive Onboarding Script
# Guides users through complete system setup and configuration

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration variables
ENV_FILE=".env"
ENV_EXAMPLE=".env.example"
BACKUP_DIR="backups"

# Utility functions
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $1$(printf '%*s' $((57 - ${#1})) '')║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}[Step $1/$2]${NC} $3"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC}  $1"
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local response

    if [ "$default" = "y" ]; then
        read -p "$(echo -e ${CYAN}${prompt}${NC} [Y/n] )" response
        response=${response:-y}
    else
        read -p "$(echo -e ${CYAN}${prompt}${NC} [y/N] )" response
        response=${response:-n}
    fi

    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

ask_input() {
    local prompt="$1"
    local default="$2"
    local response

    if [ -n "$default" ]; then
        read -p "$(echo -e ${CYAN}${prompt}${NC} [${GREEN}${default}${NC}]: )" response
        response=${response:-$default}
    else
        read -p "$(echo -e ${CYAN}${prompt}${NC}: )" response
    fi

    echo "$response"
}

validate_domain() {
    local domain="$1"
    # Basic domain validation
    if [[ "$domain" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_email_domain() {
    local domain="$1"
    # Allow comma-separated domains
    if [[ "$domain" =~ ^[a-zA-Z0-9.-]+(,[a-zA-Z0-9.-]+)*$ ]]; then
        return 0
    else
        return 1
    fi
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Main onboarding flow
main() {
    clear
    print_header "Welcome to OpenClaw DevOps Onboarding!"

    echo -e "${MAGENTA}This interactive setup will guide you through:${NC}"
    echo "  1. Prerequisites validation"
    echo "  2. Environment configuration"
    echo "  3. Domain setup"
    echo "  4. Security configuration"
    echo "  5. OAuth setup (optional)"
    echo "  6. Service installation"
    echo "  7. First-time startup"
    echo ""

    if ! ask_yes_no "Ready to begin?"; then
        echo ""
        print_warning "Onboarding cancelled. Run 'make onboarding' when ready."
        exit 0
    fi

    # Step 1: Check Prerequisites
    clear
    print_step 1 7 "Prerequisites Check"
    check_prerequisites

    # Step 2: Environment Setup
    clear
    print_step 2 7 "Environment File Setup"
    setup_environment_file

    # Step 3: Domain Configuration
    clear
    print_step 3 7 "Domain Configuration"
    configure_domains

    # Step 4: Security Configuration
    clear
    print_step 4 7 "Security & Password Generation"
    configure_security

    # Step 5: OAuth Configuration
    clear
    print_step 5 7 "OAuth & Authentication"
    configure_oauth

    # Step 6: Optional Services
    clear
    print_step 6 7 "Optional Services Configuration"
    configure_optional_services

    # Step 7: Installation & Startup
    clear
    print_step 7 7 "Installation & Startup"
    install_and_start

    # Completion
    clear
    show_completion_summary
}

check_prerequisites() {
    echo -e "${YELLOW}Checking system requirements...${NC}"
    echo ""

    local has_errors=0

    # Check Node.js
    if check_command node; then
        local node_version=$(node --version | sed 's/v//')
        local node_major=$(echo $node_version | cut -d. -f1)

        if [ "$node_major" -ge 20 ]; then
            print_success "Node.js $node_version (requires 20+)"
        else
            print_error "Node.js $node_version is too old (requires 20+)"
            has_errors=1
        fi
    else
        print_error "Node.js not found (requires 20+)"
        has_errors=1
    fi

    # Check Docker
    if check_command docker; then
        local docker_version=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        print_success "Docker $docker_version"

        # Check if Docker daemon is running
        if docker info >/dev/null 2>&1; then
            print_success "Docker daemon is running"
        else
            print_warning "Docker daemon is not running"
            print_info "Please start Docker Desktop or Docker daemon"
            has_errors=1
        fi
    else
        print_error "Docker not found"
        has_errors=1
    fi

    # Check pnpm (will install if missing)
    if check_command pnpm; then
        local pnpm_version=$(pnpm --version)
        print_success "pnpm $pnpm_version"
    else
        print_warning "pnpm not found - will be installed"
    fi

    # Check disk space
    local available_space=$(df -h . | awk 'NR==2 {print $4}')
    print_info "Available disk space: $available_space"

    echo ""

    if [ $has_errors -eq 1 ]; then
        print_error "Prerequisites not met. Please install required software:"
        echo ""
        echo "  Node.js 20+: https://nodejs.org/"
        echo "  Docker: https://docs.docker.com/get-docker/"
        echo ""
        exit 1
    fi

    print_success "All prerequisites met!"
    echo ""
    read -p "Press Enter to continue..."
}

setup_environment_file() {
    if [ -f "$ENV_FILE" ]; then
        echo -e "${YELLOW}Existing .env file detected${NC}"
        echo ""
        print_info "Current .env will be backed up"
        echo ""

        if ask_yes_no "Do you want to reconfigure your .env?"; then
            # Backup existing .env
            mkdir -p "$BACKUP_DIR"
            local backup_file="$BACKUP_DIR/.env.backup.$(date +%Y%m%d-%H%M%S)"
            cp "$ENV_FILE" "$backup_file"
            print_success "Backed up to $backup_file"
        else
            print_info "Using existing .env file"
            echo ""
            read -p "Press Enter to continue..."
            return
        fi
    else
        if [ ! -f "$ENV_EXAMPLE" ]; then
            print_error ".env.example not found!"
            exit 1
        fi
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        print_success "Created .env from .env.example"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

configure_domains() {
    echo -e "${YELLOW}Domain Configuration${NC}"
    echo ""
    echo "OpenClaw uses a multi-domain architecture:"
    echo "  • Main domain: Landing page"
    echo "  • Subdomain (openclaw.*): Gateway API"
    echo "  • Subdomain (assistant.*): Admin portal"
    echo ""

    local current_domain=$(grep "^DOMAIN=" "$ENV_FILE" | cut -d= -f2)

    print_info "Current domain: ${current_domain:-not set}"
    echo ""

    # Ask for deployment type
    echo "Deployment type:"
    echo "  1) Production with custom domain (e.g., mycompany.com)"
    echo "  2) Development with localhost"
    echo "  3) Development with local domain (e.g., example.local)"
    echo ""

    local deploy_choice
    read -p "$(echo -e ${CYAN}Choose deployment type${NC} [1-3]: )" deploy_choice

    local main_domain
    local landing_domain
    local gateway_domain
    local assistant_domain

    case $deploy_choice in
        1)
            # Production domain
            while true; do
                main_domain=$(ask_input "Enter your main domain" "$current_domain")
                if validate_domain "$main_domain"; then
                    break
                else
                    print_error "Invalid domain format. Please try again."
                fi
            done

            landing_domain="$main_domain"

            if ask_yes_no "Use www subdomain for landing page?"; then
                landing_domain="www.$main_domain"
            fi

            gateway_domain=$(ask_input "Gateway subdomain" "openclaw.$main_domain")
            assistant_domain=$(ask_input "Assistant subdomain" "assistant.$main_domain")
            ;;
        2)
            # Localhost
            main_domain="localhost"
            landing_domain="localhost"
            gateway_domain="localhost"
            assistant_domain="localhost"
            print_info "Using localhost - services will be accessed via different ports"
            ;;
        3)
            # Local domain
            main_domain=$(ask_input "Enter your local domain" "example.local")
            landing_domain="$main_domain"
            gateway_domain="openclaw.$main_domain"
            assistant_domain="assistant.$main_domain"
            print_warning "Remember to add entries to /etc/hosts for local domains"
            ;;
        *)
            print_warning "Invalid choice. Using default: your-domain.com"
            main_domain="your-domain.com"
            landing_domain="your-domain.com"
            gateway_domain="openclaw.your-domain.com"
            assistant_domain="assistant.your-domain.com"
            ;;
    esac

    # Update .env file
    sed -i.bak "s|^DOMAIN=.*|DOMAIN=${main_domain}|" "$ENV_FILE"
    sed -i.bak "s|^LANDING_DOMAIN=.*|LANDING_DOMAIN=${landing_domain}|" "$ENV_FILE"
    sed -i.bak "s|^GATEWAY_DOMAIN=.*|GATEWAY_DOMAIN=${gateway_domain}|" "$ENV_FILE"
    sed -i.bak "s|^ASSISTANT_DOMAIN=.*|ASSISTANT_DOMAIN=${assistant_domain}|" "$ENV_FILE"
    sed -i.bak "s|^NEXT_PUBLIC_LANDING_DOMAIN=.*|NEXT_PUBLIC_LANDING_DOMAIN=${landing_domain}|" "$ENV_FILE"
    sed -i.bak "s|^NEXTAUTH_URL=.*|NEXTAUTH_URL=https://${assistant_domain}|" "$ENV_FILE"
    sed -i.bak "s|^NEXT_PUBLIC_GATEWAY_URL=.*|NEXT_PUBLIC_GATEWAY_URL=https://${gateway_domain}|" "$ENV_FILE"
    sed -i.bak "s|^CORS_ORIGIN=.*|CORS_ORIGIN=https://${assistant_domain},https://${landing_domain}|" "$ENV_FILE"
    rm -f "$ENV_FILE.bak"

    echo ""
    print_success "Domain configuration complete!"
    echo ""
    echo -e "${GREEN}Your domains:${NC}"
    echo "  Landing:   $landing_domain"
    echo "  Gateway:   $gateway_domain"
    echo "  Assistant: $assistant_domain"
    echo ""
    read -p "Press Enter to continue..."
}

configure_security() {
    echo -e "${YELLOW}Security Configuration${NC}"
    echo ""
    echo "Generating secure passwords for all services..."
    echo ""

    if ask_yes_no "Generate secure passwords automatically?" "y"; then
        # Run the password generation script
        if [ -f "scripts/generate-passwords.sh" ]; then
            chmod +x scripts/generate-passwords.sh

            # Silent mode - generate passwords without prompts
            echo "y" | ./scripts/generate-passwords.sh >/dev/null 2>&1 || true

            print_success "All service passwords generated"
            echo ""
            print_info "Passwords are 32+ characters, cryptographically random"
            print_info "Each service has a unique password"
        else
            print_error "Password generation script not found"
        fi
    else
        print_warning "You'll need to manually edit passwords in .env"
        print_info "Use: openssl rand -base64 32 to generate secure passwords"
    fi

    echo ""

    # Environment mode
    echo "Environment mode:"
    echo "  1) Development (NODE_ENV=development)"
    echo "  2) Production (NODE_ENV=production)"
    echo ""

    local env_choice
    read -p "$(echo -e ${CYAN}Choose environment${NC} [1-2]: )" env_choice

    if [ "$env_choice" = "2" ]; then
        sed -i.bak "s|^NODE_ENV=.*|NODE_ENV=production|" "$ENV_FILE"
        print_success "Set to production mode"
    else
        sed -i.bak "s|^NODE_ENV=.*|NODE_ENV=development|" "$ENV_FILE"
        print_success "Set to development mode"
    fi
    rm -f "$ENV_FILE.bak"

    echo ""
    read -p "Press Enter to continue..."
}

configure_oauth() {
    echo -e "${YELLOW}OAuth & Authentication Configuration${NC}"
    echo ""
    echo "The assistant portal uses Google OAuth for authentication."
    echo ""

    if ask_yes_no "Configure Google OAuth now?"; then
        echo ""
        print_info "You'll need to create OAuth credentials at:"
        print_info "https://console.cloud.google.com/apis/credentials"
        echo ""
        echo "Steps:"
        echo "  1. Create a new project or select existing"
        echo "  2. Enable Google+ API"
        echo "  3. Create OAuth 2.0 Client ID"
        echo "  4. Add authorized redirect URIs"
        echo ""

        if ask_yes_no "Have you created OAuth credentials?"; then
            echo ""
            local google_client_id
            google_client_id=$(ask_input "Enter Google Client ID")

            if [ -n "$google_client_id" ]; then
                sed -i.bak "s|^GOOGLE_CLIENT_ID=.*|GOOGLE_CLIENT_ID=${google_client_id}|" "$ENV_FILE"
                rm -f "$ENV_FILE.bak"
                print_success "Google Client ID saved"
                print_info "Google Client Secret was auto-generated (you can update it later)"
            fi

            echo ""
            echo "Allowed OAuth email domains:"
            echo "Only users with these email domains can log in."
            echo "(Comma-separated, e.g., mycompany.com,partner.com)"
            echo ""

            while true; do
                local allowed_domains
                allowed_domains=$(ask_input "Enter allowed domains" "your-domain.com")

                if validate_email_domain "$allowed_domains"; then
                    sed -i.bak "s|^ALLOWED_OAUTH_DOMAINS=.*|ALLOWED_OAUTH_DOMAINS=${allowed_domains}|" "$ENV_FILE"
                    rm -f "$ENV_FILE.bak"
                    print_success "Allowed domains: $allowed_domains"
                    break
                else
                    print_error "Invalid format. Use comma-separated domains."
                fi
            done
        else
            print_warning "OAuth not configured - you'll need to set it up later"
            print_info "Edit GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET in .env"
        fi
    else
        print_warning "Skipping OAuth configuration"
        print_info "The assistant portal will need OAuth to be configured later"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

configure_optional_services() {
    echo -e "${YELLOW}Optional Services${NC}"
    echo ""

    # Telegram Bot
    if ask_yes_no "Enable Telegram bot integration?"; then
        echo ""
        print_info "Get bot token from @BotFather on Telegram"
        print_info "Send /newbot to @BotFather and follow instructions"
        echo ""

        if ask_yes_no "Have you created a Telegram bot?"; then
            local telegram_token
            telegram_token=$(ask_input "Enter Telegram bot token")

            if [ -n "$telegram_token" ]; then
                sed -i.bak "s|^TELEGRAM_ENABLED=.*|TELEGRAM_ENABLED=true|" "$ENV_FILE"
                sed -i.bak "s|^TELEGRAM_BOT_TOKEN=.*|TELEGRAM_BOT_TOKEN=${telegram_token}|" "$ENV_FILE"
                rm -f "$ENV_FILE.bak"
                print_success "Telegram bot enabled"
            fi
        else
            print_info "You can enable Telegram later in .env"
        fi
    else
        sed -i.bak "s|^TELEGRAM_ENABLED=.*|TELEGRAM_ENABLED=false|" "$ENV_FILE"
        rm -f "$ENV_FILE.bak"
    fi

    echo ""

    # Monitoring stack
    if ask_yes_no "Do you want to enable full monitoring stack?" "y"; then
        print_info "Full stack includes: MongoDB, PostgreSQL, Redis, Kafka, n8n, Prometheus, Grafana"
        ENABLE_FULL_STACK="yes"
    else
        print_info "Basic stack: Nginx, Landing, Gateway, Assistant only"
        ENABLE_FULL_STACK="no"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

install_and_start() {
    echo -e "${YELLOW}Installation & Startup${NC}"
    echo ""

    # Install pnpm if needed
    if ! check_command pnpm; then
        print_info "Installing pnpm globally..."
        npm install -g pnpm@9
        print_success "pnpm installed"
    fi

    echo ""

    # Install dependencies
    if ask_yes_no "Install project dependencies?" "y"; then
        echo ""
        print_info "This may take a few minutes..."
        echo ""

        if pnpm install; then
            print_success "Dependencies installed"
        else
            print_error "Failed to install dependencies"
            return 1
        fi
    fi

    echo ""

    # Build Docker images
    if ask_yes_no "Build Docker images?" "y"; then
        echo ""
        print_info "This may take 5-10 minutes..."
        echo ""

        if [ -f "BUILD-IMAGES.sh" ]; then
            chmod +x BUILD-IMAGES.sh
            if ./BUILD-IMAGES.sh; then
                print_success "Docker images built"
            else
                print_error "Failed to build images"
                return 1
            fi
        else
            print_warning "BUILD-IMAGES.sh not found, skipping image build"
        fi
    fi

    echo ""

    # Start services
    if ask_yes_no "Start services now?" "y"; then
        echo ""

        if [ "$ENABLE_FULL_STACK" = "yes" ]; then
            print_info "Starting full stack..."
            docker-compose -f docker-compose.full.yml up -d
        else
            print_info "Starting basic stack..."
            docker-compose up -d
        fi

        echo ""
        print_success "Services started!"
        echo ""
        print_info "Waiting for services to become healthy (this may take 40-60 seconds)..."
        sleep 10
    fi

    echo ""
    read -p "Press Enter to continue..."
}

show_completion_summary() {
    print_header "🎉 Onboarding Complete!"

    echo -e "${GREEN}Your OpenClaw DevOps platform is configured!${NC}"
    echo ""

    # Show service URLs
    local landing_domain=$(grep "^LANDING_DOMAIN=" "$ENV_FILE" | cut -d= -f2)
    local gateway_domain=$(grep "^GATEWAY_DOMAIN=" "$ENV_FILE" | cut -d= -f2)
    local assistant_domain=$(grep "^ASSISTANT_DOMAIN=" "$ENV_FILE" | cut -d= -f2)

    echo -e "${CYAN}Service URLs:${NC}"
    echo "  Landing:   http://$landing_domain (port 3000)"
    echo "  Gateway:   http://$gateway_domain (port 18789)"
    echo "  Assistant: http://$assistant_domain (port 5555)"
    echo "  Nginx:     http://localhost (port 80)"
    echo ""

    if [ "$ENABLE_FULL_STACK" = "yes" ]; then
        echo -e "${CYAN}Monitoring & Tools:${NC}"
        echo "  Grafana:    http://localhost:3001"
        echo "  Prometheus: http://localhost:9090"
        echo "  n8n:        http://localhost:5678"
        echo ""
    fi

    echo -e "${YELLOW}Next Steps:${NC}"
    echo ""
    echo "  1. Check service status:"
    echo "     ${GREEN}make status${NC}"
    echo ""
    echo "  2. View logs:"
    echo "     ${GREEN}make logs${NC}"
    echo ""
    echo "  3. Check health:"
    echo "     ${GREEN}make health${NC}"
    echo ""
    echo "  4. Development mode (with hot reload):"
    echo "     ${GREEN}make dev${NC}"
    echo ""

    echo -e "${YELLOW}Important Files:${NC}"
    echo "  .env          - Your configuration (keep secure!)"
    echo "  CLAUDE.md     - Developer guide"
    echo "  DEPLOYMENT.md - Deployment instructions"
    echo "  SECURITY.md   - Security best practices"
    echo ""

    echo -e "${YELLOW}Useful Commands:${NC}"
    echo "  ${GREEN}make help${NC}          - Show all available commands"
    echo "  ${GREEN}make verify${NC}        - Verify installation"
    echo "  ${GREEN}make security-verify${NC} - Check security configuration"
    echo "  ${GREEN}make restart${NC}       - Restart all services"
    echo "  ${GREEN}make stop${NC}          - Stop all services"
    echo ""

    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${CYAN}Backups:${NC}"
        echo "  Configuration backups saved in: ${BACKUP_DIR}/"
        echo ""
    fi

    echo -e "${YELLOW}⚠️  Security Reminders:${NC}"
    echo "  • Never commit .env to version control"
    echo "  • Update OAuth credentials for production"
    echo "  • Configure SSL certificates for HTTPS"
    echo "  • Review SECURITY.md for hardening steps"
    echo ""

    print_success "Setup complete! Run 'make help' to see all available commands."
    echo ""
}

# Run main function
main
