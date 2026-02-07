'use client'

import { useState, useCallback, useRef, useEffect } from 'react'
import { useSocket } from './use-socket'

interface LogEntry {
  id: string
  timestamp: Date
  level: 'info' | 'warn' | 'error' | 'debug'
  message: string
  service: string
}

interface UseLogsReturn {
  logs: LogEntry[]
  subscribe: (service: string) => void
  unsubscribe: (service: string) => void
  clearLogs: () => void
  isStreaming: boolean
  currentService: string | null
}

export function useLogs(): UseLogsReturn {
  const [logs, setLogs] = useState<LogEntry[]>([])
  const [currentService, setCurrentService] = useState<string | null>(null)
  const [isStreaming, setIsStreaming] = useState(false)
  const { emit, on, off } = useSocket()

  // Parse log level from log message
  const parseLogLevel = (message: string): LogEntry['level'] => {
    const lowerMessage = message.toLowerCase()
    if (lowerMessage.includes('error') || lowerMessage.includes('err')) return 'error'
    if (lowerMessage.includes('warn') || lowerMessage.includes('warning')) return 'warn'
    if (lowerMessage.includes('debug')) return 'debug'
    return 'info'
  }

  // Handle incoming log stream data
  useEffect(() => {
    const handleLogStream = (data: { service: string; data: string; timestamp: string }) => {
      if (data.service !== currentService) return

      // Split multi-line logs
      const lines = data.data.split('\n').filter((line) => line.trim())

      const newEntries: LogEntry[] = lines.map((line, index) => ({
        id: `${Date.now()}_${index}`,
        timestamp: new Date(data.timestamp || Date.now()),
        level: parseLogLevel(line),
        message: line,
        service: data.service,
      }))

      setLogs((prev) => {
        // Keep last 1000 logs to prevent memory issues
        const combined = [...prev, ...newEntries]
        return combined.slice(-1000)
      })
    }

    on('logs:stream', handleLogStream)
    return () => off('logs:stream', handleLogStream)
  }, [on, off, currentService])

  const subscribe = useCallback(
    (service: string) => {
      // Unsubscribe from previous service
      if (currentService && currentService !== service) {
        emit('logs:unsubscribe', { service: currentService })
      }

      setCurrentService(service)
      setLogs([])
      setIsStreaming(true)
      emit('logs:subscribe', { service })
    },
    [emit, currentService]
  )

  const unsubscribe = useCallback(
    (service: string) => {
      emit('logs:unsubscribe', { service })
      setIsStreaming(false)
      setCurrentService(null)
    },
    [emit]
  )

  const clearLogs = useCallback(() => {
    setLogs([])
  }, [])

  return {
    logs,
    subscribe,
    unsubscribe,
    clearLogs,
    isStreaming,
    currentService,
  }
}
