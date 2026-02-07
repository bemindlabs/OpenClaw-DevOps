# Environment Variable Migration Notice

**⚠️ Important:** This app no longer uses a local `.env` file.

## New Configuration

All environment variables are now defined in the **root `.env` file** at `/project-root/.env`.

### Migration Steps

1. Copy root `.env.example` to `.env`:
   ```bash
   cd /path/to/project-root
   cp .env.example .env
   ```

2. Edit root `.env` with your values

3. The assistant app will receive environment variables via:
   - Docker Compose `env_file: .env` directive
   - Or via `docker-compose.yml` environment section

### Variables Used by Assistant App

The assistant app uses these variables from root `.env`:
- `MONGODB_URI`
- `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`
- `NEXT_PUBLIC_GATEWAY_URL`
- `NEXTAUTH_URL`
- `NEXTAUTH_SECRET`
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`

See the root `.env.example` file for full configuration details.
