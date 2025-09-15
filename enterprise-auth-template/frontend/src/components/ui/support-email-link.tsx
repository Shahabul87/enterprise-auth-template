'use client';

import React from 'react';
import { Button } from '@/components/ui/button';

interface SupportEmailLinkProps {
  email: string;
}

export function SupportEmailLink({ email }: SupportEmailLinkProps) {
  const handleClick = () => {
    const currentUrl = typeof window !== 'undefined' ? window.location.href : '';
    const subject = '404 Error Report';
    const body = `I encountered a 404 error at: ${currentUrl}`;
    const mailtoUrl = `mailto:${email}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
    window.location.href = mailtoUrl;
  };

  return (
    <Button variant='outline' size='sm' onClick={handleClick}>
      Contact Support
    </Button>
  );
}