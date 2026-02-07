export type ServiceStatus = 'running' | 'exited' | 'restarting' | 'paused' | 'dead' | 'created' | 'removing'
export type ServiceHealth = 'healthy' | 'unhealthy' | 'starting' | 'unknown'

export interface Service {
  name: string
  displayName: string
  category: 'core' | 'database' | 'messaging' | 'monitoring'
  status: ServiceStatus
  health: ServiceHealth
  port?: number
  uptime?: string
  restartCount?: number
  lastStarted?: string
}

export interface ServiceAction {
  service: string
  action: 'start' | 'stop' | 'restart' | 'logs'
}

export interface ServiceStatusResponse {
  service: string
  status: ServiceStatus
  health: ServiceHealth
  uptime: number
  restartCount: number
  lastStarted: string
}
