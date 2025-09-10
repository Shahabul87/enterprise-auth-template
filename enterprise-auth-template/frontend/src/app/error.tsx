'use client';

import React, { useEffect } from 'react';
import { AlertCircle, RefreshCw, Home, Bug, ArrowLeft } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';
import { getInstrumentation } from '@/instrumentation';
import { useRouter } from 'next/navigation';

interface ErrorPageProps {
  error: Error & { digest?: string };
  reset: () => void;
}

/**
 * Global Error Boundary Component for Next.js App Router
 *
 * This component catches unhandled errors in the application and provides
 * a user-friendly error page with recovery options.
 *
 * @see https://nextjs.org/docs/app/building-your-application/routing/error-handling
 */
export default function ErrorPage({ error, reset }: ErrorPageProps): JSX.Element {
  const router = useRouter();
  const isDevelopment = process.env.NODE_ENV === 'development';

  useEffect(() => {
    // Track the error in our instrumentation system
    const instrumentation = getInstrumentation();
    instrumentation.trackError({
      message: error.message,
      ...(error.stack ? { stack: error.stack } : {}),
      type: 'app_error',
      filename: 'app-error-boundary',
    });

    // Error is tracked via instrumentation above
    // Additional logging removed to avoid console warnings
  }, [error]);

  const getErrorType = (
    error: Error
  ): 'network' | 'auth' | 'validation' | 'server' | 'client' | 'unknown' => {
    const errorString = error.toString().toLowerCase();
    const stackString = (error.stack || '').toLowerCase();

    if (errorString.includes('network') || errorString.includes('fetch')) return 'network';
    if (
      errorString.includes('auth') ||
      errorString.includes('unauthorized') ||
      errorString.includes('forbidden')
    )
      return 'auth';
    if (errorString.includes('validation') || errorString.includes('invalid')) return 'validation';
    if (
      errorString.includes('server') ||
      errorString.includes('500') ||
      errorString.includes('502') ||
      errorString.includes('503')
    )
      return 'server';
    if (stackString.includes('client') || errorString.includes('hydration')) return 'client';

    return 'unknown';
  };

  const errorType = getErrorType(error);

  const getErrorMessage = (
    type: typeof errorType
  ): { title: string; description: string; icon: React.ReactNode } => {
    const iconProps = { className: 'h-6 w-6' };

    switch (type) {
      case 'network':
        return {
          title: 'Network Connection Error',
          description:
            'Unable to connect to our servers. Please check your internet connection and try again.',
          icon: <AlertCircle {...iconProps} className='h-6 w-6 text-orange-500' />,
        };
      case 'auth':
        return {
          title: 'Authentication Error',
          description: 'There was a problem with your authentication. Please sign in again.',
          icon: <AlertCircle {...iconProps} className='h-6 w-6 text-red-500' />,
        };
      case 'validation':
        return {
          title: 'Validation Error',
          description: 'The data provided is invalid. Please check your input and try again.',
          icon: <AlertCircle {...iconProps} className='h-6 w-6 text-yellow-500' />,
        };
      case 'server':
        return {
          title: 'Server Error',
          description:
            'Our servers are experiencing issues. Our team has been notified and is working on a fix.',
          icon: <AlertCircle {...iconProps} className='h-6 w-6 text-red-500' />,
        };
      case 'client':
        return {
          title: 'Application Error',
          description: 'Something went wrong in the application. This might be a temporary issue.',
          icon: <Bug {...iconProps} className='h-6 w-6 text-purple-500' />,
        };
      default:
        return {
          title: 'Unexpected Error',
          description:
            'An unexpected error occurred. Please try again or contact support if the problem persists.',
          icon: <AlertCircle {...iconProps} className='h-6 w-6 text-gray-500' />,
        };
    }
  };

  const errorInfo = getErrorMessage(errorType);

  const handleReset = () => {
    // Track recovery attempt
    getInstrumentation().trackTelemetry({
      event: 'error_recovery_attempt',
      properties: {
        errorType,
        recoveryMethod: 'reset',
        errorMessage: error.message,
      },
    });

    reset();
  };

  const handleReload = () => {
    // Track recovery attempt
    getInstrumentation().trackTelemetry({
      event: 'error_recovery_attempt',
      properties: {
        errorType,
        recoveryMethod: 'reload',
        errorMessage: error.message,
      },
    });

    window.location.reload();
  };

  const handleGoHome = () => {
    // Track recovery attempt
    getInstrumentation().trackTelemetry({
      event: 'error_recovery_attempt',
      properties: {
        errorType,
        recoveryMethod: 'home',
        errorMessage: error.message,
      },
    });

    router.push('/');
  };

  const handleGoBack = () => {
    // Track recovery attempt
    getInstrumentation().trackTelemetry({
      event: 'error_recovery_attempt',
      properties: {
        errorType,
        recoveryMethod: 'back',
        errorMessage: error.message,
      },
    });

    router.back();
  };

  const handleReportIssue = () => {
    // Track issue report
    getInstrumentation().trackTelemetry({
      event: 'error_issue_reported',
      properties: {
        errorType,
        errorMessage: error.message,
        errorDigest: error.digest,
      },
    });

    // Create a pre-filled support email or form
    const subject = encodeURIComponent(`Error Report: ${errorInfo.title}`);
    const body = encodeURIComponent(`
Error Details:
- Type: ${errorType}
- Message: ${error.message}
- Digest: ${error.digest || 'N/A'}
- Time: ${new Date().toISOString()}
- URL: ${window.location.href}
- User Agent: ${navigator.userAgent}

Please describe what you were doing when this error occurred:
[Your description here]
    `);

    window.open(`mailto:support@example.com?subject=${subject}&body=${body}`);
  };

  return (
    <div className='min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 p-4'>
      <Card className='max-w-2xl w-full shadow-lg'>
        <CardHeader className='text-center'>
          <div className='flex justify-center mb-4'>{errorInfo.icon}</div>
          <CardTitle className='text-2xl font-bold text-gray-900 dark:text-gray-100'>
            {errorInfo.title}
          </CardTitle>
          <CardDescription className='text-gray-600 dark:text-gray-400 max-w-md mx-auto'>
            {errorInfo.description}
          </CardDescription>
        </CardHeader>

        <CardContent className='space-y-6'>
          {/* Error Details Alert */}
          <Alert variant='destructive' className='border-red-200 dark:border-red-800'>
            <AlertCircle className='h-4 w-4' />
            <AlertTitle>Error Information</AlertTitle>
            <AlertDescription className='mt-2'>
              <div className='space-y-1 text-sm'>
                <div>
                  <strong>Message:</strong> {error.message || 'Unknown error occurred'}
                </div>
                {error.digest && (
                  <div>
                    <strong>Error ID:</strong> {error.digest}
                  </div>
                )}
                <div>
                  <strong>Time:</strong> {new Date().toLocaleString()}
                </div>
              </div>
            </AlertDescription>
          </Alert>

          {/* Development Mode: Stack Trace */}
          {isDevelopment && error.stack && (
            <div className='space-y-2'>
              <h3 className='text-sm font-semibold text-gray-700 dark:text-gray-300 flex items-center gap-2'>
                <Bug className='h-4 w-4' />
                Stack Trace (Development Only)
              </h3>
              <pre className='text-xs bg-gray-100 dark:bg-gray-800 p-4 rounded-lg overflow-auto max-h-48 border border-gray-200 dark:border-gray-700'>
                {error.stack}
              </pre>
            </div>
          )}

          <Separator />

          {/* Recovery Actions */}
          <div className='space-y-4'>
            <h3 className='font-semibold text-gray-900 dark:text-gray-100'>
              What would you like to do?
            </h3>

            <div className='grid gap-2 sm:grid-cols-2'>
              <Button onClick={handleReset} className='w-full'>
                <RefreshCw className='mr-2 h-4 w-4' />
                Try Again
              </Button>

              <Button onClick={handleReload} variant='outline' className='w-full'>
                <RefreshCw className='mr-2 h-4 w-4' />
                Reload Page
              </Button>

              <Button onClick={handleGoBack} variant='outline' className='w-full'>
                <ArrowLeft className='mr-2 h-4 w-4' />
                Go Back
              </Button>

              <Button onClick={handleGoHome} variant='outline' className='w-full'>
                <Home className='mr-2 h-4 w-4' />
                Go Home
              </Button>
            </div>
          </div>

          <Separator />

          {/* Support Section */}
          <div className='bg-gray-50 dark:bg-gray-800/50 rounded-lg p-4'>
            <h4 className='font-medium text-gray-900 dark:text-gray-100 mb-2'>Need Help?</h4>
            <p className='text-sm text-gray-600 dark:text-gray-400 mb-3'>
              If this error persists, please report it to our support team. We&apos;ll investigate
              and resolve the issue.
            </p>
            <Button
              onClick={handleReportIssue}
              variant='outline'
              size='sm'
              className='w-full sm:w-auto'
            >
              <Bug className='mr-2 h-4 w-4' />
              Report Issue
            </Button>
          </div>

          {/* Error Metadata for Support */}
          <details className='text-xs text-gray-500 dark:text-gray-400'>
            <summary className='cursor-pointer hover:text-gray-700 dark:hover:text-gray-300'>
              Technical Details (for support)
            </summary>
            <div className='mt-2 p-3 bg-gray-100 dark:bg-gray-800 rounded font-mono'>
              <div>Error Type: {errorType}</div>
              <div>Timestamp: {new Date().toISOString()}</div>
              <div>URL: {typeof window !== 'undefined' ? window.location.href : 'N/A'}</div>
              <div>
                User Agent: {typeof navigator !== 'undefined' ? navigator.userAgent : 'N/A'}
              </div>
              {error.digest && <div>Digest: {error.digest}</div>}
            </div>
          </details>
        </CardContent>
      </Card>
    </div>
  );
}
