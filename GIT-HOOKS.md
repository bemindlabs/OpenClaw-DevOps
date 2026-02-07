# Git Hooks Configuration

This project uses **Husky** and **lint-staged** to enforce code quality before commits and pushes.

## Installed Hooks

### Pre-commit Hook

Runs automatically before each commit to ensure code quality:

1. **lint-staged** - Lints and formats only staged files:
   - `.{js,jsx,ts,tsx}` files → ESLint with auto-fix
   - `.{json,md,yml,yaml}` files → Prettier formatting

2. **Type Check** - Validates TypeScript across all workspaces:
   ```bash
   pnpm typecheck
   ```

### Pre-push Hook

Runs before pushing to remote repository:

1. **Build Validation** - Ensures all apps compile successfully:
   ```bash
   pnpm build:all
   ```

This catches build errors before they reach CI/CD.

## Manual Execution

You can run these checks manually anytime:

```bash
# Lint staged files
pnpm lint-staged

# Type check all workspaces
pnpm typecheck

# Build all apps
pnpm build:all

# Lint all files (not just staged)
pnpm lint:all
```

## Configuration Files

- `.husky/pre-commit` - Pre-commit hook script
- `.husky/pre-push` - Pre-push hook script
- `.prettierrc` - Prettier formatting rules
- `.prettierignore` - Files excluded from Prettier
- `package.json` - lint-staged configuration

## Skipping Hooks (Not Recommended)

In rare cases where you need to bypass hooks:

```bash
# Skip pre-commit
git commit --no-verify -m "message"

# Skip pre-push
git push --no-verify
```

⚠️ **Warning:** Only use `--no-verify` when absolutely necessary. Bypassing hooks can lead to broken builds and code quality issues.

## Troubleshooting

### Hook Not Running

If hooks aren't executing:

```bash
# Reinstall husky
rm -rf .husky
pnpm prepare

# Verify hooks are executable
chmod +x .husky/pre-commit .husky/pre-push
```

### Type Check Failures

If type checking fails:

```bash
# Check which workspace has issues
cd apps/landing && pnpm exec tsc --noEmit
cd apps/assistant && pnpm exec tsc --noEmit
cd apps/openclaw-gateway && pnpm exec tsc --noEmit
```

### Build Failures

If pre-push build fails:

```bash
# Test each app individually
pnpm build:landing
pnpm build:assistant
pnpm build:gateway
```

### Lint-staged Issues

If lint-staged fails:

```bash
# Check ESLint configuration
pnpm lint:all

# Format all files manually
pnpm exec prettier --write "**/*.{json,md,yml,yaml}"
```

## CI/CD Integration

These same checks run in CI/CD pipelines. The hooks ensure:
- Faster feedback (catch issues locally)
- Reduced CI/CD failures
- Consistent code quality across the team

## Team Setup

After cloning the repository:

```bash
# Install dependencies (automatically sets up hooks)
pnpm install

# Hooks are now active! ✅
```

The `prepare` script in package.json automatically initializes Husky during `pnpm install`.

## Customization

To modify hook behavior:

1. **Add new checks** - Edit `.husky/pre-commit` or `.husky/pre-push`
2. **Change lint-staged rules** - Update `lint-staged` in `package.json`
3. **Adjust Prettier settings** - Modify `.prettierrc`

---

**Last Updated:** 2026-02-07
**Husky Version:** 9.1.7
**lint-staged Version:** 16.2.7
