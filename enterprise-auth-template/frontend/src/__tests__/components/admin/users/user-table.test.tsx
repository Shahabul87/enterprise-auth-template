/**
 * @jest-environment jsdom
 */
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import UserTable from '@/components/admin/users/user-table';
import { useAuth } from '@/contexts/auth-context';
import { useDebounce } from '@/hooks/use-debounce';
import AdminAPI from '@/lib/admin-api';
import { formatDate } from '@/lib/utils';

// Type definitions for UI components
interface DropdownMenuProps {
  children: React.ReactNode;
}

interface DropdownMenuContentProps {
  children: React.ReactNode;
  align?: string;
}

interface DropdownMenuItemProps {
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
  className?: string;
}

interface DropdownMenuLabelProps {
  children: React.ReactNode;
}

interface SelectProps {
  value?: string;
  onValueChange?: (value: string) => void;
  children?: React.ReactNode;
}

interface SelectContentProps {
  children: React.ReactNode;
}

interface SelectItemProps {
  children: React.ReactNode;
  value: string;
}

interface SelectTriggerProps {
  children: React.ReactNode;
  className?: string;
}

interface SelectValueProps {
  placeholder?: string;
}

interface CardProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface CardContentProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface CardDescriptionProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface CardHeaderProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface CardTitleProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface AlertProps {
  children: React.ReactNode;
  variant?: string;
  className?: string;
  [key: string]: unknown;
}

interface AlertDescriptionProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

// Mock dependencies
jest.mock('@/contexts/auth-context', () => ({
  useAuth: jest.fn(),
}));

jest.mock('@/hooks/use-debounce', () => ({
  useDebounce: jest.fn(),
}));

jest.mock('@/lib/admin-api', () => ({
  default: {
    getUsers: jest.fn(),
    bulkUserOperation: jest.fn(),
    activateUser: jest.fn(),
    deactivateUser: jest.fn(),
    verifyUser: jest.fn(),
    unverifyUser: jest.fn(),
    generateUserReport: jest.fn(),
  },
}));

jest.mock('@/lib/utils', () => ({
  formatDate: jest.fn(),
}));

// Mock dialog components
jest.mock('@/components/admin/users/user-create-dialog', () => {
  return function MockUserCreateDialog({ open, onClose, onSuccess }: { open: boolean; onClose: () => void; onSuccess: () => void }) {
    return open ? (
      <div data-testid='user-create-dialog'>
        <button onClick={onClose}>Close Create</button>
        <button onClick={onSuccess}>Success Create</button>
      </div>
    ) : null;
  };
});

jest.mock('@/components/admin/users/user-edit-dialog', () => {
  return function MockUserEditDialog({ user, open, onClose, onSuccess }: { user?: { id: string }; open: boolean; onClose: () => void; onSuccess: () => void }) {
    return open ? (
      <div data-testid='user-edit-dialog'>
        <span data-testid='editing-user'>{user?.id}</span>
        <button onClick={onClose}>Close Edit</button>
        <button onClick={onSuccess}>Success Edit</button>
      </div>
    ) : null;
  };
});

jest.mock('@/components/admin/users/user-delete-dialog', () => {
  return function MockUserDeleteDialog({ user, open, onClose, onSuccess }: { user?: { id: string }; open: boolean; onClose: () => void; onSuccess: () => void }) {
    return open ? (
      <div data-testid='user-delete-dialog'>
        <span data-testid='deleting-user'>{user?.id}</span>
        <button onClick={onClose}>Close Delete</button>
        <button onClick={onSuccess}>Success Delete</button>
      </div>
    ) : null;
  };
});

jest.mock('@/components/admin/users/user-role-dialog', () => {
  return function MockUserRoleDialog({ user, open, onClose, onSuccess }: { user?: { id: string }; open: boolean; onClose: () => void; onSuccess: () => void }) {
    return open ? (
      <div data-testid='user-role-dialog'>
        <span data-testid='role-user'>{user?.id}</span>
        <button onClick={onClose}>Close Role</button>
        <button onClick={onSuccess}>Success Role</button>
      </div>
    ) : null;
  };
});

// Mock UI components
jest.mock('@/components/ui/table', () => ({
  Table: ({ children, ...props }: React.PropsWithChildren<{ [key: string]: unknown }>) => <table {...props}>{children}</table>,
  TableBody: ({ children, ...props }: React.PropsWithChildren<{ [key: string]: unknown }>) => <tbody {...props}>{children}</tbody>,
  TableCell: ({ children, className, colSpan, ...props }: React.PropsWithChildren<{ className?: string; colSpan?: number; [key: string]: unknown }>) => (
    <td className={className} colSpan={colSpan} {...props}>
      {children}
    </td>
  ),
  TableHead: ({ children, className, ...props }: React.PropsWithChildren<{ className?: string; [key: string]: unknown }>) => (
    <th className={className} {...props}>
      {children}
    </th>
  ),
  TableHeader: ({ children, ...props }: React.PropsWithChildren<{ [key: string]: unknown }>) => <thead {...props}>{children}</thead>,
  TableRow: ({ children, ...props }: React.PropsWithChildren<{ [key: string]: unknown }>) => <tr {...props}>{children}</tr>,
}));

jest.mock('@/components/ui/button', () => ({
  Button: ({ children, onClick, disabled, variant, size, className, ...props }: React.PropsWithChildren<{ onClick?: () => void; disabled?: boolean; variant?: string; size?: string; className?: string; [key: string]: unknown }>) => (
    <button
      onClick={onClick}
      disabled={disabled}
      className={className}
      data-variant={variant}
      data-size={size}
      {...props}
    >
      {children}
    </button>
  ),
}));

jest.mock('@/components/ui/input', () => ({
  Input: ({ placeholder, value, onChange, className, ...props }: { placeholder?: string; value?: string; onChange?: React.ChangeEventHandler<HTMLInputElement>; className?: string; [key: string]: unknown }) => (
    <input
      placeholder={placeholder}
      value={value}
      onChange={onChange}
      className={className}
      {...props}
    />
  ),
}));

jest.mock('@/components/ui/badge', () => ({
  Badge: ({ children, variant, ...props }: React.PropsWithChildren<{ variant?: string; [key: string]: unknown }>) => (
    <span data-testid='badge' data-variant={variant} {...props}>
      {children}
    </span>
  ),
}));

jest.mock('@/components/ui/checkbox', () => ({
  Checkbox: ({ checked, onCheckedChange, disabled, ...props }: { checked?: boolean; onCheckedChange?: (checked: boolean) => void; disabled?: boolean; [key: string]: unknown }) => (
    <input
      type='checkbox'
      checked={checked}
      onChange={(e) => onCheckedChange && onCheckedChange(e.target.checked)}
      disabled={disabled}
      {...props}
    />
  ),
}));

jest.mock('@/components/ui/dropdown-menu', () => ({
  DropdownMenu: ({ children }: DropdownMenuProps) => <div data-testid='dropdown-menu'>{children}</div>,
  DropdownMenuContent: ({ children, align }: DropdownMenuContentProps) => (
    <div data-testid='dropdown-content' data-align={align}>
      {children}
    </div>
  ),
  DropdownMenuItem: ({ children, onClick, disabled, className }: DropdownMenuItemProps) => (
    <button onClick={onClick} disabled={disabled} className={className} data-testid='dropdown-item'>
      {children}
    </button>
  ),
  DropdownMenuLabel: ({ children }: DropdownMenuLabelProps) => <div data-testid='dropdown-label'>{children}</div>,
  DropdownMenuSeparator: () => <hr data-testid='dropdown-separator' />,
  DropdownMenuTrigger: ({ children }: React.PropsWithChildren<{ asChild?: boolean }>) => (
    <div data-testid='dropdown-trigger'>{children}</div>
  ),
}));

jest.mock('@/components/ui/select', () => ({
  Select: ({ children, value, onValueChange }: SelectProps) => (
    <div data-testid='select' data-value={value}>
      <input
        type='hidden'
        value={value}
        onChange={(e) => onValueChange && onValueChange(e.target.value)}
      />
      {children}
    </div>
  ),
  SelectContent: ({ children }: SelectContentProps) => <div data-testid='select-content'>{children}</div>,
  SelectItem: ({ children, value }: SelectItemProps) => (
    <option value={value} data-testid='select-item'>
      {children}
    </option>
  ),
  SelectTrigger: ({ children, className }: SelectTriggerProps) => (
    <div data-testid='select-trigger' className={className}>
      {children}
    </div>
  ),
  SelectValue: ({ placeholder }: SelectValueProps) => (
    <span data-testid='select-value' data-placeholder={placeholder} />
  ),
}));

jest.mock('@/components/ui/card', () => ({
  Card: ({ children, ...props }: CardProps) => (
    <div data-testid='card' {...props}>
      {children}
    </div>
  ),
  CardContent: ({ children, ...props }: CardContentProps) => (
    <div data-testid='card-content' {...props}>
      {children}
    </div>
  ),
  CardDescription: ({ children, ...props }: CardDescriptionProps) => (
    <div data-testid='card-description' {...props}>
      {children}
    </div>
  ),
  CardHeader: ({ children, ...props }: CardHeaderProps) => (
    <div data-testid='card-header' {...props}>
      {children}
    </div>
  ),
  CardTitle: ({ children, ...props }: CardTitleProps) => (
    <h2 data-testid='card-title' {...props}>
      {children}
    </h2>
  ),
}));

jest.mock('@/components/ui/alert', () => ({
  Alert: ({ children, variant, className, ...props }: AlertProps) => (
    <div data-testid='alert' data-variant={variant} className={className} {...props}>
      {children}
    </div>
  ),
  AlertDescription: ({ children, ...props }: AlertDescriptionProps) => (
    <div data-testid='alert-description' {...props}>
      {children}
    </div>
  ),
}));

jest.mock('lucide-react', () => ({
  Search: ({ className }: { className?: string }) => <div data-testid='search-icon' className={className} />,
  MoreHorizontal: ({ className }: { className?: string }) => (
    <div data-testid='more-horizontal-icon' className={className} />
  ),
  Edit: ({ className }: { className?: string }) => <div data-testid='edit-icon' className={className} />,
  Trash2: ({ className }: { className?: string }) => <div data-testid='trash-icon' className={className} />,
  Shield: ({ className }: { className?: string }) => <div data-testid='shield-icon' className={className} />,
  UserCheck: ({ className }: { className?: string }) => <div data-testid='user-check-icon' className={className} />,
  UserX: ({ className }: { className?: string }) => <div data-testid='user-x-icon' className={className} />,
  Download: ({ className }: { className?: string }) => <div data-testid='download-icon' className={className} />,
  Filter: ({ className }: { className?: string }) => <div data-testid='filter-icon' className={className} />,
  ChevronLeft: ({ className }: { className?: string }) => (
    <div data-testid='chevron-left-icon' className={className} />
  ),
  ChevronRight: ({ className }: { className?: string }) => (
    <div data-testid='chevron-right-icon' className={className} />
  ),
  AlertCircle: ({ className }: { className?: string }) => (
    <div data-testid='alert-circle-icon' className={className} />
  ),
  Plus: ({ className }: { className?: string }) => <div data-testid='plus-icon' className={className} />,
  RefreshCw: ({ className }: { className?: string }) => <div data-testid='refresh-icon' className={className} />,
}));

// Mock data
const mockUsers = [
  {
    id: '1',
    email: 'john.doe@example.com',
    full_name: 'John Doe',
    is_active: true,
    is_verified: true,
    email_verified: true,
    is_superuser: false,
    two_factor_enabled: false,
    failed_login_attempts: 0,
    last_login: '2024-01-15T10:30:00Z',
    user_metadata: {},
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
    roles: [
      {
        id: 'role1',
        name: 'User',
        description: 'Standard user role',
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        permissions: [],
      },
    ],
  },
  {
    id: '2',
    email: 'jane.smith@example.com',
    full_name: 'Jane Smith',
    is_active: false,
    is_verified: false,
    email_verified: false,
    is_superuser: true,
    two_factor_enabled: true,
    failed_login_attempts: 0,
    last_login: null,
    user_metadata: {},
    created_at: '2024-01-02T00:00:00Z',
    updated_at: '2024-01-02T00:00:00Z',
    roles: [
      {
        id: 'role2',
        name: 'Admin',
        description: 'Administrator role',
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        permissions: [],
      },
    ],
  },
];

const mockAuthContext = {
  user: {
    id: 'current-user',
    email: 'current@example.com',
    full_name: 'Current User',
    is_active: true,
    is_verified: true,
    email_verified: true,
    is_superuser: true,
    two_factor_enabled: false,
    failed_login_attempts: 0,
    last_login: new Date().toISOString(),
    user_metadata: {},
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    roles: [],
  },
  tokens: {
    access_token: 'mock-access-token',
    refresh_token: 'mock-refresh-token',
    token_type: 'Bearer',
    expires_in: 3600,
  },
  isAuthenticated: true,
  isLoading: false,
  permissions: ['users:read', 'users:create', 'users:update', 'users:delete'],
  hasPermission: jest.fn(),
  hasRole: jest.fn(),
  login: jest.fn(),
  register: jest.fn(),
  logout: jest.fn(),
  refreshToken: jest.fn(),
  updateUser: jest.fn(),
};

const mockAdminAPI = AdminAPI as jest.Mocked<typeof AdminAPI>;
const mockFormatDate = formatDate as jest.MockedFunction<typeof formatDate>;
const mockUseAuth = useAuth as jest.MockedFunction<typeof useAuth>;
const mockUseDebounce = useDebounce as jest.MockedFunction<typeof useDebounce>;

describe('UserTable', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Setup default mocks
    mockUseAuth.mockReturnValue(mockAuthContext);
    mockUseDebounce.mockImplementation((value) => value);
    mockFormatDate.mockImplementation((date, format) => `formatted-${date}-${format}`);

    // Default API responses
    mockAdminAPI.getUsers.mockResolvedValue({
      success: true,
      data: {
        items: mockUsers,
        total: 2,
        pages: 1,
        page: 1,
        per_page: 10,
        has_next: false,
        has_prev: false,
      },
    });

    // Default permissions
    mockAuthContext.hasPermission.mockImplementation((permission: string) => {
      const allowedPermissions = [
        'users:read',
        'users:create',
        'users:update',
        'users:delete',
        'roles:manage',
      ];
      return allowedPermissions.includes(permission);
    });
  });

  it('renders user table with data', async () => {
    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getByTestId('card-title')).toHaveTextContent('User Management');
      expect(screen.getByTestId('card-description')).toHaveTextContent(
        'Manage user accounts, roles, and permissions'
      );
    });

    // Check if users are displayed
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('jane.smith@example.com')).toBeInTheDocument();
    });
  });

  it('handles loading state', () => {
    mockAdminAPI.getUsers.mockImplementation(() => new Promise(() => {})); // Never resolves

    render(<UserTable />);

    expect(screen.getByTestId('refresh-icon')).toBeInTheDocument();
  });

  it('handles error state', async () => {
    mockAdminAPI.getUsers.mockRejectedValue(new Error('API Error'));

    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getByTestId('alert')).toBeInTheDocument();
      expect(screen.getByText('API Error')).toBeInTheDocument();
    });
  });

  it('shows permission denied when user lacks users:read permission', () => {
    mockAuthContext.hasPermission.mockReturnValue(false);

    render(<UserTable />);

    expect(screen.getByTestId('alert')).toBeInTheDocument();
    expect(screen.getByText("You don't have permission to view users.")).toBeInTheDocument();
  });

  it('renders search input and filters', async () => {
    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getByPlaceholderText('Search users...')).toBeInTheDocument();
      expect(screen.getAllByTestId('select')).toHaveLength(3); // Status, verification, page size
    });
  });

  it('handles search functionality', async () => {
    const user = userEvent.setup();
    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getByPlaceholderText('Search users...')).toBeInTheDocument();
    });

    const searchInput = screen.getByPlaceholderText('Search users...');
    await user.type(searchInput, 'john');

    // Debounce should be called
    expect(mockUseDebounce).toHaveBeenCalledWith('john', 300);
  });

  it('handles user selection', async () => {
    const user = userEvent.setup();
    render(<UserTable />);

    await waitFor(() => {
      const checkboxes = screen.getAllByRole('checkbox');
      expect(checkboxes.length).toBeGreaterThan(0);
    });

    const userCheckbox = screen.getAllByRole('checkbox')[1] as HTMLInputElement; // First user checkbox
    await user.click(userCheckbox);

    expect(userCheckbox).toBeChecked();
  });

  it('handles select all functionality', async () => {
    const user = userEvent.setup();
    render(<UserTable />);

    await waitFor(() => {
      const checkboxes = screen.getAllByRole('checkbox');
      expect(checkboxes.length).toBeGreaterThan(0);
    });

    const selectAllCheckbox = screen.getAllByRole('checkbox')[0] as HTMLInputElement;
    await user.click(selectAllCheckbox);

    // All user checkboxes should be checked
    const checkboxes = screen.getAllByRole('checkbox');
    checkboxes.slice(1).forEach((checkbox) => {
      expect(checkbox).toBeChecked();
    });
  });

  it('shows bulk actions when users are selected', async () => {
    const user = userEvent.setup();
    render(<UserTable />);

    await waitFor(() => {
      const checkboxes = screen.getAllByRole('checkbox');
      expect(checkboxes.length).toBeGreaterThan(0);
    });

    const userCheckbox = screen.getAllByRole('checkbox')[1] as HTMLInputElement;
    await user.click(userCheckbox);

    await waitFor(() => {
      expect(screen.getByText('1 user(s) selected')).toBeInTheDocument();
      expect(screen.getByText('Activate')).toBeInTheDocument();
      expect(screen.getByText('Deactivate')).toBeInTheDocument();
      expect(screen.getByText('Verify')).toBeInTheDocument();
      expect(screen.getByText('Delete')).toBeInTheDocument();
    });
  });

  it('handles bulk operations', async () => {
    const user = userEvent.setup();
    mockAdminAPI.bulkUserOperation.mockResolvedValue({ success: true });

    render(<UserTable />);

    await waitFor(() => {
      const checkboxes = screen.getAllByRole('checkbox');
      expect(checkboxes.length).toBeGreaterThan(0);
    });

    const userCheckbox = screen.getAllByRole('checkbox')[1] as HTMLInputElement;
    await user.click(userCheckbox);

    await waitFor(() => {
      expect(screen.getByText('Activate')).toBeInTheDocument();
    });

    const activateButton = screen.getByText('Activate') as HTMLButtonElement;
    await user.click(activateButton);

    expect(mockAdminAPI.bulkUserOperation).toHaveBeenCalledWith({
      user_ids: ['1'],
      operation: 'activate',
    });
  });

  it('opens create dialog when Add User button is clicked', async () => {
    const user = userEvent.setup();
    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getByText('Add User')).toBeInTheDocument();
    });

    const addUserButton = screen.getByText('Add User');
    await user.click(addUserButton);

    expect(screen.getByTestId('user-create-dialog')).toBeInTheDocument();
  });

  it('opens edit dialog when Edit is clicked from dropdown', async () => {
    const user = userEvent.setup();
    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getAllByTestId('dropdown-trigger')).toHaveLength(2);
    });

    // Find and click edit in dropdown items
    const editButtons = screen.getAllByText('Edit Details');
    expect(editButtons.length).toBeGreaterThan(0);

    await user.click(editButtons[0] as HTMLElement);

    expect(screen.getByTestId('user-edit-dialog')).toBeInTheDocument();
    expect(screen.getByTestId('editing-user')).toHaveTextContent('1');
  });

  it('opens delete dialog when Delete is clicked from dropdown', async () => {
    const user = userEvent.setup();
    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getAllByTestId('dropdown-trigger')).toHaveLength(2);
    });

    const deleteButtons = screen.getAllByText('Delete User');
    expect(deleteButtons.length).toBeGreaterThan(0);

    await user.click(deleteButtons[0] as HTMLElement);

    expect(screen.getByTestId('user-delete-dialog')).toBeInTheDocument();
    expect(screen.getByTestId('deleting-user')).toHaveTextContent('1');
  });

  it('opens role management dialog when Manage Roles is clicked', async () => {
    const user = userEvent.setup();
    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getAllByTestId('dropdown-trigger')).toHaveLength(2);
    });

    const roleButtons = screen.getAllByText('Manage Roles');
    expect(roleButtons.length).toBeGreaterThan(0);

    await user.click(roleButtons[0] as HTMLElement);

    expect(screen.getByTestId('user-role-dialog')).toBeInTheDocument();
    expect(screen.getByTestId('role-user')).toHaveTextContent('1');
  });

  it('handles user activation toggle', async () => {
    const user = userEvent.setup();
    mockAdminAPI.deactivateUser.mockResolvedValue({ success: true });

    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getAllByTestId('dropdown-trigger')).toHaveLength(2);
    });

    const deactivateButtons = screen.getAllByText('Deactivate');
    expect(deactivateButtons.length).toBeGreaterThan(0);

    await user.click(deactivateButtons[0] as HTMLElement);

    expect(mockAdminAPI.deactivateUser).toHaveBeenCalledWith('1');
  });

  it('handles user verification toggle', async () => {
    const user = userEvent.setup();
    mockAdminAPI.unverifyUser.mockResolvedValue({ success: true });

    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getAllByTestId('dropdown-trigger')).toHaveLength(2);
    });

    const unverifyButtons = screen.getAllByText('Unverify');
    expect(unverifyButtons.length).toBeGreaterThan(0);

    await user.click(unverifyButtons[0] as HTMLElement);

    expect(mockAdminAPI.unverifyUser).toHaveBeenCalledWith('1');
  });

  it('handles export functionality', async () => {
    const user = userEvent.setup();
    mockAdminAPI.generateUserReport.mockResolvedValue({
      success: true,
      data: { download_url: 'http://example.com/report.csv' },
    });

    // Mock window.open
    const mockOpen = jest.fn();
    Object.defineProperty(window, 'open', {
      value: mockOpen,
      writable: true,
    });

    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getByText('Export')).toBeInTheDocument();
    });

    const exportButton = screen.getByText('Export');
    await user.click(exportButton);

    await waitFor(() => {
      expect(screen.getByText('Export as CSV')).toBeInTheDocument();
    });

    const csvExportButton = screen.getByText('Export as CSV');
    await user.click(csvExportButton);

    expect(mockAdminAPI.generateUserReport).toHaveBeenCalledWith('csv', expect.any(Object));
    expect(mockOpen).toHaveBeenCalledWith('http://example.com/report.csv', '_blank');
  });

  it('handles refresh functionality', async () => {
    const user = userEvent.setup();
    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getByText('Refresh')).toBeInTheDocument();
    });

    // Clear the initial call
    mockAdminAPI.getUsers.mockClear();

    const refreshButton = screen.getByText('Refresh');
    await user.click(refreshButton);

    expect(mockAdminAPI.getUsers).toHaveBeenCalled();
  });

  it('displays user information correctly', async () => {
    render(<UserTable />);

    await waitFor(() => {
      // Check user names
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('Jane Smith')).toBeInTheDocument();

      // Check emails
      expect(screen.getByText('john.doe@example.com')).toBeInTheDocument();
      expect(screen.getByText('jane.smith@example.com')).toBeInTheDocument();

      // Check roles
      expect(screen.getByText('User')).toBeInTheDocument();
      expect(screen.getByText('Admin')).toBeInTheDocument();

      // Check super admin badge
      expect(screen.getByText('Super Admin')).toBeInTheDocument();

      // Check status badges
      expect(screen.getByText('Active')).toBeInTheDocument();
      expect(screen.getByText('Inactive')).toBeInTheDocument();
      expect(screen.getByText('Verified')).toBeInTheDocument();
    });
  });

  it('disables actions for current user', async () => {
    mockAuthContext.user = {
      id: '1',
      email: 'john.doe@example.com',
      full_name: 'John Doe',
      is_active: true,
      is_verified: true,
      email_verified: true,
      is_superuser: false,
      two_factor_enabled: false,
      failed_login_attempts: 0,
      last_login: new Date().toISOString(),
      user_metadata: {},
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      roles: [],
    };

    render(<UserTable />);

    await waitFor(() => {
      const checkboxes = screen.getAllByRole('checkbox');
      expect(checkboxes.length).toBeGreaterThan(0);
    });

    // Current user's checkbox should be disabled
    const currentUserCheckbox = screen.getAllByRole('checkbox')[1];
    expect(currentUserCheckbox).toBeDisabled();
  });

  it('handles pagination', async () => {
    const user = userEvent.setup();
    mockAdminAPI.getUsers.mockResolvedValue({
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

    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getByText('Page 1 of 2')).toBeInTheDocument();
    });

    const nextButton = screen.getByText('Next');
    await user.click(nextButton);

    expect(mockAdminAPI.getUsers).toHaveBeenCalledWith(
      expect.any(Object),
      2, // page
      10 // pageSize
    );
  });

  it('handles empty state', async () => {
    mockAdminAPI.getUsers.mockResolvedValue({
      success: true,
      data: {
        items: [],
        total: 0,
        pages: 0,
        page: 1,
        per_page: 10,
        has_next: false,
        has_prev: false,
      },
    });

    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getByText('No users found')).toBeInTheDocument();
    });
  });

  it('handles API error in bulk operations', async () => {
    const user = userEvent.setup();
    mockAdminAPI.bulkUserOperation.mockRejectedValue(new Error('Bulk operation failed'));

    render(<UserTable />);

    await waitFor(() => {
      const checkboxes = screen.getAllByRole('checkbox');
      expect(checkboxes.length).toBeGreaterThan(0);
    });

    const userCheckbox = screen.getAllByRole('checkbox')[1] as HTMLInputElement;
    await user.click(userCheckbox);

    await waitFor(() => {
      expect(screen.getByText('Activate')).toBeInTheDocument();
    });

    const activateButton = screen.getByText('Activate') as HTMLButtonElement;
    await user.click(activateButton);

    await waitFor(() => {
      expect(screen.getByText('Bulk operation failed')).toBeInTheDocument();
    });
  });

  it('handles dialog success callbacks', async () => {
    const user = userEvent.setup();
    render(<UserTable />);

    await waitFor(() => {
      expect(screen.getByText('Add User')).toBeInTheDocument();
    });

    const addUserButton = screen.getByText('Add User');
    await user.click(addUserButton);

    expect(screen.getByTestId('user-create-dialog')).toBeInTheDocument();

    // Clear the initial API call
    mockAdminAPI.getUsers.mockClear();

    const successButton = screen.getByText('Success Create');
    await user.click(successButton);

    // Dialog should close and users should reload
    expect(screen.queryByTestId('user-create-dialog')).not.toBeInTheDocument();
    expect(mockAdminAPI.getUsers).toHaveBeenCalled();
  });
});
