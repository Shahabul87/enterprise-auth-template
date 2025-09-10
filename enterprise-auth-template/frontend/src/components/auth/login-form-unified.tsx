'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { Loader2, Mail, Lock, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Checkbox } from '@/components/ui/checkbox';
import Link from 'next/link';

// Use unified auth store instead of context
import { useAuthStore } from '@/stores/auth.store';
import { useFormErrorHandler } from '@/hooks/use-error-handler';

// Validation schema
const loginSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(1, 'Password is required'),
  rememberMe: z.boolean().optional(),
});

type LoginFormData = z.infer<typeof loginSchema>;

export function LoginFormUnified() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  
  // Use unified auth store
  const { login, error: authError } = useAuthStore();
  
  // Use form error handler
  const { handleFormError, clearAllErrors, getFieldError } = useFormErrorHandler();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: '',
      password: '',
      rememberMe: false,
    },
  });

  const onSubmit = async (data: LoginFormData) => {
    setIsLoading(true);
    clearAllErrors();

    try {
      const response = await login({
        email: data.email,
        password: data.password,
      });

      if (response.success) {
        // Redirect to dashboard or requested page
        const redirectTo = new URLSearchParams(window.location.search).get('from') || '/dashboard';
        router.push(redirectTo);
      } else {
        // Error is automatically handled by the store
        // Additional handling can be done here if needed
      }
    } catch (error) {
      // Handle any unexpected errors
      handleFormError(error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      {/* Display auth error if exists */}
      {authError && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{authError.message}</AlertDescription>
        </Alert>
      )}

      {/* Email field */}
      <div className="space-y-2">
        <Label htmlFor="email">Email</Label>
        <div className="relative">
          <Mail className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
          <Input
            {...register('email')}
            id="email"
            type="email"
            placeholder="you@example.com"
            className={`pl-10 ${errors.email || getFieldError('email') ? 'border-red-500' : ''}`}
            disabled={isLoading}
            autoComplete="email"
          />
        </div>
        {(errors.email || getFieldError('email')) && (
          <p className="text-sm text-red-500">
            {errors.email?.message || getFieldError('email')}
          </p>
        )}
      </div>

      {/* Password field */}
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <Label htmlFor="password">Password</Label>
          <Link
            href="/auth/forgot-password"
            className="text-sm text-primary hover:underline"
          >
            Forgot password?
          </Link>
        </div>
        <div className="relative">
          <Lock className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
          <Input
            {...register('password')}
            id="password"
            type="password"
            placeholder="••••••••"
            className={`pl-10 ${errors.password || getFieldError('password') ? 'border-red-500' : ''}`}
            disabled={isLoading}
            autoComplete="current-password"
          />
        </div>
        {(errors.password || getFieldError('password')) && (
          <p className="text-sm text-red-500">
            {errors.password?.message || getFieldError('password')}
          </p>
        )}
      </div>

      {/* Remember me checkbox */}
      <div className="flex items-center space-x-2">
        <Checkbox
          {...register('rememberMe')}
          id="rememberMe"
          disabled={isLoading}
        />
        <Label
          htmlFor="rememberMe"
          className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
        >
          Remember me for 30 days
        </Label>
      </div>

      {/* Submit button */}
      <Button
        type="submit"
        className="w-full"
        disabled={isLoading}
      >
        {isLoading ? (
          <>
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            Signing in...
          </>
        ) : (
          'Sign In'
        )}
      </Button>

      {/* Register link */}
      <div className="text-center text-sm">
        Don&apos;t have an account?{' '}
        <Link
          href="/auth/register"
          className="font-medium text-primary hover:underline"
        >
          Create an account
        </Link>
      </div>
    </form>
  );
}

/**
 * Example of a protected component using the unified auth store
 */
export function ProtectedComponent() {
  const { 
    user, 
    isAuthenticated, 
    hasPermission, 
    hasRole,
    logout 
  } = useAuthStore();

  // Check authentication
  if (!isAuthenticated) {
    return <div>Please sign in to continue.</div>;
  }

  // Check specific permission
  if (!hasPermission('dashboard:view')) {
    return <div>You don&apos;t have permission to view this content.</div>;
  }

  // Check role
  if (!hasRole('admin')) {
    return <div>Admin access required.</div>;
  }

  return (
    <div>
      <h2>Welcome, {user?.first_name}!</h2>
      <p>Email: {user?.email}</p>
      <Button onClick={logout}>Sign Out</Button>
    </div>
  );
}

/**
 * Hook for requiring authentication in components
 */
export function useRequireAuth(redirectTo = '/auth/login') {
  const router = useRouter();
  const { isAuthenticated, isInitialized } = useAuthStore();

  // Redirect if not authenticated after initialization
  if (isInitialized && !isAuthenticated) {
    router.push(`${redirectTo}?from=${encodeURIComponent(window.location.pathname)}`);
  }

  return { isAuthenticated, isInitialized };
}