'use client';

import { Suspense } from 'react';
import { MagicLinkVerify } from '@/components/auth/magic-link-verify';
import { Loader2 } from 'lucide-react';

function Loading() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <Loader2 className="h-8 w-8 animate-spin text-primary" />
    </div>
  );
}

export default function MagicLinkPage() {
  return (
    <Suspense fallback={<Loading />}>
      <MagicLinkVerify />
    </Suspense>
  );
}