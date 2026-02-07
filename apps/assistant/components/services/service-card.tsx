'use client'

import { Service } from '@/types/service'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { HealthBadge, StatusDot } from './health-badge'
import { Play, Square, RotateCcw, Loader2 } from 'lucide-react'
import { cn } from '@/lib/utils'

interface ServiceCardProps {
  service: Service
  onAction: (action: 'start' | 'stop' | 'restart') => void
  actionLoading?: boolean
  userRole?: 'admin' | 'operator' | 'viewer'
}

export function ServiceCard({
  service,
  onAction,
  actionLoading = false,
  userRole = 'admin',
}: ServiceCardProps) {
  const canControl = userRole === 'admin' || userRole === 'operator'
  const isRunning = service.status === 'running'

  const getCategoryColor = () => {
    switch (service.category) {
      case 'core':
        return 'border-l-blue-500'
      case 'database':
        return 'border-l-green-500'
      case 'messaging':
        return 'border-l-purple-500'
      case 'monitoring':
        return 'border-l-orange-500'
      default:
        return 'border-l-gray-500'
    }
  }

  return (
    <Card className={cn('border-l-4', getCategoryColor())}>
      <CardHeader className="pb-2">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <StatusDot health={service.health} status={service.status} />
            <CardTitle className="text-lg">{service.displayName}</CardTitle>
          </div>
          <HealthBadge health={service.health} status={service.status} />
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-3">
          {/* Service Info */}
          <div className="grid grid-cols-2 gap-2 text-sm text-muted-foreground">
            <div>
              <span className="font-medium">Port:</span> {service.port || 'N/A'}
            </div>
            <div>
              <span className="font-medium">Uptime:</span> {service.uptime || 'N/A'}
            </div>
            {service.restartCount !== undefined && (
              <div className="col-span-2">
                <span className="font-medium">Restarts:</span> {service.restartCount}
              </div>
            )}
          </div>

          {/* Action Buttons */}
          {canControl && (
            <div className="flex gap-2 pt-2">
              {!isRunning ? (
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => onAction('start')}
                  disabled={actionLoading}
                  className="flex-1"
                >
                  {actionLoading ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Play className="h-4 w-4 mr-1" />
                  )}
                  Start
                </Button>
              ) : (
                <>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => onAction('restart')}
                    disabled={actionLoading}
                    className="flex-1"
                  >
                    {actionLoading ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <RotateCcw className="h-4 w-4 mr-1" />
                    )}
                    Restart
                  </Button>
                  <Button
                    size="sm"
                    variant="destructive"
                    onClick={() => onAction('stop')}
                    disabled={actionLoading}
                  >
                    {actionLoading ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <Square className="h-4 w-4" />
                    )}
                  </Button>
                </>
              )}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
}
