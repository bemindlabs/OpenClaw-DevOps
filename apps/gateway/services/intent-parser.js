/**
 * Intent Parser Service
 * Parses natural language commands into actions
 */

// Service aliases
const SERVICE_ALIASES = {
  'mongo': 'mongodb',
  'db': 'mongodb',
  'database': 'mongodb',
  'pg': 'postgres',
  'postgresql': 'postgres',
  'cache': 'redis',
  'web': 'nginx',
  'proxy': 'nginx',
  'frontend': 'landing',
  'landing-page': 'landing',
  'admin': 'assistant',
  'portal': 'assistant',
  'api': 'gateway',
  'metrics': 'prometheus',
  'dashboard': 'grafana',
  'workflow': 'n8n',
  'automation': 'n8n',
  'queue': 'kafka',
  'messaging': 'kafka',
  'zk': 'zookeeper'
};

// Action patterns
const ACTION_PATTERNS = {
  start: [
    /^start\s+(\w+)/i,
    /^run\s+(\w+)/i,
    /^boot\s+(\w+)/i,
    /^launch\s+(\w+)/i,
    /^up\s+(\w+)/i,
    /^bring\s+up\s+(\w+)/i
  ],
  stop: [
    /^stop\s+(\w+)/i,
    /^halt\s+(\w+)/i,
    /^kill\s+(\w+)/i,
    /^down\s+(\w+)/i,
    /^shutdown\s+(\w+)/i,
    /^bring\s+down\s+(\w+)/i
  ],
  restart: [
    /^restart\s+(\w+)/i,
    /^reboot\s+(\w+)/i,
    /^reload\s+(\w+)/i,
    /^bounce\s+(\w+)/i
  ],
  status: [
    /^status\s*(\w*)/i,
    /^check\s+(\w+)/i,
    /^show\s+status\s*(\w*)/i,
    /^how\s+is\s+(\w+)/i,
    /^is\s+(\w+)\s+running/i,
    /^what.s\s+the\s+status\s+of\s+(\w+)/i
  ],
  logs: [
    /^logs?\s+(\w+)/i,
    /^show\s+logs?\s+(?:for\s+)?(\w+)/i,
    /^tail\s+(\w+)/i,
    /^view\s+logs?\s+(?:for\s+)?(\w+)/i,
    /^get\s+logs?\s+(?:for\s+)?(\w+)/i
  ],
  help: [
    /^help$/i,
    /^commands$/i,
    /^what\s+can\s+you\s+do/i,
    /^\?$/
  ]
};

// Valid services
const VALID_SERVICES = [
  'nginx', 'landing', 'gateway', 'assistant',
  'mongodb', 'postgres', 'redis',
  'kafka', 'zookeeper', 'n8n',
  'prometheus', 'grafana', 'node-exporter',
  'cadvisor', 'redis-exporter', 'postgres-exporter'
];

class IntentParser {
  /**
   * Parse a message and extract intent
   */
  parse(message) {
    const normalizedMessage = message.trim().toLowerCase();

    // Check for help
    if (this.matchesHelp(normalizedMessage)) {
      return {
        action: 'help',
        service: null,
        confidence: 1.0,
        originalMessage: message
      };
    }

    // Try to match action patterns
    for (const [action, patterns] of Object.entries(ACTION_PATTERNS)) {
      if (action === 'help') continue;

      for (const pattern of patterns) {
        const match = normalizedMessage.match(pattern);
        if (match) {
          const serviceName = this.normalizeServiceName(match[1] || '');

          // For status without service, return all
          if (action === 'status' && !serviceName) {
            return {
              action: 'status',
              service: 'all',
              confidence: 0.9,
              originalMessage: message
            };
          }

          // Check if service is valid
          if (serviceName && VALID_SERVICES.includes(serviceName)) {
            return {
              action,
              service: serviceName,
              confidence: 0.95,
              originalMessage: message
            };
          } else if (serviceName) {
            // Unknown service
            return {
              action,
              service: serviceName,
              confidence: 0.5,
              error: `Unknown service: ${serviceName}`,
              suggestions: this.getSuggestions(serviceName),
              originalMessage: message
            };
          }
        }
      }
    }

    // No match found
    return {
      action: 'unknown',
      service: null,
      confidence: 0,
      originalMessage: message,
      suggestions: ['Try: "restart nginx", "status mongodb", "logs landing"']
    };
  }

  /**
   * Normalize service name (handle aliases)
   */
  normalizeServiceName(name) {
    if (!name) return null;
    const normalized = name.toLowerCase().trim();

    // Check aliases
    if (SERVICE_ALIASES[normalized]) {
      return SERVICE_ALIASES[normalized];
    }

    // Check valid services
    if (VALID_SERVICES.includes(normalized)) {
      return normalized;
    }

    // Partial match
    const partial = VALID_SERVICES.find(s => s.startsWith(normalized));
    if (partial) {
      return partial;
    }

    return normalized;
  }

  /**
   * Check if message is asking for help
   */
  matchesHelp(message) {
    return ACTION_PATTERNS.help.some(p => p.test(message));
  }

  /**
   * Get suggestions for unknown service
   */
  getSuggestions(unknownService) {
    // Find similar services
    const suggestions = VALID_SERVICES.filter(s =>
      s.includes(unknownService) ||
      unknownService.includes(s.substring(0, 3))
    );

    if (suggestions.length > 0) {
      return suggestions.slice(0, 3);
    }

    return VALID_SERVICES.slice(0, 5);
  }

  /**
   * Get help text
   */
  getHelpText() {
    return `
Available Commands:
  - start <service>   Start a service
  - stop <service>    Stop a service
  - restart <service> Restart a service
  - status [service]  Check service status (all if no service specified)
  - logs <service>    View service logs

Available Services:
  Core: nginx, landing, gateway, assistant
  Databases: mongodb, postgres, redis
  Messaging: kafka, zookeeper, n8n
  Monitoring: prometheus, grafana

Examples:
  "restart nginx"
  "status mongodb"
  "show logs for landing"
  "is redis running?"
`.trim();
  }

  /**
   * Get valid services list
   */
  getValidServices() {
    return VALID_SERVICES;
  }
}

module.exports = new IntentParser();
