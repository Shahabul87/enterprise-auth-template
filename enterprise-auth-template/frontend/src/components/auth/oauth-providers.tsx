'use client';

import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Separator } from '@/components/ui/separator';
import { Loader2, AlertCircle } from 'lucide-react';
import { Icons } from '@/components/icons';

interface OAuthProvidersProps {
  className?: string;
  onSuccess?: () => void;
}

interface OAuthProvider {
  name: string;
  id: string;
  icon: React.ReactNode;
  bgColor: string;
  textColor: string;
}

const providers: OAuthProvider[] = [
  {
    id: 'google',
    name: 'Google',
    icon: <Icons.google className='h-5 w-5' />,
    bgColor: 'bg-white hover:bg-gray-50',
    textColor: 'text-gray-700',
  },
  {
    id: 'github',
    name: 'GitHub',
    icon: <Icons.gitHub className='h-5 w-5' />,
    bgColor: 'bg-gray-900 hover:bg-gray-800',
    textColor: 'text-white',
  },
  {
    id: 'discord',
    name: 'Discord',
    icon: <Icons.discord className='h-5 w-5' />,
    bgColor: 'bg-indigo-600 hover:bg-indigo-700',
    textColor: 'text-white',
  },
];

export default function OAuthProviders({ className }: OAuthProvidersProps): JSX.Element {
  const [loading, setLoading] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleOAuthLogin = async (providerId: string): Promise<void> => {
    setLoading(providerId);
    setError(null);

    try {
      // Get OAuth initialization from backend
      const response = await fetch(
        `${process.env['NEXT_PUBLIC_API_URL'] || 'http://localhost:8000'}/api/v1/oauth/${providerId}/init`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );

      if (!response.ok) {
        throw new Error(`OAuth initialization failed: ${response.status}`);
      }

      const data = await response.json();

      // Store only provider info in session storage (state is handled server-side)
      // SECURITY: We don't store the state client-side to prevent XSS attacks
      if (typeof window !== 'undefined') {
        sessionStorage.setItem('oauth_provider', providerId);
        // Store return URL for post-authentication redirect
        const returnUrl = window.location.pathname + window.location.search;
        sessionStorage.setItem('oauth_return_url', returnUrl);
      }

      // Redirect to OAuth provider
      window.location.href = data.authorization_url;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'OAuth login failed';
      setError(errorMessage);
      setLoading(null);
    }
  };

  return (
    <div className={className}>
      <div className='relative'>
        <div className='absolute inset-0 flex items-center'>
          <Separator />
        </div>
        <div className='relative flex justify-center text-xs uppercase'>
          <span className='bg-background px-2 text-muted-foreground'>Or continue with</span>
        </div>
      </div>

      {error && (
        <Alert variant='destructive' className='mt-4'>
          <AlertCircle className='h-4 w-4' />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      <div className='mt-4 grid grid-cols-1 gap-2'>
        {providers.map((provider) => (
          <Button
            key={provider.id}
            variant='outline'
            className={`${provider.bgColor} ${provider.textColor} border`}
            onClick={() => handleOAuthLogin(provider.id)}
            disabled={loading !== null}
          >
            {loading === provider.id ? (
              <Loader2 className='mr-2 h-4 w-4 animate-spin' />
            ) : (
              <span className='mr-2'>{provider.icon}</span>
            )}
            Continue with {provider.name}
          </Button>
        ))}
      </div>
    </div>
  );
}
