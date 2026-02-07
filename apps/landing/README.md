# OpenClaw Landing Page

Production-ready Next.js 15 landing page for the OpenClaw AI Agent Platform.

## Tech Stack

- **Next.js 15** - Latest App Router with React Server Components
- **TypeScript** - Type-safe development
- **Tailwind CSS v4** - Modern utility-first CSS framework
- **shadcn/ui** - High-quality React components
- **Lucide React** - Beautiful icon library

## Features

- Modern gradient design with slate/purple theme
- Fully responsive layout
- shadcn/ui components (Button, Card)
- Production-optimized build with standalone output
- Docker support for easy deployment
- SEO-friendly with proper metadata

## Getting Started

### Quick Start (Full Stack)

The easiest way to run the landing page with all OpenClaw services:

```bash
# From project root (/Users/lps/server/)
./start-all.sh

# This will:
# 1. Build all Docker images (landing, assistant, gateway, nginx)
# 2. Start all containers with docker-compose
# 3. Verify all services are running
# 4. Show service URLs and helpful commands

# Access the landing page at:
# http://localhost:3000
```

The quick start script uses `make` commands under the hood. See the root README for all available commands.

### Development (This App Only)

If you want to run just the landing page in development mode:

```bash
# Install dependencies (from monorepo root)
pnpm install

# Run landing dev server
pnpm dev:landing
# or from root:
make dev-landing

# Open http://localhost:3000
```

### Production Build (Standalone)

```bash
# Build for production
pnpm build

# Start production server
pnpm start
```

### Linting

```bash
# Run ESLint
pnpm lint
```

## Docker Deployment

### Quick Start Script (Recommended)

```bash
# From project root
./start-all.sh
```

This handles building, starting, and health checking all services.

### Build and Run with Docker Compose

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

### Build Docker Image Manually

```bash
# Build the image (from project root)
docker build -t openclaw-landing -f apps/landing/Dockerfile .

# Run the container
docker run -p 3000:3000 openclaw-landing
```

The Docker setup uses a multi-stage build for optimal image size and includes:
- Dependency caching for faster builds
- Non-root user for security
- Health checks
- Standalone output mode

## Project Structure

```
.
├── app/                    # Next.js App Router
│   ├── globals.css        # Global styles with shadcn theme
│   ├── layout.tsx         # Root layout
│   └── page.tsx           # Landing page
├── components/
│   └── ui/                # shadcn/ui components
│       ├── button.tsx
│       └── card.tsx
├── lib/
│   └── utils.ts           # Utility functions
├── public/                # Static assets
├── Dockerfile             # Multi-stage production build
├── docker-compose.yml     # Docker Compose configuration
└── next.config.ts         # Next.js configuration

```

## Configuration

### Next.js Configuration

The project is configured with:
- **Output**: `standalone` - Optimized for Docker deployment
- **TypeScript**: Strict type checking enabled
- **Turbopack**: Fast development builds (Next.js 15 default)

### shadcn/ui

Components are configured with:
- **Style**: New York
- **Base Color**: Slate
- **CSS Variables**: Enabled for theming
- **RSC**: React Server Components enabled

## Environment Variables

No environment variables are required for basic operation. Add any API keys or configuration in `.env.local`:

```bash
# Example
# NEXT_PUBLIC_API_URL=https://api.example.com
```

## Landing Page Sections

1. **Hero Section** - Main headline with CTA buttons
2. **Features Section** - 4 feature cards highlighting key benefits
3. **CTA Section** - Secondary call-to-action
4. **Footer** - Simple copyright notice

## Customization

### Update Colors

Edit the CSS variables in `app/globals.css`:

```css
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --primary: 222.2 47.4% 11.2%;
  /* ... */
}
```

### Add Components

Add new shadcn/ui components:

```bash
npx shadcn@latest add [component-name]
```

Available components: https://ui.shadcn.com/docs/components

## Performance

- **Lighthouse Score**: Optimized for Core Web Vitals
- **Bundle Size**: Minimal with code splitting
- **Image Optimization**: Next.js automatic image optimization
- **Static Generation**: Pre-rendered at build time

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## License

MIT

## Support

For issues or questions, please open an issue on GitHub.
