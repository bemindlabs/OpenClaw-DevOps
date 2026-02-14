#!/bin/bash

# validate-ports.sh
# Port configuration validation script for OpenClaw DevOps platform
# Checks for port conflicts, validates registry consistency, and generates validation report

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PORTS_FILE="$PROJECT_ROOT/ports.json"

# Validation counters
ERRORS=0
WARNINGS=0
INFO=0

# Function to print colored messages
print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    ((WARNINGS++))
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
    ((INFO++))
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check if ports.json exists
check_ports_file() {
    print_header "Checking Port Registry"

    if [ ! -f "$PORTS_FILE" ]; then
        print_error "ports.json not found at $PORTS_FILE"
        exit 1
    fi

    print_success "Found ports.json"

    # Validate JSON syntax
    if ! jq empty "$PORTS_FILE" 2>/dev/null; then
        print_error "ports.json contains invalid JSON"
        exit 1
    fi

    print_success "ports.json is valid JSON"
}

# Check for duplicate port assignments
check_duplicate_ports() {
    print_header "Checking for Duplicate Port Assignments"

    local duplicates=$(jq -r '.services | to_entries | map(.value.port) | group_by(.) | map(select(length > 1)) | .[]' "$PORTS_FILE" 2>/dev/null)

    if [ -n "$duplicates" ]; then
        print_error "Duplicate port assignments found:"
        echo "$duplicates" | while read -r port; do
            local services=$(jq -r ".services | to_entries | map(select(.value.port == $port) | .key) | join(\", \")" "$PORTS_FILE")
            echo "  Port $port: $services"
        done
    else
        print_success "No duplicate port assignments"
    fi
}

# Check if ports are within defined range
check_port_range() {
    print_header "Checking Port Range Compliance"

    local range_start=$(jq -r '.portRange.start' "$PORTS_FILE")
    local range_end=$(jq -r '.portRange.end' "$PORTS_FILE")

    print_info "Valid port range: $range_start-$range_end"

    jq -r '.services | to_entries[] | "\(.key):\(.value.port)"' "$PORTS_FILE" | while IFS=: read -r service port; do
        if [ "$port" -lt "$range_start" ] || [ "$port" -gt "$range_end" ]; then
            print_error "Service '$service' port $port is outside valid range ($range_start-$range_end)"
        fi
    done

    if [ $ERRORS -eq 0 ]; then
        print_success "All ports within valid range"
    fi
}

# Check for system port conflicts (macOS/Linux)
check_system_conflicts() {
    print_header "Checking for System Port Conflicts"

    local os_type=$(uname -s)

    jq -r '.services | to_entries[] | "\(.key):\(.value.port)"' "$PORTS_FILE" | while IFS=: read -r service port; do
        if [ "$os_type" = "Darwin" ]; then
            # macOS: use lsof
            if lsof -iTCP:"$port" -sTCP:LISTEN -t >/dev/null 2>&1; then
                local process=$(lsof -iTCP:"$port" -sTCP:LISTEN 2>/dev/null | tail -n 1 | awk '{print $1}')
                print_warning "Port $port ($service) is already in use by: $process"
            fi
        else
            # Linux: use ss or netstat
            if command -v ss >/dev/null 2>&1; then
                if ss -tuln | grep -q ":$port "; then
                    print_warning "Port $port ($service) is already in use"
                fi
            elif command -v netstat >/dev/null 2>&1; then
                if netstat -tuln | grep -q ":$port "; then
                    print_warning "Port $port ($service) is already in use"
                fi
            fi
        fi
    done

    if [ $WARNINGS -eq 0 ]; then
        print_success "No system port conflicts detected"
    fi
}

# Check environment variable consistency
check_env_vars() {
    print_header "Checking Environment Variable Consistency"

    local env_example="$PROJECT_ROOT/.env.example"

    if [ ! -f "$env_example" ]; then
        print_warning ".env.example not found, skipping env var validation"
        return
    fi

    jq -r '.services | to_entries[] | "\(.key):\(.value.envVar):\(.value.port)"' "$PORTS_FILE" | while IFS=: read -r service env_var port; do
        if [ -n "$env_var" ]; then
            if grep -q "^${env_var}=" "$env_example"; then
                local env_value=$(grep "^${env_var}=" "$env_example" | cut -d'=' -f2)
                if [ "$env_value" != "$port" ]; then
                    print_warning "Environment variable mismatch: $env_var=$env_value in .env.example, but ports.json defines $port"
                fi
            else
                print_warning "Environment variable $env_var not found in .env.example"
            fi
        fi
    done

    if [ $WARNINGS -eq 0 ]; then
        print_success "Environment variables are consistent"
    fi
}

# Check configuration file references
check_config_files() {
    print_header "Checking Configuration File References"

    jq -r '.services | to_entries[] | "\(.key):\(.value.configFiles[])"' "$PORTS_FILE" 2>/dev/null | while IFS=: read -r service config_file; do
        local file_path="$PROJECT_ROOT/$config_file"
        if [ ! -f "$file_path" ]; then
            print_warning "Config file not found for $service: $config_file"
        fi
    done

    if [ $WARNINGS -eq 0 ]; then
        print_success "All configuration files exist"
    fi
}

# Validate service dependencies
check_dependencies() {
    print_header "Checking Service Dependencies"

    local all_services=$(jq -r '.services | keys[]' "$PORTS_FILE")

    jq -r '.services | to_entries[] | "\(.key):\(.value.dependencies[])"' "$PORTS_FILE" 2>/dev/null | while IFS=: read -r service dependency; do
        if ! echo "$all_services" | grep -q "^${dependency}$"; then
            print_error "Service '$service' depends on undefined service: $dependency"
        fi
    done

    if [ $ERRORS -eq 0 ]; then
        print_success "All service dependencies are valid"
    fi
}

# Generate port allocation report
generate_report() {
    print_header "Port Allocation Report"

    echo ""
    printf "%-25s %-12s %-12s %-12s\n" "CATEGORY" "RANGE" "ALLOCATED" "AVAILABLE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    jq -r '.categories | to_entries[] | "\(.key):\(.value.range)"' "$PORTS_FILE" | while IFS=: read -r category range; do
        local start=$(echo "$range" | cut -d'-' -f1)
        local end=$(echo "$range" | cut -d'-' -f2)
        local total=$((end - start + 1))

        local allocated=$(jq -r ".services | to_entries[] | select(.value.category == \"$category\") | .key" "$PORTS_FILE" | wc -l | tr -d ' ')
        local available=$((total - allocated))

        printf "%-25s %-12s %-12s %-12s\n" "$category" "$range" "$allocated" "$available"
    done

    echo ""

    # Total statistics
    local total_services=$(jq -r '.services | length' "$PORTS_FILE")
    local total_ports=$(jq -r '.portRange.total' "$PORTS_FILE")
    local total_available=$((total_ports - total_services))

    print_info "Total Services: $total_services"
    print_info "Total Ports Available: $total_ports"
    print_info "Remaining Ports: $total_available"
}

# List all port mappings
list_ports() {
    print_header "Current Port Mappings"

    echo ""
    printf "%-25s %-12s %-12s %-20s\n" "SERVICE" "OLD PORT" "NEW PORT" "ENV VAR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    jq -r '.services | to_entries[] | "\(.value.name):\(.value.oldPort):\(.value.port):\(.value.envVar)"' "$PORTS_FILE" | \
        sort -t: -k3 -n | \
        while IFS=: read -r name old_port new_port env_var; do
            printf "%-25s %-12s %-12s %-20s\n" "$name" "$old_port" "$new_port" "$env_var"
        done

    echo ""
}

# Main validation function
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          OpenClaw Port Configuration Validator                ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"

    # Run all checks
    check_ports_file
    check_duplicate_ports
    check_port_range
    check_system_conflicts
    check_env_vars
    check_config_files
    check_dependencies
    generate_report
    list_ports

    # Summary
    print_header "Validation Summary"
    echo ""

    if [ $ERRORS -gt 0 ]; then
        print_error "Validation failed with $ERRORS error(s)"
        exit 1
    elif [ $WARNINGS -gt 0 ]; then
        print_warning "Validation completed with $WARNINGS warning(s)"
        exit 0
    else
        print_success "All validation checks passed!"
        exit 0
    fi
}

# Run main function
main
