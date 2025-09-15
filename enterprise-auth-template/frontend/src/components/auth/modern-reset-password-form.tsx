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
  Lock,
  ArrowRight,
  CheckCircle2,
  AlertCircle,
  Sparkles,
  KeyRound,
  Shield,
  Eye,
  EyeOff,
  Check,
  X,
} from 'lucide-react';

interface ModernResetPasswordFormProps {
  token: string;
}

export function ModernResetPasswordForm({ token }: ModernResetPasswordFormProps): JSX.Element {
  const router = useRouter();
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [status, setStatus] = useState<'idle' | 'submitting' | 'success' | 'error'>('idle');
  const [error, setError] = useState('');

  const passwordRequirements = [
    { regex: /.{8,}/, text: 'At least 8 characters' },
    { regex: /[A-Z]/, text: 'One uppercase letter' },
    { regex: /[a-z]/, text: 'One lowercase letter' },
    { regex: /[0-9]/, text: 'One number' },
    { regex: /[!@#$%^&*]/, text: 'One special character' },
  ];

  const checkPasswordStrength = (pass: string): number => {
    return passwordRequirements.filter(req => req.regex.test(pass)).length;
  };

  const getPasswordStrengthColor = (): string => {
    const strength = checkPasswordStrength(password);
    if (strength <= 2) return 'bg-red-500';
    if (strength <= 3) return 'bg-amber-500';
    if (strength <= 4) return 'bg-yellow-500';
    return 'bg-green-500';
  };

  const handleSubmit = async (e: React.FormEvent): Promise<void> => {
    e.preventDefault();
    setError('');

    if (!password || !confirmPassword) {
      setError('Please fill in all fields');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    if (checkPasswordStrength(password) < 3) {
      setError('Password is too weak. Please meet at least 3 requirements.');
      return;
    }

    setStatus('submitting');

    try {
      const { authApi } = await import('@/lib/api/auth-api');
      await authApi.confirmPasswordReset({
        token,
        password,
      });

      setStatus('success');
      setTimeout(() => {
        router.push('/auth/login');
      }, 3000);
    } catch (err) {
      setStatus('error');
      if (err instanceof Error) {
        setError(err.message || 'Failed to reset password. The link may be expired.');
      } else {
        setError('Failed to reset password. The link may be expired.');
      }
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
                : 'bg-gradient-to-br from-violet-500 to-purple-600'
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
            className='text-3xl font-bold text-center bg-gradient-to-r from-violet-600 to-purple-600 bg-clip-text text-transparent'
          >
            {status === 'success' ? 'Password Reset!' : 'Create New Password'}
          </motion.h2>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.4 }}
            className='text-center text-gray-600 dark:text-gray-400 mt-2'
          >
            {status === 'success'
              ? 'Your password has been successfully reset'
              : 'Enter your new password below'}
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
                  <Label htmlFor='password' className='text-sm font-medium'>
                    New Password
                  </Label>
                  <div className='relative mt-1'>
                    <Lock className='absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400' />
                    <Input
                      id='password'
                      type={showPassword ? 'text' : 'password'}
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      className={cn(
                        'pl-10 pr-10 h-11 bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700',
                        error && 'border-red-500'
                      )}
                      placeholder='Enter new password'
                      disabled={status === 'submitting'}
                    />
                    <button
                      type='button'
                      onClick={() => setShowPassword(!showPassword)}
                      className='absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600'
                    >
                      {showPassword ? <EyeOff className='w-4 h-4' /> : <Eye className='w-4 h-4' />}
                    </button>
                  </div>

                  {/* Password strength indicator */}
                  {password && (
                    <div className='mt-2'>
                      <div className='flex items-center justify-between mb-1'>
                        <span className='text-xs text-gray-600 dark:text-gray-400'>
                          Password strength
                        </span>
                        <span className='text-xs font-medium text-gray-700 dark:text-gray-300'>
                          {checkPasswordStrength(password)}/5
                        </span>
                      </div>
                      <div className='w-full bg-gray-200 dark:bg-gray-700 rounded-full h-1.5'>
                        <motion.div
                          initial={{ width: 0 }}
                          animate={{ width: `${(checkPasswordStrength(password) / 5) * 100}%` }}
                          className={cn('h-1.5 rounded-full', getPasswordStrengthColor())}
                        />
                      </div>
                    </div>
                  )}
                </motion.div>

                <motion.div variants={itemVariants}>
                  <Label htmlFor='confirmPassword' className='text-sm font-medium'>
                    Confirm Password
                  </Label>
                  <div className='relative mt-1'>
                    <Shield className='absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400' />
                    <Input
                      id='confirmPassword'
                      type={showConfirmPassword ? 'text' : 'password'}
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      className={cn(
                        'pl-10 pr-10 h-11 bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700',
                        error && 'border-red-500'
                      )}
                      placeholder='Confirm new password'
                      disabled={status === 'submitting'}
                    />
                    <button
                      type='button'
                      onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                      className='absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600'
                    >
                      {showConfirmPassword ? <EyeOff className='w-4 h-4' /> : <Eye className='w-4 h-4' />}
                    </button>
                  </div>
                </motion.div>

                {/* Password requirements */}
                {password && (
                  <motion.div
                    variants={itemVariants}
                    className='bg-gray-50 dark:bg-gray-800/50 rounded-lg p-3'
                  >
                    <p className='text-xs font-medium text-gray-700 dark:text-gray-300 mb-2'>
                      Password requirements:
                    </p>
                    <div className='space-y-1'>
                      {passwordRequirements.map((req, index) => (
                        <div
                          key={index}
                          className='flex items-center space-x-2 text-xs'
                        >
                          {req.regex.test(password) ? (
                            <Check className='w-3 h-3 text-green-500' />
                          ) : (
                            <X className='w-3 h-3 text-gray-400' />
                          )}
                          <span
                            className={cn(
                              req.regex.test(password)
                                ? 'text-green-700 dark:text-green-400'
                                : 'text-gray-500 dark:text-gray-400'
                            )}
                          >
                            {req.text}
                          </span>
                        </div>
                      ))}
                    </div>
                  </motion.div>
                )}

                {error && (
                  <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className='bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-3'
                  >
                    <div className='flex items-start'>
                      <AlertCircle className='w-4 h-4 text-red-600 dark:text-red-400 mt-0.5 mr-2 flex-shrink-0' />
                      <p className='text-sm text-red-600 dark:text-red-400'>{error}</p>
                    </div>
                  </motion.div>
                )}

                <motion.div variants={itemVariants}>
                  <Button
                    type='submit'
                    disabled={status === 'submitting'}
                    className='w-full h-11 bg-gradient-to-r from-violet-600 to-purple-600 hover:from-violet-700 hover:to-purple-700 text-white font-medium'
                  >
                    {status === 'submitting' ? (
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                        className='w-4 h-4 border-2 border-white border-t-transparent rounded-full'
                      />
                    ) : (
                      <>
                        Reset Password
                        <ArrowRight className='ml-2 w-4 h-4' />
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
                  Password Reset Successful!
                </h3>

                <p className='text-gray-600 dark:text-gray-400 mb-6'>
                  You can now sign in with your new password
                </p>

                <div className='flex items-center justify-center mb-6'>
                  <Sparkles className='w-4 h-4 text-yellow-500 animate-pulse' />
                  <Sparkles className='w-5 h-5 text-yellow-500 animate-pulse mx-2' />
                  <Sparkles className='w-4 h-4 text-yellow-500 animate-pulse' />
                </div>

                <Button
                  onClick={() => router.push('/auth/login')}
                  className='w-full h-11 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white font-medium'
                >
                  Go to Login
                  <ArrowRight className='ml-2 w-4 h-4' />
                </Button>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Footer */}
          {status === 'error' && (
            <div className='mt-6 pt-6 border-t border-gray-200 dark:border-gray-700'>
              <p className='text-center text-sm text-gray-600 dark:text-gray-400'>
                Reset link expired?{' '}
                <Link
                  href='/auth/forgot-password'
                  className='font-medium text-blue-600 hover:text-blue-500 transition-colors'
                >
                  Request a new one
                </Link>
              </p>
            </div>
          )}
        </div>
      </motion.div>
    </div>
  );
}