'use client';

import React from 'react';
import { useRequireAuth } from '@/stores/auth.store';
import AdminLayout from '@/components/admin/admin-layout';
import RealTimeMetricsDashboard from '@/components/admin/metrics/real-time-metrics-dashboard';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { AlertCircle } from 'lucide-react';

export default function AdminMetricsPage(): React.ReactElement {
  // Require authentication and admin permissions
  const { user, hasPermission } = useRequireAuth();

  // Check if user has admin dashboard access
  if (user && !hasPermission('metrics:read')) {
    return (
      <AdminLayout>
        <Alert variant='destructive'>
          <AlertCircle className='h-4 w-4' />
          <AlertDescription>
            You don&apos;t have permission to view system metrics.
          </AlertDescription>
        </Alert>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <RealTimeMetricsDashboard />
    </AdminLayout>
  );
}