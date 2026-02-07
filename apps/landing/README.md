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

### Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Open http://localhost:3000
```

### Production Build

```bash
# Build for production
npm run build

# Start production server
npm start
```

### Linting

```bash
# Run ESLint
npm run lint
```

## Docker Deployment

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
# Build the image
docker build -t openclaw-landing .

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
