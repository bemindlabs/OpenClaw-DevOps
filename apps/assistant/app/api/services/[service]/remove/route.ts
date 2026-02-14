import { NextRequest, NextResponse } from 'next/server'

const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:18789'

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ service: string }> }
) {
  try {
    const { service } = await params

    // Parse request body for options
    let options = { volumes: false, force: false }
    try {
      const body = await request.json()
      options = {
        volumes: body.volumes === true,
        force: body.force === true,
      }
    } catch {
      // No body or invalid JSON, use defaults
    }

    const response = await fetch(
      `${GATEWAY_URL}/api/services/${service}/remove`,
      {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(options),
      }
    )

    const data = await response.json()

    if (!response.ok) {
      return NextResponse.json(
        { success: false, error: data.error || 'Gateway request failed' },
        { status: response.status }
      )
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('[Assistant API] Service remove error:', error)
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    )
  }
}
