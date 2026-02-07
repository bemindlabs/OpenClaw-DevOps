# Multi-stage Dockerfile for Next.js 16 production build (pnpm monorepo)

# Stage 1: Dependencies
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /monorepo

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

# Copy monorepo root files
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml .npmrc ./
COPY apps/landing/package.json ./apps/landing/

# Install dependencies
RUN pnpm install --frozen-lockfile --filter @openclaw/landing...

# Stage 2: Builder
FROM node:20-alpine AS builder
WORKDIR /monorepo

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

# Copy dependencies from deps stage
COPY --from=deps /monorepo ./

# Copy app source
COPY apps/landing ./apps/landing/

# Build Next.js app
ENV NEXT_TELEMETRY_DISABLED=1
WORKDIR /monorepo/apps/landing
RUN pnpm build

# Stage 3: Runner
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files from builder
COPY --from=builder /monorepo/apps/landing/public ./public
COPY --from=builder --chown=nextjs:nodejs /monorepo/apps/landing/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /monorepo/apps/landing/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
