import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Server, Database, Activity, Clock, TrendingUp, Zap, MessageSquare, FileText } from 'lucide-react'

export default function DashboardPage() {
  return (
    <div className="space-y-8 animate-fade-in">
      {/* Header */}
      <div>
        <div className="flex items-center gap-3 mb-2">
          <div className="flex items-center gap-2">
            <span className="relative flex h-3 w-3">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-3 w-3 bg-primary-500"></span>
            </span>
            <h1 className="text-4xl font-bold tracking-tight text-neutral-50">Dashboard</h1>
          </div>
        </div>
        <p className="text-neutral-400 text-lg">
          Manage your OpenClaw DevOps services and infrastructure
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <Card className="bg-neutral-900 border-neutral-800 hover:border-primary-800 transition-colors">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-neutral-300">Total Services</CardTitle>
            <Server className="h-4 w-4 text-primary-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-neutral-50">16</div>
            <p className="text-xs text-neutral-500 mt-1 flex items-center gap-1">
              <TrendingUp className="h-3 w-3 text-primary-500" />
              Across 4 categories
            </p>
          </CardContent>
        </Card>

        <Card className="bg-neutral-900 border-neutral-800 hover:border-primary-800 transition-colors">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-neutral-300">Healthy Services</CardTitle>
            <Activity className="h-4 w-4 text-primary-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-neutral-50">14</div>
            <div className="mt-1 flex items-center gap-2">
              <Badge className="status-healthy text-xs">Running</Badge>
              <span className="text-xs text-neutral-500">2 degraded</span>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-neutral-900 border-neutral-800 hover:border-primary-800 transition-colors">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-neutral-300">Chat Sessions</CardTitle>
            <MessageSquare className="h-4 w-4 text-accent-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-neutral-50">0</div>
            <p className="text-xs text-neutral-500 mt-1">
              Start chatting to manage services
            </p>
          </CardContent>
        </Card>

        <Card className="bg-neutral-900 border-neutral-800 hover:border-primary-800 transition-colors">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-neutral-300">Uptime</CardTitle>
            <Clock className="h-4 w-4 text-primary-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-neutral-50">99.9%</div>
            <p className="text-xs text-neutral-500 mt-1">
              Last 30 days average
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Main Content Grid */}
      <div className="grid gap-6 md:grid-cols-2">
        {/* Quick Actions */}
        <Card className="bg-neutral-900 border-neutral-800">
          <CardHeader>
            <div className="flex items-center gap-2">
              <Zap className="h-5 w-5 text-primary-500" />
              <CardTitle className="text-neutral-50">Quick Actions</CardTitle>
            </div>
            <CardDescription className="text-neutral-400">
              Common service management tasks
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-950 border border-neutral-800 hover:border-primary-800 hover:bg-neutral-950/50 cursor-pointer transition-all group">
              <div className="flex items-center gap-3">
                <Server className="h-4 w-4 text-neutral-500 group-hover:text-primary-500 transition-colors" />
                <span className="text-sm text-neutral-300 group-hover:text-neutral-100 transition-colors">View all services</span>
              </div>
              <Badge variant="outline" className="border-neutral-700 text-neutral-500">16 services</Badge>
            </div>
            <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-950 border border-neutral-800 hover:border-accent-800 hover:bg-neutral-950/50 cursor-pointer transition-all group">
              <div className="flex items-center gap-3">
                <MessageSquare className="h-4 w-4 text-neutral-500 group-hover:text-accent-500 transition-colors" />
                <span className="text-sm text-neutral-300 group-hover:text-neutral-100 transition-colors">Open chat interface</span>
              </div>
              <Badge variant="outline" className="border-neutral-700 text-neutral-500">Chat</Badge>
            </div>
            <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-950 border border-neutral-800 hover:border-primary-800 hover:bg-neutral-950/50 cursor-pointer transition-all group">
              <div className="flex items-center gap-3">
                <FileText className="h-4 w-4 text-neutral-500 group-hover:text-primary-500 transition-colors" />
                <span className="text-sm text-neutral-300 group-hover:text-neutral-100 transition-colors">View service logs</span>
              </div>
              <Badge variant="outline" className="border-neutral-700 text-neutral-500">Logs</Badge>
            </div>
            <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-950 border border-neutral-800 hover:border-primary-800 hover:bg-neutral-950/50 cursor-pointer transition-all group">
              <div className="flex items-center gap-3">
                <Activity className="h-4 w-4 text-neutral-500 group-hover:text-primary-500 transition-colors" />
                <span className="text-sm text-neutral-300 group-hover:text-neutral-100 transition-colors">Health monitoring</span>
              </div>
              <Badge className="status-healthy">Active</Badge>
            </div>
          </CardContent>
        </Card>

        {/* Service Categories */}
        <Card className="bg-neutral-900 border-neutral-800">
          <CardHeader>
            <div className="flex items-center gap-2">
              <Database className="h-5 w-5 text-accent-500" />
              <CardTitle className="text-neutral-50">Service Categories</CardTitle>
            </div>
            <CardDescription className="text-neutral-400">
              Services organized by type
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-3">
              <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-950 border border-neutral-800">
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 rounded-full bg-primary-500"></div>
                  <span className="text-sm text-neutral-300">Core Services</span>
                </div>
                <div className="flex items-center gap-2">
                  <Badge className="bg-primary-950 text-primary-400 border-primary-800">3</Badge>
                  <span className="text-xs text-neutral-500">100% healthy</span>
                </div>
              </div>

              <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-950 border border-neutral-800">
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 rounded-full bg-accent-500"></div>
                  <span className="text-sm text-neutral-300">Database Services</span>
                </div>
                <div className="flex items-center gap-2">
                  <Badge className="bg-accent-950 text-accent-400 border-accent-800">3</Badge>
                  <span className="text-xs text-neutral-500">100% healthy</span>
                </div>
              </div>

              <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-950 border border-neutral-800">
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 rounded-full bg-info"></div>
                  <span className="text-sm text-neutral-300">Messaging Services</span>
                </div>
                <div className="flex items-center gap-2">
                  <Badge className="bg-blue-950 text-blue-400 border-blue-800">3</Badge>
                  <span className="text-xs text-amber-500">66% healthy</span>
                </div>
              </div>

              <div className="flex items-center justify-between p-3 rounded-lg bg-neutral-950 border border-neutral-800">
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 rounded-full bg-warning"></div>
                  <span className="text-sm text-neutral-300">Monitoring Services</span>
                </div>
                <div className="flex items-center gap-2">
                  <Badge className="bg-amber-950 text-amber-400 border-amber-800">7</Badge>
                  <span className="text-xs text-neutral-500">85% healthy</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Recent Activity */}
      <Card className="bg-neutral-900 border-neutral-800">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <div className="flex items-center gap-2">
                <Activity className="h-5 w-5 text-primary-500" />
                <CardTitle className="text-neutral-50">Recent Activity</CardTitle>
              </div>
              <CardDescription className="text-neutral-400 mt-1">
                Latest system events and service changes
              </CardDescription>
            </div>
            <Badge variant="outline" className="border-neutral-700 text-neutral-500">
              Last 24 hours
            </Badge>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-start gap-4 pb-4 border-b border-neutral-800">
              <div className="flex-shrink-0 w-2 h-2 rounded-full bg-primary-500 mt-2"></div>
              <div className="flex-1">
                <div className="flex items-center justify-between mb-1">
                  <p className="text-sm text-neutral-300">All services started successfully</p>
                  <span className="text-xs text-neutral-500">2 hours ago</span>
                </div>
                <p className="text-xs text-neutral-500">16 services are now running</p>
              </div>
            </div>

            <div className="flex items-start gap-4 pb-4 border-b border-neutral-800">
              <div className="flex-shrink-0 w-2 h-2 rounded-full bg-accent-500 mt-2"></div>
              <div className="flex-1">
                <div className="flex items-center justify-between mb-1">
                  <p className="text-sm text-neutral-300">MongoDB backup completed</p>
                  <span className="text-xs text-neutral-500">5 hours ago</span>
                </div>
                <p className="text-xs text-neutral-500">Automated daily backup successful</p>
              </div>
            </div>

            <div className="flex items-start gap-4">
              <div className="flex-shrink-0 w-2 h-2 rounded-full bg-info mt-2"></div>
              <div className="flex-1">
                <div className="flex items-center justify-between mb-1">
                  <p className="text-sm text-neutral-300">Prometheus metrics collected</p>
                  <span className="text-xs text-neutral-500">8 hours ago</span>
                </div>
                <p className="text-xs text-neutral-500">System performance metrics updated</p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
