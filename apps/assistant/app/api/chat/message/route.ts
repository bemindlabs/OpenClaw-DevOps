import { NextRequest, NextResponse } from 'next/server'

// Use localhost for dev mode on host, host.docker.internal for Docker Desktop
// Check if we're running inside Docker by checking for /.dockerenv
const isDocker = require('fs').existsSync('/.dockerenv')
const GATEWAY_URL = process.env.GATEWAY_URL || (isDocker ? 'http://host.docker.internal:18789' : 'http://localhost:18789')

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    console.log('[Assistant API] Proxying chat request to gateway:', GATEWAY_URL)
    console.log('[Assistant API] Request body:', body)

    const response = await fetch(`${GATEWAY_URL}/api/chat/message`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    })

    console.log('[Assistant API] Gateway response status:', response.status)

    const data = await response.json()
    console.log('[Assistant API] Gateway response data:', data)

    if (!response.ok) {
      console.error('[Assistant API] Gateway returned error:', data)
      return NextResponse.json(
        { success: false, error: data.error || 'Gateway request failed' },
        { status: response.status }
      )
    }

    return NextResponse.json(data)
  } catch (error) {
    // Enhanced error logging
    console.error('[Assistant API] Chat message error:', error)
    console.error('[Assistant API] Error details:', {
      message: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
      cause: error instanceof Error ? error.cause : undefined,
      name: error instanceof Error ? error.name : undefined,
    })

    // Write to stderr for immediate output
    process.stderr.write(`[Assistant API ERROR] ${JSON.stringify({
      message: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
      cause: error instanceof Error ? error.cause : undefined,
    }, null, 2)}\n`)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    )
  }
}
