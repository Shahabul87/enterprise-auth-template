'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Checkbox } from '@/components/ui/checkbox';
import { useRegister } from '@/hooks/api/use-auth';
import { cn } from '@/lib/utils';
import {
  Mail,
  Lock,
  User,
  ArrowRight,
  CheckCircle2,
  AlertCircle,
  Sparkles,
  Shield,
  UserPlus,
  Github,
  Chrome,
  Building2,
} from 'lucide-react';

export function ModernRegisterForm(): JSX.Element {
  const router = useRouter();
  const [step, setStep] = useState<'info' | 'credentials' | 'complete'>('info');
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    organization: '',
    acceptTerms: false,
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const { mutate: register, isPending } = useRegister();

  const validateStep = (currentStep: string): boolean => {
    const newErrors: Record<string, string> = {};

    if (currentStep === 'info') {
      if (!formData.name.trim()) {
        newErrors.name = 'Name is required';
      }
      if (!formData.email.trim()) {
        newErrors.email = 'Email is required';
      } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
        newErrors.email = 'Please enter a valid email';
      }
    }

    if (currentStep === 'credentials') {
      if (!formData.password) {
        newErrors.password = 'Password is required';
      } else if (formData.password.length < 8) {
        newErrors.password = 'Password must be at least 8 characters';
      }
      if (formData.password !== formData.confirmPassword) {
        newErrors.confirmPassword = 'Passwords do not match';
      }
      if (!formData.acceptTerms) {
        newErrors.acceptTerms = 'You must accept the terms and conditions';
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNextStep = (): void => {
    if (step === 'info' && validateStep('info')) {
      setStep('credentials');
    } else if (step === 'credentials' && validateStep('credentials')) {
      handleSubmit();
    }
  };

  const handleSubmit = (): void => {
    register(
      {
        email: formData.email,
        password: formData.password,
        full_name: formData.name,
        confirm_password: formData.confirmPassword,
        agree_to_terms: formData.acceptTerms,
      },
      {
        onSuccess: () => {
          setStep('complete');
          // Don't redirect - user needs to check email for link
        },
        onError: (error) => {
          setErrors({
            submit: error.response?.data?.detail || 'Registration failed',
          });
        },
      }
    );
  };

  const inputVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.3 },
    },
    exit: { opacity: 0, y: -20 },
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
            className='w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center mb-6 mx-auto'
          >
            <UserPlus className='w-8 h-8 text-white' />
          </motion.div>

          <motion.h2
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className='text-3xl font-bold text-center bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent'
          >
            Create Account
          </motion.h2>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.4 }}
            className='text-center text-gray-600 dark:text-gray-400 mt-2'
          >
            Join thousands of teams already using our platform
          </motion.p>

          {/* Progress indicator */}
          <div className='flex items-center justify-center mt-6 space-x-2'>
            {['info', 'credentials', 'complete'].map((s, index) => (
              <motion.div
                key={s}
                initial={false}
                animate={{
                  width: step === s ? 40 : 8,
                  backgroundColor:
                    step === s
                      ? '#3b82f6'
                      : index < ['info', 'credentials', 'complete'].indexOf(step)
                      ? '#10b981'
                      : '#e5e7eb',
                }}
                transition={{ duration: 0.3 }}
                className='h-2 rounded-full'
              />
            ))}
          </div>
        </div>

        {/* Form */}
        <div className='p-8 pt-0'>
          <AnimatePresence mode='wait'>
            {step === 'info' && (
              <motion.div
                key='info'
                variants={containerVariants}
                initial='hidden'
                animate='visible'
                exit='exit'
                className='space-y-4'
              >
                <motion.div variants={inputVariants}>
                  <Label htmlFor='name' className='text-sm font-medium'>
                    Full Name
                  </Label>
                  <div className='relative mt-1'>
                    <User className='absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400' />
                    <Input
                      id='name'
                      type='text'
                      value={formData.name}
                      onChange={(e) =>
                        setFormData({ ...formData, name: e.target.value })
                      }
                      className={cn(
                        'pl-10 h-11 bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700',
                        errors.name && 'border-red-500'
                      )}
                      placeholder='John Doe'
                    />
                    {errors.name && (
                      <p className='text-xs text-red-500 mt-1'>{errors.name}</p>
                    )}
                  </div>
                </motion.div>

                <motion.div variants={inputVariants}>
                  <Label htmlFor='email' className='text-sm font-medium'>
                    Email Address
                  </Label>
                  <div className='relative mt-1'>
                    <Mail className='absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400' />
                    <Input
                      id='email'
                      type='email'
                      value={formData.email}
                      onChange={(e) =>
                        setFormData({ ...formData, email: e.target.value })
                      }
                      className={cn(
                        'pl-10 h-11 bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700',
                        errors.email && 'border-red-500'
                      )}
                      placeholder='john@example.com'
                    />
                    {errors.email && (
                      <p className='text-xs text-red-500 mt-1'>{errors.email}</p>
                    )}
                  </div>
                </motion.div>

                <motion.div variants={inputVariants}>
                  <Label htmlFor='organization' className='text-sm font-medium'>
                    Organization (Optional)
                  </Label>
                  <div className='relative mt-1'>
                    <Building2 className='absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400' />
                    <Input
                      id='organization'
                      type='text'
                      value={formData.organization}
                      onChange={(e) =>
                        setFormData({ ...formData, organization: e.target.value })
                      }
                      className='pl-10 h-11 bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700'
                      placeholder='Acme Inc.'
                    />
                  </div>
                </motion.div>

                <motion.div variants={inputVariants}>
                  <Button
                    onClick={handleNextStep}
                    className='w-full h-11 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white font-medium'
                  >
                    Continue
                    <ArrowRight className='ml-2 w-4 h-4' />
                  </Button>
                </motion.div>
              </motion.div>
            )}

            {step === 'credentials' && (
              <motion.div
                key='credentials'
                variants={containerVariants}
                initial='hidden'
                animate='visible'
                exit='exit'
                className='space-y-4'
              >
                <motion.div variants={inputVariants}>
                  <Label htmlFor='password' className='text-sm font-medium'>
                    Password
                  </Label>
                  <div className='relative mt-1'>
                    <Lock className='absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400' />
                    <Input
                      id='password'
                      type='password'
                      value={formData.password}
                      onChange={(e) =>
                        setFormData({ ...formData, password: e.target.value })
                      }
                      className={cn(
                        'pl-10 h-11 bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700',
                        errors.password && 'border-red-500'
                      )}
                      placeholder='••••••••'
                    />
                    {errors.password && (
                      <p className='text-xs text-red-500 mt-1'>
                        {errors.password}
                      </p>
                    )}
                  </div>
                </motion.div>

                <motion.div variants={inputVariants}>
                  <Label htmlFor='confirmPassword' className='text-sm font-medium'>
                    Confirm Password
                  </Label>
                  <div className='relative mt-1'>
                    <Shield className='absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400' />
                    <Input
                      id='confirmPassword'
                      type='password'
                      value={formData.confirmPassword}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          confirmPassword: e.target.value,
                        })
                      }
                      className={cn(
                        'pl-10 h-11 bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700',
                        errors.confirmPassword && 'border-red-500'
                      )}
                      placeholder='••••••••'
                    />
                    {errors.confirmPassword && (
                      <p className='text-xs text-red-500 mt-1'>
                        {errors.confirmPassword}
                      </p>
                    )}
                  </div>
                </motion.div>

                <motion.div variants={inputVariants} className='flex items-start'>
                  <Checkbox
                    id='terms'
                    checked={formData.acceptTerms}
                    onCheckedChange={(checked) =>
                      setFormData({ ...formData, acceptTerms: checked as boolean })
                    }
                    className='mt-1'
                  />
                  <Label
                    htmlFor='terms'
                    className='ml-2 text-sm text-gray-600 dark:text-gray-400 cursor-pointer'
                  >
                    I agree to the{' '}
                    <Link
                      href='/terms'
                      className='text-blue-600 hover:underline'
                    >
                      Terms of Service
                    </Link>{' '}
                    and{' '}
                    <Link
                      href='/privacy'
                      className='text-blue-600 hover:underline'
                    >
                      Privacy Policy
                    </Link>
                  </Label>
                </motion.div>
                {errors.acceptTerms && (
                  <p className='text-xs text-red-500 -mt-2'>
                    {errors.acceptTerms}
                  </p>
                )}

                {errors.submit && (
                  <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className='bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-3 flex items-start'
                  >
                    <AlertCircle className='w-4 h-4 text-red-600 dark:text-red-400 mt-0.5 mr-2 flex-shrink-0' />
                    <p className='text-sm text-red-600 dark:text-red-400'>
                      {errors.submit}
                    </p>
                  </motion.div>
                )}

                <motion.div
                  variants={inputVariants}
                  className='flex space-x-3'
                >
                  <Button
                    onClick={() => setStep('info')}
                    variant='outline'
                    className='flex-1 h-11'
                  >
                    Back
                  </Button>
                  <Button
                    onClick={handleNextStep}
                    disabled={isPending}
                    className='flex-1 h-11 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white font-medium'
                  >
                    {isPending ? (
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                        className='w-4 h-4 border-2 border-white border-t-transparent rounded-full'
                      />
                    ) : (
                      <>
                        Create Account
                        <Sparkles className='ml-2 w-4 h-4' />
                      </>
                    )}
                  </Button>
                </motion.div>
              </motion.div>
            )}

            {step === 'complete' && (
              <motion.div
                key='complete'
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
                <h3 className='text-2xl font-bold text-gray-900 dark:text-white mb-2'>
                  Account Created!
                </h3>
                <p className='text-gray-600 dark:text-gray-400 mb-4'>
                  We&apos;ve sent a verification link to your email.
                </p>
                <div className='bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4 text-left'>
                  <p className='text-sm text-blue-700 dark:text-blue-300 font-medium mb-2'>
                    Next steps:
                  </p>
                  <ol className='text-sm text-blue-600 dark:text-blue-400 space-y-1'>
                    <li>1. Check your email inbox</li>
                    <li>2. Click the verification link</li>
                    <li>3. Log in to your account</li>
                  </ol>
                  <p className='text-xs text-blue-500 dark:text-blue-500 mt-3'>
                    Note: Check your spam folder if you don&apos;t see the email
                  </p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {step !== 'complete' && (
            <>
              {/* Divider */}
              <div className='relative my-6'>
                <div className='absolute inset-0 flex items-center'>
                  <div className='w-full border-t border-gray-200 dark:border-gray-700' />
                </div>
                <div className='relative flex justify-center text-xs uppercase'>
                  <span className='bg-white dark:bg-gray-900 px-2 text-gray-500 dark:text-gray-400'>
                    Or continue with
                  </span>
                </div>
              </div>

              {/* Social buttons */}
              <div className='grid grid-cols-2 gap-3'>
                <Button
                  variant='outline'
                  className='h-11 border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800'
                >
                  <Github className='mr-2 h-4 w-4' />
                  GitHub
                </Button>
                <Button
                  variant='outline'
                  className='h-11 border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800'
                >
                  <Chrome className='mr-2 h-4 w-4' />
                  Google
                </Button>
              </div>
            </>
          )}
        </div>

        {/* Footer */}
        {step !== 'complete' && (
          <div className='px-8 pb-8'>
            <p className='text-center text-sm text-gray-600 dark:text-gray-400'>
              Already have an account?{' '}
              <Link
                href='/auth/login'
                className='font-medium text-blue-600 hover:text-blue-500 transition-colors'
              >
                Sign in
              </Link>
            </p>
          </div>
        )}
      </motion.div>
    </div>
  );
}