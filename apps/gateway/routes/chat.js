/**
 * Chat Routes
 * REST API endpoints for chat functionality
 */

const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const intentParser = require('../services/intent-parser');
const dockerManager = require('../services/docker-manager');

// In-memory chat history (replace with MongoDB in production)
let chatHistory = [];
const MAX_HISTORY = 1000;

/**
 * POST /api/chat/message
 * Process a chat message and execute commands
 */
router.post('/message', async (req, res) => {
  const { message, sessionId, userId } = req.body;

  if (!message) {
    return res.status(400).json({
      success: false,
      error: 'Message is required'
    });
  }

  const messageId = uuidv4();
  const timestamp = new Date().toISOString();

  try {
    // Parse intent
    const intent = intentParser.parse(message);

    let response = '';
    let executedCommand = null;
    let commandOutput = null;

    // Execute based on intent
    switch (intent.action) {
      case 'help':
        response = intentParser.getHelpText();
        break;

      case 'status':
        if (intent.service === 'all') {
          const allStatus = await dockerManager.getAllServicesStatus();
          const running = Object.values(allStatus).filter(s => s.running).length;
          const total = Object.keys(allStatus).length;
          response = `Services: ${running}/${total} running\n\n`;

          for (const [name, status] of Object.entries(allStatus)) {
            const icon = status.running ? '🟢' : '🔴';
            response += `${icon} ${name}: ${status.status} (${status.health})\n`;
          }
        } else {
          const status = await dockerManager.getServiceStatus(intent.service);
          const icon = status.running ? '🟢' : '🔴';
          response = `${icon} ${status.service}: ${status.status}\n`;
          response += `Health: ${status.health}\n`;
          if (status.uptime) {
            response += `Uptime: ${formatUptime(status.uptime)}\n`;
          }
          if (status.restarts > 0) {
            response += `Restarts: ${status.restarts}\n`;
          }
        }
        break;

      case 'start':
        executedCommand = `docker-compose start ${intent.service}`;
        try {
          const result = await dockerManager.startService(intent.service);
          commandOutput = result.output;
          response = `✅ Started ${intent.service} successfully`;
        } catch (error) {
          response = `❌ Failed to start ${intent.service}: ${error.error || error.message}`;
        }
        break;

      case 'stop':
        executedCommand = `docker-compose stop ${intent.service}`;
        try {
          const result = await dockerManager.stopService(intent.service);
          commandOutput = result.output;
          response = `✅ Stopped ${intent.service} successfully`;
        } catch (error) {
          response = `❌ Failed to stop ${intent.service}: ${error.error || error.message}`;
        }
        break;

      case 'restart':
        executedCommand = `docker-compose restart ${intent.service}`;
        try {
          const result = await dockerManager.restartService(intent.service);
          commandOutput = result.output;
          response = `✅ Restarted ${intent.service} successfully`;
        } catch (error) {
          response = `❌ Failed to restart ${intent.service}: ${error.error || error.message}`;
        }
        break;

      case 'logs':
        response = `📋 Log streaming for ${intent.service} - connect via WebSocket to receive real-time logs`;
        break;

      case 'unknown':
        if (intent.error) {
          response = `⚠️ ${intent.error}\n`;
          if (intent.suggestions) {
            response += `Did you mean: ${intent.suggestions.join(', ')}?`;
          }
        } else {
          response = `❓ I didn't understand that command.\n\n${intentParser.getHelpText()}`;
        }
        break;

      default:
        response = `Unknown action: ${intent.action}`;
    }

    // Save to history
    const chatMessage = {
      id: messageId,
      sessionId: sessionId || 'default',
      userId: userId || 'anonymous',
      message,
      intent,
      response,
      executedCommand,
      commandOutput,
      timestamp
    };

    chatHistory.push(chatMessage);

    // Trim history if needed
    if (chatHistory.length > MAX_HISTORY) {
      chatHistory = chatHistory.slice(-MAX_HISTORY);
    }

    res.json({
      success: true,
      id: messageId,
      response,
      intent: {
        action: intent.action,
        service: intent.service,
        confidence: intent.confidence
      },
      executedCommand,
      timestamp
    });

  } catch (error) {
    console.error('Error processing chat message:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * GET /api/chat/history
 * Get chat history
 */
router.get('/history', (req, res) => {
  const limit = parseInt(req.query.limit) || 50;
  const sessionId = req.query.sessionId;

  let history = chatHistory;

  if (sessionId) {
    history = history.filter(h => h.sessionId === sessionId);
  }

  res.json({
    success: true,
    messages: history.slice(-limit),
    total: history.length,
    timestamp: new Date().toISOString()
  });
});

/**
 * DELETE /api/chat/history
 * Clear chat history
 */
router.delete('/history', (req, res) => {
  const sessionId = req.query.sessionId;

  if (sessionId) {
    chatHistory = chatHistory.filter(h => h.sessionId !== sessionId);
  } else {
    chatHistory = [];
  }

  res.json({
    success: true,
    message: 'Chat history cleared',
    timestamp: new Date().toISOString()
  });
});

/**
 * Format uptime in human-readable format
 */
function formatUptime(seconds) {
  if (seconds < 60) return `${seconds}s`;
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m ${seconds % 60}s`;
  if (seconds < 86400) {
    const hours = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    return `${hours}h ${mins}m`;
  }
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  return `${days}d ${hours}h`;
}

module.exports = router;
