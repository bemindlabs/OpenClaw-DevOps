import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  output: 'standalone',
  reactStrictMode: true,
  poweredByHeader: false,
  compress: true,

  // Environment variables exposed to the browser
  env: {
    NEXT_PUBLIC_GATEWAY_URL: process.env.GATEWAY_URL || 'http://localhost:18789',
  },

  // Turbopack configuration (Next.js 16+)
  turbopack: {},
}

export default nextConfig
