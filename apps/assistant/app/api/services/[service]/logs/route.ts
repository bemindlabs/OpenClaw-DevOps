import { NextRequest, NextResponse } from 'next/server'

const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:18789'

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ service: string }> }
) {
  try {
    const { service } = await params
    const { searchParams } = new URL(request.url)

    // Build query parameters
    const queryParams = new URLSearchParams()
    const tail = searchParams.get('tail')
    const timestamps = searchParams.get('timestamps')
    const since = searchParams.get('since')

    if (tail) queryParams.set('tail', tail)
    if (timestamps) queryParams.set('timestamps', timestamps)
    if (since) queryParams.set('since', since)

    const queryString = queryParams.toString()
    const url = `${GATEWAY_URL}/api/services/${service}/logs${queryString ? `?${queryString}` : ''}`

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })

    const data = await response.json()

    if (!response.ok) {
      return NextResponse.json(
        { success: false, error: data.error || 'Gateway request failed' },
        { status: response.status }
      )
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('[Assistant API] Service logs error:', error)
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    )
  }
}
