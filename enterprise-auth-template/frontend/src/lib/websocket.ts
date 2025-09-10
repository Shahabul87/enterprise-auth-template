/**
 * WebSocket client utility
 * Provides reliable WebSocket connections with auto-reconnection, message queuing, and type safety
 * Supports multiple connection types, authentication, and message multiplexing
 */

import { ErrorHandler } from '@/lib/error-handler';
import { useAuthStore } from '@/stores/auth.store';

// WebSocket types
export interface WebSocketMessage<T = unknown> {
  id?: string;
  type: string;
  data: T;
  timestamp?: number;
  userId?: string;
  channel?: string;
}

export interface WebSocketResponse<T = unknown> extends WebSocketMessage<T> {
  success: boolean;
  error?: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
  requestId?: string;
}

export interface WebSocketSubscription {
  id: string;
  channel: string;
  callback: (message: WebSocketMessage) => void;
  options?: {
    filter?: (message: WebSocketMessage) => boolean;
    transform?: (message: WebSocketMessage) => WebSocketMessage;
  };
}

export interface WebSocketStats {
  connected: boolean;
  connectionTime?: number;
  disconnectedAt?: number;
  reconnectAttempts: number;
  totalReconnects: number;
  messagesReceived: number;
  messagesSent: number;
  queuedMessages: number;
  lastHeartbeat?: number;
  latency?: number;
}

export interface ConnectionState {
  status: 'disconnected' | 'connecting' | 'connected' | 'reconnecting' | 'error';
  url: string;
  protocols?: string[];
  readyState: number;
  lastError?: string;
  connectedAt?: number;
  disconnectedAt?: number;
}

// Configuration interfaces
export interface WebSocketConfig {
  url: string;
  protocols?: string[];
  authentication?: {
    enabled: boolean;
    tokenLocation: 'header' | 'query' | 'message';
    tokenKey?: string;
    refreshToken?: boolean;
  };
  reconnection?: {
    enabled: boolean;
    maxAttempts: number;
    initialDelay: number;
    maxDelay: number;
    backoffFactor: number;
    jitter?: boolean;
  };
  heartbeat?: {
    enabled: boolean;
    interval: number;
    timeout: number;
    message?: WebSocketMessage;
  };
  messageQueue?: {
    enabled: boolean;
    maxSize: number;
    persistToDisk?: boolean;
    flushOnReconnect?: boolean;
  };
  channels?: {
    enabled: boolean;
    defaultChannel?: string;
    autoSubscribe?: string[];
  };
  compression?: {
    enabled: boolean;
    threshold: number;
  };
  debug?: boolean;
  enableMetrics?: boolean;
}

/**
 * WebSocket client manager class
 * Handles connections, reconnection, message queuing, and subscriptions
 */
class WebSocketClient {
  private config: WebSocketConfig;
  private socket: WebSocket | null = null;
  private connectionState: ConnectionState;
  private subscriptions = new Map<string, WebSocketSubscription>();
  private messageQueue: WebSocketMessage[] = [];
  private pendingMessages = new Map<string, { resolve: (response: WebSocketResponse) => void; reject: (error: Error) => void; timeout: NodeJS.Timeout }>();
  private reconnectTimeout: NodeJS.Timeout | null = null;
  private heartbeatInterval: NodeJS.Timeout | null = null;
  private heartbeatTimeout: NodeJS.Timeout | null = null;
  private stats: WebSocketStats;
  private listeners: {
    onOpen: ((event: Event) => void)[];
    onClose: ((event: CloseEvent) => void)[];
    onError: ((event: Event) => void)[];
    onMessage: ((message: WebSocketMessage) => void)[];
    onStateChange: ((state: ConnectionState) => void)[];
  };
  private debug = false;
  private reconnectAttempts = 0;

  constructor(config: WebSocketConfig) {
    this.config = {
      protocols: [],
      authentication: {
        enabled: true,
        tokenLocation: 'header',
        tokenKey: 'Authorization',
        refreshToken: true,
      },
      reconnection: {
        enabled: true,
        maxAttempts: 10,
        initialDelay: 1000,
        maxDelay: 30000,
        backoffFactor: 1.5,
        jitter: true,
      },
      heartbeat: {
        enabled: true,
        interval: 30000, // 30 seconds
        timeout: 10000, // 10 seconds
        message: { type: 'ping', data: {} },
      },
      messageQueue: {
        enabled: true,
        maxSize: 100,
        persistToDisk: false,
        flushOnReconnect: true,
      },
      channels: {
        enabled: true,
        defaultChannel: 'general',
        autoSubscribe: [],
      },
      compression: {
        enabled: false,
        threshold: 1024,
      },
      debug: process.env['NODE_ENV'] === 'development',
      enableMetrics: true,
      ...config,
    };

    this.connectionState = {
      status: 'disconnected',
      url: this.config.url,
      ...(this.config.protocols ? { protocols: this.config.protocols } : {}),
      readyState: WebSocket.CLOSED,
    };

    this.stats = {
      connected: false,
      reconnectAttempts: 0,
      totalReconnects: 0,
      messagesReceived: 0,
      messagesSent: 0,
      queuedMessages: 0,
    };

    this.listeners = {
      onOpen: [],
      onClose: [],
      onError: [],
      onMessage: [],
      onStateChange: [],
    };

    this.debug = this.config.debug || false;
  }

  /**
   * Connect to WebSocket server
   */
  public async connect(): Promise<void> {
    try {
      if (this.isConnected()) {
        this.log('Already connected');
        return;
      }

      this.updateConnectionState({ status: 'connecting' });
      this.log('Connecting to WebSocket:', this.config.url);

      // Build connection URL with authentication if needed
      const url = await this.buildConnectionUrl();

      // Create WebSocket connection
      this.socket = new WebSocket(url, this.config.protocols);

      // Set up event handlers
      this.setupEventHandlers();

      // Wait for connection to open
      await this.waitForConnection();

      // Start heartbeat if enabled
      if (this.config.heartbeat?.enabled) {
        this.startHeartbeat();
      }

      // Auto-subscribe to channels
      if (this.config.channels?.autoSubscribe) {
        for (const channel of this.config.channels.autoSubscribe) {
          await this.subscribe(channel, () => {});
        }
      }

      // Flush queued messages
      if (this.config.messageQueue?.flushOnReconnect) {
        await this.flushMessageQueue();
      }

      this.stats.connected = true;
      this.stats.connectionTime = Date.now();
      this.reconnectAttempts = 0;

      this.log('WebSocket connected successfully');
    } catch (error) {
      this.handleConnectionError(error);
      throw error;
    }
  }

  /**
   * Disconnect from WebSocket server
   */
  public disconnect(code = 1000, reason = 'Client disconnect'): void {
    try {
      this.log('Disconnecting WebSocket');

      this.updateConnectionState({ status: 'disconnected' });

      // Clear timeouts
      this.clearTimeouts();

      // Close socket
      if (this.socket && this.socket.readyState === WebSocket.OPEN) {
        this.socket.close(code, reason);
      }

      this.socket = null;
      this.stats.connected = false;
      this.stats.disconnectedAt = Date.now();
    } catch (error) {
      // WebSocket disconnect error occurred
    }
  }

  /**
   * Send message to WebSocket server
   */
  public async send<T = unknown>(
    message: WebSocketMessage<T>,
    options: {
      timeout?: number;
      expectResponse?: boolean;
      retries?: number;
    } = {}
  ): Promise<WebSocketResponse | void> {
    try {
      const { timeout = 10000, expectResponse = false, retries: _unusedRetries = 3 } = options;

      // Generate message ID for tracking
      const messageId = message.id || this.generateMessageId();
      const currentUserId = this.getCurrentUserId();
      const enrichedMessage: WebSocketMessage<T> = {
        type: message.type,
        data: message.data,
        id: messageId,
        timestamp: Date.now(),
        ...(currentUserId ? { userId: currentUserId } : {}),
        ...(message.channel !== undefined ? { channel: message.channel } : {}),
      };

      // Queue message if not connected
      if (!this.isConnected()) {
        if (this.config.messageQueue?.enabled) {
          return this.queueMessage(enrichedMessage, options);
        } else {
          throw new Error('WebSocket not connected and message queuing is disabled');
        }
      }

      // Send message
      const serialized = await this.serializeMessage(enrichedMessage);
      this.socket!.send(serialized);

      this.stats.messagesSent++;
      this.log('Sent message:', enrichedMessage.type, enrichedMessage.id);

      // Handle response expectation
      if (expectResponse) {
        return this.waitForResponse(messageId, timeout);
      }
    } catch (error) {
      

      // Retry if configured
      if (options.retries && options.retries > 0) {
        this.log(`Retrying message send (${options.retries} attempts left)`);
        return this.send(message, { ...options, retries: options.retries - 1 });
      }

      throw error;
    }
  }

  /**
   * Subscribe to a channel or message type
   */
  public subscribe(
    channel: string,
    callback: (message: WebSocketMessage) => void,
    options?: WebSocketSubscription['options']
  ): string {
    const subscriptionId = this.generateSubscriptionId();

    const subscription: WebSocketSubscription = {
      id: subscriptionId,
      channel,
      callback,
      ...(options ? { options } : {}),
    };

    this.subscriptions.set(subscriptionId, subscription);

    // Send subscription message if channels are enabled
    if (this.config.channels?.enabled) {
      this.send({
        type: 'subscribe',
        data: { channel },
      }).catch(() => {
        
      });
    }

    this.log('Subscribed to channel:', channel, 'ID:', subscriptionId);
    return subscriptionId;
  }

  /**
   * Unsubscribe from a channel
   */
  public unsubscribe(subscriptionId: string): boolean {
    const subscription = this.subscriptions.get(subscriptionId);
    if (!subscription) {
      this.log('Subscription not found:', subscriptionId);
      return false;
    }

    this.subscriptions.delete(subscriptionId);

    // Send unsubscription message if channels are enabled
    if (this.config.channels?.enabled) {
      this.send({
        type: 'unsubscribe',
        data: { channel: subscription.channel },
      }).catch(() => {
        
      });
    }

    this.log('Unsubscribed from channel:', subscription.channel, 'ID:', subscriptionId);
    return true;
  }

  /**
   * Check if WebSocket is connected
   */
  public isConnected(): boolean {
    return this.socket?.readyState === WebSocket.OPEN;
  }

  /**
   * Get connection state
   */
  public getConnectionState(): ConnectionState {
    return { ...this.connectionState };
  }

  /**
   * Get connection statistics
   */
  public getStats(): WebSocketStats {
    const latency = this.calculateLatency();
    return {
      connected: this.stats.connected,
      reconnectAttempts: this.stats.reconnectAttempts,
      totalReconnects: this.stats.totalReconnects,
      messagesReceived: this.stats.messagesReceived,
      messagesSent: this.stats.messagesSent,
      queuedMessages: this.messageQueue.length,
      ...(latency !== undefined ? { latency } : {}),
      ...(this.stats.connectionTime !== undefined ? { connectionTime: this.stats.connectionTime } : {}),
      ...(this.stats.disconnectedAt !== undefined ? { disconnectedAt: this.stats.disconnectedAt } : {}),
      ...(this.stats.lastHeartbeat !== undefined ? { lastHeartbeat: this.stats.lastHeartbeat } : {}),
    };
  }

  /**
   * Add event listeners
   */
  public on<K extends keyof WebSocketClient['listeners']>(
    event: K,
    callback: WebSocketClient['listeners'][K][0]
  ): () => void {
    // Type assertion for different event types
    (this.listeners[event] as unknown[]).push(callback);

    // Return unsubscribe function
    return () => {
      const index = (this.listeners[event] as unknown[]).indexOf(callback);
      if (index > -1) {
        this.listeners[event].splice(index, 1);
      }
    };
  }

  /**
   * Build connection URL with authentication
   */
  private async buildConnectionUrl(): Promise<string> {
    let url = this.config.url;

    if (this.config.authentication?.enabled) {
      const token = await this.getAuthToken();
      
      if (token && this.config.authentication.tokenLocation === 'query') {
        const separator = url.includes('?') ? '&' : '?';
        const tokenKey = this.config.authentication.tokenKey || 'token';
        url += `${separator}${tokenKey}=${encodeURIComponent(token)}`;
      }
    }

    return url;
  }

  /**
   * Get authentication token
   */
  private async getAuthToken(): Promise<string | null> {
    try {
      const { accessToken, isTokenValid, refreshAccessToken } = useAuthStore.getState();

      if (!accessToken) {
        return null;
      }

      // Check if token is valid
      if (!isTokenValid() && this.config.authentication?.refreshToken) {
        this.log('Token expired, attempting refresh');
        await refreshAccessToken();
        return useAuthStore.getState().accessToken;
      }

      return accessToken;
    } catch {
      
      return null;
    }
  }

  /**
   * Get current user ID
   */
  private getCurrentUserId(): string | undefined {
    return useAuthStore.getState().user?.id;
  }

  /**
   * Set up WebSocket event handlers
   */
  private setupEventHandlers(): void {
    if (!this.socket) return;

    this.socket.onopen = (event) => {
      this.updateConnectionState({ 
        status: 'connected', 
        connectedAt: Date.now(),
        readyState: WebSocket.OPEN,
      });

      this.log('WebSocket connection opened');
      this.listeners.onOpen.forEach(callback => callback(event));
    };

    this.socket.onclose = (event) => {
      this.updateConnectionState({ 
        status: 'disconnected', 
        disconnectedAt: Date.now(),
        readyState: WebSocket.CLOSED,
      });

      this.stats.connected = false;
      this.clearTimeouts();

      this.log('WebSocket connection closed:', event.code, event.reason);
      this.listeners.onClose.forEach(callback => callback(event));

      // Auto-reconnect if enabled and not a clean closure
      if (this.config.reconnection?.enabled && event.code !== 1000) {
        this.scheduleReconnect();
      }
    };

    this.socket.onerror = (event) => {
      this.updateConnectionState({ 
        status: 'error', 
        lastError: 'WebSocket error occurred',
        readyState: this.socket?.readyState || WebSocket.CLOSED,
      });

      
      this.listeners.onError.forEach(callback => callback(event));
    };

    this.socket.onmessage = async (event) => {
      try {
        const message = await this.deserializeMessage(event.data);
        this.stats.messagesReceived++;
        
        this.log('Received message:', message.type, message.id);
        
        // Handle heartbeat responses
        if (message.type === 'pong') {
          this.handleHeartbeatResponse(message);
          return;
        }

        // Handle pending response messages
        if (message.id && this.pendingMessages.has(message.id)) {
          this.handlePendingResponse(message.id, message as WebSocketResponse);
          return;
        }

        // Distribute message to subscribers
        this.distributeMessage(message);

        // Notify global message listeners
        this.listeners.onMessage.forEach(callback => callback(message));
      } catch {
        
      }
    };
  }

  /**
   * Wait for WebSocket connection to open
   */
  private waitForConnection(): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.socket) {
        reject(new Error('No WebSocket instance'));
        return;
      }

      if (this.socket.readyState === WebSocket.OPEN) {
        resolve();
        return;
      }

      const timeout = setTimeout(() => {
        reject(new Error('WebSocket connection timeout'));
      }, 10000);

      const onOpen = () => {
        clearTimeout(timeout);
        resolve();
      };

      const onError = (_unusedError: Event) => {
        clearTimeout(timeout);
        reject(new Error('WebSocket connection failed'));
      };

      this.socket.addEventListener('open', onOpen, { once: true });
      this.socket.addEventListener('error', onError, { once: true });
    });
  }

  /**
   * Start heartbeat mechanism
   */
  private startHeartbeat(): void {
    if (!this.config.heartbeat?.enabled) return;

    this.heartbeatInterval = setInterval(() => {
      if (this.isConnected()) {
        const heartbeatMessage = this.config.heartbeat!.message!;
        
        // Set up heartbeat timeout
        this.heartbeatTimeout = setTimeout(() => {
          this.log('Heartbeat timeout - connection may be dead');
          this.handleConnectionTimeout();
        }, this.config.heartbeat!.timeout!);

        this.send(heartbeatMessage).catch(() => {
          
        });

        this.stats.lastHeartbeat = Date.now();
      }
    }, this.config.heartbeat.interval);
  }

  /**
   * Handle heartbeat response
   */
  private handleHeartbeatResponse(message: WebSocketMessage): void {
    if (this.heartbeatTimeout) {
      clearTimeout(this.heartbeatTimeout);
      this.heartbeatTimeout = null;
    }

    // Calculate latency
    if (message.timestamp) {
      this.stats.latency = Date.now() - message.timestamp;
    }

    this.log('Heartbeat received, latency:', this.stats.latency, 'ms');
  }

  /**
   * Handle connection timeout
   */
  private handleConnectionTimeout(): void {
    this.log('Connection timeout detected, forcing reconnect');
    this.disconnect(1000, 'Connection timeout');
    
    if (this.config.reconnection?.enabled) {
      this.scheduleReconnect();
    }
  }

  /**
   * Schedule reconnection attempt
   */
  private scheduleReconnect(): void {
    if (!this.config.reconnection?.enabled) return;

    if (this.reconnectAttempts >= (this.config.reconnection.maxAttempts || 10)) {
      this.log('Max reconnection attempts reached');
      this.updateConnectionState({ status: 'error', lastError: 'Max reconnection attempts reached' });
      return;
    }

    this.reconnectAttempts++;
    this.stats.reconnectAttempts = this.reconnectAttempts;

    const delay = this.calculateReconnectDelay();
    this.log(`Scheduling reconnect attempt ${this.reconnectAttempts} in ${delay}ms`);

    this.updateConnectionState({ status: 'reconnecting' });

    this.reconnectTimeout = setTimeout(async () => {
      try {
        this.stats.totalReconnects++;
        await this.connect();
      } catch {
        
        this.scheduleReconnect(); // Try again
      }
    }, delay);
  }

  /**
   * Calculate reconnection delay with exponential backoff
   */
  private calculateReconnectDelay(): number {
    const { initialDelay = 1000, maxDelay = 30000, backoffFactor = 1.5, jitter = true } = this.config.reconnection || {};

    let delay = initialDelay * Math.pow(backoffFactor, this.reconnectAttempts - 1);
    delay = Math.min(delay, maxDelay);

    // Add jitter to prevent thundering herd
    if (jitter) {
      delay = delay * (0.5 + Math.random() * 0.5);
    }

    return Math.round(delay);
  }

  /**
   * Queue message for later sending
   */
  private queueMessage<T>(message: WebSocketMessage<T>, _unusedOptions: unknown): Promise<WebSocketResponse | void> {
    return new Promise((resolve, reject) => {
      if (this.messageQueue.length >= (this.config.messageQueue?.maxSize || 100)) {
        reject(new Error('Message queue is full'));
        return;
      }

      this.messageQueue.push(message);
      this.log('Message queued:', message.type, message.id);

      // For now, resolve immediately for queued messages
      // In a real implementation, you might want to resolve when the message is actually sent
      resolve();
    });
  }

  /**
   * Flush queued messages
   */
  private async flushMessageQueue(): Promise<void> {
    if (this.messageQueue.length === 0) return;

    this.log(`Flushing ${this.messageQueue.length} queued messages`);

    const messages = [...this.messageQueue];
    this.messageQueue = [];

    for (const message of messages) {
      try {
        await this.send(message);
      } catch (error) {
        
        // Re-queue failed message
        this.messageQueue.push(message);
      }
    }
  }

  /**
   * Wait for response to a specific message
   */
  private waitForResponse(messageId: string, timeout: number): Promise<WebSocketResponse> {
    return new Promise((resolve, reject) => {
      const timeoutHandle = setTimeout(() => {
        this.pendingMessages.delete(messageId);
        reject(new Error(`Message response timeout: ${messageId}`));
      }, timeout);

      this.pendingMessages.set(messageId, {
        resolve,
        reject,
        timeout: timeoutHandle,
      });
    });
  }

  /**
   * Handle pending message response
   */
  private handlePendingResponse(messageId: string, response: WebSocketResponse): void {
    const pending = this.pendingMessages.get(messageId);
    if (!pending) return;

    clearTimeout(pending.timeout);
    this.pendingMessages.delete(messageId);

    if (response.success) {
      pending.resolve(response);
    } else {
      pending.reject(new Error(response.error?.message || 'Unknown error'));
    }
  }

  /**
   * Distribute message to subscribers
   */
  private distributeMessage(message: WebSocketMessage): void {
    this.subscriptions.forEach((subscription) => {
      try {
        // Check if message matches subscription
        const matchesChannel = !this.config.channels?.enabled || 
          message.channel === subscription.channel ||
          subscription.channel === '*'; // Wildcard subscription

        if (!matchesChannel) return;

        // Apply filters if configured
        if (subscription.options?.filter && !subscription.options.filter(message)) {
          return;
        }

        // Apply transformations if configured
        let transformedMessage = message;
        if (subscription.options?.transform) {
          transformedMessage = subscription.options.transform(message);
        }

        // Call subscription callback
        subscription.callback(transformedMessage);
      } catch {
        
      }
    });
  }

  /**
   * Serialize message for transmission
   */
  private async serializeMessage(message: WebSocketMessage): Promise<string> {
    try {
      const serialized = JSON.stringify(message);

      // Apply compression if enabled and message is large enough
      if (this.config.compression?.enabled && serialized.length > (this.config.compression.threshold || 1024)) {
        // Compression would be implemented here
        this.log('Message compressed');
      }

      return serialized;
    } catch {
      
      throw new Error('Message serialization failed');
    }
  }

  /**
   * Deserialize received message
   */
  private async deserializeMessage(data: string | ArrayBuffer | Blob): Promise<WebSocketMessage> {
    try {
      let messageData: string;

      if (typeof data === 'string') {
        messageData = data;
      } else if (data instanceof ArrayBuffer) {
        messageData = new TextDecoder().decode(data);
      } else if (data instanceof Blob) {
        messageData = await data.text();
      } else {
        throw new Error('Unsupported message data type');
      }

      // Handle decompression if needed
      // Decompression logic would go here

      return JSON.parse(messageData);
    } catch {
      
      throw new Error('Message deserialization failed');
    }
  }

  /**
   * Calculate connection latency
   */
  private calculateLatency(): number | undefined {
    return this.stats.latency;
  }

  /**
   * Handle connection error
   */
  private handleConnectionError(error: unknown): void {
    const parsedError = ErrorHandler.parseError(error);
    this.updateConnectionState({ 
      status: 'error', 
      lastError: parsedError.message 
    });
    
  }

  /**
   * Update connection state and notify listeners
   */
  private updateConnectionState(updates: Partial<ConnectionState>): void {
    this.connectionState = { ...this.connectionState, ...updates };
    this.listeners.onStateChange.forEach(callback => callback(this.connectionState));
  }

  /**
   * Clear all timeouts
   */
  private clearTimeouts(): void {
    if (this.reconnectTimeout) {
      clearTimeout(this.reconnectTimeout);
      this.reconnectTimeout = null;
    }

    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
    }

    if (this.heartbeatTimeout) {
      clearTimeout(this.heartbeatTimeout);
      this.heartbeatTimeout = null;
    }

    // Clear pending message timeouts
    this.pendingMessages.forEach(({ timeout }) => {
      clearTimeout(timeout);
    });
    this.pendingMessages.clear();
  }

  /**
   * Generate unique message ID
   */
  private generateMessageId(): string {
    return `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Generate unique subscription ID
   */
  private generateSubscriptionId(): string {
    return `sub_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Debug logging
   */
  private log(..._unusedArgs: unknown[]): void {
    if (this.debug) {
      
    }
  }

  /**
   * Clean up resources
   */
  public cleanup(): void {
    this.disconnect();
    this.subscriptions.clear();
    this.messageQueue = [];
    this.clearTimeouts();
  }
}

/**
 * WebSocket manager singleton
 * Manages multiple WebSocket connections
 */
class WebSocketManager {
  private static instance: WebSocketManager;
  private connections = new Map<string, WebSocketClient>();
  private defaultConnection: string | null = null;

  private constructor() {}

  public static getInstance(): WebSocketManager {
    if (!WebSocketManager.instance) {
      WebSocketManager.instance = new WebSocketManager();
    }
    return WebSocketManager.instance;
  }

  /**
   * Create a new WebSocket connection
   */
  public createConnection(id: string, config: WebSocketConfig, setAsDefault = false): WebSocketClient {
    const client = new WebSocketClient(config);
    this.connections.set(id, client);

    if (setAsDefault || !this.defaultConnection) {
      this.defaultConnection = id;
    }

    return client;
  }

  /**
   * Get WebSocket connection by ID
   */
  public getConnection(id?: string): WebSocketClient | null {
    const connectionId = id || this.defaultConnection;
    if (!connectionId) return null;

    return this.connections.get(connectionId) || null;
  }

  /**
   * Remove WebSocket connection
   */
  public removeConnection(id: string): boolean {
    const connection = this.connections.get(id);
    if (!connection) return false;

    connection.cleanup();
    this.connections.delete(id);

    if (this.defaultConnection === id) {
      this.defaultConnection = this.connections.keys().next().value || null;
    }

    return true;
  }

  /**
   * Get all connection IDs
   */
  public getConnectionIds(): string[] {
    return Array.from(this.connections.keys());
  }

  /**
   * Clean up all connections
   */
  public cleanup(): void {
    this.connections.forEach((connection) => {
      connection.cleanup();
    });
    this.connections.clear();
    this.defaultConnection = null;
  }
}

// Create and export manager instance
const wsManager = WebSocketManager.getInstance();

// Convenience functions for default connection
export const createWebSocketConnection = (config: WebSocketConfig, id = 'default'): WebSocketClient => {
  return wsManager.createConnection(id, config, true);
};

export const getWebSocketConnection = (id?: string): WebSocketClient | null => {
  return wsManager.getConnection(id);
};

export const connectWebSocket = async (id?: string): Promise<void> => {
  const connection = wsManager.getConnection(id);
  if (!connection) {
    throw new Error('WebSocket connection not found');
  }
  return connection.connect();
};

export const disconnectWebSocket = (id?: string): void => {
  const connection = wsManager.getConnection(id);
  if (!connection) {
    throw new Error('WebSocket connection not found');
  }
  connection.disconnect();
};

export const sendWebSocketMessage = <T = unknown>(
  message: WebSocketMessage<T>,
  options?: Parameters<WebSocketClient['send']>[1],
  connectionId?: string
): Promise<WebSocketResponse | void> => {
  const connection = wsManager.getConnection(connectionId);
  if (!connection) {
    throw new Error('WebSocket connection not found');
  }
  return connection.send(message, options);
};

export const subscribeToChannel = (
  channel: string,
  callback: (message: WebSocketMessage) => void,
  options?: WebSocketSubscription['options'],
  connectionId?: string
): string => {
  const connection = wsManager.getConnection(connectionId);
  if (!connection) {
    throw new Error('WebSocket connection not found');
  }
  return connection.subscribe(channel, callback, options);
};

export const unsubscribeFromChannel = (subscriptionId: string, connectionId?: string): boolean => {
  const connection = wsManager.getConnection(connectionId);
  if (!connection) {
    throw new Error('WebSocket connection not found');
  }
  return connection.unsubscribe(subscriptionId);
};

// Export types and classes
export {
  WebSocketClient,
  WebSocketManager,
  wsManager as webSocketManager,
};

export default wsManager;