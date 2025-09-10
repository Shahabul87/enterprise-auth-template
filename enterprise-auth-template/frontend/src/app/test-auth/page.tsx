'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { 
  Mail, 
  Shield, 
  Fingerprint, 
  Link, 
  Smartphone,
  Key,
  CheckCircle,
  AlertCircle,
  User,
  Settings,
  Lock
} from 'lucide-react';

// Import authentication components
import { EnhancedLoginForm } from '@/components/auth/enhanced-login-form';
import { RegisterForm } from '@/components/auth/register-form';
import OAuthProviders from '@/components/auth/oauth-providers';
import { WebAuthnLogin } from '@/components/auth/webauthn-login';
import { MagicLinkRequest } from '@/components/auth/magic-link-request';
// import { TwoFactorSetup } from '@/components/auth/two-factor-setup';
import { ForgotPasswordForm } from '@/components/auth/forgot-password-form';
import { ResetPasswordForm } from '@/components/auth/reset-password-form';

interface TestResult {
  method: string;
  status: 'success' | 'error' | 'pending';
  message: string;
  timestamp: Date;
}

export default function TestAuthPage(): JSX.Element {
  const router = useRouter();
  const [testResults, setTestResults] = useState<TestResult[]>([]);
  const [, setShowPasswordLogin] = useState(true);
  
  const addTestResult = (method: string, status: 'success' | 'error', message: string) => {
    setTestResults(prev => [...prev, {
      method,
      status,
      message,
      timestamp: new Date()
    }]);
  };

  const handleAuthSuccess = (method: string, _result?: unknown) => {
    addTestResult(method, 'success', `${method} authentication successful`);
    // Success logged to test results - result data available for debugging
    // Debug: ${method} success with result data
    // Note: In real usage, this would redirect to dashboard
    // router.push('/dashboard');
  };

  // const _handleAuthError = (method: string, error: unknown) => {
  //   const errorMessage = error instanceof Error ? error.message : 'Authentication failed';
  //   addTestResult(method, 'error', `${method}: ${errorMessage}`);
  //   // Error logged to test results
  // };

  const clearResults = () => {
    setTestResults([]);
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-background to-muted">
      <div className="container mx-auto px-4 py-8">
        <div className="mb-8 text-center">
          <h1 className="text-3xl font-bold mb-2">Authentication Testing Suite</h1>
          <p className="text-muted-foreground">
            Test all authentication methods for your enterprise application
          </p>
          <Button 
            variant="outline" 
            onClick={() => router.push('/')} 
            className="mt-4"
          >
            ← Back to Home
          </Button>
        </div>

        {/* Test Results Panel */}
        {testResults.length > 0 && (
          <Card className="mb-8">
            <CardHeader className="flex flex-row items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2">
                  <Settings className="h-5 w-5" />
                  Test Results
                </CardTitle>
                <CardDescription>
                  Authentication test results and logs
                </CardDescription>
              </div>
              <Button variant="outline" size="sm" onClick={clearResults}>
                Clear Results
              </Button>
            </CardHeader>
            <CardContent>
              <div className="space-y-2 max-h-48 overflow-y-auto">
                {testResults.map((result, index) => (
                  <div key={index} className="flex items-start gap-3 p-3 rounded-lg border">
                    {result.status === 'success' ? (
                      <CheckCircle className="h-4 w-4 text-green-600 mt-0.5" />
                    ) : (
                      <AlertCircle className="h-4 w-4 text-red-600 mt-0.5" />
                    )}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <Badge variant={result.status === 'success' ? 'default' : 'destructive'}>
                          {result.method}
                        </Badge>
                        <span className="text-sm text-muted-foreground">
                          {result.timestamp.toLocaleTimeString()}
                        </span>
                      </div>
                      <p className="text-sm">{result.message}</p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        )}

        <Tabs defaultValue="login" className="w-full">
          <TabsList className="grid w-full grid-cols-4 mb-8">
            <TabsTrigger value="login">Login Methods</TabsTrigger>
            <TabsTrigger value="register">Registration</TabsTrigger>
            <TabsTrigger value="security">Security Setup</TabsTrigger>
            <TabsTrigger value="recovery">Account Recovery</TabsTrigger>
          </TabsList>

          {/* Login Methods Tab */}
          <TabsContent value="login" className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              
              {/* Email/Password Login */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Mail className="h-5 w-5" />
                    Email/Password Login
                  </CardTitle>
                  <CardDescription>
                    Standard email and password authentication
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <EnhancedLoginForm 
                    onSuccess={() => handleAuthSuccess('Email/Password', {})}
                  />
                </CardContent>
              </Card>

              {/* WebAuthn/Passkeys */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Fingerprint className="h-5 w-5" />
                    WebAuthn/Passkeys
                  </CardTitle>
                  <CardDescription>
                    Biometric and security key authentication
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <WebAuthnLogin
                    onSuccess={(result) => handleAuthSuccess('WebAuthn/Passkeys', result)}
                    onShowPasswordLogin={() => setShowPasswordLogin(true)}
                    showEmailInput={true}
                  />
                </CardContent>
              </Card>

              {/* OAuth2 Social Login */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <User className="h-5 w-5" />
                    OAuth2 Social Login
                  </CardTitle>
                  <CardDescription>
                    Google, GitHub, Discord authentication
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <OAuthProviders 
                    onSuccess={() => handleAuthSuccess('OAuth2 Social', {})}
                  />
                </CardContent>
              </Card>

              {/* Magic Links */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Link className="h-5 w-5" />
                    Magic Links
                  </CardTitle>
                  <CardDescription>
                    Passwordless email authentication
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <MagicLinkRequest 
                    onBack={() => {}}
                  />
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          {/* Registration Tab */}
          <TabsContent value="register" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <User className="h-5 w-5" />
                  User Registration
                </CardTitle>
                <CardDescription>
                  Create new user accounts with email verification
                </CardDescription>
              </CardHeader>
              <CardContent>
                <RegisterForm 
                  onSuccess={() => handleAuthSuccess('Registration', {})}
                />
              </CardContent>
            </Card>
          </TabsContent>

          {/* Security Setup Tab */}
          <TabsContent value="security" className="space-y-6">
            <Alert>
              <Shield className="h-4 w-4" />
              <AlertDescription>
                <strong>Note:</strong> These security setup features require an authenticated user. 
                In production, users would access these through their profile settings.
              </AlertDescription>
            </Alert>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* 2FA Setup */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Smartphone className="h-5 w-5" />
                    Two-Factor Authentication
                  </CardTitle>
                  <CardDescription>
                    TOTP-based 2FA with authenticator apps
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="text-center py-8">
                    <Smartphone className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                    <p className="text-sm text-muted-foreground mb-4">
                      2FA setup requires authentication. Visit after login:
                    </p>
                    <Button 
                      onClick={() => router.push('/auth/2fa-setup')}
                      className="w-full"
                    >
                      Go to 2FA Setup
                    </Button>
                  </div>
                </CardContent>
              </Card>

              {/* WebAuthn Setup */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Key className="h-5 w-5" />
                    Passkey Registration
                  </CardTitle>
                  <CardDescription>
                    Register new passkeys for passwordless login
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="text-center py-8">
                    <Key className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                    <p className="text-sm text-muted-foreground mb-4">
                      Passkey setup requires authentication. Visit after login:
                    </p>
                    <Button 
                      onClick={() => router.push('/auth/webauthn-setup')}
                      className="w-full"
                    >
                      Go to Passkey Setup
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          {/* Account Recovery Tab */}
          <TabsContent value="recovery" className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              
              {/* Forgot Password */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Lock className="h-5 w-5" />
                    Forgot Password
                  </CardTitle>
                  <CardDescription>
                    Request password reset via email
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <ForgotPasswordForm 
                    onSuccess={() => handleAuthSuccess('Password Reset Request', {})}
                  />
                </CardContent>
              </Card>

              {/* Reset Password */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Key className="h-5 w-5" />
                    Reset Password
                  </CardTitle>
                  <CardDescription>
                    Reset password with email token (requires token)
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <ResetPasswordForm 
                    token="test-token"
                    onSuccess={() => handleAuthSuccess('Password Reset', {})}
                  />
                </CardContent>
              </Card>
            </div>

            <Alert>
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>
                <strong>Testing Note:</strong> Password reset requires a valid token from email. 
                Test the forgot password flow first to receive a reset email.
              </AlertDescription>
            </Alert>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}