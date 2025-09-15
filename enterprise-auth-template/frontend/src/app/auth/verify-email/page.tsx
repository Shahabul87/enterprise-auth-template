'use client';

import { useState, useEffect, Suspense } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { useAuthStore } from '@/stores/auth.store';
import { cn } from '@/lib/utils';
import {
  Mail,
  CheckCircle2,
  AlertCircle,
  RefreshCw,
  ArrowRight,
  Clock,
  Shield,
  Sparkles,
  Send,
} from 'lucide-react';

function VerifyEmailContent(): JSX.Element {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { resendVerification } = useAuthStore();
  const [verificationCode, setVerificationCode] = useState('');
  const [email, setEmail] = useState('');
  const [status, setStatus] = useState<'pending' | 'verifying' | 'success' | 'error'>('pending');
  const [error, setError] = useState('');
  const [resendCooldown, setResendCooldown] = useState(0);

  useEffect(() => {
    // Get email from query params or localStorage
    const emailParam = searchParams.get('email');
    const storedEmail = localStorage.getItem('registrationEmail');
    setEmail(emailParam || storedEmail || '');

    // Auto-verify if token is in URL
    const token = searchParams.get('token');
    if (token) {
      handleVerification(token);
    }
  }, [searchParams]);

  useEffect(() => {
    if (resendCooldown > 0) {
      const timer = setTimeout(() => setResendCooldown(resendCooldown - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [resendCooldown]);

  const handleVerification = async (token?: string): Promise<void> => {
    setStatus('verifying');
    setError('');

    const verifyToken = token || verificationCode;
    if (!verifyToken) {
      setError('Please enter the verification code');
      setStatus('error');
      return;
    }

    try {
      // Simulate API call for now
      await new Promise(resolve => setTimeout(resolve, 2000));

      // TODO: Replace with actual API call
      // const response = await api.verifyEmail({ token: verifyToken });

      setStatus('success');
      setTimeout(() => {
        router.push('/auth/login');
      }, 3000);
    } catch (err) {
      setError('Invalid or expired verification code. Please try again.');
      setStatus('error');
    }
  };

  const handleResendEmail = async (): Promise<void> => {
    if (resendCooldown > 0 || !email) return;

    try {
      const response = await resendVerification();
      if (response.success) {
        setResendCooldown(60);
        // Show success message
      } else {
        setError(response.error?.message || 'Failed to resend verification email');
      }
    } catch (err) {
      setError('Failed to resend verification email. Please try again.');
    }
  };

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.3 },
    },
  };

  return (
    <div className='relative min-h-screen overflow-hidden'>
      {/* Animated gradient background */}
      <div className='absolute inset-0'>
        <div className='absolute inset-0 bg-gradient-to-br from-cyan-50 via-blue-50 to-indigo-50 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800'></div>

        {/* Animated orbs */}
        <div className='absolute top-0 -left-4 w-72 h-72 bg-cyan-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob dark:bg-cyan-900 dark:opacity-30'></div>
        <div className='absolute top-0 -right-4 w-72 h-72 bg-blue-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob [animation-delay:2s] dark:bg-blue-900 dark:opacity-30'></div>
        <div className='absolute -bottom-8 left-20 w-72 h-72 bg-indigo-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob [animation-delay:4s] dark:bg-indigo-900 dark:opacity-30'></div>

        {/* Grid pattern overlay */}
        <div className='absolute inset-0 bg-[url("/grid.svg")] bg-center [mask-image:linear-gradient(180deg,white,rgba(255,255,255,0))]'></div>
      </div>

      {/* Content */}
      <div className='relative z-10 flex items-center justify-center min-h-screen p-4 py-12'>
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.5 }}
          className='w-full max-w-md mx-auto'
        >
          <div className='bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl rounded-2xl shadow-2xl border border-gray-200/50 dark:border-gray-700/50 overflow-hidden'>
            {/* Header */}
            <div className='relative p-8 pb-6'>
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
                className={cn(
                  'w-16 h-16 rounded-2xl flex items-center justify-center mb-6 mx-auto',
                  status === 'success'
                    ? 'bg-gradient-to-br from-green-500 to-green-600'
                    : status === 'error'
                    ? 'bg-gradient-to-br from-red-500 to-red-600'
                    : 'bg-gradient-to-br from-blue-500 to-indigo-600'
                )}
              >
                {status === 'success' ? (
                  <CheckCircle2 className='w-8 h-8 text-white' />
                ) : status === 'error' ? (
                  <AlertCircle className='w-8 h-8 text-white' />
                ) : (
                  <Mail className='w-8 h-8 text-white' />
                )}
              </motion.div>

              <motion.h2
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                className='text-3xl font-bold text-center bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent'
              >
                {status === 'success'
                  ? 'Email Verified!'
                  : status === 'error'
                  ? 'Verification Failed'
                  : 'Verify Your Email'}
              </motion.h2>

              <motion.p
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.4 }}
                className='text-center text-gray-600 dark:text-gray-400 mt-2'
              >
                {status === 'success'
                  ? 'Your account has been successfully verified'
                  : status === 'error'
                  ? 'We couldn&apos;t verify your email'
                  : email
                  ? `We sent a verification code to ${email}`
                  : 'Enter the code we sent to your email'}
              </motion.p>
            </div>

            {/* Content */}
            <div className='p-8 pt-0'>
              <AnimatePresence mode='wait'>
                {status === 'pending' && (
                  <motion.div
                    key='pending'
                    variants={containerVariants}
                    initial='hidden'
                    animate='visible'
                    exit={{ opacity: 0, scale: 0.95 }}
                    className='space-y-4'
                  >
                    <motion.div variants={itemVariants}>
                      <div className='flex items-center space-x-2 text-sm text-gray-600 dark:text-gray-400 mb-4'>
                        <Shield className='w-4 h-4' />
                        <span>Enter the 6-digit code from your email</span>
                      </div>
                      <Input
                        type='text'
                        value={verificationCode}
                        onChange={(e) => setVerificationCode(e.target.value)}
                        placeholder='123456'
                        className='h-12 text-center text-2xl font-mono tracking-widest bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700'
                        maxLength={6}
                      />
                    </motion.div>

                    <motion.div variants={itemVariants}>
                      <Button
                        onClick={() => handleVerification()}
                        className='w-full h-11 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-medium'
                      >
                        Verify Email
                        <ArrowRight className='ml-2 w-4 h-4' />
                      </Button>
                    </motion.div>

                    <motion.div
                      variants={itemVariants}
                      className='flex items-center justify-center space-x-2'
                    >
                      <span className='text-sm text-gray-600 dark:text-gray-400'>
                        Didn&apos;t receive the code?
                      </span>
                      <Button
                        variant='link'
                        onClick={handleResendEmail}
                        disabled={resendCooldown > 0}
                        className='text-sm font-medium text-blue-600 hover:text-blue-500 p-0'
                      >
                        {resendCooldown > 0 ? (
                          <span className='flex items-center'>
                            <Clock className='w-3 h-3 mr-1' />
                            {resendCooldown}s
                          </span>
                        ) : (
                          <span className='flex items-center'>
                            <RefreshCw className='w-3 h-3 mr-1' />
                            Resend
                          </span>
                        )}
                      </Button>
                    </motion.div>
                  </motion.div>
                )}

                {status === 'verifying' && (
                  <motion.div
                    key='verifying'
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className='text-center py-8'
                  >
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                      className='w-12 h-12 border-4 border-blue-600 border-t-transparent rounded-full mx-auto mb-4'
                    />
                    <p className='text-gray-600 dark:text-gray-400'>
                      Verifying your email...
                    </p>
                  </motion.div>
                )}

                {status === 'success' && (
                  <motion.div
                    key='success'
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className='text-center py-8'
                  >
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ type: 'spring', stiffness: 200 }}
                      className='w-20 h-20 bg-gradient-to-br from-green-400 to-green-600 rounded-full flex items-center justify-center mx-auto mb-4'
                    >
                      <CheckCircle2 className='w-10 h-10 text-white' />
                    </motion.div>
                    <h3 className='text-xl font-bold text-gray-900 dark:text-white mb-2'>
                      Verification Successful!
                    </h3>
                    <p className='text-gray-600 dark:text-gray-400 mb-4'>
                      Redirecting you to login...
                    </p>
                    <div className='flex items-center justify-center'>
                      <Sparkles className='w-4 h-4 text-yellow-500 animate-pulse' />
                      <Sparkles className='w-5 h-5 text-yellow-500 animate-pulse mx-2' />
                      <Sparkles className='w-4 h-4 text-yellow-500 animate-pulse' />
                    </div>
                  </motion.div>
                )}

                {status === 'error' && (
                  <motion.div
                    key='error'
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className='space-y-4'
                  >
                    <div className='bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4'>
                      <p className='text-sm text-red-600 dark:text-red-400'>
                        {error}
                      </p>
                    </div>
                    <Button
                      onClick={() => {
                        setStatus('pending');
                        setError('');
                        setVerificationCode('');
                      }}
                      className='w-full h-11 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-medium'
                    >
                      Try Again
                      <RefreshCw className='ml-2 w-4 h-4' />
                    </Button>
                  </motion.div>
                )}
              </AnimatePresence>

              {/* Additional Info */}
              {status === 'pending' && (
                <div className='mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800'>
                  <div className='flex items-start'>
                    <Send className='w-4 h-4 text-blue-600 dark:text-blue-400 mt-0.5 mr-2 flex-shrink-0' />
                    <div className='text-sm text-blue-700 dark:text-blue-300'>
                      <p className='font-medium mb-1'>Check your spam folder</p>
                      <p className='text-xs opacity-90'>
                        Sometimes our emails end up there. Make sure to mark us as
                        not spam!
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Footer */}
            {status !== 'success' && status !== 'verifying' && (
              <div className='px-8 pb-8'>
                <p className='text-center text-sm text-gray-600 dark:text-gray-400'>
                  Wrong email?{' '}
                  <Link
                    href='/auth/register'
                    className='font-medium text-blue-600 hover:text-blue-500 transition-colors'
                  >
                    Go back to registration
                  </Link>
                </p>
              </div>
            )}
          </div>
        </motion.div>
      </div>
    </div>
  );
}

export default function VerifyEmailPage(): JSX.Element {
  return (
    <Suspense
      fallback={
        <div className='relative min-h-screen flex items-center justify-center'>
          <div className='absolute inset-0 bg-gradient-to-br from-cyan-50 via-blue-50 to-indigo-50 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800'></div>
          <div className='relative'>
            <div className='animate-spin rounded-full h-12 w-12 border-4 border-blue-500 border-t-transparent'></div>
          </div>
        </div>
      }
    >
      <VerifyEmailContent />
    </Suspense>
  );
}