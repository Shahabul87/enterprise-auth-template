'use client';

import { useState, useEffect } from 'react';
import { useRequireAuth } from '@/stores/auth.store';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Checkbox } from '@/components/ui/checkbox';
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
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Key,
  Plus,
  Copy,
  MoreHorizontal,
  Trash2,
  AlertTriangle,
  Calendar,
  Activity,
  Clock,
  CheckCircle,
  XCircle,
} from 'lucide-react';
import { toast } from 'sonner';

// Types based on backend API

interface APIKeyResponse {
  id: string;
  name: string;
  description: string | null;
  key_prefix: string;
  scopes: string[];
  rate_limit: number;
  allowed_ips: string[];
  is_active: boolean;
  usage_count: number;
  last_used_at: string | null;
  created_at: string;
  updated_at: string;
  expires_at: string | null;
  days_until_expiry: number | null;
}

interface APIKeyCreateRequest {
  name: string;
  description?: string;
  scopes: string[];
  rate_limit: number;
  allowed_ips?: string[];
  expires_in_days?: number;
}

interface APIKeyCreateResponse {
  api_key: APIKeyResponse;
  key: string;
  warning: string;
}

interface APIKeyUsageStats {
  api_key_id: string;
  period: string;
  total_requests: number;
  successful_requests: number;
  failed_requests: number;
  rate_limit_hits: number;
  unique_ips: number;
  most_used_endpoints: Array<{ endpoint: string; count: number }>;
  daily_usage: Array<{ date: string; requests: number }>;
  error_breakdown: Record<string, number>;
}

const API_KEY_SCOPES: Record<string, { label: string; description: string }> = {
  'read': { label: 'Read', description: 'Read access to resources' },
  'write': { label: 'Write', description: 'Create and modify resources' },
  'delete': { label: 'Delete', description: 'Delete resources' },
  'admin': { label: 'Admin', description: 'Full administrative access' },
  'users:read': { label: 'Users (Read)', description: 'Read user information' },
  'users:write': { label: 'Users (Write)', description: 'Manage user accounts' },
  'metrics:read': { label: 'Metrics (Read)', description: 'Access analytics and metrics' },
  'webhooks:manage': { label: 'Webhooks', description: 'Manage webhook configurations' },
  'notifications:send': { label: 'Notifications', description: 'Send notifications' },
};

export default function APIKeysPage(): JSX.Element {
  const { user } = useRequireAuth();
  const [apiKeys, setApiKeys] = useState<APIKeyResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [viewKeyDialogOpen, setViewKeyDialogOpen] = useState(false);
  const [usageDialogOpen, setUsageDialogOpen] = useState(false);
  const [selectedKey, setSelectedKey] = useState<APIKeyResponse | null>(null);
  const [selectedKeyValue, setSelectedKeyValue] = useState<string>('');
  const [usageStats, setUsageStats] = useState<APIKeyUsageStats | null>(null);
  const [createForm, setCreateForm] = useState<APIKeyCreateRequest>({
    name: '',
    description: '',
    scopes: [],
    rate_limit: 1000,
    allowed_ips: [],
    expires_in_days: 90,
  });
  const [allowedIpsText, setAllowedIpsText] = useState('');

  useEffect(() => {
    loadAPIKeys();
  }, []);

  const loadAPIKeys = async (): Promise<void> => {
    try {
      setLoading(true);
      // TODO: Replace with actual API call
      const mockData: APIKeyResponse[] = [
        {
          id: '1',
          name: 'Analytics Dashboard',
          description: 'API key for analytics dashboard access',
          key_prefix: 'ak_test_123...',
          scopes: ['metrics:read', 'users:read'],
          rate_limit: 5000,
          allowed_ips: ['192.168.1.0/24'],
          is_active: true,
          usage_count: 1247,
          last_used_at: new Date(Date.now() - 1000 * 60 * 30).toISOString(),
          created_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 30).toISOString(),
          updated_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 7).toISOString(),
          expires_at: new Date(Date.now() + 1000 * 60 * 60 * 24 * 60).toISOString(),
          days_until_expiry: 60,
        },
        {
          id: '2',
          name: 'Mobile App',
          description: 'API key for mobile application',
          key_prefix: 'ak_live_456...',
          scopes: ['read', 'write', 'notifications:send'],
          rate_limit: 10000,
          allowed_ips: [],
          is_active: true,
          usage_count: 5678,
          last_used_at: new Date(Date.now() - 1000 * 60 * 5).toISOString(),
          created_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 90).toISOString(),
          updated_at: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString(),
          expires_at: null,
          days_until_expiry: null,
        },
      ];
      setApiKeys(mockData);
    } catch {
      toast.error('Failed to load API keys');
      // Error logged for debugging
    } finally {
      setLoading(false);
    }
  };

  const handleCreateAPIKey = async (): Promise<void> => {
    try {
      if (!createForm.name.trim()) {
        toast.error('API key name is required');
        return;
      }

      if (createForm.scopes.length === 0) {
        toast.error('At least one scope must be selected');
        return;
      }

      const allowed_ips = allowedIpsText
        .split('\n')
        .map(ip => ip.trim())
        .filter(ip => ip.length > 0);

      const requestData: APIKeyCreateRequest = {
        ...createForm,
        ...(allowed_ips.length > 0 ? { allowed_ips } : {}),
      };

      // TODO: Replace with actual API call
      const mockResponse: APIKeyCreateResponse = {
        api_key: {
          id: String(apiKeys.length + 1),
          name: requestData.name,
          description: requestData.description || null,
          key_prefix: `ak_${requestData.name.toLowerCase().replace(/\s+/g, '_').substring(0, 8)}...`,
          scopes: requestData.scopes,
          rate_limit: requestData.rate_limit,
          allowed_ips: requestData.allowed_ips || [],
          is_active: true,
          usage_count: 0,
          last_used_at: null,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
          expires_at: requestData.expires_in_days 
            ? new Date(Date.now() + requestData.expires_in_days * 24 * 60 * 60 * 1000).toISOString()
            : null,
          days_until_expiry: requestData.expires_in_days || null,
        },
        key: `ak_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`,
        warning: 'Store this API key securely. It will not be shown again.',
      };

      setApiKeys(prev => [...prev, mockResponse.api_key]);
      setSelectedKeyValue(mockResponse.key);
      setCreateDialogOpen(false);
      setViewKeyDialogOpen(true);
      
      // Reset form
      setCreateForm({
        name: '',
        description: '',
        scopes: [],
        rate_limit: 1000,
        allowed_ips: [],
        expires_in_days: 90,
      });
      setAllowedIpsText('');
      
      toast.success('API key created successfully');
    } catch {
      toast.error('Failed to create API key');
      // Error logged for debugging
    }
  };

  const handleToggleAPIKey = async (keyId: string, isActive: boolean): Promise<void> => {
    try {
      // TODO: Replace with actual API call
      setApiKeys(prev => 
        prev.map(key => 
          key.id === keyId ? { ...key, is_active: !isActive } : key
        )
      );
      toast.success(isActive ? 'API key deactivated' : 'API key activated');
    } catch {
      toast.error('Failed to update API key');
      // Error logged for debugging
    }
  };

  const handleDeleteAPIKey = async (keyId: string): Promise<void> => {
    try {
      // TODO: Replace with actual API call
      setApiKeys(prev => prev.filter(key => key.id !== keyId));
      toast.success('API key deleted');
    } catch {
      toast.error('Failed to delete API key');
      // Error logged for debugging
    }
  };

  const handleViewUsage = async (apiKey: APIKeyResponse): Promise<void> => {
    try {
      setSelectedKey(apiKey);
      // TODO: Replace with actual API call
      const mockUsageStats: APIKeyUsageStats = {
        api_key_id: apiKey.id,
        period: '30 days',
        total_requests: apiKey.usage_count,
        successful_requests: Math.floor(apiKey.usage_count * 0.95),
        failed_requests: Math.floor(apiKey.usage_count * 0.05),
        rate_limit_hits: Math.floor(apiKey.usage_count * 0.02),
        unique_ips: 15,
        most_used_endpoints: [
          { endpoint: '/api/v1/users', count: Math.floor(apiKey.usage_count * 0.4) },
          { endpoint: '/api/v1/metrics', count: Math.floor(apiKey.usage_count * 0.3) },
          { endpoint: '/api/v1/notifications', count: Math.floor(apiKey.usage_count * 0.3) },
        ],
        daily_usage: Array.from({ length: 7 }, (_, i) => ({
          date: new Date(Date.now() - i * 24 * 60 * 60 * 1000).toISOString().split('T')[0]!,
          requests: Math.floor(Math.random() * 200) + 50,
        })).reverse(),
        error_breakdown: {
          '401': 12,
          '403': 8,
          '429': 15,
          '500': 3,
        },
      };
      setUsageStats(mockUsageStats);
      setUsageDialogOpen(true);
    } catch {
      toast.error('Failed to load usage statistics');
      // Error logged for debugging
    }
  };

  const copyToClipboard = async (text: string): Promise<void> => {
    try {
      await navigator.clipboard.writeText(text);
      toast.success('Copied to clipboard');
    } catch {
      toast.error('Failed to copy to clipboard');
      // Error logged for debugging
    }
  };


  const formatTimeAgo = (dateString: string | null): string => {
    if (!dateString) return 'Never';
    
    const date = new Date(dateString);
    const now = new Date();
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (diffInSeconds < 60) return 'Just now';
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`;
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`;
    return `${Math.floor(diffInSeconds / 86400)}d ago`;
  };

  const getExpiryStatus = (key: APIKeyResponse): { color: string; text: string; icon: JSX.Element } => {
    if (!key.expires_at) {
      return {
        color: 'text-gray-500',
        text: 'Never expires',
        icon: <CheckCircle className="h-4 w-4" />,
      };
    }

    const daysUntilExpiry = key.days_until_expiry || 0;
    
    if (daysUntilExpiry <= 0) {
      return {
        color: 'text-red-500',
        text: 'Expired',
        icon: <XCircle className="h-4 w-4" />,
      };
    }
    
    if (daysUntilExpiry <= 7) {
      return {
        color: 'text-red-500',
        text: `Expires in ${daysUntilExpiry} day${daysUntilExpiry === 1 ? '' : 's'}`,
        icon: <AlertTriangle className="h-4 w-4" />,
      };
    }
    
    if (daysUntilExpiry <= 30) {
      return {
        color: 'text-yellow-500',
        text: `Expires in ${daysUntilExpiry} days`,
        icon: <Clock className="h-4 w-4" />,
      };
    }
    
    return {
      color: 'text-green-500',
      text: `Expires in ${daysUntilExpiry} days`,
      icon: <Calendar className="h-4 w-4" />,
    };
  };

  if (!user) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  if (loading) {
    return (
      <Card>
        <CardContent className="py-12 text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto mb-4"></div>
          <p className="text-muted-foreground">Loading API keys...</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="flex items-center gap-2">
                <Key className="h-5 w-5" />
                API Keys
              </CardTitle>
              <CardDescription>
                Create and manage API keys for programmatic access to your account.
                API keys provide secure authentication for applications and services.
              </CardDescription>
            </div>
            <Dialog open={createDialogOpen} onOpenChange={setCreateDialogOpen}>
              <DialogTrigger asChild>
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Create API Key
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-2xl">
                <DialogHeader>
                  <DialogTitle>Create New API Key</DialogTitle>
                  <DialogDescription>
                    Create a new API key for programmatic access. Choose scopes carefully based on your needs.
                  </DialogDescription>
                </DialogHeader>
                
                <div className="space-y-6">
                  <div className="space-y-2">
                    <Label htmlFor="name">Name *</Label>
                    <Input
                      id="name"
                      placeholder="e.g., Analytics Dashboard, Mobile App"
                      value={createForm.name}
                      onChange={(e) => setCreateForm(prev => ({ ...prev, name: e.target.value }))}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="description">Description</Label>
                    <Textarea
                      id="description"
                      placeholder="What will this API key be used for?"
                      value={createForm.description}
                      onChange={(e) => setCreateForm(prev => ({ ...prev, description: e.target.value }))}
                      rows={3}
                    />
                  </div>

                  <div className="space-y-3">
                    <Label>Scopes *</Label>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      {Object.entries(API_KEY_SCOPES).map(([scope, info]) => (
                        <div key={scope} className="flex items-start space-x-3">
                          <Checkbox
                            id={scope}
                            checked={createForm.scopes.includes(scope)}
                            onCheckedChange={(checked) => {
                              setCreateForm(prev => ({
                                ...prev,
                                scopes: checked
                                  ? [...prev.scopes, scope]
                                  : prev.scopes.filter(s => s !== scope),
                              }));
                            }}
                          />
                          <div className="space-y-1">
                            <Label
                              htmlFor={scope}
                              className="text-sm font-medium cursor-pointer"
                            >
                              {info.label}
                            </Label>
                            <p className="text-xs text-muted-foreground">
                              {info.description}
                            </p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="rate_limit">Rate Limit (requests/hour)</Label>
                      <Input
                        id="rate_limit"
                        type="number"
                        min="100"
                        max="10000"
                        value={createForm.rate_limit}
                        onChange={(e) => setCreateForm(prev => ({ 
                          ...prev, 
                          rate_limit: parseInt(e.target.value) || 1000 
                        }))}
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="expires_in_days">Expires in (days)</Label>
                      <Select
                        value={createForm.expires_in_days?.toString() || 'never'}
                        onValueChange={(value) => {
                          setCreateForm(prev => ({
                            ...prev,
                            ...(value === 'never' ? {} : { expires_in_days: parseInt(value) }),
                          }));
                        }}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="7">7 days</SelectItem>
                          <SelectItem value="30">30 days</SelectItem>
                          <SelectItem value="90">90 days</SelectItem>
                          <SelectItem value="365">1 year</SelectItem>
                          <SelectItem value="never">Never expires</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="allowed_ips">Allowed IP Addresses (optional)</Label>
                    <Textarea
                      id="allowed_ips"
                      placeholder="192.168.1.0/24&#10;10.0.0.1&#10;203.0.113.0/24"
                      value={allowedIpsText}
                      onChange={(e) => setAllowedIpsText(e.target.value)}
                      rows={4}
                    />
                    <p className="text-xs text-muted-foreground">
                      Enter IP addresses or CIDR ranges, one per line. Leave empty to allow all IPs.
                    </p>
                  </div>
                </div>

                <DialogFooter>
                  <Button variant="outline" onClick={() => setCreateDialogOpen(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleCreateAPIKey}>
                    Create API Key
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>
        </CardHeader>
      </Card>

      {/* API Keys Table */}
      <Card>
        <CardHeader>
          <CardTitle>Your API Keys ({apiKeys.length})</CardTitle>
        </CardHeader>
        <CardContent>
          {apiKeys.length === 0 ? (
            <div className="text-center py-12">
              <Key className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-medium text-muted-foreground mb-2">No API keys yet</h3>
              <p className="text-sm text-muted-foreground mb-4">
                Create your first API key to start using our API programmatically.
              </p>
              <Button onClick={() => setCreateDialogOpen(true)}>
                <Plus className="h-4 w-4 mr-2" />
                Create Your First API Key
              </Button>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Key Prefix</TableHead>
                  <TableHead>Scopes</TableHead>
                  <TableHead>Usage</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Last Used</TableHead>
                  <TableHead>Expires</TableHead>
                  <TableHead></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {apiKeys.map((apiKey) => {
                  const expiryStatus = getExpiryStatus(apiKey);
                  
                  return (
                    <TableRow key={apiKey.id}>
                      <TableCell>
                        <div>
                          <div className="font-medium">{apiKey.name}</div>
                          {apiKey.description && (
                            <div className="text-sm text-muted-foreground">
                              {apiKey.description}
                            </div>
                          )}
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <code className="text-sm bg-muted px-2 py-1 rounded">
                            {apiKey.key_prefix}
                          </code>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex flex-wrap gap-1">
                          {apiKey.scopes.slice(0, 2).map((scope) => (
                            <Badge key={scope} variant="secondary" className="text-xs">
                              {API_KEY_SCOPES[scope]?.label || scope}
                            </Badge>
                          ))}
                          {apiKey.scopes.length > 2 && (
                            <Badge variant="secondary" className="text-xs">
                              +{apiKey.scopes.length - 2} more
                            </Badge>
                          )}
                        </div>
                      </TableCell>
                      <TableCell>
                        <Button
                          variant="link"
                          className="p-0 h-auto text-sm"
                          onClick={() => handleViewUsage(apiKey)}
                        >
                          {apiKey.usage_count.toLocaleString()} requests
                        </Button>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <Switch
                            checked={apiKey.is_active}
                            onCheckedChange={() => handleToggleAPIKey(apiKey.id, apiKey.is_active)}
                          />
                          <span className={`text-sm ${apiKey.is_active ? 'text-green-600' : 'text-gray-500'}`}>
                            {apiKey.is_active ? 'Active' : 'Inactive'}
                          </span>
                        </div>
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {formatTimeAgo(apiKey.last_used_at)}
                      </TableCell>
                      <TableCell>
                        <div className={`flex items-center gap-1 text-sm ${expiryStatus.color}`}>
                          {expiryStatus.icon}
                          <span>{expiryStatus.text}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="sm">
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuItem onClick={() => handleViewUsage(apiKey)}>
                              <Activity className="h-4 w-4 mr-2" />
                              View Usage
                            </DropdownMenuItem>
                            <DropdownMenuItem onClick={() => copyToClipboard(apiKey.key_prefix)}>
                              <Copy className="h-4 w-4 mr-2" />
                              Copy Prefix
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => handleDeleteAPIKey(apiKey.id)}
                              className="text-destructive"
                            >
                              <Trash2 className="h-4 w-4 mr-2" />
                              Delete
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* View API Key Dialog */}
      <Dialog open={viewKeyDialogOpen} onOpenChange={setViewKeyDialogOpen}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <CheckCircle className="h-5 w-5 text-green-500" />
              API Key Created Successfully
            </DialogTitle>
            <DialogDescription>
              Your API key has been created. Make sure to copy it now as it won&apos;t be shown again.
            </DialogDescription>
          </DialogHeader>

          <Alert>
            <AlertTriangle className="h-4 w-4" />
            <AlertDescription>
              <strong>Important:</strong> Store this API key securely. For security reasons, 
              you won&apos;t be able to view it again after closing this dialog.
            </AlertDescription>
          </Alert>

          <div className="space-y-4">
            <div>
              <Label>Your API Key</Label>
              <div className="flex items-center gap-2 mt-1">
                <Input
                  value={selectedKeyValue}
                  readOnly
                  type="text"
                  className="font-mono"
                />
                <Button
                  size="sm"
                  onClick={() => copyToClipboard(selectedKeyValue)}
                >
                  <Copy className="h-4 w-4" />
                </Button>
              </div>
            </div>

            <div className="bg-muted p-4 rounded-lg">
              <h4 className="font-medium mb-2">Quick Start</h4>
              <pre className="text-sm overflow-x-auto">
                <code>{`curl -H "Authorization: Bearer ${selectedKeyValue}" \\
  https://api.yourapp.com/v1/users`}</code>
              </pre>
            </div>
          </div>

          <DialogFooter>
            <Button onClick={() => setViewKeyDialogOpen(false)}>
              I&apos;ve Saved My API Key
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Usage Statistics Dialog */}
      <Dialog open={usageDialogOpen} onOpenChange={setUsageDialogOpen}>
        <DialogContent className="max-w-4xl">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Activity className="h-5 w-5" />
              API Key Usage Statistics
            </DialogTitle>
            <DialogDescription>
              {selectedKey?.name} - Usage statistics for the last {usageStats?.period}
            </DialogDescription>
          </DialogHeader>

          {usageStats && (
            <div className="space-y-6">
              {/* Overview Stats */}
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <Card>
                  <CardContent className="p-4 text-center">
                    <div className="text-2xl font-bold text-primary">
                      {usageStats.total_requests.toLocaleString()}
                    </div>
                    <div className="text-sm text-muted-foreground">Total Requests</div>
                  </CardContent>
                </Card>
                <Card>
                  <CardContent className="p-4 text-center">
                    <div className="text-2xl font-bold text-green-600">
                      {Math.round((usageStats.successful_requests / usageStats.total_requests) * 100)}%
                    </div>
                    <div className="text-sm text-muted-foreground">Success Rate</div>
                  </CardContent>
                </Card>
                <Card>
                  <CardContent className="p-4 text-center">
                    <div className="text-2xl font-bold text-yellow-600">
                      {usageStats.rate_limit_hits}
                    </div>
                    <div className="text-sm text-muted-foreground">Rate Limits</div>
                  </CardContent>
                </Card>
                <Card>
                  <CardContent className="p-4 text-center">
                    <div className="text-2xl font-bold text-blue-600">
                      {usageStats.unique_ips}
                    </div>
                    <div className="text-sm text-muted-foreground">Unique IPs</div>
                  </CardContent>
                </Card>
              </div>

              {/* Most Used Endpoints */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Most Used Endpoints</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    {usageStats.most_used_endpoints.map((endpoint, index) => (
                      <div key={endpoint.endpoint} className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <Badge variant="outline">{index + 1}</Badge>
                          <code className="text-sm">{endpoint.endpoint}</code>
                        </div>
                        <div className="text-sm font-medium">
                          {endpoint.count.toLocaleString()} requests
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              {/* Daily Usage Chart - Simplified */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Daily Usage</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    {usageStats.daily_usage.map((day) => (
                      <div key={day.date} className="flex items-center justify-between">
                        <div className="text-sm">{new Date(day.date).toLocaleDateString()}</div>
                        <div className="flex items-center gap-2">
                          <div className="w-24 bg-muted rounded-full h-2">
                            <div 
                              className="bg-primary h-2 rounded-full"
                              style={{ 
                                width: `${Math.min((day.requests / Math.max(...usageStats.daily_usage.map(d => d.requests))) * 100, 100)}%` 
                              }}
                            ></div>
                          </div>
                          <div className="text-sm font-medium w-16 text-right">
                            {day.requests}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              {/* Error Breakdown */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Error Breakdown</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    {Object.entries(usageStats.error_breakdown).map(([code, count]) => (
                      <div key={code} className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <Badge variant="destructive">{code}</Badge>
                          <span className="text-sm">
                            {code === '401' ? 'Unauthorized' :
                             code === '403' ? 'Forbidden' :
                             code === '429' ? 'Rate Limited' :
                             code === '500' ? 'Server Error' : 'Unknown'}
                          </span>
                        </div>
                        <div className="text-sm font-medium">{count} errors</div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          )}

          <DialogFooter>
            <Button onClick={() => setUsageDialogOpen(false)}>Close</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}