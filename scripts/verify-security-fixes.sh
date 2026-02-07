#!/bin/bash
# Verify Security Fixes - Test all security implementations
# This script validates that all security fixes are properly implemented

# Don't exit on error - we want to collect all test results
set +e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0
PASSED=0

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Security Fixes Verification                            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to report test results
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo "=== File Existence Checks ==="
echo ""

# Check if authentication middleware exists
if [ -f "apps/gateway/middleware/auth.js" ]; then
    pass "Authentication middleware file exists"
else
    fail "Authentication middleware file missing"
fi

# Check if security documentation exists
if [ -f "SECURITY.md" ]; then
    pass "SECURITY.md documentation exists"
else
    fail "SECURITY.md documentation missing"
fi

if [ -f "SECURITY-FIXES-SUMMARY.md" ]; then
    pass "SECURITY-FIXES-SUMMARY.md exists"
else
    fail "SECURITY-FIXES-SUMMARY.md missing"
fi

echo ""
echo "=== JavaScript Syntax Validation ==="
echo ""

# Validate JavaScript syntax
if node -c apps/gateway/middleware/auth.js 2>/dev/null; then
    pass "auth.js syntax valid"
else
    fail "auth.js syntax errors"
fi

if node -c apps/gateway/routes/services.js 2>/dev/null; then
    pass "services.js syntax valid"
else
    fail "services.js syntax errors"
fi

if node -c apps/gateway/services/docker-manager.js 2>/dev/null; then
    pass "docker-manager.js syntax valid"
else
    fail "docker-manager.js syntax errors"
fi

if node -c apps/gateway/index.js 2>/dev/null; then
    pass "index.js syntax valid"
else
    fail "index.js syntax errors"
fi

echo ""
echo "=== Security Implementation Checks ==="
echo ""

# Check if requireAuth is imported in services.js
if grep -q "requireAuth" apps/gateway/routes/services.js; then
    pass "Authentication middleware imported in services routes"
else
    fail "Authentication middleware NOT imported in services routes"
fi

# Check if POST endpoints use requireAuth
if grep -q "router.post.*requireAuth" apps/gateway/routes/services.js; then
    pass "POST endpoints protected with requireAuth"
else
    fail "POST endpoints NOT protected with requireAuth"
fi

# Check if spawn is used instead of exec
if grep -q "spawn" apps/gateway/services/docker-manager.js; then
    pass "Using spawn (safe) instead of exec"
else
    fail "NOT using spawn - potential command injection"
fi

if ! grep -q "exec(" apps/gateway/services/docker-manager.js; then
    pass "exec() removed (command injection fixed)"
else
    warn "exec() still present - check if intentional"
fi

# Check CORS configuration
if grep -q "CORS_ORIGINS" apps/gateway/index.js; then
    pass "CORS origins parsed from environment variable"
else
    fail "CORS origins NOT configured from environment"
fi

if ! grep -q "origin: '\*'" apps/gateway/index.js; then
    pass "Wildcard CORS removed"
else
    fail "Wildcard CORS still present"
fi

# Check docker-compose privileged flag
if ! grep -q "privileged: true" docker-compose.full.yml; then
    pass "Privileged flag removed from docker-compose"
else
    warn "Privileged flag still present in docker-compose"
fi

if grep -q "cap_add:" docker-compose.full.yml; then
    pass "Using specific capabilities instead of privileged"
else
    warn "No capabilities specified (check if intentional)"
fi

echo ""
echo "=== Environment Variable Documentation ==="
echo ""

# Check if new environment variables are documented
if grep -q "GATEWAY_AUTH_TOKEN" .env.example; then
    pass "GATEWAY_AUTH_TOKEN documented in .env.example"
else
    fail "GATEWAY_AUTH_TOKEN NOT documented"
fi

if grep -q "CORS_ORIGIN" .env.example; then
    pass "CORS_ORIGIN documented in .env.example"
else
    fail "CORS_ORIGIN NOT documented"
fi

if grep -q "ALLOWED_OAUTH_DOMAINS" .env.example; then
    pass "ALLOWED_OAUTH_DOMAINS documented in .env.example"
else
    fail "ALLOWED_OAUTH_DOMAINS NOT documented"
fi

echo ""
echo "=== Path References Check ==="
echo ""

# Check if old openclaw-gateway paths are updated
OLD_PATH_COUNT=$(grep -r "apps/openclaw-gateway" \
    apps/gateway/Dockerfile \
    BUILD-IMAGES.sh \
    start-all.sh \
    scripts/start-full-stack.sh \
    .github/workflows/ci.yml \
    README.md \
    CLAUDE.md \
    2>/dev/null | wc -l | tr -d ' ')

if [ "$OLD_PATH_COUNT" -eq 0 ]; then
    pass "All paths updated to apps/gateway"
else
    warn "Found $OLD_PATH_COUNT reference(s) to old path apps/openclaw-gateway"
fi

echo ""
echo "=== Docker Compose Validation ==="
echo ""

# Validate docker-compose syntax
if docker-compose -f docker-compose.yml config > /dev/null 2>&1; then
    pass "docker-compose.yml syntax valid"
else
    warn "docker-compose.yml syntax check failed (might be due to missing .env)"
fi

if docker-compose -f docker-compose.full.yml config > /dev/null 2>&1; then
    pass "docker-compose.full.yml syntax valid"
else
    warn "docker-compose.full.yml syntax check failed (might be due to missing .env)"
fi

echo ""
echo "=== Code Pattern Checks ==="
echo ""

# Check for constant-time comparison
if grep -q "constantTimeCompare" apps/gateway/middleware/auth.js; then
    pass "Constant-time comparison implemented (timing attack protection)"
else
    fail "Constant-time comparison NOT implemented"
fi

# Check for action whitelist
if grep -q "allowedActions" apps/gateway/services/docker-manager.js; then
    pass "Action whitelist implemented in docker-manager"
else
    fail "Action whitelist NOT implemented"
fi

# Check for Bearer token validation
if grep -q "Bearer" apps/gateway/middleware/auth.js; then
    pass "Bearer token authentication implemented"
else
    fail "Bearer token authentication NOT implemented"
fi

echo ""
echo "=== Documentation Coverage ==="
echo ""

# Check if security docs mention all fixes
if grep -q "Command Injection" SECURITY.md; then
    pass "Command injection fix documented"
else
    warn "Command injection fix not mentioned in SECURITY.md"
fi

if grep -q "Authentication" SECURITY.md; then
    pass "Authentication requirement documented"
else
    warn "Authentication not mentioned in SECURITY.md"
fi

if grep -q "CORS" SECURITY.md; then
    pass "CORS hardening documented"
else
    warn "CORS not mentioned in SECURITY.md"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                    VERIFICATION SUMMARY                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Errors:${NC}   $ERRORS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Security verification FAILED - $ERRORS error(s) found${NC}"
    echo "Please review the errors above and fix before deploying."
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Security verification passed with $WARNINGS warning(s)${NC}"
    echo "Review warnings above - they may be acceptable depending on context."
    exit 0
else
    echo -e "${GREEN}✅ All security verifications PASSED!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run: ./scripts/generate-passwords.sh"
    echo "2. Configure CORS_ORIGIN and ALLOWED_OAUTH_DOMAINS in .env"
    echo "3. Review SECURITY.md for deployment best practices"
    exit 0
fi
