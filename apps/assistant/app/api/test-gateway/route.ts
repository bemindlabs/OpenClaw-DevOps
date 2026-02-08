import { NextRequest, NextResponse } from 'next/server'

// Use localhost for dev mode on host, host.docker.internal for Docker Desktop
const isDocker = require('fs').existsSync('/.dockerenv')
const GATEWAY_URL = process.env.GATEWAY_URL || (isDocker ? 'http://host.docker.internal:18789' : 'http://localhost:18789')

export async function GET(request: NextRequest) {
  const results: any = {
    gateway_url: GATEWAY_URL,
    tests: []
  }

  // Test 1: Health check
  try {
    const healthResponse = await fetch(`${GATEWAY_URL}/health`)
    const healthData = await healthResponse.json()
    results.tests.push({
      name: 'Health Check',
      success: true,
      status: healthResponse.status,
      data: healthData
    })
  } catch (error) {
    results.tests.push({
      name: 'Health Check',
      success: false,
      error: error instanceof Error ? {
        message: error.message,
        stack: error.stack,
        cause: error.cause?.toString()
      } : String(error)
    })
  }

  // Test 2: Chat endpoint GET
  try {
    const chatResponse = await fetch(`${GATEWAY_URL}/api/chat/message`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    })
    const chatData = await chatResponse.text()
    results.tests.push({
      name: 'Chat GET',
      success: true,
      status: chatResponse.status,
      data: chatData
    })
  } catch (error) {
    results.tests.push({
      name: 'Chat GET',
      success: false,
      error: error instanceof Error ? {
        message: error.message,
        stack: error.stack,
        cause: error.cause?.toString()
      } : String(error)
    })
  }

  // Test 3: Chat endpoint POST
  try {
    const chatResponse = await fetch(`${GATEWAY_URL}/api/chat/message`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ message: 'test', mode: 'assistant' })
    })
    const chatData = await chatResponse.json()
    results.tests.push({
      name: 'Chat POST',
      success: true,
      status: chatResponse.status,
      data: chatData
    })
  } catch (error) {
    results.tests.push({
      name: 'Chat POST',
      success: false,
      error: error instanceof Error ? {
        message: error.message,
        stack: error.stack,
        cause: error.cause?.toString()
      } : String(error)
    })
  }

  return NextResponse.json(results, { status: 200 })
}
