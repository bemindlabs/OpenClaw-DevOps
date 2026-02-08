'use client'

import { useChat } from '@/hooks/use-chat'
import { MessageList } from '@/components/chat/message-list'
import { MessageInput, CommandSuggestions } from '@/components/chat/message-input'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Trash2, Send, Bot, Terminal } from 'lucide-react'
import { useSocket } from '@/hooks/use-socket'

export default function ChatPage() {
  const { messages, sendMessage, isLoading, error, clearMessages, sessionId, mode, setMode } = useChat()
  const { connected } = useSocket()

  return (
    <div className="h-[calc(100vh-8rem)]">
      <Card className="h-full flex flex-col">
        <CardHeader className="flex flex-row items-center justify-between py-4 border-b">
          <div>
            <CardTitle className="text-lg">Chat Interface</CardTitle>
            <CardDescription className="text-xs">
              {mode === 'command'
                ? 'Manage services via natural language commands'
                : 'Chat with AI assistant powered by LLM'}
            </CardDescription>
          </div>
          <div className="flex items-center gap-2">
            {/* Mode Toggle */}
            <div className="flex items-center gap-1 bg-muted rounded-md p-0.5">
              <Button
                variant={mode === 'command' ? 'default' : 'ghost'}
                size="sm"
                onClick={() => setMode('command')}
                className="h-7 px-2"
              >
                <Terminal className="h-3.5 w-3.5 mr-1" />
                <span className="text-xs">Command</span>
              </Button>
              <Button
                variant={mode === 'assistant' ? 'default' : 'ghost'}
                size="sm"
                onClick={() => setMode('assistant')}
                className="h-7 px-2"
              >
                <Bot className="h-3.5 w-3.5 mr-1" />
                <span className="text-xs">Assistant</span>
              </Button>
            </div>

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

          {/* Command suggestions (only in command mode) */}
          {mode === 'command' && <CommandSuggestions onSelect={sendMessage} />}

          {/* Input area */}
          <MessageInput
            onSend={sendMessage}
            disabled={isLoading}
            placeholder={
              mode === 'command'
                ? "Type a command (e.g., 'restart nginx', 'status', 'logs mongodb')..."
                : "Ask me anything about OpenClaw or DevOps..."
            }
          />
        </CardContent>
      </Card>
    </div>
  )
}
