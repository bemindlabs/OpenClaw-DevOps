# OpenClaw Gateway

AI Agent Platform Gateway Service

## Features

- RESTful API endpoints
- Health check monitoring
- CORS enabled
- Docker support
- Production-ready

## Development

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Run in production mode
npm start
```

## Docker

```bash
# Build image
docker build -t openclaw-gateway:latest .

# Run container
docker run -p 18789:18789 openclaw-gateway:latest
```

## Environment Variables

- `PORT` - Server port (default: 18789)
- `HOSTNAME` - Server host (default: 0.0.0.0)
- `NODE_ENV` - Environment (development/production)

## Endpoints

- `GET /` - API information
- `GET /health` - Health check
- `GET /api/status` - Service status
