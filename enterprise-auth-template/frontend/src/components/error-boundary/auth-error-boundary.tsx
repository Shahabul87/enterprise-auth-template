'use client';

import React, { Component, ErrorInfo, ReactNode } from 'react';
import { AlertCircle, RefreshCw, Home, LogOut } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
}

interface State {
  hasError: boolean;
  error: Error | null;
  errorInfo: ErrorInfo | null;
  errorCount: number;
}

export class AuthErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
      errorCount: 0,
    };
  }

  static getDerivedStateFromError(error: Error): State {
    return {
      hasError: true,
      error,
      errorInfo: null,
      errorCount: 0,
    };
  }

  override componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // Log error to console in development
    if (process.env.NODE_ENV === 'development') {
      
    }

    // Call optional error handler
    if (this.props.onError) {
      this.props.onError(error, errorInfo);
    }

    // Update state with error info
    this.setState((prevState) => ({
      errorInfo,
      errorCount: prevState.errorCount + 1,
    }));

    // Log to error reporting service in production
    if (process.env.NODE_ENV === 'production') {
      this.logErrorToService(error, errorInfo);
    }
  }

  logErrorToService = (_error: Error, _errorInfo: ErrorInfo) => { // eslint-disable-line @typescript-eslint/no-unused-vars
    // Implement error logging to service like Sentry, LogRocket, etc.
    // Example:
    // errorReportingService.log({
    //   error: error.toString(),
    //   stack: error.stack,
    //   componentStack: errorInfo.componentStack,
    //   timestamp: new Date().toISOString(),
    //   userAgent: navigator.userAgent,
    //   url: window.location.href,
    // });
  };

  handleReset = () => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
      errorCount: 0,
    });
  };

  handleReload = () => {
    window.location.reload();
  };

  handleGoHome = () => {
    window.location.href = '/';
  };

  handleLogout = () => {
    // Clear auth data and redirect to login
    if (typeof window !== 'undefined') {
      // Clear all auth-related storage
      localStorage.clear();
      sessionStorage.clear();
      
      // Clear cookies
      document.cookie.split(';').forEach((c) => {
        document.cookie = c
          .replace(/^ +/, '')
          .replace(/=.*/, '=;expires=' + new Date().toUTCString() + ';path=/');
      });
      
      // Redirect to login
      window.location.href = '/auth/login';
    }
  };

  isAuthError = (error: Error): boolean => {
    const authErrorPatterns = [
      /unauthorized/i,
      /forbidden/i,
      /auth/i,
      /token/i,
      /session/i,
      /permission/i,
      /401/,
      /403/,
    ];

    const errorString = error.toString() + (error.stack || '');
    return authErrorPatterns.some((pattern) => pattern.test(errorString));
  };

  override render() {
    if (this.state.hasError && this.state.error) {
      // Use custom fallback if provided
      if (this.props.fallback) {
        return <>{this.props.fallback}</>;
      }

      const isAuthRelated = this.isAuthError(this.state.error);
      const isDevelopment = process.env.NODE_ENV === 'development';

      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900 p-4">
          <Card className="max-w-2xl w-full">
            <CardHeader>
              <div className="flex items-center space-x-2">
                <AlertCircle className="h-6 w-6 text-red-500" />
                <CardTitle className="text-2xl">
                  {isAuthRelated ? 'Authentication Error' : 'Application Error'}
                </CardTitle>
              </div>
              <CardDescription>
                {isAuthRelated
                  ? 'There was a problem with authentication. Please try logging in again.'
                  : 'Something went wrong. Please try refreshing the page or contact support if the problem persists.'}
              </CardDescription>
            </CardHeader>

            <CardContent className="space-y-4">
              {/* Error message */}
              <Alert variant="destructive">
                <AlertCircle className="h-4 w-4" />
                <AlertTitle>Error Details</AlertTitle>
                <AlertDescription>
                  {this.state.error.message || 'An unexpected error occurred'}
                </AlertDescription>
              </Alert>

              {/* Development mode: Show stack trace */}
              {isDevelopment && this.state.errorInfo && (
                <div className="space-y-2">
                  <h3 className="text-sm font-semibold text-gray-700 dark:text-gray-300">
                    Stack Trace (Development Only)
                  </h3>
                  <pre className="text-xs bg-gray-100 dark:bg-gray-800 p-3 rounded overflow-auto max-h-64">
                    {this.state.error.stack}
                  </pre>
                  <pre className="text-xs bg-gray-100 dark:bg-gray-800 p-3 rounded overflow-auto max-h-64">
                    {this.state.errorInfo.componentStack}
                  </pre>
                </div>
              )}

              {/* Error metadata */}
              {this.state.errorCount > 1 && (
                <Alert>
                  <AlertDescription>
                    This error has occurred {this.state.errorCount} times.
                  </AlertDescription>
                </Alert>
              )}

              {/* Action buttons */}
              <div className="flex flex-wrap gap-2">
                {isAuthRelated ? (
                  <>
                    <Button onClick={this.handleLogout} variant="default">
                      <LogOut className="mr-2 h-4 w-4" />
                      Sign Out & Sign In Again
                    </Button>
                    <Button onClick={this.handleReset} variant="outline">
                      Try Again
                    </Button>
                  </>
                ) : (
                  <>
                    <Button onClick={this.handleReload} variant="default">
                      <RefreshCw className="mr-2 h-4 w-4" />
                      Reload Page
                    </Button>
                    <Button onClick={this.handleReset} variant="outline">
                      Try Again
                    </Button>
                  </>
                )}
                <Button onClick={this.handleGoHome} variant="outline">
                  <Home className="mr-2 h-4 w-4" />
                  Go to Home
                </Button>
              </div>

              {/* Support information */}
              <div className="mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  If this problem persists, please contact support with the following information:
                </p>
                <div className="mt-2 p-3 bg-gray-100 dark:bg-gray-800 rounded text-xs font-mono">
                  <div>Error: {this.state.error.name}</div>
                  <div>Time: {new Date().toISOString()}</div>
                  <div>URL: {typeof window !== 'undefined' ? window.location.href : 'N/A'}</div>
                  {isAuthRelated && <div>Type: Authentication Error</div>}
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      );
    }

    return this.props.children;
  }
}

// Error boundary specifically for auth-related errors with simpler UI
export function SimpleAuthErrorBoundary({ children }: { children: ReactNode }) {
  return (
    <AuthErrorBoundary
      fallback={
        <div className="min-h-screen flex items-center justify-center p-4">
          <div className="text-center">
            <h1 className="text-2xl font-bold mb-4">Authentication Required</h1>
            <p className="mb-4">Please sign in to continue.</p>
            <Button onClick={() => (window.location.href = '/auth/login')}>
              Go to Login
            </Button>
          </div>
        </div>
      }
    >
      {children}
    </AuthErrorBoundary>
  );
}