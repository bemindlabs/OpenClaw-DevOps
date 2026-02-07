'use client'

import { useRef, useEffect } from 'react'
import { ChatMessage } from '@/types/chat'
import { MessageBubble } from './message-bubble'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Bot, MessageSquare } from 'lucide-react'

interface MessageListProps {
  messages: ChatMessage[]
  isLoading?: boolean
}

export function MessageList({ messages, isLoading = false }: MessageListProps) {
  const scrollRef = useRef<HTMLDivElement>(null)

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight
    }
  }, [messages])

  if (messages.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-full text-center p-8">
        <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mb-4">
          <MessageSquare className="h-8 w-8 text-primary" />
        </div>
        <h3 className="text-lg font-semibold mb-2">OpenClaw Assistant</h3>
        <p className="text-muted-foreground max-w-md">
          Manage your services through natural language commands. Try commands like:
        </p>
        <div className="mt-4 space-y-2 text-sm">
          <code className="block bg-muted px-3 py-1 rounded">status</code>
          <code className="block bg-muted px-3 py-1 rounded">restart nginx</code>
          <code className="block bg-muted px-3 py-1 rounded">logs mongodb</code>
          <code className="block bg-muted px-3 py-1 rounded">help</code>
        </div>
        <p className="text-xs text-muted-foreground mt-4">
          Commands are also available via Telegram
        </p>
      </div>
    )
  }

  return (
    <ScrollArea className="h-full" ref={scrollRef}>
      <div className="space-y-1">
        {messages.map((message) => (
          <MessageBubble key={message.id} message={message} />
        ))}

        {/* Typing indicator */}
        {isLoading && (
          <div className="flex gap-3 p-4">
            <div className="h-8 w-8 rounded-full bg-primary flex items-center justify-center">
              <Bot className="h-4 w-4 text-primary-foreground" />
            </div>
            <div className="bg-muted rounded-lg px-4 py-2">
              <div className="flex gap-1">
                <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce" />
                <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce [animation-delay:0.1s]" />
                <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce [animation-delay:0.2s]" />
              </div>
            </div>
          </div>
        )}
      </div>
    </ScrollArea>
  )
}
