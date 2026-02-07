# GCE Configuration Files

Configuration files specific to GCE deployment.

## OpenClaw Gateway Configuration

**File:** `openclaw-gateway.json`

This configuration is optimized for production deployment on GCE:

### Key Differences from Local:

1. **Gateway Mode:** `production` (vs `local`)
2. **Bind Address:** `0.0.0.0` (accessible from network)
3. **Telegram:** Enabled by default
4. **Trusted Proxies:** Includes GCP internal network ranges

### Setup Instructions:

1. **Copy config to server:**
   ```bash
   gcloud compute scp openclaw-gateway.json \
     bmt-staging-research:/home/lps/server/config/ \
     --zone=asia-southeast1-a \
     --project=bemind-technology
   ```

2. **Update sensitive values:**
   - `channels.telegram.botToken` - Your Telegram bot token
   - `gateway.auth.token` - Random secure token (32+ chars)

3. **Generate auth token:**
   ```bash
   openssl rand -hex 32
   ```

### Environment Variables:

The configuration can also use environment variables:
- `TELEGRAM_BOT_TOKEN`
- `GATEWAY_AUTH_TOKEN`
- `AI_MODEL_PRIMARY`

### Backup:

Always backup your configuration before updates:
```bash
cp openclaw-gateway.json openclaw-gateway.json.bak
```
