'use client';

import React, { useState, useEffect, useMemo, useCallback } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
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
  DialogHeader,
  DialogTitle,
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
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Skeleton } from '@/components/ui/skeleton';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Calendar } from '@/components/ui/calendar';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover';
import {
  Search,
  Download,
  RefreshCw,
  Calendar as CalendarIcon,
  Clock,
  Shield,
  Activity,
  AlertTriangle,
  CheckCircle,
  XCircle,
  Info,
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
  Eye,
  Copy,
  Lock,
  Unlock,
  UserCheck,
  UserX,
  Mail,
  Key,
  Settings,
  Trash2,
  Edit,
  LogIn,
  LogOut,
} from 'lucide-react';
import { format, startOfDay, endOfDay, subDays } from 'date-fns';
import { useToast } from '@/components/ui/use-toast';
import { cn } from '@/lib/utils';

interface AuditLog {
  id: string;
  timestamp: string;
  action: string;
  category: string;
  severity: 'info' | 'warning' | 'error' | 'critical';
  userId?: string;
  userName?: string;
  userEmail?: string;
  ipAddress: string;
  userAgent?: string;
  resource?: string;
  resourceId?: string;
  changes?: Record<string, { old: unknown; new: unknown }>;
  metadata?: Record<string, unknown>;
  status: 'success' | 'failure';
  errorMessage?: string;
  duration?: number;
}

interface AuditFilter {
  search: string;
  category: string;
  severity: string;
  status: string;
  action: string;
  userId: string;
  dateRange: {
    from: Date | undefined;
    to: Date | undefined;
  };
  ipAddress: string;
}

interface AuditStats {
  totalLogs: number;
  byCategory: Record<string, number>;
  bySeverity: Record<string, number>;
  byStatus: Record<string, number>;
  topUsers: Array<{ userId: string; userName: string; count: number }>;
  topActions: Array<{ action: string; count: number }>;
  recentAlerts: number;
}

const actionIcons: Record<string, React.ComponentType<React.SVGProps<SVGSVGElement>>> = {
  'user.login': LogIn,
  'user.logout': LogOut,
  'user.created': UserCheck,
  'user.updated': Edit,
  'user.deleted': UserX,
  'user.suspended': Lock,
  'user.activated': Unlock,
  'password.changed': Key,
  'password.reset': Key,
  'email.verified': Mail,
  '2fa.enabled': Shield,
  '2fa.disabled': Shield,
  'permission.granted': CheckCircle,
  'permission.revoked': XCircle,
  'api_key.created': Key,
  'api_key.revoked': Key,
  'settings.updated': Settings,
  'data.exported': Download,
  'data.deleted': Trash2,
};

const categoryColors: Record<string, string> = {
  authentication: 'bg-blue-500',
  authorization: 'bg-purple-500',
  user_management: 'bg-green-500',
  security: 'bg-red-500',
  data: 'bg-yellow-500',
  system: 'bg-gray-500',
  api: 'bg-indigo-500',
  admin: 'bg-pink-500',
};

export default function AuditLogViewer() {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [stats, setStats] = useState<AuditStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [selectedLog, setSelectedLog] = useState<AuditLog | null>(null);
  const [showDetailsDialog, setShowDetailsDialog] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [pageSize] = useState(20);
  const { toast } = useToast();

  const [filter, setFilter] = useState<AuditFilter>({
    search: '',
    category: 'all',
    severity: 'all',
    status: 'all',
    action: 'all',
    userId: '',
    dateRange: {
      from: subDays(new Date(), 7),
      to: new Date(),
    },
    ipAddress: '',
  });

  const categories = [
    'all',
    'authentication',
    'authorization',
    'user_management',
    'security',
    'data',
    'system',
    'api',
    'admin',
  ];

  const severities = ['all', 'info', 'warning', 'error', 'critical'];
  const statuses = ['all', 'success', 'failure'];

  const fetchAuditLogs = useCallback(async () => {
    try {
      const params = new URLSearchParams({
        page: currentPage.toString(),
        limit: pageSize.toString(),
      });

      if (filter.search) params.append('search', filter.search);
      if (filter.category !== 'all') params.append('category', filter.category);
      if (filter.severity !== 'all') params.append('severity', filter.severity);
      if (filter.status !== 'all') params.append('status', filter.status);
      if (filter.action !== 'all') params.append('action', filter.action);
      if (filter.userId) params.append('user_id', filter.userId);
      if (filter.ipAddress) params.append('ip_address', filter.ipAddress);
      if (filter.dateRange.from) {
        params.append('from_date', startOfDay(filter.dateRange.from).toISOString());
      }
      if (filter.dateRange.to) {
        params.append('to_date', endOfDay(filter.dateRange.to).toISOString());
      }

      const response = await fetch(`/api/v1/admin/audit-logs?${params}`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setLogs(data.logs);
        setTotalPages(Math.ceil(data.total / pageSize));
      }
    } catch {
      // Log error to monitoring service
      // Error details intentionally not logged in production for security
      toast({
        title: 'Error',
        description: 'Failed to fetch audit logs',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  }, [currentPage, pageSize, filter, toast]);

  const fetchAuditStats = useCallback(async () => {
    try {
      const response = await fetch('/api/v1/admin/audit-logs/stats', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setStats(data);
      }
    } catch {
      // Error details intentionally not logged in production for security
      // Stats are not critical, silently fail
    }
  }, []);

  useEffect(() => {
    fetchAuditLogs();
    fetchAuditStats();
  }, [fetchAuditLogs, fetchAuditStats]);

  const exportAuditLogs = async () => {
    try {
      const params = new URLSearchParams();
      if (filter.dateRange.from) {
        params.append('from_date', startOfDay(filter.dateRange.from).toISOString());
      }
      if (filter.dateRange.to) {
        params.append('to_date', endOfDay(filter.dateRange.to).toISOString());
      }

      const response = await fetch(`/api/v1/admin/audit-logs/export?${params}`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const blob = await response.blob();
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `audit_logs_${format(new Date(), 'yyyy-MM-dd')}.csv`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);

        toast({
          title: 'Success',
          description: 'Audit logs exported successfully',
        });
      }
    } catch {
      // Error details intentionally not logged for security
      toast({
        title: 'Error',
        description: 'Failed to export audit logs',
        variant: 'destructive',
      });
    }
  };

  const getSeverityBadge = (severity: string) => {
    switch (severity) {
      case 'info':
        return (
          <Badge variant="secondary" className="text-xs">
            <Info className="mr-1 h-3 w-3" />
            Info
          </Badge>
        );
      case 'warning':
        return (
          <Badge variant="warning" className="text-xs">
            <AlertTriangle className="mr-1 h-3 w-3" />
            Warning
          </Badge>
        );
      case 'error':
        return (
          <Badge variant="destructive" className="text-xs">
            <XCircle className="mr-1 h-3 w-3" />
            Error
          </Badge>
        );
      case 'critical':
        return (
          <Badge variant="destructive" className="text-xs bg-red-700">
            <AlertTriangle className="mr-1 h-3 w-3" />
            Critical
          </Badge>
        );
      default:
        return null;
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'success':
        return (
          <Badge variant="success" className="text-xs">
            <CheckCircle className="mr-1 h-3 w-3" />
            Success
          </Badge>
        );
      case 'failure':
        return (
          <Badge variant="destructive" className="text-xs">
            <XCircle className="mr-1 h-3 w-3" />
            Failed
          </Badge>
        );
      default:
        return null;
    }
  };

  const getActionIcon = (action: string) => {
    const Icon = actionIcons[action] || Activity;
    return <Icon className="h-4 w-4" />;
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    toast({
      title: 'Copied',
      description: 'Copied to clipboard',
    });
  };

  const filteredLogs = useMemo(() => {
    return logs; // Already filtered server-side
  }, [logs]);

  if (loading) {
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
          <h2 className="text-2xl font-bold tracking-tight">Audit Logs</h2>
          <p className="text-muted-foreground">
            System-wide activity and security audit trail
          </p>
        </div>
        <div className="flex space-x-2">
          <Button variant="outline" size="sm" onClick={fetchAuditLogs}>
            <RefreshCw className="mr-2 h-4 w-4" />
            Refresh
          </Button>
          <Button variant="outline" size="sm" onClick={exportAuditLogs}>
            <Download className="mr-2 h-4 w-4" />
            Export
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      {stats && (
        <div className="grid gap-4 md:grid-cols-4">
          <Card>
            <CardHeader className="pb-2">
              <CardDescription>Total Logs</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-2xl font-bold">{stats.totalLogs.toLocaleString()}</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardDescription>Recent Alerts</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-2xl font-bold">{stats.recentAlerts}</p>
              {stats.recentAlerts > 0 && (
                <Badge variant="destructive" className="mt-2">
                  Requires Attention
                </Badge>
              )}
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardDescription>Top Action</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm font-medium">
                {stats.topActions[0]?.action || 'N/A'}
              </p>
              <p className="text-xs text-muted-foreground">
                {stats.topActions[0]?.count || 0} occurrences
              </p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardDescription>Most Active User</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm font-medium">
                {stats.topUsers[0]?.userName || 'N/A'}
              </p>
              <p className="text-xs text-muted-foreground">
                {stats.topUsers[0]?.count || 0} actions
              </p>
            </CardContent>
          </Card>
        </div>
      )}

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
                placeholder="Search logs..."
                value={filter.search}
                onChange={(e) => setFilter({ ...filter, search: e.target.value })}
              />
            </div>
            <Select
              value={filter.category}
              onValueChange={(value) => setFilter({ ...filter, category: value })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Category" />
              </SelectTrigger>
              <SelectContent>
                {categories.map((category) => (
                  <SelectItem key={category} value={category}>
                    {category === 'all'
                      ? 'All Categories'
                      : category.replace('_', ' ').replace(/\b\w/g, (l) => l.toUpperCase())}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select
              value={filter.severity}
              onValueChange={(value) => setFilter({ ...filter, severity: value })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Severity" />
              </SelectTrigger>
              <SelectContent>
                {severities.map((severity) => (
                  <SelectItem key={severity} value={severity}>
                    {severity === 'all'
                      ? 'All Severities'
                      : severity.charAt(0).toUpperCase() + severity.slice(1)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select
              value={filter.status}
              onValueChange={(value) => setFilter({ ...filter, status: value })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                {statuses.map((status) => (
                  <SelectItem key={status} value={status}>
                    {status === 'all'
                      ? 'All Status'
                      : status.charAt(0).toUpperCase() + status.slice(1)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="grid gap-4 md:grid-cols-4 mt-4">
            <Input
              placeholder="User ID"
              value={filter.userId}
              onChange={(e) => setFilter({ ...filter, userId: e.target.value })}
            />
            <Input
              placeholder="IP Address"
              value={filter.ipAddress}
              onChange={(e) => setFilter({ ...filter, ipAddress: e.target.value })}
            />
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant="outline"
                  className={cn(
                    'justify-start text-left font-normal',
                    !filter.dateRange.from && 'text-muted-foreground'
                  )}
                >
                  <CalendarIcon className="mr-2 h-4 w-4" />
                  {filter.dateRange.from ? (
                    format(filter.dateRange.from, 'PPP')
                  ) : (
                    <span>From date</span>
                  )}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0">
                <Calendar
                  mode="single"
                  selected={filter.dateRange.from}
                  onSelect={(date) =>
                    setFilter({
                      ...filter,
                      dateRange: { ...filter.dateRange, from: date },
                    })
                  }
                  initialFocus
                />
              </PopoverContent>
            </Popover>
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant="outline"
                  className={cn(
                    'justify-start text-left font-normal',
                    !filter.dateRange.to && 'text-muted-foreground'
                  )}
                >
                  <CalendarIcon className="mr-2 h-4 w-4" />
                  {filter.dateRange.to ? (
                    format(filter.dateRange.to, 'PPP')
                  ) : (
                    <span>To date</span>
                  )}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0">
                <Calendar
                  mode="single"
                  selected={filter.dateRange.to}
                  onSelect={(date) =>
                    setFilter({
                      ...filter,
                      dateRange: { ...filter.dateRange, to: date },
                    })
                  }
                  initialFocus
                />
              </PopoverContent>
            </Popover>
          </div>
        </CardContent>
      </Card>

      {/* Logs Table */}
      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Timestamp</TableHead>
              <TableHead>Action</TableHead>
              <TableHead>User</TableHead>
              <TableHead>Category</TableHead>
              <TableHead>Severity</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>IP Address</TableHead>
              <TableHead>Duration</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredLogs.map((log) => (
              <TableRow key={log.id}>
                <TableCell>
                  <div className="flex items-center space-x-2">
                    <Clock className="h-3 w-3 text-muted-foreground" />
                    <div>
                      <p className="text-xs font-medium">
                        {format(new Date(log.timestamp), 'MMM d, yyyy')}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {format(new Date(log.timestamp), 'HH:mm:ss')}
                      </p>
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <div className="flex items-center space-x-2">
                    {getActionIcon(log.action)}
                    <span className="text-sm">{log.action.replace('.', ' ')}</span>
                  </div>
                </TableCell>
                <TableCell>
                  {log.userName ? (
                    <div>
                      <p className="text-sm font-medium">{log.userName}</p>
                      <p className="text-xs text-muted-foreground">{log.userEmail}</p>
                    </div>
                  ) : (
                    <span className="text-sm text-muted-foreground">System</span>
                  )}
                </TableCell>
                <TableCell>
                  <div className="flex items-center space-x-2">
                    <div
                      className={cn(
                        'h-2 w-2 rounded-full',
                        categoryColors[log.category] || 'bg-gray-500'
                      )}
                    />
                    <span className="text-sm capitalize">
                      {log.category.replace('_', ' ')}
                    </span>
                  </div>
                </TableCell>
                <TableCell>{getSeverityBadge(log.severity)}</TableCell>
                <TableCell>{getStatusBadge(log.status)}</TableCell>
                <TableCell>
                  <code className="text-xs">{log.ipAddress}</code>
                </TableCell>
                <TableCell>
                  {log.duration ? (
                    <span className="text-xs">{log.duration}ms</span>
                  ) : (
                    <span className="text-xs text-muted-foreground">-</span>
                  )}
                </TableCell>
                <TableCell className="text-right">
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-8 w-8"
                    onClick={() => {
                      setSelectedLog(log);
                      setShowDetailsDialog(true);
                    }}
                  >
                    <Eye className="h-4 w-4" />
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        {filteredLogs.length === 0 && (
          <CardContent className="py-8 text-center">
            <p className="text-muted-foreground">No audit logs found</p>
          </CardContent>
        )}
      </Card>

      {/* Pagination */}
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          Page {currentPage} of {totalPages}
        </p>
        <div className="flex items-center space-x-2">
          <Button
            variant="outline"
            size="icon"
            onClick={() => setCurrentPage(1)}
            disabled={currentPage === 1}
          >
            <ChevronsLeft className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => setCurrentPage(currentPage - 1)}
            disabled={currentPage === 1}
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => setCurrentPage(currentPage + 1)}
            disabled={currentPage === totalPages}
          >
            <ChevronRight className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => setCurrentPage(totalPages)}
            disabled={currentPage === totalPages}
          >
            <ChevronsRight className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Log Details Dialog */}
      <Dialog open={showDetailsDialog} onOpenChange={setShowDetailsDialog}>
        <DialogContent className="sm:max-w-[700px]">
          <DialogHeader>
            <DialogTitle>Audit Log Details</DialogTitle>
            <DialogDescription>
              Complete information about this audit log entry
            </DialogDescription>
          </DialogHeader>
          {selectedLog && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label>Log ID</Label>
                  <div className="flex items-center space-x-2 mt-1">
                    <code className="text-sm">{selectedLog.id}</code>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-6 w-6"
                      onClick={() => copyToClipboard(selectedLog.id)}
                    >
                      <Copy className="h-3 w-3" />
                    </Button>
                  </div>
                </div>
                <div>
                  <Label>Timestamp</Label>
                  <p className="text-sm mt-1">
                    {format(new Date(selectedLog.timestamp), 'PPpp')}
                  </p>
                </div>
                <div>
                  <Label>Action</Label>
                  <div className="flex items-center space-x-2 mt-1">
                    {getActionIcon(selectedLog.action)}
                    <span className="text-sm">{selectedLog.action}</span>
                  </div>
                </div>
                <div>
                  <Label>Category</Label>
                  <p className="text-sm capitalize mt-1">
                    {selectedLog.category.replace('_', ' ')}
                  </p>
                </div>
                <div>
                  <Label>Severity</Label>
                  <div className="mt-1">{getSeverityBadge(selectedLog.severity)}</div>
                </div>
                <div>
                  <Label>Status</Label>
                  <div className="mt-1">{getStatusBadge(selectedLog.status)}</div>
                </div>
              </div>

              {selectedLog.userId && (
                <div>
                  <Label>User Information</Label>
                  <div className="mt-2 p-3 bg-muted rounded-md">
                    <div className="grid grid-cols-2 gap-2 text-sm">
                      <div>
                        <span className="text-muted-foreground">ID:</span>{' '}
                        {selectedLog.userId}
                      </div>
                      <div>
                        <span className="text-muted-foreground">Name:</span>{' '}
                        {selectedLog.userName}
                      </div>
                      <div>
                        <span className="text-muted-foreground">Email:</span>{' '}
                        {selectedLog.userEmail}
                      </div>
                      <div>
                        <span className="text-muted-foreground">IP:</span>{' '}
                        {selectedLog.ipAddress}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {selectedLog.resource && (
                <div>
                  <Label>Resource</Label>
                  <div className="mt-2 p-3 bg-muted rounded-md">
                    <div className="text-sm">
                      <span className="text-muted-foreground">Type:</span>{' '}
                      {selectedLog.resource}
                      {selectedLog.resourceId && (
                        <>
                          <br />
                          <span className="text-muted-foreground">ID:</span>{' '}
                          {selectedLog.resourceId}
                        </>
                      )}
                    </div>
                  </div>
                </div>
              )}

              {selectedLog.changes && Object.keys(selectedLog.changes).length > 0 && (
                <div>
                  <Label>Changes</Label>
                  <ScrollArea className="h-48 mt-2">
                    <pre className="text-xs bg-muted p-3 rounded-md">
                      {JSON.stringify(selectedLog.changes, null, 2)}
                    </pre>
                  </ScrollArea>
                </div>
              )}

              {selectedLog.metadata && Object.keys(selectedLog.metadata).length > 0 && (
                <div>
                  <Label>Additional Metadata</Label>
                  <ScrollArea className="h-48 mt-2">
                    <pre className="text-xs bg-muted p-3 rounded-md">
                      {JSON.stringify(selectedLog.metadata, null, 2)}
                    </pre>
                  </ScrollArea>
                </div>
              )}

              {selectedLog.errorMessage && (
                <Alert variant="destructive">
                  <AlertTriangle className="h-4 w-4" />
                  <AlertTitle>Error</AlertTitle>
                  <AlertDescription>{selectedLog.errorMessage}</AlertDescription>
                </Alert>
              )}

              {selectedLog.userAgent && (
                <div>
                  <Label>User Agent</Label>
                  <p className="text-xs mt-1 text-muted-foreground">
                    {selectedLog.userAgent}
                  </p>
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}