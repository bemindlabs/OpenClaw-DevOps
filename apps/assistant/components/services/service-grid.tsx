'use client'

import { useServices, SERVICE_CATEGORIES } from '@/hooks/use-services'
import { ServiceCard } from './service-card'
import { Button } from '@/components/ui/button'
import { RefreshCw, Loader2 } from 'lucide-react'

interface ServiceGridProps {
  userRole?: 'admin' | 'operator' | 'viewer'
}

export function ServiceGrid({ userRole = 'admin' }: ServiceGridProps) {
  const { services, loading, error, refreshServices, executeAction, actionLoading } =
    useServices()

  const categoryLabels = {
    core: 'Core Services',
    database: 'Database Services',
    messaging: 'Messaging Services',
    monitoring: 'Monitoring Services',
  }

  const categoryDescriptions = {
    core: 'Essential services for the platform',
    database: 'Data storage and caching',
    messaging: 'Event streaming and workflow automation',
    monitoring: 'Metrics collection and visualization',
  }

  const handleAction = async (
    serviceName: string,
    action: 'start' | 'stop' | 'restart'
  ) => {
    const result = await executeAction(serviceName, action)
    if (!result.success) {
      // TODO: Show toast notification
      console.error(result.message)
    }
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center">
        <p className="text-destructive mb-4">{error}</p>
        <Button onClick={refreshServices} variant="outline">
          <RefreshCw className="mr-2 h-4 w-4" />
          Retry
        </Button>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Header with refresh button */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">Services</h2>
          <p className="text-muted-foreground">
            Manage and monitor all platform services
          </p>
        </div>
        <Button
          onClick={refreshServices}
          variant="outline"
          size="sm"
          disabled={loading}
        >
          {loading ? (
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
          ) : (
            <RefreshCw className="mr-2 h-4 w-4" />
          )}
          Refresh
        </Button>
      </div>

      {/* Service categories */}
      {(Object.keys(SERVICE_CATEGORIES) as Array<keyof typeof SERVICE_CATEGORIES>).map(
        (category) => (
          <section key={category}>
            <div className="mb-4">
              <h3 className="text-lg font-semibold">
                {categoryLabels[category]}
              </h3>
              <p className="text-sm text-muted-foreground">
                {categoryDescriptions[category]}
              </p>
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {SERVICE_CATEGORIES[category].map((serviceName) => {
                const service = services[serviceName]
                if (!service) return null

                return (
                  <ServiceCard
                    key={serviceName}
                    service={service}
                    onAction={(action) => handleAction(serviceName, action)}
                    actionLoading={actionLoading[serviceName]}
                    userRole={userRole}
                  />
                )
              })}
            </div>
          </section>
        )
      )}
    </div>
  )
}
