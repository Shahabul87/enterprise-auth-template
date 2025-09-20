'use client';

import React from 'react';
import { useRequireAuth } from '@/stores/auth.store';
import AdminLayout from '@/components/admin/admin-layout';
import AdminDashboard from '@/components/admin/admin-dashboard';

export default function AdminPage(): React.ReactElement {
  // Require authentication and admin permissions
  const { user, hasPermission } = useRequireAuth();

  // Check if user has admin dashboard access
  if (user && !hasPermission('dashboard:read')) {
    return (
      <AdminLayout>
        <div className='flex items-center justify-center h-full'>
          <div className='text-center'>
            <h1 className='text-2xl font-bold text-destructive'>Access Denied</h1>
            <p className='text-muted-foreground mt-2'>
              You don&apos;t have permission to access the admin dashboard.
            </p>
          </div>
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <AdminDashboard />
    </AdminLayout>
  );
}
