# Portainer Setup Guide

## Overview

Portainer is a lightweight Docker management UI that provides an easy-to-use interface for managing containers, images, networks, and volumes. It's included in the OpenClaw DevOps base stack.

## Quick Start

### 1. Start Portainer

```bash
# Start all services including Portainer
docker-compose up -d

# Or start Portainer specifically
docker-compose up -d portainer
```

### 2. Access Portainer

- **Local**: http://localhost:9000
- **Production**: https://portainer.your-domain.com

### 3. Initial Setup

On first access, you'll be prompted to:

1. **Create Admin User**
   - Username: admin
   - Password: (minimum 12 characters)
   - Confirm password

2. **Select Environment**
   - Choose "Docker" (local)
   - Click "Connect"

3. **Complete Setup**
   - You'll see your Docker environment dashboard

## Configuration

### Environment Variables

In `.env` file:

```bash
# Portainer Configuration
PORTAINER_PORT=9000           # Main web UI port
PORTAINER_EDGE_PORT=8000      # Edge agent communication port
PORTAINER_DOMAIN=portainer.your-domain.com
```

### Domain Setup

#### Local Development

Use `localhost:9000` directly.

#### Production with Nginx

1. Update nginx configuration:
   ```bash
   # Edit nginx/conf.d/portainer.conf
   # Update server_name to your domain
   server_name portainer.your-domain.com;
   ```

2. Restart nginx:
   ```bash
   docker-compose restart nginx
   ```

#### Production with Cloudflare

1. Add DNS record:
   ```bash
   # Using the Cloudflare setup script
   cd deployments/gce

   # Add to setup-cloudflare-dns.sh:
   create_dns_record "portainer-agents.bemind.tech" "$EXTERNAL_IP"

   # Or manually in Cloudflare dashboard:
   # Type: A
   # Name: portainer-agents
   # Content: [Your server IP]
   # Proxy: Enabled (orange cloud)
   ```

2. Run DNS setup:
   ```bash
   ./setup-cloudflare-dns.sh
   ```

## Features

### Container Management

- **View Containers**: See all running and stopped containers
- **Start/Stop/Restart**: Control container lifecycle
- **Logs**: View real-time container logs
- **Console**: Access container shell
- **Stats**: Monitor resource usage

### Image Management

- **Pull Images**: Download images from registries
- **Build Images**: Build from Dockerfile
- **Tag Images**: Create image tags
- **Delete Images**: Remove unused images

### Network Management

- **Create Networks**: Define custom networks
- **Connect Containers**: Attach containers to networks
- **Inspect Networks**: View network configuration

### Volume Management

- **Create Volumes**: Define persistent storage
- **Attach Volumes**: Mount volumes to containers
- **Browse Files**: View volume contents
- **Delete Volumes**: Remove unused volumes

### Stack Management

- **Deploy Stacks**: Deploy Docker Compose stacks
- **Update Stacks**: Modify running stacks
- **Remove Stacks**: Clean up stack resources

## Usage Examples

### Deploy a Stack

1. Go to **Stacks** → **Add Stack**
2. Name your stack (e.g., "openclaw-full")
3. Paste your `docker-compose.yml` content
4. Set environment variables
5. Click **Deploy**

### View Container Logs

1. Go to **Containers**
2. Click on container name
3. Click **Logs** tab
4. Use filters and search

### Access Container Shell

1. Go to **Containers**
2. Click on container name
3. Click **Console** tab
4. Select shell (`/bin/bash` or `/bin/sh`)
5. Click **Connect**

### Monitor Resources

1. Go to **Dashboard**
2. View real-time stats:
   - CPU usage
   - Memory usage
   - Container count
   - Volume count

## Security

### Admin Password

- **Minimum 12 characters** required
- Use strong, unique password
- Store in password manager

### Access Control

Portainer supports multiple authentication methods:

- **Local Authentication** (default)
- **LDAP/AD** (Enterprise)
- **OAuth** (Enterprise)

### Role-Based Access

Create teams and users with specific permissions:

1. Go to **Users**
2. Click **Add User**
3. Set username, password, role
4. Assign to team (if using teams)

### SSL/TLS

For production, always use HTTPS:

1. Configure nginx with SSL certificates
2. Or use Cloudflare flexible proxy
3. Never expose HTTP Portainer publicly

## Troubleshooting

### Cannot Access Portainer

**Problem**: Port 9000 not accessible

**Solutions**:
1. Check container is running:
   ```bash
   docker ps | grep portainer
   ```

2. Check port binding:
   ```bash
   netstat -an | grep 9000
   ```

3. Check firewall rules:
   ```bash
   # GCE
   gcloud compute firewall-rules list --filter="portainer"
   ```

### Lost Admin Password

**Problem**: Forgot admin password

**Solution**:
```bash
# Reset admin password
docker stop openclaw-portainer
docker run --rm -v portainer-data:/data \
  portainer/helper-reset-password

# Start Portainer again
docker start openclaw-portainer
```

### Docker Socket Permission Denied

**Problem**: Cannot connect to Docker

**Solution**:
```bash
# Ensure Docker socket is mounted
docker inspect openclaw-portainer | grep -A5 Mounts

# Should show:
# "Source": "/var/run/docker.sock"
# "Mode": "ro"
```

### High Memory Usage

**Problem**: Portainer using too much memory

**Solution**:
```bash
# Add memory limit to docker-compose.yml
portainer:
  mem_limit: 512m
  memswap_limit: 512m
```

## Best Practices

### 1. Regular Backups

Backup Portainer data:

```bash
# Backup volume
docker run --rm -v portainer-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/portainer-backup.tar.gz /data

# Restore
docker run --rm -v portainer-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/portainer-backup.tar.gz -C /
```

### 2. Use HTTPS

Always use HTTPS in production:
- Configure nginx SSL
- Or use Cloudflare proxy
- Never expose HTTP publicly

### 3. Limit Access

- Use strong passwords
- Enable two-factor authentication (Enterprise)
- Restrict network access with firewall
- Use VPN for remote access

### 4. Monitor Activity

- Review container logs regularly
- Check resource usage
- Monitor failed login attempts
- Set up alerts for critical events

### 5. Keep Updated

Update Portainer regularly:

```bash
# Pull latest image
docker pull portainer/portainer-ce:latest

# Restart container
docker-compose up -d portainer
```

## Integration with OpenClaw

Portainer can manage all OpenClaw services:

### View OpenClaw Stack

1. Go to **Stacks**
2. Find "openclaw" stack
3. View services, networks, volumes

### Monitor Services

1. Go to **Containers**
2. Filter by "openclaw" prefix
3. Check health status
4. View logs

### Scale Services

1. Go to **Stacks** → **openclaw**
2. Click **Editor**
3. Modify service replicas
4. Click **Update**

### Manage Volumes

1. Go to **Volumes**
2. Find OpenClaw volumes:
   - `nginx-logs`
   - `portainer-data`
3. Browse or backup

## Advanced Features

### Templates

Create custom templates for quick deployment:

1. Go to **App Templates**
2. Click **Add Template**
3. Define template JSON
4. Save template

### Webhooks

Trigger container updates via webhook:

1. Go to **Containers**
2. Select container
3. Click **Duplicate/Edit**
4. Enable webhook
5. Copy webhook URL
6. Use in CI/CD pipeline

### Edge Agent (Enterprise)

Manage remote Docker hosts:

1. Install Edge Agent on remote host
2. Connect to Portainer
3. Manage multiple environments
4. Monitor distributed containers

## Resources

- **Portainer Docs**: https://docs.portainer.io
- **Community Forum**: https://community.portainer.io
- **GitHub**: https://github.com/portainer/portainer
- **Docker Hub**: https://hub.docker.com/r/portainer/portainer-ce

---

**Last Updated**: 2026-02-08
**Version**: Portainer CE (latest)
