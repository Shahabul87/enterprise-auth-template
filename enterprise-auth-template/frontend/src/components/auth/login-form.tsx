'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuthStore } from '@/stores/auth.store';
import { useFormErrorHandler } from '@/hooks/use-error-handler';
import { LoginFormData } from '@/types';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { PasswordInput } from '@/components/ui/password-input';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import { Separator } from '@/components/ui/separator';
import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { useAuthForm, validationRules, isFormValid } from '@/hooks/use-auth-form';
import {
  Loader2,
  Mail,
  Lock,
  ArrowRight,
  Shield,
  Sparkles
} from 'lucide-react';
import OAuthProviders from './oauth-providers';
import { TwoFactorVerify } from './two-factor-verify';
import { cn } from '@/lib/utils';

interface LoginFormProps {
  onSuccess?: () => void;
}

export function LoginForm({ onSuccess }: LoginFormProps): React.ReactElement {
  const { login, isLoading } = useAuthStore();
  const router = useRouter();
  const [tempToken, setTempToken] = useState<string | null>(null);
  const [show2FA, setShow2FA] = useState(false);
  const { handleFormError, clearAllErrors } = useFormErrorHandler();

  const { form, isSubmitting, error, setError, handleSubmit } = useAuthForm<LoginFormData>({
    defaultValues: {
      email: '',
      password: '',
      rememberMe: false,
    },
    onSuccess: async () => {
      if (onSuccess) {
        onSuccess();
      } else {
        router.push('/dashboard');
      }
    },
  });

  const onSubmit = handleSubmit(async (data: LoginFormData): Promise<boolean> => {
    clearAllErrors();
    try {
      // Use unified store login which handles token storage
      const response = await login({
        email: data.email,
        password: data.password,
      });

      if (response.success) {
        if (onSuccess) {
          onSuccess();
        } else {
          router.push('/dashboard');
        }
        return true;
      } else {
        setError(response.error?.message || 'Invalid email or password');
        return false;
      }
    } catch (error) {
      const standardError = handleFormError(error);
      setError(standardError.userMessage || 'An error occurred during login');
      return false;
    }
  });

  const handle2FASuccess = (): void => {
    // Store tokens and redirect
    if (typeof window !== 'undefined') {
      // The auth context will handle token storage
      window.location.href = onSuccess ? '/' : '/dashboard';
    }
  };

  const handle2FACancel = (): void => {
    setShow2FA(false);
    setTempToken(null);
    form.reset();
  };

  const formIsValid = isFormValid(form, ['email', 'password']);

  // Show 2FA verification if needed
  if (show2FA && tempToken) {
    return (
      <TwoFactorVerify
        tempToken={tempToken}
        onSuccess={handle2FASuccess}
        onCancel={handle2FACancel}
      />
    );
  }

  return (
    <div className="w-full max-w-md mx-auto">
      {/* Logo and Brand */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-primary/20 to-primary/10 mb-4">
          <Shield className="w-8 h-8 text-primary" />
        </div>
        <h1 className="text-3xl font-bold tracking-tight">Welcome back</h1>
        <p className="text-muted-foreground mt-2">
          Sign in to continue to your secure workspace
        </p>
      </div>

      <Card className="border-0 shadow-xl">
        <CardContent className="p-8">
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5">
            {error && (
              <Alert variant="destructive" className="bg-destructive/10 border-destructive/20">
                <AlertDescription className="text-sm">{error}</AlertDescription>
              </Alert>
            )}

            <FormField
              control={form.control}
              name="email"
              rules={validationRules.email}
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-medium">Email</FormLabel>
                  <FormControl>
                    <div className="relative">
                      <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                      <Input
                        type="email"
                        placeholder="name@company.com"
                        className="pl-10 h-11"
                        disabled={isLoading || isSubmitting}
                        {...field}
                      />
                    </div>
                  </FormControl>
                  <FormMessage className="text-xs" />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="password"
              rules={{
                required: 'Password is required',
                minLength: {
                  value: 1,
                  message: 'Password is required',
                },
              }}
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-sm font-medium">Password</FormLabel>
                  <FormControl>
                    <div className="relative">
                      <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                      <PasswordInput
                        placeholder="••••••••"
                        className="pl-10 h-11"
                        disabled={isLoading || isSubmitting}
                        {...field}
                      />
                    </div>
                  </FormControl>
                  <FormMessage className="text-xs" />
                </FormItem>
              )}
            />

            <div className="flex items-center justify-between">
              <FormField
                control={form.control}
                name="rememberMe"
                render={({ field }) => (
                  <div className="flex items-center space-x-2">
                    <Checkbox
                      id="remember"
                      checked={!!field.value}
                      onCheckedChange={field.onChange}
                      disabled={isLoading || isSubmitting}
                    />
                    <label
                      htmlFor="remember"
                      className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 cursor-pointer"
                    >
                      Remember me
                    </label>
                  </div>
                )}
              />
              <Link
                href="/auth/forgot-password"
                className="text-sm font-medium text-primary hover:text-primary/80 transition-colors"
              >
                Forgot password?
              </Link>
            </div>

            <Button
              type="submit"
              className="w-full h-11 font-medium bg-gradient-to-r from-primary to-primary/90 hover:from-primary/90 hover:to-primary/80 transition-all duration-200"
              disabled={!formIsValid || isLoading || isSubmitting}
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Signing in...
                </>
              ) : (
                <>
                  Sign in
                  <ArrowRight className="ml-2 h-4 w-4" />
                </>
              )}
            </Button>
          </form>

          {/* Divider */}
          <div className="relative my-6">
            <div className="absolute inset-0 flex items-center">
              <Separator className="w-full" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-background px-2 text-muted-foreground">Or continue with</span>
            </div>
          </div>

          {/* OAuth Providers */}
          <OAuthProviders className="mb-6" {...(onSuccess && { onSuccess })} />

          {/* Sign up link */}
          <div className="text-center text-sm">
            <span className="text-muted-foreground">New to our platform?</span>{' '}
            <Link
              href="/auth/register"
              className="font-medium text-primary hover:text-primary/80 transition-colors"
            >
              Create an account
            </Link>
          </div>

          {/* Security Badge */}
          <div className="mt-6 pt-6 border-t">
            <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground">
              <Sparkles className="h-3 w-3" />
              <span>Enterprise-grade security with end-to-end encryption</span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

export default LoginForm;
