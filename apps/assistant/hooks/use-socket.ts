'use client'

import { useEffect, useRef, useCallback, useState } from 'react'
import { Socket } from 'socket.io-client'
import {
  getSocket,
  disconnectSocket,
  ServiceStatusEvent,
  LogStreamEvent,
  ChatResponseEvent,
  SystemAlertEvent,
} from '@/lib/socket'

interface UseSocketReturn {
  socket: Socket | null
  connected: boolean
  emit: (event: string, data: any) => void
  on: (event: string, callback: (data: any) => void) => void
  off: (event: string, callback?: (data: any) => void) => void
}

export function useSocket(): UseSocketReturn {
  const socketRef = useRef<Socket | null>(null)
  const [connected, setConnected] = useState(false)

  useEffect(() => {
    socketRef.current = getSocket()

    const handleConnect = () => setConnected(true)
    const handleDisconnect = () => setConnected(false)

    socketRef.current.on('connect', handleConnect)
    socketRef.current.on('disconnect', handleDisconnect)

    // Set initial state
    setConnected(socketRef.current.connected)

    return () => {
      socketRef.current?.off('connect', handleConnect)
      socketRef.current?.off('disconnect', handleDisconnect)
    }
  }, [])

  const emit = useCallback((event: string, data: any) => {
    socketRef.current?.emit(event, data)
  }, [])

  const on = useCallback((event: string, callback: (data: any) => void) => {
    socketRef.current?.on(event, callback)
  }, [])

  const off = useCallback((event: string, callback?: (data: any) => void) => {
    if (callback) {
      socketRef.current?.off(event, callback)
    } else {
      socketRef.current?.off(event)
    }
  }, [])

  return {
    socket: socketRef.current,
    connected,
    emit,
    on,
    off,
  }
}

// Hook for service status updates
export function useServiceStatusUpdates(
  onStatusUpdate: (data: ServiceStatusEvent) => void
) {
  const { on, off } = useSocket()

  useEffect(() => {
    on('service:status', onStatusUpdate)
    return () => off('service:status', onStatusUpdate)
  }, [on, off, onStatusUpdate])
}

// Hook for log streaming
export function useLogStream(
  service: string | null,
  onLogData: (data: LogStreamEvent) => void
) {
  const { emit, on, off } = useSocket()

  useEffect(() => {
    if (!service) return

    // Subscribe to logs
    emit('logs:subscribe', { service })
    on('logs:stream', onLogData)

    return () => {
      emit('logs:unsubscribe', { service })
      off('logs:stream', onLogData)
    }
  }, [service, emit, on, off, onLogData])
}

// Hook for system alerts
export function useSystemAlerts(onAlert: (data: SystemAlertEvent) => void) {
  const { on, off } = useSocket()

  useEffect(() => {
    on('system:alert', onAlert)
    return () => off('system:alert', onAlert)
  }, [on, off, onAlert])
}
