import React from 'react';
import { Loader2, Shield, Zap, Clock } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';

/**
 * Global Loading Component for Next.js App Router
 *
 * This component is automatically shown when navigating between pages or
 * when page components are loading. It provides a consistent loading experience
 * across the entire application.
 *
 * @see https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming
 */

const LoadingSpinner = ({ size = 24 }: { size?: number }) => (
  <Loader2 className={`animate-spin`} size={size} />
);

const FeatureLoadingCard = ({
  icon: Icon,
  title,
  description,
}: {
  icon: React.ComponentType<React.SVGProps<SVGSVGElement>>;
  title: string;
  description: string;
}) => (
  <Card className='border-gray-200 dark:border-gray-700 bg-white/50 dark:bg-gray-800/50 backdrop-blur-sm'>
    <CardContent className='p-6 text-center'>
      <div className='flex justify-center mb-3'>
        <div className='w-12 h-12 rounded-full bg-blue-100 dark:bg-blue-900/20 flex items-center justify-center'>
          <Icon className='h-6 w-6 text-blue-600 dark:text-blue-400' />
        </div>
      </div>
      <h3 className='font-semibold text-gray-900 dark:text-white mb-2'>{title}</h3>
      <p className='text-sm text-gray-600 dark:text-gray-400'>{description}</p>
    </CardContent>
  </Card>
);

const NavigationSkeleton = () => (
  <div className='border-b border-gray-200 dark:border-gray-700 bg-white/80 dark:bg-gray-900/80 backdrop-blur-sm'>
    <div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8'>
      <div className='flex justify-between items-center h-16'>
        {/* Logo skeleton */}
        <div className='flex items-center'>
          <Skeleton className='h-8 w-8 rounded' />
          <Skeleton className='h-6 w-32 ml-3' />
        </div>

        {/* Navigation links skeleton */}
        <div className='hidden md:flex items-center space-x-8'>
          <Skeleton className='h-4 w-16' />
          <Skeleton className='h-4 w-20' />
          <Skeleton className='h-4 w-18' />
        </div>

        {/* User menu skeleton */}
        <div className='flex items-center space-x-4'>
          <Skeleton className='h-8 w-8 rounded-full' />
          <Skeleton className='h-4 w-20' />
        </div>
      </div>
    </div>
  </div>
);

const HeroSectionSkeleton = () => (
  <div className='relative bg-gradient-to-r from-blue-50 to-purple-50 dark:from-gray-900 dark:to-gray-800 py-24'>
    <div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8'>
      <div className='text-center'>
        <Skeleton className='h-12 w-96 mx-auto mb-6' />
        <Skeleton className='h-6 w-128 mx-auto mb-4' />
        <Skeleton className='h-6 w-96 mx-auto mb-8' />

        <div className='flex justify-center space-x-4'>
          <Skeleton className='h-12 w-32' />
          <Skeleton className='h-12 w-28' />
        </div>
      </div>
    </div>
  </div>
);

const ContentSkeleton = () => (
  <div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12'>
    {/* Features grid skeleton */}
    <div className='grid md:grid-cols-3 gap-6 mb-12'>
      {Array.from({ length: 3 }).map((_, i) => (
        <Card key={i} className='p-6'>
          <div className='flex items-center mb-4'>
            <Skeleton className='h-12 w-12 rounded-lg mr-4' />
            <div>
              <Skeleton className='h-5 w-24 mb-2' />
              <Skeleton className='h-4 w-32' />
            </div>
          </div>
          <Skeleton className='h-4 w-full mb-2' />
          <Skeleton className='h-4 w-3/4' />
        </Card>
      ))}
    </div>

    {/* Stats section skeleton */}
    <div className='grid md:grid-cols-4 gap-6 mb-12'>
      {Array.from({ length: 4 }).map((_, i) => (
        <div key={i} className='text-center'>
          <Skeleton className='h-8 w-16 mx-auto mb-2' />
          <Skeleton className='h-4 w-20 mx-auto' />
        </div>
      ))}
    </div>
  </div>
);

export default function Loading(): React.ReactElement {
  return (
    <div className='min-h-screen bg-gradient-to-br from-gray-50 via-white to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900'>
      {/* Navigation Skeleton */}
      <NavigationSkeleton />

      {/* Main Loading Content */}
      <div className='relative'>
        {/* Loading Overlay */}
        <div className='fixed inset-0 bg-white/70 dark:bg-gray-900/70 backdrop-blur-sm z-40 flex items-center justify-center'>
          <Card className='mx-4 shadow-xl border-0 bg-white/90 dark:bg-gray-800/90 backdrop-blur-md'>
            <CardContent className='p-8 text-center max-w-md'>
              {/* Animated Logo/Icon */}
              <div className='flex justify-center mb-6'>
                <div className='relative'>
                  <div className='w-16 h-16 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 flex items-center justify-center animate-pulse'>
                    <Shield className='h-8 w-8 text-white' />
                  </div>
                  <div className='absolute -top-1 -right-1'>
                    <LoadingSpinner size={20} />
                  </div>
                </div>
              </div>

              {/* Loading Message */}
              <h2 className='text-2xl font-bold text-gray-900 dark:text-white mb-2'>
                Loading Application
              </h2>
              <p className='text-gray-600 dark:text-gray-400 mb-6'>
                Preparing your secure authentication experience...
              </p>

              {/* Progress Indicator */}
              <div className='space-y-3 mb-6'>
                <div className='w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2'>
                  <div
                    className='bg-gradient-to-r from-blue-500 to-purple-600 h-2 rounded-full animate-pulse'
                    style={{ width: '70%' }}
                  ></div>
                </div>
                <div className='flex items-center justify-center text-sm text-gray-500 dark:text-gray-400'>
                  <Clock className='h-4 w-4 mr-2' />
                  This should only take a moment
                </div>
              </div>

              {/* Loading Features */}
              <div className='space-y-2 text-sm'>
                <div className='flex items-center text-gray-600 dark:text-gray-400'>
                  <div className='w-2 h-2 bg-green-500 rounded-full mr-3'></div>
                  Initializing secure session
                </div>
                <div className='flex items-center text-gray-600 dark:text-gray-400'>
                  <div className='w-2 h-2 bg-green-500 rounded-full mr-3'></div>
                  Loading user preferences
                </div>
                <div className='flex items-center text-gray-600 dark:text-gray-400'>
                  <LoadingSpinner size={8} />
                  <span className='ml-3'>Preparing dashboard</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Background Content Skeletons */}
        <div className='relative z-10'>
          <HeroSectionSkeleton />

          {/* Features Preview */}
          <div className='py-16 bg-white dark:bg-gray-800'>
            <div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8'>
              <div className='text-center mb-12'>
                <Skeleton className='h-8 w-64 mx-auto mb-4' />
                <Skeleton className='h-5 w-96 mx-auto' />
              </div>

              <div className='grid md:grid-cols-3 gap-8'>
                <FeatureLoadingCard
                  icon={Shield}
                  title='Enterprise Security'
                  description='Advanced authentication and authorization features'
                />
                <FeatureLoadingCard
                  icon={Zap}
                  title='High Performance'
                  description='Optimized for speed and scalability'
                />
                <FeatureLoadingCard
                  icon={Clock}
                  title='Real-time Updates'
                  description='Live synchronization across all devices'
                />
              </div>
            </div>
          </div>

          <ContentSkeleton />
        </div>
      </div>
    </div>
  );
}
