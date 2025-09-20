'use client';

import { useAuthStore } from '@/stores/auth.store';
import { TwoFactorSetup } from '@/components/auth/two-factor-setup';
import { useRouter } from 'next/navigation';

export default function TwoFactorSetupPage(): React.ReactElement {
  const { isLoading, isAuthenticated } = useAuthStore();
  // Use isAuthenticated if needed
  isAuthenticated;
  const router = useRouter();

  if (isLoading) {
    return (
      <div className='flex items-center justify-center min-h-screen'>
        <div className='animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900'></div>
      </div>
    );
  }

  const handleComplete = () => {
    router.push('/profile?tab=security');
  };

  const handleCancel = () => {
    router.back();
  };

  return (
    <div className='flex flex-col min-h-screen bg-muted/50'>
      <header className='border-b bg-background'>
        <div className='container mx-auto px-4 py-4'>
          <h1 className='text-xl font-bold text-primary'>Two-Factor Authentication Setup</h1>
        </div>
      </header>

      <div className='flex-1 flex items-center justify-center p-4'>
        <div className='w-full max-w-2xl'>
          <TwoFactorSetup onComplete={handleComplete} onCancel={handleCancel} />
        </div>
      </div>
    </div>
  );
}