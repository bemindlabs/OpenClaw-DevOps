import { NextRequest, NextResponse } from 'next/server'

const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:18789'

export async function GET(request: NextRequest) {
  try {
    const response = await fetch(`${GATEWAY_URL}/health`, {
      method: 'GET',
    })

    const data = await response.json()

    if (!response.ok) {
      return NextResponse.json(
        { success: false, error: 'Gateway health check failed' },
        { status: response.status }
      )
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('[Assistant API] Health check error:', error)
    return NextResponse.json(
      {
        status: 'unhealthy',
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    )
  }
}
