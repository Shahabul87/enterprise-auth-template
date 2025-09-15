'use client';

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import {
  CheckCircle2,
  XCircle,
  Loader2,
  ArrowRight,
  Mail,
  AlertCircle
} from 'lucide-react';

export default function VerifyPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [verificationStatus, setVerificationStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [errorMessage, setErrorMessage] = useState<string>('');
  const [countdown, setCountdown] = useState(5);

  useEffect(() => {
    const token = searchParams?.get('token');

    if (!token) {
      setVerificationStatus('error');
      setErrorMessage('No verification token provided. Please check your email for the correct link.');
      return;
    }

    // Call the verification API
    const verifyEmail = async () => {
      try {
        const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';
        const response = await fetch(`${apiUrl}/api/v1/auth/verify-email/${token}`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        });

        const data = await response.json();

        if (response.ok && data.success) {
          setVerificationStatus('success');
          // Start countdown for auto-redirect
          const timer = setInterval(() => {
            setCountdown((prev) => {
              if (prev <= 1) {
                clearInterval(timer);
                router.push('/auth/login');
                return 0;
              }
              return prev - 1;
            });
          }, 1000);
        } else {
          setVerificationStatus('error');
          setErrorMessage(data.error?.message || 'Failed to verify email. The link may be expired or invalid.');
        }
      } catch (error) {
        setVerificationStatus('error');
        setErrorMessage('An error occurred while verifying your email. Please try again.');
        console.error('Verification error:', error);
      }
    };

    verifyEmail();
  }, [searchParams, router]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50/30 flex items-center justify-center px-4 py-8">
      <div className="w-full max-w-md">
        <Card className="border-0 shadow-2xl bg-white/95 backdrop-blur-sm">
          <CardContent className="p-8">
            {verificationStatus === 'loading' && (
              <div className="text-center">
                <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-blue-100 mb-6">
                  <Loader2 className="w-10 h-10 text-blue-600 animate-spin" />
                </div>
                <h1 className="text-2xl font-bold mb-2 text-gray-900">
                  Verifying Your Email
                </h1>
                <p className="text-gray-600">
                  Please wait while we verify your email address...
                </p>
              </div>
            )}

            {verificationStatus === 'success' && (
              <div className="text-center">
                <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-green-100 mb-6">
                  <CheckCircle2 className="w-10 h-10 text-green-600" />
                </div>
                <h1 className="text-2xl font-bold mb-2 text-gray-900">
                  Email Verified Successfully!
                </h1>
                <p className="text-gray-600 mb-6">
                  Your email has been verified. You can now log in to your account.
                </p>

                <Alert className="bg-blue-50 border-blue-200 mb-6">
                  <AlertCircle className="h-4 w-4 text-blue-600" />
                  <AlertDescription className="text-sm text-blue-800">
                    Redirecting to login page in {countdown} seconds...
                  </AlertDescription>
                </Alert>

                <Button
                  onClick={() => router.push('/auth/login')}
                  className="w-full h-12 text-base font-medium bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-white rounded-lg shadow-md hover:shadow-lg transition-all duration-200"
                >
                  <ArrowRight className="w-5 h-5 mr-2" />
                  Continue to Login
                </Button>
              </div>
            )}

            {verificationStatus === 'error' && (
              <div className="text-center">
                <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-red-100 mb-6">
                  <XCircle className="w-10 h-10 text-red-600" />
                </div>
                <h1 className="text-2xl font-bold mb-2 text-gray-900">
                  Verification Failed
                </h1>
                <p className="text-gray-600 mb-6">
                  {errorMessage}
                </p>

                <Alert variant="destructive" className="mb-6">
                  <AlertCircle className="h-4 w-4" />
                  <AlertDescription className="text-sm">
                    {errorMessage}
                  </AlertDescription>
                </Alert>

                <div className="space-y-3">
                  <Link href="/auth/register" className="block">
                    <Button
                      variant="outline"
                      className="w-full h-12 text-base"
                    >
                      <Mail className="w-4 h-4 mr-2" />
                      Request New Verification Email
                    </Button>
                  </Link>

                  <Link href="/auth/login" className="block">
                    <Button
                      className="w-full h-12 text-base font-medium bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-white rounded-lg shadow-md hover:shadow-lg transition-all duration-200"
                    >
                      <ArrowRight className="w-5 h-5 mr-2" />
                      Go to Login
                    </Button>
                  </Link>
                </div>

                <div className="mt-6 pt-6 border-t border-gray-200">
                  <p className="text-xs text-gray-500 text-center">
                    If you continue to have issues, please{' '}
                    <Link href="/support" className="text-indigo-600 hover:text-indigo-700">
                      contact support
                    </Link>
                  </p>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}