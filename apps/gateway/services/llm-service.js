/**
 * LLM Service
 * Multi-provider LLM integration with fallback support
 */

const OpenAI = require('openai');
const Anthropic = require('@anthropic-ai/sdk');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Global registry to track ALL instances ever created
global.LLMServiceInstances = global.LLMServiceInstances || [];

class LLMService {
  constructor() {
    // Unique instance ID for tracking
    this.instanceId = Date.now() + '-' + Math.random().toString(36).substr(2, 9);
    global.LLMServiceInstances.push(this.instanceId);

    process.stderr.write(`\n[LLM Service] Constructor called at: ${new Date().toISOString()}\n`);
    process.stderr.write(`[LLM Service] Instance ID: ${this.instanceId}\n`);
    process.stderr.write(`[LLM Service] Total instances created: ${global.LLMServiceInstances.length}\n`);
    process.stderr.write(`[LLM Service] All instance IDs: ${global.LLMServiceInstances.join(', ')}\n\n`);

    console.log('[LLM Service] OPENAI_API_KEY:', process.env.OPENAI_API_KEY ? `EXISTS (${process.env.OPENAI_API_KEY.substring(0,10)}...)` : 'MISSING');

    this.provider = process.env.LLM_PROVIDER || 'openai';
    this.fallbackProviders = (process.env.LLM_FALLBACK_PROVIDERS || 'anthropic,google').split(',');

    // Initialize clients
    this.clients = {};

    // OpenAI
    console.log('[LLM Service] Checking OPENAI_API_KEY...');
    if (process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== 'sk-CHANGE_ME_OPENAI_API_KEY_INSECURE_EXAMPLE') {
      try {
        console.log('[LLM Service] Creating OpenAI client');
        this.clients.openai = new OpenAI({
          apiKey: process.env.OPENAI_API_KEY,
        });
        console.log('[LLM Service] OpenAI client created successfully');
        console.log('[LLM Service] this.clients after OpenAI:', Object.keys(this.clients));
      } catch (error) {
        console.error('[LLM Service] ERROR creating OpenAI client:', error.message);
      }
    } else {
      console.log('[LLM Service] NOT creating OpenAI client - key missing or placeholder');
    }

    // Anthropic
    if (process.env.ANTHROPIC_API_KEY && process.env.ANTHROPIC_API_KEY !== 'sk-ant-CHANGE_ME_ANTHROPIC_KEY_INSECURE_EXAMPLE') {
      this.clients.anthropic = new Anthropic({
        apiKey: process.env.ANTHROPIC_API_KEY,
      });
    }

    // Google
    if (process.env.GOOGLE_AI_API_KEY && process.env.GOOGLE_AI_API_KEY !== 'CHANGE_ME_GOOGLE_AI_KEY_INSECURE_EXAMPLE') {
      this.clients.google = new GoogleGenerativeAI(process.env.GOOGLE_AI_API_KEY);
    }

    // Moonshot / Kimi (OpenAI-compatible)
    if (process.env.MOONSHOT_API_KEY && process.env.MOONSHOT_API_KEY !== 'CHANGE_ME_MOONSHOT_KEY_INSECURE_EXAMPLE') {
      this.clients.moonshot = new OpenAI({
        apiKey: process.env.MOONSHOT_API_KEY,
        baseURL: process.env.MOONSHOT_BASE_URL || 'https://api.moonshot.cn/v1',
      });
    }

    // Conversation history (in-memory for now)
    this.conversationHistory = new Map();

    console.log('✓ LLM Service initialized');
    console.log(`  Primary provider: ${this.provider}`);
    console.log(`  Available clients: ${Object.keys(this.clients).join(', ')}`);

    // FINAL VERIFICATION
    process.stderr.write(`[LLM Constructor END] this.clients keys: ${Object.keys(this.clients).join(', ')}\n`);
    process.stderr.write(`[LLM Constructor END] this.clients.openai exists: ${!!this.clients.openai}\n`);
  }

  /**
   * Get or create conversation history for a session
   */
  getHistory(sessionId) {
    if (!this.conversationHistory.has(sessionId)) {
      this.conversationHistory.set(sessionId, []);
    }
    return this.conversationHistory.get(sessionId);
  }

  /**
   * Add message to history
   */
  addToHistory(sessionId, role, content) {
    const history = this.getHistory(sessionId);
    history.push({ role, content, timestamp: new Date().toISOString() });

    // Keep last 20 messages
    if (history.length > 20) {
      history.shift();
    }
  }

  /**
   * Clear conversation history
   */
  clearHistory(sessionId) {
    this.conversationHistory.delete(sessionId);
  }

  /**
   * Chat with LLM (with fallback support)
   */
  async chat(message, sessionId = 'default', systemPrompt = null) {
    console.log('[LLM.chat] Method called. Provider:', this.provider, 'Clients:', Object.keys(this.clients));
    const providers = [this.provider, ...this.fallbackProviders];
    console.log('[LLM.chat] Will try providers:', providers);

    let lastError = null;

    for (const provider of providers) {
      try {
        console.log(`[LLM.chat] Attempting chat with provider: ${provider}`);
        const response = await this.chatWithProvider(provider, message, sessionId, systemPrompt);

        // Add to history
        this.addToHistory(sessionId, 'user', message);
        this.addToHistory(sessionId, 'assistant', response);

        return {
          success: true,
          response,
          provider,
          sessionId
        };
      } catch (error) {
        console.error(`Error with provider ${provider}:`, error.message);
        lastError = error;

        // Try next provider
        continue;
      }
    }

    // All providers failed
    throw new Error(`All LLM providers failed. Last error: ${lastError?.message || 'Unknown error'}`);
  }

  /**
   * Chat with specific provider
   */
  async chatWithProvider(provider, message, sessionId, systemPrompt) {
    switch (provider) {
      case 'openai':
        return await this.chatOpenAI(message, sessionId, systemPrompt);

      case 'anthropic':
        return await this.chatAnthropic(message, sessionId, systemPrompt);

      case 'google':
        return await this.chatGoogle(message, sessionId, systemPrompt);

      case 'moonshot':
        return await this.chatMoonshot(message, sessionId, systemPrompt);

      default:
        throw new Error(`Unknown provider: ${provider}`);
    }
  }

  /**
   * Chat with OpenAI
   */
  async chatOpenAI(message, sessionId, systemPrompt) {
    if (!this.clients.openai) {
      throw new Error('OpenAI client not initialized');
    }

    const history = this.getHistory(sessionId);
    const model = process.env.LLM_CHAT_MODEL || 'gpt-4o-mini';

    const messages = [
      {
        role: 'system',
        content: systemPrompt || this.getDefaultSystemPrompt()
      },
      ...history.map(h => ({ role: h.role, content: h.content })),
      { role: 'user', content: message }
    ];

    const completion = await this.clients.openai.chat.completions.create({
      model: model.replace('openai/', ''),
      messages,
      temperature: parseFloat(process.env.LLM_TEMPERATURE) || 0.7,
      max_tokens: parseInt(process.env.LLM_MAX_TOKENS) || 2048,
    });

    return completion.choices[0].message.content;
  }

  /**
   * Chat with Anthropic
   */
  async chatAnthropic(message, sessionId, systemPrompt) {
    if (!this.clients.anthropic) {
      throw new Error('Anthropic client not initialized');
    }

    const history = this.getHistory(sessionId);
    const model = process.env.LLM_COMPLETION_MODEL || 'claude-3-5-sonnet-20241022';

    const messages = [
      ...history.map(h => ({ role: h.role, content: h.content })),
      { role: 'user', content: message }
    ];

    const response = await this.clients.anthropic.messages.create({
      model: model.replace('anthropic/', ''),
      max_tokens: parseInt(process.env.LLM_MAX_TOKENS) || 2048,
      system: systemPrompt || this.getDefaultSystemPrompt(),
      messages,
    });

    return response.content[0].text;
  }

  /**
   * Chat with Google
   */
  async chatGoogle(message, sessionId, systemPrompt) {
    if (!this.clients.google) {
      throw new Error('Google client not initialized');
    }

    const history = this.getHistory(sessionId);
    const modelName = process.env.AI_MODEL_PRIMARY || 'gemini-flash-latest';

    const model = this.clients.google.getGenerativeModel({
      model: modelName.replace('google/', '')
    });

    // Build chat context
    const chat = model.startChat({
      history: history.map(h => ({
        role: h.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: h.content }]
      })),
      generationConfig: {
        temperature: parseFloat(process.env.LLM_TEMPERATURE) || 0.7,
        maxOutputTokens: parseInt(process.env.LLM_MAX_TOKENS) || 2048,
      },
    });

    const result = await chat.sendMessage(message);
    const response = await result.response;
    return response.text();
  }

  /**
   * Chat with Moonshot / Kimi (OpenAI-compatible API)
   */
  async chatMoonshot(message, sessionId, systemPrompt) {
    if (!this.clients.moonshot) {
      throw new Error('Moonshot client not initialized');
    }

    const history = this.getHistory(sessionId);
    const model = 'moonshot-v1-8k'; // Default Moonshot model

    const messages = [
      {
        role: 'system',
        content: systemPrompt || this.getDefaultSystemPrompt()
      },
      ...history.map(h => ({ role: h.role, content: h.content })),
      { role: 'user', content: message }
    ];

    const completion = await this.clients.moonshot.chat.completions.create({
      model,
      messages,
      temperature: parseFloat(process.env.LLM_TEMPERATURE) || 0.7,
      max_tokens: parseInt(process.env.LLM_MAX_TOKENS) || 2048,
    });

    return completion.choices[0].message.content;
  }

  /**
   * Get default system prompt for OpenClaw
   */
  getDefaultSystemPrompt() {
    return `You are OpenClaw Assistant, a helpful AI assistant for the OpenClaw DevOps platform.

You help users manage their Docker services, troubleshoot issues, and provide guidance on using the platform.

Current capabilities:
- Answer questions about OpenClaw platform
- Provide Docker and DevOps guidance
- Help troubleshoot issues
- Explain service architecture

Be concise, helpful, and technical. If you're unsure about something, say so.`;
  }

  /**
   * Get service status
   */
  getStatus() {
    // Force re-check of clients to ensure they're actually there
    const availableClients = [];

    if (this.clients.openai) availableClients.push('openai');
    if (this.clients.anthropic) availableClients.push('anthropic');
    if (this.clients.google) availableClients.push('google');
    if (this.clients.moonshot) availableClients.push('moonshot');

    return {
      instanceId: this.instanceId,
      provider: this.provider,
      availableProviders: availableClients,
      _clientsObjectKeys: Object.keys(this.clients),  // For debugging
      _hasOpenAI: !!this.clients.openai,
      fallbackProviders: this.fallbackProviders,
      activeConversations: this.conversationHistory.size
    };
  }
}

// Singleton instance
let llmService = null;

function getLLMService() {
  if (!llmService) {
    console.log('[getLLMService] Creating NEW singleton instance');
    llmService = new LLMService();
  } else {
    console.log('[getLLMService] Returning EXISTING singleton instance');
  }
  return llmService;
}

console.log('[llm-service.js] Module loading');
console.log('[llm-service.js] __filename:', __filename);
console.log('[llm-service.js] module.id:', module.id);

// Create and export the singleton instance
const instance = getLLMService();
console.log('[llm-service.js] Exporting instance ID:', instance.instanceId);

module.exports = instance;
