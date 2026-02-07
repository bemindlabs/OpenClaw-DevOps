import { io, Socket } from 'socket.io-client'

let socket: Socket | null = null

const GATEWAY_URL = process.env.NEXT_PUBLIC_GATEWAY_URL || 'http://localhost:18789'

export function getSocket(): Socket {
  if (!socket) {
    socket = io(GATEWAY_URL, {
      autoConnect: true,
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
      timeout: 10000,
      transports: ['websocket', 'polling'],
    })

    socket.on('connect', () => {
      console.log('Socket connected:', socket?.id)
    })

    socket.on('disconnect', (reason) => {
      console.log('Socket disconnected:', reason)
    })

    socket.on('connect_error', (error) => {
      console.error('Socket connection error:', error.message)
    })
  }

  return socket
}

export function disconnectSocket(): void {
  if (socket) {
    socket.disconnect()
    socket = null
  }
}

// Socket event types
export interface ServiceStatusEvent {
  service: string
  status: string
  health: string
  timestamp: string
}

export interface LogStreamEvent {
  service: string
  data: string
  timestamp: string
}

export interface ChatResponseEvent {
  text: string
  intent?: {
    action: string
    service: string
    confidence: number
  }
  executedCommand?: string
  timestamp: string
}

export interface SystemAlertEvent {
  level: 'info' | 'warning' | 'error'
  message: string
  service?: string
  timestamp: string
}
