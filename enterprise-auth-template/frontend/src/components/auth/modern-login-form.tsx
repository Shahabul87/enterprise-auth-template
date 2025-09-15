'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Mail,
  Lock,
  Fingerprint,
  ArrowRight,
  Sparkles,
  Shield,
  Zap,
  Eye,
  EyeOff,
  Check,
  Loader2,
  Github,
  Chrome
} from 'lucide-react';
import { useAuthStore } from '@/stores/auth.store';
import { useToast } from '@/components/ui/use-toast';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { cn } from '@/lib/utils';

type AuthMethod = 'password' | 'passkey' | 'magic-link';

export function ModernLoginForm() {
  const [authMethod, setAuthMethod] = useState<AuthMethod>('password');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [emailSent, setEmailSent] = useState(false);

  const router = useRouter();
  const { toast } = useToast();
  const { login } = useAuthStore();

  const handlePasswordLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      toast({
        title: 'Missing credentials',
        description: 'Please enter both email and password',
        variant: 'destructive',
      });
      return;
    }

    setIsLoading(true);
    try {
      await login({ email, password });
      toast({
        title: 'Welcome back!',
        description: 'Login successful',
      });
      router.push('/dashboard');
    } catch (error) {
      toast({
        title: 'Login failed',
        description: error instanceof Error ? error.message : 'Please check your credentials',
        variant: 'destructive',
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handlePasskeyLogin = async () => {
    setIsLoading(true);
    try {
      // Simulate passkey authentication
      toast({
        title: 'Passkey authentication',
        description: 'Please use your device authenticator',
      });
      // In production, this would trigger WebAuthn API
      setTimeout(() => {
        setIsLoading(false);
        toast({
          title: 'Passkey not configured',
          description: 'Please set up passkey in your security settings first',
          variant: 'destructive',
        });
      }, 2000);
    } catch (error) {
      setIsLoading(false);
      toast({
        title: 'Authentication failed',
        description: 'Could not authenticate with passkey',
        variant: 'destructive',
      });
    }
  };

  const handleMagicLink = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) {
      toast({
        title: 'Email required',
        description: 'Please enter your email address',
        variant: 'destructive',
      });
      return;
    }

    setIsLoading(true);
    try {
      // Simulate sending magic link
      await new Promise(resolve => setTimeout(resolve, 1500));
      setEmailSent(true);
      toast({
        title: 'Magic link sent!',
        description: 'Check your email for the login link',
      });
    } catch (error) {
      toast({
        title: 'Failed to send',
        description: 'Could not send magic link. Please try again.',
        variant: 'destructive',
      });
    } finally {
      setIsLoading(false);
    }
  };

  const authMethods = [
    {
      id: 'password' as AuthMethod,
      label: 'Password',
      icon: Lock,
      color: 'from-blue-500 to-indigo-600',
      description: 'Sign in with email and password'
    },
    {
      id: 'passkey' as AuthMethod,
      label: 'Passkey',
      icon: Fingerprint,
      color: 'from-purple-500 to-pink-600',
      description: 'Secure biometric authentication'
    },
    {
      id: 'magic-link' as AuthMethod,
      label: 'Magic Link',
      icon: Mail,
      color: 'from-emerald-500 to-teal-600',
      description: 'Get a login link via email'
    },
  ];

  return (
    <div className="w-full max-w-md mx-auto">
      {/* Logo and Title */}
      <motion.div
        className="text-center mb-8"
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-blue-500 to-purple-600 mb-4 shadow-lg">
          <Shield className="w-8 h-8 text-white" />
        </div>
        <h1 className="text-3xl font-bold bg-gradient-to-r from-gray-900 to-gray-600 dark:from-gray-100 dark:to-gray-400 bg-clip-text text-transparent">
          Welcome Back
        </h1>
        <p className="text-gray-500 dark:text-gray-400 mt-2">
          Choose your preferred sign-in method
        </p>
      </motion.div>

      {/* Auth Method Selector */}
      <motion.div
        className="grid grid-cols-3 gap-2 mb-8"
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5, delay: 0.1 }}
      >
        {authMethods.map((method) => {
          const Icon = method.icon;
          const isActive = authMethod === method.id;

          return (
            <button
              key={method.id}
              onClick={() => {
                setAuthMethod(method.id);
                setEmailSent(false);
              }}
              className={cn(
                "relative group flex flex-col items-center p-3 rounded-xl transition-all duration-300",
                "border-2 backdrop-blur-sm",
                isActive
                  ? "border-transparent bg-gradient-to-br shadow-lg scale-105"
                  : "border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600 hover:scale-105",
                isActive && method.color
              )}
            >
              <Icon
                className={cn(
                  "w-6 h-6 mb-1 transition-colors duration-300",
                  isActive ? "text-white" : "text-gray-600 dark:text-gray-400"
                )}
              />
              <span
                className={cn(
                  "text-xs font-medium transition-colors duration-300",
                  isActive ? "text-white" : "text-gray-700 dark:text-gray-300"
                )}
              >
                {method.label}
              </span>
              {isActive && (
                <motion.div
                  className="absolute inset-0 rounded-xl bg-gradient-to-br opacity-20"
                  layoutId="activeTab"
                  transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                />
              )}
            </button>
          );
        })}
      </motion.div>

      {/* Auth Forms */}
      <motion.div
        className="bg-white dark:bg-gray-900 rounded-2xl shadow-xl border border-gray-100 dark:border-gray-800 p-8"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.2 }}
      >
        <AnimatePresence mode="wait">
          {/* Password Login Form */}
          {authMethod === 'password' && (
            <motion.form
              key="password"
              onSubmit={handlePasswordLogin}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              transition={{ duration: 0.3 }}
              className="space-y-6"
            >
              <div className="space-y-4">
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <Input
                    type="email"
                    placeholder="Enter your email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="pl-10 h-12 bg-gray-50 dark:bg-gray-800 border-gray-200 dark:border-gray-700 focus:bg-white dark:focus:bg-gray-900 transition-colors"
                    disabled={isLoading}
                  />
                </div>

                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <Input
                    type={showPassword ? 'text' : 'password'}
                    placeholder="Enter your password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="pl-10 pr-10 h-12 bg-gray-50 dark:bg-gray-800 border-gray-200 dark:border-gray-700 focus:bg-white dark:focus:bg-gray-900 transition-colors"
                    disabled={isLoading}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                  >
                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-between text-sm">
                <label className="flex items-center space-x-2 cursor-pointer">
                  <input type="checkbox" className="rounded border-gray-300 text-blue-600 focus:ring-blue-500" />
                  <span className="text-gray-600 dark:text-gray-400">Remember me</span>
                </label>
                <Link
                  href="/auth/forgot-password"
                  className="text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 font-medium"
                >
                  Forgot password?
                </Link>
              </div>

              <Button
                type="submit"
                disabled={isLoading}
                className="w-full h-12 bg-gradient-to-r from-blue-500 to-indigo-600 hover:from-blue-600 hover:to-indigo-700 text-white font-medium rounded-xl shadow-lg hover:shadow-xl transition-all duration-300"
              >
                {isLoading ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <>
                    Sign In
                    <ArrowRight className="w-5 h-5 ml-2" />
                  </>
                )}
              </Button>
            </motion.form>
          )}

          {/* Passkey Login */}
          {authMethod === 'passkey' && (
            <motion.div
              key="passkey"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              transition={{ duration: 0.3 }}
              className="space-y-6"
            >
              <div className="text-center py-8">
                <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-gradient-to-br from-purple-500 to-pink-600 mb-4 shadow-lg">
                  <Fingerprint className="w-10 h-10 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-gray-800 dark:text-gray-200 mb-2">
                  Sign in with Passkey
                </h3>
                <p className="text-gray-600 dark:text-gray-400 text-sm">
                  Use your device&apos;s biometric authentication
                </p>
              </div>

              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <Input
                  type="email"
                  placeholder="Enter your email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="pl-10 h-12 bg-gray-50 dark:bg-gray-800 border-gray-200 dark:border-gray-700 focus:bg-white dark:focus:bg-gray-900 transition-colors"
                  disabled={isLoading}
                />
              </div>

              <Button
                onClick={handlePasskeyLogin}
                disabled={isLoading || !email}
                className="w-full h-12 bg-gradient-to-r from-purple-500 to-pink-600 hover:from-purple-600 hover:to-pink-700 text-white font-medium rounded-xl shadow-lg hover:shadow-xl transition-all duration-300"
              >
                {isLoading ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <>
                    <Fingerprint className="w-5 h-5 mr-2" />
                    Authenticate with Passkey
                  </>
                )}
              </Button>

              <div className="text-center">
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  Your device must support WebAuthn for passkey authentication
                </p>
              </div>
            </motion.div>
          )}

          {/* Magic Link Login */}
          {authMethod === 'magic-link' && (
            <motion.form
              key="magic-link"
              onSubmit={handleMagicLink}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              transition={{ duration: 0.3 }}
              className="space-y-6"
            >
              {!emailSent ? (
                <>
                  <div className="text-center py-8">
                    <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-gradient-to-br from-emerald-500 to-teal-600 mb-4 shadow-lg">
                      <Zap className="w-10 h-10 text-white" />
                    </div>
                    <h3 className="text-xl font-semibold text-gray-800 dark:text-gray-200 mb-2">
                      Magic Link Sign In
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 text-sm">
                      We&apos;ll send you a secure link to sign in instantly
                    </p>
                  </div>

                  <div className="relative">
                    <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <Input
                      type="email"
                      placeholder="Enter your email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="pl-10 h-12 bg-gray-50 dark:bg-gray-800 border-gray-200 dark:border-gray-700 focus:bg-white dark:focus:bg-gray-900 transition-colors"
                      disabled={isLoading}
                    />
                  </div>

                  <Button
                    type="submit"
                    disabled={isLoading || !email}
                    className="w-full h-12 bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 text-white font-medium rounded-xl shadow-lg hover:shadow-xl transition-all duration-300"
                  >
                    {isLoading ? (
                      <Loader2 className="w-5 h-5 animate-spin" />
                    ) : (
                      <>
                        <Sparkles className="w-5 h-5 mr-2" />
                        Send Magic Link
                      </>
                    )}
                  </Button>
                </>
              ) : (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="text-center py-12"
                >
                  <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-green-100 dark:bg-green-900/20 mb-4">
                    <Check className="w-10 h-10 text-green-600 dark:text-green-400" />
                  </div>
                  <h3 className="text-xl font-semibold text-gray-800 dark:text-gray-200 mb-2">
                    Check Your Email!
                  </h3>
                  <p className="text-gray-600 dark:text-gray-400 text-sm mb-6">
                    We&apos;ve sent a magic link to<br />
                    <span className="font-medium text-gray-800 dark:text-gray-200">{email}</span>
                  </p>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => setEmailSent(false)}
                    className="border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800"
                  >
                    Try another email
                  </Button>
                </motion.div>
              )}
            </motion.form>
          )}
        </AnimatePresence>

        {/* Social Login Options */}
        {authMethod === 'password' && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="mt-8"
          >
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-200 dark:border-gray-700"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-4 bg-white dark:bg-gray-900 text-gray-500 dark:text-gray-400">
                  Or continue with
                </span>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3 mt-6">
              <Button
                type="button"
                variant="outline"
                className="h-11 border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
              >
                <Github className="w-5 h-5 mr-2" />
                GitHub
              </Button>
              <Button
                type="button"
                variant="outline"
                className="h-11 border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
              >
                <Chrome className="w-5 h-5 mr-2" />
                Google
              </Button>
            </div>
          </motion.div>
        )}
      </motion.div>

      {/* Sign Up Link */}
      <motion.div
        className="text-center mt-8"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.5, delay: 0.4 }}
      >
        <p className="text-gray-600 dark:text-gray-400">
          Don&apos;t have an account?{' '}
          <Link
            href="/auth/register"
            className="text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 font-medium"
          >
            Sign up for free
          </Link>
        </p>
      </motion.div>
    </div>
  );
}