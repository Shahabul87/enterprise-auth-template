'use client';

import { useState, useEffect, Suspense } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
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
  Inbox,
  ExternalLink,
  CheckCircle,
  Info,
  ArrowLeft,
} from 'lucide-react';

function VerifyEmailContent(): React.ReactElement {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { resendVerification } = useAuthStore();
  const [email, setEmail] = useState('');
  const [resendStatus, setResendStatus] = useState<'idle' | 'sending' | 'sent' | 'error'>('idle');
  const [resendCooldown, setResendCooldown] = useState(0);
  const [resendMessage, setResendMessage] = useState('');

  useEffect(() => {
    // Get email from query params or localStorage
    const emailParam = searchParams.get('email');
    const storedEmail = localStorage.getItem('registrationEmail');
    setEmail(emailParam || storedEmail || '');
  }, [searchParams]);

  useEffect(() => {
    if (resendCooldown > 0) {
      const timer = setTimeout(() => setResendCooldown(resendCooldown - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [resendCooldown]);

  const handleResendEmail = async (): Promise<void> => {
    if (resendCooldown > 0) return;

    setResendStatus('sending');
    setResendMessage('');

    try {
      const response = await resendVerification();
      if (response.success) {
        setResendStatus('sent');
        setResendMessage('Verification email sent successfully!');
        setResendCooldown(60);
      } else {
        setResendStatus('error');
        setResendMessage(response.error?.message || 'Failed to resend verification email');
      }
    } catch (err) {
      setResendStatus('error');
      setResendMessage('Failed to resend verification email. Please try again.');
    }

    // Reset status after 5 seconds
    setTimeout(() => {
      setResendStatus('idle');
      setResendMessage('');
    }, 5000);
  };

  const emailProviders = [
    { name: 'Gmail', url: 'https://mail.google.com', icon: '📧' },
    { name: 'Outlook', url: 'https://outlook.live.com', icon: '📨' },
    { name: 'Yahoo', url: 'https://mail.yahoo.com', icon: '📮' },
    { name: 'iCloud', url: 'https://www.icloud.com/mail', icon: '☁️' },
  ];

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
          className='w-full max-w-lg mx-auto'
        >
          <div className='bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl rounded-2xl shadow-2xl border border-gray-200/50 dark:border-gray-700/50 overflow-hidden'>
            {/* Header */}
            <div className='relative p-8 pb-6'>
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
                className='w-16 h-16 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-2xl flex items-center justify-center mb-6 mx-auto'
              >
                <Inbox className='w-8 h-8 text-white' />
              </motion.div>

              <motion.h2
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                className='text-3xl font-bold text-center bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent'
              >
                Check Your Email
              </motion.h2>

              <motion.p
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.4 }}
                className='text-center text-gray-600 dark:text-gray-400 mt-2'
              >
                {email
                  ? `We've sent a verification link to ${email}`
                  : "We've sent a verification link to your email address"}
              </motion.p>
            </div>

            {/* Content */}
            <div className='p-8 pt-0'>
              <motion.div
                variants={containerVariants}
                initial='hidden'
                animate='visible'
                className='space-y-6'
              >
                {/* Steps */}
                <motion.div variants={itemVariants} className='space-y-3'>
                  <div className='flex items-start space-x-3'>
                    <div className='flex-shrink-0 w-8 h-8 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center'>
                      <span className='text-sm font-semibold text-blue-600 dark:text-blue-400'>1</span>
                    </div>
                    <div>
                      <p className='text-sm font-medium text-gray-900 dark:text-white'>
                        Open your email inbox
                      </p>
                      <p className='text-xs text-gray-500 dark:text-gray-400 mt-1'>
                        Look for an email from our team
                      </p>
                    </div>
                  </div>

                  <div className='flex items-start space-x-3'>
                    <div className='flex-shrink-0 w-8 h-8 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center'>
                      <span className='text-sm font-semibold text-blue-600 dark:text-blue-400'>2</span>
                    </div>
                    <div>
                      <p className='text-sm font-medium text-gray-900 dark:text-white'>
                        Click the verification link
                      </p>
                      <p className='text-xs text-gray-500 dark:text-gray-400 mt-1'>
                        The link will verify your account instantly
                      </p>
                    </div>
                  </div>

                  <div className='flex items-start space-x-3'>
                    <div className='flex-shrink-0 w-8 h-8 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center'>
                      <span className='text-sm font-semibold text-blue-600 dark:text-blue-400'>3</span>
                    </div>
                    <div>
                      <p className='text-sm font-medium text-gray-900 dark:text-white'>
                        Start using your account
                      </p>
                      <p className='text-xs text-gray-500 dark:text-gray-400 mt-1'>
                        You'll be redirected to login after verification
                      </p>
                    </div>
                  </div>
                </motion.div>

                {/* Quick Links to Email Providers */}
                <motion.div variants={itemVariants}>
                  <div className='bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-xl p-4'>
                    <div className='flex items-center justify-center mb-3'>
                      <div className='h-px bg-gradient-to-r from-transparent via-blue-300 dark:via-blue-700 to-transparent flex-1' />
                      <p className='text-xs font-semibold text-blue-700 dark:text-blue-400 px-3 uppercase tracking-wider'>
                        Quick Access
                      </p>
                      <div className='h-px bg-gradient-to-r from-transparent via-blue-300 dark:via-blue-700 to-transparent flex-1' />
                    </div>
                    <div className='grid grid-cols-4 gap-2'>
                      {emailProviders.map((provider, index) => (
                        <motion.a
                          key={provider.name}
                          href={provider.url}
                          target='_blank'
                          rel='noopener noreferrer'
                          initial={{ opacity: 0, y: 10 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: 0.5 + index * 0.1 }}
                          whileHover={{ scale: 1.05, y: -2 }}
                          whileTap={{ scale: 0.95 }}
                          className='group relative flex flex-col items-center justify-center p-3 bg-white dark:bg-gray-800 rounded-xl shadow-sm hover:shadow-md transition-all duration-200 border border-gray-200/50 dark:border-gray-700/50'
                        >
                          <div className='absolute inset-0 bg-gradient-to-br from-blue-400/0 to-indigo-400/0 group-hover:from-blue-400/10 group-hover:to-indigo-400/10 rounded-xl transition-all duration-300' />
                          <span className='text-2xl mb-1 transform group-hover:scale-110 transition-transform duration-200'>
                            {provider.icon}
                          </span>
                          <span className='text-xs font-medium text-gray-700 dark:text-gray-300 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors'>
                            {provider.name}
                          </span>
                          <ExternalLink className='absolute top-1 right-1 w-2.5 h-2.5 text-gray-400 opacity-0 group-hover:opacity-100 transition-opacity' />
                        </motion.a>
                      ))}
                    </div>
                  </div>
                </motion.div>

                {/* Resend Section */}
                <motion.div variants={itemVariants} className='space-y-3'>
                  <div className='relative my-4'>
                    <div className='absolute inset-0 flex items-center'>
                      <div className='w-full h-px bg-gradient-to-r from-transparent via-gray-300 dark:via-gray-600 to-transparent' />
                    </div>
                    <div className='relative flex justify-center'>
                      <span className='bg-white dark:bg-gray-900 px-4 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider'>
                        Still waiting?
                      </span>
                    </div>
                  </div>

                  <motion.button
                    onClick={handleResendEmail}
                    disabled={resendCooldown > 0 || resendStatus === 'sending'}
                    whileHover={{ scale: resendCooldown > 0 || resendStatus === 'sending' ? 1 : 1.02 }}
                    whileTap={{ scale: resendCooldown > 0 || resendStatus === 'sending' ? 1 : 0.98 }}
                    className={cn(
                      'relative w-full h-12 rounded-xl font-medium transition-all duration-200 flex items-center justify-center gap-2 overflow-hidden',
                      resendCooldown > 0 || resendStatus === 'sending'
                        ? 'bg-gray-100 dark:bg-gray-800 text-gray-400 dark:text-gray-500 cursor-not-allowed'
                        : 'bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white shadow-lg hover:shadow-xl'
                    )}
                  >
                    {/* Animated background gradient */}
                    {!(resendCooldown > 0 || resendStatus === 'sending') && (
                      <motion.div
                        className='absolute inset-0 bg-gradient-to-r from-blue-400/20 via-indigo-400/20 to-blue-400/20'
                        animate={{
                          x: ['0%', '100%', '0%'],
                        }}
                        transition={{
                          duration: 3,
                          repeat: Infinity,
                          ease: 'linear',
                        }}
                        style={{ width: '200%' }}
                      />
                    )}

                    {/* Button content */}
                    <div className='relative flex items-center justify-center'>
                      {resendStatus === 'sending' ? (
                        <>
                          <motion.div
                            animate={{ rotate: 360 }}
                            transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                            className='w-5 h-5 border-2 border-blue-600 dark:border-blue-400 border-t-transparent rounded-full'
                          />
                          <span className='ml-2'>Sending email...</span>
                        </>
                      ) : resendCooldown > 0 ? (
                        <>
                          <div className='relative'>
                            <Clock className='w-5 h-5' />
                            <motion.div
                              className='absolute inset-0 border-2 border-blue-600 dark:border-blue-400 rounded-full'
                              initial={{ pathLength: 1 }}
                              animate={{ pathLength: 0 }}
                              transition={{ duration: resendCooldown, ease: 'linear' }}
                            />
                          </div>
                          <span className='ml-2'>Resend available in {resendCooldown}s</span>
                        </>
                      ) : (
                        <>
                          <Mail className='w-5 h-5' />
                          <span className='ml-2'>Resend Verification Email</span>
                          <motion.div
                            initial={{ x: -10, opacity: 0 }}
                            animate={{ x: 0, opacity: 1 }}
                            transition={{ delay: 0.2 }}
                          >
                            <Send className='w-4 h-4 ml-1' />
                          </motion.div>
                        </>
                      )}
                    </div>
                  </motion.button>

                  {/* Resend Status Messages */}
                  <AnimatePresence>
                    {resendMessage && (
                      <motion.div
                        initial={{ opacity: 0, y: -10 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -10 }}
                        className={cn(
                          'text-sm text-center p-2 rounded-lg',
                          resendStatus === 'sent'
                            ? 'bg-green-50 text-green-700 dark:bg-green-900/20 dark:text-green-400'
                            : 'bg-red-50 text-red-700 dark:bg-red-900/20 dark:text-red-400'
                        )}
                      >
                        {resendStatus === 'sent' && <CheckCircle className='w-4 h-4 inline mr-1' />}
                        {resendStatus === 'error' && <AlertCircle className='w-4 h-4 inline mr-1' />}
                        {resendMessage}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </motion.div>

                {/* Tips */}
                <motion.div
                  variants={itemVariants}
                  className='p-4 bg-amber-50 dark:bg-amber-900/20 rounded-lg border border-amber-200 dark:border-amber-800'
                >
                  <div className='flex items-start'>
                    <Info className='w-4 h-4 text-amber-600 dark:text-amber-400 mt-0.5 mr-2 flex-shrink-0' />
                    <div className='text-sm text-amber-700 dark:text-amber-300'>
                      <p className='font-medium mb-1'>Can't find the email?</p>
                      <ul className='text-xs space-y-1 opacity-90'>
                        <li>• Check your spam or junk folder</li>
                        <li>• Add our email to your contacts</li>
                        <li>• Wait a few minutes for delivery</li>
                      </ul>
                    </div>
                  </div>
                </motion.div>
              </motion.div>
            </div>

            {/* Footer */}
            <div className='px-8 pb-8'>
              <div className='flex items-center justify-between'>
                <Link
                  href='/auth/register'
                  className='text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white transition-colors flex items-center'
                >
                  <ArrowLeft className='w-3 h-3 mr-1' />
                  Back to register
                </Link>
                <Link
                  href='/auth/login'
                  className='text-sm font-medium text-blue-600 hover:text-blue-500 transition-colors flex items-center'
                >
                  Go to login
                  <ArrowRight className='w-3 h-3 ml-1' />
                </Link>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}

export default function VerifyEmailPage(): React.ReactElement {
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