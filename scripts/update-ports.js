#!/usr/bin/env node

/**
 * update-ports.js
 * Automated port configuration updater for OpenClaw DevOps platform
 * Reads ports.json and updates all configuration files automatically
 */

const fs = require('fs');
const path = require('path');

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

// Project paths
const PROJECT_ROOT = path.resolve(__dirname, '..');
const PORTS_FILE = path.join(PROJECT_ROOT, 'ports.json');
const ENV_EXAMPLE = path.join(PROJECT_ROOT, '.env.example');

// Counters
let filesUpdated = 0;
let filesSkipped = 0;
let errors = 0;

/**
 * Print colored message
 */
function print(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function printHeader(message) {
  print('', 'reset');
  print('━'.repeat(70), 'blue');
  print(`  ${message}`, 'blue');
  print('━'.repeat(70), 'blue');
}

function printSuccess(message) {
  print(`✅ ${message}`, 'green');
}

function printError(message) {
  print(`❌ ERROR: ${message}`, 'red');
  errors++;
}

function printWarning(message) {
  print(`⚠️  WARNING: ${message}`, 'yellow');
}

function printInfo(message) {
  print(`ℹ️  ${message}`, 'cyan');
}

/**
 * Load ports.json
 */
function loadPortsConfig() {
  try {
    const content = fs.readFileSync(PORTS_FILE, 'utf-8');
    return JSON.parse(content);
  } catch (error) {
    printError(`Failed to load ports.json: ${error.message}`);
    process.exit(1);
  }
}

/**
 * Create backup of file
 */
function backupFile(filePath) {
  const backupPath = `${filePath}.backup`;
  try {
    if (fs.existsSync(filePath)) {
      fs.copyFileSync(filePath, backupPath);
      printInfo(`Created backup: ${path.basename(backupPath)}`);
    }
  } catch (error) {
    printWarning(`Failed to create backup for ${filePath}: ${error.message}`);
  }
}

/**
 * Update .env.example with new port definitions
 */
function updateEnvExample(portsConfig) {
  printHeader('Updating .env.example');

  if (!fs.existsSync(ENV_EXAMPLE)) {
    printWarning('.env.example not found, skipping');
    filesSkipped++;
    return;
  }

  backupFile(ENV_EXAMPLE);

  try {
    let content = fs.readFileSync(ENV_EXAMPLE, 'utf-8');
    const lines = content.split('\n');
    const updatedLines = [];
    let inPortSection = false;
    let portSectionStart = -1;

    // Find port configuration section
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      // Detect start of port configuration section
      if (line.includes('# Port Configuration') || line.includes('# Ports')) {
        inPortSection = true;
        portSectionStart = i;
        updatedLines.push(line);
        updatedLines.push('# All services use ports in the 32100-32199 range');
        updatedLines.push('');
        continue;
      }

      // Detect end of port section (next major section or empty line pattern)
      if (inPortSection && (line.startsWith('# ') && !line.includes('PORT')) && portSectionStart !== -1) {
        inPortSection = false;
      }

      // If we're in port section, check if line contains a port env var
      if (inPortSection) {
        let lineUpdated = false;

        for (const [serviceName, serviceConfig] of Object.entries(portsConfig.services)) {
          const envVar = serviceConfig.envVar;
          if (envVar && line.startsWith(`${envVar}=`)) {
            updatedLines.push(`${envVar}=${serviceConfig.port}`);
            lineUpdated = true;
            break;
          }
        }

        if (!lineUpdated && !line.startsWith('#') && line.includes('PORT') && line.includes('=')) {
          // Keep the line but warn about unknown port variable
          updatedLines.push(line);
          const varName = line.split('=')[0];
          printWarning(`Unknown port variable found: ${varName}`);
        } else if (!lineUpdated) {
          updatedLines.push(line);
        }
      } else {
        updatedLines.push(line);
      }
    }

    // If no port section found, add one
    if (portSectionStart === -1) {
      printInfo('No port section found, adding new section');
      updatedLines.push('');
      updatedLines.push('# ============================================');
      updatedLines.push('# Port Configuration');
      updatedLines.push('# All services use ports in the 32100-32199 range');
      updatedLines.push('# ============================================');
      updatedLines.push('');

      // Add all port variables
      Object.entries(portsConfig.services)
        .filter(([_, config]) => config.envVar)
        .sort((a, b) => a[1].port - b[1].port)
        .forEach(([serviceName, serviceConfig]) => {
          updatedLines.push(`${serviceConfig.envVar}=${serviceConfig.port}`);
        });
    }

    fs.writeFileSync(ENV_EXAMPLE, updatedLines.join('\n'), 'utf-8');
    printSuccess('Updated .env.example');
    filesUpdated++;
  } catch (error) {
    printError(`Failed to update .env.example: ${error.message}`);
  }
}

/**
 * Update docker-compose.yml files
 */
function updateDockerCompose(portsConfig) {
  printHeader('Updating Docker Compose Files');

  const composeFiles = [
    'docker-compose.yml',
    'docker-compose.full.yml',
  ];

  composeFiles.forEach((filename) => {
    const filePath = path.join(PROJECT_ROOT, filename);

    if (!fs.existsSync(filePath)) {
      printWarning(`${filename} not found, skipping`);
      filesSkipped++;
      return;
    }

    backupFile(filePath);

    try {
      let content = fs.readFileSync(filePath, 'utf-8');
      let updated = false;

      // Update port mappings and environment variables
      Object.entries(portsConfig.services).forEach(([serviceName, serviceConfig]) => {
        const { port, oldPort, envVar } = serviceConfig;

        // Update port mappings: "oldPort:xxx" -> "newPort:newPort"
        if (oldPort) {
          const portMappingRegex = new RegExp(`['"]?${oldPort}:(\\d+)['"]?`, 'g');
          if (content.match(portMappingRegex)) {
            content = content.replace(portMappingRegex, `${port}:${port}`);
            updated = true;
          }
        }

        // Update environment variable references
        if (envVar) {
          const envVarRegex = new RegExp(`\\$\\{${envVar}:-\\d+\\}`, 'g');
          if (content.match(envVarRegex)) {
            content = content.replace(envVarRegex, `\${${envVar}:-${port}}`);
            updated = true;
          }
        }

        // Update health check URLs
        if (serviceConfig.healthCheck) {
          const oldHealthCheck = serviceConfig.healthCheck.replace(`:${port}`, `:${oldPort}`);
          if (content.includes(oldHealthCheck)) {
            content = content.replace(oldHealthCheck, serviceConfig.healthCheck);
            updated = true;
          }
        }
      });

      if (updated) {
        fs.writeFileSync(filePath, content, 'utf-8');
        printSuccess(`Updated ${filename}`);
        filesUpdated++;
      } else {
        printInfo(`No changes needed for ${filename}`);
        filesSkipped++;
      }
    } catch (error) {
      printError(`Failed to update ${filename}: ${error.message}`);
    }
  });
}

/**
 * Update nginx configuration files
 */
function updateNginxConfigs(portsConfig) {
  printHeader('Updating Nginx Configurations');

  const nginxConfDir = path.join(PROJECT_ROOT, 'nginx', 'conf.d');

  if (!fs.existsSync(nginxConfDir)) {
    printWarning('nginx/conf.d directory not found, skipping');
    filesSkipped++;
    return;
  }

  const confFiles = fs.readdirSync(nginxConfDir).filter(f => f.endsWith('.conf'));

  confFiles.forEach((filename) => {
    const filePath = path.join(nginxConfDir, filename);
    backupFile(filePath);

    try {
      let content = fs.readFileSync(filePath, 'utf-8');
      let updated = false;

      // Update upstream server definitions
      Object.entries(portsConfig.services).forEach(([serviceName, serviceConfig]) => {
        const { port, oldPort } = serviceConfig;

        if (oldPort) {
          // Update patterns like "landing:3000" -> "landing:32102"
          const upstreamRegex = new RegExp(`(${serviceName}):${oldPort}`, 'g');
          if (content.match(upstreamRegex)) {
            content = content.replace(upstreamRegex, `$1:${port}`);
            updated = true;
          }

          // Update patterns like "localhost:3000" -> "localhost:32102"
          const localhostRegex = new RegExp(`(localhost|127\\.0\\.0\\.1):${oldPort}`, 'g');
          if (content.match(localhostRegex)) {
            content = content.replace(localhostRegex, `$1:${port}`);
            updated = true;
          }
        }
      });

      if (updated) {
        fs.writeFileSync(filePath, content, 'utf-8');
        printSuccess(`Updated nginx/${filename}`);
        filesUpdated++;
      } else {
        printInfo(`No changes needed for nginx/${filename}`);
        filesSkipped++;
      }
    } catch (error) {
      printError(`Failed to update nginx/${filename}: ${error.message}`);
    }
  });
}

/**
 * Update Prometheus configuration
 */
function updatePrometheus(portsConfig) {
  printHeader('Updating Prometheus Configuration');

  const prometheusConfig = path.join(PROJECT_ROOT, 'monitoring', 'prometheus', 'prometheus.yml');

  if (!fs.existsSync(prometheusConfig)) {
    printWarning('prometheus.yml not found, skipping');
    filesSkipped++;
    return;
  }

  backupFile(prometheusConfig);

  try {
    let content = fs.readFileSync(prometheusConfig, 'utf-8');
    let updated = false;

    // Update scrape targets
    Object.entries(portsConfig.services).forEach(([serviceName, serviceConfig]) => {
      const { port, oldPort } = serviceConfig;

      if (oldPort) {
        // Update patterns like "localhost:9090" -> "localhost:32160"
        const targetRegex = new RegExp(`(localhost|127\\.0\\.0\\.1):${oldPort}`, 'g');
        if (content.match(targetRegex)) {
          content = content.replace(targetRegex, `$1:${port}`);
          updated = true;
        }
      }
    });

    if (updated) {
      fs.writeFileSync(prometheusConfig, content, 'utf-8');
      printSuccess('Updated prometheus.yml');
      filesUpdated++;
    } else {
      printInfo('No changes needed for prometheus.yml');
      filesSkipped++;
    }
  } catch (error) {
    printError(`Failed to update prometheus.yml: ${error.message}`);
  }
}

/**
 * Update Makefile
 */
function updateMakefile(portsConfig) {
  printHeader('Updating Makefile');

  const makefilePath = path.join(PROJECT_ROOT, 'Makefile');

  if (!fs.existsSync(makefilePath)) {
    printWarning('Makefile not found, skipping');
    filesSkipped++;
    return;
  }

  backupFile(makefilePath);

  try {
    let content = fs.readFileSync(makefilePath, 'utf-8');
    let updated = false;

    // Update URL references and health check endpoints
    Object.entries(portsConfig.services).forEach(([serviceName, serviceConfig]) => {
      const { port, oldPort } = serviceConfig;

      if (oldPort) {
        // Update localhost URLs
        const urlRegex = new RegExp(`(http://localhost):${oldPort}`, 'g');
        if (content.match(urlRegex)) {
          content = content.replace(urlRegex, `$1:${port}`);
          updated = true;
        }

        // Update HTTPS URLs
        const httpsRegex = new RegExp(`(https://localhost):${oldPort}`, 'g');
        if (content.match(httpsRegex)) {
          content = content.replace(httpsRegex, `$1:${port}`);
          updated = true;
        }
      }
    });

    if (updated) {
      fs.writeFileSync(makefilePath, content, 'utf-8');
      printSuccess('Updated Makefile');
      filesUpdated++;
    } else {
      printInfo('No changes needed for Makefile');
      filesSkipped++;
    }
  } catch (error) {
    printError(`Failed to update Makefile: ${error.message}`);
  }
}

/**
 * Generate PORT_MAP.md documentation
 */
function generatePortMap(portsConfig) {
  printHeader('Generating PORT_MAP.md');

  const portMapPath = path.join(PROJECT_ROOT, 'PORT_MAP.md');

  try {
    const lines = [];

    lines.push('# Port Mapping Reference');
    lines.push('');
    lines.push('This document provides a comprehensive reference for all port assignments in the OpenClaw DevOps platform.');
    lines.push('');
    lines.push(`**Last Updated:** ${new Date().toISOString().split('T')[0]}`);
    lines.push(`**Version:** ${portsConfig.version || '1.0.0'}`);
    lines.push('');
    lines.push('## Port Range');
    lines.push('');
    lines.push(`All services use ports in the range **${portsConfig.portRange.start}-${portsConfig.portRange.end}** (${portsConfig.portRange.total} ports total).`);
    lines.push('');
    lines.push('## Port Categories');
    lines.push('');

    Object.entries(portsConfig.categories).forEach(([category, config]) => {
      lines.push(`- **${category}** (${config.range}): ${config.description}`);
    });

    lines.push('');
    lines.push('## Complete Port Mapping');
    lines.push('');
    lines.push('| Service | Old Port | New Port | Env Variable | Health Check | External |');
    lines.push('|---------|----------|----------|--------------|--------------|----------|');

    // Sort services by new port number
    const sortedServices = Object.entries(portsConfig.services)
      .sort((a, b) => a[1].port - b[1].port);

    sortedServices.forEach(([serviceName, config]) => {
      const healthCheck = config.healthCheck || 'N/A';
      const externalFacing = config.externalFacing ? '✅' : '❌';
      lines.push(`| ${config.name} | ${config.oldPort || 'N/A'} | ${config.port} | ${config.envVar || 'N/A'} | ${healthCheck} | ${externalFacing} |`);
    });

    lines.push('');
    lines.push('## Migration Guide');
    lines.push('');
    lines.push('### Quick Reference (Old → New)');
    lines.push('');
    lines.push('```');

    sortedServices
      .filter(([_, config]) => config.oldPort)
      .forEach(([_, config]) => {
        lines.push(`${config.name.padEnd(25)} ${config.oldPort.toString().padEnd(8)} → ${config.port}`);
      });

    lines.push('```');
    lines.push('');
    lines.push('## Visual Port Range Diagram');
    lines.push('');
    lines.push('```');
    lines.push('32100-32119: Core Applications');
    lines.push('  ├─ 32100  Nginx HTTP');
    lines.push('  ├─ 32101  Nginx HTTPS');
    lines.push('  ├─ 32102  Landing Page');
    lines.push('  ├─ 32103  Admin Assistant');
    lines.push('  ├─ 32104  Gateway');
    lines.push('  ├─ 32105  Portainer');
    lines.push('  └─ 32106  Portainer Edge');
    lines.push('');
    lines.push('32120-32139: Databases');
    lines.push('  ├─ 32120  MongoDB');
    lines.push('  ├─ 32121  PostgreSQL');
    lines.push('  └─ 32122  Redis');
    lines.push('');
    lines.push('32140-32159: Messaging & Workflows');
    lines.push('  ├─ 32140  Zookeeper');
    lines.push('  ├─ 32141  Kafka');
    lines.push('  └─ 32142  n8n');
    lines.push('');
    lines.push('32160-32179: Monitoring & Metrics');
    lines.push('  ├─ 32160  Prometheus');
    lines.push('  ├─ 32161  Grafana');
    lines.push('  ├─ 32162  Node Exporter');
    lines.push('  ├─ 32163  cAdvisor');
    lines.push('  ├─ 32164  Redis Exporter');
    lines.push('  ├─ 32165  PostgreSQL Exporter');
    lines.push('  └─ 32166  MongoDB Exporter');
    lines.push('');
    lines.push('32180-32189: Optional Services (Reserved)');
    lines.push('32190-32199: Future Expansion (Reserved)');
    lines.push('```');
    lines.push('');
    lines.push('## Health Check URLs');
    lines.push('');

    sortedServices
      .filter(([_, config]) => config.healthCheck)
      .forEach(([_, config]) => {
        lines.push(`- **${config.name}**: ${config.healthCheck}`);
      });

    lines.push('');
    lines.push('## Port Allocation Status');
    lines.push('');

    Object.entries(portsConfig.categories).forEach(([category, config]) => {
      const [start, end] = config.range.split('-').map(Number);
      const total = end - start + 1;
      const allocated = Object.values(portsConfig.services)
        .filter(s => s.category === category)
        .length;
      const available = total - allocated;

      lines.push(`**${category}**: ${allocated}/${total} ports allocated (${available} available)`);
    });

    lines.push('');
    lines.push('---');
    lines.push('');
    lines.push('_Auto-generated from ports.json by update-ports.js_');

    fs.writeFileSync(portMapPath, lines.join('\n'), 'utf-8');
    printSuccess('Generated PORT_MAP.md');
    filesUpdated++;
  } catch (error) {
    printError(`Failed to generate PORT_MAP.md: ${error.message}`);
  }
}

/**
 * Main function
 */
function main() {
  print('', 'reset');
  print('╔═══════════════════════════════════════════════════════════════╗', 'blue');
  print('║         OpenClaw Port Configuration Updater                  ║', 'blue');
  print('╚═══════════════════════════════════════════════════════════════╝', 'blue');

  // Load ports configuration
  printInfo('Loading ports.json...');
  const portsConfig = loadPortsConfig();
  printSuccess(`Loaded ${Object.keys(portsConfig.services).length} service definitions`);

  // Run all updates
  updateEnvExample(portsConfig);
  updateDockerCompose(portsConfig);
  updateNginxConfigs(portsConfig);
  updatePrometheus(portsConfig);
  updateMakefile(portsConfig);
  generatePortMap(portsConfig);

  // Summary
  printHeader('Update Summary');
  print('');
  printInfo(`Files updated: ${filesUpdated}`);
  printInfo(`Files skipped: ${filesSkipped}`);

  if (errors > 0) {
    printError(`Completed with ${errors} error(s)`);
    process.exit(1);
  } else {
    printSuccess('All updates completed successfully!');
    print('');
    printInfo('Next steps:');
    printInfo('  1. Review the changes with: git diff');
    printInfo('  2. Run validation: ./scripts/validate-ports.sh');
    printInfo('  3. Test locally: docker-compose config');
    process.exit(0);
  }
}

// Run main function
main();
