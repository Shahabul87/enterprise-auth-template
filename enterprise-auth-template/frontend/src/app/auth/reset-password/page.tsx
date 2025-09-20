'use client';

import { useSearchParams } from 'next/navigation';
import { useGuestOnly } from '@/stores/auth.store';
import { ModernResetPasswordForm } from '@/components/auth/modern-reset-password-form';
import { Suspense } from 'react';

function ResetPasswordContent(): React.ReactElement {
  const { isLoading } = useGuestOnly('/dashboard');
  const searchParams = useSearchParams();
  const token = searchParams.get('token') || '';

  if (isLoading) {
    return (
      <div className='relative min-h-screen flex items-center justify-center'>
        <div className='absolute inset-0 bg-gradient-to-br from-violet-50 via-purple-50 to-pink-50 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800'></div>
        <div className='relative'>
          <div className='animate-spin rounded-full h-12 w-12 border-4 border-violet-500 border-t-transparent'></div>
        </div>
      </div>
    );
  }

  return (
    <div className='relative min-h-screen overflow-hidden'>
      {/* Animated gradient background */}
      <div className='absolute inset-0'>
        <div className='absolute inset-0 bg-gradient-to-br from-violet-50 via-purple-50 to-pink-50 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800'></div>

        {/* Animated orbs */}
        <div className='absolute top-0 -left-4 w-72 h-72 bg-violet-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob dark:bg-violet-900 dark:opacity-30'></div>
        <div className='absolute top-0 -right-4 w-72 h-72 bg-purple-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob [animation-delay:2s] dark:bg-purple-900 dark:opacity-30'></div>
        <div className='absolute -bottom-8 left-20 w-72 h-72 bg-pink-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob [animation-delay:4s] dark:bg-pink-900 dark:opacity-30'></div>

        {/* Grid pattern overlay */}
        <div className='absolute inset-0 bg-[url("/grid.svg")] bg-center [mask-image:linear-gradient(180deg,white,rgba(255,255,255,0))]'></div>
      </div>

      {/* Content */}
      <div className='relative z-10 flex items-center justify-center min-h-screen p-4 py-12'>
        <ModernResetPasswordForm token={token} />
      </div>
    </div>
  );
}

export default function ResetPasswordPage(): React.ReactElement {
  return (
    <Suspense
      fallback={
        <div className='flex items-center justify-center min-h-screen'>
          <div className='animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900'></div>
        </div>
      }
    >
      <ResetPasswordContent />
    </Suspense>
  );
}
