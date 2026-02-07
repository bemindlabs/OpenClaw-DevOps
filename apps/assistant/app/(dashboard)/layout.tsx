import { auth } from '@/lib/auth'
import { redirect } from 'next/navigation'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Button } from '@/components/ui/button'
import { signOut } from '@/lib/auth'
import Link from 'next/link'
import { LayoutDashboard, MessageSquare, Server, FileText, LogOut, Zap } from 'lucide-react'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const session = await auth()

  if (!session?.user) {
    redirect('/login')
  }

  const navigation = [
    { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
    { name: 'Services', href: '/dashboard/services', icon: Server },
    { name: 'Chat', href: '/dashboard/chat', icon: MessageSquare },
    { name: 'Logs', href: '/dashboard/logs', icon: FileText },
  ]

  const userInitials = session.user.name
    ?.split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase() || 'U'

  return (
    <div className="min-h-screen bg-background-primary">
      {/* Sidebar - Using Design System Colors */}
      <div className="fixed left-0 top-0 h-screen w-64 border-r border-neutral-800 bg-neutral-950 flex flex-col">
        {/* Logo Section */}
        <div className="p-6 border-b border-neutral-800">
          <div className="flex items-center gap-2 mb-1">
            <div className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary-500 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-primary-500"></span>
            </div>
            <h1 className="text-lg font-bold text-text-primary">OpenClaw</h1>
          </div>
          <p className="text-xs text-text-tertiary ml-4">Admin Portal</p>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
          {navigation.map((item) => {
            const Icon = item.icon
            return (
              <Link
                key={item.name}
                href={item.href}
                className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-text-secondary hover:text-text-primary hover:bg-neutral-900 transition-all group"
              >
                <Icon className="h-5 w-5 text-neutral-500 group-hover:text-primary-500 transition-colors" />
                <span className="group-hover:translate-x-0.5 transition-transform">{item.name}</span>
              </Link>
            )
          })}
        </nav>

        {/* User Section - Bottom */}
        <div className="p-4 border-t border-neutral-800">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                className="w-full justify-start gap-3 p-3 h-auto hover:bg-neutral-900 transition-colors"
              >
                <Avatar className="h-9 w-9 ring-2 ring-neutral-800">
                  <AvatarImage src={session.user.image || undefined} />
                  <AvatarFallback className="bg-primary-950 text-primary-400 text-xs font-semibold">
                    {userInitials}
                  </AvatarFallback>
                </Avatar>
                <div className="flex flex-col items-start text-left flex-1 min-w-0">
                  <span className="font-medium text-sm text-text-primary truncate w-full">
                    {session.user.name}
                  </span>
                  <span className="text-xs text-text-tertiary truncate w-full">
                    {session.user.email}
                  </span>
                </div>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent
              align="end"
              className="w-64 bg-neutral-900 border-neutral-800"
            >
              <DropdownMenuLabel className="text-text-secondary">My Account</DropdownMenuLabel>
              <DropdownMenuSeparator className="bg-neutral-800" />
              <DropdownMenuItem className="text-text-tertiary text-xs hover:bg-neutral-800 hover:text-text-secondary">
                Role: <span className="ml-1 text-primary-400 font-medium">{session.user.role}</span>
              </DropdownMenuItem>
              <DropdownMenuSeparator className="bg-neutral-800" />
              <form
                action={async () => {
                  'use server'
                  await signOut({ redirectTo: '/login' })
                }}
              >
                <Button
                  type="submit"
                  variant="ghost"
                  className="w-full justify-start text-sm text-text-secondary hover:text-text-primary hover:bg-neutral-800"
                >
                  <LogOut className="mr-2 h-4 w-4" />
                  Sign out
                </Button>
              </form>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Main Content Area */}
      <div className="ml-64 min-h-screen">
        <div className="p-8 max-w-7xl mx-auto">
          {children}
        </div>
      </div>
    </div>
  )
}
