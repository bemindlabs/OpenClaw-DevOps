'use client'

import { useState, useRef, KeyboardEvent } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Send, Loader2 } from 'lucide-react'

interface MessageInputProps {
  onSend: (message: string) => void
  disabled?: boolean
  placeholder?: string
}

export function MessageInput({
  onSend,
  disabled = false,
  placeholder = 'Type a command or message...',
}: MessageInputProps) {
  const [message, setMessage] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)

  const handleSend = () => {
    if (message.trim() && !disabled) {
      onSend(message.trim())
      setMessage('')
      inputRef.current?.focus()
    }
  }

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  return (
    <div className="flex gap-2 p-4 border-t bg-background">
      <Input
        ref={inputRef}
        value={message}
        onChange={(e) => setMessage(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
        disabled={disabled}
        className="flex-1"
      />
      <Button
        onClick={handleSend}
        disabled={disabled || !message.trim()}
        size="icon"
      >
        {disabled ? (
          <Loader2 className="h-4 w-4 animate-spin" />
        ) : (
          <Send className="h-4 w-4" />
        )}
      </Button>
    </div>
  )
}

// Command suggestions component
interface CommandSuggestionsProps {
  onSelect: (command: string) => void
}

export function CommandSuggestions({ onSelect }: CommandSuggestionsProps) {
  const suggestions = [
    { label: 'Status', command: 'status', description: 'Check all services' },
    { label: 'Restart nginx', command: 'restart nginx', description: 'Restart Nginx proxy' },
    { label: 'Logs mongodb', command: 'logs mongodb', description: 'View MongoDB logs' },
    { label: 'Help', command: 'help', description: 'Show available commands' },
  ]

  return (
    <div className="flex flex-wrap gap-2 px-4 py-2 border-t bg-slate-50 dark:bg-slate-900">
      <span className="text-xs text-muted-foreground self-center">Quick commands:</span>
      {suggestions.map((suggestion) => (
        <Button
          key={suggestion.command}
          variant="outline"
          size="sm"
          className="text-xs h-7"
          onClick={() => onSelect(suggestion.command)}
        >
          {suggestion.label}
        </Button>
      ))}
    </div>
  )
}
