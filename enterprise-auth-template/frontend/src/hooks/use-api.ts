'use client';

import { useState, useCallback, useRef, useEffect } from 'react';
import { ApiResponse, ApiError, RequestOptions, HttpMethod } from '@/types/api.types';

/**
 * Generic API hook with comprehensive error handling and loading states
 * 
 * Provides a flexible interface for making HTTP requests with built-in:
 * - Loading states
 * - Error handling and retry logic
 * - Request cancellation
 * - Response caching
 * - TypeScript type safety
 * 
 * @example
 * ```typescript
 * // Basic usage
 * const { execute, data, loading, error } = useApi<User>();
 * 
 * const handleSubmit = async (userData: CreateUserRequest) => {
 *   const result = await execute('/api/users', {
 *     method: 'POST',
 *     data: userData
 *   });
 *   if (result.success) {
 *     
 *   }
 * };
 * 
 * // With retry and cancellation
 * const { execute, cancel, retry } = useApi<ApiResponse<User[]>>({
 *   retryAttempts: 3,
 *   retryDelay: 1000,
 * });
 * ```
 */

export interface ApiHookConfig {
  /** Base URL for API requests */
  baseURL?: string;
  /** Default headers for all requests */
  defaultHeaders?: Record<string, string>;
  /** Number of retry attempts on failure */
  retryAttempts?: number;
  /** Delay between retry attempts (ms) */
  retryDelay?: number;
  /** Request timeout (ms) */
  timeout?: number;
  /** Whether to cache successful responses */
  enableCaching?: boolean;
  /** Cache duration (ms) */
  cacheDuration?: number;
  /** Custom error handler */
  onError?: (error: ApiError) => void;
  /** Custom success handler */
  onSuccess?: <T>(data: T) => void;
}

export interface ApiRequestConfig extends RequestOptions {
  /** HTTP method */
  method?: HttpMethod;
  /** Request body data */
  data?: unknown;
  /** Whether to include credentials (cookies) */
  withCredentials?: boolean;
  /** Skip loading state for this request */
  skipLoading?: boolean;
  /** Custom retry configuration for this request */
  retryConfig?: {
    attempts?: number;
    delay?: number;
  };
}

export interface ApiState<T = unknown> {
  /** Response data */
  data: T | null;
  /** Loading state */
  loading: boolean;
  /** Error state */
  error: ApiError | null;
  /** Whether request was successful */
  success: boolean;
  /** Response status code */
  status: number | null;
  /** Whether retry is in progress */
  retrying: boolean;
  /** Current retry attempt */
  retryCount: number;
}

export interface ApiActions<T = unknown> {
  /** Execute API request */
  execute: (url: string, config?: ApiRequestConfig) => Promise<ApiResponse<T>>;
  /** Cancel current request */
  cancel: () => void;
  /** Retry last failed request */
  retry: () => Promise<ApiResponse<T> | null>;
  /** Reset state to initial values */
  reset: () => void;
  /** Clear error state */
  clearError: () => void;
  /** Update data manually */
  setData: (data: T | null) => void;
}

export interface UseApiReturn<T = unknown> extends ApiState<T>, ApiActions<T> {}

// Simple cache implementation
const cache = new Map<string, { data: unknown; timestamp: number; duration: number }>();

const getCacheKey = (url: string, config?: ApiRequestConfig): string => {
  return `${config?.method || 'GET'}:${url}:${JSON.stringify(config?.data || {})}`;
};

const getFromCache = <T>(key: string): T | null => {
  const cached = cache.get(key);
  if (!cached) return null;
  
  if (Date.now() - cached.timestamp > cached.duration) {
    cache.delete(key);
    return null;
  }
  
  return cached.data as T;
};

const setCache = (key: string, data: unknown, duration: number): void => {
  cache.set(key, {
    data,
    timestamp: Date.now(),
    duration,
  });
};

export function useApi<T = unknown>(config: ApiHookConfig = {}): UseApiReturn<T> {
  const {
    baseURL = '',
    defaultHeaders = {},
    retryAttempts = 0,
    retryDelay = 1000,
    timeout = 10000,
    enableCaching = false,
    cacheDuration = 300000, // 5 minutes
    onError,
    onSuccess,
  } = config;

  const [state, setState] = useState<ApiState<T>>({
    data: null,
    loading: false,
    error: null,
    success: false,
    status: null,
    retrying: false,
    retryCount: 0,
  });

  const abortControllerRef = useRef<AbortController | null>(null);
  const lastRequestRef = useRef<{ url: string; config?: ApiRequestConfig } | null>(null);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
      }
    };
  }, []);

  const updateState = useCallback((updates: Partial<ApiState<T>>) => {
    setState(prev => ({ ...prev, ...updates }));
  }, []);

  const makeRequest = useCallback(
    async <TResponse = T>(
      url: string,
      requestConfig: ApiRequestConfig = {},
      isRetry = false
    ): Promise<ApiResponse<TResponse>> => {
      const {
        method = 'GET',
        data,
        headers = {},
        params,
        timeout: requestTimeout = timeout,
        withCredentials = true,
        skipLoading = false,
        signal,
      } = requestConfig;

      // Cancel previous request
      if (abortControllerRef.current && !abortControllerRef.current.signal.aborted) {
        abortControllerRef.current.abort();
      }

      // Create new abort controller
      const controller = new AbortController();
      abortControllerRef.current = controller;

      // Check cache first for GET requests
      if (enableCaching && method === 'GET') {
        const cacheKey = getCacheKey(url, requestConfig);
        const cachedData = getFromCache<TResponse>(cacheKey);
        if (cachedData) {
          const response: ApiResponse<TResponse> = {
            success: true,
            data: cachedData,
          };
          
          updateState({
            data: cachedData as T,
            loading: false,
            error: null,
            success: true,
            status: 200,
            retrying: false,
          });

          if (onSuccess) {
            onSuccess(cachedData);
          }

          return response;
        }
      }

      // Update loading state
      if (!skipLoading) {
        updateState({
          loading: true,
          error: null,
          retrying: isRetry,
        });
      }

      try {
        const fullUrl = `${baseURL}${url}`;
        const requestHeaders = {
          'Content-Type': 'application/json',
          ...defaultHeaders,
          ...headers,
        };

        // Build request options
        const fetchOptions: RequestInit = {
          method,
          headers: requestHeaders,
          signal: signal || controller.signal,
          credentials: withCredentials ? 'include' : 'omit',
        };

        // Add body for non-GET requests
        if (data && method !== 'GET') {
          fetchOptions.body = JSON.stringify(data);
        }

        // Add query parameters
        let requestUrl = fullUrl;
        if (params && Object.keys(params).length > 0) {
          const searchParams = new URLSearchParams();
          Object.entries(params).forEach(([key, value]) => {
            if (value !== undefined && value !== null) {
              searchParams.append(key, String(value));
            }
          });
          requestUrl += `?${searchParams.toString()}`;
        }

        // Set timeout
        const timeoutId = setTimeout(() => {
          controller.abort();
        }, requestTimeout);

        const response = await fetch(requestUrl, fetchOptions);
        clearTimeout(timeoutId);

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          const apiError: ApiError = {
            code: `HTTP_${response.status}`,
            message: errorData.message || response.statusText || 'Request failed',
            details: errorData.details || { status: response.status, url: requestUrl },
          };

          throw apiError;
        }

        const responseData: ApiResponse<TResponse> = await response.json();

        // Cache successful GET responses
        if (enableCaching && method === 'GET' && responseData.success && responseData.data) {
          const cacheKey = getCacheKey(url, requestConfig);
          setCache(cacheKey, responseData.data, cacheDuration);
        }

        updateState({
          data: responseData.data as T,
          loading: false,
          error: null,
          success: responseData.success,
          status: response.status,
          retrying: false,
          retryCount: 0,
        });

        if (onSuccess && responseData.data) {
          onSuccess(responseData.data);
        }

        return responseData;

      } catch (err) {
        // Handle abort errors
        if (err instanceof Error && err.name === 'AbortError') {
          return {
            success: false,
            error: {
              code: 'REQUEST_CANCELLED',
              message: 'Request was cancelled',
            },
          };
        }

        const apiError: ApiError = err instanceof Error && 'code' in err 
          ? err as ApiError
          : {
              code: 'NETWORK_ERROR',
              message: err instanceof Error ? err.message : 'Network request failed',
              details: { url, method },
            };

        updateState({
          loading: false,
          error: apiError,
          success: false,
          retrying: false,
        });

        if (onError) {
          onError(apiError);
        }

        return {
          success: false,
          error: apiError,
        };
      }
    },
    [baseURL, defaultHeaders, timeout, enableCaching, cacheDuration, onError, onSuccess, updateState]
  );

  const executeWithRetry = useCallback(
    async <TResponse = T>(
      url: string,
      requestConfig: ApiRequestConfig = {},
      attemptNumber = 0
    ): Promise<ApiResponse<TResponse>> => {
      const result = await makeRequest<TResponse>(url, requestConfig, attemptNumber > 0);

      if (!result.success && attemptNumber < (requestConfig.retryConfig?.attempts || retryAttempts)) {
        updateState({ retryCount: attemptNumber + 1 });
        
        await new Promise(resolve => 
          setTimeout(resolve, requestConfig.retryConfig?.delay || retryDelay)
        );
        
        return executeWithRetry<TResponse>(url, requestConfig, attemptNumber + 1);
      }

      return result;
    },
    [makeRequest, retryAttempts, retryDelay, updateState]
  );

  const execute = useCallback(
    async (url: string, requestConfig?: ApiRequestConfig): Promise<ApiResponse<T>> => {
      lastRequestRef.current = {
        url,
        ...(requestConfig ? { config: requestConfig } : {}),
      };
      return executeWithRetry<T>(url, requestConfig);
    },
    [executeWithRetry]
  );

  const cancel = useCallback(() => {
    if (abortControllerRef.current) {
      abortControllerRef.current.abort();
      updateState({
        loading: false,
        retrying: false,
      });
    }
  }, [updateState]);

  const retry = useCallback(async (): Promise<ApiResponse<T> | null> => {
    if (!lastRequestRef.current) return null;
    
    const { url, config } = lastRequestRef.current;
    return execute(url, config);
  }, [execute]);

  const reset = useCallback(() => {
    setState({
      data: null,
      loading: false,
      error: null,
      success: false,
      status: null,
      retrying: false,
      retryCount: 0,
    });
    lastRequestRef.current = null;
  }, []);

  const clearError = useCallback(() => {
    updateState({ error: null });
  }, [updateState]);

  const setData = useCallback((data: T | null) => {
    updateState({ data });
  }, [updateState]);

  return {
    ...state,
    execute,
    cancel,
    retry,
    reset,
    clearError,
    setData,
  };
}

/**
 * Simplified API hook for quick HTTP requests
 * 
 * @example
 * ```typescript
 * const fetchUsers = useApiCall<User[]>();
 * 
 * const loadUsers = async () => {
 *   const users = await fetchUsers('/api/users');
 *   if (users) {
 *     setUsersList(users);
 *   }
 * };
 * ```
 */
export function useApiCall<T = unknown>(config: ApiHookConfig = {}) {
  const { execute } = useApi<T>(config);

  return useCallback(
    async (url: string, requestConfig?: ApiRequestConfig): Promise<T | null> => {
      const result = await execute(url, requestConfig);
      return result.success ? result.data || null : null;
    },
    [execute]
  );
}