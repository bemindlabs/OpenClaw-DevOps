# Port Mapping Reference

This document provides a comprehensive reference for all port assignments in the OpenClaw DevOps platform.

**Last Updated:** 2026-02-14
**Version:** 1.0.0

## Port Range

All services use ports in the range **32100-32199** (100 ports total).

## Port Categories

- **core** (32100-32119): Core application services (Nginx, Landing, Assistant, Gateway, Portainer)
- **databases** (32120-32139): Database services (MongoDB, PostgreSQL, Redis)
- **messaging** (32140-32159): Messaging and workflow services (Zookeeper, Kafka, n8n)
- **monitoring** (32160-32179): Monitoring and observability (Prometheus, Grafana, Exporters)
- **optional** (32180-32189): Optional AI services (Ollama, LM Studio)
- **reserved** (32190-32199): Reserved for future expansion

## Complete Port Mapping

| Service | Old Port | New Port | Env Variable | Health Check | External |
|---------|----------|----------|--------------|--------------|----------|
| Nginx HTTP | 80 | 32100 | NGINX_HTTP_PORT | http://localhost:32100/health | ✅ |
| Nginx HTTPS | 443 | 32101 | NGINX_HTTPS_PORT | https://localhost:32101/health | ✅ |
| Landing Page | 3000 | 32102 | LANDING_PORT | http://localhost:32102 | ❌ |
| Admin Assistant Portal | 5555 | 32103 | ASSISTANT_PORT | http://localhost:32103 | ❌ |
| OpenClaw Gateway | 18789 | 32104 | GATEWAY_PORT | http://localhost:32104/health | ❌ |
| Portainer | 9000 | 32105 | PORTAINER_PORT | http://localhost:32105/api/status | ❌ |
| Portainer Edge | 8000 | 32106 | PORTAINER_EDGE_PORT | N/A | ❌ |
| Nginx Proxy Manager | 81 | 32107 | NGINX_PROXY_MANAGER_PORT | http://localhost:32107 | ❌ |
| MongoDB | 27017 | 32120 | MONGODB_PORT | N/A | ❌ |
| PostgreSQL | 5432 | 32121 | POSTGRES_PORT | N/A | ❌ |
| Redis | 6379 | 32122 | REDIS_PORT | N/A | ❌ |
| Zookeeper | 2181 | 32140 | ZOOKEEPER_PORT | N/A | ❌ |
| Kafka | 9092 | 32141 | KAFKA_PORT | N/A | ❌ |
| n8n | 5678 | 32142 | N8N_PORT | http://localhost:32142/healthz | ❌ |
| Prometheus | 9090 | 32160 | PROMETHEUS_PORT | http://localhost:32160/-/healthy | ❌ |
| Grafana | 3001 | 32161 | GRAFANA_PORT | http://localhost:32161/api/health | ❌ |
| Node Exporter | 9100 | 32162 | NODE_EXPORTER_PORT | http://localhost:32162/metrics | ❌ |
| cAdvisor | 8080 | 32163 | CADVISOR_PORT | http://localhost:32163/metrics | ❌ |
| Redis Exporter | 9121 | 32164 | REDIS_EXPORTER_PORT | http://localhost:32164/metrics | ❌ |
| PostgreSQL Exporter | 9187 | 32165 | POSTGRES_EXPORTER_PORT | http://localhost:32165/metrics | ❌ |
| MongoDB Exporter | 9216 | 32166 | MONGODB_EXPORTER_PORT | http://localhost:32166/metrics | ❌ |

## Migration Guide

### Quick Reference (Old → New)

```
Nginx HTTP                80       → 32100
Nginx HTTPS               443      → 32101
Landing Page              3000     → 32102
Admin Assistant Portal    5555     → 32103
OpenClaw Gateway          18789    → 32104
Portainer                 9000     → 32105
Portainer Edge            8000     → 32106
Nginx Proxy Manager       81       → 32107
MongoDB                   27017    → 32120
PostgreSQL                5432     → 32121
Redis                     6379     → 32122
Zookeeper                 2181     → 32140
Kafka                     9092     → 32141
n8n                       5678     → 32142
Prometheus                9090     → 32160
Grafana                   3001     → 32161
Node Exporter             9100     → 32162
cAdvisor                  8080     → 32163
Redis Exporter            9121     → 32164
PostgreSQL Exporter       9187     → 32165
MongoDB Exporter          9216     → 32166
```

## Visual Port Range Diagram

```
32100-32119: Core Applications
  ├─ 32100  Nginx HTTP
  ├─ 32101  Nginx HTTPS
  ├─ 32102  Landing Page
  ├─ 32103  Admin Assistant
  ├─ 32104  Gateway
  ├─ 32105  Portainer
  └─ 32106  Portainer Edge

32120-32139: Databases
  ├─ 32120  MongoDB
  ├─ 32121  PostgreSQL
  └─ 32122  Redis

32140-32159: Messaging & Workflows
  ├─ 32140  Zookeeper
  ├─ 32141  Kafka
  └─ 32142  n8n

32160-32179: Monitoring & Metrics
  ├─ 32160  Prometheus
  ├─ 32161  Grafana
  ├─ 32162  Node Exporter
  ├─ 32163  cAdvisor
  ├─ 32164  Redis Exporter
  ├─ 32165  PostgreSQL Exporter
  └─ 32166  MongoDB Exporter

32180-32189: Optional Services (Reserved)
32190-32199: Future Expansion (Reserved)
```

## Health Check URLs

- **Nginx HTTP**: http://localhost:32100/health
- **Nginx HTTPS**: https://localhost:32101/health
- **Landing Page**: http://localhost:32102
- **Admin Assistant Portal**: http://localhost:32103
- **OpenClaw Gateway**: http://localhost:32104/health
- **Portainer**: http://localhost:32105/api/status
- **Nginx Proxy Manager**: http://localhost:32107
- **n8n**: http://localhost:32142/healthz
- **Prometheus**: http://localhost:32160/-/healthy
- **Grafana**: http://localhost:32161/api/health
- **Node Exporter**: http://localhost:32162/metrics
- **cAdvisor**: http://localhost:32163/metrics
- **Redis Exporter**: http://localhost:32164/metrics
- **PostgreSQL Exporter**: http://localhost:32165/metrics
- **MongoDB Exporter**: http://localhost:32166/metrics

## Port Allocation Status

**core**: 8/20 ports allocated (12 available)
**databases**: 3/20 ports allocated (17 available)
**messaging**: 3/20 ports allocated (17 available)
**monitoring**: 7/20 ports allocated (13 available)
**optional**: 0/10 ports allocated (10 available)
**reserved**: 0/10 ports allocated (10 available)

---

_Auto-generated from ports.json by update-ports.js_