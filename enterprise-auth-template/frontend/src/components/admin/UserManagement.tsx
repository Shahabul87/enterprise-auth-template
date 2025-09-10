'use client';

import React, { useState, useEffect, useMemo } from 'react';
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Skeleton } from '@/components/ui/skeleton';
import { Checkbox } from '@/components/ui/checkbox';
import { Switch } from '@/components/ui/switch';
import { Textarea } from '@/components/ui/textarea';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import {
  Plus,
  Search,
  Download,
  Upload,
  MoreVertical,
  Shield,
  Ban,
  Mail,
  CheckCircle,
  XCircle,
  Trash2,
  Edit,
  Eye,
  Key,
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
  ArrowUp,
  ArrowDown,
  Info,
} from 'lucide-react';
import { formatDistanceToNow, format } from 'date-fns';
import { useToast } from '@/components/ui/use-toast';
import { useAdminStore, UserManagement as User } from '@/stores/adminStore';


interface BulkAction {
  action: 'activate' | 'deactivate' | 'suspend' | 'lock' | 'reset_password' | 'verify_email';
  userIds: string[];
  reason?: string;
}

interface UserFilter {
  search: string;
  status: string;
  role: string;
  verified: string;
  dateRange: { from: Date | null; to: Date | null };
  sortBy: 'name' | 'email' | 'created' | 'lastLogin';
  sortOrder: 'asc' | 'desc';
}

export default function UserManagement() {
  const {
    users,
    totalUsers,
    currentPage,
    pageSize,
    isLoading,
    // error,
    fetchUsers,
    updateUserStatus,
    deleteUser,
    bulkUpdateUserStatus,
    exportUsers,
    importUsers,
  } = useAdminStore();

  const [selectedUsers, setSelectedUsers] = useState<Set<string>>(new Set());
  const [showUserDialog, setShowUserDialog] = useState(false);
  const [showBulkDialog, setShowBulkDialog] = useState(false);
  const [showImportDialog, setShowImportDialog] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [bulkAction, setBulkAction] = useState<BulkAction['action'] | ''>('');
  const [bulkReason, setBulkReason] = useState('');
  const { toast } = useToast();

  const [filter, setFilter] = useState<UserFilter>({
    search: '',
    status: 'all',
    role: 'all',
    verified: 'all',
    dateRange: { from: null, to: null },
    sortBy: 'created',
    sortOrder: 'desc',
  });

  // Form state for creating/editing user
  const [formData, setFormData] = useState({
    email: '',
    name: '',
    password: '',
    roles: [] as string[],
    sendWelcomeEmail: true,
    requirePasswordChange: false,
  });

  useEffect(() => {
    fetchUsers(currentPage);
  }, [currentPage, fetchUsers]);

  const filteredUsers = useMemo(() => {
    let filtered = [...users];

    // Search filter
    if (filter.search) {
      const searchLower = filter.search.toLowerCase();
      filtered = filtered.filter(
        (user) =>
          user.name.toLowerCase().includes(searchLower) ||
          user.email.toLowerCase().includes(searchLower)
      );
    }

    // Status filter
    if (filter.status !== 'all') {
      filtered = filtered.filter((user) => user.status === filter.status);
    }

    // Role filter
    if (filter.role !== 'all') {
      filtered = filtered.filter((user) => user.roles.includes(filter.role));
    }

    // Verification filter
    if (filter.verified === 'verified') {
      filtered = filtered.filter((user) => user.emailVerified);
    } else if (filter.verified === 'unverified') {
      filtered = filtered.filter((user) => !user.emailVerified);
    }

    // Date range filter
    if (filter.dateRange.from) {
      filtered = filtered.filter(
        (user) => new Date(user.createdAt) >= filter.dateRange.from!
      );
    }
    if (filter.dateRange.to) {
      filtered = filtered.filter(
        (user) => new Date(user.createdAt) <= filter.dateRange.to!
      );
    }

    // Sorting
    filtered.sort((a, b) => {
      let aValue: string | number = '';
      let bValue: string | number = '';

      switch (filter.sortBy) {
        case 'name':
          aValue = a.name;
          bValue = b.name;
          break;
        case 'email':
          aValue = a.email;
          bValue = b.email;
          break;
        case 'created':
          aValue = new Date(a.createdAt).getTime();
          bValue = new Date(b.createdAt).getTime();
          break;
        case 'lastLogin':
          aValue = a.lastLogin ? new Date(a.lastLogin).getTime() : 0;
          bValue = b.lastLogin ? new Date(b.lastLogin).getTime() : 0;
          break;
      }

      if (filter.sortOrder === 'asc') {
        return aValue > bValue ? 1 : -1;
      } else {
        return aValue < bValue ? 1 : -1;
      }
    });

    return filtered;
  }, [users, filter]);

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedUsers(new Set(filteredUsers.map((u) => u.id)));
    } else {
      setSelectedUsers(new Set());
    }
  };

  const handleSelectUser = (userId: string, checked: boolean) => {
    const newSelected = new Set(selectedUsers);
    if (checked) {
      newSelected.add(userId);
    } else {
      newSelected.delete(userId);
    }
    setSelectedUsers(newSelected);
  };

  const handleBulkAction = async () => {
    if (!bulkAction || selectedUsers.size === 0) return;

    try {
      await bulkUpdateUserStatus(Array.from(selectedUsers), bulkAction as User['status']);
      toast({
        title: 'Success',
        description: `Bulk action completed for ${selectedUsers.size} users`,
      });
      setShowBulkDialog(false);
      setSelectedUsers(new Set());
      setBulkAction('');
      setBulkReason('');
      await fetchUsers(currentPage);
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to perform bulk action',
        variant: 'destructive',
      });
    }
  };

  const handleExportUsers = async () => {
    try {
      const blob = await exportUsers('csv');
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `users_export_${format(new Date(), 'yyyy-MM-dd')}.csv`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      
      toast({
        title: 'Success',
        description: 'Users exported successfully',
      });
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to export users',
        variant: 'destructive',
      });
    }
  };

  const handleImportUsers = async (file: File) => {
    try {
      await importUsers(file);
      toast({
        title: 'Success',
        description: 'Users imported successfully',
      });
      setShowImportDialog(false);
      await fetchUsers(currentPage);
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to import users',
        variant: 'destructive',
      });
    }
  };

  const handleResetPassword = async (userId: string) => {
    try {
      const response = await fetch(`/api/v1/admin/users/${userId}/reset-password`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        toast({
          title: 'Success',
          description: 'Password reset email sent',
        });
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to reset password',
        variant: 'destructive',
      });
    }
  };

  const handleImpersonateUser = async (userId: string) => {
    try {
      const response = await fetch(`/api/v1/admin/users/${userId}/impersonate`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        // Store impersonation token and redirect
        localStorage.setItem('impersonation_token', data.token);
        window.location.href = '/dashboard';
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to impersonate user',
        variant: 'destructive',
      });
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'active':
        return (
          <Badge variant="success" className="text-xs">
            <CheckCircle className="mr-1 h-3 w-3" />
            Active
          </Badge>
        );
      case 'inactive':
        return (
          <Badge variant="secondary" className="text-xs">
            <XCircle className="mr-1 h-3 w-3" />
            Inactive
          </Badge>
        );
      case 'suspended':
        return (
          <Badge variant="destructive" className="text-xs">
            <Ban className="mr-1 h-3 w-3" />
            Suspended
          </Badge>
        );
      case 'deleted':
        return (
          <Badge variant="outline" className="text-xs">
            <Trash2 className="mr-1 h-3 w-3" />
            Deleted
          </Badge>
        );
      default:
        return null;
    }
  };

  const totalPages = Math.ceil(totalUsers / pageSize);

  if (isLoading && users.length === 0) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-12 w-full" />
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">User Management</h2>
          <p className="text-muted-foreground">
            Manage users, roles, and permissions
          </p>
        </div>
        <div className="flex space-x-2">
          <Button variant="outline" size="sm" onClick={handleExportUsers}>
            <Download className="mr-2 h-4 w-4" />
            Export
          </Button>
          <Dialog open={showImportDialog} onOpenChange={setShowImportDialog}>
            <DialogTrigger asChild>
              <Button variant="outline" size="sm">
                <Upload className="mr-2 h-4 w-4" />
                Import
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Import Users</DialogTitle>
                <DialogDescription>
                  Upload a CSV file to import users in bulk
                </DialogDescription>
              </DialogHeader>
              <div className="grid gap-4 py-4">
                <div className="grid gap-2">
                  <Label htmlFor="import-file">CSV File</Label>
                  <Input
                    id="import-file"
                    type="file"
                    accept=".csv"
                    onChange={(e) => {
                      const file = e.target.files?.[0];
                      if (file) {
                        handleImportUsers(file);
                      }
                    }}
                  />
                </div>
                <Alert>
                  <Info className="h-4 w-4" />
                  <AlertTitle>CSV Format</AlertTitle>
                  <AlertDescription>
                    The CSV should have columns: email, name, role
                  </AlertDescription>
                </Alert>
              </div>
            </DialogContent>
          </Dialog>
          <Button size="sm" onClick={() => setShowUserDialog(true)}>
            <Plus className="mr-2 h-4 w-4" />
            Add User
          </Button>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Filters</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-4">
            <div className="flex items-center space-x-2">
              <Search className="h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search users..."
                value={filter.search}
                onChange={(e) => setFilter({ ...filter, search: e.target.value })}
              />
            </div>
            <Select
              value={filter.status}
              onValueChange={(value) => setFilter({ ...filter, status: value })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Status</SelectItem>
                <SelectItem value="active">Active</SelectItem>
                <SelectItem value="inactive">Inactive</SelectItem>
                <SelectItem value="suspended">Suspended</SelectItem>
                <SelectItem value="deleted">Deleted</SelectItem>
              </SelectContent>
            </Select>
            <Select
              value={filter.role}
              onValueChange={(value) => setFilter({ ...filter, role: value })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Role" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Roles</SelectItem>
                <SelectItem value="admin">Admin</SelectItem>
                <SelectItem value="user">User</SelectItem>
                <SelectItem value="moderator">Moderator</SelectItem>
              </SelectContent>
            </Select>
            <Select
              value={filter.verified}
              onValueChange={(value) => setFilter({ ...filter, verified: value })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Verification" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Users</SelectItem>
                <SelectItem value="verified">Verified</SelectItem>
                <SelectItem value="unverified">Unverified</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Bulk Actions */}
      {selectedUsers.size > 0 && (
        <Alert>
          <AlertDescription className="flex items-center justify-between">
            <span>{selectedUsers.size} users selected</span>
            <div className="flex space-x-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setSelectedUsers(new Set())}
              >
                Clear Selection
              </Button>
              <Dialog open={showBulkDialog} onOpenChange={setShowBulkDialog}>
                <DialogTrigger asChild>
                  <Button size="sm">Bulk Actions</Button>
                </DialogTrigger>
                <DialogContent>
                  <DialogHeader>
                    <DialogTitle>Bulk Actions</DialogTitle>
                    <DialogDescription>
                      Apply action to {selectedUsers.size} selected users
                    </DialogDescription>
                  </DialogHeader>
                  <div className="grid gap-4 py-4">
                    <div className="grid gap-2">
                      <Label>Action</Label>
                      <Select
                        value={bulkAction}
                        onValueChange={(value) => setBulkAction(value as BulkAction['action'])}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select action" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="activate">Activate</SelectItem>
                          <SelectItem value="deactivate">Deactivate</SelectItem>
                          <SelectItem value="suspend">Suspend</SelectItem>
                          <SelectItem value="delete">Delete</SelectItem>
                          <SelectItem value="reset_password">Reset Password</SelectItem>
                          <SelectItem value="verify_email">Verify Email</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="grid gap-2">
                      <Label>Reason (optional)</Label>
                      <Textarea
                        value={bulkReason}
                        onChange={(e) => setBulkReason(e.target.value)}
                        placeholder="Provide a reason for this action"
                      />
                    </div>
                  </div>
                  <DialogFooter>
                    <Button variant="outline" onClick={() => setShowBulkDialog(false)}>
                      Cancel
                    </Button>
                    <Button onClick={handleBulkAction} disabled={!bulkAction}>
                      Apply Action
                    </Button>
                  </DialogFooter>
                </DialogContent>
              </Dialog>
            </div>
          </AlertDescription>
        </Alert>
      )}

      {/* Users Table */}
      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-12">
                <Checkbox
                  checked={
                    filteredUsers.length > 0 &&
                    selectedUsers.size === filteredUsers.length
                  }
                  onCheckedChange={handleSelectAll}
                />
              </TableHead>
              <TableHead>
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-8 px-2"
                  onClick={() =>
                    setFilter({
                      ...filter,
                      sortBy: 'name',
                      sortOrder:
                        filter.sortBy === 'name' && filter.sortOrder === 'asc'
                          ? 'desc'
                          : 'asc',
                    })
                  }
                >
                  User
                  {filter.sortBy === 'name' &&
                    (filter.sortOrder === 'asc' ? (
                      <ArrowUp className="ml-2 h-4 w-4" />
                    ) : (
                      <ArrowDown className="ml-2 h-4 w-4" />
                    ))}
                </Button>
              </TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Roles</TableHead>
              <TableHead>Verification</TableHead>
              <TableHead>
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-8 px-2"
                  onClick={() =>
                    setFilter({
                      ...filter,
                      sortBy: 'lastLogin',
                      sortOrder:
                        filter.sortBy === 'lastLogin' && filter.sortOrder === 'asc'
                          ? 'desc'
                          : 'asc',
                    })
                  }
                >
                  Last Login
                  {filter.sortBy === 'lastLogin' &&
                    (filter.sortOrder === 'asc' ? (
                      <ArrowUp className="ml-2 h-4 w-4" />
                    ) : (
                      <ArrowDown className="ml-2 h-4 w-4" />
                    ))}
                </Button>
              </TableHead>
              <TableHead>
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-8 px-2"
                  onClick={() =>
                    setFilter({
                      ...filter,
                      sortBy: 'created',
                      sortOrder:
                        filter.sortBy === 'created' && filter.sortOrder === 'asc'
                          ? 'desc'
                          : 'asc',
                    })
                  }
                >
                  Created
                  {filter.sortBy === 'created' &&
                    (filter.sortOrder === 'asc' ? (
                      <ArrowUp className="ml-2 h-4 w-4" />
                    ) : (
                      <ArrowDown className="ml-2 h-4 w-4" />
                    ))}
                </Button>
              </TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredUsers.map((user) => (
              <TableRow key={user.id}>
                <TableCell>
                  <Checkbox
                    checked={selectedUsers.has(user.id)}
                    onCheckedChange={(checked) =>
                      handleSelectUser(user.id, checked as boolean)
                    }
                  />
                </TableCell>
                <TableCell>
                  <div className="flex items-center space-x-3">
                    <Avatar className="h-8 w-8">
                      <AvatarImage src={user.avatar} />
                      <AvatarFallback>
                        {user.name
                          .split(' ')
                          .map((n) => n[0])
                          .join('')
                          .toUpperCase()}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <p className="font-medium">{user.name}</p>
                      <p className="text-xs text-muted-foreground">{user.email}</p>
                    </div>
                  </div>
                </TableCell>
                <TableCell>{getStatusBadge(user.status)}</TableCell>
                <TableCell>
                  <div className="flex flex-wrap gap-1">
                    {user.roles.map((role) => (
                      <Badge key={role} variant="outline" className="text-xs">
                        {role}
                      </Badge>
                    ))}
                  </div>
                </TableCell>
                <TableCell>
                  <div className="flex items-center space-x-2">
                    {user.emailVerified ? (
                      <Badge variant="success" className="text-xs">
                        <Mail className="mr-1 h-3 w-3" />
                        Email
                      </Badge>
                    ) : (
                      <Badge variant="secondary" className="text-xs">
                        <Mail className="mr-1 h-3 w-3" />
                        Unverified
                      </Badge>
                    )}
                    {user.twoFactorEnabled && (
                      <Badge variant="success" className="text-xs">
                        <Shield className="mr-1 h-3 w-3" />
                        2FA
                      </Badge>
                    )}
                  </div>
                </TableCell>
                <TableCell>
                  {user.lastLogin ? (
                    <span className="text-xs">
                      {formatDistanceToNow(new Date(user.lastLogin))} ago
                    </span>
                  ) : (
                    <span className="text-xs text-muted-foreground">Never</span>
                  )}
                </TableCell>
                <TableCell>
                  <span className="text-xs">
                    {format(new Date(user.createdAt), 'MMM d, yyyy')}
                  </span>
                </TableCell>
                <TableCell className="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="icon" className="h-8 w-8">
                        <MoreVertical className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuLabel>Actions</DropdownMenuLabel>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem
                        onClick={() => {
                          setSelectedUser(user);
                          setShowUserDialog(true);
                        }}
                      >
                        <Edit className="mr-2 h-4 w-4" />
                        Edit User
                      </DropdownMenuItem>
                      <DropdownMenuItem onClick={() => handleImpersonateUser(user.id)}>
                        <Eye className="mr-2 h-4 w-4" />
                        Impersonate
                      </DropdownMenuItem>
                      <DropdownMenuItem onClick={() => handleResetPassword(user.id)}>
                        <Key className="mr-2 h-4 w-4" />
                        Reset Password
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem
                        onClick={() => updateUserStatus(user.id, 'suspended')}
                        disabled={user.status === 'suspended'}
                      >
                        <Ban className="mr-2 h-4 w-4" />
                        Suspend User
                      </DropdownMenuItem>
                      <DropdownMenuItem
                        className="text-destructive"
                        onClick={() => deleteUser(user.id)}
                      >
                        <Trash2 className="mr-2 h-4 w-4" />
                        Delete User
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        {filteredUsers.length === 0 && (
          <CardContent className="py-8 text-center">
            <p className="text-muted-foreground">No users found</p>
          </CardContent>
        )}
      </Card>

      {/* Pagination */}
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          Showing {(currentPage - 1) * pageSize + 1} to{' '}
          {Math.min(currentPage * pageSize, totalUsers)} of {totalUsers} users
        </p>
        <div className="flex items-center space-x-2">
          <Button
            variant="outline"
            size="icon"
            onClick={() => fetchUsers(1)}
            disabled={currentPage === 1}
          >
            <ChevronsLeft className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => fetchUsers(currentPage - 1)}
            disabled={currentPage === 1}
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <span className="text-sm">
            Page {currentPage} of {totalPages}
          </span>
          <Button
            variant="outline"
            size="icon"
            onClick={() => fetchUsers(currentPage + 1)}
            disabled={currentPage === totalPages}
          >
            <ChevronRight className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => fetchUsers(totalPages)}
            disabled={currentPage === totalPages}
          >
            <ChevronsRight className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* User Dialog */}
      <Dialog open={showUserDialog} onOpenChange={setShowUserDialog}>
        <DialogContent className="sm:max-w-[600px]">
          <DialogHeader>
            <DialogTitle>
              {selectedUser ? 'Edit User' : 'Create New User'}
            </DialogTitle>
            <DialogDescription>
              {selectedUser
                ? 'Update user information and permissions'
                : 'Add a new user to the system'}
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid gap-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                placeholder="user@example.com"
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="name">Name</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="John Doe"
              />
            </div>
            {!selectedUser && (
              <div className="grid gap-2">
                <Label htmlFor="password">Password</Label>
                <Input
                  id="password"
                  type="password"
                  value={formData.password}
                  onChange={(e) =>
                    setFormData({ ...formData, password: e.target.value })
                  }
                  placeholder="Strong password"
                />
              </div>
            )}
            <div className="grid gap-2">
              <Label>Roles</Label>
              <div className="space-y-2">
                {['admin', 'moderator', 'user'].map((role) => (
                  <div key={role} className="flex items-center space-x-2">
                    <Checkbox
                      id={role}
                      checked={formData.roles.includes(role)}
                      onCheckedChange={(checked) => {
                        if (checked) {
                          setFormData({
                            ...formData,
                            roles: [...formData.roles, role],
                          });
                        } else {
                          setFormData({
                            ...formData,
                            roles: formData.roles.filter((r) => r !== role),
                          });
                        }
                      }}
                    />
                    <label
                      htmlFor={role}
                      className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                    >
                      {role.charAt(0).toUpperCase() + role.slice(1)}
                    </label>
                  </div>
                ))}
              </div>
            </div>
            {!selectedUser && (
              <>
                <div className="flex items-center space-x-2">
                  <Switch
                    id="sendWelcome"
                    checked={formData.sendWelcomeEmail}
                    onCheckedChange={(checked) =>
                      setFormData({ ...formData, sendWelcomeEmail: checked })
                    }
                  />
                  <Label htmlFor="sendWelcome">Send welcome email</Label>
                </div>
                <div className="flex items-center space-x-2">
                  <Switch
                    id="requirePassword"
                    checked={formData.requirePasswordChange}
                    onCheckedChange={(checked) =>
                      setFormData({ ...formData, requirePasswordChange: checked })
                    }
                  />
                  <Label htmlFor="requirePassword">
                    Require password change on first login
                  </Label>
                </div>
              </>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowUserDialog(false)}>
              Cancel
            </Button>
            <Button onClick={() => {
              // Handle create/update user
              setShowUserDialog(false);
            }}>
              {selectedUser ? 'Update User' : 'Create User'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}