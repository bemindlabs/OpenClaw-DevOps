# Quick Start Guide

Get the OpenClaw landing page up and running in minutes.

## Prerequisites

- Node.js 20 or higher
- npm (comes with Node.js)

## Installation & Run

```bash
# Navigate to the project directory
cd /Users/lps/server/apps/landing

# Install dependencies (if not already installed)
npm install

# Start development server
npm run dev
```

Visit http://localhost:3000 to see the landing page.

## Production Deployment

### Option 1: Node.js (Recommended for quick testing)

```bash
# Build the project
npm run build

# Start production server
npm start
```

### Option 2: Docker (Recommended for production)

```bash
# Build and start with Docker Compose
docker-compose up -d

# Check logs
docker-compose logs -f

# Stop
docker-compose down
```

### Option 3: Docker (Manual)

```bash
# Build image
docker build -t openclaw-landing .

# Run container
docker run -d -p 3000:3000 --name openclaw-landing openclaw-landing

# Check logs
docker logs -f openclaw-landing

# Stop
docker stop openclaw-landing
docker rm openclaw-landing
```

## Project Files Overview

### Core Application Files
- `app/page.tsx` - Main landing page component
- `app/layout.tsx` - Root layout with metadata
- `app/globals.css` - Global styles and theme variables

### Component Files
- `components/ui/button.tsx` - Button component (shadcn/ui)
- `components/ui/card.tsx` - Card component (shadcn/ui)
- `lib/utils.ts` - Utility functions

### Configuration Files
- `next.config.ts` - Next.js configuration (standalone output enabled)
- `tsconfig.json` - TypeScript configuration
- `components.json` - shadcn/ui configuration
- `package.json` - Project dependencies

### Deployment Files
- `Dockerfile` - Multi-stage Docker build
- `docker-compose.yml` - Docker Compose configuration
- `.dockerignore` - Files to exclude from Docker build

## Common Commands

```bash
# Development
npm run dev          # Start dev server (http://localhost:3000)

# Production
npm run build        # Build for production
npm start           # Start production server

# Code Quality
npm run lint        # Run ESLint

# Docker
docker-compose up -d              # Start in background
docker-compose logs -f            # View logs
docker-compose down               # Stop and remove
docker-compose up --build -d      # Rebuild and start
```

## Customization

### 1. Change Content
Edit `app/page.tsx` to modify:
- Hero section text
- Feature descriptions
- CTA button labels and actions

### 2. Update Colors
Edit CSS variables in `app/globals.css`:
```css
:root {
  --primary: 222.2 47.4% 11.2%;  /* Change primary color */
  --background: 0 0% 100%;        /* Change background */
}
```

### 3. Add More Components
```bash
# Add shadcn/ui components
npx shadcn@latest add [component-name]

# Examples:
npx shadcn@latest add input
npx shadcn@latest add form
npx shadcn@latest add dialog
```

### 4. Update Metadata
Edit `app/layout.tsx` to change SEO metadata:
```typescript
export const metadata: Metadata = {
  title: "Your Title",
  description: "Your description",
}
```

## Troubleshooting

### Port 3000 already in use
```bash
# Find and kill the process
lsof -ti:3000 | xargs kill -9

# Or use a different port
PORT=3001 npm run dev
```

### Build errors
```bash
# Clear Next.js cache
rm -rf .next

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Rebuild
npm run build
```

### Docker issues
```bash
# Remove existing containers
docker-compose down -v

# Clear Docker build cache
docker system prune -a

# Rebuild from scratch
docker-compose build --no-cache
docker-compose up -d
```

## Next Steps

1. Customize the content and design
2. Add more pages (create files in `app/` directory)
3. Set up environment variables in `.env.local`
4. Configure your domain and deploy
5. Add analytics and monitoring

For more details, see the main [README.md](./README.md).
