'use client';

/**
 * Enhanced Login Form with WebAuthn Support
 * 
 * Provides multiple authentication options:
 * - WebAuthn/Passkeys (preferred)
 * - Email/Password (fallback)
 * - OAuth providers
 * - Two-factor authentication
 * 
 * Features seamless switching between authentication methods
 * based on user preference and device capabilities.
 */

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Separator } from '@/components/ui/separator';
import { Alert, AlertDescription } from '@/components/ui/alert';
import {
  Fingerprint,
  Mail,
  Shield,
  Info,
  ArrowRight,
  Sparkles,
} from 'lucide-react';
import { WebAuthnLogin } from './webauthn-login';
import { LoginForm } from './login-form';
import { MagicLinkRequest } from './magic-link-request';
import OAuthProviders from './oauth-providers';
import { webAuthnUtils } from '@/lib/webauthn-client';

interface EnhancedLoginFormProps {
  onSuccess?: () => void;
  /** Initial authentication method to show */
  initialMethod?: 'passkey' | 'password' | 'magic-link';
}

export function EnhancedLoginForm({ 
  onSuccess,
  initialMethod = 'passkey',
}: EnhancedLoginFormProps): JSX.Element {
  const router = useRouter();
  const [currentMethod, setCurrentMethod] = useState(initialMethod);
  const [isWebAuthnSupported, setIsWebAuthnSupported] = useState(false);
  const [platformInfo, setPlatformInfo] = useState<{
    platform: string;
    supportMessage: string;
  } | null>(null);

  // Check WebAuthn support and capabilities
  useEffect(() => {
    const checkWebAuthnSupport = async () => {
      const supported = webAuthnUtils.isSupported();
      setIsWebAuthnSupported(supported);

      if (supported) {
        setPlatformInfo(webAuthnUtils.getPlatformInfo());
        
        // If passkey was requested but not supported, fallback to password
        if (initialMethod === 'passkey' && !supported) {
          setCurrentMethod('password');
        }
      } else {
        // Force password method if WebAuthn not supported
        setCurrentMethod('password');
      }
    };

    checkWebAuthnSupport();
  }, [initialMethod]);

  const handleAuthSuccess = (result?: {
    data?: { access_token?: string };
  }) => {
    if (result?.data?.access_token) {
      // Handle WebAuthn authentication success
      // The token should be automatically set by the API client
      if (onSuccess) {
        onSuccess();
      } else {
        router.push('/dashboard');
      }
    } else {
      // Handle other authentication methods
      if (onSuccess) {
        onSuccess();
      } else {
        router.push('/dashboard');
      }
    }
  };

  const handleShowPasswordLogin = () => {
    setCurrentMethod('password');
  };

  const handleShowPasskeyLogin = () => {
    setCurrentMethod('passkey');
  };

  const handleShowMagicLink = () => {
    setCurrentMethod('magic-link');
  };

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader className="text-center">
          <CardTitle className="flex items-center justify-center gap-2">
            <Shield className="h-6 w-6" />
            Welcome back
          </CardTitle>
          <CardDescription>
            Choose your preferred way to sign in
          </CardDescription>
        </CardHeader>
        
        <CardContent>
          <Tabs value={currentMethod} onValueChange={(value) => setCurrentMethod(value as 'passkey' | 'password' | 'magic-link')}>
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="passkey" disabled={!isWebAuthnSupported}>
                <Fingerprint className="h-4 w-4 mr-2" />
                Passkey
              </TabsTrigger>
              <TabsTrigger value="password">
                <Mail className="h-4 w-4 mr-2" />
                Password
              </TabsTrigger>
              <TabsTrigger value="magic-link">
                <Sparkles className="h-4 w-4 mr-2" />
                Magic Link
              </TabsTrigger>
            </TabsList>

            <div className="mt-6">
              <TabsContent value="passkey" className="space-y-4">
                {isWebAuthnSupported ? (
                  <WebAuthnLogin
                    onSuccess={handleAuthSuccess}
                    onShowPasswordLogin={handleShowPasswordLogin}
                    showEmailInput={true}
                  />
                ) : (
                  <Alert>
                    <Info className="h-4 w-4" />
                    <AlertDescription>
                      Passkeys are not supported in this browser. Please use password login instead.
                    </AlertDescription>
                  </Alert>
                )}
              </TabsContent>

              <TabsContent value="password" className="space-y-4">
                <LoginForm onSuccess={handleAuthSuccess} />
                
                <div className="space-y-2">
                  <Separator />
                  <div className="text-center space-y-2">
                    {isWebAuthnSupported && (
                      <Button 
                        variant="outline" 
                        onClick={handleShowPasskeyLogin}
                        className="w-full"
                      >
                        <Fingerprint className="h-4 w-4 mr-2" />
                        Use passkey instead
                      </Button>
                    )}
                    <Button 
                      variant="outline" 
                      onClick={handleShowMagicLink}
                      className="w-full"
                    >
                      <Sparkles className="h-4 w-4 mr-2" />
                      Sign in without password
                    </Button>
                  </div>
                </div>
              </TabsContent>

              <TabsContent value="magic-link" className="space-y-4">
                <MagicLinkRequest 
                  onBack={() => setCurrentMethod('password')}
                />
              </TabsContent>
            </div>
          </Tabs>

          <div className="mt-6 space-y-4">
            <Separator />
            
            {/* OAuth Providers */}
            <div>
              <p className="text-sm text-muted-foreground text-center mb-4">
                Or continue with
              </p>
              <OAuthProviders onSuccess={handleAuthSuccess} />
            </div>
          </div>

          {/* Information about passkeys */}
          {isWebAuthnSupported && currentMethod === 'passkey' && platformInfo && (
            <div className="mt-6 p-4 bg-muted rounded-lg">
              <div className="flex items-start gap-3">
                <Info className="h-5 w-5 text-muted-foreground mt-0.5" />
                <div className="text-sm space-y-2">
                  <p className="font-medium">
                    About passkeys on {platformInfo.platform}
                  </p>
                  <p className="text-muted-foreground">
                    {platformInfo.supportMessage}. Passkeys are more secure than passwords 
                    and work only on the correct website.
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Registration link */}
          <div className="mt-6 text-center text-sm text-muted-foreground">
            Don&apos;t have an account?{' '}
            <Link 
              href="/auth/register" 
              className="text-primary hover:underline font-medium"
            >
              Create account
              <ArrowRight className="h-3 w-3 ml-1 inline" />
            </Link>
          </div>
        </CardContent>
      </Card>

      {/* Help text */}
      <div className="text-center space-y-2">
        <div className="text-xs text-muted-foreground">
          <Link 
            href="/auth/forgot-password"
            className="hover:underline"
          >
            Forgot your password?
          </Link>
          {' • '}
          <Link 
            href="/support"
            className="hover:underline"
          >
            Need help?
          </Link>
        </div>
      </div>
    </div>
  );
}

/**
 * Quick Passkey Login Component
 * 
 * A streamlined component that prioritizes passkey authentication
 * with minimal UI for users who primarily use passkeys.
 */
export function QuickPasskeyLogin({ 
  onSuccess,
}: { onSuccess?: () => void }): JSX.Element {
  const [showFullForm, setShowFullForm] = useState(false);

  if (showFullForm) {
    return <EnhancedLoginForm onSuccess={onSuccess || (() => {})} initialMethod="password" />;
  }

  if (!webAuthnUtils.isSupported()) {
    return <EnhancedLoginForm onSuccess={onSuccess || (() => {})} initialMethod="password" />;
  }

  return (
    <Card>
      <CardHeader className="text-center">
        <CardTitle className="flex items-center justify-center gap-2">
          <Fingerprint className="h-6 w-6" />
          Quick Sign In
        </CardTitle>
        <CardDescription>
          Use your passkey for instant access
        </CardDescription>
      </CardHeader>
      
      <CardContent className="space-y-4">
        <WebAuthnLogin
          onSuccess={onSuccess || (() => {})}
          onShowPasswordLogin={() => setShowFullForm(true)}
          showEmailInput={false}
        />
        
        <Separator />
        
        <div className="text-center">
          <Button 
            variant="ghost" 
            size="sm"
            onClick={() => setShowFullForm(true)}
            className="text-muted-foreground"
          >
            More sign in options
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}