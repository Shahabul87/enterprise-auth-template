'use client';

import React from 'react';
import { Button } from '@/components/ui/button';
import { ArrowLeft } from 'lucide-react';

interface BackButtonProps {
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link';
  size?: 'default' | 'sm' | 'lg' | 'icon';
  className?: string;
}

export function BackButton({ variant = 'outline', size = 'lg', className = '' }: BackButtonProps) {
  return (
    <Button
      variant={variant}
      size={size}
      onClick={() => window.history.back()}
      className={className}
    >
      <ArrowLeft className='mr-2 h-4 w-4' />
      Go Back
    </Button>
  );
}