---
title: Architecture Overview
tags: [architecture, design, overview]
created: 2026-02-07
related: [[Services Reference]], [[Docker Compose]], [[Network Architecture]]
---

# Architecture Overview

Complete architectural overview of the OpenClaw DevOps stack.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                       Internet                          │
└──────────────────────┬──────────────────────────────────┘
                       │
                   DNS Resolution
                       │
         ┌─────────────┴─────────────┐
         │                           │
    agents.ddns.net          openclaw.agents.ddns.net
         │                           │
         └─────────────┬─────────────┘
                       │
                 ┌─────▼─────┐
                 │   Nginx   │  Port 80/443
                 │  (Proxy)  │
                 └─────┬─────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
    ┌────▼────┐               ┌──────▼──────┐
    │ Landing │ :3000         │   Gateway   │ :18789
    │  Page   │               │  (OpenClaw) │
    └────┬────┘               └──────┬──────┘
         │                           │
         └─────────────┬─────────────┘
                       │
         ┌─────────────┴─────────────────────┐
         │                                   │
    ┌────▼────┐  ┌──────────┐  ┌─────────┐ │
    │ MongoDB │  │PostgreSQL│  │  Redis  │ │
    └─────────┘  └──────────┘  └─────────┘ │
         │                                   │
    ┌────▼────┐  ┌──────────┐  ┌─────────┐ │
    │  Kafka  │  │    n8n   │  │   ...   │ │
    └─────────┘  └──────────┘  └─────────┘ │
                                            │
                 Monitoring Stack           │
         ┌───────────────────────┐          │
         │  Prometheus  Grafana  │◄─────────┘
         └───────────────────────┘
```

## Layer Architecture

### Layer 1: Edge Layer
**Nginx Reverse Proxy**
- Handles all incoming HTTP/HTTPS traffic
- SSL termination
- Rate limiting
- Request routing
- Static file caching

**Responsibilities:**
- Route to landing page (`/`)
- Route to gateway (`openclaw.` subdomain)
- Health check endpoints
- Error pages

**Config:** `nginx/nginx.conf`, `nginx/conf.d/*.conf`

### Layer 2: Application Layer

#### Landing Page (Next.js)
- **Port:** 3000
- **Framework:** Next.js 16
- **Build:** Standalone mode
- **Features:**
  - Server-side rendering
  - Static optimization
  - API routes
  - React 19

**Connections:**
- MongoDB (data storage)
- PostgreSQL (structured data)
- Redis (caching/sessions)
- Gateway (API calls)

#### OpenClaw Gateway
- **Port:** 18789
- **Type:** AI Agent Gateway
- **Features:**
  - Agent management
  - Telegram integration
  - Workflow automation
  - Token authentication

**Connections:**
- MongoDB (agent data)
- PostgreSQL (workflows)
- Redis (state/cache)
- Kafka (events)
- n8n (webhook integration)

### Layer 3: Data Layer

#### MongoDB (Port 27017)
**Purpose:** Primary document database

**Collections:**
- `users` - User accounts
- `sessions` - Active sessions
- `workflows` - Workflow definitions
- `events` - Event log

**Features:**
- Replica set ready
- Auto-indexing
- User authentication

#### PostgreSQL (Port 5432)
**Purpose:** Relational database

**Databases:**
- `openclaw` - Main application
- `n8n` - Workflow engine

**Schemas:**
- `app` - Application tables
- `audit` - Audit logs
- `public` - Extensions

**Features:**
- ACID compliance
- Full-text search
- JSON support

#### Redis (Port 6379)
**Purpose:** Cache and message broker

**Use Cases:**
- Session storage
- API response caching
- Rate limiting
- Pub/sub messaging

**Configuration:**
- Max memory: 256MB
- Eviction: LRU
- Persistence: RDB snapshots

### Layer 4: Messaging Layer

#### Kafka (Port 9092)
**Purpose:** Event streaming

**Features:**
- Topic-based messaging
- High throughput
- Persistent log
- Horizontal scalability

**Topics:**
- Agent events
- System logs
- User actions
- Workflow triggers

#### Zookeeper (Port 2181)
**Purpose:** Kafka coordination

**Responsibilities:**
- Broker management
- Topic configuration
- Consumer group coordination

#### n8n (Port 5678)
**Purpose:** Workflow automation

**Features:**
- Visual workflow designer
- 200+ integrations
- Webhook support
- Scheduled workflows

**Storage:** PostgreSQL

### Layer 5: Observability Layer

#### Prometheus (Port 9090)
**Purpose:** Metrics collection

**Scrapes:**
- System metrics (Node Exporter)
- Container metrics (cAdvisor)
- Database metrics (Exporters)
- Application metrics

**Features:**
- 30-day retention
- Alert rules
- PromQL queries

#### Grafana (Port 3001)
**Purpose:** Visualization

**Features:**
- Pre-configured dashboards
- Alert notifications
- User management
- Multiple data sources

#### Exporters
- **Node Exporter** (9100) - System metrics
- **cAdvisor** (8080) - Container metrics
- **Redis Exporter** (9121) - Redis metrics
- **Postgres Exporter** (9187) - PostgreSQL metrics
- **MongoDB Exporter** (9216) - MongoDB metrics

## Network Architecture

### Host Network Mode

All services use `network_mode: "host"`:

**Benefits:**
- Direct localhost communication
- No port mapping overhead
- Simplified networking
- Better performance

**Trade-offs:**
- All services share host network
- No network isolation
- Port conflicts possible
- Less portable

### Service Communication

```
Landing ←→ Gateway    : HTTP (localhost:18789)
Landing ←→ MongoDB    : MongoDB protocol (localhost:27017)
Landing ←→ PostgreSQL : PostgreSQL protocol (localhost:5432)
Landing ←→ Redis      : Redis protocol (localhost:6379)
Gateway ←→ Kafka      : Kafka protocol (localhost:9092)
Gateway ←→ n8n        : HTTP webhooks (localhost:5678)
```

### External Access

```
Internet → Nginx (80/443) → Services
             ├─ / → Landing (3000)
             └─ openclaw. → Gateway (18789)
```

## Data Flow

### User Request Flow
1. User requests `agents.ddns.net`
2. DNS resolves to server IP
3. Nginx receives request on port 80/443
4. Nginx proxies to Landing (port 3000)
5. Landing queries MongoDB/PostgreSQL
6. Landing caches in Redis
7. Response sent back through Nginx
8. Metrics collected by Prometheus

### Agent Workflow Flow
1. Telegram message received
2. OpenClaw Gateway processes
3. Agent spawned
4. Workflow triggered in n8n
5. Events published to Kafka
6. Database updated
7. Response sent via Telegram
8. Logs stored in MongoDB

### Monitoring Flow
1. Exporters collect metrics
2. Prometheus scrapes every 15s
3. Data stored in Prometheus TSDB
4. Grafana queries Prometheus
5. Dashboards visualize metrics
6. Alerts triggered on thresholds

## Deployment Models

### Local Development
- All services on localhost
- Hot reload enabled
- Development databases
- Debug logging

### GCE Production
- Distributed on GCE instance
- SSL/TLS enabled
- Production databases
- Structured logging
- Automated backups
- Monitoring alerts

## Security Architecture

### Network Security
- Services bind to localhost only
- Nginx as only public-facing service
- Firewall rules restrict access
- Rate limiting on Nginx

### Authentication
- Token-based for Gateway
- Basic auth for n8n/Grafana
- Password-protected databases
- API key for AI services

### Data Security
- All passwords in .env (gitignored)
- SSL/TLS for external traffic
- Encrypted connections to DBs
- Regular security updates

## Scalability Considerations

### Horizontal Scaling
- Nginx: Multiple instances behind load balancer
- Landing: Multiple replicas
- Gateway: Stateless, can scale
- Databases: Replica sets/clusters

### Vertical Scaling
- Increase container resources
- Optimize queries
- Add more disk space
- Increase connection pools

### Performance Optimization
- Redis caching
- Static asset caching
- Database indexing
- Connection pooling
- Lazy loading

## Related Documentation

- [[Services Reference]] - Detailed service docs
- [[Docker Compose]] - Container configuration
- [[Network Architecture]] - Network details
- [[Security Best Practices]] - Security guide
- [[Performance Tuning]] - Optimization tips

---

#architecture #design #overview #system-design
