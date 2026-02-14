'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import {
  MoreVertical,
  PlayCircle,
  PowerOff,
  Download,
  Trash2,
  Loader2,
} from 'lucide-react'
import { ServiceActionType } from '@/types/service'

interface ServiceActionsProps {
  serviceName: string
  serviceDisplayName: string
  isRunning: boolean
  onAction: (action: ServiceActionType) => void
  actionLoading: boolean
  disabled?: boolean
}

export function ServiceActions({
  serviceName,
  serviceDisplayName,
  isRunning,
  onAction,
  actionLoading,
  disabled = false,
}: ServiceActionsProps) {
  const [confirmAction, setConfirmAction] = useState<{
    action: ServiceActionType
    title: string
    description: string
  } | null>(null)
  const [dropdownOpen, setDropdownOpen] = useState(false)

  const handleAction = (action: ServiceActionType) => {
    // Actions that require confirmation
    if (action === 'remove' || action === 'down') {
      const actionDetails = {
        remove: {
          title: 'Remove Container',
          description: `Are you sure you want to remove the container for "${serviceDisplayName}"? This will delete the container but preserve volumes and images.`,
        },
        down: {
          title: 'Stop and Remove Service',
          description: `Are you sure you want to stop and remove "${serviceDisplayName}"? This will stop the service and remove its container.`,
        },
      }

      setConfirmAction({
        action,
        ...actionDetails[action],
      })
      setDropdownOpen(false)
      return
    }

    // Execute action directly
    onAction(action)
    setDropdownOpen(false)
  }

  const handleConfirm = () => {
    if (confirmAction) {
      onAction(confirmAction.action)
      setConfirmAction(null)
    }
  }

  return (
    <>
      <DropdownMenu open={dropdownOpen} onOpenChange={setDropdownOpen}>
        <DropdownMenuTrigger asChild>
          <Button
            variant="ghost"
            size="icon"
            disabled={disabled || actionLoading}
            className="h-8 w-8"
          >
            {actionLoading ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <MoreVertical className="h-4 w-4" />
            )}
            <span className="sr-only">Open service actions menu</span>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem
            onClick={() => handleAction('up')}
            disabled={actionLoading}
          >
            <PlayCircle className="mr-2 h-4 w-4" />
            <span>Create & Start (Up)</span>
          </DropdownMenuItem>
          <DropdownMenuItem
            onClick={() => handleAction('pull')}
            disabled={actionLoading}
          >
            <Download className="mr-2 h-4 w-4" />
            <span>Pull Latest Image</span>
          </DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem
            onClick={() => handleAction('down')}
            disabled={actionLoading}
            className="text-orange-600 focus:text-orange-600"
          >
            <PowerOff className="mr-2 h-4 w-4" />
            <span>Stop & Remove (Down)</span>
          </DropdownMenuItem>
          <DropdownMenuItem
            onClick={() => handleAction('remove')}
            disabled={actionLoading || isRunning}
            className="text-destructive focus:text-destructive"
          >
            <Trash2 className="mr-2 h-4 w-4" />
            <span>Remove Container</span>
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>

      <AlertDialog
        open={confirmAction !== null}
        onOpenChange={(open) => !open && setConfirmAction(null)}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>{confirmAction?.title}</AlertDialogTitle>
            <AlertDialogDescription>
              {confirmAction?.description}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={() => setConfirmAction(null)}>
              Cancel
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={handleConfirm}
              className={
                confirmAction?.action === 'remove'
                  ? 'bg-destructive text-destructive-foreground hover:bg-destructive/90'
                  : 'bg-orange-600 text-white hover:bg-orange-700'
              }
            >
              {confirmAction?.action === 'remove' ? 'Remove' : 'Stop & Remove'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}
