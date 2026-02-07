export interface ChatMessage {
  id: string
  userId: string
  userName: string
  message: string
  role: 'user' | 'assistant'
  intent?: {
    action: string
    service: string
    confidence: number
  }
  response?: {
    text: string
    executedCommand?: string
    exitCode?: number
    data?: any
  }
  timestamp: Date
  sessionId: string
}

export interface ChatIntent {
  action: 'start' | 'stop' | 'restart' | 'logs' | 'status' | 'help' | 'unknown'
  service: string | 'all'
  confidence: number
}
