
import { renderHook, act, waitFor } from '@testing-library/react';
import { useWebSocket } from '@/hooks/use-websocket';
import WS from 'jest-websocket-mock';
import React from 'react';

/**
 * @jest-environment jsdom
 */


describe('useWebSocket', () => {
  let server: WS;
  const mockUrl = 'ws://localhost:1234';

  beforeEach(() => {
    server = new WS(mockUrl);
  });

  afterEach(() => {
    WS.clean();
    jest.clearAllTimers();
  });

describe('Connection Management', () => {
    it('should initialize with disconnected state', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));

      expect(result.current.isConnected).toBe(false);
      expect(result.current.getReadyState()).toBe(3);
      expect(result.current.lastMessage).toBeNull();
      expect(result.current.error).toBeNull();
    });

    it('should connect to WebSocket server', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));
      expect(result.current.getReadyState()).toBe(1);
    });

    it('should disconnect from WebSocket server', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      act(() => {
        result.current.disconnect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(false));
      expect(result.current.getReadyState()).toBe(3);
    });

    it('should auto-connect when shouldConnect is true', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: true }));

      await waitFor(() => expect(result.current.isConnected).toBe(true));
    });

    it('should not auto-connect when shouldConnect is false', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.isConnected).toBe(false);
      }); });
    });
  });

describe('Message Handling', () => {
    it('should receive messages from server', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));
      const testMessage = { type: 'test', data: 'hello' };

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      act(() => {
        server.send(JSON.stringify(testMessage));
      });

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.lastMessageData).toEqual(testMessage);
      }); });
    });

    it('should send messages to server', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));
      const testMessage = { type: 'test', data: 'hello' };

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      act(() => {
        result.current.sendJson(testMessage);
      });

      await expect(server).toReceiveMessage(JSON.stringify(testMessage));
    });

    it('should handle message count and metrics', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      const messages = ['msg1', 'msg2', 'msg3'];

      for (const msg of messages) {
        act(() => {
          server.send(JSON.stringify({ data: msg }));
        });
      }

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.metrics.messagesReceived).toBe(3);
      }); });
    });

    it('should clear message queue', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false, queueMessagesWhenDisconnected: true }));

      // Queue a message when disconnected
      act(() => {
        result.current.sendJson({ data: 'test' });
      });

      expect(result.current.queuedMessageCount).toBe(1);

      act(() => {
        result.current.clearMessageQueue();
      });

      expect(result.current.queuedMessageCount).toBe(0);
    });
  });

describe('Reconnection Logic', () => {
    jest.useFakeTimers();

    it('should attempt reconnection on disconnect', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, {
        shouldConnect: false,
        shouldReconnect: () => true,
        reconnectInterval: 1000,
        reconnectAttempts: 3
}));
      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      // Simulate disconnect
      act(() => {
        server.close();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(false));

      // Should attempt reconnection
      expect(result.current.reconnectCount).toBe(0);

      jest.advanceTimersByTime(1000);

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.reconnectCount).toBeGreaterThan(0);
      }); });
    });

    it('should stop reconnecting after max attempts', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, {
        shouldConnect: false,
        shouldReconnect: () => true,
        reconnectInterval: 1000,
        reconnectAttempts: 2
}));
      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      act(() => {
        server.close();
      });

      // Advance through reconnect attempts
      for (let i = 0; i < 3; i++) {
        jest.advanceTimersByTime(1000);
      }

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.reconnectCount).toBeLessThanOrEqual(2);
      }); });
    });

    jest.useRealTimers();
  });

describe('Error Handling', () => {
    it('should handle connection errors', async () => {
      const { result } = renderHook(() => useWebSocket('ws://invalid-url'));

      act(() => {
        result.current.connect();
      });

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.error).not.toBeNull();
      }); });

      expect(result.current.isConnected).toBe(false);
    });

    it('should handle message parsing errors', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      // Send invalid JSON - it should handle gracefully and keep original data
      act(() => {
        server.send('invalid json {');
      });

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.lastMessageData).toBe('invalid json {');
      }); });
    }); });

    it('should clear error on successful connect', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      expect(result.current.error).toBeNull();
    });
  });

describe('Event Callbacks', () => {
    it('should call onOpen callback', async () => {
      const onOpen = jest.fn();
      const { result } = renderHook(() => useWebSocket(mockUrl, { onOpen }));

      act(() => {
        result.current.connect();
      });

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(onOpen).toHaveBeenCalledWith(expect.any(Event));
      }); });
    });

    it('should call onClose callback', async () => {
      const onClose = jest.fn();
      const { result } = renderHook(() => useWebSocket(mockUrl, { onClose }));

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      act(() => {
        server.close();
      });

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(onClose).toHaveBeenCalledWith(expect.any(CloseEvent));
      }); });
    });

    it('should call onMessage callback', async () => {
      const onMessage = jest.fn();
      const { result } = renderHook(() => useWebSocket(mockUrl, { onMessage }));
      const testMessage = { type: 'test' };

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      act(() => {
        server.send(JSON.stringify(testMessage));
      });

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(onMessage).toHaveBeenCalledWith(testMessage);
      }); });
    });

    it('should call onError callback', async () => {
      const onError = jest.fn();
      const { result } = renderHook(() => useWebSocket('ws://invalid-url', { onError }));

      act(() => {
        result.current.connect();
      });

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(onError).toHaveBeenCalled();
      }); });
    });
  });

describe('Binary Data', () => {
    it('should send binary data', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      const binaryData = new Uint8Array([1, 2, 3, 4, 5]);

      act(() => {
        result.current.send(binaryData);
      });

      await expect(server).toReceiveMessage(binaryData);
    });
  });

describe('Protocols', () => {
    it('should connect with subprotocols', async () => {
      const protocols = ['chat', 'superchat'];
      const { result } = renderHook(() => useWebSocket(mockUrl, { protocols, shouldConnect: false }));

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));
    });
  });

describe('Cleanup', () => {
    it('should cleanup on unmount', async () => {
      const { result, unmount } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      unmount();

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(server.messages).toHaveLength(0);
      }); });
    });

    it('should cancel pending operations on unmount', async () => {
      const { result, unmount } = renderHook(() => useWebSocket(mockUrl, {
        shouldConnect: false,
        shouldReconnect: () => true,
        reconnectInterval: 1000
}));
      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      // Trigger reconnection
      act(() => {
        server.close();
      });

      // Unmount before reconnection
      unmount();

      // Should not attempt to reconnect
      expect(result.current.reconnectCount).toBe(0);
    });
  });

describe('Ready State', () => {
    it('should track WebSocket ready state', async () => {
      const { result } = renderHook(() => useWebSocket(mockUrl, { shouldConnect: false }));

      expect(result.current.getReadyState()).toBe(3);

      act(() => {
        result.current.connect();
      });

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.getReadyState()).toBe(1);
      }); });

      act(() => {
        result.current.disconnect();
      });

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.getReadyState()).toBe(3);
      }); });
    });
  });

describe('URL Changes', () => {
    it('should reconnect when URL changes', async () => {
      const { result, rerender } = renderHook(
        ({ url }) => useWebSocket(url, { shouldConnect: false }),
        { initialProps: { url: mockUrl } }
      );

      act(() => {
        result.current.connect();
      });

      await waitFor(() => expect(result.current.isConnected).toBe(true));

      const newUrl = 'ws://localhost:5678';
      const newServer = new WS(newUrl);

      rerender({ url: newUrl });

      act(() => {
        result.current.connect();
      });

      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.isConnected).toBe(true);
      }); });

      newServer.close();
    });
  });
});
}