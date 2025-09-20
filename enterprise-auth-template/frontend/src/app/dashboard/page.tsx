'use client';

import Link from 'next/link';
import { useRequireAuth } from '@/stores/auth.store';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { motion } from 'framer-motion';
import {
  User,
  Shield,
  Activity,
  Settings,
  LogOut,
  ChevronRight,
  Users,
  Key,
  CheckCircle2,
  XCircle,
  TrendingUp,
  TrendingDown,
  Calendar,
  Clock,
  Award,
  AlertCircle,
  BarChart3,
  PieChart,
  Target,
  Zap,
  Lock,
  Unlock,
  UserCheck,
  UserX,
  ShieldCheck,
  ShieldAlert,
} from 'lucide-react';

export default function DashboardPage(): React.ReactElement {
  const { user, logout, permissions, hasPermission, hasRole } = useRequireAuth();

  if (!user) {
    return (
      <div className='flex items-center justify-center min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800'>
        <div className='animate-spin rounded-full h-12 w-12 border-4 border-primary border-t-transparent'></div>
      </div>
    );
  }

  const stats = [
    {
      title: 'Active Sessions',
      value: '3',
      change: '+2',
      trend: 'up',
      icon: Activity,
      color: 'from-blue-500 to-blue-600',
    },
    {
      title: 'Login Attempts',
      value: '12',
      change: '-15%',
      trend: 'down',
      icon: UserCheck,
      color: 'from-green-500 to-green-600',
    },
    {
      title: 'Security Score',
      value: '92%',
      change: '+5%',
      trend: 'up',
      icon: Shield,
      color: 'from-purple-500 to-purple-600',
    },
    {
      title: 'API Calls',
      value: '1.2k',
      change: '+18%',
      trend: 'up',
      icon: Zap,
      color: 'from-orange-500 to-orange-600',
    },
  ];

  const recentActivity = [
    { action: 'Login successful', time: '2 minutes ago', type: 'success' },
    { action: 'Profile updated', time: '1 hour ago', type: 'info' },
    { action: '2FA enabled', time: '3 hours ago', type: 'success' },
    { action: 'Password changed', time: '1 day ago', type: 'warning' },
    { action: 'New device added', time: '2 days ago', type: 'info' },
  ];

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
            <div>
              <h1 className='text-2xl font-bold bg-gradient-to-r from-gray-900 to-gray-600 dark:from-white dark:to-gray-300 bg-clip-text text-transparent'>
                Dashboard
              </h1>
              <p className='text-sm text-gray-600 dark:text-gray-400'>
                Welcome back, {user.full_name.split(' ')[0]}!
              </p>
            </div>
            <div className='flex items-center gap-3'>
              <Button variant='ghost' size='icon' className='relative'>
                <AlertCircle className='h-5 w-5' />
                <span className='absolute -top-1 -right-1 h-2 w-2 bg-red-500 rounded-full'></span>
              </Button>
              <Button asChild variant='outline' className='hidden sm:flex'>
                <Link href='/profile' className='flex items-center gap-2'>
                  <User className='h-4 w-4' />
                  Profile
                </Link>
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
        {/* Stats Grid */}
        <motion.div
          variants={containerVariants}
          initial='hidden'
          animate='visible'
          className='grid gap-4 md:grid-cols-2 lg:grid-cols-4 mb-8'
        >
          {stats.map((stat, index) => (
            <motion.div key={index} variants={itemVariants}>
              <Card className='overflow-hidden hover:shadow-lg transition-shadow duration-300'>
                <CardContent className='p-6'>
                  <div className='flex items-center justify-between'>
                    <div>
                      <p className='text-sm text-gray-600 dark:text-gray-400'>{stat.title}</p>
                      <p className='text-2xl font-bold mt-1'>{stat.value}</p>
                      <div className='flex items-center gap-1 mt-2'>
                        {stat.trend === 'up' ? (
                          <TrendingUp className='h-4 w-4 text-green-500' />
                        ) : (
                          <TrendingDown className='h-4 w-4 text-red-500' />
                        )}
                        <span
                          className={`text-xs font-medium ${
                            stat.trend === 'up' ? 'text-green-500' : 'text-red-500'
                          }`}
                        >
                          {stat.change}
                        </span>
                      </div>
                    </div>
                    <div
                      className={`w-12 h-12 rounded-xl bg-gradient-to-br ${stat.color} flex items-center justify-center`}
                    >
                      <stat.icon className='h-6 w-6 text-white' />
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </motion.div>

        <div className='grid gap-6 lg:grid-cols-3'>
          {/* User Profile Card */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.2 }}
          >
            <Card className='overflow-hidden h-full'>
              <div className='h-24 bg-gradient-to-br from-blue-500 to-purple-600'></div>
              <CardContent className='relative pt-12 pb-6'>
                <div className='absolute -top-10 left-1/2 -translate-x-1/2'>
                  <div className='w-20 h-20 rounded-full bg-white dark:bg-gray-800 p-1'>
                    <div className='w-full h-full rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center'>
                      <User className='h-10 w-10 text-white' />
                    </div>
                  </div>
                </div>
                <div className='text-center'>
                  <h3 className='text-lg font-semibold'>
                    {user.full_name}
                  </h3>
                  <p className='text-sm text-gray-600 dark:text-gray-400'>{user.email}</p>

                  <div className='flex items-center justify-center gap-2 mt-4'>
                    {user.email_verified ? (
                      <span className='inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'>
                        <CheckCircle2 className='h-3 w-3' />
                        Verified
                      </span>
                    ) : (
                      <span className='inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400'>
                        <AlertCircle className='h-3 w-3' />
                        Unverified
                      </span>
                    )}
                    {user.is_active ? (
                      <span className='inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400'>
                        <Unlock className='h-3 w-3' />
                        Active
                      </span>
                    ) : (
                      <span className='inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'>
                        <Lock className='h-3 w-3' />
                        Inactive
                      </span>
                    )}
                  </div>

                  <div className='mt-6 space-y-3'>
                    <div className='flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800/50 rounded-lg'>
                      <span className='text-sm font-medium'>Account Type</span>
                      <span className='text-sm text-gray-600 dark:text-gray-400'>
                        {user.is_superuser ? 'Admin' : 'Standard'}
                      </span>
                    </div>
                    <div className='flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800/50 rounded-lg'>
                      <span className='text-sm font-medium'>Member Since</span>
                      <span className='text-sm text-gray-600 dark:text-gray-400'>
                        {new Date().toLocaleDateString()}
                      </span>
                    </div>
                  </div>

                  <Button asChild className='w-full mt-6'>
                    <Link href='/profile'>
                      Manage Profile
                      <ChevronRight className='h-4 w-4 ml-1' />
                    </Link>
                  </Button>
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Roles & Permissions */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className='lg:col-span-2 space-y-6'
          >
            {/* Roles Card */}
            <Card>
              <CardHeader>
                <CardTitle className='flex items-center gap-2'>
                  <Users className='h-5 w-5' />
                  Your Roles
                </CardTitle>
                <CardDescription>Assigned roles and their status</CardDescription>
              </CardHeader>
              <CardContent>
                {user.roles && user.roles.length > 0 ? (
                  <div className='grid gap-3 sm:grid-cols-2'>
                    {user.roles.map((role) => (
                      <div
                        key={role.id}
                        className='flex items-center justify-between p-3 bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-800/50 dark:to-gray-800/30 rounded-lg hover:shadow-md transition-shadow'
                      >
                        <div className='flex items-center gap-3'>
                          <div className='w-10 h-10 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center'>
                            <Shield className='h-5 w-5 text-white' />
                          </div>
                          <div>
                            <p className='font-medium text-sm'>{role.name}</p>
                            {role.description && (
                              <p className='text-xs text-gray-600 dark:text-gray-400'>
                                {role.description}
                              </p>
                            )}
                          </div>
                        </div>
                        {role.is_active ? (
                          <CheckCircle2 className='h-5 w-5 text-green-500' />
                        ) : (
                          <XCircle className='h-5 w-5 text-gray-400' />
                        )}
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className='text-center py-8 text-gray-500'>
                    <Users className='h-12 w-12 mx-auto mb-3 text-gray-300' />
                    <p>No roles assigned</p>
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Permissions Card */}
            <Card>
              <CardHeader>
                <CardTitle className='flex items-center gap-2'>
                  <Key className='h-5 w-5' />
                  Access Permissions
                </CardTitle>
                <CardDescription>Your current access levels</CardDescription>
              </CardHeader>
              <CardContent>
                <div className='grid gap-4 sm:grid-cols-2'>
                  <div>
                    <h4 className='text-sm font-medium mb-3'>Resource Access</h4>
                    <div className='space-y-2'>
                      {['users:read', 'users:write', 'admin:access'].map((perm) => (
                        <div
                          key={perm}
                          className='flex items-center justify-between p-2 bg-gray-50 dark:bg-gray-800/50 rounded'
                        >
                          <span className='text-sm font-mono'>{perm}</span>
                          {hasPermission(perm) ? (
                            <ShieldCheck className='h-4 w-4 text-green-500' />
                          ) : (
                            <ShieldAlert className='h-4 w-4 text-gray-400' />
                          )}
                        </div>
                      ))}
                    </div>
                  </div>

                  <div>
                    <h4 className='text-sm font-medium mb-3'>Role Status</h4>
                    <div className='space-y-2'>
                      {['admin', 'user', 'moderator'].map((role) => (
                        <div
                          key={role}
                          className='flex items-center justify-between p-2 bg-gray-50 dark:bg-gray-800/50 rounded'
                        >
                          <span className='text-sm capitalize'>{role}</span>
                          {hasRole(role) ? (
                            <UserCheck className='h-4 w-4 text-green-500' />
                          ) : (
                            <UserX className='h-4 w-4 text-gray-400' />
                          )}
                        </div>
                      ))}
                    </div>
                  </div>
                </div>

                {permissions.length > 0 && (
                  <div className='mt-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg'>
                    <p className='text-xs text-blue-700 dark:text-blue-300'>
                      <strong>Total Permissions:</strong> {permissions.length} active
                    </p>
                  </div>
                )}
              </CardContent>
            </Card>
          </motion.div>
        </div>

        {/* Recent Activity */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className='mt-6'
        >
          <Card>
            <CardHeader>
              <CardTitle className='flex items-center gap-2'>
                <Activity className='h-5 w-5' />
                Recent Activity
              </CardTitle>
              <CardDescription>Your latest account activities</CardDescription>
            </CardHeader>
            <CardContent>
              <div className='space-y-3'>
                {recentActivity.map((activity, index) => (
                  <div
                    key={index}
                    className='flex items-center justify-between p-3 hover:bg-gray-50 dark:hover:bg-gray-800/50 rounded-lg transition-colors'
                  >
                    <div className='flex items-center gap-3'>
                      <div
                        className={`w-2 h-2 rounded-full ${
                          activity.type === 'success'
                            ? 'bg-green-500'
                            : activity.type === 'warning'
                            ? 'bg-yellow-500'
                            : 'bg-blue-500'
                        }`}
                      />
                      <span className='text-sm font-medium'>{activity.action}</span>
                    </div>
                    <span className='text-xs text-gray-500 dark:text-gray-400'>
                      <Clock className='h-3 w-3 inline mr-1' />
                      {activity.time}
                    </span>
                  </div>
                ))}
              </div>

              <Button variant='outline' className='w-full mt-4'>
                View All Activity
                <ChevronRight className='h-4 w-4 ml-1' />
              </Button>
            </CardContent>
          </Card>
        </motion.div>

        {/* Quick Actions */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className='mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4'
        >
          <Button
            variant='outline'
            className='h-24 flex flex-col items-center justify-center gap-2 hover:bg-blue-50 hover:border-blue-300 dark:hover:bg-blue-950 dark:hover:border-blue-700'
          >
            <Settings className='h-6 w-6' />
            <span>Settings</span>
          </Button>
          <Button
            variant='outline'
            className='h-24 flex flex-col items-center justify-center gap-2 hover:bg-purple-50 hover:border-purple-300 dark:hover:bg-purple-950 dark:hover:border-purple-700'
          >
            <Shield className='h-6 w-6' />
            <span>Security</span>
          </Button>
          <Button
            variant='outline'
            className='h-24 flex flex-col items-center justify-center gap-2 hover:bg-green-50 hover:border-green-300 dark:hover:bg-green-950 dark:hover:border-green-700'
          >
            <BarChart3 className='h-6 w-6' />
            <span>Analytics</span>
          </Button>
          <Button
            variant='outline'
            className='h-24 flex flex-col items-center justify-center gap-2 hover:bg-orange-50 hover:border-orange-300 dark:hover:bg-orange-950 dark:hover:border-orange-700'
          >
            <Award className='h-6 w-6' />
            <span>Achievements</span>
          </Button>
        </motion.div>
      </main>
    </div>
  );
}