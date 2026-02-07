'use client'

import { useState, useEffect, useCallback } from 'react'
import { Service, ServiceStatus, ServiceHealth } from '@/types/service'
import { SERVICES, SERVICE_CATEGORIES } from '@/lib/constants'
import apiClient from '@/lib/api-client'

interface UseServicesReturn {
  services: Record<string, Service>
  loading: boolean
  error: string | null
  refreshServices: () => Promise<void>
  executeAction: (serviceName: string, action: 'start' | 'stop' | 'restart') => Promise<{
    success: boolean
    message: string
  }>
  actionLoading: Record<string, boolean>
}

export function useServices(): UseServicesReturn {
  const [services, setServices] = useState<Record<string, Service>>({})
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [actionLoading, setActionLoading] = useState<Record<string, boolean>>({})

  // Initialize services with base data
  useEffect(() => {
    const initialServices: Record<string, Service> = {}
    Object.entries(SERVICES).forEach(([name, service]) => {
      initialServices[name] = {
        ...service,
        status: 'created' as ServiceStatus,
        health: 'unknown' as ServiceHealth,
      }
    })
    setServices(initialServices)
  }, [])

  // Fetch service statuses from API
  const refreshServices = useCallback(async () => {
    setLoading(true)
    setError(null)

    try {
      const response = await apiClient.getAllServicesStatus()

      if (response.success && response.data) {
        setServices((prev) => {
          const updated = { ...prev }
          Object.entries(response.data!).forEach(([name, status]) => {
            if (updated[name]) {
              updated[name] = {
                ...updated[name],
                status: status.status,
                health: status.health,
                uptime: formatUptime(status.uptime),
                restartCount: status.restartCount,
                lastStarted: status.lastStarted,
              }
            }
          })
          return updated
        })
      } else {
        // If API fails, mark all as unknown
        setError(response.error || 'Failed to fetch service status')
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch services')
    } finally {
      setLoading(false)
    }
  }, [])

  // Execute service action
  const executeAction = useCallback(
    async (
      serviceName: string,
      action: 'start' | 'stop' | 'restart'
    ): Promise<{ success: boolean; message: string }> => {
      setActionLoading((prev) => ({ ...prev, [serviceName]: true }))

      try {
        let response

        switch (action) {
          case 'start':
            response = await apiClient.startService(serviceName)
            break
          case 'stop':
            response = await apiClient.stopService(serviceName)
            break
          case 'restart':
            response = await apiClient.restartService(serviceName)
            break
        }

        if (response.success) {
          // Refresh status after action
          await refreshServices()
          return {
            success: true,
            message: response.data?.message || `Service ${action} successful`,
          }
        } else {
          return {
            success: false,
            message: response.error || `Failed to ${action} service`,
          }
        }
      } catch (err) {
        return {
          success: false,
          message: err instanceof Error ? err.message : `Failed to ${action} service`,
        }
      } finally {
        setActionLoading((prev) => ({ ...prev, [serviceName]: false }))
      }
    },
    [refreshServices]
  )

  // Auto-refresh on mount
  useEffect(() => {
    refreshServices()

    // Refresh every 30 seconds
    const interval = setInterval(refreshServices, 30000)
    return () => clearInterval(interval)
  }, [refreshServices])

  return {
    services,
    loading,
    error,
    refreshServices,
    executeAction,
    actionLoading,
  }
}

// Helper function to format uptime
function formatUptime(seconds: number): string {
  if (!seconds || seconds < 0) return 'N/A'

  const days = Math.floor(seconds / 86400)
  const hours = Math.floor((seconds % 86400) / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)

  if (days > 0) return `${days}d ${hours}h`
  if (hours > 0) return `${hours}h ${minutes}m`
  return `${minutes}m`
}

// Export categories for grouping
export { SERVICE_CATEGORIES }
