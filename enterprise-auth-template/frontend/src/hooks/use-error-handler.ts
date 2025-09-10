'use client';

import { useCallback, useState } from 'react';
import { useRouter } from 'next/navigation';
import { ErrorHandler, StandardError, ErrorCategory } from '@/lib/error-handler';
import { useAuthStore } from '@/stores/auth.store';

/**
 * Hook for handling errors consistently across the application
 */
export function useErrorHandler() {
  const [error, setError] = useState<StandardError | null>(null);
  const [isRetrying, setIsRetrying] = useState(false);
  const router = useRouter();
  const { logout } = useAuthStore();

  /**
   * Handle error with appropriate action based on category
   */
  const handleError = useCallback(
    (error: unknown, options?: { showToast?: boolean; context?: Record<string, unknown> }) => {
      const standardError = ErrorHandler.handle(error, options);
      setError(standardError);

      // Handle authentication errors
      if (standardError.category === ErrorCategory.AUTHENTICATION) {
        if (standardError.code === 'TOKEN_EXPIRED' || standardError.code === 'TOKEN_INVALID') {
          // Redirect to login
          logout();
          router.push('/auth/login?expired=true');
        }
      }

      // Handle authorization errors
      if (standardError.category === ErrorCategory.AUTHORIZATION) {
        router.push('/unauthorized');
      }

      return standardError;
    },
    [logout, router]
  );

  /**
   * Clear current error
   */
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  /**
   * Retry a failed operation
   */
  const retry = useCallback(
    async (operation: () => Promise<unknown>) => {
      if (!error?.retryable) return;

      setIsRetrying(true);
      clearError();

      try {
        const result = await operation();
        return result;
      } catch (err) {
        handleError(err);
        throw err;
      } finally {
        setIsRetrying(false);
      }
    },
    [error, clearError, handleError]
  );

  return {
    error,
    isRetrying,
    handleError,
    clearError,
    retry,
  };
}

/**
 * Hook for handling async operations with loading and error states
 */
export function useAsyncOperation<T = unknown>() {
  const [isLoading, setIsLoading] = useState(false);
  const [data, setData] = useState<T | null>(null);
  const { error, handleError, clearError } = useErrorHandler();

  /**
   * Execute an async operation with error handling
   */
  const execute = useCallback(
    async (
      operation: () => Promise<T>,
      options?: {
        onSuccess?: (data: T) => void;
        onError?: (error: StandardError) => void;
        showToast?: boolean;
      }
    ) => {
      setIsLoading(true);
      clearError();

      try {
        const result = await operation();
        setData(result);
        
        if (options?.onSuccess) {
          options.onSuccess(result);
        }
        
        return result;
      } catch (err) {
        const standardError = handleError(err, { showToast: options?.showToast ?? true });
        
        if (options?.onError) {
          options.onError(standardError);
        }
        
        throw standardError;
      } finally {
        setIsLoading(false);
      }
    },
    [clearError, handleError]
  );

  /**
   * Reset the state
   */
  const reset = useCallback(() => {
    setData(null);
    clearError();
    setIsLoading(false);
  }, [clearError]);

  return {
    isLoading,
    data,
    error,
    execute,
    reset,
  };
}

/**
 * Hook for handling form errors with field-level validation
 */
export function useFormErrorHandler() {
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const { error, handleError, clearError } = useErrorHandler();

  /**
   * Handle form submission error
   */
  const handleFormError = useCallback(
    (error: unknown) => {
      const standardError = handleError(error, { showToast: false });

      // Extract field-level errors if available
      if (standardError.details?.['fields']) {
        setFieldErrors(standardError.details['fields'] as Record<string, string>);
      } else if (standardError.field) {
        setFieldErrors({ [standardError.field]: standardError.message });
      }

      return standardError;
    },
    [handleError]
  );

  /**
   * Clear field error
   */
  const clearFieldError = useCallback((field: string) => {
    setFieldErrors((prev) => {
      const next = { ...prev };
      delete next[field];
      return next;
    });
  }, []);

  /**
   * Clear all errors
   */
  const clearAllErrors = useCallback(() => {
    setFieldErrors({});
    clearError();
  }, [clearError]);

  /**
   * Get error for specific field
   */
  const getFieldError = useCallback(
    (field: string) => {
      return fieldErrors[field] || null;
    },
    [fieldErrors]
  );

  return {
    error,
    fieldErrors,
    handleFormError,
    clearFieldError,
    clearAllErrors,
    getFieldError,
  };
}

/**
 * Hook for handling API mutations with optimistic updates
 */
export function useMutation<TData = unknown, TVariables = unknown>({
  mutationFn,
  onSuccess,
  onError,
  optimisticUpdate,
}: {
  mutationFn: (variables: TVariables) => Promise<TData>;
  onSuccess?: (data: TData, variables: TVariables) => void;
  onError?: (error: StandardError, variables: TVariables) => void;
  optimisticUpdate?: (variables: TVariables) => void;
}) {
  const [isLoading, setIsLoading] = useState(false);
  const { error, handleError, clearError } = useErrorHandler();

  const mutate = useCallback(
    async (variables: TVariables) => {
      setIsLoading(true);
      clearError();

      // Apply optimistic update if provided
      if (optimisticUpdate) {
        optimisticUpdate(variables);
      }

      try {
        const result = await mutationFn(variables);
        
        if (onSuccess) {
          onSuccess(result, variables);
        }
        
        return result;
      } catch (err) {
        const standardError = handleError(err);
        
        if (onError) {
          onError(standardError, variables);
        }
        
        // Revert optimistic update on error
        // This would require a rollback function to be implemented
        
        throw standardError;
      } finally {
        setIsLoading(false);
      }
    },
    [mutationFn, onSuccess, onError, optimisticUpdate, clearError, handleError]
  );

  return {
    mutate,
    isLoading,
    error,
    reset: clearError,
  };
}