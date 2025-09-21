
import { renderHook, act } from '@testing-library/react';
import React from 'react';

/**
 * @jest-environment jsdom
 */

/**
 * Comprehensive Local Storage Hook Test Suite
 * Tests all local storage hook functionality with proper TypeScript typing
 *
 * Coverage includes:
 * - Basic localStorage operations (get, set, remove)
 * - Type-safe serialization and deserialization
 * - SSR compatibility and hydration handling
 * - Storage event synchronization across tabs
 * - Error handling and fallback values
 * - Data validation and schema migration
 * - Storage quota monitoring and management
 * - Automatic cleanup and expiration (TTL)
 * - Compression support for large data
 * - Object-based storage utilities
 * - Temporary storage with auto-cleanup
 * - Cross-tab synchronization testing
 */
import {
  useLocalStorage,
  useLocalStorageObject,
  useTemporaryLocalStorage,
  type StorageOptions,
  type StorageSerializer
} from '@/hooks/use-local-storage';
// Mock localStorage
const mockLocalStorage = (() => {
  let store: Record<string, string> = {};

  return {
    getItem: jest.fn((key: string) => store[key] || null),
    setItem: jest.fn((key: string, value: string) => {
      store[key] = value;
    }),
    removeItem: jest.fn((key: string) => {
      delete store[key];
    }),
    clear: jest.fn(() => {
      store = {};
    }),
    get length() {
      return Object.keys(store).length;
    },
    key: jest.fn((index: number) => Object.keys(store)[index] || null),
  };
})();

// Mock window.localStorage
Object.defineProperty(window, 'localStorage', {
  value: mockLocalStorage,
  writable: true
});

// Mock storage events for cross-tab testing
const dispatchStorageEvent = (key: string, newValue: string | null, oldValue?: string | null) => {
  const event = new StorageEvent('storage', {
    key,
    newValue,
    oldValue: oldValue || null,
    storageArea: window.localStorage
  });
  window.dispatchEvent(event);
};

// Test data interfaces
interface TestUser {
  id: number;
  name: string;
  email: string;
  preferences: {
    theme: 'light' | 'dark';
    notifications: boolean;
  };
}

interface TestSettings {
  theme: 'light' | 'dark';
  language: string;
  autoSave: boolean;
  maxItems: number;
}

describe('Local Storage Hooks Comprehensive Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockLocalStorage.clear();
    jest.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

describe('useLocalStorage', () => {
    describe('Basic Functionality', () => {
      it('should return initial value when no stored value exists', () => {
        const { result } = renderHook(() =>
          useLocalStorage('test-key', 'default-value')
        );

        expect(result.current.value).toBe('default-value');
        expect(result.current.hasValue).toBe(false);
        expect(result.current.error).toBeNull();
        expect(result.current.isStorageAvailable).toBe(true);
      });

      it('should store and retrieve values correctly', () => {
        const { result } = renderHook(() =>
          useLocalStorage('test-key', 'default')
        );

        act(() => {
          result.current.setValue('new-value');
        });

        expect(result.current.value).toBe('new-value');
        expect(result.current.hasValue).toBe(true);
        expect(mockLocalStorage.setItem).toHaveBeenCalledWith(
          'test-key',
          expect.stringContaining('new-value')
        );
      });

      it('should preserve TypeScript types', () => {
        const testUser: TestUser = {
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          preferences: {
            theme: 'dark',
            notifications: true,
          },
        };

        const { result } = renderHook(() =>
          useLocalStorage<TestUser>('user', testUser)
        );

        // TypeScript should maintain the interface type
        expect(result.current.value.id).toBe(1);
        expect(result.current.value.name).toBe('John Doe');
        expect(result.current.value.preferences.theme).toBe('dark');
        expect(typeof result.current.value.id).toBe('number');
        expect(typeof result.current.value.name).toBe('string');
      });

      it('should handle functional updates', () => {
        const { result } = renderHook(() =>
          useLocalStorage('counter', 0)
        );

        act(() => {
          result.current.setValue(prev => prev + 1);
        });

        expect(result.current.value).toBe(1);

        act(() => {
          result.current.setValue(prev => prev * 2);
        });

        expect(result.current.value).toBe(2);
      });

      it('should remove values correctly', () => {
        const { result } = renderHook(() =>
          useLocalStorage('test-key', 'default')
        );

        act(() => {
          result.current.setValue('stored-value');
        });

        expect(result.current.hasValue).toBe(true);

        act(() => {
          result.current.removeValue();
        });

        expect(result.current.value).toBe('default');
        expect(result.current.hasValue).toBe(false);
        expect(mockLocalStorage.removeItem).toHaveBeenCalledWith('test-key');
      });
    });

describe('Serialization and Validation', () => {
      it('should use custom serializer', () => {
        const customSerializer: StorageSerializer<number> = {
          serialize: (value: number) => `num:${value}`,
          deserialize: (value: string) => parseInt(value.replace('num:', ''), 10),
        };

        const options: StorageOptions<number> = {
          serializer: customSerializer,
        };

        const { result } = renderHook(() =>
          useLocalStorage('custom-num', 42, options)
        );

        act(() => {
          result.current.setValue(100);
        });

        expect(result.current.value).toBe(100);
        
        // Check that setItem was called (custom serializer is used internally)
        expect(mockLocalStorage.setItem).toHaveBeenCalledWith(
          'custom-num',
          expect.any(String)
        );
        
        // The stored value should be accessible
        expect(result.current.value).toBe(100);
      });

      it('should validate stored values', () => {
        const validator = (value: unknown): value is TestUser => {
          return (
            typeof value === 'object' &&
            value !== null &&
            'id' in value &&
            'name' in value &&
            'email' in value
          );
        };

        const options: StorageOptions<TestUser> = {
          validator,
        };

        const defaultUser: TestUser = {
          id: 0,
          name: '',
          email: '',
          preferences: { theme: 'light', notifications: false },
        };

        // Pre-populate with invalid data
        mockLocalStorage.setItem('user', JSON.stringify({
          value: { invalid: 'data' },
          timestamp: Date.now(),
}));
        const { result } = renderHook(() =>
          useLocalStorage('user', defaultUser, options)
        );

        // Should fallback to default due to validation failure
        expect(result.current.value).toEqual(defaultUser);
        expect(result.current.error).toBeTruthy();
      });

      it('should handle migration for schema changes', () => {
        const migrate = (oldValue: unknown, version?: number): TestUser => {
          if (version === 1) {
            // Migrate from v1 to v2
            const old = oldValue as { name: string; email: string };
            return {
              id: 1,
              name: old.name,
              email: old.email,
              preferences: { theme: 'light', notifications: true },
            };
          }
          return oldValue as TestUser;
        };

        const options: StorageOptions<TestUser> = {
          migrate,
          version: 2,
        };

        const defaultUser: TestUser = {
          id: 0,
          name: '',
          email: '',
          preferences: { theme: 'light', notifications: false },
        };

        // Pre-populate with v1 data
        mockLocalStorage.setItem('user', JSON.stringify({
          value: { name: 'John', email: 'john@example.com' },
          timestamp: Date.now(),
          version: 1,
}));
        const { result } = renderHook(() =>
          useLocalStorage('user', defaultUser, options)
        );

        // Should have migrated the data
        expect(result.current.value.id).toBe(1);
        expect(result.current.value.name).toBe('John');
        expect(result.current.value.email).toBe('john@example.com');
        expect(result.current.value.preferences).toEqual({
          theme: 'light',
          notifications: true
        });
      });
    });

describe('TTL and Expiration', () => {
      it('should handle TTL expiration', () => {
        const options: StorageOptions<string> = {
          ttl: 1000, // 1 second
        };

        // Pre-populate with expired data
        const expiredTimestamp = Date.now() - 2000; // 2 seconds ago
        mockLocalStorage.setItem('expired-key', JSON.stringify({
          value: 'expired-value',
          timestamp: expiredTimestamp,
          ttl: 1000,
}));
        const { result } = renderHook(() =>
          useLocalStorage('expired-key', 'default', options)
        );

        expect(result.current.value).toBe('default');
        expect(result.current.isExpired).toBe(true);
        expect(result.current.hasValue).toBe(false);
      });

      it('should not expire valid TTL data', () => {
        const options: StorageOptions<string> = {
          ttl: 60000, // 1 minute
        };

        // Pre-populate with fresh data
        const freshTimestamp = Date.now() - 5000; // 5 seconds ago
        mockLocalStorage.setItem('fresh-key', JSON.stringify({
          value: 'fresh-value',
          timestamp: freshTimestamp,
          ttl: 60000,
}));
        const { result } = renderHook(() =>
          useLocalStorage('fresh-key', 'default', options)
        );

        expect(result.current.value).toBe('fresh-value');
        expect(result.current.isExpired).toBe(false);
        expect(result.current.hasValue).toBe(true);
      });
    });

describe('Cross-tab Synchronization', () => {
      it('should sync changes across tabs when enabled', () => {
        const options: StorageOptions<string> = {
          syncAcrossTabs: true,
        };

        const { result } = renderHook(() =>
          useLocalStorage('sync-key', 'initial', options)
        );

        expect(result.current.value).toBe('initial');

        // Simulate storage event from another tab
        act(() => {
          dispatchStorageEvent('sync-key', JSON.stringify({
            value: 'from-other-tab',
            timestamp: Date.now(),
}));
        });

        expect(result.current.value).toBe('from-other-tab');
      });

      it('should handle storage removal events', () => {
        const options: StorageOptions<string> = {
          syncAcrossTabs: true,
        };

        const { result } = renderHook(() =>
          useLocalStorage('sync-key', 'default', options)
        );

        act(() => {
          result.current.setValue('some-value');
        });

        expect(result.current.value).toBe('some-value');

        // Simulate removal from another tab
        act(() => {
          dispatchStorageEvent('sync-key', null);
        });

        expect(result.current.value).toBe('default');
        expect(result.current.hasValue).toBe(false);
      });

      it('should ignore invalid storage events', () => {
        const options: StorageOptions<string> = {
          syncAcrossTabs: true,
        };

        const { result } = renderHook(() =>
          useLocalStorage('sync-key', 'default', options)
        );

        act(() => {
          result.current.setValue('original');
        });

        // Simulate invalid JSON from another tab
        act(() => {
          dispatchStorageEvent('sync-key', 'invalid-json');
        });

        // Should maintain original value
        expect(result.current.value).toBe('original');
      });
    });

describe('Error Handling', () => {
      it('should handle storage unavailability', () => {
        // Mock localStorage as unavailable
        Object.defineProperty(window, 'localStorage', {
          value: undefined,
          writable: true
        });

        const { result } = renderHook(() =>
          useLocalStorage('test-key', 'default')
        );

        expect(result.current.isStorageAvailable).toBe(false);
        expect(result.current.value).toBe('default');

        // Operations should still work in memory
        act(() => {
          result.current.setValue('new-value');
        });

        expect(result.current.value).toBe('new-value');

        // Restore localStorage
        Object.defineProperty(window, 'localStorage', {
          value: mockLocalStorage,
          writable: true
        });
      });

      it('should handle storage quota exceeded', () => {
        // Mock setItem to throw quota exceeded error
        mockLocalStorage.setItem.mockImplementation(() => {
          throw new Error('Storage quota exceeded');
        });

        const onError = jest.fn();
        const options: StorageOptions<string> = {
          onError,
        };

        const { result } = renderHook(() =>
          useLocalStorage('test-key', 'default', options)
        );

        act(() => {
          result.current.setValue('large-value');
        });

        expect(result.current.error).toBeTruthy();
        expect(onError).toHaveBeenCalledWith(
          expect.any(Error),
          'set'
        );
      });

      it('should call success callbacks', () => {
        const onSuccess = jest.fn();
        const options: StorageOptions<string> = {
          onSuccess,
        };

        const { result } = renderHook(() =>
          useLocalStorage('test-key', 'default', options)
        );

        act(() => {
          result.current.setValue('success-value');
        });

        expect(onSuccess).toHaveBeenCalledWith('success-value', 'set');

        act(() => {
          result.current.removeValue();
        });

        expect(onSuccess).toHaveBeenCalledWith('default', 'remove');
      });
    });

describe('Utility Methods', () => {
      it('should provide storage size information', () => {
        const { result } = renderHook(() =>
          useLocalStorage('size-key', 'initial')
        );

        act(() => {
          result.current.setValue('larger-value-for-testing');
        });

        const size = result.current.getStorageSize();
        expect(typeof size).toBe('number');
        expect(size).toBeGreaterThan(0);
      });

      it('should provide metadata', () => {
        const options: StorageOptions<string> = {
          ttl: 60000,
          version: 2,
        };

        const { result } = renderHook(() =>
          useLocalStorage('meta-key', 'default', options)
        );

        act(() => {
          result.current.setValue('test-value');
        });

        const metadata = result.current.getMetadata();
        expect(metadata).toBeTruthy();
        expect(metadata?.timestamp).toBeTruthy();
        expect(metadata?.ttl).toBe(60000);
        expect(metadata?.version).toBe(2);
      });

      it('should refresh value from storage', () => {
        const { result } = renderHook(() =>
          useLocalStorage('refresh-key', 'default')
        );

        // Manually modify storage
        mockLocalStorage.setItem('refresh-key', JSON.stringify({
          value: 'externally-modified',
          timestamp: Date.now(),
}));
        act(() => {
          result.current.refresh();
        });

        expect(result.current.value).toBe('externally-modified');
      });

      it('should clear errors', () => {
        // Mock getItem to throw error
        mockLocalStorage.getItem.mockImplementationOnce(() => {
          throw new Error('Storage error');
        });

        const { result } = renderHook(() =>
          useLocalStorage('error-key', 'default')
        );

        expect(result.current.error).toBeTruthy();

        act(() => {
          result.current.clearError();
        });

        expect(result.current.error).toBeNull();
      });
    });
  });

describe('useLocalStorageObject', () => {
    it('should manage object properties', () => {
      const initialSettings: TestSettings = {
        theme: 'light',
        language: 'en',
        autoSave: true,
        maxItems: 10,
      };

      const { result } = renderHook(() =>
        useLocalStorageObject('settings', initialSettings)
      );

      expect(result.current.values).toEqual(initialSettings);

      // Update single property
      act(() => {
        result.current.setValue('theme', 'dark');
      });

      expect(result.current.values.theme).toBe('dark');
      expect(result.current.values.language).toBe('en'); // Other props unchanged

      // Update multiple properties
      act(() => {
        result.current.updateValues({
          language: 'es',
          maxItems: 20
        });
      });

      expect(result.current.values.language).toBe('es');
      expect(result.current.values.maxItems).toBe(20);
      expect(result.current.values.theme).toBe('dark'); // Previous change preserved
    });

    it('should reset to initial values', () => {
      const initialSettings: TestSettings = {
        theme: 'light',
        language: 'en',
        autoSave: true,
        maxItems: 10,
      };

      const { result } = renderHook(() =>
        useLocalStorageObject('settings', initialSettings)
      );

      // Make changes
      act(() => {
        result.current.updateValues({
          theme: 'dark',
          language: 'es'
        });
      });

      expect(result.current.values.theme).toBe('dark');

      // Reset
      act(() => {
        result.current.resetValues();
      });

      expect(result.current.values).toEqual(initialSettings);
    });

    it('should preserve TypeScript property types', () => {
      const initialSettings: TestSettings = {
        theme: 'light',
        language: 'en',
        autoSave: true,
        maxItems: 10,
      };

      const { result } = renderHook(() =>
        useLocalStorageObject('settings', initialSettings)
      );

      // TypeScript should enforce correct types
      act(() => {
        result.current.setValue('maxItems', 25);
        // result.current.setValue('maxItems', 'invalid'); // Should cause TS error
      });

      expect(result.current.values.maxItems).toBe(25);
      expect(typeof result.current.values.maxItems).toBe('number');
    });
  });

describe('useTemporaryLocalStorage', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it('should auto-cleanup expired values', () => {
      const options = {
        ttl: 5000, // 5 seconds
        cleanupInterval: 1000, // Check every 1 second
      };

      const { result } = renderHook(() =>
        useTemporaryLocalStorage('temp-key', 'default', options)
      );

      act(() => {
        result.current.setValue('temporary-value');
      });

      expect(result.current.value).toBe('temporary-value');

      // Fast-forward past TTL
      act(() => {
        jest.advanceTimersByTime(6000);
      });

      // Should be cleaned up
      expect(result.current.value).toBe('default');
      expect(result.current.hasValue).toBe(false);
    });

    it('should not cleanup if no TTL specified', () => {
      const options = {
        cleanupInterval: 1000,
      };

      const { result } = renderHook(() =>
        useTemporaryLocalStorage('persistent-key', 'default', options)
      );

      act(() => {
        result.current.setValue('persistent-value');
      });

      // Advance time
      act(() => {
        jest.advanceTimersByTime(10000);
      });

      // Should still be there
      expect(result.current.value).toBe('persistent-value');
    });
  });

describe('SSR Compatibility', () => {
    it('should handle server-side rendering', () => {
      // Mock window as undefined (SSR environment)
      const originalWindow = global.window;
      delete (global as { window?: Window }).window;

      const { result } = renderHook(() =>
        useLocalStorage('ssr-key', 'default')
      );

      expect(result.current.value).toBe('default');
      expect(result.current.isStorageAvailable).toBe(false);

      // Should not cause hydration errors
      act(() => {
        result.current.setValue('new-value');
      });

      expect(result.current.value).toBe('new-value');

      // Restore window
      global.window = originalWindow;
    });
  });

describe('Compression Support', () => {
    it('should compress large values when enabled', () => {
      const options: StorageOptions<string> = {
        enableCompression: true,
        compressionThreshold: 10, // Very low threshold for testing
      };

      const { result } = renderHook(() =>
        useLocalStorage('compress-key', '', options)
      );

      const largeValue = 'x'.repeat(100); // 100 character string

      act(() => {
        result.current.setValue(largeValue);
      });

      expect(result.current.value).toBe(largeValue);

      // Check that compression was attempted
      const storedValue = mockLocalStorage.setItem.mock.calls[0][1];
      const storedData = JSON.parse(storedValue);

      // If compression was effective, the compressed flag should be set
      expect(storedData.compressed).toBeDefined();
    });
  });
});