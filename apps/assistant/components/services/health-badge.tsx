'use client'

import { Badge } from '@/components/ui/badge'
import { ServiceHealth, ServiceStatus } from '@/types/service'
import { cn } from '@/lib/utils'

interface HealthBadgeProps {
  health: ServiceHealth
  status: ServiceStatus
  className?: string
}

export function HealthBadge({ health, status, className }: HealthBadgeProps) {
  const getStatusColor = () => {
    if (status === 'running') {
      switch (health) {
        case 'healthy':
          return 'bg-green-500 text-white'
        case 'unhealthy':
          return 'bg-red-500 text-white'
        case 'starting':
          return 'bg-yellow-500 text-white'
        default:
          return 'bg-blue-500 text-white'
      }
    }

    switch (status) {
      case 'exited':
        return 'bg-gray-500 text-white'
      case 'restarting':
        return 'bg-yellow-500 text-white'
      case 'paused':
        return 'bg-orange-500 text-white'
      case 'dead':
        return 'bg-red-600 text-white'
      default:
        return 'bg-gray-400 text-white'
    }
  }

  const getLabel = () => {
    if (status === 'running') {
      return health.charAt(0).toUpperCase() + health.slice(1)
    }
    return status.charAt(0).toUpperCase() + status.slice(1)
  }

  return (
    <Badge className={cn(getStatusColor(), className)}>
      {getLabel()}
    </Badge>
  )
}

interface StatusDotProps {
  health: ServiceHealth
  status: ServiceStatus
  className?: string
}

export function StatusDot({ health, status, className }: StatusDotProps) {
  const getColor = () => {
    if (status === 'running') {
      switch (health) {
        case 'healthy':
          return 'bg-green-500'
        case 'unhealthy':
          return 'bg-red-500'
        case 'starting':
          return 'bg-yellow-500 animate-pulse'
        default:
          return 'bg-blue-500'
      }
    }

    switch (status) {
      case 'exited':
        return 'bg-gray-500'
      case 'restarting':
        return 'bg-yellow-500 animate-pulse'
      default:
        return 'bg-gray-400'
    }
  }

  return (
    <span
      className={cn(
        'inline-block h-2.5 w-2.5 rounded-full',
        getColor(),
        className
      )}
    />
  )
}
