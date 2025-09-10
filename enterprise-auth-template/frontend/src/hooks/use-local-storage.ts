'use client';

import { useState, useCallback, useEffect, useRef, useMemo } from 'react';

/**
 * Local storage hook with TypeScript support and advanced features
 * 
 * Provides a comprehensive localStorage interface with:
 * - Type-safe serialization/deserialization
 * - SSR compatibility (no hydration errors)
 * - Storage event synchronization across tabs
 * - Error handling and fallback values
 * - Optional data validation
 * - Storage quota monitoring
 * - Automatic cleanup and expiration
 * - Compression support for large data
 * - Migration support for schema changes
 * 
 * @example
 * ```typescript
 * // Basic usage
 * const [user, setUser] = useLocalStorage<User>('currentUser', null);
 * 
 * // With validation
 * const [preferences, setPreferences] = useLocalStorage('userPreferences', 
 *   { theme: 'light' },
 *   {
 *     validator: (value) => {
 *       return value && typeof value.theme === 'string';
 *     },
 *     serializer: {
 *       serialize: JSON.stringify,
 *       deserialize: JSON.parse,
 *     }
 *   }
 * );
 * 
 * // With expiration
 * const [tempData, setTempData] = useLocalStorage('tempData', null, {
 *   ttl: 3600000, // 1 hour
 * });
 * 
 * // Multi-tab synchronization
 * const [sharedState, setSharedState] = useLocalStorage('sharedState', 0, {
 *   syncAcrossTabs: true,
 * });
 * ```
 */

export interface StorageSerializer<T> {
  /** Serialize value to string */
  serialize: (value: T) => string;
  /** Deserialize string to value */
  deserialize: (value: string) => T;
}

export interface StorageOptions<T> {
  /** Custom serializer for complex data types */
  serializer?: StorageSerializer<T>;
  /** Value validator function */
  validator?: (value: unknown) => value is T;
  /** Time to live in milliseconds */
  ttl?: number;
  /** Whether to sync changes across browser tabs */
  syncAcrossTabs?: boolean;
  /** Whether to compress large values */
  enableCompression?: boolean;
  /** Compression threshold in bytes */
  compressionThreshold?: number;
  /** Migration function for handling schema changes */
  migrate?: (oldValue: unknown, version?: number) => T;
  /** Current schema version */
  version?: number;
  /** Error handler */
  onError?: (error: Error, operation: 'get' | 'set' | 'remove') => void;
  /** Success handler */
  onSuccess?: (value: T, operation: 'get' | 'set' | 'remove') => void;
}

export interface StoredValue<T> {
  /** The actual stored value */
  value: T;
  /** Timestamp when value was stored */
  timestamp: number;
  /** TTL in milliseconds */
  ttl?: number;
  /** Schema version */
  version?: number;
  /** Whether value is compressed */
  compressed?: boolean;
}

export interface UseLocalStorageReturn<T> {
  /** Current value */
  value: T;
  /** Set new value */
  setValue: (value: T | ((prevValue: T) => T)) => void;
  /** Remove value from storage */
  removeValue: () => void;
  /** Check if value exists in storage */
  hasValue: boolean;
  /** Whether storage is available */
  isStorageAvailable: boolean;
  /** Last error that occurred */
  error: Error | null;
  /** Clear last error */
  clearError: () => void;
  /** Get raw storage size for this key */
  getStorageSize: () => number;
  /** Check if value is expired */
  isExpired: boolean;
  /** Refresh value from storage */
  refresh: () => void;
  /** Get storage metadata */
  getMetadata: () => Omit<StoredValue<T>, 'value'> | null;
}

// Default JSON serializer
const defaultSerializer: StorageSerializer<unknown> = {
  serialize: JSON.stringify,
  deserialize: JSON.parse,
};

// Simple compression using btoa/atob (basic implementation)
const compress = (str: string): string => {
  try {
    return btoa(str);
  } catch {
    return str;
  }
};

const decompress = (str: string): string => {
  try {
    return atob(str);
  } catch {
    return str;
  }
};

// Check if localStorage is available
const isLocalStorageAvailable = (): boolean => {
  if (typeof window === 'undefined') return false;
  
  try {
    const testKey = '__localStorage_test__';
    localStorage.setItem(testKey, 'test');
    localStorage.removeItem(testKey);
    return true;
  } catch {
    return false;
  }
};

// Get current storage usage
const getStorageUsage = (): { used: number; total: number; remaining: number } => {
  if (!isLocalStorageAvailable()) {
    return { used: 0, total: 0, remaining: 0 };
  }

  let used = 0;
  for (const key in localStorage) {
    if (localStorage.hasOwnProperty(key)) {
      used += localStorage[key].length + key.length;
    }
  }

  // Most browsers have a 5-10MB limit
  const total = 10 * 1024 * 1024; // 10MB estimate
  return {
    used,
    total,
    remaining: total - used,
  };
};

export function useLocalStorage<T>(
  key: string,
  initialValue: T,
  options: StorageOptions<T> = {}
): UseLocalStorageReturn<T> {
  const {
    serializer = defaultSerializer as StorageSerializer<T>,
    validator,
    ttl,
    syncAcrossTabs = false,
    enableCompression = false,
    compressionThreshold = 1024, // 1KB
    migrate,
    version = 1,
    onError,
    onSuccess,
  } = options;

  const [storedValue, setStoredValue] = useState<T>(initialValue);
  const [error, setError] = useState<Error | null>(null);
  const [hasValue, setHasValue] = useState<boolean>(false);
  const [isExpired, setIsExpired] = useState<boolean>(false);
  
  const isStorageAvailable = useMemo(() => isLocalStorageAvailable(), []);
  const storageRef = useRef<Storage | null>(
    isStorageAvailable ? localStorage : null
  );
  const initializedRef = useRef<boolean>(false);

  // Check if value is expired
  const checkExpiration = useCallback((storedData: StoredValue<T>): boolean => {
    if (!storedData.ttl) return false;
    return Date.now() - storedData.timestamp > storedData.ttl;
  }, []);

  // Get value from storage
  const getStoredValue = useCallback((): T => {
    if (!storageRef.current) {
      return initialValue;
    }

    try {
      const item = storageRef.current.getItem(key);
      
      if (item === null) {
        setHasValue(false);
        return initialValue;
      }

      let storedData: StoredValue<T>;
      try {
        storedData = JSON.parse(item) as StoredValue<T>;
      } catch {
        // Handle legacy data without metadata
        const legacyValue = serializer.deserialize(item);
        if (validator && !validator(legacyValue)) {
          throw new Error('Stored value failed validation');
        }
        setHasValue(true);
        return legacyValue;
      }

      // Check expiration
      if (checkExpiration(storedData)) {
        storageRef.current.removeItem(key);
        setHasValue(false);
        setIsExpired(true);
        return initialValue;
      }

      // Decompress if needed
      let valueStr = serializer.serialize(storedData.value);
      if (storedData.compressed) {
        valueStr = decompress(valueStr);
      }

      // Deserialize
      let value: T;
      try {
        value = serializer.deserialize(valueStr);
      } catch {
        value = storedData.value;
      }

      // Handle migration
      if (migrate && storedData.version !== version) {
        value = migrate(value, storedData.version);
      }

      // Validate
      if (validator && !validator(value)) {
        throw new Error('Stored value failed validation');
      }

      setHasValue(true);
      setIsExpired(false);
      
      if (onSuccess) {
        onSuccess(value, 'get');
      }

      return value;

    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to get stored value');
      setError(error);
      setHasValue(false);
      
      if (onError) {
        onError(error, 'get');
      }
      
      return initialValue;
    }
  }, [key, initialValue, serializer, validator, migrate, version, checkExpiration, onError, onSuccess]);

  // Set value in storage
  const setStorageValue = useCallback(
    (value: T) => {
      if (!storageRef.current) {
        setStoredValue(value);
        return;
      }

      try {
        // Create storage object with metadata
        const storedData: StoredValue<T> = {
          value,
          timestamp: Date.now(),
          version,
        };

        if (ttl) {
          storedData.ttl = ttl;
        }

        // Serialize
        let serializedValue = JSON.stringify(storedData);
        
        // Compress if enabled and value is large enough
        if (enableCompression && serializedValue.length > compressionThreshold) {
          const compressed = compress(serializedValue);
          if (compressed.length < serializedValue.length) {
            serializedValue = compressed;
            storedData.compressed = true;
          }
        }

        // Check storage quota
        const { remaining } = getStorageUsage();
        if (remaining < serializedValue.length) {
          throw new Error('Storage quota exceeded');
        }

        // Store the complete object
        const finalStored = storedData.compressed 
          ? { ...storedData, value: serializedValue }
          : storedData;

        storageRef.current.setItem(key, JSON.stringify(finalStored));
        
        setStoredValue(value);
        setHasValue(true);
        setError(null);
        setIsExpired(false);
        
        if (onSuccess) {
          onSuccess(value, 'set');
        }

      } catch (err) {
        const error = err instanceof Error ? err : new Error('Failed to set stored value');
        setError(error);
        
        if (onError) {
          onError(error, 'set');
        }
      }
    },
    [key, ttl, version, enableCompression, compressionThreshold, onError, onSuccess]
  );

  // Remove value from storage
  const removeStorageValue = useCallback(() => {
    if (!storageRef.current) {
      setStoredValue(initialValue);
      return;
    }

    try {
      storageRef.current.removeItem(key);
      setStoredValue(initialValue);
      setHasValue(false);
      setError(null);
      setIsExpired(false);
      
      if (onSuccess) {
        onSuccess(initialValue, 'remove');
      }
      
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to remove stored value');
      setError(error);
      
      if (onError) {
        onError(error, 'remove');
      }
    }
  }, [key, initialValue, onError, onSuccess]);

  // Initialize value on mount
  useEffect(() => {
    if (!initializedRef.current) {
      const value = getStoredValue();
      setStoredValue(value);
      initializedRef.current = true;
    }
  }, [getStoredValue]);

  // Listen for storage events across tabs
  useEffect(() => {
    if (!syncAcrossTabs || !isStorageAvailable) return;

    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === key && e.newValue !== null) {
        try {
          const storedData: StoredValue<T> = JSON.parse(e.newValue);
          
          if (!checkExpiration(storedData)) {
            let value = storedData.value;
            
            // Handle decompression
            if (storedData.compressed) {
              const valueStr = decompress(serializer.serialize(value));
              value = serializer.deserialize(valueStr);
            }
            
            // Handle migration
            if (migrate && storedData.version !== version) {
              value = migrate(value, storedData.version);
            }
            
            // Validate
            if (!validator || validator(value)) {
              setStoredValue(value);
              setHasValue(true);
              setIsExpired(false);
            }
          }
        } catch {
          // Ignore parsing errors from other tabs
        }
      } else if (e.key === key && e.newValue === null) {
        setStoredValue(initialValue);
        setHasValue(false);
        setIsExpired(false);
      }
    };

    window.addEventListener('storage', handleStorageChange);
    return () => window.removeEventListener('storage', handleStorageChange);
  }, [key, syncAcrossTabs, isStorageAvailable, serializer, validator, migrate, version, initialValue, checkExpiration]);

  // Public API
  const setValue = useCallback(
    (value: T | ((prevValue: T) => T)) => {
      const newValue = typeof value === 'function' 
        ? (value as (prevValue: T) => T)(storedValue)
        : value;
      
      setStorageValue(newValue);
    },
    [storedValue, setStorageValue]
  );

  const removeValue = useCallback(() => {
    removeStorageValue();
  }, [removeStorageValue]);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const getStorageSize = useCallback((): number => {
    if (!storageRef.current) return 0;
    
    try {
      const item = storageRef.current.getItem(key);
      return item ? item.length + key.length : 0;
    } catch {
      return 0;
    }
  }, [key]);

  const refresh = useCallback(() => {
    const value = getStoredValue();
    setStoredValue(value);
  }, [getStoredValue]);

  const getMetadata = useCallback((): Omit<StoredValue<T>, 'value'> | null => {
    if (!storageRef.current) return null;
    
    try {
      const item = storageRef.current.getItem(key);
      if (!item) return null;
      
      const storedData: StoredValue<T> = JSON.parse(item);
      const { value: _unused, ...metadata } = storedData;
      return metadata;
    } catch {
      return null;
    }
  }, [key]);

  return {
    value: storedValue,
    setValue,
    removeValue,
    hasValue,
    isStorageAvailable,
    error,
    clearError,
    getStorageSize,
    isExpired,
    refresh,
    getMetadata,
  };
}

/**
 * Hook for managing multiple related localStorage values as a single object
 * 
 * @example
 * ```typescript
 * const {
 *   values: settings,
 *   setValue,
 *   updateValues,
 *   resetValues,
 * } = useLocalStorageObject('appSettings', {
 *   theme: 'light',
 *   language: 'en',
 *   notifications: true,
 * });
 * 
 * // Update single setting
 * setValue('theme', 'dark');
 * 
 * // Update multiple settings
 * updateValues({ theme: 'dark', language: 'es' });
 * ```
 */
export function useLocalStorageObject<T extends Record<string, unknown>>(
  key: string,
  initialValue: T,
  options: StorageOptions<T> = {}
) {
  const localStorage = useLocalStorage(key, initialValue, options);

  const setValue = useCallback(
    <K extends keyof T>(property: K, value: T[K]) => {
      localStorage.setValue(prev => ({
        ...prev,
        [property]: value,
      }));
    },
    [localStorage]
  );

  const updateValues = useCallback(
    (updates: Partial<T>) => {
      localStorage.setValue(prev => ({
        ...prev,
        ...updates,
      }));
    },
    [localStorage]
  );

  const resetValues = useCallback(() => {
    localStorage.setValue(initialValue);
  }, [localStorage, initialValue]);

  return {
    values: localStorage.value,
    setValue,
    updateValues,
    resetValues,
    removeValue: localStorage.removeValue,
    hasValue: localStorage.hasValue,
    isStorageAvailable: localStorage.isStorageAvailable,
    error: localStorage.error,
    clearError: localStorage.clearError,
    getStorageSize: localStorage.getStorageSize,
    isExpired: localStorage.isExpired,
    refresh: localStorage.refresh,
    getMetadata: localStorage.getMetadata,
  };
}

/**
 * Hook for managing localStorage with automatic cleanup
 * 
 * @example
 * ```typescript
 * const sessionData = useTemporaryLocalStorage('sessionData', null, {
 *   ttl: 1800000, // 30 minutes
 *   cleanupInterval: 300000, // Check every 5 minutes
 * });
 * ```
 */
export function useTemporaryLocalStorage<T>(
  key: string,
  initialValue: T,
  options: StorageOptions<T> & {
    /** Cleanup check interval (ms) */
    cleanupInterval?: number;
  } = {}
) {
  const { cleanupInterval = 300000, ...storageOptions } = options; // Default 5 minutes
  const localStorage = useLocalStorage(key, initialValue, storageOptions);

  // Auto-cleanup expired values
  useEffect(() => {
    if (!cleanupInterval || !storageOptions.ttl) return;

    const interval = setInterval(() => {
      if (localStorage.isExpired) {
        localStorage.removeValue();
      }
    }, cleanupInterval);

    return () => clearInterval(interval);
  }, [cleanupInterval, storageOptions.ttl, localStorage]);

  return localStorage;
}