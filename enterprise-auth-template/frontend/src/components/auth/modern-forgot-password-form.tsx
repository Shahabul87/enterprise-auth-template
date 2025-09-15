'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { cn } from '@/lib/utils';
import {
  Mail,
  ArrowRight,
  CheckCircle2,
  AlertCircle,
  Sparkles,
  ArrowLeft,
  Send,
  KeyRound,
  Shield,
} from 'lucide-react';

export function ModernForgotPasswordForm(): JSX.Element {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [status, setStatus] = useState<'idle' | 'submitting' | 'success' | 'error'>('idle');
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent): Promise<void> => {
    e.preventDefault();

    if (!email) {
      setError('Please enter your email address');
      return;
    }

    if (!/\S+@\S+\.\S+/.test(email)) {
      setError('Please enter a valid email address');
      return;
    }

    setStatus('submitting');
    setError('');

    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));

      // TODO: Replace with actual API call
      // const response = await api.requestPasswordReset({ email });

      setStatus('success');
      localStorage.setItem('resetEmail', email);
    } catch (err) {
      setStatus('error');
      setError('Failed to send reset link. Please try again.');
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
    <div className='w-full max-w-md mx-auto'>
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
        className='bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl rounded-2xl shadow-2xl border border-gray-200/50 dark:border-gray-700/50 overflow-hidden'
      >
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
                : 'bg-gradient-to-br from-amber-500 to-orange-600'
            )}
          >
            {status === 'success' ? (
              <CheckCircle2 className='w-8 h-8 text-white' />
            ) : (
              <KeyRound className='w-8 h-8 text-white' />
            )}
          </motion.div>

          <motion.h2
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className='text-3xl font-bold text-center bg-gradient-to-r from-amber-600 to-orange-600 bg-clip-text text-transparent'
          >
            {status === 'success' ? 'Check Your Email' : 'Reset Password'}
          </motion.h2>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.4 }}
            className='text-center text-gray-600 dark:text-gray-400 mt-2'
          >
            {status === 'success'
              ? `We&apos;ve sent a reset link to ${email}`
              : 'Enter your email to receive a password reset link'}
          </motion.p>
        </div>

        {/* Content */}
        <div className='p-8 pt-0'>
          <AnimatePresence mode='wait'>
            {status !== 'success' ? (
              <motion.form
                key='form'
                variants={containerVariants}
                initial='hidden'
                animate='visible'
                exit={{ opacity: 0, scale: 0.95 }}
                onSubmit={handleSubmit}
                className='space-y-4'
              >
                <motion.div variants={itemVariants}>
                  <Label htmlFor='email' className='text-sm font-medium'>
                    Email Address
                  </Label>
                  <div className='relative mt-1'>
                    <Mail className='absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400' />
                    <Input
                      id='email'
                      type='email'
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className={cn(
                        'pl-10 h-11 bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700',
                        error && 'border-red-500'
                      )}
                      placeholder='Enter your email address'
                      disabled={status === 'submitting'}
                    />
                  </div>
                  {error && (
                    <p className='text-xs text-red-500 mt-1'>{error}</p>
                  )}
                </motion.div>

                <motion.div variants={itemVariants}>
                  <div className='bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 rounded-lg p-3'>
                    <div className='flex items-start'>
                      <Shield className='w-4 h-4 text-amber-600 dark:text-amber-400 mt-0.5 mr-2 flex-shrink-0' />
                      <div className='text-sm text-amber-700 dark:text-amber-300'>
                        <p className='font-medium mb-1'>Security Notice</p>
                        <p className='text-xs opacity-90'>
                          For your security, the reset link will expire in 1 hour.
                        </p>
                      </div>
                    </div>
                  </div>
                </motion.div>

                <motion.div variants={itemVariants}>
                  <Button
                    type='submit'
                    disabled={status === 'submitting'}
                    className='w-full h-11 bg-gradient-to-r from-amber-600 to-orange-600 hover:from-amber-700 hover:to-orange-700 text-white font-medium'
                  >
                    {status === 'submitting' ? (
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                        className='w-4 h-4 border-2 border-white border-t-transparent rounded-full'
                      />
                    ) : (
                      <>
                        Send Reset Link
                        <Send className='ml-2 w-4 h-4' />
                      </>
                    )}
                  </Button>
                </motion.div>
              </motion.form>
            ) : (
              <motion.div
                key='success'
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className='space-y-6'
              >
                <div className='text-center'>
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: 'spring', stiffness: 200 }}
                    className='w-20 h-20 bg-gradient-to-br from-green-400 to-green-600 rounded-full flex items-center justify-center mx-auto mb-4'
                  >
                    <Mail className='w-10 h-10 text-white' />
                  </motion.div>

                  <h3 className='text-xl font-bold text-gray-900 dark:text-white mb-2'>
                    Email Sent!
                  </h3>

                  <p className='text-gray-600 dark:text-gray-400 text-sm'>
                    We&apos;ve sent a password reset link to:
                  </p>

                  <p className='font-mono text-sm text-blue-600 dark:text-blue-400 mt-2'>
                    {email}
                  </p>
                </div>

                <div className='space-y-3'>
                  <div className='bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4 border border-blue-200 dark:border-blue-800'>
                    <h4 className='font-medium text-blue-900 dark:text-blue-100 mb-2 text-sm'>
                      Next Steps:
                    </h4>
                    <ol className='space-y-1 text-xs text-blue-700 dark:text-blue-300'>
                      <li>1. Check your email inbox</li>
                      <li>2. Click the reset link in the email</li>
                      <li>3. Create a new secure password</li>
                      <li>4. Sign in with your new password</li>
                    </ol>
                  </div>

                  <div className='flex items-center justify-center'>
                    <Sparkles className='w-4 h-4 text-yellow-500 animate-pulse' />
                    <Sparkles className='w-5 h-5 text-yellow-500 animate-pulse mx-2' />
                    <Sparkles className='w-4 h-4 text-yellow-500 animate-pulse' />
                  </div>

                  <Button
                    onClick={() => router.push('/auth/login')}
                    className='w-full h-11 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white font-medium'
                  >
                    Back to Login
                    <ArrowRight className='ml-2 w-4 h-4' />
                  </Button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Footer */}
          {status !== 'success' && (
            <div className='mt-6 pt-6 border-t border-gray-200 dark:border-gray-700'>
              <div className='flex items-center justify-between text-sm'>
                <Link
                  href='/auth/login'
                  className='flex items-center text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 transition-colors'
                >
                  <ArrowLeft className='w-4 h-4 mr-1' />
                  Back to login
                </Link>

                <Link
                  href='/auth/register'
                  className='text-blue-600 hover:text-blue-500 font-medium transition-colors'
                >
                  Create account
                </Link>
              </div>
            </div>
          )}
        </div>
      </motion.div>

      {/* Help text */}
      {status !== 'success' && (
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6 }}
          className='text-center text-xs text-gray-500 dark:text-gray-400 mt-6'
        >
          Didn&apos;t receive the email? Check your spam folder or{' '}
          <Link href='/support' className='text-blue-600 hover:text-blue-500'>
            contact support
          </Link>
        </motion.p>
      )}
    </div>
  );
}