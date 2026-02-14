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
// PROJECT_DIR should be the project root, not the gateway directory
const PROJECT_DIR = process.env.PROJECT_DIR || path.resolve(__dirname, '../../..');

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

  /**
   * Up a service (create and start)
   * Uses docker-compose up -d to create and start the service
   */
  async upService(serviceName) {
    if (!VALID_SERVICES.includes(serviceName)) {
      throw new Error(`Invalid service: ${serviceName}`);
    }

    // Check if already running
    const status = await this.getServiceStatus(serviceName);
    if (status.running) {
      return {
        success: true,
        message: `Service ${serviceName} is already running`,
        status: 'already_running',
        service: serviceName
      };
    }

    return this.runComposeCommandWithFlags('up', ['-d'], serviceName);
  }

  /**
   * Down a service (stop and remove)
   * Uses docker-compose down to stop and remove the service
   */
  async downService(serviceName) {
    if (!VALID_SERVICES.includes(serviceName)) {
      throw new Error(`Invalid service: ${serviceName}`);
    }

    // Check if service exists
    const status = await this.getServiceStatus(serviceName);
    if (status.status === 'not_found') {
      return {
        success: true,
        message: `Service ${serviceName} is not running`,
        status: 'not_found',
        service: serviceName
      };
    }

    return this.runComposeCommandWithFlags('down', [], serviceName);
  }

  /**
   * Get logs for a service (non-streaming, for HTTP)
   * Returns logs as an array of log lines
   */
  async getLogs(serviceName, options = { tail: 100, timestamps: true }) {
    const container = await this.getContainer(serviceName);

    if (!container) {
      throw new Error(`Service not found: ${serviceName}`);
    }

    const tail = Math.min(Math.max(options.tail || 100, 1), 10000);
    const timestamps = options.timestamps !== false;
    const since = options.since || 0;

    const logBuffer = await container.logs({
      follow: false,
      stdout: true,
      stderr: true,
      tail: tail,
      timestamps: timestamps,
      since: since
    });

    // Parse Docker log format (first 8 bytes are header)
    const logs = this.parseDockerLogs(logBuffer);

    return {
      success: true,
      service: serviceName,
      logs: logs,
      count: logs.length,
      options: { tail, timestamps, since }
    };
  }

  /**
   * Parse Docker log buffer
   * Docker logs have an 8-byte header: [stream_type(1), 0, 0, 0, size(4)]
   */
  parseDockerLogs(buffer) {
    const logs = [];

    if (!buffer || buffer.length === 0) {
      return logs;
    }

    // Convert buffer to string and split by newlines
    // Handle both raw string and multiplexed format
    const content = buffer.toString('utf8');

    // Simple approach: split by newlines and filter empty lines
    const lines = content.split('\n').filter(line => {
      // Filter out header bytes (non-printable characters at start)
      const cleaned = line.replace(/^[\x00-\x08]/g, '');
      return cleaned.trim().length > 0;
    });

    for (const line of lines) {
      // Clean any remaining header bytes
      const cleanedLine = line.replace(/^[\x00-\x08]+/g, '').trim();
      if (cleanedLine) {
        logs.push(cleanedLine);
      }
    }

    return logs;
  }

  /**
   * Remove a service (with volumes option)
   * Stops the container first, then removes it
   */
  async removeService(serviceName, options = { volumes: false, force: false }) {
    if (!VALID_SERVICES.includes(serviceName)) {
      throw new Error(`Invalid service: ${serviceName}`);
    }

    const container = await this.getContainer(serviceName);

    if (!container) {
      return {
        success: true,
        message: `Service ${serviceName} not found (already removed)`,
        status: 'not_found',
        service: serviceName
      };
    }

    const info = await container.inspect();
    const isRunning = info.State.Running;

    // Stop the container if running
    if (isRunning) {
      if (!options.force) {
        throw new Error(`Service ${serviceName} is running. Use force: true to stop and remove.`);
      }
      await container.stop({ t: 10 }); // 10 second timeout
    }

    // Remove the container
    await container.remove({
      v: options.volumes || false, // Remove volumes if specified
      force: options.force || false
    });

    return {
      success: true,
      message: `Service ${serviceName} removed successfully`,
      status: 'removed',
      service: serviceName,
      volumesRemoved: options.volumes
    };
  }

  /**
   * Pull latest image for a service
   */
  async pullImage(serviceName) {
    if (!VALID_SERVICES.includes(serviceName)) {
      throw new Error(`Invalid service: ${serviceName}`);
    }

    const container = await this.getContainer(serviceName);
    let imageName;

    if (container) {
      // Get image name from existing container
      const info = await container.inspect();
      imageName = info.Config.Image;
    } else {
      // Use service name mapping for common images
      const imageMap = {
        'nginx': 'nginx:alpine',
        'mongodb': 'mongo:7',
        'postgres': 'postgres:16-alpine',
        'redis': 'redis:7-alpine',
        'kafka': 'bitnami/kafka:latest',
        'zookeeper': 'bitnami/zookeeper:latest',
        'n8n': 'n8nio/n8n:latest',
        'prometheus': 'prom/prometheus:latest',
        'grafana': 'grafana/grafana:latest',
        'node-exporter': 'prom/node-exporter:latest',
        'cadvisor': 'gcr.io/cadvisor/cadvisor:latest',
        'redis-exporter': 'oliver006/redis_exporter:latest',
        'postgres-exporter': 'quay.io/prometheuscommunity/postgres-exporter:latest',
        // Custom images use local builds
        'landing': 'openclaw-landing:latest',
        'gateway': 'openclaw-gateway:latest',
        'assistant': 'openclaw-assistant:latest'
      };
      imageName = imageMap[serviceName];
    }

    if (!imageName) {
      throw new Error(`Cannot determine image for service: ${serviceName}`);
    }

    // Check if it's a local image (no registry prefix)
    const isLocalImage = imageName.startsWith('openclaw-');
    if (isLocalImage) {
      return {
        success: true,
        message: `Service ${serviceName} uses local image ${imageName}. Use docker build to update.`,
        status: 'local_image',
        service: serviceName,
        image: imageName,
        requiresBuild: true
      };
    }

    // Pull the image
    return new Promise((resolve, reject) => {
      docker.pull(imageName, (err, stream) => {
        if (err) {
          return reject({
            success: false,
            error: err.message,
            service: serviceName,
            image: imageName
          });
        }

        // Follow the pull progress
        const pullOutput = [];
        docker.modem.followProgress(stream, (err, output) => {
          if (err) {
            return reject({
              success: false,
              error: err.message,
              service: serviceName,
              image: imageName
            });
          }

          resolve({
            success: true,
            message: `Image ${imageName} pulled successfully`,
            status: 'pulled',
            service: serviceName,
            image: imageName,
            layers: output.length
          });
        }, (event) => {
          pullOutput.push(event);
        });
      });
    });
  }

  /**
   * Run a docker-compose command with additional flags
   * Uses spawn to prevent command injection
   */
  runComposeCommandWithFlags(action, flags, serviceName) {
    return new Promise((resolve, reject) => {
      // Validate action
      const allowedActions = ['start', 'stop', 'restart', 'up', 'down', 'pull', 'build'];
      if (!allowedActions.includes(action)) {
        return reject({
          success: false,
          error: `Invalid action: ${action}`,
          command: action
        });
      }

      // Validate flags (only allow known safe flags)
      const allowedFlags = ['-d', '--detach', '--no-deps', '--force-recreate', '--remove-orphans'];
      for (const flag of flags) {
        if (!allowedFlags.includes(flag)) {
          return reject({
            success: false,
            error: `Invalid flag: ${flag}`,
            command: action
          });
        }
      }

      // Build args array
      const args = ['-f', COMPOSE_FILE, action, ...flags];
      if (serviceName) {
        args.push(serviceName);
      }

      const child = spawn('docker-compose', args, {
        cwd: PROJECT_DIR,
        timeout: 120000 // 2 minute timeout for operations like pull
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
          command: action,
          flags: flags
        });
      });

      child.on('close', (code) => {
        if (code !== 0) {
          reject({
            success: false,
            error: `Command exited with code ${code}`,
            stderr: stderr,
            command: action,
            flags: flags
          });
        } else {
          resolve({
            success: true,
            output: stdout || stderr,
            command: action,
            flags: flags,
            service: serviceName
          });
        }
      });
    });
  }
}

module.exports = new DockerManager();
