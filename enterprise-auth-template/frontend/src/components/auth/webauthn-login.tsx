'use client';

/**
 * WebAuthn Login Component
 * 
 * Provides passkey authentication interface including:
 * - One-click passkey login
 * - Email-specific passkey login
 * - Cross-platform compatibility messaging
 * - Fallback to password authentication
 * 
 * Integrates with the main authentication flow.
 */

import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Separator } from '@/components/ui/separator';
import {
  Shield,
  Fingerprint,
  Smartphone,
  AlertTriangle,
  ArrowLeft,
  Mail,
} from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { webAuthnService, webAuthnUtils } from '@/lib/webauthn-client';

interface WebAuthnLoginProps {
  /** Callback when authentication succeeds */
  onSuccess: (result: { data?: { access_token?: string }; [key: string]: unknown }) => void;
  /** Callback to show password login form */
  onShowPasswordLogin: () => void;
  /** Pre-filled email address */
  initialEmail?: string;
  /** Whether to show email input */
  showEmailInput?: boolean;
}

export function WebAuthnLogin({ 
  onSuccess, 
  onShowPasswordLogin,
  initialEmail = '',
  showEmailInput = true,
}: WebAuthnLoginProps) {
  const [email, setEmail] = useState(initialEmail);
  const [isAuthenticating, setIsAuthenticating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isSupported, setIsSupported] = useState(false);
  const [platformInfo, setPlatformInfo] = useState<{
    platform: string;
    supportMessage?: string;
    authenticatorName?: string;
  } | null>(null);
  const { toast } = useToast();

  // Check WebAuthn support on component mount
  useEffect(() => {
    const supported = webAuthnUtils.isSupported();
    setIsSupported(supported);

    if (supported) {
      setPlatformInfo(webAuthnUtils.getPlatformInfo());
    }
  }, []);

  const handlePasskeyLogin = async () => {
    if (!isSupported) {
      toast({
        title: 'Not supported',
        description: 'Passkeys are not supported in this browser.',
        variant: 'destructive',
      });
      return;
    }

    try {
      setIsAuthenticating(true);
      setError(null);

      // Authenticate with WebAuthn (email is optional for discoverable credentials)
      const result = await webAuthnService.authenticate(
        showEmailInput && email.trim() ? email.trim() : undefined
      );

      toast({
        title: 'Welcome back!',
        description: 'You have been successfully signed in with your passkey.',
      });

      // Call success callback with authentication result
      onSuccess({ 
        data: { access_token: result.access_token },
        ...result 
      });

    } catch (err: unknown) {
      // WebAuthn authentication failed - error already handled by service layer
      
      const errorMessage = webAuthnUtils.getErrorMessage(err);
      setError(errorMessage);

      toast({
        title: 'Authentication failed',
        description: errorMessage,
        variant: 'destructive',
      });

    } finally {
      setIsAuthenticating(false);
    }
  };

  const handleDiscoverableLogin = async () => {
    try {
      setIsAuthenticating(true);
      setError(null);

      // Authenticate without email (discoverable credentials)
      const result = await webAuthnService.authenticate();

      toast({
        title: 'Welcome back!',
        description: 'You have been successfully signed in with your passkey.',
      });

      onSuccess({ 
        data: { access_token: result.access_token },
        ...result 
      });

    } catch (err: unknown) {
      // Discoverable WebAuthn authentication failed - error already handled by service layer
      
      const errorMessage = webAuthnUtils.getErrorMessage(err);
      setError(errorMessage);

      toast({
        title: 'Authentication failed',
        description: errorMessage,
        variant: 'destructive',
      });

    } finally {
      setIsAuthenticating(false);
    }
  };

  // If WebAuthn is not supported, show fallback
  if (!isSupported) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            Passkey Login
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Alert>
            <AlertTriangle className="h-4 w-4" />
            <AlertDescription>
              Passkeys are not supported in this browser. Please use password login instead.
            </AlertDescription>
          </Alert>
          <div className="mt-4">
            <Button onClick={onShowPasswordLogin} className="w-full">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Use password instead
            </Button>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Fingerprint className="h-5 w-5" />
          Sign in with passkey
        </CardTitle>
        <CardDescription>
          {platformInfo?.supportMessage || 'Use your saved passkey to sign in securely'}
        </CardDescription>
      </CardHeader>
      
      <CardContent className="space-y-6">
        {error && (
          <Alert variant="destructive">
            <AlertTriangle className="h-4 w-4" />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {showEmailInput && (
          <div className="space-y-4">
            <div>
              <Label htmlFor="email">Email address (optional)</Label>
              <Input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Enter your email"
                disabled={isAuthenticating}
              />
              <p className="text-sm text-muted-foreground mt-1">
                Leave empty to use any passkey on this device
              </p>
            </div>

            <Button 
              onClick={handlePasskeyLogin}
              disabled={isAuthenticating}
              className="w-full"
              size="lg"
            >
              {isAuthenticating ? (
                'Authenticating...'
              ) : (
                <>
                  <Fingerprint className="h-4 w-4 mr-2" />
                  Sign in with passkey
                </>
              )}
            </Button>

            <Separator />
            
            <div className="text-center">
              <p className="text-sm text-muted-foreground mb-3">
                Or use any passkey saved on this device
              </p>
              <Button 
                variant="outline"
                onClick={handleDiscoverableLogin}
                disabled={isAuthenticating}
                className="w-full"
              >
                <Smartphone className="h-4 w-4 mr-2" />
                Use any saved passkey
              </Button>
            </div>
          </div>
        )}

        {!showEmailInput && (
          <Button 
            onClick={handleDiscoverableLogin}
            disabled={isAuthenticating}
            className="w-full"
            size="lg"
          >
            {isAuthenticating ? (
              'Authenticating...'
            ) : (
              <>
                <Fingerprint className="h-4 w-4 mr-2" />
                Sign in with passkey
              </>
            )}
          </Button>
        )}

        <Separator />

        <div className="space-y-3">
          <Button 
            variant="outline" 
            onClick={onShowPasswordLogin}
            disabled={isAuthenticating}
            className="w-full"
          >
            <Mail className="h-4 w-4 mr-2" />
            Use password instead
          </Button>

          {platformInfo && (
            <div className="text-center text-sm text-muted-foreground">
              <p>
                <strong>{platformInfo.authenticatorName}</strong> available on {platformInfo.platform}
              </p>
            </div>
          )}
        </div>

        <div className="text-xs text-muted-foreground space-y-2">
          <h4 className="font-medium text-foreground">About passkeys:</h4>
          <ul className="space-y-1 ml-4">
            <li>• More secure than passwords</li>
            <li>• Protected by your device&apos;s security</li>
            <li>• Works only on the correct website</li>
            <li>• No need to remember passwords</li>
          </ul>
        </div>
      </CardContent>
    </Card>
  );
}

/**
 * Simplified WebAuthn Login Button
 * 
 * A minimal button component for integrating passkey login
 * into existing authentication forms.
 */
interface WebAuthnLoginButtonProps {
  onSuccess: (result: { data?: { access_token?: string }; [key: string]: unknown }) => void;
  email?: string;
  disabled?: boolean;
  className?: string;
}

export function WebAuthnLoginButton({ 
  onSuccess, 
  email,
  disabled = false,
  className = '',
}: WebAuthnLoginButtonProps) {
  const [isAuthenticating, setIsAuthenticating] = useState(false);
  const { toast } = useToast();

  const handleLogin = async () => {
    if (!webAuthnUtils.isSupported()) {
      toast({
        title: 'Not supported',
        description: 'Passkeys are not supported in this browser.',
        variant: 'destructive',
      });
      return;
    }

    try {
      setIsAuthenticating(true);

      const result = await webAuthnService.authenticate(email);
      
      toast({
        title: 'Welcome back!',
        description: 'Signed in with passkey.',
      });

      onSuccess({ 
        data: { access_token: result.access_token },
        ...result 
      });

    } catch (err: unknown) {
      const errorMessage = webAuthnUtils.getErrorMessage(err);
      toast({
        title: 'Authentication failed',
        description: errorMessage,
        variant: 'destructive',
      });

    } finally {
      setIsAuthenticating(false);
    }
  };

  if (!webAuthnUtils.isSupported()) {
    return null;
  }

  return (
    <Button
      variant="outline"
      onClick={handleLogin}
      disabled={disabled || isAuthenticating}
      className={`${className}`}
    >
      {isAuthenticating ? (
        'Authenticating...'
      ) : (
        <>
          <Fingerprint className="h-4 w-4 mr-2" />
          Sign in with passkey
        </>
      )}
    </Button>
  );
}