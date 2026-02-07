# OpenClaw Gateway Dockerfile (pnpm monorepo)
# Multi-stage build for production deployment

# Stage 1: Dependencies
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat python3 make g++
WORKDIR /monorepo

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

# Copy monorepo root files
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml .npmrc ./
COPY apps/gateway/package.json ./apps/gateway/

# Install production dependencies only
RUN pnpm install --frozen-lockfile --filter @openclaw/gateway... --prod

# Stage 2: Builder
FROM node:20-alpine AS builder
WORKDIR /monorepo

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

# Copy dependencies from deps stage
COPY --from=deps /monorepo ./

# Copy app source
COPY apps/gateway ./apps/gateway/

# Build if needed (uncomment if TypeScript or build step required)
# WORKDIR /monorepo/apps/gateway
# RUN pnpm build

# Stage 3: Runner
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Create non-root user with access to docker socket
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 gateway
# Add gateway user to root group for Docker socket access (macOS Docker Desktop)
RUN adduser gateway root

# Copy node_modules and app from builder
COPY --from=builder /monorepo/node_modules ./node_modules
COPY --from=builder /monorepo/apps/gateway ./

# Change ownership
RUN chown -R gateway:nodejs /app

USER gateway

EXPOSE 18789

ENV PORT=18789
ENV HOSTNAME="0.0.0.0"

# Start the gateway
CMD ["node", "index.js"]
