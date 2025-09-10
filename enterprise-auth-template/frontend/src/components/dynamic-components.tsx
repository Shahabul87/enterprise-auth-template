'use client';

/**
 * Dynamic Component Imports
 *
 * Code-splitting implementation using Next.js dynamic imports
 * for improved bundle size and loading performance.
 */

import dynamic from 'next/dynamic';
import {
  DashboardSkeleton,
  TableSkeleton,
  FormSkeleton,
  LoadingSpinner,
} from '@/components/ui/dynamic-loading';

// Admin Components - Heavy components that should be lazy loaded
export const AdminDashboard = dynamic(
  () => import('@/app/admin/page').then((mod) => ({ default: mod.default })),
  {
    loading: () => <DashboardSkeleton />,
    ssr: false,
  }
);

export const UserManagement = dynamic(
  () => import('@/app/admin/users/page').then((mod) => ({ default: mod.default })),
  {
    loading: () => <TableSkeleton />,
    ssr: false,
  }
);

export const RoleManagement = dynamic(
  () => import('@/app/admin/roles/page').then((mod) => ({ default: mod.default })),
  {
    loading: () => <TableSkeleton />,
    ssr: false,
  }
);

export const AuditLogs = dynamic(
  () => import('@/app/admin/audit-logs/page').then((mod) => ({ default: mod.default })),
  {
    loading: () => <TableSkeleton />,
    ssr: false,
  }
);

export const SystemSettings = dynamic(
  () => import('@/app/admin/settings/page').then((mod) => ({ default: mod.default })),
  {
    loading: () => <FormSkeleton />,
    ssr: false,
  }
);

// Dashboard Components
export const UserDashboard = dynamic(
  () => import('@/app/dashboard/page').then((mod) => ({ default: mod.default })),
  {
    loading: () => <DashboardSkeleton />,
    ssr: false,
  }
);

// Auth Components - Critical path, load with priority
export const LoginForm = dynamic(() => import('@/components/auth/login-form'), {
  loading: () => <FormSkeleton />,
  ssr: true, // Keep SSR for SEO and faster initial load
});

export const RegisterForm = dynamic(() => import('@/components/auth/register-form'), {
  loading: () => <FormSkeleton />,
  ssr: true, // Keep SSR for SEO and faster initial load
});

// Chart Components - Heavy visualization libraries (stub components for now)
// TODO: Implement actual chart components when needed
export const AnalyticsChart = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>Analytics Chart - To be implemented</p>
  </div>
);

export const UsageChart = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>Usage Chart - To be implemented</p>
  </div>
);

export const RevenueChart = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>Revenue Chart - To be implemented</p>
  </div>
);

// Table Components - Data heavy components
export const UserTable = dynamic(() => import('@/components/admin/users/user-table'), {
  loading: () => <TableSkeleton />,
  ssr: false,
});

export const RoleTable = dynamic(() => import('@/components/admin/roles/role-table'), {
  loading: () => <TableSkeleton />,
  ssr: false,
});

// TODO: Implement audit table component
export const AuditTable = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>Audit Table - To be implemented</p>
  </div>
);

// Modal Components - Stub implementations
// TODO: Implement these modal components when needed
export const UserEditModal = ({ isOpen, onClose }: { isOpen: boolean; onClose: () => void; user?: unknown }) =>
  isOpen ? (
    <div className='fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center'>
      <div className='bg-white p-6 rounded-lg'>
        <p>User Edit Modal - To be implemented</p>
        <button onClick={onClose} className='mt-4 px-4 py-2 bg-gray-200 rounded'>
          Close
        </button>
      </div>
    </div>
  ) : null;

export const RoleEditModal = ({ isOpen, onClose }: { isOpen: boolean; onClose: () => void; role?: unknown }) =>
  isOpen ? (
    <div className='fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center'>
      <div className='bg-white p-6 rounded-lg'>
        <p>Role Edit Modal - To be implemented</p>
        <button onClick={onClose} className='mt-4 px-4 py-2 bg-gray-200 rounded'>
          Close
        </button>
      </div>
    </div>
  ) : null;

export const ConfirmationModal = ({ isOpen, onClose, onConfirm, message }: { isOpen: boolean; onClose: () => void; onConfirm: () => void; message: string }) =>
  isOpen ? (
    <div className='fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center'>
      <div className='bg-white p-6 rounded-lg'>
        <p>{message || 'Confirmation Modal - To be implemented'}</p>
        <div className='mt-4 space-x-2'>
          <button onClick={onClose} className='px-4 py-2 bg-gray-200 rounded'>
            Cancel
          </button>
          <button onClick={onConfirm} className='px-4 py-2 bg-red-500 text-white rounded'>
            Confirm
          </button>
        </div>
      </div>
    </div>
  ) : null;

// File Upload Components - Stub implementations
export const FileUploader = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>File Uploader - To be implemented</p>
  </div>
);

export const ImageEditor = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>Image Editor - To be implemented</p>
  </div>
);

export const CodeEditor = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>Code Editor - To be implemented</p>
  </div>
);

export const RichTextEditor = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>Rich Text Editor - To be implemented</p>
  </div>
);

export const PDFViewer = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>PDF Viewer - To be implemented</p>
  </div>
);

// Advanced Components - Stub implementations
export const DataVisualization = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>Data Visualization - To be implemented</p>
  </div>
);

export const ReportGenerator = () => (
  <div className='p-4 border rounded-lg'>
    <p className='text-muted-foreground'>Report Generator - To be implemented</p>
  </div>
);

// Utility function to create dynamic component with error handling
export const createDynamicComponent = <T extends React.ComponentType<unknown>>(
  importFn: () => Promise<{ default: T } | T>,
  options: {
    loading?: React.ComponentType;
    error?: React.ComponentType<{ error: Error; retry: () => void }>;
    ssr?: boolean;
  } = {}
) => {
  return dynamic(importFn, {
    loading: options.loading ? () => {
      const LoadingComponent = options.loading!;
      return <LoadingComponent />;
    } : () => <LoadingSpinner />,
    ssr: options.ssr || false,
  });
};

// Preload functions for critical components
export const preloadCriticalComponents = () => {
  // Preload components that are likely to be needed soon
  import('@/components/auth/login-form');
  import('@/components/auth/register-form');
};

export const preloadAdminComponents = () => {
  // Preload admin components when user navigates to admin area
  import('@/app/admin/page');
  import('@/components/admin/users/user-table');
  import('@/app/admin/users/page');
};

export const preloadDashboardComponents = () => {
  // Preload dashboard components when user logs in
  import('@/app/dashboard/page');
  // TODO: Preload actual chart components when implemented
};
