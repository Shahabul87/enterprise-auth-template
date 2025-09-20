import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import UserManagement from '@/components/admin/UserManagement';
import { useAuth, useRequireAuth } from '@/stores/auth.store';
import AdminAPI from '@/lib/admin-api';
import type { User } from '@/types';
/**
 * @jest-environment jsdom
 */
jest.mock('@/stores/auth.store', () => ({
  useAuthStore: jest.fn(() => ({
    user: null,
    tokens: null,
    accessToken: null,
    isAuthenticated: false,
    isLoading: false,
    isInitialized: true,
    permissions: [],
    roles: [],
    session: null,
    error: null,
    authErrors: [],
    isEmailVerified: false,
    is2FAEnabled: false,
    requiresPasswordChange: false,
    isTokenValid: () => true,
    initialize: async () => {},
    login: async () => ({ success: true, data: { user: null, tokens: null } }),
    register: async () => ({ success: true, data: { message: 'Success' } }),
    logout: async () => {},
    refreshToken: async () => true,
    refreshAccessToken: async () => null,
    updateUser: () => {},
    hasPermission: () => false,
    hasRole: () => false,
    hasAnyRole: () => false,
    hasAllPermissions: () => false,
    setError: () => {},
    clearError: () => {},
    addAuthError: () => {},
    clearAuthErrors: () => {},
    updateSession: () => {},
    checkSession: async () => true,
    extendSession: async () => {},
    fetchUserData: async () => {},
    fetchPermissions: async () => {},
    verifyEmail: async () => ({ success: true, data: { message: 'Success' } }),
    resendVerification: async () => ({ success: true, data: { message: 'Success' } }),
    changePassword: async () => ({ success: true, data: { message: 'Success' } }),
    requestPasswordReset: async () => ({ success: true, data: { message: 'Success' } }),
    confirmPasswordReset: async () => ({ success: true, data: { message: 'Success' } }),
    setup2FA: async () => ({ success: true, data: { qr_code: '', backup_codes: [] } }),
    verify2FA: async () => ({ success: true, data: { enabled: true, message: 'Success' } }),
    disable2FA: async () => ({ success: true, data: { enabled: false, message: 'Success' } }),
    clearAuth: () => {},
    setupTokenRefresh: () => {},
    clearAuthData: () => {},
    setAuth: () => {},
    user: null,
    isAuthenticated: false,
    isLoading: false,
    permissions: [],
    hasPermission: jest.fn(() => false),
    hasRole: jest.fn(() => false),
  useGuestOnly: jest.fn(() => ({
    isLoading: false,
  }))}}))));,
    user: null,
    isAuthenticated: false,
    isLoading: false,
    error: null,
    login: jest.fn().mockResolvedValue({ success: true }),
    register: jest.fn().mockResolvedValue({ success: true }),
    logout: jest.fn().mockResolvedValue(undefined),
    setUser: jest.fn(),
    clearError: jest.fn(),
    refreshToken: jest.fn().mockResolvedValue(true),
    requestPasswordReset: jest.fn().mockResolvedValue({ success: true }),
    confirmPasswordReset: jest.fn().mockResolvedValue({ success: true }),
    verifyEmail: jest.fn().mockResolvedValue({ success: true }),
    resendVerification: jest.fn().mockResolvedValue({ success: true }),
    initialize: jest.fn().mockResolvedValue(undefined),
}}));
jest.mock('@/lib/admin-api');
jest.mock('@/stores/adminStore', () => ({
  useAdminStore: jest.fn(() => ({
    users: [],
    totalUsers: 0,
    currentPage: 1,
    pageSize: 10,
    isLoading: false,
    error: null,
    fetchUsers: jest.fn(),
    updateUser: jest.fn(),
    deleteUser: jest.fn(),
    createUser: jest.fn(),
    bulkAction: jest.fn(),
  })),
jest.mock('@/components/ui/card', () => ({
  Card: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  CardContent: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  CardHeader: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  CardTitle: ({ children, ...props }: any) => <h3 {...props}>{children}</h3>,
jest.mock('@/components/ui/button', () => ({
  Button: ({ children, onClick, ...props }: any) => (
    <button onClick={onClick} {...props}>{children}</button>
  ),
jest.mock('@/components/ui/badge', () => ({
  Badge: ({ children, ...props }: any) => <span {...props}>{children}</span>,
jest.mock('@/components/ui/input', () => ({
  Input: (props: any) => <input {...props} />,
}));
jest.mock('@/components/ui/label', () => ({
  Label: ({ children, ...props }: any) => <label {...props}>{children}</label>,
jest.mock('@/components/ui/dialog', () => ({
  Dialog: ({ children, open }: any) => open ? <div>{children}</div> : null,
  DialogContent: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  DialogDescription: ({ children, ...props }: any) => <p {...props}>{children}</p>,
  DialogFooter: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  DialogHeader: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  DialogTitle: ({ children, ...props }: any) => <h2 {...props}>{children}</h2>,
  DialogTrigger: ({ children, ...props }: any) => <div {...props}>{children}</div>,
jest.mock('@/components/ui/select', () => ({
  Select: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  SelectContent: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  SelectItem: ({ children, value, ...props }: any) => (
    <div data-value={value} {...props}>{children}</div>
  ),
  SelectTrigger: ({ children, ...props }: any) => (
    <button role="combobox" {...props}>{children}</button>
  ),
  SelectValue: ({ placeholder }: any) => <span>{placeholder}</span>,
jest.mock('@/components/ui/table', () => ({
  Table: ({ children, ...props }: any) => <table {...props}>{children}</table>,
  TableBody: ({ children, ...props }: any) => <tbody {...props}>{children}</tbody>,
  TableCell: ({ children, ...props }: any) => <td {...props}>{children}</td>,
  TableHead: ({ children, ...props }: any) => <th {...props}>{children}</th>,
  TableHeader: ({ children, ...props }: any) => <thead {...props}>{children}</thead>,
  TableRow: ({ children, ...props }: any) => <tr {...props}>{children}</tr>,
jest.mock('@/components/ui/dropdown-menu', () => ({
  DropdownMenu: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  DropdownMenuContent: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  DropdownMenuItem: ({ children, onClick, ...props }: any) => (
    <button onClick={onClick} {...props}>{children}</button>
  ),
  DropdownMenuLabel: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  DropdownMenuSeparator: () => <hr />,
  DropdownMenuTrigger: ({ children, ...props }: any) => <div {...props}>{children}</div>,
jest.mock('@/components/ui/alert', () => ({
  Alert: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  AlertDescription: ({ children, ...props }: any) => <p {...props}>{children}</p>,
  AlertTitle: ({ children, ...props }: any) => <h4 {...props}>{children}</h4>,
jest.mock('@/components/ui/skeleton', () => ({
  Skeleton: (props: any) => <div data-testid="user-management-skeleton" {...props} />,
jest.mock('@/components/ui/checkbox', () => ({
  Checkbox: (props: any) => <input type="checkbox" role="checkbox" {...props} />,
jest.mock('@/components/ui/switch', () => ({
  Switch: (props: any) => <input type="checkbox" role="switch" {...props} />,
jest.mock('@/components/ui/textarea', () => ({
  Textarea: (props: any) => <textarea {...props} />,
}));
jest.mock('@/components/ui/avatar', () => ({
  Avatar: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  AvatarFallback: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  AvatarImage: (props: any) => <img {...props} />,
jest.mock('@/components/ui/use-toast', () => ({
  useToast: () => ({
    toast: jest.fn(),
  }),
}));
jest.mock('date-fns', () => ({
  formatDistanceToNow: jest.fn((date) => 'recently'),
  format: jest.fn((date, formatStr) => 'formatted date'),
jest.mock('lucide-react', () => ({
  Plus: () => <div data-testid="plus-icon" />,
  Search: () => <div data-testid="search-icon" />,
  Download: () => <div data-testid="download-icon" />,
  Upload: () => <div data-testid="upload-icon" />,
  MoreVertical: () => <div data-testid="more-icon" />,
  Shield: () => <div data-testid="shield-icon" />,
  Ban: () => <div data-testid="ban-icon" />,
  Mail: () => <div data-testid="mail-icon" />,
  CheckCircle: () => <div data-testid="check-circle-icon" />,
  XCircle: () => <div data-testid="x-circle-icon" />,
  Trash2: () => <div data-testid="trash-icon" />,
  Edit: () => <div data-testid="edit-icon" />,
  Eye: () => <div data-testid="eye-icon" />,
  Key: () => <div data-testid="key-icon" />,
  ChevronLeft: () => <div data-testid="chevron-left-icon" />,
  ChevronRight: () => <div data-testid="chevron-right-icon" />,
  ChevronsLeft: () => <div data-testid="chevrons-left-icon" />,
  ChevronsRight: () => <div data-testid="chevrons-right-icon" />,
  ArrowUp: () => <div data-testid="arrow-up-icon" />,
  ArrowDown: () => <div data-testid="arrow-down-icon" />,
  Info: () => <div data-testid="info-icon" />,
  Filter: () => <div data-testid="filter-icon" />,
  MoreHorizontal: () => <div data-testid="more-icon" />,
  Trash: () => <div data-testid="trash-icon" />,
  UserPlus: () => <div data-testid="user-plus-icon" />,
  RefreshCw: () => <div data-testid="refresh-icon" />,
  const mockAdminAPI = jest.mocked(AdminAPI);
  const mockGetUsers = mockAdminAPI.getUsers;
  const mockUseAuth = jest.mocked(useAuth);
/**
 * UserManagement Component Tests
 * Tests the user management admin component with proper TypeScript types
 */
// Type definitions
interface MockAuthStore {
  user: User | null;
  isAuthenticated: boolean;
  permissions: string[];
  hasPermission: jest.MockedFunction<(permission: string) => boolean>;
// Mock AdminAPI with proper static method mocking
// Mock UI components from shadcn/ui
// Mock Lucide icons
}
describe('UserManagement Component', () => {
  let queryClient: QueryClient;
  let mockAuthStore: MockAuthStore;
  let mockAdminStore: any;
// Mock data with correct schema alignment for UserManagement component
  const mockUsers = [
    {
      id: '1',
      email: 'admin@example.com',
      name: 'Admin User', // This component expects name field
      first_name: 'Admin',
      full_name: 'Admin User',
      two_factor_enabled: true,
      roles: ['admin'], // This component expects string array
      status: 'active',
    {
      id: '2',
      email: 'user@example.com',
      name: 'Regular User',
      first_name: 'Regular',
      full_name: 'Regular User',
      is_superuser: false,
      roles: ['user'],
      status: 'active',
    {
      id: '3',
      email: 'suspended@example.com',
      name: 'Suspended User',
      first_name: 'Suspended',
      full_name: 'Suspended User',
      is_active: false,
      is_verified: false,
      email_verified: false,
      is_superuser: false,
      roles: ['user'],
      status: 'suspended',
// Get references to the mocked AdminAPI functions
  const mockBulkUserOperation = mockAdminAPI.bulkUserOperation;
  const mockActivateUser = mockAdminAPI.activateUser;
  const mockDeactivateUser = mockAdminAPI.deactivateUser;
  const mockVerifyUser = mockAdminAPI.verifyUser;
  const mockUnverifyUser = mockAdminAPI.unverifyUser;
  const mockCreateUser = mockAdminAPI.createUser;
  const mockUpdateUser = mockAdminAPI.updateUser;
  const mockDeleteUser = mockAdminAPI.deleteUser;
  const mockGenerateUserReport = mockAdminAPI.generateUserReport;
  beforeEach(() => {
    jest.clearAllMocks();
    queryClient = new QueryClient({
      defaultOptions: {
        queries: { retry: false },
      },
    });
    mockAuthStore = {
      user: mockUsers[0] as User,
      isAuthenticated: true,
      permissions: ['users:read', 'users:create', 'users:update', 'users:delete'],
      hasPermission: jest.fn((permission: string) =>
        ['users:read', 'users:create', 'users:update', 'users:delete'].includes(permission)
      ),
    };
    mockAdminStore = {
      users: mockUsers,
      totalUsers: mockUsers.length,
      currentPage: 1,
      pageSize: 10,
      isLoading: false,
      error: null,
      fetchUsers: jest.fn(),
      updateUser: jest.fn(),
      deleteUser: jest.fn(),
      createUser: jest.fn(),
      bulkAction: jest.fn(),
    };
    (useRequireAuth as jest.Mock).mockReturnValue(mockAuthStore);
    const { useAdminStore } = require('@/stores/adminStore');
    useAdminStore.mockReturnValue(mockAdminStore);
    // Default API responses using AdminAPI pattern
    mockGetUsers.mockResolvedValue({
      success: true,
      data: {
        items: mockUsers,
        total: mockUsers.length,
        pages: 1,
        page: 1,
        per_page: 10,
        has_next: false,
        has_prev: false,
      },
    });
    mockCreateUser.mockResolvedValue({ success: true, data: mockUsers[0] });
    mockUpdateUser.mockResolvedValue({ success: true, data: mockUsers[0] });
    mockDeleteUser.mockResolvedValue({ success: true });
    mockBulkUserOperation.mockResolvedValue({ success: true });
    mockActivateUser.mockResolvedValue({ success: true });
    mockDeactivateUser.mockResolvedValue({ success: true });
    mockVerifyUser.mockResolvedValue({ success: true });
    mockUnverifyUser.mockResolvedValue({ success: true });
    mockGenerateUserReport.mockResolvedValue({
      success: true,
      data: { download_url: 'http://example.com/report.csv' },
    });
  });
  const renderComponent = () => {
    return render(
      <QueryClientProvider client={queryClient}>
        <UserManagement />
      </QueryClientProvider>
    );
  };
  describe('Rendering', () => {
    it('should render the user management interface', async () => {
      renderComponent();
      await act(async () => { await waitFor(() => {
        expect(screen.getByText('User Management')).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/search users/i)).toBeInTheDocument();
        expect(screen.getByRole('button', { name: /add user/i })).toBeInTheDocument();
      });
    }); });
    it('should display users in a table', async () => {
      renderComponent();
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText('admin@example.com')).toBeInTheDocument();
        expect(screen.getByText('user@example.com')).toBeInTheDocument();
        expect(screen.getByText('suspended@example.com')).toBeInTheDocument();
      }); });
    });
    it('should show user status badges', async () => {
      renderComponent();
      await act(async () => { await waitFor(() => {
        const activeBadges = screen.getAllByText('active');
        expect(activeBadges).toHaveLength(2);
        expect(screen.getByText('suspended')).toBeInTheDocument();
      },
    { timeout: 5000 });
    }); });
    it('should show user roles', async () => {
      renderComponent();
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText('admin')).toBeInTheDocument();
        expect(screen.getAllByText('user')).toHaveLength(2);
      }); });
    });
  });

describe('Search and Filtering', () => {
    it('should filter users by search term', async () => {
      renderComponent();
      const searchInput = screen.getByPlaceholderText(/search users/i);
      await act(async () => { await userEvent.type(searchInput, 'admin');
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText('admin@example.com')).toBeInTheDocument();
        expect(screen.queryByText('user@example.com')).not.toBeInTheDocument();
      }); });
    });
    it('should filter users by role', async () => {
      renderComponent();
      const roleFilter = screen.getByRole('combobox', { name: /filter by role/i });
      await act(async () => { await userEvent.click(roleFilter);
      await act(async () => { await userEvent.click(screen.getByText('Admin'));
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText('admin@example.com')).toBeInTheDocument();
        expect(screen.queryByText('user@example.com')).not.toBeInTheDocument();
      }); });
    });
    it('should filter users by status', async () => {
      renderComponent();
      const statusFilter = screen.getByRole('combobox', { name: /filter by status/i });
      await act(async () => { await userEvent.click(statusFilter);
      await act(async () => { await userEvent.click(screen.getByText('Suspended'));
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText('suspended@example.com')).toBeInTheDocument();
        expect(screen.queryByText('admin@example.com')).not.toBeInTheDocument();
      }); });
    });
    it('should clear filters when clear button is clicked', async () => {
      renderComponent();
      const searchInput = screen.getByPlaceholderText(/search users/i);
      await act(async () => { await userEvent.type(searchInput, 'admin');
      const clearButton = screen.getByRole('button', { name: /clear filters/i });
      await act(async () => { await userEvent.click(clearButton);
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(searchInput).toHaveValue('');
        expect(screen.getByText('user@example.com')).toBeInTheDocument();
      }); });
    });
  });

describe('User Actions', () => {
    it('should open edit dialog when edit button is clicked', async () => {
      renderComponent();
      await act(async () => { await act(async () => { await waitFor(() => {
        const editButtons = screen.getAllByTestId('edit-icon');
        if (editButtons[0]) act(() => { fireEvent.click(editButtons[0]) });
      }); });
      expect(screen.getByText('Edit User')).toBeInTheDocument();
      expect(screen.getByLabelText('Email')).toHaveValue('admin@example.com');
    });
    it('should update user when edit form is submitted', async () => {
      mockUpdateUser.mockResolvedValueOnce({
        success: true,
        data: { ...mockUsers[0], first_name: 'Updated', last_name: 'Admin' },
      });
      renderComponent();
      await act(async () => { await waitFor(() => {
        const editButtons = screen.getAllByTestId('edit-icon');
        if (editButtons[0]) act(() => { fireEvent.click(editButtons[0]) });
      });
      const nameInput = screen.getByLabelText('Name');
      await act(async () => { await userEvent.clear(nameInput);
      await act(async () => { await userEvent.type(nameInput, 'Updated Admin');
      const saveButton = screen.getByRole('button', { name: /save changes/i });
      await act(async () => { await userEvent.click(saveButton);
      await act(async () => { await waitFor(() => {
        expect(mockUpdateUser).toHaveBeenCalledWith('1', expect.objectContaining({
          first_name: 'Updated',
          last_name: 'Admin',
      });
    }); });
    it('should open delete confirmation when delete button is clicked', async () => {
      renderComponent();
      await act(async () => { await act(async () => { await waitFor(() => {
        const deleteButtons = screen.getAllByTestId('trash-icon');
        if (deleteButtons[0]) act(() => { fireEvent.click(deleteButtons[0]) });
      }); });
      expect(screen.getByText('Delete User')).toBeInTheDocument();
      expect(screen.getByText(/are you sure you want to delete/i)).toBeInTheDocument();
    });
    it('should delete user when confirmed', async () => {
      renderComponent();
      await act(async () => { await waitFor(() => {
        const deleteButtons = screen.getAllByTestId('trash-icon');
        if (deleteButtons[0]) act(() => { fireEvent.click(deleteButtons[0]) });
      });
      const confirmButton = screen.getByRole('button', { name: /delete/i });
      await act(async () => { await userEvent.click(confirmButton);
      await act(async () => { await waitFor(() => {
        expect(mockDeleteUser).toHaveBeenCalledWith('1');
      });
    }); });
    it('should suspend user when suspend action is clicked', async () => {
      renderComponent();
      await act(async () => { await waitFor(() => {
        const moreButtons = screen.getAllByTestId('more-icon');
        if (moreButtons[1]) act(() => { fireEvent.click(moreButtons[1]) }); // Click on regular user's actions
      });
      const suspendOption = screen.getByText('Suspend User');
      await act(async () => { await userEvent.click(suspendOption);
      await act(async () => { await waitFor(() => {
        expect(mockDeactivateUser).toHaveBeenCalledWith('2');
      });
    }); });
    it('should reset user password when reset action is clicked', async () => {
      renderComponent();
      await act(async () => { await waitFor(() => {
        const moreButtons = screen.getAllByTestId('more-icon');
        if (moreButtons[0]) act(() => { fireEvent.click(moreButtons[0]) });
      });
      const resetOption = screen.getByText('Reset Password');
      await act(async () => { await userEvent.click(resetOption);
      expect(screen.getByText(/password reset email will be sent/i)).toBeInTheDocument();
      const confirmButton = screen.getByRole('button', { name: /send reset email/i });
      await act(async () => { await userEvent.click(confirmButton);
      // Note: This would use a separate password reset API method if available
      // For now, we'll test that the action was triggered
      await act(async () => { await waitFor(() => {
        expect(screen.queryByText('Reset Password')).not.toBeInTheDocument();
      });
    }); });
  });

describe('Add New User', () => {
    it('should open add user dialog when add button is clicked', async () => {
      renderComponent();
      const addButton = screen.getByRole('button', { name: /add user/i });
      await act(async () => { await userEvent.click(addButton);
      expect(screen.getByText('Add New User')).toBeInTheDocument();
      expect(screen.getByLabelText('Email')).toBeInTheDocument();
      expect(screen.getByLabelText('Name')).toBeInTheDocument();
      expect(screen.getByLabelText('Role')).toBeInTheDocument();
    });
    it('should create new user when form is submitted', async () => {
      mockCreateUser.mockResolvedValueOnce({
        success: true,
        data: {
          id: '4',
          email: 'new@example.com',
          name: 'New User',
          first_name: 'New',
          last_name: 'User',
          full_name: 'New User',
          is_active: true,
          is_verified: false,
          email_verified: false,
          is_superuser: false,
          two_factor_enabled: false,
          failed_login_attempts: 0,
          last_login: null,
          user_metadata: {},
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
          roles: [],
        },
      });
      renderComponent();
      const addButton = screen.getByRole('button', { name: /add user/i });
      await act(async () => { await userEvent.click(addButton);
      await act(async () => { await userEvent.type(screen.getByLabelText('Email'), 'new@example.com');
      await act(async () => { await userEvent.type(screen.getByLabelText('Name'), 'New User');
      const roleSelect = screen.getByLabelText('Role');
      await act(async () => { await userEvent.click(roleSelect);
      await act(async () => { await userEvent.click(screen.getByText('User'));
      const createButton = screen.getByRole('button', { name: /create user/i });
      await act(async () => { await userEvent.click(createButton);
      await act(async () => { await waitFor(() => {
        expect(mockCreateUser).toHaveBeenCalledWith(expect.objectContaining({
          email: 'new@example.com',
          first_name: 'New',
          last_name: 'User',
      });
    }); });
    it('should show validation errors for invalid input', async () => {
      renderComponent();
      const addButton = screen.getByRole('button', { name: /add user/i });
      await act(async () => { await userEvent.click(addButton);
      const createButton = screen.getByRole('button', { name: /create user/i });
      await act(async () => { await userEvent.click(createButton);
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText(/email is required/i)).toBeInTheDocument();
        expect(screen.getByText(/name is required/i)).toBeInTheDocument();
      }); });
    });
  });

describe('Bulk Actions', () => {
    it('should select multiple users', async () => {
      renderComponent();
      await act(async () => { await act(async () => { await waitFor(() => {
        const checkboxes = screen.getAllByRole('checkbox');
        if (checkboxes[1]) act(() => { fireEvent.click(checkboxes[1]) }); // Select first user
        if (checkboxes[2]) act(() => { fireEvent.click(checkboxes[2]) }); // Select second user
      }); });
      expect(screen.getByText('2 users selected')).toBeInTheDocument();
    });
    it('should show bulk action options when users are selected', async () => {
      renderComponent();
      await act(async () => { await act(async () => { await waitFor(() => {
        const checkboxes = screen.getAllByRole('checkbox');
        if (checkboxes[1]) act(() => { fireEvent.click(checkboxes[1]) });
      }); });
      expect(screen.getByRole('button', { name: /bulk actions/i })).toBeInTheDocument();
    });
    it('should perform bulk delete', async () => {
      renderComponent();
      await act(async () => { await waitFor(() => {
        const checkboxes = screen.getAllByRole('checkbox');
        if (checkboxes[1]) act(() => { fireEvent.click(checkboxes[1]) });
        if (checkboxes[2]) act(() => { fireEvent.click(checkboxes[2]) });
      });
      const bulkActionsButton = screen.getByRole('button', { name: /bulk actions/i });
      await act(async () => { await userEvent.click(bulkActionsButton);
      const deleteOption = screen.getByText('Delete Selected');
      await act(async () => { await userEvent.click(deleteOption);
      const confirmButton = screen.getByRole('button', { name: /confirm delete/i });
      await act(async () => { await userEvent.click(confirmButton);
      await act(async () => { await waitFor(() => {
        expect(mockBulkUserOperation).toHaveBeenCalledWith({
          user_ids: ['1', '2'],
          operation: 'delete',
        });
      });
    }); });
  });

describe('Export', () => {
    it('should export users to CSV', async () => {
      // Mock window.open
      const mockOpen = jest.fn();
      Object.defineProperty(window, 'open', {
        value: mockOpen,
        writable: true,
      });
      renderComponent();
      const exportButton = screen.getByRole('button', { name: /export/i });
      await act(async () => { await userEvent.click(exportButton);
      const csvOption = screen.getByText('Export as CSV');
      await act(async () => { await userEvent.click(csvOption);
      await act(async () => { await waitFor(() => {
        expect(mockGenerateUserReport).toHaveBeenCalledWith('csv', expect.any(Object));
        expect(mockOpen).toHaveBeenCalledWith('http://example.com/report.csv', '_blank');
      });
    }); });
  });

describe('Pagination', () => {
    it('should display pagination controls', async () => {
      renderComponent();
      await act(async () => { await waitFor(() => {
        expect(screen.getByRole('button', { name: /previous/i })).toBeInTheDocument();
        expect(screen.getByRole('button', { name: /next/i })).toBeInTheDocument();
        expect(screen.getByText(/page 1 of/i)).toBeInTheDocument();
      });
    }); });
    it('should navigate to next page', async () => {
      mockGetUsers.mockResolvedValue({
        success: true,
        data: {
          items: mockUsers,
          total: 20,
          pages: 2,
          page: 1,
          per_page: 10,
          has_next: true,
          has_prev: false,
        },
      });
      renderComponent();
      await act(async () => { await waitFor(() => {
        const nextButton = screen.getByRole('button', { name: /next/i });
        if (nextButton) act(() => { fireEvent.click(nextButton) });
      });
      await act(async () => { await waitFor(() => {
        expect(mockGetUsers).toHaveBeenCalledWith(
          expect.any(Object),
          2, // page
          10 // pageSize
        );
      });
    }); });
  });

describe('Error Handling', () => {
    it('should display error message when API fails', async () => {
      mockGetUsers.mockRejectedValueOnce(new Error('Failed to fetch users'));
      renderComponent();
      await act(async () => { await waitFor(() => {
        expect(screen.getByText(/failed to fetch users/i)).toBeInTheDocument();
      });
    }); });
    it('should show retry button on error', async () => {
      mockGetUsers.mockRejectedValueOnce(new Error('Network error'));
      renderComponent();
      await act(async () => { await waitFor(() => {
        expect(screen.getByRole('button', { name: /retry/i })).toBeInTheDocument();
      });
    }); });
  });

describe('Loading States', () => {
    it('should show loading skeleton while fetching data', async () => {
      renderComponent();
      expect(screen.getByTestId('user-management-skeleton')).toBeInTheDocument();
    });
  });

describe('Permissions', () => {
    it('should hide edit buttons when user lacks edit permission', async () => {
      mockAuthStore.hasPermission.mockReturnValue(false);
      renderComponent();
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.queryAllByTestId('edit-icon')).toHaveLength(0);
      }); });
    });
    it('should hide delete buttons when user lacks delete permission', async () => {
      mockAuthStore.hasPermission.mockImplementation((permission: string) =>
        permission !== 'users.delete'
      );
      renderComponent();
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.queryAllByTestId('trash-icon')).toHaveLength(0);
      }); });
    });
  });
});