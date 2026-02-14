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

/**
 * POST /api/services/:name/up
 * Create and start a service (requires authentication)
 */
router.post('/:name/up', requireAuth, validateService, async (req, res) => {
  try {
    const result = await dockerManager.upService(req.params.name);
    res.json({
      success: true,
      message: `Service ${req.params.name} is up`,
      ...result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Error bringing up ${req.params.name}:`, error);
    res.status(500).json({
      success: false,
      error: error.message || error.error,
      output: error.stderr
    });
  }
});

/**
 * POST /api/services/:name/down
 * Stop and remove a service (requires authentication)
 */
router.post('/:name/down', requireAuth, validateService, async (req, res) => {
  try {
    const result = await dockerManager.downService(req.params.name);
    res.json({
      success: true,
      message: `Service ${req.params.name} is down`,
      ...result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Error bringing down ${req.params.name}:`, error);
    res.status(500).json({
      success: false,
      error: error.message || error.error,
      output: error.stderr
    });
  }
});

/**
 * GET /api/services/:name/logs
 * Get logs for a service
 */
router.get('/:name/logs', validateService, async (req, res) => {
  try {
    // Parse query parameters
    const options = {
      tail: parseInt(req.query.tail, 10) || 100,
      timestamps: req.query.timestamps !== 'false',
      since: parseInt(req.query.since, 10) || 0
    };

    const result = await dockerManager.getLogs(req.params.name, options);
    res.json({
      ...result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Error getting logs for ${req.params.name}:`, error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * DELETE /api/services/:name/remove
 * Remove a service (requires authentication)
 */
router.delete('/:name/remove', requireAuth, validateService, async (req, res) => {
  try {
    // Parse options from request body
    const options = {
      volumes: req.body?.volumes === true,
      force: req.body?.force === true
    };

    const result = await dockerManager.removeService(req.params.name, options);
    res.json({
      ...result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Error removing ${req.params.name}:`, error);
    res.status(500).json({
      success: false,
      error: error.message || error.error
    });
  }
});

/**
 * POST /api/services/:name/pull
 * Pull latest image for a service (requires authentication)
 */
router.post('/:name/pull', requireAuth, validateService, async (req, res) => {
  try {
    const result = await dockerManager.pullImage(req.params.name);
    res.json({
      ...result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Error pulling image for ${req.params.name}:`, error);
    res.status(500).json({
      success: false,
      error: error.message || error.error
    });
  }
});

module.exports = router;
