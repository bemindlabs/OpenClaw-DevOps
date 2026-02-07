import { ServiceStatusResponse } from '@/types/service'

const API_BASE = process.env.NEXT_PUBLIC_GATEWAY_URL || 'http://localhost:18789'

interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
}

async function fetchApi<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  try {
    const response = await fetch(`${API_BASE}${endpoint}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      return {
        success: false,
        error: errorData.message || `HTTP ${response.status}: ${response.statusText}`,
      }
    }

    const data = await response.json()
    return { success: true, data }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error occurred',
    }
  }
}

export const apiClient = {
  // Health check
  async getHealth() {
    return fetchApi<{ status: string; service: string; version: string }>('/health')
  },

  // Get status of all services
  async getAllServicesStatus() {
    return fetchApi<Record<string, ServiceStatusResponse>>('/api/services/status')
  },

  // Get individual service status
  async getServiceStatus(service: string) {
    return fetchApi<ServiceStatusResponse>(`/api/services/${service}/status`)
  },

  // Start a service
  async startService(service: string) {
    return fetchApi<{ message: string; output: string }>(`/api/services/${service}/start`, {
      method: 'POST',
    })
  },

  // Stop a service
  async stopService(service: string) {
    return fetchApi<{ message: string; output: string }>(`/api/services/${service}/stop`, {
      method: 'POST',
    })
  },

  // Restart a service
  async restartService(service: string) {
    return fetchApi<{ message: string; output: string }>(`/api/services/${service}/restart`, {
      method: 'POST',
    })
  },

  // Send chat message (for Telegram bridge or direct chat)
  async sendChatMessage(message: string, sessionId?: string) {
    return fetchApi<{
      response: string
      intent: { action: string; service: string; confidence: number }
      executedCommand?: string
    }>('/api/chat/message', {
      method: 'POST',
      body: JSON.stringify({ message, sessionId }),
    })
  },

  // Get chat history
  async getChatHistory(limit = 50) {
    return fetchApi<Array<{
      id: string
      message: string
      response: string
      timestamp: string
    }>>(`/api/chat/history?limit=${limit}`)
  },
}

export default apiClient
