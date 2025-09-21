'use client';

import { useEffect, useState, useCallback, useRef, useMemo } from 'react';

/**
 * Debounce hook with comprehensive functionality and TypeScript support
 * 
 * Provides debouncing capabilities with:
 * - Value debouncing with configurable delay
 * - Function debouncing for callbacks
 * - Leading and trailing edge execution options
 * - Manual flush and cancel capabilities
 * - Immediate execution option
 * - Cleanup on unmount
 * 
 * @example
 * ```typescript
 * // Basic value debouncing
 * const debouncedSearchTerm = useDebounce(searchTerm, 300);
 * 
 * // Function debouncing
 * const { debouncedCallback, flush, cancel } = useDebouncedCallback(
 *   (query: string) => searchAPI(query),
 *   500,
 *   { leading: false, trailing: true }
 * );
 * 
 * // Advanced debouncing with options
 * const debouncedValue = useDebounce(inputValue, 300, {
 *   leading: true,
 *   maxWait: 1000,
 * });
 * ```
 */

export interface DebounceOptions {
  /** Execute on the leading edge of the timeout */
  leading?: boolean;
  /** Execute on the trailing edge of the timeout */
  trailing?: boolean;
  /** Maximum time function is allowed to be delayed */
  maxWait?: number;
}

export interface DebouncedState<T> {
  /** Current debounced value */
  value: T;
  /** Whether debounce is currently waiting */
  isPending: boolean;
  /** Manually trigger the debounced update */
  flush: () => void;
  /** Cancel pending debounced update */
  cancel: () => void;
}

/**
 * Debounces a value, delaying updates until after the specified delay
 * 
 * @param value - The value to debounce
 * @param delay - The delay in milliseconds
 * @param options - Debounce options
 * @returns The debounced value
 */
export function useDebounce<T>(
  value: T,
  delay: number,
  options?: DebounceOptions
): T {
  const { leading = false, trailing = true, maxWait } = options || {};
  const [debouncedValue, setDebouncedValue] = useState<T>(value);
  const timeoutRef = useRef<NodeJS.Timeout | undefined>(undefined);
  const maxTimeoutRef = useRef<NodeJS.Timeout | undefined>(undefined);
  const lastCallTimeRef = useRef<number | undefined>(undefined);
  const lastInvokeTimeRef = useRef<number>(0);
  const lastValueRef = useRef<T>(value);
  const leadingInvokedRef = useRef<boolean>(false);

  // Keep track of the last value
  lastValueRef.current = value;

  const invokeFunc = useCallback(() => {
    setDebouncedValue(lastValueRef.current);
    lastInvokeTimeRef.current = Date.now();
  }, []);

  const leadingEdge = useCallback((time: number) => {
    lastInvokeTimeRef.current = time;
    if (leading && !leadingInvokedRef.current) {
      // Set the value immediately for leading edge
      setDebouncedValue(lastValueRef.current);
      leadingInvokedRef.current = true;
    }
  }, [leading]);

  const remainingWait = useCallback((time: number) => {
    const timeSinceLastCall = time - (lastCallTimeRef.current || 0);
    const timeSinceLastInvoke = time - lastInvokeTimeRef.current;
    const timeWaiting = delay - timeSinceLastCall;

    return maxWait !== undefined
      ? Math.min(timeWaiting, maxWait - timeSinceLastInvoke)
      : timeWaiting;
  }, [delay, maxWait]);

  const shouldInvoke = useCallback((time: number) => {
    const timeSinceLastCall = time - (lastCallTimeRef.current || 0);
    const timeSinceLastInvoke = time - lastInvokeTimeRef.current;

    return (
      lastCallTimeRef.current === undefined ||
      timeSinceLastCall >= delay ||
      timeSinceLastCall < 0 ||
      (maxWait !== undefined && timeSinceLastInvoke >= maxWait)
    );
  }, [delay, maxWait]);

  // We'll use useRef to break the circular dependency
  const timerExpiredRef = useRef<(() => void) | undefined>(undefined);
  
  const trailingEdgeFunc = useCallback(() => {
    timeoutRef.current = undefined;

    if (trailing && lastCallTimeRef.current !== undefined) {
      invokeFunc();
    }

    lastCallTimeRef.current = undefined;
    leadingInvokedRef.current = false; // Reset for next cycle
    return debouncedValue;
  }, [trailing, invokeFunc, debouncedValue]);

  const timerExpired = useCallback(() => {
    const time = Date.now();
    if (shouldInvoke(time)) {
      return trailingEdgeFunc();
    }
    
    const remaining = remainingWait(time);
    timeoutRef.current = setTimeout(() => timerExpiredRef.current?.(), remaining);
    return undefined;
  }, [shouldInvoke, remainingWait, trailingEdgeFunc]);
  
  timerExpiredRef.current = timerExpired;

  const debounced = useCallback(() => {
    const time = Date.now();
    const isInvoking = shouldInvoke(time);

    lastCallTimeRef.current = time;

    if (isInvoking) {
      if (timeoutRef.current === undefined) {
        leadingEdge(lastCallTimeRef.current);
      }
      if (maxWait !== undefined) {
        timeoutRef.current = setTimeout(timerExpired, delay);
        return leadingEdge(lastCallTimeRef.current);
      }
    }

    // Clear existing timeout if any
    if (timeoutRef.current !== undefined) {
      clearTimeout(timeoutRef.current);
      leadingInvokedRef.current = false;
    }

    timeoutRef.current = setTimeout(timerExpired, delay);
  }, [shouldInvoke, leadingEdge, timerExpired, delay, maxWait]);

  // Trigger debounced function when value changes
  useEffect(() => {
    debounced();
  }, [value, debounced]);

  // Set up maxWait timer
  useEffect(() => {
    if (maxWait !== undefined && lastCallTimeRef.current !== undefined) {
      maxTimeoutRef.current = setTimeout(() => {
        if (timeoutRef.current) {
          trailingEdgeFunc();
        }
      }, maxWait);
    }

    return () => {
      if (maxTimeoutRef.current) {
        clearTimeout(maxTimeoutRef.current);
      }
    };
  }, [value, maxWait, trailingEdgeFunc]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
      if (maxTimeoutRef.current) {
        clearTimeout(maxTimeoutRef.current);
      }
    };
  }, []);

  return debouncedValue;
}

/**
 * Enhanced debounce hook with state information and manual controls
 * 
 * @param value - The value to debounce
 * @param delay - The delay in milliseconds
 * @param options - Debounce options
 * @returns Debounced state with controls
 */
export function useAdvancedDebounce<T>(
  value: T,
  delay: number,
  // options?: DebounceOptions
): DebouncedState<T> {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);
  const [isPending, setIsPending] = useState<boolean>(false);
  const timeoutRef = useRef<NodeJS.Timeout | undefined>(undefined);

  const flush = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = undefined;
    }
    setDebouncedValue(value);
    setIsPending(false);
  }, [value]);

  const cancel = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = undefined;
    }
    setIsPending(false);
  }, []);

  useEffect(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    setIsPending(true);

    timeoutRef.current = setTimeout(() => {
      setDebouncedValue(value);
      setIsPending(false);
      timeoutRef.current = undefined;
    }, delay);

    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, [value, delay]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      cancel();
    };
  }, [cancel]);

  return useMemo(() => ({
    value: debouncedValue,
    isPending,
    flush,
    cancel,
  }), [debouncedValue, isPending, flush, cancel]);
}

/**
 * Debounced callback hook for function debouncing
 * 
 * @param callback - The function to debounce
 * @param delay - The delay in milliseconds
 * @param options - Debounce options
 * @returns Debounced callback with controls
 */
export function useDebouncedCallback<TArgs extends unknown[], TReturn>(
  callback: (...args: TArgs) => TReturn,
  delay: number,
  options?: DebounceOptions
): {
  debouncedCallback: (...args: TArgs) => void;
  flush: () => void;
  cancel: () => void;
  isPending: boolean;
} {
  const { leading = false, trailing = true, maxWait } = options || {};
  const [isPending, setIsPending] = useState<boolean>(false);

  const timeoutRef = useRef<NodeJS.Timeout | undefined>(undefined);
  const maxTimeoutRef = useRef<NodeJS.Timeout | undefined>(undefined);
  const argsRef = useRef<TArgs | undefined>(undefined);
  const lastCallTimeRef = useRef<number | undefined>(undefined);
  const lastInvokeTimeRef = useRef<number>(0);

  const invokeFunc = useCallback(() => {
    if (argsRef.current) {
      const result = callback(...argsRef.current);
      lastInvokeTimeRef.current = Date.now();
      setIsPending(false);
      return result;
    }
    return undefined;
  }, [callback]);

  const flush = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = undefined;
    }
    if (maxTimeoutRef.current) {
      clearTimeout(maxTimeoutRef.current);
      maxTimeoutRef.current = undefined;
    }
    
    if (argsRef.current) {
      invokeFunc();
    }
  }, [invokeFunc]);

  const cancel = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = undefined;
    }
    if (maxTimeoutRef.current) {
      clearTimeout(maxTimeoutRef.current);
      maxTimeoutRef.current = undefined;
    }
    
    lastCallTimeRef.current = undefined;
    argsRef.current = undefined;
    setIsPending(false);
  }, []);

  const debouncedCallback = useCallback(
    (...args: TArgs) => {
      const time = Date.now();
      argsRef.current = args;
      lastCallTimeRef.current = time;
      setIsPending(true);

      const timeSinceLastInvoke = time - lastInvokeTimeRef.current;
      const shouldCallLeading = leading && (!timeoutRef.current || timeSinceLastInvoke >= delay);
      
      if (shouldCallLeading) {
        invokeFunc();
        return;
      }

      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }

      timeoutRef.current = setTimeout(() => {
        if (trailing && argsRef.current) {
          invokeFunc();
        }
        timeoutRef.current = undefined;
      }, delay);

      // Handle maxWait
      if (maxWait !== undefined && !maxTimeoutRef.current) {
        maxTimeoutRef.current = setTimeout(() => {
          flush();
        }, maxWait);
      }
    },
    [delay, leading, trailing, maxWait, invokeFunc, flush]
  );

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      cancel();
    };
  }, [cancel]);

  return useMemo(() => ({
    debouncedCallback,
    flush,
    cancel,
    isPending,
  }), [debouncedCallback, flush, cancel, isPending]);
}

/**
 * Simple debounced search hook for common search input scenarios
 * 
 * @example
 * ```typescript
 * const {
 *   searchTerm,
 *   debouncedSearchTerm,
 *   setSearchTerm,
 *   isSearching,
 *   clearSearch,
 * } = useDebouncedSearch('', 300);
 * ```
 */
export function useDebouncedSearch(
  initialValue: string = '',
  delay: number = 300
): {
  searchTerm: string;
  debouncedSearchTerm: string;
  setSearchTerm: (term: string) => void;
  isSearching: boolean;
  clearSearch: () => void;
} {
  const [searchTerm, setSearchTerm] = useState<string>(initialValue);
  const { value: debouncedSearchTerm, isPending } = useAdvancedDebounce(searchTerm, delay);

  const clearSearch = useCallback(() => {
    setSearchTerm('');
  }, []);

  return useMemo(() => ({
    searchTerm,
    debouncedSearchTerm,
    setSearchTerm,
    isSearching: isPending,
    clearSearch,
  }), [searchTerm, debouncedSearchTerm, isPending, clearSearch]);
}
