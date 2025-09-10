'use client';

import React, { useState, useEffect, useCallback } from 'react';
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Skeleton } from '@/components/ui/skeleton';
import { Checkbox } from '@/components/ui/checkbox';
import { Textarea } from '@/components/ui/textarea';
import {
  Key,
  Plus,
  Copy,
  MoreVertical,
  AlertTriangle,
  RefreshCw,
  Trash2,
  Activity,
  Clock,
  CheckCircle,
  XCircle,
  BarChart,
} from 'lucide-react';
import { formatDistanceToNow, format } from 'date-fns';
import { useToast } from '@/components/ui/use-toast';

interface ApiKey {
  id: string;
  name: string;
  key: string;
  prefix: string;
  scopes: string[];
  status: 'active' | 'revoked' | 'expired';
  expiresAt?: string;
  createdAt: string;
  lastUsedAt?: string;
  usageCount: number;
  rateLimit?: number;
  ipWhitelist?: string[];
  description?: string;
}

interface ApiKeyScope {
  id: string;
  name: string;
  description: string;
  permissions: string[];
  category: string;
}

interface ApiKeyUsageStats {
  totalCalls: number;
  successfulCalls: number;
  failedCalls: number;
  averageLatency: number;
  peakUsageTime: string;
  topEndpoints: Array<{ endpoint: string; count: number }>;
  dailyUsage: Array<{ date: string; count: number }>;
}

const availableScopes: ApiKeyScope[] = [
  {
    id: 'read:users',
    name: 'Read Users',
    description: 'Read user information',
    permissions: ['users.read', 'profiles.read'],
    category: 'Users',
  },
  {
    id: 'write:users',
    name: 'Write Users',
    description: 'Modify user information',
    permissions: ['users.write', 'profiles.write'],
    category: 'Users',
  },
  {
    id: 'read:analytics',
    name: 'Read Analytics',
    description: 'Access analytics data',
    permissions: ['analytics.read', 'reports.read'],
    category: 'Analytics',
  },
  {
    id: 'admin:all',
    name: 'Admin Access',
    description: 'Full administrative access',
    permissions: ['*'],
    category: 'Admin',
  },
];

export default function ApiKeyManagement() {
  const [apiKeys, setApiKeys] = useState<ApiKey[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreateDialog, setShowCreateDialog] = useState(false);
  const [showKeyDialog, setShowKeyDialog] = useState(false);
  const [newApiKey, setNewApiKey] = useState<string>('');
  const [selectedKey, setSelectedKey] = useState<ApiKey | null>(null);
  const [showUsageStats, setShowUsageStats] = useState(false);
  const [usageStats, setUsageStats] = useState<ApiKeyUsageStats | null>(null);
  const [activeTab, setActiveTab] = useState('active');
  const { toast } = useToast();

  // Form state for creating new API key
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    scopes: [] as string[],
    expiresIn: '30',
    rateLimit: '1000',
    ipWhitelist: '',
  });

  const fetchApiKeys = useCallback(async () => {
    try {
      const response = await fetch('/api/v1/api-keys', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setApiKeys(data.api_keys);
      }
    } catch {
      
      toast({
        title: 'Error',
        description: 'Failed to fetch API keys',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  }, [toast]);

  useEffect(() => {
    fetchApiKeys();
  }, [fetchApiKeys]);

  const handleCreateApiKey = async () => {
    try {
      const response = await fetch('/api/v1/api-keys', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
        body: JSON.stringify({
          name: formData.name,
          description: formData.description,
          scopes: formData.scopes,
          expires_in_days: parseInt(formData.expiresIn),
          rate_limit: parseInt(formData.rateLimit),
          ip_whitelist: formData.ipWhitelist
            ? formData.ipWhitelist.split(',').map((ip) => ip.trim())
            : [],
        }),
      });

      if (response.ok) {
        const data = await response.json();
        setNewApiKey(data.api_key);
        setShowKeyDialog(true);
        setShowCreateDialog(false);
        await fetchApiKeys();
        
        // Reset form
        setFormData({
          name: '',
          description: '',
          scopes: [],
          expiresIn: '30',
          rateLimit: '1000',
          ipWhitelist: '',
        });
        
        toast({
          title: 'Success',
          description: 'API key created successfully',
        });
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to create API key',
        variant: 'destructive',
      });
    }
  };

  const handleRevokeKey = async (keyId: string) => {
    try {
      const response = await fetch(`/api/v1/api-keys/${keyId}/revoke`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        toast({
          title: 'Success',
          description: 'API key revoked successfully',
        });
        await fetchApiKeys();
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to revoke API key',
        variant: 'destructive',
      });
    }
  };

  const handleRotateKey = async (keyId: string) => {
    try {
      const response = await fetch(`/api/v1/api-keys/${keyId}/rotate`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setNewApiKey(data.api_key);
        setShowKeyDialog(true);
        toast({
          title: 'Success',
          description: 'API key rotated successfully',
        });
        await fetchApiKeys();
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to rotate API key',
        variant: 'destructive',
      });
    }
  };

  const fetchUsageStats = async (keyId: string) => {
    try {
      const response = await fetch(`/api/v1/api-keys/${keyId}/usage`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setUsageStats(data);
        setShowUsageStats(true);
      }
    } catch {
      
    }
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    toast({
      title: 'Copied',
      description: 'API key copied to clipboard',
    });
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
      case 'revoked':
        return (
          <Badge variant="destructive" className="text-xs">
            <XCircle className="mr-1 h-3 w-3" />
            Revoked
          </Badge>
        );
      case 'expired':
        return (
          <Badge variant="secondary" className="text-xs">
            <Clock className="mr-1 h-3 w-3" />
            Expired
          </Badge>
        );
      default:
        return null;
    }
  };

  const filteredKeys = apiKeys.filter((key) => {
    if (activeTab === 'active') return key.status === 'active';
    if (activeTab === 'revoked') return key.status === 'revoked';
    if (activeTab === 'expired') return key.status === 'expired';
    return true;
  });

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
          <h2 className="text-2xl font-bold tracking-tight">API Keys</h2>
          <p className="text-muted-foreground">
            Manage your API keys for programmatic access
          </p>
        </div>
        <div className="flex space-x-2">
          <Button variant="outline" size="sm" onClick={fetchApiKeys}>
            <RefreshCw className="mr-2 h-4 w-4" />
            Refresh
          </Button>
          <Dialog open={showCreateDialog} onOpenChange={setShowCreateDialog}>
            <DialogTrigger asChild>
              <Button size="sm">
                <Plus className="mr-2 h-4 w-4" />
                Create API Key
              </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[600px]">
              <DialogHeader>
                <DialogTitle>Create New API Key</DialogTitle>
                <DialogDescription>
                  Generate a new API key with specific permissions and settings
                </DialogDescription>
              </DialogHeader>
              <div className="grid gap-4 py-4">
                <div className="grid gap-2">
                  <Label htmlFor="name">Name</Label>
                  <Input
                    id="name"
                    value={formData.name}
                    onChange={(e) =>
                      setFormData({ ...formData, name: e.target.value })
                    }
                    placeholder="Production API Key"
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="description">Description</Label>
                  <Textarea
                    id="description"
                    value={formData.description}
                    onChange={(e) =>
                      setFormData({ ...formData, description: e.target.value })
                    }
                    placeholder="Used for production environment"
                  />
                </div>
                <div className="grid gap-2">
                  <Label>Scopes</Label>
                  <div className="space-y-2 max-h-48 overflow-y-auto">
                    {availableScopes.map((scope) => (
                      <div key={scope.id} className="flex items-start space-x-2">
                        <Checkbox
                          id={scope.id}
                          checked={formData.scopes.includes(scope.id)}
                          onCheckedChange={(checked) => {
                            if (checked) {
                              setFormData({
                                ...formData,
                                scopes: [...formData.scopes, scope.id],
                              });
                            } else {
                              setFormData({
                                ...formData,
                                scopes: formData.scopes.filter(
                                  (s) => s !== scope.id
                                ),
                              });
                            }
                          }}
                        />
                        <div className="flex-1">
                          <label
                            htmlFor={scope.id}
                            className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                          >
                            {scope.name}
                          </label>
                          <p className="text-xs text-muted-foreground">
                            {scope.description}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="grid gap-2">
                    <Label htmlFor="expires">Expires In (days)</Label>
                    <Select
                      value={formData.expiresIn}
                      onValueChange={(value) =>
                        setFormData({ ...formData, expiresIn: value })
                      }
                    >
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="7">7 days</SelectItem>
                        <SelectItem value="30">30 days</SelectItem>
                        <SelectItem value="90">90 days</SelectItem>
                        <SelectItem value="365">1 year</SelectItem>
                        <SelectItem value="0">Never</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="rateLimit">Rate Limit (req/hour)</Label>
                    <Input
                      id="rateLimit"
                      type="number"
                      value={formData.rateLimit}
                      onChange={(e) =>
                        setFormData({ ...formData, rateLimit: e.target.value })
                      }
                    />
                  </div>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="ipWhitelist">
                    IP Whitelist (comma-separated)
                  </Label>
                  <Input
                    id="ipWhitelist"
                    value={formData.ipWhitelist}
                    onChange={(e) =>
                      setFormData({ ...formData, ipWhitelist: e.target.value })
                    }
                    placeholder="192.168.1.1, 10.0.0.0/24"
                  />
                </div>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setShowCreateDialog(false)}>
                  Cancel
                </Button>
                <Button onClick={handleCreateApiKey}>Create API Key</Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      {apiKeys.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <Key className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">No API Keys</h3>
            <p className="text-muted-foreground mb-4">
              Create your first API key to get started
            </p>
            <Button onClick={() => setShowCreateDialog(true)}>
              <Plus className="mr-2 h-4 w-4" />
              Create API Key
            </Button>
          </CardContent>
        </Card>
      ) : (
        <>
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList>
              <TabsTrigger value="active">
                Active ({apiKeys.filter((k) => k.status === 'active').length})
              </TabsTrigger>
              <TabsTrigger value="revoked">
                Revoked ({apiKeys.filter((k) => k.status === 'revoked').length})
              </TabsTrigger>
              <TabsTrigger value="expired">
                Expired ({apiKeys.filter((k) => k.status === 'expired').length})
              </TabsTrigger>
              <TabsTrigger value="all">All ({apiKeys.length})</TabsTrigger>
            </TabsList>

            <TabsContent value={activeTab} className="space-y-4">
              <Card>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Name</TableHead>
                      <TableHead>Key</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Scopes</TableHead>
                      <TableHead>Last Used</TableHead>
                      <TableHead>Usage</TableHead>
                      <TableHead>Expires</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredKeys.map((apiKey) => (
                      <TableRow key={apiKey.id}>
                        <TableCell>
                          <div>
                            <p className="font-medium">{apiKey.name}</p>
                            {apiKey.description && (
                              <p className="text-xs text-muted-foreground">
                                {apiKey.description}
                              </p>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center space-x-2">
                            <code className="text-xs bg-muted px-2 py-1 rounded">
                              {apiKey.prefix}...
                            </code>
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-6 w-6"
                              onClick={() => copyToClipboard(apiKey.key)}
                            >
                              <Copy className="h-3 w-3" />
                            </Button>
                          </div>
                        </TableCell>
                        <TableCell>{getStatusBadge(apiKey.status)}</TableCell>
                        <TableCell>
                          <div className="flex flex-wrap gap-1">
                            {apiKey.scopes.slice(0, 2).map((scope) => (
                              <Badge key={scope} variant="outline" className="text-xs">
                                {scope}
                              </Badge>
                            ))}
                            {apiKey.scopes.length > 2 && (
                              <Badge variant="outline" className="text-xs">
                                +{apiKey.scopes.length - 2}
                              </Badge>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          {apiKey.lastUsedAt ? (
                            <span className="text-xs">
                              {formatDistanceToNow(new Date(apiKey.lastUsedAt))} ago
                            </span>
                          ) : (
                            <span className="text-xs text-muted-foreground">Never</span>
                          )}
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center space-x-1">
                            <Activity className="h-3 w-3 text-muted-foreground" />
                            <span className="text-xs">{apiKey.usageCount}</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          {apiKey.expiresAt ? (
                            <span className="text-xs">
                              {format(new Date(apiKey.expiresAt), 'MMM d, yyyy')}
                            </span>
                          ) : (
                            <span className="text-xs text-muted-foreground">Never</span>
                          )}
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
                                  setSelectedKey(apiKey);
                                  fetchUsageStats(apiKey.id);
                                }}
                              >
                                <BarChart className="mr-2 h-4 w-4" />
                                View Usage
                              </DropdownMenuItem>
                              <DropdownMenuItem
                                onClick={() => handleRotateKey(apiKey.id)}
                                disabled={apiKey.status !== 'active'}
                              >
                                <RefreshCw className="mr-2 h-4 w-4" />
                                Rotate Key
                              </DropdownMenuItem>
                              <DropdownMenuItem
                                className="text-destructive"
                                onClick={() => handleRevokeKey(apiKey.id)}
                                disabled={apiKey.status !== 'active'}
                              >
                                <Trash2 className="mr-2 h-4 w-4" />
                                Revoke Key
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </Card>
            </TabsContent>
          </Tabs>
        </>
      )}

      {/* New API Key Dialog */}
      <Dialog open={showKeyDialog} onOpenChange={setShowKeyDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>API Key Created</DialogTitle>
            <DialogDescription>
              Make sure to copy your API key now. You won&apos;t be able to see it again!
            </DialogDescription>
          </DialogHeader>
          <Alert>
            <AlertTriangle className="h-4 w-4" />
            <AlertTitle>Important</AlertTitle>
            <AlertDescription>
              This is the only time you&apos;ll see this API key. Store it securely.
            </AlertDescription>
          </Alert>
          <div className="space-y-4">
            <div className="p-4 bg-muted rounded-lg">
              <code className="text-sm break-all">{newApiKey}</code>
            </div>
            <Button
              className="w-full"
              onClick={() => {
                copyToClipboard(newApiKey);
                setShowKeyDialog(false);
                setNewApiKey('');
              }}
            >
              <Copy className="mr-2 h-4 w-4" />
              Copy and Close
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Usage Stats Dialog */}
      <Dialog open={showUsageStats} onOpenChange={setShowUsageStats}>
        <DialogContent className="sm:max-w-[700px]">
          <DialogHeader>
            <DialogTitle>API Key Usage Statistics</DialogTitle>
            <DialogDescription>
              {selectedKey?.name} - Usage over the last 30 days
            </DialogDescription>
          </DialogHeader>
          {usageStats && (
            <div className="space-y-4">
              <div className="grid grid-cols-4 gap-4">
                <Card>
                  <CardHeader className="pb-2">
                    <CardDescription>Total Calls</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <p className="text-2xl font-bold">{usageStats.totalCalls}</p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className="pb-2">
                    <CardDescription>Success Rate</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <p className="text-2xl font-bold">
                      {((usageStats.successfulCalls / usageStats.totalCalls) * 100).toFixed(
                        1
                      )}
                      %
                    </p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className="pb-2">
                    <CardDescription>Avg Latency</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <p className="text-2xl font-bold">
                      {usageStats.averageLatency}ms
                    </p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className="pb-2">
                    <CardDescription>Peak Time</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <p className="text-2xl font-bold">{usageStats.peakUsageTime}</p>
                  </CardContent>
                </Card>
              </div>

              <Card>
                <CardHeader>
                  <CardTitle className="text-base">Top Endpoints</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    {usageStats.topEndpoints.map((endpoint, index) => (
                      <div key={index} className="flex justify-between items-center">
                        <code className="text-sm">{endpoint.endpoint}</code>
                        <Badge variant="secondary">{endpoint.count} calls</Badge>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}