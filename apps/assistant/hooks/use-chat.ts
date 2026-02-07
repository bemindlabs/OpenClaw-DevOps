'use client'

import { useState, useCallback, useRef, useEffect } from 'react'
import { ChatMessage, ChatIntent } from '@/types/chat'
import apiClient from '@/lib/api-client'
import { useSocket } from './use-socket'

interface UseChatReturn {
  messages: ChatMessage[]
  sendMessage: (text: string) => Promise<void>
  isLoading: boolean
  error: string | null
  clearMessages: () => void
  sessionId: string
}

export function useChat(): UseChatReturn {
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const sessionIdRef = useRef<string>(generateSessionId())
  const { emit, on, off, connected } = useSocket()

  // Generate unique session ID
  function generateSessionId(): string {
    return `session_${Date.now()}_${Math.random().toString(36).substring(7)}`
  }

  // Listen for real-time chat responses (if using WebSocket)
  useEffect(() => {
    const handleChatResponse = (data: any) => {
      const assistantMessage: ChatMessage = {
        id: `msg_${Date.now()}`,
        userId: 'system',
        userName: 'OpenClaw Assistant',
        message: data.text,
        role: 'assistant',
        intent: data.intent,
        response: {
          text: data.text,
          executedCommand: data.executedCommand,
        },
        timestamp: new Date(),
        sessionId: sessionIdRef.current,
      }

      setMessages((prev) => [...prev, assistantMessage])
      setIsLoading(false)
    }

    on('chat:response', handleChatResponse)
    return () => off('chat:response', handleChatResponse)
  }, [on, off])

  const sendMessage = useCallback(
    async (text: string) => {
      if (!text.trim()) return

      setIsLoading(true)
      setError(null)

      // Add user message immediately
      const userMessage: ChatMessage = {
        id: `msg_${Date.now()}`,
        userId: 'user',
        userName: 'You',
        message: text,
        role: 'user',
        timestamp: new Date(),
        sessionId: sessionIdRef.current,
      }

      setMessages((prev) => [...prev, userMessage])

      try {
        // Send via REST API (will be bridged to Telegram or processed directly)
        const response = await apiClient.sendChatMessage(text, sessionIdRef.current)

        if (response.success && response.data) {
          const assistantMessage: ChatMessage = {
            id: `msg_${Date.now() + 1}`,
            userId: 'system',
            userName: 'OpenClaw Assistant',
            message: response.data.response,
            role: 'assistant',
            intent: response.data.intent,
            response: {
              text: response.data.response,
              executedCommand: response.data.executedCommand,
            },
            timestamp: new Date(),
            sessionId: sessionIdRef.current,
          }

          setMessages((prev) => [...prev, assistantMessage])
        } else {
          setError(response.error || 'Failed to send message')
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to send message')
      } finally {
        setIsLoading(false)
      }
    },
    []
  )

  const clearMessages = useCallback(() => {
    setMessages([])
    sessionIdRef.current = generateSessionId()
  }, [])

  return {
    messages,
    sendMessage,
    isLoading,
    error,
    clearMessages,
    sessionId: sessionIdRef.current,
  }
}
