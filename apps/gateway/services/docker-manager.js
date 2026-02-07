/**
 * Docker Manager Service
 * Manages Docker containers via Dockerode
 */

const Docker = require('dockerode');
const { spawn } = require('child_process');
const path = require('path');

// Initialize Docker connection
const docker = new Docker({ socketPath: '/var/run/docker.sock' });

// Service name to container name mapping
const SERVICE_MAP = {
  'nginx': 'openclaw-nginx',
  'landing': 'openclaw-landing',
  'gateway': 'openclaw-gateway',
  'assistant': 'openclaw-assistant',
  'mongodb': 'openclaw-mongodb',
  'postgres': 'openclaw-postgres',
  'redis': 'openclaw-redis',
  'kafka': 'openclaw-kafka',
  'zookeeper': 'openclaw-zookeeper',
  'n8n': 'openclaw-n8n',
  'prometheus': 'openclaw-prometheus',
  'grafana': 'openclaw-grafana',
  'node-exporter': 'openclaw-node-exporter',
  'cadvisor': 'openclaw-cadvisor',
  'redis-exporter': 'openclaw-redis-exporter',
  'postgres-exporter': 'openclaw-postgres-exporter'
};

// Valid service names
const VALID_SERVICES = Object.keys(SERVICE_MAP);

// Compose file path (use relative paths, not hardcoded absolute paths)
const COMPOSE_FILE = process.env.COMPOSE_FILE || 'docker-compose.full.yml';
const PROJECT_DIR = process.env.PROJECT_DIR || process.cwd();

class DockerManager {
  /**
   * Get container by service name
   */
  async getContainer(serviceName) {
    const containerName = SERVICE_MAP[serviceName];
    if (!containerName) {
      throw new Error(`Unknown service: ${serviceName}`);
    }

    const containers = await docker.listContainers({ all: true });
    const container = containers.find(c =>
      c.Names.some(n => n === `/${containerName}` || n === containerName)
    );

    if (!container) {
      return null;
    }

    return docker.getContainer(container.Id);
  }

  /**
   * Get status of a single service
   */
  async getServiceStatus(serviceName) {
    try {
      const container = await this.getContainer(serviceName);

      if (!container) {
        return {
          service: serviceName,
          status: 'not_found',
          health: 'unknown',
          running: false,
          container: null
        };
      }

      const info = await container.inspect();
      const state = info.State;

      return {
        service: serviceName,
        container: SERVICE_MAP[serviceName],
        status: state.Status,
        health: state.Health?.Status || 'no_healthcheck',
        running: state.Running,
        started: state.StartedAt,
        restarts: info.RestartCount || 0,
        uptime: state.Running ? this.calculateUptime(state.StartedAt) : 0,
        ports: this.extractPorts(info.NetworkSettings?.Ports || {}),
        image: info.Config?.Image
      };
    } catch (error) {
      return {
        service: serviceName,
        status: 'error',
        health: 'unknown',
        running: false,
        error: error.message
      };
    }
  }

  /**
   * Get status of all services
   */
  async getAllServicesStatus() {
    const results = {};

    for (const service of VALID_SERVICES) {
      results[service] = await this.getServiceStatus(service);
    }

    return results;
  }

  /**
   * Start a service using docker-compose
   */
  async startService(serviceName) {
    if (!VALID_SERVICES.includes(serviceName)) {
      throw new Error(`Invalid service: ${serviceName}`);
    }

    return this.runComposeCommand('start', serviceName);
  }

  /**
   * Stop a service using docker-compose
   */
  async stopService(serviceName) {
    if (!VALID_SERVICES.includes(serviceName)) {
      throw new Error(`Invalid service: ${serviceName}`);
    }

    return this.runComposeCommand('stop', serviceName);
  }

  /**
   * Restart a service using docker-compose
   */
  async restartService(serviceName) {
    if (!VALID_SERVICES.includes(serviceName)) {
      throw new Error(`Invalid service: ${serviceName}`);
    }

    return this.runComposeCommand('restart', serviceName);
  }

  /**
   * Run a docker-compose command (using spawn to prevent command injection)
   */
  runComposeCommand(action, serviceName) {
    return new Promise((resolve, reject) => {
      // Validate action to prevent command injection
      const allowedActions = ['start', 'stop', 'restart', 'up', 'down'];
      if (!allowedActions.includes(action)) {
        return reject({
          success: false,
          error: `Invalid action: ${action}`,
          command: action
        });
      }

      // Use spawn with array of arguments (prevents shell injection)
      const args = ['-f', COMPOSE_FILE, action, serviceName];
      const child = spawn('docker-compose', args, {
        cwd: PROJECT_DIR,
        timeout: 60000
      });

      let stdout = '';
      let stderr = '';

      child.stdout.on('data', (data) => {
        stdout += data.toString();
      });

      child.stderr.on('data', (data) => {
        stderr += data.toString();
      });

      child.on('error', (error) => {
        reject({
          success: false,
          error: error.message,
          stderr: stderr,
          command: action
        });
      });

      child.on('close', (code) => {
        if (code !== 0) {
          reject({
            success: false,
            error: `Command exited with code ${code}`,
            stderr: stderr,
            command: action
          });
        } else {
          resolve({
            success: true,
            output: stdout || stderr,
            command: action,
            service: serviceName
          });
        }
      });
    });
  }

  /**
   * Stream logs from a container
   */
  async streamLogs(serviceName, socket, options = {}) {
    const container = await this.getContainer(serviceName);

    if (!container) {
      throw new Error(`Service not found: ${serviceName}`);
    }

    const logStream = await container.logs({
      follow: true,
      stdout: true,
      stderr: true,
      tail: options.tail || 100,
      timestamps: true
    });

    logStream.on('data', (chunk) => {
      socket.emit('logs:stream', {
        service: serviceName,
        data: chunk.toString('utf8'),
        timestamp: new Date().toISOString()
      });
    });

    logStream.on('error', (err) => {
      socket.emit('logs:error', {
        service: serviceName,
        error: err.message
      });
    });

    return logStream;
  }

  /**
   * Calculate uptime in seconds
   */
  calculateUptime(startedAt) {
    const started = new Date(startedAt);
    const now = new Date();
    return Math.floor((now - started) / 1000);
  }

  /**
   * Extract port mappings
   */
  extractPorts(ports) {
    const result = {};
    for (const [container, bindings] of Object.entries(ports)) {
      if (bindings && bindings.length > 0) {
        result[container] = bindings.map(b => `${b.HostIp}:${b.HostPort}`);
      }
    }
    return result;
  }

  /**
   * Get list of valid services
   */
  getValidServices() {
    return VALID_SERVICES;
  }

  /**
   * Check if Docker is available
   */
  async isDockerAvailable() {
    try {
      await docker.ping();
      return true;
    } catch {
      return false;
    }
  }
}

module.exports = new DockerManager();
