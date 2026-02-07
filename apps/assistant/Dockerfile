# Multi-stage Dockerfile for Next.js 16 production build (pnpm monorepo)

# Stage 1: Dependencies
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /monorepo

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

# Copy monorepo root files
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml .npmrc tsconfig.json ./
COPY apps/assistant/package.json ./apps/assistant/

# Install dependencies
RUN pnpm install --frozen-lockfile --filter @openclaw/assistant...

# Stage 2: Builder
FROM node:20-alpine AS builder
WORKDIR /monorepo

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

# Copy dependencies from deps stage
COPY --from=deps /monorepo ./

# Copy app source
COPY apps/assistant ./apps/assistant/

# Build Next.js app
ENV NEXT_TELEMETRY_DISABLED=1
WORKDIR /monorepo/apps/assistant
RUN pnpm build

# Stage 3: Runner
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy the entire standalone build (includes monorepo structure with symlinks intact)
COPY --from=builder --chown=nextjs:nodejs /monorepo/apps/assistant/.next/standalone ./
# Copy static files
COPY --from=builder --chown=nextjs:nodejs /monorepo/apps/assistant/.next/static ./apps/assistant/.next/static
# Copy public files
COPY --from=builder /monorepo/apps/assistant/public ./apps/assistant/public

USER nextjs

EXPOSE 5555

ENV PORT=5555
ENV HOSTNAME="0.0.0.0"

# Server.js is at apps/assistant/server.js in the standalone structure
CMD ["node", "apps/assistant/server.js"]
