# Cloudflare DNS Setup Guide

## Overview

This guide walks you through setting up Cloudflare DNS for your OpenClaw DevOps deployment with **flexible proxy mode** (HTTPS between client and Cloudflare, HTTP between Cloudflare and origin).

## Prerequisites

- Cloudflare account with `bemind.tech` domain
- API token with DNS edit permissions
- GCE instance deployed and running

## Step 1: Get Cloudflare Credentials

### API Token

1. Go to https://dash.cloudflare.com/profile/api-tokens
2. Click **"Create Token"**
3. Use **"Edit zone DNS"** template
4. **Zone Resources**: Include > Specific zone > `bemind.tech`
5. Click **"Continue to summary"**
6. Click **"Create Token"**
7. **Copy the token** (you won't see it again)

### Zone ID

1. Go to https://dash.cloudflare.com
2. Click on your domain (`bemind.tech`)
3. Scroll down on the right sidebar
4. Copy the **Zone ID**

## Step 2: Set Environment Variables

Export your Cloudflare credentials:

```bash
export CLOUDFLARE_API_TOKEN='your-api-token-here'
export CLOUDFLARE_ZONE_ID='your-zone-id-here'
```

Or add them to `config.env`:

```bash
# Edit config.env
cd /Users/lps/server/deployments/gce
nano config.env

# Add these lines (uncomment and replace with your values):
CLOUDFLARE_API_TOKEN=your-api-token-here
CLOUDFLARE_ZONE_ID=your-zone-id-here
```

## Step 3: Run Setup Script

```bash
cd /Users/lps/server/deployments/gce
./setup-cloudflare-dns.sh
```

The script will:
1. ✅ Create/update DNS A record for `devops-agents.bemind.tech`
2. ✅ Create/update DNS A record for `openclaw-agents.bemind.tech`
3. ✅ Enable Cloudflare proxy (orange cloud)
4. ✅ Set SSL mode to **Flexible**
5. ✅ Verify DNS propagation

## What the Script Does

### DNS Records Created

| Subdomain | Type | Target | Proxy | TTL |
|-----------|------|--------|-------|-----|
| `devops-agents.bemind.tech` | A | `34.158.49.120` | ✓ | Auto |
| `openclaw-agents.bemind.tech` | A | `34.158.49.120` | ✓ | Auto |

### SSL/TLS Mode: Flexible

**Flexible mode** means:
- **Client → Cloudflare**: HTTPS (encrypted)
- **Cloudflare → Origin Server**: HTTP (unencrypted)

This works because:
- Cloudflare terminates SSL at their edge
- Your origin server (GCE nginx) serves HTTP on port 80
- Users see `https://` and get SSL certificate from Cloudflare

### Advantages of Flexible Mode

✅ No SSL certificate needed on origin server
✅ Fast setup (works immediately)
✅ Free SSL from Cloudflare
✅ Full DDoS protection

### Limitations

⚠️ Traffic between Cloudflare and origin is unencrypted
⚠️ Not suitable for highly sensitive data (use Full/Strict for that)

## Step 4: Verify Setup

After DNS propagates (1-5 minutes), test your domains:

### Check Landing Page
```bash
curl -I https://devops-agents.bemind.tech
```

Expected: `HTTP/2 200` with Cloudflare headers

### Check Gateway
```bash
curl -I https://openclaw-agents.bemind.tech
```

Expected: `HTTP/2 200` with Cloudflare headers

### Visual Test

Open in browser:
- **Landing**: https://devops-agents.bemind.tech
- **Gateway**: https://openclaw-agents.bemind.tech/health

You should see:
- ✅ Valid SSL certificate (from Cloudflare)
- ✅ Green padlock in browser
- ✅ Working application

## Troubleshooting

### DNS Not Resolving

**Problem**: `dig devops-agents.bemind.tech` returns nothing

**Solutions**:
1. Wait 1-5 minutes for propagation
2. Check Zone ID is correct
3. Verify API token has DNS edit permissions

### SSL Certificate Error

**Problem**: Browser shows "Your connection is not private"

**Solutions**:
1. Wait for SSL to provision (1-2 minutes)
2. Check SSL mode is set to Flexible
3. Verify Cloudflare proxy is enabled (orange cloud)

### Origin Server Not Responding

**Problem**: Cloudflare returns 521 or 522 error

**Solutions**:
1. Verify GCE instance is running:
   ```bash
   gcloud compute instances list --filter="name=bmt-staging-research"
   ```

2. Check nginx is running:
   ```bash
   gcloud compute ssh bmt-staging-research --zone=asia-southeast1-a --command="docker ps"
   ```

3. Verify port 80 is accessible:
   ```bash
   curl http://34.158.49.120
   ```

4. Check firewall rules allow HTTP (port 80):
   ```bash
   gcloud compute firewall-rules list --filter="name~openclaw"
   ```

### API Token Issues

**Problem**: Script returns "Authentication error"

**Solutions**:
1. Regenerate API token
2. Ensure token has "Edit zone DNS" permission
3. Check token hasn't expired

## Advanced Configuration

### Upgrade to Full SSL (Optional)

If you want end-to-end encryption:

1. Install SSL certificate on origin server (Let's Encrypt)
2. Configure nginx to serve HTTPS on port 443
3. Update Cloudflare SSL mode from Flexible to Full or Full (Strict)

### Enable Additional Security Features

Recommended Cloudflare settings:

```bash
# Enable HSTS
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/settings/security_header" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"value":{"strict_transport_security":{"enabled":true,"max_age":31536000,"include_subdomains":true}}}'

# Enable Always Use HTTPS
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/settings/always_use_https" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"value":"on"}'
```

## Cleanup (Remove DNS Records)

To remove Cloudflare DNS records:

```bash
# List DNS records
curl -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  | jq '.result[] | {id, name, content}'

# Delete specific record
curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/<RECORD_ID>" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN"
```

## Monitoring

### Check DNS Status

```bash
# Check current DNS records
./setup-cloudflare-dns.sh --check-only

# Manual dig check
dig +short devops-agents.bemind.tech
dig +short openclaw-agents.bemind.tech
```

### Monitor SSL Status

Check SSL certificate expiration:
```bash
echo | openssl s_client -servername devops-agents.bemind.tech -connect devops-agents.bemind.tech:443 2>/dev/null | openssl x509 -noout -dates
```

## References

- [Cloudflare API Documentation](https://developers.cloudflare.com/api/)
- [SSL/TLS Encryption Modes](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/)
- [Create API Token](https://dash.cloudflare.com/profile/api-tokens)
- [Cloudflare Proxy Status](https://developers.cloudflare.com/dns/manage-dns-records/reference/proxied-dns-records/)

---

**Status**: Ready for execution
**Last Updated**: 2026-02-08
