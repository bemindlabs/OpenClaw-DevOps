/**
 * Service Management Routes
 * REST API endpoints for Docker service control
 */

const express = require('express');
const router = express.Router();
const dockerManager = require('../services/docker-manager');
const { requireAuth } = require('../middleware/auth');

// Middleware to validate service name
const validateService = (req, res, next) => {
  const { name } = req.params;
  const validServices = dockerManager.getValidServices();

  if (!validServices.includes(name)) {
    return res.status(400).json({
      success: false,
      error: `Invalid service: ${name}`,
      validServices: validServices
    });
  }

  next();
};

/**
 * GET /api/services/status
 * Get status of all services
 */
router.get('/status', async (req, res) => {
  try {
    const status = await dockerManager.getAllServicesStatus();
    res.json({
      success: true,
      services: status,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error getting services status:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * GET /api/services/list
 * Get list of valid services
 */
router.get('/list', (req, res) => {
  res.json({
    success: true,
    services: dockerManager.getValidServices(),
    categories: {
      core: ['nginx', 'landing', 'gateway', 'assistant'],
      databases: ['mongodb', 'postgres', 'redis'],
      messaging: ['kafka', 'zookeeper', 'n8n'],
      monitoring: ['prometheus', 'grafana', 'node-exporter', 'cadvisor', 'redis-exporter', 'postgres-exporter']
    }
  });
});

/**
 * GET /api/services/:name/status
 * Get status of a specific service
 */
router.get('/:name/status', validateService, async (req, res) => {
  try {
    const status = await dockerManager.getServiceStatus(req.params.name);
    res.json({
      success: true,
      ...status,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Error getting status for ${req.params.name}:`, error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * POST /api/services/:name/start
 * Start a service (requires authentication)
 */
router.post('/:name/start', requireAuth, validateService, async (req, res) => {
  try {
    const result = await dockerManager.startService(req.params.name);
    res.json({
      success: true,
      message: `Service ${req.params.name} started`,
      ...result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Error starting ${req.params.name}:`, error);
    res.status(500).json({
      success: false,
      error: error.message || error.error,
      output: error.stderr
    });
  }
});

/**
 * POST /api/services/:name/stop
 * Stop a service (requires authentication)
 */
router.post('/:name/stop', requireAuth, validateService, async (req, res) => {
  try {
    const result = await dockerManager.stopService(req.params.name);
    res.json({
      success: true,
      message: `Service ${req.params.name} stopped`,
      ...result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Error stopping ${req.params.name}:`, error);
    res.status(500).json({
      success: false,
      error: error.message || error.error,
      output: error.stderr
    });
  }
});

/**
 * POST /api/services/:name/restart
 * Restart a service (requires authentication)
 */
router.post('/:name/restart', requireAuth, validateService, async (req, res) => {
  try {
    const result = await dockerManager.restartService(req.params.name);
    res.json({
      success: true,
      message: `Service ${req.params.name} restarted`,
      ...result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Error restarting ${req.params.name}:`, error);
    res.status(500).json({
      success: false,
      error: error.message || error.error,
      output: error.stderr
    });
  }
});

/**
 * GET /api/services/health
 * Quick health check of Docker availability
 */
router.get('/health', async (req, res) => {
  try {
    const available = await dockerManager.isDockerAvailable();
    res.json({
      success: true,
      dockerAvailable: available,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      dockerAvailable: false,
      error: error.message
    });
  }
});

module.exports = router;
