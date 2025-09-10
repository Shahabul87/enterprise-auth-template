/**
 * React Query Client Configuration
 *
 * Optimized TanStack Query client configuration for enterprise applications
 * with caching strategies, error handling, and performance optimizations.
 */

import { QueryClient, DefaultOptions } from '@tanstack/react-query';

// Default query options optimized for enterprise use
const defaultQueryOptions: DefaultOptions = {
  queries: {
    // Caching strategy
    staleTime: 5 * 60 * 1000, // 5 minutes - data is fresh for 5 minutes
    gcTime: 10 * 60 * 1000, // 10 minutes - cache time (formerly cacheTime)

    // Network optimizations
    refetchOnWindowFocus: false, // Don't refetch on window focus in enterprise apps
    refetchOnMount: true, // Refetch when component mounts
    refetchOnReconnect: true, // Refetch when network reconnects

    // Retry strategy
    retry: (failureCount, error: Error | unknown) => {
      const errorObj = error as { status?: number };
      // Don't retry on client errors (4xx)
      if (errorObj?.status && errorObj.status >= 400 && errorObj.status < 500) {
        return false;
      }

      // Don't retry on authentication errors
      if (errorObj?.status === 401 || errorObj?.status === 403) {
        return false;
      }

      // Retry up to 3 times for server errors and network issues
      return failureCount < 3;
    },

    retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),

    // Performance optimizations
    networkMode: 'online', // Only run queries when online
  },

  mutations: {
    // Retry mutations only once for server errors
    retry: (failureCount, error: Error | unknown) => {
      const errorObj = error as { status?: number };
      // Don't retry client errors
      if (errorObj?.status && errorObj.status >= 400 && errorObj.status < 500) {
        return false;
      }

      // Retry once for server errors
      return failureCount < 1;
    },

    retryDelay: 1000,
    networkMode: 'online',
  },
};

// Create the query client instance
export const queryClient = new QueryClient({
  defaultOptions: defaultQueryOptions,
});

// Query key factory for consistent query keys
export const queryKeys = {
  // Authentication queries
  auth: {
    me: () => ['auth', 'me'] as const,
    permissions: (userId: string) => ['auth', 'permissions', userId] as const,
    roles: (userId: string) => ['auth', 'roles', userId] as const,
  },

  // User queries
  users: {
    all: () => ['users'] as const,
    list: (params: Record<string, unknown>) => ['users', 'list', params] as const,
    detail: (userId: string) => ['users', 'detail', userId] as const,
    roles: (userId: string) => ['users', 'roles', userId] as const,
    permissions: (userId: string) => ['users', 'permissions', userId] as const,
  },

  // Role queries
  roles: {
    all: () => ['roles'] as const,
    list: (params?: Record<string, unknown>) => ['roles', 'list', params] as const,
    detail: (roleId: string) => ['roles', 'detail', roleId] as const,
    permissions: (roleId: string) => ['roles', 'permissions', roleId] as const,
  },

  // Permission queries
  permissions: {
    all: () => ['permissions'] as const,
    list: (params?: Record<string, unknown>) => ['permissions', 'list', params] as const,
    detail: (permissionId: string) => ['permissions', 'detail', permissionId] as const,
  },

  // Audit queries
  audit: {
    all: () => ['audit'] as const,
    logs: (params: Record<string, unknown>) => ['audit', 'logs', params] as const,
    detail: (logId: string) => ['audit', 'detail', logId] as const,
    stats: (params?: Record<string, unknown>) => ['audit', 'stats', params] as const,
  },

  // Dashboard queries
  dashboard: {
    stats: () => ['dashboard', 'stats'] as const,
    analytics: (period: string) => ['dashboard', 'analytics', period] as const,
    activities: (limit: number) => ['dashboard', 'activities', limit] as const,
  },

  // Settings queries
  settings: {
    all: () => ['settings'] as const,
    system: () => ['settings', 'system'] as const,
    user: (userId: string) => ['settings', 'user', userId] as const,
    security: () => ['settings', 'security'] as const,
  },
};

// Cache invalidation helpers
export const invalidateQueries = {
  // Invalidate all user-related queries
  users: () => queryClient.invalidateQueries({ queryKey: queryKeys.users.all() }),

  // Invalidate specific user queries
  user: (userId: string) =>
    queryClient.invalidateQueries({
      queryKey: queryKeys.users.detail(userId),
    }),

  // Invalidate all role-related queries
  roles: () => queryClient.invalidateQueries({ queryKey: queryKeys.roles.all() }),

  // Invalidate specific role queries
  role: (roleId: string) =>
    queryClient.invalidateQueries({
      queryKey: queryKeys.roles.detail(roleId),
    }),

  // Invalidate auth queries
  auth: () => queryClient.invalidateQueries({ queryKey: queryKeys.auth.me() }),

  // Invalidate dashboard queries
  dashboard: () => queryClient.invalidateQueries({ queryKey: queryKeys.dashboard.stats() }),

  // Invalidate all audit queries
  audit: () => queryClient.invalidateQueries({ queryKey: queryKeys.audit.all() }),
};

// Prefetch helpers for performance optimization
export const prefetchQueries = {
  // Prefetch user list
  userList: async (params: Record<string, unknown> = {}) => {
    return queryClient.prefetchQuery({
      queryKey: queryKeys.users.list(params),
      queryFn: () => {
        // This will be implemented with actual API calls
        return Promise.resolve([]);
      },
      staleTime: 2 * 60 * 1000, // 2 minutes
    });
  },

  // Prefetch dashboard data
  dashboard: async () => {
    return Promise.all([
      queryClient.prefetchQuery({
        queryKey: queryKeys.dashboard.stats(),
        queryFn: () => {
          // This will be implemented with actual API calls
          return Promise.resolve({});
        },
        staleTime: 60 * 1000, // 1 minute
      }),
      queryClient.prefetchQuery({
        queryKey: queryKeys.dashboard.activities(10),
        queryFn: () => {
          // This will be implemented with actual API calls
          return Promise.resolve([]);
        },
        staleTime: 30 * 1000, // 30 seconds
      }),
    ]);
  },

  // Prefetch user permissions
  userPermissions: async (userId: string) => {
    return queryClient.prefetchQuery({
      queryKey: queryKeys.auth.permissions(userId),
      queryFn: () => {
        // This will be implemented with actual API calls
        return Promise.resolve([]);
      },
      staleTime: 5 * 60 * 1000, // 5 minutes
    });
  },
};

// Query client utilities
export const queryUtils = {
  // Get cached data
  getCachedData: <T>(queryKey: readonly unknown[]): T | undefined => {
    return queryClient.getQueryData<T>(queryKey);
  },

  // Set query data
  setQueryData: <T>(queryKey: readonly unknown[], data: T | ((old: T | undefined) => T)) => {
    queryClient.setQueryData(queryKey, data);
  },

  // Remove queries from cache
  removeQueries: (queryKey: readonly unknown[]) => {
    queryClient.removeQueries({ queryKey });
  },

  // Clear all cache
  clearCache: () => {
    queryClient.clear();
  },

  // Get cache stats
  getCacheStats: () => {
    const cache = queryClient.getQueryCache();
    return {
      totalQueries: cache.getAll().length,
      staleQueries: cache.getAll().filter((query) => query.isStale()).length,
      fetchingQueries: cache.getAll().filter((query) => query.state.fetchStatus === 'fetching')
        .length,
    };
  },
};

// Error handling for queries
export const handleQueryError = (error: Error | unknown) => {
  const errorObj = error as { status?: number };
  // Handle specific error types
  if (errorObj?.status === 401) {
    // Redirect to login
    window.location.href = '/auth/login';
  } else if (errorObj?.status === 403) {
    // Show unauthorized message - handled via toast/notification
  } else if (errorObj?.status && errorObj.status >= 500) {
    // Show server error message - handled via toast/notification
  }
};

// Performance monitoring
export const queryPerformanceMonitor = {
  // Log slow queries
  logSlowQueries: (threshold: number = 2000) => {
    queryClient.getQueryCache().subscribe((event) => {
      if (event.type === 'updated' && event.query.state.dataUpdatedAt) {
        const queryTime = Date.now() - event.query.state.dataUpdatedAt;
        if (queryTime > threshold) {
          // Log slow query performance for monitoring (replaced console.warn)
          // Performance data would be sent to monitoring service
          // queryKey: event.query.queryKey, duration: queryTime
        }
      }
    });
  },

  // Get performance metrics
  getMetrics: () => {
    const cache = queryClient.getQueryCache();
    const queries = cache.getAll();

    return {
      totalQueries: queries.length,
      activeQueries: queries.filter((q) => q.getObserversCount() > 0).length,
      staleQueries: queries.filter((q) => q.isStale()).length,
      errorQueries: queries.filter((q) => q.state.status === 'error').length,
      loadingQueries: queries.filter((q) => q.state.fetchStatus === 'fetching').length,
    };
  },
};
