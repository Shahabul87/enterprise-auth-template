'use client';

import { useGuestOnly } from '@/stores/auth.store';
import { ModernForgotPasswordForm } from '@/components/auth/modern-forgot-password-form';

export default function ForgotPasswordPage(): React.ReactElement {
  const { isLoading } = useGuestOnly('/dashboard');

  if (isLoading) {
    return (
      <div className='relative min-h-screen flex items-center justify-center'>
        <div className='absolute inset-0 bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800'></div>
        <div className='relative'>
          <div
            className='animate-spin rounded-full h-12 w-12 border-4 border-amber-500 border-t-transparent'
            role='status'
            aria-label='Loading'
          >
            <span className='sr-only'>Loading...</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className='relative min-h-screen overflow-hidden'>
      {/* Animated gradient background */}
      <div className='absolute inset-0'>
        <div className='absolute inset-0 bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800'></div>

        {/* Animated orbs */}
        <div className='absolute top-0 -left-4 w-72 h-72 bg-amber-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob dark:bg-amber-900 dark:opacity-30'></div>
        <div className='absolute top-0 -right-4 w-72 h-72 bg-orange-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob [animation-delay:2s] dark:bg-orange-900 dark:opacity-30'></div>
        <div className='absolute -bottom-8 left-20 w-72 h-72 bg-red-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob [animation-delay:4s] dark:bg-red-900 dark:opacity-30'></div>

        {/* Grid pattern overlay */}
        <div className='absolute inset-0 grid-pattern'></div>
      </div>

      {/* Content */}
      <div className='relative z-10 flex items-center justify-center min-h-screen p-4 py-12'>
        <ModernForgotPasswordForm />
      </div>
    </div>
  );
}
