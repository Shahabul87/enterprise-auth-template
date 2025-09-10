'use client';

import { useRouter } from 'next/navigation';
import { MagicLinkRequest } from '@/components/auth/magic-link-request';

export default function MagicLinkRequestPage() {
  const router = useRouter();

  const handleBack = () => {
    router.push('/auth/login');
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-gradient-to-b from-background to-muted">
      <MagicLinkRequest onBack={handleBack} />
    </div>
  );
}