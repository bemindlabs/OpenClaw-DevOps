/**
 * Socket.IO Server
 * Real-time communication for service updates and log streaming
 */

const dockerManager = require('../services/docker-manager');

// Active log streams by socket ID
const activeLogStreams = new Map();

/**
 * Initialize Socket.IO server
 */
function initializeSocket(io) {
  io.on('connection', (socket) => {
    console.log(`Socket connected: ${socket.id}`);

    // Send initial connection confirmation
    socket.emit('connected', {
      socketId: socket.id,
      timestamp: new Date().toISOString()
    });

    // Handle service status subscription
    socket.on('services:subscribe', async () => {
      try {
        const status = await dockerManager.getAllServicesStatus();
        socket.emit('services:status', {
          services: status,
          timestamp: new Date().toISOString()
        });
      } catch (error) {
        socket.emit('error', {
          type: 'services:status',
          error: error.message
        });
      }
    });

    // Handle individual service status request
    socket.on('service:status', async (data) => {
      try {
        const { service } = data;
        const status = await dockerManager.getServiceStatus(service);
        socket.emit('service:status', {
          ...status,
          timestamp: new Date().toISOString()
        });
      } catch (error) {
        socket.emit('error', {
          type: 'service:status',
          service: data.service,
          error: error.message
        });
      }
    });

    // Handle log stream subscription
    socket.on('logs:subscribe', async (data) => {
      try {
        const { service, tail = 100 } = data;

        // Stop any existing stream for this socket
        if (activeLogStreams.has(socket.id)) {
          const existingStream = activeLogStreams.get(socket.id);
          existingStream.destroy();
        }

        // Start new log stream
        const logStream = await dockerManager.streamLogs(service, socket, { tail });
        activeLogStreams.set(socket.id, logStream);

        socket.emit('logs:subscribed', {
          service,
          timestamp: new Date().toISOString()
        });
      } catch (error) {
        socket.emit('error', {
          type: 'logs:subscribe',
          service: data.service,
          error: error.message
        });
      }
    });

    // Handle log stream unsubscription
    socket.on('logs:unsubscribe', () => {
      if (activeLogStreams.has(socket.id)) {
        const stream = activeLogStreams.get(socket.id);
        stream.destroy();
        activeLogStreams.delete(socket.id);

        socket.emit('logs:unsubscribed', {
          timestamp: new Date().toISOString()
        });
      }
    });

    // Handle chat messages via WebSocket
    socket.on('chat:message', async (data) => {
      const { message, sessionId } = data;
      const intentParser = require('../services/intent-parser');

      try {
        const intent = intentParser.parse(message);

        // Emit intent parsing result
        socket.emit('chat:intent', {
          intent,
          timestamp: new Date().toISOString()
        });

        // If it's an action command, execute and emit result
        if (['start', 'stop', 'restart'].includes(intent.action) && intent.service) {
          socket.emit('chat:executing', {
            action: intent.action,
            service: intent.service,
            timestamp: new Date().toISOString()
          });

          try {
            let result;
            switch (intent.action) {
              case 'start':
                result = await dockerManager.startService(intent.service);
                break;
              case 'stop':
                result = await dockerManager.stopService(intent.service);
                break;
              case 'restart':
                result = await dockerManager.restartService(intent.service);
                break;
            }

            socket.emit('chat:response', {
              success: true,
              text: `✅ ${intent.action} ${intent.service} completed`,
              intent,
              result,
              timestamp: new Date().toISOString()
            });

            // Broadcast service status update to all clients
            const status = await dockerManager.getServiceStatus(intent.service);
            io.emit('service:updated', {
              service: intent.service,
              status,
              timestamp: new Date().toISOString()
            });

          } catch (error) {
            socket.emit('chat:response', {
              success: false,
              text: `❌ Failed to ${intent.action} ${intent.service}: ${error.message}`,
              intent,
              error: error.message,
              timestamp: new Date().toISOString()
            });
          }
        } else if (intent.action === 'status') {
          // Handle status requests
          const status = intent.service === 'all'
            ? await dockerManager.getAllServicesStatus()
            : await dockerManager.getServiceStatus(intent.service);

          socket.emit('chat:response', {
            success: true,
            text: 'Status retrieved',
            intent,
            data: status,
            timestamp: new Date().toISOString()
          });
        } else if (intent.action === 'help') {
          socket.emit('chat:response', {
            success: true,
            text: intentParser.getHelpText(),
            intent,
            timestamp: new Date().toISOString()
          });
        } else {
          socket.emit('chat:response', {
            success: false,
            text: intent.error || 'Unknown command',
            intent,
            suggestions: intent.suggestions,
            timestamp: new Date().toISOString()
          });
        }
      } catch (error) {
        socket.emit('chat:response', {
          success: false,
          text: `Error: ${error.message}`,
          timestamp: new Date().toISOString()
        });
      }
    });

    // Handle disconnect
    socket.on('disconnect', (reason) => {
      console.log(`Socket disconnected: ${socket.id} (${reason})`);

      // Clean up log stream
      if (activeLogStreams.has(socket.id)) {
        const stream = activeLogStreams.get(socket.id);
        stream.destroy();
        activeLogStreams.delete(socket.id);
      }
    });

    // Handle errors
    socket.on('error', (error) => {
      console.error(`Socket error (${socket.id}):`, error);
    });
  });

  // Periodic service status broadcast (every 30 seconds)
  setInterval(async () => {
    try {
      const status = await dockerManager.getAllServicesStatus();
      io.emit('services:status', {
        services: status,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      console.error('Error broadcasting service status:', error);
    }
  }, 30000);

  console.log('Socket.IO server initialized');
}

module.exports = { initializeSocket };
