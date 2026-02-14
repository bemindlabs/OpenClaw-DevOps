/**
 * OpenClaw DevOps Gateway
 * AI Agent Platform Gateway Service with Docker Management
 */

// Commented out dotenv - using Docker environment variables instead
// require('dotenv').config();

// DEBUG: Log environment variables at startup
console.log('[STARTUP DEBUG] OPENAI_API_KEY:', process.env.OPENAI_API_KEY ? `EXISTS (${process.env.OPENAI_API_KEY.substring(0,10)}...)` : 'MISSING');
console.log('[STARTUP DEBUG] LLM_PROVIDER:', process.env.LLM_PROVIDER);
console.log('[STARTUP DEBUG] All OPENAI env vars:', Object.keys(process.env).filter(k => k.includes('OPENAI')));

const express = require('express');
const cors = require('cors');
const { createServer } = require('http');
const { Server } = require('socket.io');

// Import routes
const servicesRoutes = require('./routes/services');
const chatRoutes = require('./routes/chat');

// Import socket handler
const { initializeSocket } = require('./socket/index');

// Initialize Express app
const app = express();
const httpServer = createServer(app);

// Configuration
const PORT = process.env.PORT || 32104;
const HOST = process.env.HOSTNAME || '0.0.0.0';
const NODE_ENV = process.env.NODE_ENV || 'development';

// Parse CORS origins from environment variable
const CORS_ORIGINS = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(',').map(origin => origin.trim())
  : (NODE_ENV === 'development' ? ['http://localhost:32102', 'http://localhost:32103'] : []);

// Initialize Socket.IO
const io = new Server(httpServer, {
  cors: {
    origin: CORS_ORIGINS.length > 0 ? CORS_ORIGINS : false,
    methods: ['GET', 'POST'],
    credentials: true
  },
  transports: ['websocket', 'polling'],
  pingTimeout: 60000,
  pingInterval: 25000
});

// Initialize socket handlers
initializeSocket(io);

// Middleware
app.use(cors({
  origin: CORS_ORIGINS.length > 0 ? CORS_ORIGINS : false,
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.path} ${res.statusCode} ${duration}ms`);
  });
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'openclaw-devops-gateway',
    version: '1.1.0',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    features: {
      rest: true,
      websocket: true,
      docker: true,
      chat: true
    }
  });
});

// API status endpoint
app.get('/api/status', (req, res) => {
  res.json({
    status: 'running',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    environment: NODE_ENV,
    connections: io.engine.clientsCount,
    timestamp: new Date().toISOString()
  });
});

// Root endpoint - API documentation
app.get('/', (req, res) => {
  res.json({
    name: 'OpenClaw DevOps Gateway',
    version: '1.1.0',
    description: 'AI Agent Platform Gateway with Docker Service Management',
    endpoints: {
      health: 'GET /health',
      status: 'GET /api/status',
      services: {
        list: 'GET /api/services/list',
        status: 'GET /api/services/status',
        serviceStatus: 'GET /api/services/:name/status',
        start: 'POST /api/services/:name/start',
        stop: 'POST /api/services/:name/stop',
        restart: 'POST /api/services/:name/restart',
        up: 'POST /api/services/:name/up',
        down: 'POST /api/services/:name/down',
        logs: 'GET /api/services/:name/logs',
        pull: 'POST /api/services/:name/pull',
        remove: 'DELETE /api/services/:name/remove'
      },
      chat: {
        message: 'POST /api/chat/message',
        history: 'GET /api/chat/history'
      }
    },
    websocket: {
      events: {
        subscribe: 'services:subscribe',
        status: 'service:status',
        logs: 'logs:subscribe',
        chat: 'chat:message'
      }
    },
    documentation: 'https://github.com/YOUR_ORG/openclaw-devops'
  });
});

// Mount routes
app.use('/api/services', servicesRoutes);
app.use('/api/chat', chatRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    method: req.method,
    message: 'The requested endpoint does not exist'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.name || 'Internal Server Error',
    message: err.message,
    ...(NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Start server
httpServer.listen(PORT, HOST, () => {
  console.log('');
  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║           OpenClaw DevOps Gateway v1.1.0                  ║');
  console.log('╠═══════════════════════════════════════════════════════════╣');
  console.log(`║  HTTP:      http://${HOST}:${PORT}                       ║`);
  console.log(`║  WebSocket: ws://${HOST}:${PORT}                         ║`);
  console.log(`║  Environment: ${NODE_ENV.padEnd(43)}║`);
  console.log('╠═══════════════════════════════════════════════════════════╣');
  console.log('║  Endpoints:                                               ║');
  console.log('║    GET  /health              Health check                 ║');
  console.log('║    GET  /api/services/status All services status          ║');
  console.log('║    POST /api/services/:name/restart  Restart service      ║');
  console.log('║    POST /api/chat/message    Process chat command         ║');
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('');
});

// Graceful shutdown
const shutdown = (signal) => {
  console.log(`\n${signal} received, shutting down gracefully...`);

  httpServer.close(() => {
    console.log('HTTP server closed');
    io.close(() => {
      console.log('Socket.IO server closed');
      process.exit(0);
    });
  });

  // Force close after 10 seconds
  setTimeout(() => {
    console.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

module.exports = { app, httpServer, io };
