'use client';

import React from 'react';
import { useRequireAuth } from '@/stores/auth.store';
import AdminLayout from '@/components/admin/admin-layout';
import UserTable from '@/components/admin/users/user-table';

export default function AdminUsersPage(): React.ReactElement {
  // Require authentication
  const { user, hasPermission } = useRequireAuth();

  // Check if user has permission to view users
  if (user && !hasPermission('users:read')) {
    return (
      <AdminLayout>
        <div className='flex items-center justify-center h-full'>
          <div className='text-center'>
            <h1 className='text-2xl font-bold text-destructive'>Access Denied</h1>
            <p className='text-muted-foreground mt-2'>
              You don&apos;t have permission to view user management.
            </p>
          </div>
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <UserTable />
    </AdminLayout>
  );
}
