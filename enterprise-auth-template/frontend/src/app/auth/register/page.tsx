'use client';

import { useGuestOnly } from '@/stores/auth.store';
import { RegisterForm } from '@/components/auth/register-form';

export default function RegisterPage(): JSX.Element {
  const { isLoading } = useGuestOnly('/dashboard');

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary/60"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50/30 flex items-center justify-center px-4 py-8">
      <RegisterForm />
    </div>
  );
}