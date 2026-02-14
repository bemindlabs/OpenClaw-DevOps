#!/bin/bash

# check-sensitive-data.sh
# Checks for sensitive data before commits to ensure open-source readiness
# This script prevents accidental commits of IPs, domains, secrets, etc.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
ERRORS=0
WARNINGS=0

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Checking for Sensitive Data (Open Source Compliance)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")

if [ -z "$STAGED_FILES" ]; then
    echo -e "${YELLOW}No staged files to check${NC}"
    exit 0
fi

echo -e "${BLUE}Checking staged files...${NC}"
echo ""

# Check 1: .env file
echo -e "${YELLOW}[1/8]${NC} Checking for .env file..."
if echo "$STAGED_FILES" | grep -q "^\.env$"; then
    echo -e "${RED}❌ ERROR: .env file is staged for commit${NC}"
    echo -e "${YELLOW}   → This file contains secrets and should NEVER be committed${NC}"
    echo -e "${YELLOW}   → Run: git reset HEAD .env${NC}"
    ((ERRORS++))
else
    echo -e "${GREEN}✅ No .env file in commit${NC}"
fi
echo ""

# Check 2: API Keys and Secrets
echo -e "${YELLOW}[2/8]${NC} Checking for API keys and secrets..."
SECRETS_FOUND=0
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        # Check for common API key patterns
        if grep -qE "(sk-[a-zA-Z0-9]{20,}|AIza[a-zA-Z0-9_-]{35}|ghp_[a-zA-Z0-9]{36}|xox[baprs]-[a-zA-Z0-9-]{10,})" "$file" 2>/dev/null; then
            echo -e "${RED}❌ ERROR: Potential API key found in: $file${NC}"
            ((ERRORS++))
            ((SECRETS_FOUND++))
        fi

        # Check for password patterns (not in .env.example)
        if [[ "$file" != ".env.example" ]] && [[ "$file" != *"/docs/"* ]]; then
            if grep -qE "(password['\"]?\s*[:=]\s*['\"][^'\"]{8,}['\"]|api_key['\"]?\s*[:=]\s*['\"][^'\"]{20,}['\"])" "$file" 2>/dev/null; then
                echo -e "${YELLOW}⚠️  WARNING: Potential hardcoded password in: $file${NC}"
                ((WARNINGS++))
            fi
        fi
    fi
done

if [ $SECRETS_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No API keys detected${NC}"
fi
echo ""

# Check 3: Real IP Addresses
echo -e "${YELLOW}[3/8]${NC} Checking for real IP addresses..."
IP_FOUND=0
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        # Skip allowed IPs (localhost, 0.0.0.0)
        if grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" "$file" 2>/dev/null | grep -vE "(127\.0\.0\.1|0\.0\.0\.0|localhost|255\.255\.255|192\.168\.|10\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.)" | grep -q .; then
            echo -e "${RED}❌ ERROR: Real IP address found in: $file${NC}"
            grep -nE "([0-9]{1,3}\.){3}[0-9]{1,3}" "$file" 2>/dev/null | grep -vE "(127\.0\.0\.1|0\.0\.0\.0|localhost|255\.255\.255|192\.168\.|10\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.)" | head -3
            ((ERRORS++))
            ((IP_FOUND++))
        fi
    fi
done

if [ $IP_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No real IPs detected${NC}"
fi
echo ""

# Check 4: Real Domain Names
echo -e "${YELLOW}[4/8]${NC} Checking for real domain names..."
DOMAIN_FOUND=0
EXCLUDED_DOMAINS="(your-domain\.com|example\.com|localhost|127\.0\.0\.1)"

for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        # Check for real domains (anything ending in .net, .com, .org except allowed ones)
        if grep -E "\b[a-zA-Z0-9-]+\.(net|com|org|io|dev|cloud)\b" "$file" 2>/dev/null | grep -vE "$EXCLUDED_DOMAINS" | grep -vE "(github\.com|docker\.com|nodejs\.org|npmjs\.com|yarnpkg\.com|anthropic\.com|openai\.com|mongodb\.com|postgresql\.org|redis\.io|nginx\.org|prometheus\.io)" | grep -q .; then
            echo -e "${YELLOW}⚠️  WARNING: Potential real domain in: $file${NC}"
            grep -nE "\b[a-zA-Z0-9-]+\.(net|com|org|io|dev|cloud)\b" "$file" 2>/dev/null | grep -vE "$EXCLUDED_DOMAINS" | grep -vE "(github\.com|docker\.com|nodejs\.org|npmjs\.com|yarnpkg\.com|anthropic\.com|openai\.com|mongodb\.com|postgresql\.org|redis\.io|nginx\.org|prometheus\.io)" | head -3
            ((WARNINGS++))
            ((DOMAIN_FOUND++))
        fi
    fi
done

if [ $DOMAIN_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No suspicious domains detected${NC}"
fi
echo ""

# Check 5: Absolute User Paths
echo -e "${YELLOW}[5/8]${NC} Checking for absolute user paths..."
PATH_FOUND=0
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        if grep -qE "/Users/[a-zA-Z0-9_-]+/|/home/[a-zA-Z0-9_-]+/" "$file" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  WARNING: Absolute user path in: $file${NC}"
            grep -nE "/Users/[a-zA-Z0-9_-]+/|/home/[a-zA-Z0-9_-]+/" "$file" 2>/dev/null | head -3
            ((WARNINGS++))
            ((PATH_FOUND++))
        fi
    fi
done

if [ $PATH_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No absolute user paths detected${NC}"
fi
echo ""

# Check 6: Email Addresses (non-generic)
echo -e "${YELLOW}[6/8]${NC} Checking for real email addresses..."
EMAIL_FOUND=0
EXCLUDED_EMAILS="(example\.com|your-email|admin@|noreply@|test@|user@localhost)"

for file in $STAGED_FILES; do
    if [ -f "$file" ] && [[ "$file" != "package-lock.json" ]] && [[ "$file" != "pnpm-lock.yaml" ]]; then
        if grep -E "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b" "$file" 2>/dev/null | grep -vE "$EXCLUDED_EMAILS" | grep -q .; then
            echo -e "${YELLOW}⚠️  WARNING: Potential real email in: $file${NC}"
            ((WARNINGS++))
            ((EMAIL_FOUND++))
        fi
    fi
done

if [ $EMAIL_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No suspicious emails detected${NC}"
fi
echo ""

# Check 7: Environment Variables in Code
echo -e "${YELLOW}[7/8]${NC} Checking for inline environment variables..."
INLINE_ENV_FOUND=0
for file in $STAGED_FILES; do
    if [[ "$file" =~ \.(js|ts|tsx|jsx)$ ]] && [ -f "$file" ]; then
        # Check for process.env assignments with actual values (not references)
        if grep -E "process\.env\.[A-Z_]+\s*=\s*['\"][^'\"]+['\"]" "$file" 2>/dev/null | grep -vq "process.env"; then
            echo -e "${YELLOW}⚠️  WARNING: Inline environment variable assignment in: $file${NC}"
            ((WARNINGS++))
            ((INLINE_ENV_FOUND++))
        fi
    fi
done

if [ $INLINE_ENV_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No inline environment variables detected${NC}"
fi
echo ""

# Check 8: Large Files
echo -e "${YELLOW}[8/8]${NC} Checking for large files..."
LARGE_FILES=0
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        if [ "$SIZE" -gt 1048576 ]; then  # 1MB
            echo -e "${YELLOW}⚠️  WARNING: Large file ($(($SIZE / 1024))KB): $file${NC}"
            ((WARNINGS++))
            ((LARGE_FILES++))
        fi
    fi
done

if [ $LARGE_FILES -eq 0 ]; then
    echo -e "${GREEN}✅ No large files detected${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Found $ERRORS error(s)${NC}"
    echo -e "${YELLOW}   Commit blocked - fix errors before committing${NC}"
    echo ""
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $WARNINGS warning(s)${NC}"
    echo -e "${YELLOW}   Review warnings - they may indicate sensitive data${NC}"
    echo ""
    echo -e "${BLUE}Proceed with commit? (y/N):${NC} "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Commit cancelled${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ All checks passed - safe to commit!${NC}"
    echo ""
fi

exit 0
