import React from 'react';
import { ArrowLeft, Home, Search, FileX, Compass } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { BackButton } from '@/components/ui/back-button';
import { SupportEmailLink } from '@/components/ui/support-email-link';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';
import Link from 'next/link';
import type { Metadata } from 'next';

/**
 * 404 Not Found Page Component
 *
 * This component is automatically rendered when a route is not found.
 * It provides a user-friendly experience with navigation options and helpful information.
 *
 * @see https://nextjs.org/docs/app/api-reference/file-conventions/not-found
 */

export const metadata: Metadata = {
  title: '404 - Page Not Found | Enterprise Auth Template',
  description:
    'The page you are looking for could not be found. Return to the homepage or explore our available features.',
  robots: {
    index: false,
    follow: false,
  },
};

export default function NotFound(): JSX.Element {
  const navigationLinks = [
    {
      href: '/',
      label: 'Homepage',
      description: 'Return to the main page',
      icon: Home,
    },
    {
      href: '/dashboard',
      label: 'Dashboard',
      description: 'Access your personalized dashboard',
      icon: Compass,
    },
    {
      href: '/auth/login',
      label: 'Sign In',
      description: 'Sign in to your account',
      icon: Search,
    },
  ];

  const commonPages = [
    { href: '/dashboard', label: 'Dashboard' },
    { href: '/profile', label: 'Profile Settings' },
    { href: '/auth/login', label: 'Sign In' },
    { href: '/auth/register', label: 'Create Account' },
  ];

  const supportInfo = {
    email: 'support@example.com',
    docs: '/docs',
    status: 'https://status.example.com',
  };

  return (
    <div className='min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 via-white to-purple-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 p-4'>
      <div className='max-w-4xl w-full'>
        <div className='text-center mb-8'>
          {/* Large 404 Display */}
          <div className='mb-6'>
            <div className='inline-flex items-center justify-center w-32 h-32 bg-gradient-to-br from-blue-100 to-purple-100 dark:from-blue-900/20 dark:to-purple-900/20 rounded-full mb-6'>
              <FileX className='w-16 h-16 text-blue-600 dark:text-blue-400' />
            </div>
            <h1 className='text-8xl font-bold text-gray-200 dark:text-gray-700 mb-2 select-none'>
              404
            </h1>
          </div>

          <h2 className='text-3xl font-bold text-gray-900 dark:text-white mb-4'>Page Not Found</h2>
          <p className='text-lg text-gray-600 dark:text-gray-400 max-w-md mx-auto'>
            Sorry, we couldn&apos;t find the page you&apos;re looking for. It might have been moved,
            deleted, or you might have typed the wrong URL.
          </p>
        </div>

        <div className='grid gap-6 md:grid-cols-2'>
          {/* Quick Navigation */}
          <Card>
            <CardHeader>
              <CardTitle className='flex items-center gap-2'>
                <Compass className='h-5 w-5' />
                Quick Navigation
              </CardTitle>
              <CardDescription>
                Navigate to these popular sections of our application
              </CardDescription>
            </CardHeader>
            <CardContent className='space-y-3'>
              {navigationLinks.map((link) => {
                const IconComponent = link.icon;
                return (
                  <Link key={link.href} href={link.href}>
                    <div className='flex items-center p-3 rounded-lg border border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors group'>
                      <div className='flex items-center justify-center w-10 h-10 bg-blue-100 dark:bg-blue-900/20 rounded-lg mr-3 group-hover:bg-blue-200 dark:group-hover:bg-blue-900/40'>
                        <IconComponent className='h-5 w-5 text-blue-600 dark:text-blue-400' />
                      </div>
                      <div className='flex-1'>
                        <div className='font-medium text-gray-900 dark:text-white'>
                          {link.label}
                        </div>
                        <div className='text-sm text-gray-500 dark:text-gray-400'>
                          {link.description}
                        </div>
                      </div>
                    </div>
                  </Link>
                );
              })}
            </CardContent>
          </Card>

          {/* Common Pages */}
          <Card>
            <CardHeader>
              <CardTitle className='flex items-center gap-2'>
                <Search className='h-5 w-5' />
                Popular Pages
              </CardTitle>
              <CardDescription>
                Looking for something specific? Try these common destinations
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className='space-y-2'>
                {commonPages.map((page) => (
                  <Link key={page.href} href={page.href}>
                    <div className='flex items-center justify-between p-2 rounded hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors'>
                      <span className='text-gray-900 dark:text-white'>{page.label}</span>
                      <ArrowLeft className='h-4 w-4 text-gray-400 rotate-180' />
                    </div>
                  </Link>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        <Separator className='my-8' />

        {/* Action Buttons */}
        <div className='flex flex-col sm:flex-row gap-4 justify-center items-center'>
          <Link href='/'>
            <Button size='lg' className='w-full sm:w-auto'>
              <Home className='mr-2 h-4 w-4' />
              Return Home
            </Button>
          </Link>

          <BackButton className='w-full sm:w-auto' />
        </div>

        <Separator className='my-8' />

        {/* Help Section */}
        <Card className='bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700'>
          <CardContent className='pt-6'>
            <div className='text-center space-y-4'>
              <h3 className='text-lg font-semibold text-gray-900 dark:text-white'>
                Still Can&apos;t Find What You&apos;re Looking For?
              </h3>
              <p className='text-gray-600 dark:text-gray-400 max-w-2xl mx-auto'>
                If you believe this page should exist or if you were directed here by a link from
                our application, please let us know so we can fix the issue.
              </p>

              <div className='flex flex-col sm:flex-row gap-3 justify-center items-center'>
                <SupportEmailLink email={supportInfo.email} />

                <Link href={supportInfo.docs}>
                  <Button variant='ghost' size='sm'>
                    Browse Documentation
                  </Button>
                </Link>

                <a href={supportInfo.status} target='_blank' rel='noopener noreferrer'>
                  <Button variant='ghost' size='sm'>
                    Service Status
                  </Button>
                </a>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Search Suggestion */}
        <div className='mt-8 text-center'>
          <p className='text-sm text-gray-500 dark:text-gray-400'>
            <strong>Tip:</strong> Double-check the URL for typos, or try using the search
            functionality once you&apos;re back on the main site.
          </p>
        </div>
      </div>
    </div>
  );
}
