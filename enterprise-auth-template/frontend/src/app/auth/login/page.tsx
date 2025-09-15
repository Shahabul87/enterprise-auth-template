'use client';

import { useGuestOnly } from '@/stores/auth.store';
import { EnhancedLoginForm } from '@/components/auth/enhanced-login-form';
import { AuthHeader } from '@/components/layout/auth-header';

export default function LoginPage(): JSX.Element {
  const { isLoading } = useGuestOnly('/dashboard');

  if (isLoading) {
    return (
      <div className='flex items-center justify-center min-h-screen'>
        <div className='animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900'></div>
      </div>
    );
  }

  return (
    <>
      <AuthHeader />
      <div className='flex items-center justify-center min-h-screen pt-16 p-4'>
        <EnhancedLoginForm />
      </div>
    </>
  );
}
