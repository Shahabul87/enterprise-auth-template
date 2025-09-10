'use client';

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Loader2, CheckCircle, XCircle, Mail } from 'lucide-react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { verifyMagicLink } from '@/lib/api/magic-links';

type VerificationStatus = 'verifying' | 'success' | 'error' | 'no-token';

export function MagicLinkVerify() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [status, setStatus] = useState<VerificationStatus>('verifying');
  const [errorMessage, setErrorMessage] = useState<string>('');

  useEffect(() => {
    const verifyToken = async () => {
      const token = searchParams.get('token');

      if (!token) {
        setStatus('no-token');
        return;
      }

      try {
        const response = await verifyMagicLink(token);

        if (response.success && response.access_token && response.user && response.refresh_token) {
          // Store auth data using auth context
          // Since the auth context doesn't expose storeAuthData directly,
          // we'll need to use the login flow or create a custom method
          // For now, we'll store the tokens manually
          if (typeof window !== 'undefined') {
            const tokenPair = {
              access_token: response.access_token,
              refresh_token: response.refresh_token,
              token_type: response.token_type || 'bearer',
              expires_in: 3600, // Default to 1 hour
            };
            
            // Store tokens in cookies (using the auth context pattern)
            const { storeAuthTokens } = await import('@/lib/cookie-manager');
            storeAuthTokens(tokenPair);
            
            // Store user data in session storage
            sessionStorage.setItem('auth_user', JSON.stringify(response.user));
          }

          setStatus('success');

          // Redirect to dashboard after a short delay
          setTimeout(() => {
            router.push('/dashboard');
          }, 2000);
        } else {
          setStatus('error');
          setErrorMessage('Invalid or expired magic link');
        }
      } catch (error) {
        
        setStatus('error');
        
        if (error instanceof Error) {
          if (error.message.includes('expired')) {
            setErrorMessage('This magic link has expired. Please request a new one.');
          } else if (error.message.includes('used')) {
            setErrorMessage('This magic link has already been used.');
          } else {
            setErrorMessage('Failed to verify magic link. Please try again.');
          }
        } else {
          setErrorMessage('An unexpected error occurred.');
        }
      }
    };

    verifyToken();
  }, [searchParams, router]);

  const renderContent = () => {
    switch (status) {
      case 'verifying':
        return (
          <>
            <div className="mx-auto mb-4 h-16 w-16 rounded-full bg-blue-100 flex items-center justify-center">
              <Loader2 className="h-8 w-8 text-blue-600 animate-spin" />
            </div>
            <CardTitle>Verifying Your Magic Link</CardTitle>
            <CardDescription>
              Please wait while we sign you in...
            </CardDescription>
          </>
        );

      case 'success':
        return (
          <>
            <div className="mx-auto mb-4 h-16 w-16 rounded-full bg-green-100 flex items-center justify-center">
              <CheckCircle className="h-8 w-8 text-green-600" />
            </div>
            <CardTitle>Success!</CardTitle>
            <CardDescription>
              You&apos;ve been signed in successfully. Redirecting to your dashboard...
            </CardDescription>
          </>
        );

      case 'error':
        return (
          <>
            <div className="mx-auto mb-4 h-16 w-16 rounded-full bg-red-100 flex items-center justify-center">
              <XCircle className="h-8 w-8 text-red-600" />
            </div>
            <CardTitle>Verification Failed</CardTitle>
            <CardDescription>
              We couldn&apos;t verify your magic link
            </CardDescription>
            <CardContent className="pt-6">
              <Alert variant="destructive">
                <AlertDescription>{errorMessage}</AlertDescription>
              </Alert>
              <div className="mt-6 space-y-2">
                <Button
                  onClick={() => router.push('/auth/magic-link')}
                  className="w-full"
                >
                  <Mail className="mr-2 h-4 w-4" />
                  Request New Magic Link
                </Button>
                <Button
                  variant="outline"
                  onClick={() => router.push('/auth/login')}
                  className="w-full"
                >
                  Back to Login
                </Button>
              </div>
            </CardContent>
          </>
        );

      case 'no-token':
        return (
          <>
            <div className="mx-auto mb-4 h-16 w-16 rounded-full bg-yellow-100 flex items-center justify-center">
              <Mail className="h-8 w-8 text-yellow-600" />
            </div>
            <CardTitle>No Magic Link Token</CardTitle>
            <CardDescription>
              It looks like you accessed this page directly
            </CardDescription>
            <CardContent className="pt-6">
              <Alert>
                <AlertDescription>
                  To sign in with a magic link, click the link in the email we sent you.
                  If you haven&apos;t requested a magic link yet, you can do so below.
                </AlertDescription>
              </Alert>
              <div className="mt-6 space-y-2">
                <Button
                  onClick={() => router.push('/auth/magic-link')}
                  className="w-full"
                >
                  <Mail className="mr-2 h-4 w-4" />
                  Request Magic Link
                </Button>
                <Button
                  variant="outline"
                  onClick={() => router.push('/auth/login')}
                  className="w-full"
                >
                  Back to Login
                </Button>
              </div>
            </CardContent>
          </>
        );
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          {renderContent()}
        </CardHeader>
      </Card>
    </div>
  );
}