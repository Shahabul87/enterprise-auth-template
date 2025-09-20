/**
 * React Query Provider
 * 
 * Provides TanStack Query client to the application with dev tools,
 * error boundaries, and performance monitoring.
 */

'use client';

import React, { useState } from 'react';
import { QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { 
  queryClient, 
  queryPerformanceMonitor,
  handleQueryError 
} from '@/lib/api/react-query-client';

interface QueryProviderProps {
  children: React.ReactNode;
}

export function QueryProvider({ children }: QueryProviderProps): React.ReactElement {
  // Initialize performance monitoring once
  React.useEffect(() => {
    // Start performance monitoring in development
    if (process.env.NODE_ENV === 'development') {
      queryPerformanceMonitor.logSlowQueries(1000); // 1 second threshold
    }
  }, []);

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      {/* Show React Query DevTools only in development */}
      {process.env.NODE_ENV === 'development' && (
        <ReactQueryDevtools 
          initialIsOpen={false}
        />
      )}
    </QueryClientProvider>
  );
}

/**
 * Query Error Boundary
 * 
 * Catches and handles query errors at the component level
 */
interface QueryErrorBoundaryState {
  hasError: boolean;
  error?: Error;
}

export class QueryErrorBoundary extends React.Component<
  React.PropsWithChildren<{}>,
  QueryErrorBoundaryState
> {
  constructor(props: React.PropsWithChildren<{}>) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): QueryErrorBoundaryState {
    return { hasError: true, error };
  }

  override componentDidCatch(error: Error, _unusedErrorInfo: React.ErrorInfo) {
    // Log error to monitoring service
    handleQueryError(error);
    
    // Error details available in _errorInfo for debugging
    // Development errors will be handled by the monitoring service
  }

  override render() {
    if (this.state.hasError) {
      return (
        <div className="p-6 text-center">
          <h2 className="text-lg font-semibold text-destructive mb-2">
            Something went wrong
          </h2>
          <p className="text-muted-foreground mb-4">
            {this.state.error?.message || 'An unexpected error occurred'}
          </p>
          <button
            onClick={() => this.setState({ hasError: false })}
            className="px-4 py-2 bg-primary text-primary-foreground rounded hover:bg-primary/90"
          >
            Try again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

/**
 * Query Status Monitor Hook
 * 
 * Hook for monitoring query performance and cache statistics
 */
export const useQueryMonitor = () => {
  const [stats, setStats] = useState({
    totalQueries: 0,
    activeQueries: 0,
    staleQueries: 0,
    errorQueries: 0,
    loadingQueries: 0,
  });

  React.useEffect(() => {
    const updateStats = () => {
      const newStats = queryPerformanceMonitor.getMetrics();
      setStats(newStats);
    };

    // Update stats every 5 seconds in development
    if (process.env.NODE_ENV === 'development') {
      const interval = setInterval(updateStats, 5000);
      updateStats(); // Initial update
      return () => clearInterval(interval);
    }
    
    return undefined;
  }, []);

  return stats;
};

/**
 * Query Health Check Component
 * 
 * Displays query health statistics in development
 */
export const QueryHealthCheck: React.FC = () => {
  const stats = useQueryMonitor();

  if (process.env.NODE_ENV !== 'development') {
    return null;
  }

  return (
    <div className="fixed bottom-4 left-4 bg-background border rounded-lg p-3 text-xs shadow-lg">
      <h4 className="font-semibold mb-2">Query Stats</h4>
      <div className="space-y-1">
        <div>Total: {stats.totalQueries}</div>
        <div>Active: {stats.activeQueries}</div>
        <div>Stale: {stats.staleQueries}</div>
        <div className={stats.errorQueries > 0 ? 'text-destructive' : ''}>
          Errors: {stats.errorQueries}
        </div>
        <div>Loading: {stats.loadingQueries}</div>
      </div>
    </div>
  );
};