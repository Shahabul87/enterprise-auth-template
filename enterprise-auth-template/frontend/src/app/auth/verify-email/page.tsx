'use client';

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { useAuthStore } from '@/stores/auth.store';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Card, CardContent } from '@/components/ui/card';
import {
  Mail,
  CheckCircle2,
  ArrowRight,
  RefreshCw,
  Clock,
  AlertCircle,
} from 'lucide-react';

export default function VerifyEmailPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { resendVerification } = useAuthStore();

  const [isResending, setIsResending] = useState(false);
  const [resendSuccess, setResendSuccess] = useState(false);
  const [resendError, setResendError] = useState<string | null>(null);
  const [timeLeft, setTimeLeft] = useState(60);
  const [canResend, setCanResend] = useState(false);
  const [email, setEmail] = useState<string | null>(null);

  // Get email from URL params or localStorage on mount
  useEffect(() => {
    const urlEmail = searchParams?.get('email');
    if (urlEmail) {
      setEmail(urlEmail);
    } else if (typeof window !== 'undefined') {
      const storedEmail = localStorage.getItem('registrationEmail');
      if (storedEmail) {
        setEmail(storedEmail);
      }
    }
  }, [searchParams]);

  // Countdown timer for resend button
  useEffect(() => {
    if (!canResend && timeLeft > 0) {
      const timer = setTimeout(() => setTimeLeft(timeLeft - 1), 1000);
      return () => clearTimeout(timer);
    } else if (timeLeft === 0) {
      setCanResend(true);
    }
  }, [timeLeft, canResend]);

  const handleResendEmail = async () => {
    if (!email || isResending) return;

    setIsResending(true);
    setResendError(null);
    setResendSuccess(false);

    try {
      const response = await resendVerification();

      if (response.success) {
        setResendSuccess(true);
        setCanResend(false);
        setTimeLeft(60);
      } else {
        setResendError(response.error?.message || 'Failed to resend verification email');
      }
    } catch (error) {
      setResendError(error instanceof Error ? error.message : 'An error occurred');
    } finally {
      setIsResending(false);
    }
  };

  const handleBackToLogin = () => {
    // Clear any stored registration email
    if (typeof window !== 'undefined') {
      localStorage.removeItem('registrationEmail');
    }
    router.push('/auth/login');
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-gradient-to-br from-blue-50 via-white to-green-50">
      <div className="w-full max-w-md">
        <Card className="border-0 shadow-2xl bg-white/95 backdrop-blur-sm">
          <CardContent className="p-8">
            {/* Success Icon */}
            <div className="text-center mb-6">
              <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-green-100 mb-4 animate-pulse">
                <CheckCircle2 className="w-10 h-10 text-green-600" />
              </div>
              <h1 className="text-3xl font-bold mb-2 text-gray-900">
                Check Your Email
              </h1>
              <p className="text-gray-600">
                We&apos;ve sent a verification link to verify your account
              </p>
            </div>

            {/* Email Display */}
            {email && (
              <div className="bg-blue-50 rounded-lg p-4 mb-6 border border-blue-200">
                <div className="flex items-center gap-3">
                  <Mail className="w-5 h-5 text-blue-600 flex-shrink-0" />
                  <div>
                    <p className="text-sm font-medium text-blue-900">Email sent to:</p>
                    <p className="text-blue-700 font-mono text-sm">{email}</p>
                  </div>
                </div>
              </div>
            )}

            {/* Instructions */}
            <div className="bg-gray-50 rounded-lg p-6 mb-6">
              <h3 className="font-semibold mb-4 flex items-center gap-2">
                <span className="text-lg">📧</span>
                Next Steps:
              </h3>
              <ol className="space-y-3 text-sm text-gray-700">
                <li className="flex items-start gap-3">
                  <span className="font-semibold text-blue-600 flex-shrink-0">1.</span>
                  <span>Open your email inbox and look for our verification message</span>
                </li>
                <li className="flex items-start gap-3">
                  <span className="font-semibold text-blue-600 flex-shrink-0">2.</span>
                  <span>Click the &quot;Verify Email&quot; button in the email</span>
                </li>
                <li className="flex items-start gap-3">
                  <span className="font-semibold text-blue-600 flex-shrink-0">3.</span>
                  <span>Return to the login page and sign in with your credentials</span>
                </li>
                <li className="flex items-start gap-3">
                  <span className="font-semibold text-blue-600 flex-shrink-0">4.</span>
                  <span>If you don&apos;t see the email, check your spam/junk folder</span>
                </li>
              </ol>
            </div>

            {/* Important Notice */}
            <Alert className="bg-amber-50 border-amber-200 mb-6">
              <Clock className="h-4 w-4 text-amber-600" />
              <AlertDescription className="text-sm text-amber-800">
                <strong>Important:</strong> The verification link expires in 24 hours.
                You must verify your email before you can log in.
              </AlertDescription>
            </Alert>

            {/* Resend Success Message */}
            {resendSuccess && (
              <Alert className="bg-green-50 border-green-200 mb-4">
                <CheckCircle2 className="h-4 w-4 text-green-600" />
                <AlertDescription className="text-sm text-green-800">
                  Verification email sent successfully! Please check your inbox.
                </AlertDescription>
              </Alert>
            )}

            {/* Resend Error Message */}
            {resendError && (
              <Alert variant="destructive" className="mb-4">
                <AlertCircle className="h-4 w-4" />
                <AlertDescription className="text-sm">
                  {resendError}
                </AlertDescription>
              </Alert>
            )}

            {/* Action Buttons */}
            <div className="space-y-3">
              {/* Primary Action - Go to Login */}
              <Button
                onClick={handleBackToLogin}
                className="w-full h-12 text-base font-medium bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 transition-all duration-200"
              >
                <ArrowRight className="w-5 h-5 mr-2" />
                Continue to Login
              </Button>

              {/* Secondary Action - Resend Email */}
              <Button
                variant="outline"
                onClick={handleResendEmail}
                disabled={!canResend || isResending || !email}
                className="w-full h-12 text-base"
              >
                {isResending ? (
                  <>
                    <RefreshCw className="w-4 h-4 mr-2 animate-spin" />
                    Sending...
                  </>
                ) : canResend ? (
                  <>
                    <Mail className="w-4 h-4 mr-2" />
                    Resend Verification Email
                  </>
                ) : (
                  <>
                    <Clock className="w-4 h-4 mr-2" />
                    Resend in {timeLeft}s
                  </>
                )}
              </Button>

              {/* Back to Registration */}
              <div className="text-center pt-4">
                <p className="text-sm text-gray-600">
                  Wrong email address?{' '}
                  <Link
                    href="/auth/register"
                    className="font-medium text-blue-600 hover:text-blue-700 transition-colors"
                  >
                    Register again
                  </Link>
                </p>
              </div>
            </div>

            {/* Help Text */}
            <div className="mt-8 pt-6 border-t border-gray-200">
              <p className="text-xs text-gray-500 text-center">
                Still having trouble? Contact our{' '}
                <Link href="/support" className="text-blue-600 hover:text-blue-700">
                  support team
                </Link>{' '}
                for assistance.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}