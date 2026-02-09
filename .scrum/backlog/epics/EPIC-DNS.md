# EPIC-DNS: Domain & DNS Management with Cloudflare

## Epic Overview

| Field | Value |
|-------|-------|
| **Epic ID** | EPIC-DNS |
| **Title** | Domain & DNS Management with Cloudflare |
| **Status** | planning |
| **Priority** | high |
| **Phase** | MVP |
| **Start Date** | 2026-02-09 |
| **Target Date** | 2026-03-15 |
| **Owner** | DevOps Team |

## Description

Implement comprehensive domain and DNS management using Cloudflare as the primary DNS provider and CDN. This epic covers automated DNS record management, SSL/TLS configuration, domain verification, and integration with deployment automation.

## Business Value

- **Automated DNS Management**: Reduce manual DNS configuration errors
- **Improved Security**: Cloudflare proxy protection and DDoS mitigation
- **Better Performance**: CDN caching and global edge network
- **SSL/TLS Automation**: Free SSL certificates with automatic renewal
- **Deployment Integration**: DNS updates as part of CI/CD pipeline

## Success Criteria

- [ ] All production domains managed through Cloudflare
- [ ] Automated DNS record creation/update via API
- [ ] SSL/TLS configured with Flexible proxy mode
- [ ] DNS propagation monitoring and verification
- [ ] Backup and disaster recovery procedures
- [ ] Documentation for DNS management workflows

## Technical Requirements

### Functional Requirements

**FR-DNS-001**: Cloudflare API Integration
- System shall integrate with Cloudflare API v4
- Support for DNS record CRUD operations (Create, Read, Update, Delete)
- Authentication via API tokens with zone-specific permissions

**FR-DNS-002**: Automated DNS Record Management
- Automated A record creation for all service subdomains
- Support for CNAME, TXT, and MX records
- Configurable TTL values per record type

**FR-DNS-003**: SSL/TLS Configuration
- Flexible SSL mode (HTTPS to Cloudflare, HTTP to origin)
- Automatic SSL certificate provisioning
- Support for Full and Full (Strict) modes for future upgrade

**FR-DNS-004**: Domain Verification
- DNS propagation checks via public DNS resolvers (1.1.1.1, 8.8.8.8)
- Automated verification after record creation
- Health check integration for domain accessibility

**FR-DNS-005**: Multi-Environment Support
- Separate DNS configurations for dev, staging, production
- Environment-specific subdomain patterns
- Configurable domain prefixes per environment

### Non-Functional Requirements

**NFR-DNS-001**: Automation
- DNS changes automated through scripts and CI/CD
- Zero manual Cloudflare dashboard operations for routine tasks
- Idempotent operations (safe to run multiple times)

**NFR-DNS-002**: Reliability
- DNS update retries with exponential backoff
- Validation before applying changes
- Rollback capability for failed updates

**NFR-DNS-003**: Security
- API tokens stored securely (environment variables, secrets management)
- Least-privilege API token permissions
- Audit logging for all DNS changes

**NFR-DNS-004**: Monitoring
- DNS resolution monitoring
- SSL certificate expiration alerts
- Cloudflare analytics integration

## Stories

| ID | Title | Points | Status | Priority |
|----|-------|--------|--------|----------|
| US-021 | Cloudflare API Integration Setup | 3 | ready | critical |
| US-022 | Automated DNS Record Creation Script | 5 | ready | critical |
| US-023 | SSL/TLS Flexible Mode Configuration | 3 | ready | high |
| US-024 | DNS Propagation Verification | 3 | ready | high |
| US-025 | Multi-Domain Management | 5 | ready | high |
| US-026 | DNS Backup and Recovery | 3 | ready | medium |
| US-027 | Cloudflare Analytics Integration | 3 | ready | medium |

**Total Story Points**: 25

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DNS Management Flow                       │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐      ┌─────────────────┐      ┌────────────┐
│  Deployment  │─────▶│  DNS Automation │─────▶│ Cloudflare │
│   Pipeline   │      │     Scripts     │      │    API     │
└──────────────┘      └─────────────────┘      └────────────┘
                              │                       │
                              │                       ▼
                              │              ┌────────────────┐
                              │              │ DNS Records    │
                              │              │ - A Records    │
                              │              │ - CNAME        │
                              │              │ - TXT (SPF)    │
                              ▼              └────────────────┘
                      ┌─────────────────┐           │
                      │  Verification   │           │
                      │  - dig checks   │◀──────────┘
                      │  - curl tests   │
                      │  - SSL verify   │
                      └─────────────────┘

Internet Users
      │
      ▼
┌────────────────┐      ┌─────────────────┐      ┌──────────┐
│   Cloudflare   │─────▶│  Nginx Proxy    │─────▶│ Services │
│  Edge Network  │      │  (GCE Instance) │      │          │
│   (SSL + CDN)  │      │  Port 80/443    │      │ • Landing│
└────────────────┘      └─────────────────┘      │ • Gateway│
    HTTPS                      HTTP               │ • Admin  │
                                                  │ • Portainer
                                                  └──────────┘
```

## Current Domains

| Domain | Service | Status | SSL Mode |
|--------|---------|--------|----------|
| devops-agents.bemind.tech | Landing Page | ✅ Live | Flexible |
| openclaw-agents.bemind.tech | Gateway | ✅ Live | Flexible |
| admin-agents.bemind.tech | Admin Dashboard | ✅ Live | Flexible |
| portainer-agents.bemind.tech | Portainer | ⏳ Pending | Flexible |

## Dependencies

- **Depends On**: EPIC-INFRA (infrastructure must be deployed)
- **Blocks**: None
- **Related**: EPIC-MONITORING (for DNS monitoring dashboards)

## Risks & Mitigations

### Risk 1: API Rate Limiting
- **Impact**: High
- **Probability**: Low
- **Mitigation**:
  - Implement retry logic with exponential backoff
  - Cache DNS record queries
  - Use batch operations where possible

### Risk 2: DNS Propagation Delays
- **Impact**: Medium
- **Probability**: Medium
- **Mitigation**:
  - Set appropriate TTL values (Auto for Cloudflare proxy)
  - Implement verification loops with timeouts
  - Use Cloudflare's edge network for faster propagation

### Risk 3: SSL Certificate Issues
- **Impact**: High
- **Probability**: Low
- **Mitigation**:
  - Monitor certificate expiration
  - Test SSL configuration in staging first
  - Maintain rollback scripts

### Risk 4: Cloudflare Outage
- **Impact**: Critical
- **Probability**: Very Low
- **Mitigation**:
  - Secondary DNS provider for critical domains
  - Direct IP access as fallback
  - Documented manual DNS failover procedure

## Acceptance Criteria

### Epic Completion Criteria

1. **Automation**
   - [ ] All DNS operations automated via scripts
   - [ ] Integration with deployment pipeline
   - [ ] Zero manual dashboard operations required

2. **Coverage**
   - [ ] All production domains managed through Cloudflare
   - [ ] All service subdomains configured
   - [ ] Development and staging environments configured

3. **Security**
   - [ ] SSL/TLS enabled on all domains
   - [ ] API tokens secured in environment variables
   - [ ] Least-privilege permissions configured

4. **Reliability**
   - [ ] DNS propagation verification automated
   - [ ] Health checks for all domains
   - [ ] Backup/recovery procedures tested

5. **Documentation**
   - [ ] Setup guide for new domains
   - [ ] Troubleshooting playbook
   - [ ] API token management guide
   - [ ] Disaster recovery procedures

## Timeline

```
Week 1 (Feb 9-15):   US-021, US-022 (API setup + automation)
Week 2 (Feb 16-22):  US-023, US-024 (SSL config + verification)
Week 3 (Feb 23-Mar 1): US-025, US-026 (Multi-domain + backup)
Week 4 (Mar 2-8):    US-027 (Analytics integration)
Week 5 (Mar 9-15):   Testing and documentation
```

## Notes

### Current Status (2026-02-09)

- ✅ Cloudflare account configured (bemind.tech domain)
- ✅ API token created with DNS edit permissions
- ✅ Zone ID obtained
- ✅ Basic DNS setup script created (setup-cloudflare-dns.sh)
- ✅ 3 domains already configured and live
- ⏳ Portainer domain pending deployment

### Future Enhancements

- Upgrade to Full (Strict) SSL mode with Let's Encrypt on origin
- Implement Cloudflare Workers for edge computing
- Add Cloudflare Access for zero-trust security
- Integrate Cloudflare Analytics with monitoring stack
- Implement automatic failover to backup DNS provider
- Add Cloudflare Load Balancing for multi-region deployments

### Related Documentation

- `/deployments/gce/CLOUDFLARE-SETUP.md` - Setup guide
- `/deployments/gce/setup-cloudflare-dns.sh` - Automation script
- Cloudflare API Docs: https://developers.cloudflare.com/api/

---

**Created**: 2026-02-09
**Last Updated**: 2026-02-09
**Version**: 1.0
