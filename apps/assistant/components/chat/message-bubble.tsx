'use client'

import { ChatMessage } from '@/types/chat'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import { format } from 'date-fns'
import { Bot, User, Terminal } from 'lucide-react'

interface MessageBubbleProps {
  message: ChatMessage
  className?: string
}

export function MessageBubble({ message, className }: MessageBubbleProps) {
  const isUser = message.role === 'user'

  return (
    <div
      className={cn(
        'flex gap-3 p-4',
        isUser ? 'justify-end' : 'justify-start',
        className
      )}
    >
      {!isUser && (
        <Avatar className="h-8 w-8">
          <AvatarFallback className="bg-primary text-primary-foreground">
            <Bot className="h-4 w-4" />
          </AvatarFallback>
        </Avatar>
      )}

      <div
        className={cn(
          'max-w-[80%] space-y-2',
          isUser ? 'items-end' : 'items-start'
        )}
      >
        <div
          className={cn(
            'rounded-lg px-4 py-2',
            isUser
              ? 'bg-primary text-primary-foreground'
              : 'bg-muted'
          )}
        >
          <p className="text-sm whitespace-pre-wrap">{message.message}</p>
        </div>

        {/* Intent badge for assistant messages */}
        {!isUser && message.intent && message.intent.action !== 'unknown' && (
          <div className="flex items-center gap-2">
            <Badge variant="outline" className="text-xs">
              {message.intent.action}: {message.intent.service}
            </Badge>
            <span className="text-xs text-muted-foreground">
              {Math.round(message.intent.confidence * 100)}% confidence
            </span>
          </div>
        )}

        {/* Executed command for assistant messages */}
        {!isUser && message.response?.executedCommand && (
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            <Terminal className="h-3 w-3" />
            <code className="bg-slate-100 dark:bg-slate-800 px-1 rounded">
              {message.response.executedCommand}
            </code>
          </div>
        )}

        {/* Timestamp */}
        <span className="text-xs text-muted-foreground">
          {format(new Date(message.timestamp), 'HH:mm')}
        </span>
      </div>

      {isUser && (
        <Avatar className="h-8 w-8">
          <AvatarFallback>
            <User className="h-4 w-4" />
          </AvatarFallback>
        </Avatar>
      )}
    </div>
  )
}
