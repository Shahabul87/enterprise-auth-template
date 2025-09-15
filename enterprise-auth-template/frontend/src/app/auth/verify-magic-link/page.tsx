'use client';

import { useEffect, useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { useAuthStore } from '@/stores/auth.store';
import { useToast } from '@/components/ui/use-toast';
import { magicLinkService } from '@/services/auth-api.service';
import { Loader2, CheckCircle, XCircle } from 'lucide-react';

function MagicLinkVerifyContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { toast } = useToast();
  const { setAuth } = useAuthStore();
  const [status, setStatus] = useState<'verifying' | 'success' | 'error'>('verifying');
  const [message, setMessage] = useState('Verifying your magic link...');

  useEffect(() => {
    const verifyToken = async () => {
      const token = searchParams.get('token');

      if (!token) {
        setStatus('error');
        setMessage('Invalid magic link. Please request a new one.');
        toast({
          title: 'Invalid Link',
          description: 'This magic link is invalid. Please request a new one.',
          variant: 'destructive',
        });
        return;
      }

      try {
        const response = await magicLinkService.verifyMagicLink(token);

        if (response.success && response.data) {
          // Store authentication data
          setAuth(
            response.data.access_token,
            response.data.refresh_token,
            response.data.user
          );

          setStatus('success');
          setMessage('Successfully logged in! Redirecting...');

          toast({
            title: 'Welcome!',
            description: 'You have been successfully logged in.',
          });

          // Redirect to dashboard after a short delay
          setTimeout(() => {
            router.push('/dashboard');
          }, 1500);
        } else {
          throw new Error(response.error?.message || 'Verification failed');
        }
      } catch (error) {
        console.error('Magic link verification error:', error);

        setStatus('error');
        const errorMessage = error instanceof Error ? error.message : 'Failed to verify magic link';
        setMessage(errorMessage);

        toast({
          title: 'Verification Failed',
          description: errorMessage,
          variant: 'destructive',
        });

        // Redirect to login after showing error
        setTimeout(() => {
          router.push('/auth/login');
        }, 3000);
      }
    };

    verifyToken();
  }, [searchParams, router, toast, setAuth]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800">
      <div className="max-w-md w-full mx-auto p-6">
        <div className="bg-white dark:bg-gray-900 rounded-2xl shadow-xl border border-gray-100 dark:border-gray-800 p-8">
          <div className="text-center">
            {status === 'verifying' && (
              <>
                <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-blue-100 dark:bg-blue-900/20 mb-4">
                  <Loader2 className="w-8 h-8 text-blue-600 dark:text-blue-400 animate-spin" />
                </div>
                <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
                  Verifying Magic Link
                </h2>
                <p className="text-gray-600 dark:text-gray-400">
                  {message}
                </p>
              </>
            )}

            {status === 'success' && (
              <>
                <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-100 dark:bg-green-900/20 mb-4">
                  <CheckCircle className="w-8 h-8 text-green-600 dark:text-green-400" />
                </div>
                <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
                  Success!
                </h2>
                <p className="text-gray-600 dark:text-gray-400">
                  {message}
                </p>
              </>
            )}

            {status === 'error' && (
              <>
                <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-red-100 dark:bg-red-900/20 mb-4">
                  <XCircle className="w-8 h-8 text-red-600 dark:text-red-400" />
                </div>
                <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
                  Verification Failed
                </h2>
                <p className="text-gray-600 dark:text-gray-400 mb-4">
                  {message}
                </p>
                <p className="text-sm text-gray-500 dark:text-gray-500">
                  Redirecting to login page...
                </p>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default function MagicLinkVerifyPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen flex items-center justify-center">
          <Loader2 className="w-8 h-8 animate-spin" />
        </div>
      }
    >
      <MagicLinkVerifyContent />
    </Suspense>
  );
}