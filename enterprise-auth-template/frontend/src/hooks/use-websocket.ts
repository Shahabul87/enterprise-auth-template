'use client';

import { useState, useEffect, useRef, useCallback, useMemo } from 'react';

/**
 * WebSocket connection hook with comprehensive connection management
 * 
 * Provides a robust WebSocket client with:
 * - Automatic reconnection with exponential backoff
 * - Connection state management
 * - Message queuing for offline scenarios
 * - Event-based message handling
 * - Heartbeat/ping-pong support
 * - Protocol support (subprotocols)
 * - Binary and text message support
 * - Connection metrics and monitoring
 * 
 * @example
 * ```typescript
 * // Basic usage
 * const {
 *   connectionState,
 *   send,
 *   lastMessage,
 *   isConnected,
 * } = useWebSocket('ws://localhost:8080/ws', {
 *   onMessage: (event) => {
 *     
 *   },
 *   shouldReconnect: () => true,
 *   reconnectAttempts: 5,
 * });
 * 
 * // With authentication
 * const ws = useWebSocket('ws://localhost:8080/ws', {
 *   protocols: ['bearer', authToken],
 *   onOpen: () => {
 *     send(JSON.stringify({ type: 'auth', token: authToken }));
 *   }
 * });
 * 
 * // Event-based messaging
 * const ws = useWebSocket('ws://localhost:8080/ws');
 * 
 * useEffect(() => {
 *   return ws.subscribe('user_update', (data) => {
 *     
 *   });
 * }, []);
 * ```
 */

export type ConnectionState = 'Connecting' | 'Open' | 'Closing' | 'Closed' | 'Uninstantiated';

export type WebSocketMessage = string | ArrayBuffer | Blob | ArrayBufferView;

export interface WebSocketConfig {
  /** WebSocket protocols */
  protocols?: string | string[];
  /** Whether to automatically connect on mount */
  shouldConnect?: boolean;
  /** Whether to reconnect on connection loss */
  shouldReconnect?: (closeEvent?: CloseEvent) => boolean;
  /** Maximum number of reconnection attempts */
  reconnectAttempts?: number;
  /** Initial reconnection delay (ms) */
  reconnectInterval?: number;
  /** Maximum reconnection delay (ms) */
  maxReconnectInterval?: number;
  /** Exponential backoff multiplier */
  reconnectBackoffMultiplier?: number;
  /** Connection timeout (ms) */
  connectionTimeout?: number;
  /** Heartbeat interval (ms) - set to 0 to disable */
  heartbeatInterval?: number;
  /** Heartbeat message */
  heartbeatMessage?: WebSocketMessage;
  /** Maximum message queue size for offline scenarios */
  maxMessageQueueSize?: number;
  /** Whether to queue messages when disconnected */
  queueMessagesWhenDisconnected?: boolean;
  /** Message parsing function */
  messageParser?: (event: MessageEvent) => unknown;
  /** Event listeners */
  onOpen?: (event: Event, socket: WebSocket) => void;
  onMessage?: (event: MessageEvent, socket: WebSocket) => void;
  onError?: (event: Event, socket: WebSocket) => void;
  onClose?: (event: CloseEvent, socket: WebSocket) => void;
  onReconnect?: (attempt: number, event: Event) => void;
  onReconnectStop?: (attempt: number) => void;
}

export interface ConnectionMetrics {
  /** Total connection attempts */
  totalConnections: number;
  /** Total reconnection attempts */
  totalReconnections: number;
  /** Total messages sent */
  messagesSent: number;
  /** Total messages received */
  messagesReceived: number;
  /** Last connection timestamp */
  lastConnected: Date | null;
  /** Last disconnection timestamp */
  lastDisconnected: Date | null;
  /** Current uptime (ms) */
  uptime: number;
  /** Average message frequency (messages per second) */
  averageMessageFrequency: number;
}

export interface WebSocketState {
  /** Current connection state */
  connectionState: ConnectionState;
  /** Whether WebSocket is connected */
  isConnected: boolean;
  /** Whether WebSocket is connecting */
  isConnecting: boolean;
  /** Last received message */
  lastMessage: MessageEvent | null;
  /** Last parsed message data */
  lastMessageData: unknown;
  /** Connection error */
  error: Event | null;
  /** Current reconnection attempt */
  reconnectCount: number;
  /** Whether currently reconnecting */
  isReconnecting: boolean;
  /** Connection metrics */
  metrics: ConnectionMetrics;
  /** Number of queued messages */
  queuedMessageCount: number;
}

export interface WebSocketActions {
  /** Send a message */
  send: (message: WebSocketMessage) => boolean;
  /** Send a JSON message */
  sendJson: (data: unknown) => boolean;
  /** Connect to WebSocket */
  connect: () => void;
  /** Disconnect from WebSocket */
  disconnect: (code?: number, reason?: string) => void;
  /** Subscribe to specific message types */
  subscribe: (event: string, handler: (data: unknown) => void) => () => void;
  /** Unsubscribe from message types */
  unsubscribe: (event: string, handler?: (data: unknown) => void) => void;
  /** Clear message queue */
  clearMessageQueue: () => void;
  /** Get WebSocket ready state */
  getReadyState: () => number;
  /** Reset connection metrics */
  resetMetrics: () => void;
}

export interface UseWebSocketReturn extends WebSocketState, WebSocketActions {}

export function useWebSocket(
  url: string | null,
  config: WebSocketConfig = {}
): UseWebSocketReturn {
  const {
    protocols,
    shouldConnect = true,
    shouldReconnect = () => true,
    reconnectAttempts = 3,
    reconnectInterval = 1000,
    maxReconnectInterval = 30000,
    reconnectBackoffMultiplier = 1.5,
    connectionTimeout = 10000,
    heartbeatInterval = 30000,
    heartbeatMessage = 'ping',
    maxMessageQueueSize = 100,
    queueMessagesWhenDisconnected = true,
    messageParser,
    onOpen,
    onMessage,
    onError,
    onClose,
    onReconnect,
    onReconnectStop,
  } = config;

  const [connectionState, setConnectionState] = useState<ConnectionState>('Uninstantiated');
  const [lastMessage, setLastMessage] = useState<MessageEvent | null>(null);
  const [lastMessageData, setLastMessageData] = useState<unknown>(null);
  const [error, setError] = useState<Event | null>(null);
  const [reconnectCount, setReconnectCount] = useState<number>(0);
  const [isReconnecting, setIsReconnecting] = useState<boolean>(false);
  const [metrics, setMetrics] = useState<ConnectionMetrics>({
    totalConnections: 0,
    totalReconnections: 0,
    messagesSent: 0,
    messagesReceived: 0,
    lastConnected: null,
    lastDisconnected: null,
    uptime: 0,
    averageMessageFrequency: 0,
  });

  const webSocketRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>();
  const connectionTimeoutRef = useRef<NodeJS.Timeout>();
  const heartbeatIntervalRef = useRef<NodeJS.Timeout>();
  const messageQueueRef = useRef<WebSocketMessage[]>([]);
  const subscribersRef = useRef<Map<string, Set<(data: unknown) => void>>>(new Map());
  const metricsStartTimeRef = useRef<number>(Date.now());
  const lastHeartbeatRef = useRef<number>(Date.now());

  // Computed states
  const isConnected = connectionState === 'Open';
  const isConnecting = connectionState === 'Connecting';
  const queuedMessageCount = messageQueueRef.current.length;

  // Update uptime
  useEffect(() => {
    if (!isConnected) return;

    const interval = setInterval(() => {
      setMetrics(prev => ({
        ...prev,
        uptime: Date.now() - (prev.lastConnected?.getTime() || Date.now()),
      }));
    }, 1000);

    return () => clearInterval(interval);
  }, [isConnected]);

  // Connection function
  const connect = useCallback(() => {
    if (!url) return;
    
    if (webSocketRef.current?.readyState === WebSocket.OPEN) {
      return;
    }

    try {
      setConnectionState('Connecting');
      setError(null);
      
      const socket = new WebSocket(url, protocols);
      webSocketRef.current = socket;

      // Connection timeout
      if (connectionTimeout > 0) {
        connectionTimeoutRef.current = setTimeout(() => {
          if (socket.readyState === WebSocket.CONNECTING) {
            socket.close();
            setError(new Event('Connection timeout'));
          }
        }, connectionTimeout);
      }

      socket.onopen = (event: Event) => {
        if (connectionTimeoutRef.current) {
          clearTimeout(connectionTimeoutRef.current);
        }

        setConnectionState('Open');
        setError(null);
        setReconnectCount(0);
        setIsReconnecting(false);
        
        const now = new Date();
        setMetrics(prev => ({
          ...prev,
          totalConnections: prev.totalConnections + 1,
          lastConnected: now,
          uptime: 0,
        }));
        metricsStartTimeRef.current = Date.now();
        lastHeartbeatRef.current = Date.now();

        // Send queued messages
        if (messageQueueRef.current.length > 0) {
          messageQueueRef.current.forEach(message => {
            socket.send(message);
          });
          messageQueueRef.current = [];
        }

        // Start heartbeat
        if (heartbeatInterval > 0) {
          heartbeatIntervalRef.current = setInterval(() => {
            if (socket.readyState === WebSocket.OPEN) {
              socket.send(heartbeatMessage);
              lastHeartbeatRef.current = Date.now();
            }
          }, heartbeatInterval);
        }

        if (onOpen) {
          onOpen(event, socket);
        }
      };

      socket.onmessage = (event: MessageEvent) => {
        setLastMessage(event);
        
        let parsedData: unknown = event.data;
        if (messageParser) {
          try {
            parsedData = messageParser(event);
          } catch {
            // Message parser error occurred
          }
        } else if (typeof event.data === 'string') {
          try {
            parsedData = JSON.parse(event.data);
          } catch {
            // Keep original data if JSON parsing fails
            parsedData = event.data;
          }
        }
        
        setLastMessageData(parsedData);
        
        setMetrics(prev => ({
          ...prev,
          messagesReceived: prev.messagesReceived + 1,
          averageMessageFrequency: prev.messagesReceived / ((Date.now() - metricsStartTimeRef.current) / 1000),
        }));

        // Handle event-based messages
        if (typeof parsedData === 'object' && parsedData && 'type' in parsedData) {
          const eventType = (parsedData as { type: string }).type;
          const subscribers = subscribersRef.current.get(eventType);
          if (subscribers) {
            subscribers.forEach(handler => {
              try {
                handler(parsedData);
              } catch {
                // Message handler error occurred
              }
            });
          }
        }

        if (onMessage) {
          onMessage(event, socket);
        }
      };

      socket.onerror = (event: Event) => {
        setError(event);
        
        if (onError) {
          onError(event, socket);
        }
      };

      socket.onclose = (event: CloseEvent) => {
        if (connectionTimeoutRef.current) {
          clearTimeout(connectionTimeoutRef.current);
        }
        if (heartbeatIntervalRef.current) {
          clearInterval(heartbeatIntervalRef.current);
        }

        setConnectionState('Closed');
        setMetrics(prev => ({
          ...prev,
          lastDisconnected: new Date(),
        }));

        const shouldAttemptReconnect = shouldReconnect(event) && reconnectCount < reconnectAttempts;
        
        if (shouldAttemptReconnect && !event.wasClean) {
          setIsReconnecting(true);
          setReconnectCount(prev => prev + 1);
          
          const delay = Math.min(
            reconnectInterval * Math.pow(reconnectBackoffMultiplier, reconnectCount),
            maxReconnectInterval
          );

          reconnectTimeoutRef.current = setTimeout(() => {
            setMetrics(prev => ({
              ...prev,
              totalReconnections: prev.totalReconnections + 1,
            }));
            
            if (onReconnect) {
              onReconnect(reconnectCount + 1, event);
            }
            
            connect();
          }, delay);
        } else {
          setIsReconnecting(false);
          if (onReconnectStop) {
            onReconnectStop(reconnectCount);
          }
        }

        if (onClose) {
          onClose(event, socket);
        }
      };

    } catch (err) {
      setConnectionState('Closed');
      setError(err as Event);
    }
  }, [
    url,
    protocols,
    connectionTimeout,
    heartbeatInterval,
    heartbeatMessage,
    shouldReconnect,
    reconnectAttempts,
    reconnectCount,
    reconnectInterval,
    maxReconnectInterval,
    reconnectBackoffMultiplier,
    onOpen,
    onMessage,
    onError,
    onClose,
    onReconnect,
    onReconnectStop,
    messageParser,
  ]);

  // Disconnect function
  const disconnect = useCallback((code?: number, reason?: string) => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
    }
    if (connectionTimeoutRef.current) {
      clearTimeout(connectionTimeoutRef.current);
    }
    if (heartbeatIntervalRef.current) {
      clearInterval(heartbeatIntervalRef.current);
    }

    setIsReconnecting(false);
    
    if (webSocketRef.current) {
      setConnectionState('Closing');
      webSocketRef.current.close(code, reason);
    } else {
      setConnectionState('Closed');
    }
  }, []);

  // Send message function
  const send = useCallback((message: WebSocketMessage): boolean => {
    if (!webSocketRef.current || webSocketRef.current.readyState !== WebSocket.OPEN) {
      if (queueMessagesWhenDisconnected && messageQueueRef.current.length < maxMessageQueueSize) {
        messageQueueRef.current.push(message);
        return false;
      }
      return false;
    }

    try {
      webSocketRef.current.send(message);
      setMetrics(prev => ({
        ...prev,
        messagesSent: prev.messagesSent + 1,
      }));
      return true;
    } catch (err) {
      // WebSocket send error occurred
      return false;
    }
  }, [queueMessagesWhenDisconnected, maxMessageQueueSize]);

  // Send JSON message
  const sendJson = useCallback((data: unknown): boolean => {
    try {
      return send(JSON.stringify(data));
    } catch (err) {
      // WebSocket send error occurred
      return false;
    }
  }, [send]);

  // Subscribe to events
  const subscribe = useCallback((event: string, handler: (data: unknown) => void): (() => void) => {
    if (!subscribersRef.current.has(event)) {
      subscribersRef.current.set(event, new Set());
    }
    subscribersRef.current.get(event)!.add(handler);

    // Return unsubscribe function
    return () => {
      const subscribers = subscribersRef.current.get(event);
      if (subscribers) {
        subscribers.delete(handler);
        if (subscribers.size === 0) {
          subscribersRef.current.delete(event);
        }
      }
    };
  }, []);

  // Unsubscribe from events
  const unsubscribe = useCallback((event: string, handler?: (data: unknown) => void) => {
    if (handler) {
      const subscribers = subscribersRef.current.get(event);
      if (subscribers) {
        subscribers.delete(handler);
        if (subscribers.size === 0) {
          subscribersRef.current.delete(event);
        }
      }
    } else {
      subscribersRef.current.delete(event);
    }
  }, []);

  // Clear message queue
  const clearMessageQueue = useCallback(() => {
    messageQueueRef.current = [];
  }, []);

  // Get WebSocket ready state
  const getReadyState = useCallback((): number => {
    return webSocketRef.current?.readyState ?? WebSocket.CLOSED;
  }, []);

  // Reset metrics
  const resetMetrics = useCallback(() => {
    setMetrics({
      totalConnections: 0,
      totalReconnections: 0,
      messagesSent: 0,
      messagesReceived: 0,
      lastConnected: null,
      lastDisconnected: null,
      uptime: 0,
      averageMessageFrequency: 0,
    });
    metricsStartTimeRef.current = Date.now();
  }, []);

  // Auto-connect on mount
  // We use a separate effect to avoid including connect/disconnect in dependencies
  // which would cause infinite loops due to their recreation on every render
  useEffect(() => {
    if (shouldConnect && url) {
      // Direct connection without using the callback
      if (!webSocketRef.current || webSocketRef.current.readyState !== WebSocket.OPEN) {
        connect();
      }
    }

    return () => {
      // Direct cleanup without using the callback
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
      if (connectionTimeoutRef.current) {
        clearTimeout(connectionTimeoutRef.current);
      }
      if (heartbeatIntervalRef.current) {
        clearInterval(heartbeatIntervalRef.current);
      }
      if (webSocketRef.current) {
        webSocketRef.current.close();
      }
    };
  }, [url, shouldConnect, connect]); // Include connect but it's stable due to useCallback

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
      if (connectionTimeoutRef.current) {
        clearTimeout(connectionTimeoutRef.current);
      }
      if (heartbeatIntervalRef.current) {
        clearInterval(heartbeatIntervalRef.current);
      }
    };
  }, []);

  return useMemo(() => ({
    // State
    connectionState,
    isConnected,
    isConnecting,
    lastMessage,
    lastMessageData,
    error,
    reconnectCount,
    isReconnecting,
    metrics,
    queuedMessageCount,
    
    // Actions
    send,
    sendJson,
    connect,
    disconnect,
    subscribe,
    unsubscribe,
    clearMessageQueue,
    getReadyState,
    resetMetrics,
  }), [
    connectionState,
    isConnected,
    isConnecting,
    lastMessage,
    lastMessageData,
    error,
    reconnectCount,
    isReconnecting,
    metrics,
    queuedMessageCount,
    send,
    sendJson,
    connect,
    disconnect,
    subscribe,
    unsubscribe,
    clearMessageQueue,
    getReadyState,
    resetMetrics,
  ]);
}