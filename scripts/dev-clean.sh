#!/bin/bash
#
# dev-clean.sh - Clean development artifacts before starting dev servers
#

# Remove Next.js dev lock files
find apps -name ".next" -type d -exec rm -rf {}/dev/lock \; 2>/dev/null || true

# Remove any stale PID files
find apps -name "*.pid" -delete 2>/dev/null || true

echo "✓ Dev environment cleaned"
