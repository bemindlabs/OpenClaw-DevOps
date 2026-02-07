import { Service } from '@/types/service'

export const SERVICES: Record<string, Omit<Service, 'status' | 'health'>> = {
  // Core Services
  nginx: {
    name: 'nginx',
    displayName: 'Nginx',
    category: 'core',
    port: 80,
  },
  landing: {
    name: 'landing',
    displayName: 'Landing Page',
    category: 'core',
    port: 3000,
  },
  gateway: {
    name: 'gateway',
    displayName: 'OpenClaw Gateway',
    category: 'core',
    port: 18789,
  },

  // Database Services
  mongodb: {
    name: 'mongodb',
    displayName: 'MongoDB',
    category: 'database',
    port: 27017,
  },
  postgres: {
    name: 'postgres',
    displayName: 'PostgreSQL',
    category: 'database',
    port: 5432,
  },
  redis: {
    name: 'redis',
    displayName: 'Redis',
    category: 'database',
    port: 6379,
  },

  // Messaging Services
  kafka: {
    name: 'kafka',
    displayName: 'Kafka',
    category: 'messaging',
    port: 9092,
  },
  zookeeper: {
    name: 'zookeeper',
    displayName: 'Zookeeper',
    category: 'messaging',
    port: 2181,
  },
  n8n: {
    name: 'n8n',
    displayName: 'n8n',
    category: 'messaging',
    port: 5678,
  },

  // Monitoring Services
  prometheus: {
    name: 'prometheus',
    displayName: 'Prometheus',
    category: 'monitoring',
    port: 9090,
  },
  grafana: {
    name: 'grafana',
    displayName: 'Grafana',
    category: 'monitoring',
    port: 3001,
  },
  'node-exporter': {
    name: 'node-exporter',
    displayName: 'Node Exporter',
    category: 'monitoring',
    port: 9100,
  },
  cadvisor: {
    name: 'cadvisor',
    displayName: 'cAdvisor',
    category: 'monitoring',
    port: 8080,
  },
  'redis-exporter': {
    name: 'redis-exporter',
    displayName: 'Redis Exporter',
    category: 'monitoring',
    port: 9121,
  },
  'postgres-exporter': {
    name: 'postgres-exporter',
    displayName: 'PostgreSQL Exporter',
    category: 'monitoring',
    port: 9187,
  },
  'mongodb-exporter': {
    name: 'mongodb-exporter',
    displayName: 'MongoDB Exporter',
    category: 'monitoring',
    port: 9216,
  },
}

export const SERVICE_CATEGORIES = {
  core: ['nginx', 'landing', 'gateway'],
  database: ['mongodb', 'postgres', 'redis'],
  messaging: ['kafka', 'zookeeper', 'n8n'],
  monitoring: [
    'prometheus',
    'grafana',
    'node-exporter',
    'cadvisor',
    'redis-exporter',
    'postgres-exporter',
    'mongodb-exporter',
  ],
} as const

export const API_BASE_URL = process.env.NEXT_PUBLIC_GATEWAY_URL || 'http://localhost:18789'
