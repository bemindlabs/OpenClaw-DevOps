'use client'

import { useChat } from '@/hooks/use-chat'
import { MessageList } from '@/components/chat/message-list'
import { MessageInput, CommandSuggestions } from '@/components/chat/message-input'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Trash2, Send } from 'lucide-react'
import { useSocket } from '@/hooks/use-socket'

export default function ChatPage() {
  const { messages, sendMessage, isLoading, error, clearMessages, sessionId } = useChat()
  const { connected } = useSocket()

  return (
    <div className="h-[calc(100vh-8rem)]">
      <Card className="h-full flex flex-col">
        <CardHeader className="flex flex-row items-center justify-between py-4 border-b">
          <div>
            <CardTitle className="text-lg">Chat Interface</CardTitle>
            <CardDescription className="text-xs">
              Manage services via natural language commands
            </CardDescription>
          </div>
          <div className="flex items-center gap-2">
            <Badge variant={connected ? 'success' : 'destructive'} className="text-xs">
              {connected ? 'Connected' : 'Disconnected'}
            </Badge>
            <Button
              variant="ghost"
              size="sm"
              onClick={clearMessages}
              disabled={messages.length === 0}
            >
              <Trash2 className="h-4 w-4 mr-1" />
              Clear
            </Button>
          </div>
        </CardHeader>

        <CardContent className="flex-1 flex flex-col p-0 overflow-hidden">
          {/* Error banner */}
          {error && (
            <div className="bg-destructive/10 text-destructive px-4 py-2 text-sm">
              {error}
            </div>
          )}

          {/* Messages area */}
          <div className="flex-1 overflow-hidden">
            <MessageList messages={messages} isLoading={isLoading} />
          </div>

          {/* Command suggestions */}
          <CommandSuggestions onSelect={sendMessage} />

          {/* Input area */}
          <MessageInput
            onSend={sendMessage}
            disabled={isLoading}
            placeholder="Type a command (e.g., 'restart nginx', 'status', 'logs mongodb')..."
          />
        </CardContent>
      </Card>
    </div>
  )
}
