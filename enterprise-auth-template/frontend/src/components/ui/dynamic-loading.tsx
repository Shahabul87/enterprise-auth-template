'use client';

/**
 * Dynamic Loading Components
 *
 * Provides loading states for dynamically imported components
 * to improve perceived performance and user experience.
 */

import { Skeleton } from '@/components/ui/skeleton';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Loader2 } from 'lucide-react';

export const DashboardSkeleton = () => (
  <div className='space-y-6'>
    {/* Header skeleton */}
    <div className='flex items-center justify-between'>
      <Skeleton className='h-8 w-48' />
      <Skeleton className='h-10 w-32' />
    </div>

    {/* Stats cards skeleton */}
    <div className='grid gap-4 md:grid-cols-2 lg:grid-cols-4'>
      {Array.from({ length: 4 }).map((_, i) => (
        <Card key={i}>
          <CardHeader className='flex flex-row items-center justify-between space-y-0 pb-2'>
            <Skeleton className='h-4 w-24' />
            <Skeleton className='h-4 w-4 rounded' />
          </CardHeader>
          <CardContent>
            <Skeleton className='h-7 w-16 mb-1' />
            <Skeleton className='h-3 w-32' />
          </CardContent>
        </Card>
      ))}
    </div>

    {/* Main content skeleton */}
    <div className='grid gap-4 md:grid-cols-2 lg:grid-cols-7'>
      <Card className='col-span-4'>
        <CardHeader>
          <Skeleton className='h-5 w-40' />
        </CardHeader>
        <CardContent>
          <Skeleton className='h-64 w-full' />
        </CardContent>
      </Card>

      <Card className='col-span-3'>
        <CardHeader>
          <Skeleton className='h-5 w-32' />
        </CardHeader>
        <CardContent>
          <div className='space-y-4'>
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className='flex items-center space-x-4'>
                <Skeleton className='h-12 w-12 rounded-full' />
                <div className='space-y-2'>
                  <Skeleton className='h-4 w-32' />
                  <Skeleton className='h-3 w-24' />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
);

export const TableSkeleton = () => (
  <div className='space-y-4'>
    {/* Table header */}
    <div className='flex items-center justify-between'>
      <Skeleton className='h-8 w-32' />
      <div className='flex space-x-2'>
        <Skeleton className='h-9 w-20' />
        <Skeleton className='h-9 w-24' />
      </div>
    </div>

    {/* Table content */}
    <Card>
      <CardHeader>
        <div className='grid grid-cols-4 gap-4'>
          <Skeleton className='h-4 w-16' />
          <Skeleton className='h-4 w-20' />
          <Skeleton className='h-4 w-14' />
          <Skeleton className='h-4 w-18' />
        </div>
      </CardHeader>
      <CardContent>
        <div className='space-y-3'>
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className='grid grid-cols-4 gap-4 items-center'>
              <Skeleton className='h-4 w-24' />
              <Skeleton className='h-4 w-32' />
              <Skeleton className='h-6 w-16 rounded-full' />
              <Skeleton className='h-8 w-20' />
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  </div>
);

export const FormSkeleton = () => (
  <Card>
    <CardHeader>
      <Skeleton className='h-6 w-40' />
      <Skeleton className='h-4 w-64' />
    </CardHeader>
    <CardContent className='space-y-6'>
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className='space-y-2'>
          <Skeleton className='h-4 w-20' />
          <Skeleton className='h-10 w-full' />
        </div>
      ))}

      <div className='flex justify-end space-x-2'>
        <Skeleton className='h-10 w-20' />
        <Skeleton className='h-10 w-24' />
      </div>
    </CardContent>
  </Card>
);

export const LoadingSpinner = ({
  message = 'Loading...',
  size = 24,
}: {
  message?: string;
  size?: number;
}) => (
  <div className='flex items-center justify-center space-x-2 py-8'>
    <Loader2 className={`animate-spin`} size={size} />
    <span className='text-sm text-muted-foreground'>{message}</span>
  </div>
);

export const ErrorFallback = ({ error, retry }: { error: Error; retry?: () => void }) => (
  <Card>
    <CardContent className='py-8 text-center'>
      <div className='text-destructive mb-2'>
        <span className='text-lg font-semibold'>Something went wrong</span>
      </div>
      <p className='text-sm text-muted-foreground mb-4'>
        {error.message || 'An unexpected error occurred'}
      </p>
      {retry && (
        <button onClick={retry} className='text-sm underline hover:no-underline'>
          Try again
        </button>
      )}
    </CardContent>
  </Card>
);
