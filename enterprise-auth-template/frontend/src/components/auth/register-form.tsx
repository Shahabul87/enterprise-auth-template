'use client';

import React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { useAuthStore } from '@/stores/auth.store';
import { useFormErrorHandler } from '@/hooks/use-error-handler';
import { RegisterFormData } from '@/types';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { PasswordInput } from '@/components/ui/password-input';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Card, CardContent } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { PasswordStrengthIndicator } from '@/components/auth/password-strength-indicator';
import { useAuthForm, validationRules, isFormValid } from '@/hooks/use-auth-form';
import {
  Loader2,
  Mail,
  Lock,
  User,
  ArrowRight,
  Sparkles,
} from 'lucide-react';

const containerVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
      staggerChildren: 0.08
    }
  }
};

const itemVariants = {
  hidden: { opacity: 0, y: 10 },
  visible: { opacity: 1, y: 0 }
};

export function RegisterForm() {
  const router = useRouter();
  const { register: registerUser, isLoading } = useAuthStore();
  const { handleFormError, clearAllErrors } = useFormErrorHandler();
  const [isSubmitting, setIsSubmitting] = React.useState<boolean>(false);

  const { form, error, setError } = useAuthForm<RegisterFormData>({
    defaultValues: {
      email: '',
      password: '',
      confirmPassword: '',
      name: '',
      terms: false,
    },
  });

  const passwordValue = form.watch('password');

  const onSubmit = async (data: RegisterFormData): Promise<void> => {
    setIsSubmitting(true);
    clearAllErrors();
    setError('');

    try {
      const response = await registerUser({
        email: data.email,
        password: data.password,
        confirm_password: data.confirmPassword,
        name: data.name,
        agree_to_terms: data.terms,
      });

      if (response.success) {
        // Store email for verification page
        if (typeof window !== 'undefined') {
          localStorage.setItem('registrationEmail', data.email);
        }

        // Redirect to email verification page
        router.push(`/auth/verify-email?email=${encodeURIComponent(data.email)}`);
      } else {
        const errorMessage = response.error?.message || 'Registration failed';
        setError(errorMessage);
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'An error occurred';
      setError(errorMessage);
      handleFormError(error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const formIsValid = isFormValid(form, [
    'email',
    'password',
    'confirmPassword',
    'name',
    'terms',
  ]);

  return (
    <motion.div
      className="w-full max-w-md mx-auto"
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      {/* Minimal Header */}
      <motion.div className="text-center mb-8" variants={itemVariants}>
        <motion.div
          className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-indigo-500 to-purple-600 mb-4 shadow-lg"
          whileHover={{ scale: 1.05 }}
          transition={{ type: "spring", stiffness: 300 }}
        >
          <Sparkles className="w-8 h-8 text-white" />
        </motion.div>
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          Create Account
        </h1>
        <p className="text-gray-600">
          Join thousands of users already using our platform
        </p>
      </motion.div>

      <motion.div variants={itemVariants}>
        <Card className="border-0 shadow-xl bg-white">
          <CardContent className="p-6">
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5">
              {error && (
                <motion.div
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: 'auto' }}
                  exit={{ opacity: 0, height: 0 }}
                >
                  <Alert variant="destructive" className="bg-red-50 border-red-200">
                    <AlertDescription className="text-sm">{error}</AlertDescription>
                  </Alert>
                </motion.div>
              )}

              {/* Full Name Field */}
              <FormField
                control={form.control}
                name="name"
                rules={validationRules.name}
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-sm font-medium text-gray-700">
                      Full Name
                    </FormLabel>
                    <FormControl>
                      <div className="relative">
                        <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <Input
                          type="text"
                          placeholder="John Doe"
                          className="pl-10 h-11 border-gray-200 focus:border-indigo-500 focus:ring-indigo-500/20 rounded-lg"
                          disabled={isLoading || isSubmitting}
                          {...field}
                        />
                      </div>
                    </FormControl>
                    <FormMessage className="text-xs" />
                  </FormItem>
                )}
              />

              {/* Email Field */}
              <FormField
                control={form.control}
                name="email"
                rules={validationRules.email}
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-sm font-medium text-gray-700">
                      Email
                    </FormLabel>
                    <FormControl>
                      <div className="relative">
                        <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <Input
                          type="email"
                          placeholder="john@example.com"
                          className="pl-10 h-11 border-gray-200 focus:border-indigo-500 focus:ring-indigo-500/20 rounded-lg"
                          disabled={isLoading || isSubmitting}
                          {...field}
                        />
                      </div>
                    </FormControl>
                    <FormMessage className="text-xs" />
                  </FormItem>
                )}
              />

              {/* Password Field */}
              <FormField
                control={form.control}
                name="password"
                rules={validationRules.password}
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-sm font-medium text-gray-700">
                      Password
                    </FormLabel>
                    <FormControl>
                      <div className="relative">
                        <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <PasswordInput
                          placeholder="••••••••"
                          className="pl-10 h-11 border-gray-200 focus:border-indigo-500 focus:ring-indigo-500/20 rounded-lg"
                          disabled={isLoading || isSubmitting}
                          {...field}
                        />
                      </div>
                    </FormControl>
                    {passwordValue && <PasswordStrengthIndicator password={passwordValue} />}
                    <FormMessage className="text-xs" />
                  </FormItem>
                )}
              />

              {/* Confirm Password Field */}
              <FormField
                control={form.control}
                name="confirmPassword"
                rules={validationRules.confirmPassword(passwordValue)}
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-sm font-medium text-gray-700">
                      Confirm Password
                    </FormLabel>
                    <FormControl>
                      <div className="relative">
                        <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <PasswordInput
                          placeholder="••••••••"
                          className="pl-10 h-11 border-gray-200 focus:border-indigo-500 focus:ring-indigo-500/20 rounded-lg"
                          disabled={isLoading || isSubmitting}
                          {...field}
                        />
                      </div>
                    </FormControl>
                    <FormMessage className="text-xs" />
                  </FormItem>
                )}
              />

              {/* Terms Checkbox - Simplified */}
              <FormField
                control={form.control}
                name="terms"
                rules={validationRules.terms}
                render={({ field }) => (
                  <FormItem>
                    <div className="flex items-start space-x-2">
                      <FormControl>
                        <Checkbox
                          id="terms"
                          checked={!!field.value}
                          onCheckedChange={(checked) => field.onChange(checked)}
                          disabled={isLoading || isSubmitting}
                          className="mt-1 data-[state=checked]:bg-indigo-600 data-[state=checked]:border-indigo-600"
                        />
                      </FormControl>
                      <label
                        htmlFor="terms"
                        className="text-sm text-gray-600 leading-relaxed cursor-pointer"
                      >
                        I agree to the{' '}
                        <Link href="/terms" className="text-indigo-600 hover:text-indigo-700 underline-offset-2 hover:underline">
                          Terms
                        </Link>{' '}
                        and{' '}
                        <Link href="/privacy" className="text-indigo-600 hover:text-indigo-700 underline-offset-2 hover:underline">
                          Privacy Policy
                        </Link>
                      </label>
                    </div>
                    <FormMessage className="text-xs ml-6" />
                  </FormItem>
                )}
              />

              {/* Submit Button */}
              <Button
                type="submit"
                className="w-full h-11 font-medium bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-white rounded-lg shadow-md hover:shadow-lg transition-all duration-200"
                disabled={!formIsValid || isLoading || isSubmitting}
              >
                {isSubmitting ? (
                  <div className="flex items-center">
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Creating account...
                  </div>
                ) : (
                  <div className="flex items-center">
                    Create Account
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </div>
                )}
              </Button>
            </form>

            {/* Sign in link */}
            <div className="text-center mt-6 pt-6 border-t border-gray-100">
              <span className="text-sm text-gray-600">
                Already have an account?{' '}
                <Link
                  href="/auth/login"
                  className="font-medium text-indigo-600 hover:text-indigo-700"
                >
                  Sign in
                </Link>
              </span>
            </div>
          </CardContent>
        </Card>
      </motion.div>

      {/* Minimal footer */}
      <motion.p
        className="mt-6 text-center text-xs text-gray-500"
        variants={itemVariants}
      >
        Protected by enterprise-grade security
      </motion.p>
    </motion.div>
  );
}

export default RegisterForm;