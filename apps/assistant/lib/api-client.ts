import { ServiceStatusResponse } from '@/types/service'

// Use relative URLs to hit our Next.js API routes, which proxy to the gateway
// This works both in development and production, regardless of domain
const API_BASE = ''

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

  // Create and start a service (docker-compose up)
  async upService(service: string) {
    return fetchApi<{ message: string; output: string }>(`/api/services/${service}/up`, {
      method: 'POST',
    })
  },

  // Stop and remove a service (docker-compose down)
  async downService(service: string) {
    return fetchApi<{ message: string; output: string }>(`/api/services/${service}/down`, {
      method: 'POST',
    })
  },

  // Pull latest image for a service
  async pullService(service: string) {
    return fetchApi<{ message: string; output: string }>(`/api/services/${service}/pull`, {
      method: 'POST',
    })
  },

  // Remove a service container
  async removeService(service: string) {
    return fetchApi<{ message: string; output: string }>(`/api/services/${service}/remove`, {
      method: 'DELETE',
    })
  },

  // Send chat message (for Telegram bridge or direct chat)
  async sendChatMessage(message: string, sessionId?: string, mode: 'command' | 'assistant' = 'command') {
    return fetchApi<{
      response: string
      mode?: string
      provider?: string
      intent?: { action: string; service: string; confidence: number }
      executedCommand?: string
    }>('/api/chat/message', {
      method: 'POST',
      body: JSON.stringify({ message, sessionId, mode }),
    })
  },

  // Get LLM status
  async getLLMStatus() {
    return fetchApi<{
      provider: string
      availableProviders: string[]
      fallbackProviders: string[]
      activeConversations: number
    }>('/api/chat/llm/status')
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
