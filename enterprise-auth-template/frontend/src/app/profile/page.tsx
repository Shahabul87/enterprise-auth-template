'use client';

import { useRequireAuth } from '@/stores/auth.store';
import { Button } from '@/components/ui/button';
import { ProfileForm } from '@/components/profile/profile-form';
import { ChangePasswordForm } from '@/components/profile/change-password-form';
import { TwoFactorSettings } from '@/components/auth/two-factor-settings';
import { WebAuthnSetup } from '@/components/auth/webauthn-setup';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Badge } from '@/components/ui/badge';
import { formatDate } from '@/lib/utils';
import { motion } from 'framer-motion';
import {
  User,
  Users,
  Settings,
  Shield,
  Clock,
  CheckCircle,
  XCircle,
  Link as LinkIcon,
  Unlink,
  Loader2,
  Mail,
  Calendar,
  Award,
  Activity,
  Smartphone,
  Monitor,
  LogOut,
  ArrowLeft,
  Bell,
  Lock,
  Key,
  UserCheck,
  Globe,
  Database,
  Download,
  Trash2,
} from 'lucide-react';
import { Icons } from '@/components/icons';
import AuthAPI from '@/lib/auth-api';
import { useEffect, useState } from 'react';
import { Alert, AlertDescription } from '@/components/ui/alert';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

interface LinkedAccount {
  provider: string;
  provider_user_id: string;
  linked_at: string;
}

export default function ProfilePage(): React.ReactElement {
  const { user, logout } = useRequireAuth();
  const router = useRouter();
  const [linkedAccounts, setLinkedAccounts] = useState<LinkedAccount[]>([]);
  const [oauthLoading, setOauthLoading] = useState<string | null>(null);
  const [oauthMessage, setOauthMessage] = useState<{
    type: 'success' | 'error';
    text: string;
  } | null>(null);

  // Helper function to get initials from full name
  const getInitials = (name: string): string => {
    if (!name) return 'U';
    const parts = name.trim().split(' ').filter(Boolean);
    if (parts.length === 0) return 'U';
    if (parts.length === 1) return parts[0].charAt(0).toUpperCase();
    return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
  };

  useEffect(() => {
    if (user) {
      fetchLinkedAccounts();
    }
  }, [user]);

  const fetchLinkedAccounts = async (): Promise<void> => {
    try {
      const response = await AuthAPI.getLinkedAccounts();
      if (response.success && response.data) {
        setLinkedAccounts(response.data);
      }
    } catch {
      // Silent fail - linked accounts are not critical
    }
  };

  const handleLinkAccount = async (provider: string): Promise<void> => {
    setOauthLoading(provider);
    setOauthMessage(null);

    try {
      const response = await AuthAPI.linkOAuthAccount(provider);
      if (response.success && response.data) {
        window.location.href = response.data.authorize_url;
      } else {
        throw new Error(response.error?.message || 'Failed to link account');
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Failed to link account';
      setOauthMessage({ type: 'error', text: errorMessage });
      setOauthLoading(null);
    }
  };

  const handleUnlinkAccount = async (provider: string): Promise<void> => {
    if (!confirm(`Are you sure you want to unlink your ${provider} account?`)) {
      return;
    }

    setOauthLoading(provider);
    setOauthMessage(null);

    try {
      const response = await AuthAPI.unlinkOAuthAccount(provider);
      if (response.success) {
        setOauthMessage({ type: 'success', text: `${provider} account unlinked successfully` });
        await fetchLinkedAccounts();
      } else {
        throw new Error(response.error?.message || 'Failed to unlink account');
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Failed to unlink account';
      setOauthMessage({ type: 'error', text: errorMessage });
    } finally {
      setOauthLoading(null);
    }
  };

  const getProviderIcon = (provider: string): React.ReactNode => {
    switch (provider.toLowerCase()) {
      case 'google':
        return <Icons.google className='h-5 w-5' />;
      case 'github':
        return <Icons.gitHub className='h-5 w-5' />;
      case 'microsoft':
        return <Icons.microsoft className='h-5 w-5' />;
      default:
        return <LinkIcon className='h-5 w-5' />;
    }
  };

  const isLinked = (provider: string): boolean => {
    return linkedAccounts.some(
      (account) => account.provider.toLowerCase() === provider.toLowerCase()
    );
  };

  if (!user) {
    return (
      <div className='flex items-center justify-center min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800'>
        <div className='animate-spin rounded-full h-12 w-12 border-4 border-primary border-t-transparent'></div>
      </div>
    );
  }

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.3 },
    },
  };

  return (
    <div className='min-h-screen bg-gradient-to-br from-gray-50 via-white to-gray-50 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800'>
      {/* Header */}
      <header className='backdrop-blur-md bg-white/70 dark:bg-gray-900/70 sticky top-0 z-50 border-b border-gray-200 dark:border-gray-700'>
        <div className='container mx-auto px-6 py-4'>
          <div className='flex justify-between items-center'>
            <div className='flex items-center gap-4'>
              <Button
                variant='ghost'
                size='icon'
                onClick={() => router.push('/dashboard')}
                className='hover:bg-gray-100 dark:hover:bg-gray-800'
              >
                <ArrowLeft className='h-5 w-5' />
              </Button>
              <div>
                <h1 className='text-2xl font-bold bg-gradient-to-r from-gray-900 to-gray-600 dark:from-white dark:to-gray-300 bg-clip-text text-transparent'>
                  Profile Settings
                </h1>
                <p className='text-sm text-gray-600 dark:text-gray-400'>
                  Manage your account and preferences
                </p>
              </div>
            </div>
            <div className='flex items-center gap-3'>
              <Button variant='ghost' size='icon' className='relative'>
                <Bell className='h-5 w-5' />
                <span className='absolute -top-1 -right-1 h-2 w-2 bg-blue-500 rounded-full'></span>
              </Button>
              <Button
                onClick={logout}
                variant='outline'
                className='hover:bg-red-50 hover:text-red-600 hover:border-red-200 dark:hover:bg-red-950 dark:hover:text-red-400 dark:hover:border-red-800'
              >
                <LogOut className='h-4 w-4 mr-2' />
                Sign Out
              </Button>
            </div>
          </div>
        </div>
      </header>

      <main className='container mx-auto px-6 py-8'>
        <motion.div
          variants={containerVariants}
          initial='hidden'
          animate='visible'
          className='grid gap-6 lg:grid-cols-4'
        >
          {/* User Info Sidebar */}
          <motion.div variants={itemVariants} className='lg:col-span-1'>
            <Card className='overflow-hidden sticky top-24'>
              <div className='h-32 bg-gradient-to-br from-violet-500 to-purple-600 relative'>
                <div className='absolute inset-0 bg-black/20'></div>
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
                  className='absolute -bottom-10 left-1/2 -translate-x-1/2'
                >
                  <div className='w-24 h-24 rounded-full bg-white dark:bg-gray-800 p-1.5'>
                    <div className='w-full h-full rounded-full bg-gradient-to-br from-violet-500 to-purple-600 flex items-center justify-center text-3xl font-bold text-white shadow-xl'>
                      {getInitials(user.full_name || user.email)}
                    </div>
                  </div>
                </motion.div>
              </div>
              <CardContent className='pt-14 pb-6'>
                <div className='text-center mb-6'>
                  <h2 className='text-xl font-bold'>
                    {user.full_name || 'User'}
                  </h2>
                  <p className='text-sm text-gray-600 dark:text-gray-400 flex items-center justify-center gap-1 mt-1'>
                    <Mail className='h-3 w-3' />
                    {user.email}
                  </p>
                </div>
                {/* Account Status */}
                <div className='space-y-3'>
                  <div className='flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800/50 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800/70 transition-colors'>
                    <span className='text-sm font-medium flex items-center gap-2'>
                      <Activity className='h-4 w-4' />
                      Status
                    </span>
                    <Badge variant={user.is_active ? 'default' : 'destructive'} className='shadow-sm'>
                      {user.is_active ? (
                        <>
                          <CheckCircle className='w-3 h-3 mr-1' /> Active
                        </>
                      ) : (
                        <>
                          <XCircle className='w-3 h-3 mr-1' /> Inactive
                        </>
                      )}
                    </Badge>
                  </div>

                  <div className='flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800/50 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800/70 transition-colors'>
                    <span className='text-sm font-medium flex items-center gap-2'>
                      <Mail className='h-4 w-4' />
                      Email
                    </span>
                    <Badge variant={user.is_verified ? 'default' : 'secondary'} className='shadow-sm'>
                      {user.is_verified ? (
                        <>
                          <UserCheck className='w-3 h-3 mr-1' /> Verified
                        </>
                      ) : (
                        <>
                          <XCircle className='w-3 h-3 mr-1' /> Unverified
                        </>
                      )}
                    </Badge>
                  </div>

                  {user.is_superuser && (
                    <div className='flex items-center justify-between p-3 bg-gradient-to-r from-purple-50 to-purple-100 dark:from-purple-900/20 dark:to-purple-800/20 rounded-lg'>
                      <span className='text-sm font-medium flex items-center gap-2'>
                        <Shield className='h-4 w-4' />
                        Privileges
                      </span>
                      <Badge variant='default' className='bg-gradient-to-r from-purple-500 to-purple-600 shadow-sm'>
                        <Award className='w-3 h-3 mr-1' /> Admin
                      </Badge>
                    </div>
                  )}
                </div>

                {/* Account Info */}
                <div className='space-y-3 pt-4 border-t border-gray-200 dark:border-gray-700'>
                  <div className='flex items-start gap-3 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg'>
                    <Calendar className='h-4 w-4 text-blue-600 dark:text-blue-400 mt-0.5' />
                    <div className='text-sm'>
                      <p className='font-medium text-blue-900 dark:text-blue-100'>Member Since</p>
                      <p className='text-blue-700 dark:text-blue-300'>
                        {formatDate(user.created_at, 'long')}
                      </p>
                    </div>
                  </div>

                  {user.last_login && (
                    <div className='flex items-start gap-3 p-3 bg-green-50 dark:bg-green-900/20 rounded-lg'>
                      <Clock className='h-4 w-4 text-green-600 dark:text-green-400 mt-0.5' />
                      <div className='text-sm'>
                        <p className='font-medium text-green-900 dark:text-green-100'>Last Active</p>
                        <p className='text-green-700 dark:text-green-300'>
                          {formatDate(user.last_login, 'relative')}
                        </p>
                      </div>
                    </div>
                  )}
                </div>

                {/* Roles */}
                {user.roles && user.roles.length > 0 && (
                  <div className='space-y-2 pt-4 border-t border-gray-200 dark:border-gray-700'>
                    <span className='text-sm font-medium flex items-center gap-2 mb-2'>
                      <Users className='h-4 w-4' />
                      Assigned Roles
                    </span>
                    <div className='space-y-2'>
                      {user.roles.map((role) => (
                        <div
                          key={role.id}
                          className='flex items-center gap-2 p-2 bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-800/50 dark:to-gray-800/30 rounded-lg'
                        >
                          <div className='w-2 h-2 bg-green-500 rounded-full'></div>
                          <span className='text-sm font-medium'>{role.name}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Quick Actions */}
                <div className='pt-4 border-t border-gray-200 dark:border-gray-700 space-y-2'>
                  <Button variant='outline' size='sm' className='w-full justify-start' asChild>
                    <Link href='/profile/sessions'>
                      <Monitor className='h-4 w-4 mr-2' />
                      Active Sessions
                    </Link>
                  </Button>
                  <Button variant='outline' size='sm' className='w-full justify-start' asChild>
                    <Link href='/profile/activity'>
                      <Activity className='h-4 w-4 mr-2' />
                      Account Activity
                    </Link>
                  </Button>
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Main Content */}
          <motion.div variants={itemVariants} className='lg:col-span-3'>
            <Tabs defaultValue='profile' className='space-y-6'>
              <TabsList className='grid w-full grid-cols-3 lg:grid-cols-3 h-12'>
                <TabsTrigger value='profile' className='flex items-center gap-2 data-[state=active]:bg-gradient-to-r data-[state=active]:from-violet-500 data-[state=active]:to-purple-600 data-[state=active]:text-white'>
                  <User className='h-4 w-4' />
                  <span className='hidden sm:inline'>Personal Info</span>
                  <span className='sm:hidden'>Profile</span>
                </TabsTrigger>
                <TabsTrigger value='security' className='flex items-center gap-2 data-[state=active]:bg-gradient-to-r data-[state=active]:from-violet-500 data-[state=active]:to-purple-600 data-[state=active]:text-white'>
                  <Shield className='h-4 w-4' />
                  Security
                </TabsTrigger>
                <TabsTrigger value='privacy' className='flex items-center gap-2 data-[state=active]:bg-gradient-to-r data-[state=active]:from-violet-500 data-[state=active]:to-purple-600 data-[state=active]:text-white'>
                  <Lock className='h-4 w-4' />
                  Privacy
                </TabsTrigger>
              </TabsList>

              <TabsContent value='profile' className='space-y-6'>
                <ProfileForm />
              </TabsContent>

              <TabsContent value='security' className='space-y-6'>
                <ChangePasswordForm />

                {/* OAuth Linked Accounts */}
                <Card>
                  <CardHeader>
                    <CardTitle className='flex items-center gap-2'>
                      <LinkIcon className='h-5 w-5' />
                      Linked Accounts
                    </CardTitle>
                    <CardDescription>
                      Connect your social accounts for easier sign-in
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    {oauthMessage && (
                      <Alert
                        variant={oauthMessage.type === 'error' ? 'destructive' : 'default'}
                        className='mb-4'
                      >
                        <AlertDescription>{oauthMessage.text}</AlertDescription>
                      </Alert>
                    )}

                    <div className='space-y-3'>
                      {['google', 'github', 'microsoft'].map((provider) => {
                        const linked = isLinked(provider);
                        const linkedAccount = linkedAccounts.find(
                          (acc) => acc.provider.toLowerCase() === provider.toLowerCase()
                        );

                        return (
                          <div
                            key={provider}
                            className='flex items-center justify-between p-3 border rounded-lg'
                          >
                            <div className='flex items-center gap-3'>
                              {getProviderIcon(provider)}
                              <div>
                                <p className='font-medium capitalize'>{provider}</p>
                                {linked && linkedAccount && (
                                  <p className='text-sm text-muted-foreground'>
                                    Connected on{' '}
                                    {new Date(linkedAccount.linked_at).toLocaleDateString()}
                                  </p>
                                )}
                              </div>
                            </div>
                            <Button
                              variant={linked ? 'destructive' : 'outline'}
                              size='sm'
                              onClick={() =>
                                linked ? handleUnlinkAccount(provider) : handleLinkAccount(provider)
                              }
                              disabled={oauthLoading === provider}
                            >
                              {oauthLoading === provider ? (
                                <Loader2 className='h-4 w-4 animate-spin' />
                              ) : linked ? (
                                <>
                                  <Unlink className='h-4 w-4 mr-1' />
                                  Disconnect
                                </>
                              ) : (
                                <>
                                  <LinkIcon className='h-4 w-4 mr-1' />
                                  Connect
                                </>
                              )}
                            </Button>
                          </div>
                        );
                      })}
                    </div>
                  </CardContent>
                </Card>

                {/* WebAuthn/Passkeys Settings */}
                <WebAuthnSetup 
                  user={{
                    id: user.id,
                    email: user.email,
                    first_name: user.first_name,
                    last_name: user.last_name,
                  }}
                  hasPasswordBackup={true} // Assuming user has password since ChangePasswordForm is shown
                />

                {/* Two-Factor Authentication Settings */}
                <TwoFactorSettings />

                {/* Additional Security Settings */}
                <Card>
                  <CardHeader>
                    <CardTitle className='flex items-center gap-2'>
                      <Settings className='h-5 w-5' />
                      Additional Security Settings
                    </CardTitle>
                    <CardDescription>
                      More security features and account management options
                    </CardDescription>
                  </CardHeader>
                  <CardContent className='space-y-4'>
                    <div className='flex items-center justify-between p-4 border rounded-lg'>
                      <div>
                        <h4 className='text-sm font-medium'>Login Sessions</h4>
                        <p className='text-sm text-muted-foreground'>
                          Manage and monitor your active login sessions
                        </p>
                      </div>
                      <Button variant='outline' disabled>
                        Coming Soon
                      </Button>
                    </div>

                    <div className='flex items-center justify-between p-4 border rounded-lg'>
                      <div>
                        <h4 className='text-sm font-medium'>Account Activity</h4>
                        <p className='text-sm text-muted-foreground'>
                          View recent activity and login attempts
                        </p>
                      </div>
                      <Button variant='outline' disabled>
                        Coming Soon
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>

              {/* New Privacy Tab */}
              <TabsContent value='privacy' className='space-y-6'>
                <Card>
                  <CardHeader>
                    <CardTitle className='flex items-center gap-2'>
                      <Database className='h-5 w-5' />
                      Data & Privacy
                    </CardTitle>
                    <CardDescription>
                      Manage your data and privacy preferences
                    </CardDescription>
                  </CardHeader>
                  <CardContent className='space-y-4'>
                    <div className='flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-800/50 rounded-lg'>
                      <div className='flex items-center gap-3'>
                        <Download className='h-5 w-5 text-blue-600' />
                        <div>
                          <h4 className='text-sm font-medium'>Download Your Data</h4>
                          <p className='text-sm text-gray-600 dark:text-gray-400'>
                            Get a copy of all your account data
                          </p>
                        </div>
                      </div>
                      <Button variant='outline' size='sm'>
                        Request Download
                      </Button>
                    </div>

                    <div className='flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-800/50 rounded-lg'>
                      <div className='flex items-center gap-3'>
                        <Globe className='h-5 w-5 text-green-600' />
                        <div>
                          <h4 className='text-sm font-medium'>Profile Visibility</h4>
                          <p className='text-sm text-gray-600 dark:text-gray-400'>
                            Control who can see your profile
                          </p>
                        </div>
                      </div>
                      <Button variant='outline' size='sm'>
                        Configure
                      </Button>
                    </div>

                    <div className='flex items-center justify-between p-4 bg-red-50 dark:bg-red-900/20 rounded-lg border border-red-200 dark:border-red-800'>
                      <div className='flex items-center gap-3'>
                        <Trash2 className='h-5 w-5 text-red-600' />
                        <div>
                          <h4 className='text-sm font-medium text-red-900 dark:text-red-100'>Delete Account</h4>
                          <p className='text-sm text-red-700 dark:text-red-300'>
                            Permanently delete your account and all data
                          </p>
                        </div>
                      </div>
                      <Button variant='destructive' size='sm'>
                        Delete Account
                      </Button>
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className='flex items-center gap-2'>
                      <Bell className='h-5 w-5' />
                      Notification Preferences
                    </CardTitle>
                    <CardDescription>
                      Choose how you want to be notified
                    </CardDescription>
                  </CardHeader>
                  <CardContent className='space-y-4'>
                    <div className='space-y-3'>
                      {[
                        { label: 'Security Alerts', description: 'Get notified about security events', enabled: true },
                        { label: 'Product Updates', description: 'New features and improvements', enabled: false },
                        { label: 'Newsletter', description: 'Tips and best practices', enabled: false },
                      ].map((notification, index) => (
                        <div
                          key={index}
                          className='flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-800/50 rounded-lg'
                        >
                          <div>
                            <h4 className='text-sm font-medium'>{notification.label}</h4>
                            <p className='text-sm text-gray-600 dark:text-gray-400'>
                              {notification.description}
                            </p>
                          </div>
                          <Button
                            variant={notification.enabled ? 'default' : 'outline'}
                            size='sm'
                          >
                            {notification.enabled ? 'Enabled' : 'Disabled'}
                          </Button>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>
            </Tabs>
          </motion.div>
        </motion.div>
      </main>
    </div>
  );
}
