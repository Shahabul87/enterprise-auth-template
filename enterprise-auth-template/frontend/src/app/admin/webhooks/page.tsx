'use client';

import { useState, useEffect } from 'react';
import { useRequireAuth } from '@/stores/auth.store';
import AdminLayout from '@/components/admin/admin-layout';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
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
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from '@/components/ui/tabs';
import {
  Zap,
  Plus,
  MoreHorizontal,
  Activity,
  Globe,
  CheckCircle,
  XCircle,
  Clock,
  Send,
  Trash2,
  Eye,
  RefreshCw,
  TrendingUp,
  TrendingDown,
} from 'lucide-react';
import { toast } from 'sonner';

// Types based on backend API
type WebhookEventType = 
  | 'user.created' | 'user.updated' | 'user.deleted' | 'user.login' | 'user.logout'
  | 'organization.created' | 'organization.updated' | 'organization.deleted'
  | 'role.created' | 'role.updated' | 'role.deleted'
  | 'permission.created' | 'permission.updated' | 'permission.deleted'
  | 'session.created' | 'session.expired'
  | 'api_key.created' | 'api_key.updated' | 'api_key.deleted';

type WebhookStatus = 'active' | 'paused' | 'failed' | 'disabled';
type DeliveryStatus = 'pending' | 'success' | 'failed' | 'retrying';

interface WebhookResponse {
  id: string;
  name: string;
  url: string;
  description: string | null;
  events: string[];
  status: WebhookStatus;
  headers: Record<string, string>;
  timeout: number;
  retry_count: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  last_delivery: string | null;
  delivery_success_rate: number;
  total_deliveries: number;
}

interface WebhookCreateRequest {
  name: string;
  url: string;
  description?: string;
  events: WebhookEventType[];
  secret?: string;
  headers?: Record<string, string>;
  timeout: number;
  retry_count: number;
  is_active: boolean;
}

interface WebhookDelivery {
  id: string;
  webhook_id: string;
  event_type: string;
  payload: Record<string, unknown>;
  status: DeliveryStatus;
  http_status: number | null;
  response_body: string | null;
  error_message: string | null;
  attempt_count: number;
  created_at: string;
  delivered_at: string | null;
  next_retry_at: string | null;
}

const WEBHOOK_EVENTS: Record<WebhookEventType, { label: string; description: string; category: string }> = {
  'user.created': { label: 'User Created', description: 'When a new user registers', category: 'User' },
  'user.updated': { label: 'User Updated', description: 'When user profile is modified', category: 'User' },
  'user.deleted': { label: 'User Deleted', description: 'When a user account is deleted', category: 'User' },
  'user.login': { label: 'User Login', description: 'When user successfully logs in', category: 'User' },
  'user.logout': { label: 'User Logout', description: 'When user logs out', category: 'User' },
  'organization.created': { label: 'Organization Created', description: 'When new organization is created', category: 'Organization' },
  'organization.updated': { label: 'Organization Updated', description: 'When organization is modified', category: 'Organization' },
  'organization.deleted': { label: 'Organization Deleted', description: 'When organization is deleted', category: 'Organization' },
  'role.created': { label: 'Role Created', description: 'When new role is created', category: 'Role' },
  'role.updated': { label: 'Role Updated', description: 'When role is modified', category: 'Role' },
  'role.deleted': { label: 'Role Deleted', description: 'When role is deleted', category: 'Role' },
  'permission.created': { label: 'Permission Created', description: 'When new permission is created', category: 'Permission' },
  'permission.updated': { label: 'Permission Updated', description: 'When permission is modified', category: 'Permission' },
  'permission.deleted': { label: 'Permission Deleted', description: 'When permission is deleted', category: 'Permission' },
  'session.created': { label: 'Session Created', description: 'When user session starts', category: 'Session' },
  'session.expired': { label: 'Session Expired', description: 'When user session expires', category: 'Session' },
  'api_key.created': { label: 'API Key Created', description: 'When new API key is created', category: 'API Key' },
  'api_key.updated': { label: 'API Key Updated', description: 'When API key is modified', category: 'API Key' },
  'api_key.deleted': { label: 'API Key Deleted', description: 'When API key is deleted', category: 'API Key' },
};

export default function WebhooksPage(): React.ReactElement {
  const { user } = useRequireAuth();
  const [webhooks, setWebhooks] = useState<WebhookResponse[]>([]);
  const [selectedWebhook, setSelectedWebhook] = useState<WebhookResponse | null>(null);
  const [deliveries, setDeliveries] = useState<WebhookDelivery[]>([]);
  const [loading, setLoading] = useState(true);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [deliveriesDialogOpen, setDeliveriesDialogOpen] = useState(false);
  const [activeTab, setActiveTab] = useState('webhooks');
  const [createForm, setCreateForm] = useState<WebhookCreateRequest>({
    name: '',
    url: '',
    description: '',
    events: [],
    secret: '',
    headers: {},
    timeout: 30,
    retry_count: 3,
    is_active: true,
  });
  const [customHeaders, setCustomHeaders] = useState<Array<{ key: string; value: string }>>([]);

  useEffect(() => {
    loadWebhooks();
  }, []);

  const loadWebhooks = async (): Promise<void> => {
    try {
      setLoading(true);
      // TODO: Replace with actual API call
      const mockData: WebhookResponse[] = [
        {
          id: '1',
          name: 'User Activity Webhook',
          url: 'https://api.example.com/webhooks/user-activity',
          description: 'Receives user activity events for analytics',
          events: ['user.created', 'user.updated', 'user.login'],
          status: 'active',
          headers: { 'X-Source': 'enterprise-auth' },
          timeout: 30,
          retry_count: 3,
          is_active: true,
          created_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 30).toISOString(),
          updated_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 7).toISOString(),
          last_delivery: new Date(Date.now() - 1000 * 60 * 30).toISOString(),
          delivery_success_rate: 0.95,
          total_deliveries: 342,
        },
        {
          id: '2',
          name: 'Organization Events',
          url: 'https://hooks.slack.com/services/xxx/yyy/zzz',
          description: 'Slack notifications for organization changes',
          events: ['organization.created', 'organization.updated'],
          status: 'active',
          headers: {},
          timeout: 15,
          retry_count: 2,
          is_active: true,
          created_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 15).toISOString(),
          updated_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 3).toISOString(),
          last_delivery: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString(),
          delivery_success_rate: 1.0,
          total_deliveries: 28,
        },
        {
          id: '3',
          name: 'Security Alerts',
          url: 'https://api.securitytool.com/webhooks',
          description: 'Security-related events and alerts',
          events: ['user.login', 'api_key.created', 'role.updated'],
          status: 'failed',
          headers: { 'Authorization': 'Bearer ***' },
          timeout: 45,
          retry_count: 5,
          is_active: false,
          created_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 45).toISOString(),
          updated_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 1).toISOString(),
          last_delivery: new Date(Date.now() - 1000 * 60 * 60 * 24 * 2).toISOString(),
          delivery_success_rate: 0.73,
          total_deliveries: 156,
        },
      ];
      setWebhooks(mockData);
    } catch {
      toast.error('Failed to load webhooks');
    } finally {
      setLoading(false);
    }
  };

  const loadWebhookDeliveries = async (webhookId: string): Promise<void> => {
    try {
      // TODO: Replace with actual API call
      const mockDeliveries: WebhookDelivery[] = [
        {
          id: '1',
          webhook_id: webhookId,
          event_type: 'user.created',
          payload: { user_id: 'user123', email: 'user@example.com', name: 'John Doe' },
          status: 'success',
          http_status: 200,
          response_body: '{"status":"ok"}',
          error_message: null,
          attempt_count: 1,
          created_at: new Date(Date.now() - 1000 * 60 * 30).toISOString(),
          delivered_at: new Date(Date.now() - 1000 * 60 * 30).toISOString(),
          next_retry_at: null,
        },
        {
          id: '2',
          webhook_id: webhookId,
          event_type: 'user.login',
          payload: { user_id: 'user456', ip_address: '192.168.1.1', timestamp: new Date().toISOString() },
          status: 'failed',
          http_status: 500,
          response_body: '{"error":"Internal Server Error"}',
          error_message: 'Connection timeout',
          attempt_count: 3,
          created_at: new Date(Date.now() - 1000 * 60 * 60).toISOString(),
          delivered_at: null,
          next_retry_at: new Date(Date.now() + 1000 * 60 * 15).toISOString(),
        },
        {
          id: '3',
          webhook_id: webhookId,
          event_type: 'user.updated',
          payload: { user_id: 'user789', changes: ['email', 'name'] },
          status: 'retrying',
          http_status: null,
          response_body: null,
          error_message: 'Network timeout',
          attempt_count: 2,
          created_at: new Date(Date.now() - 1000 * 60 * 45).toISOString(),
          delivered_at: null,
          next_retry_at: new Date(Date.now() + 1000 * 60 * 5).toISOString(),
        },
      ];
      setDeliveries(mockDeliveries);
    } catch {
      toast.error('Failed to load webhook deliveries');
    }
  };

  const handleCreateWebhook = async (): Promise<void> => {
    try {
      if (!createForm.name.trim()) {
        toast.error('Webhook name is required');
        return;
      }

      if (!createForm.url.trim()) {
        toast.error('Webhook URL is required');
        return;
      }

      if (createForm.events.length === 0) {
        toast.error('At least one event must be selected');
        return;
      }

      // Convert custom headers array to object
      const headers = customHeaders.reduce((acc, header) => {
        if (header.key && header.value) {
          acc[header.key] = header.value;
        }
        return acc;
      }, {} as Record<string, string>);

      const requestData = {
        ...createForm,
        headers,
      };

      // TODO: Replace with actual API call
      const newWebhook: WebhookResponse = {
        id: String(webhooks.length + 1),
        name: requestData.name,
        url: requestData.url,
        description: requestData.description || null,
        events: requestData.events as string[],
        status: 'active',
        headers: requestData.headers || {},
        timeout: requestData.timeout,
        retry_count: requestData.retry_count,
        is_active: requestData.is_active,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        last_delivery: null,
        delivery_success_rate: 0,
        total_deliveries: 0,
      };

      setWebhooks(prev => [...prev, newWebhook]);
      setCreateDialogOpen(false);
      
      // Reset form
      setCreateForm({
        name: '',
        url: '',
        description: '',
        events: [],
        secret: '',
        headers: {},
        timeout: 30,
        retry_count: 3,
        is_active: true,
      });
      setCustomHeaders([]);
      
      toast.success('Webhook created successfully');
    } catch {
      toast.error('Failed to create webhook');
    }
  };

  const handleToggleWebhook = async (webhookId: string, isActive: boolean): Promise<void> => {
    try {
      // TODO: Replace with actual API call
      setWebhooks(prev => 
        prev.map(webhook => 
          webhook.id === webhookId ? { ...webhook, is_active: !isActive } : webhook
        )
      );
      toast.success(isActive ? 'Webhook disabled' : 'Webhook enabled');
    } catch {
      toast.error('Failed to update webhook');
    }
  };

  const handleDeleteWebhook = async (webhookId: string): Promise<void> => {
    try {
      // TODO: Replace with actual API call
      setWebhooks(prev => prev.filter(webhook => webhook.id !== webhookId));
      toast.success('Webhook deleted');
    } catch {
      toast.error('Failed to delete webhook');
    }
  };

  const handleTestWebhook = async (webhook?: WebhookResponse | Record<string, unknown>): Promise<void> => {
    // Use webhook parameter if needed
    webhook;
    try {
      // TODO: Replace with actual API call
      toast.success('Test webhook delivery initiated');
    } catch {
      toast.error('Failed to test webhook');
    }
  };

  const handleViewDeliveries = (webhook: WebhookResponse): void => {
    setSelectedWebhook(webhook);
    loadWebhookDeliveries(webhook.id);
    setDeliveriesDialogOpen(true);
  };

  const addCustomHeader = (): void => {
    setCustomHeaders(prev => [...prev, { key: '', value: '' }]);
  };

  const updateCustomHeader = (index: number, field: 'key' | 'value', value: string): void => {
    setCustomHeaders(prev => 
      prev.map((header, i) => 
        i === index ? { ...header, [field]: value } : header
      )
    );
  };

  const removeCustomHeader = (index: number): void => {
    setCustomHeaders(prev => prev.filter((_, i) => i !== index));
  };

  const formatDate = (dateString: string | null): string => {
    if (!dateString) return 'Never';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const getStatusIcon = (status: WebhookStatus): React.ReactElement => {
    switch (status) {
      case 'active':
        return <CheckCircle className="h-4 w-4 text-green-500" />;
      case 'paused':
        return <Clock className="h-4 w-4 text-yellow-500" />;
      case 'failed':
        return <XCircle className="h-4 w-4 text-red-500" />;
      case 'disabled':
        return <XCircle className="h-4 w-4 text-gray-500" />;
      default:
        return <Clock className="h-4 w-4" />;
    }
  };

  const getDeliveryStatusIcon = (status: DeliveryStatus): React.ReactElement => {
    switch (status) {
      case 'success':
        return <CheckCircle className="h-4 w-4 text-green-500" />;
      case 'failed':
        return <XCircle className="h-4 w-4 text-red-500" />;
      case 'retrying':
        return <RefreshCw className="h-4 w-4 text-yellow-500" />;
      case 'pending':
        return <Clock className="h-4 w-4 text-blue-500" />;
      default:
        return <Clock className="h-4 w-4" />;
    }
  };

  const groupEventsByCategory = (): Record<string, WebhookEventType[]> => {
    return Object.entries(WEBHOOK_EVENTS).reduce((acc, [event, info]) => {
      if (!acc[info?.category]) {
        acc[info?.category] = [];
      }
      acc[info?.category]?.push(event as WebhookEventType);
      return acc;
    }, {} as Record<string, WebhookEventType[]>);
  };

  if (!user) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
        </div>
      </AdminLayout>
    );
  }

  if (loading) {
    return (
      <AdminLayout>
        <Card>
          <CardContent className="py-12 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto mb-4"></div>
            <p className="text-muted-foreground">Loading webhooks...</p>
          </CardContent>
        </Card>
      </AdminLayout>
    );
  }

  const eventsByCategory = groupEventsByCategory();

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2">
                  <Zap className="h-5 w-5" />
                  Webhooks Management
                </CardTitle>
                <CardDescription>
                  Configure webhooks to receive real-time notifications about events in your application.
                  Webhooks allow external systems to stay in sync with your data.
                </CardDescription>
              </div>
              <Dialog open={createDialogOpen} onOpenChange={setCreateDialogOpen}>
                <DialogTrigger asChild>
                  <Button>
                    <Plus className="h-4 w-4 mr-2" />
                    Create Webhook
                  </Button>
                </DialogTrigger>
                <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
                  <DialogHeader>
                    <DialogTitle>Create New Webhook</DialogTitle>
                    <DialogDescription>
                      Configure a webhook to receive event notifications from the application.
                    </DialogDescription>
                  </DialogHeader>
                  
                  <div className="space-y-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="name">Name *</Label>
                        <Input
                          id="name"
                          placeholder="User Activity Webhook"
                          value={createForm.name}
                          onChange={(e) => setCreateForm(prev => ({ ...prev, name: e.target.value }))}
                        />
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="url">Endpoint URL *</Label>
                        <Input
                          id="url"
                          placeholder="https://api.example.com/webhooks"
                          value={createForm.url}
                          onChange={(e) => setCreateForm(prev => ({ ...prev, url: e.target.value }))}
                        />
                      </div>
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="description">Description</Label>
                      <Textarea
                        id="description"
                        placeholder="What will this webhook be used for?"
                        value={createForm.description}
                        onChange={(e) => setCreateForm(prev => ({ ...prev, description: e.target.value }))}
                        rows={3}
                      />
                    </div>

                    <div className="space-y-3">
                      <Label>Event Types *</Label>
                      <div className="space-y-4">
                        {Object.entries(eventsByCategory).map(([category, events]) => (
                          <div key={category} className="space-y-2">
                            <h4 className="text-sm font-medium text-muted-foreground">{category} Events</h4>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                              {events.map((event) => (
                                <div key={event} className="flex items-start space-x-3">
                                  <Checkbox
                                    id={event}
                                    checked={createForm.events.includes(event)}
                                    onCheckedChange={(checked) => {
                                      setCreateForm(prev => ({
                                        ...prev,
                                        events: checked
                                          ? [...prev.events, event]
                                          : prev.events.filter(e => e !== event),
                                      }));
                                    }}
                                  />
                                  <div className="space-y-1">
                                    <Label htmlFor={event} className="text-sm font-medium cursor-pointer">
                                      {WEBHOOK_EVENTS[event].label}
                                    </Label>
                                    <p className="text-xs text-muted-foreground">
                                      {WEBHOOK_EVENTS[event].description}
                                    </p>
                                  </div>
                                </div>
                              ))}
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="timeout">Timeout (seconds)</Label>
                        <Input
                          id="timeout"
                          type="number"
                          min="5"
                          max="120"
                          value={createForm.timeout}
                          onChange={(e) => setCreateForm(prev => ({ 
                            ...prev, 
                            timeout: parseInt(e.target.value) || 30 
                          }))}
                        />
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="retry_count">Retry Count</Label>
                        <Input
                          id="retry_count"
                          type="number"
                          min="0"
                          max="10"
                          value={createForm.retry_count}
                          onChange={(e) => setCreateForm(prev => ({ 
                            ...prev, 
                            retry_count: parseInt(e.target.value) || 3 
                          }))}
                        />
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="secret">Secret Key</Label>
                        <Input
                          id="secret"
                          placeholder="Optional HMAC secret"
                          type="password"
                          value={createForm.secret}
                          onChange={(e) => setCreateForm(prev => ({ ...prev, secret: e.target.value }))}
                        />
                      </div>
                    </div>

                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <Label>Custom Headers</Label>
                        <Button type="button" variant="outline" size="sm" onClick={addCustomHeader}>
                          <Plus className="h-3 w-3 mr-1" />
                          Add Header
                        </Button>
                      </div>
                      <div className="space-y-2">
                        {customHeaders.map((header, index) => (
                          <div key={index} className="flex gap-2">
                            <Input
                              placeholder="Header name"
                              value={header.key}
                              onChange={(e) => updateCustomHeader(index, 'key', e.target.value)}
                            />
                            <Input
                              placeholder="Header value"
                              value={header.value}
                              onChange={(e) => updateCustomHeader(index, 'value', e.target.value)}
                            />
                            <Button
                              type="button"
                              variant="outline"
                              size="sm"
                              onClick={() => removeCustomHeader(index)}
                            >
                              <Trash2 className="h-3 w-3" />
                            </Button>
                          </div>
                        ))}
                      </div>
                    </div>

                    <div className="flex items-center space-x-2">
                      <Switch
                        id="is_active"
                        checked={createForm.is_active}
                        onCheckedChange={(checked) => setCreateForm(prev => ({ ...prev, is_active: checked }))}
                      />
                      <Label htmlFor="is_active">Active</Label>
                    </div>
                  </div>

                  <DialogFooter>
                    <Button variant="outline" onClick={() => setCreateDialogOpen(false)}>
                      Cancel
                    </Button>
                    <Button onClick={handleCreateWebhook}>
                      Create Webhook
                    </Button>
                  </DialogFooter>
                </DialogContent>
              </Dialog>
            </div>
          </CardHeader>
        </Card>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
          <TabsList>
            <TabsTrigger value="webhooks" className="flex items-center gap-2">
              <Zap className="h-4 w-4" />
              Webhooks ({webhooks.length})
            </TabsTrigger>
            <TabsTrigger value="stats" className="flex items-center gap-2">
              <Activity className="h-4 w-4" />
              Statistics
            </TabsTrigger>
          </TabsList>

          <TabsContent value="webhooks" className="space-y-4">
            {webhooks.length === 0 ? (
              <Card>
                <CardContent className="py-12 text-center">
                  <Zap className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-muted-foreground mb-2">No webhooks configured</h3>
                  <p className="text-sm text-muted-foreground mb-4">
                    Create your first webhook to start receiving event notifications.
                  </p>
                  <Button onClick={() => setCreateDialogOpen(true)}>
                    <Plus className="h-4 w-4 mr-2" />
                    Create Your First Webhook
                  </Button>
                </CardContent>
              </Card>
            ) : (
              <Card>
                <CardHeader>
                  <CardTitle>Configured Webhooks</CardTitle>
                </CardHeader>
                <CardContent>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Name</TableHead>
                        <TableHead>URL</TableHead>
                        <TableHead>Events</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Success Rate</TableHead>
                        <TableHead>Last Delivery</TableHead>
                        <TableHead></TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {webhooks.map((webhook) => (
                        <TableRow key={webhook.id}>
                          <TableCell>
                            <div>
                              <div className="font-medium">{webhook.name}</div>
                              {webhook.description && (
                                <div className="text-sm text-muted-foreground max-w-xs truncate">
                                  {webhook.description}
                                </div>
                              )}
                            </div>
                          </TableCell>
                          <TableCell>
                            <div className="flex items-center gap-2">
                              <Globe className="h-3 w-3 text-muted-foreground" />
                              <code className="text-sm max-w-xs truncate">{webhook.url}</code>
                            </div>
                          </TableCell>
                          <TableCell>
                            <div className="flex flex-wrap gap-1 max-w-xs">
                              {webhook.events.slice(0, 2).map((event) => (
                                <Badge key={event} variant="secondary" className="text-xs">
                                  {event}
                                </Badge>
                              ))}
                              {webhook.events.length > 2 && (
                                <Badge variant="secondary" className="text-xs">
                                  +{webhook.events.length - 2} more
                                </Badge>
                              )}
                            </div>
                          </TableCell>
                          <TableCell>
                            <div className="flex items-center gap-2">
                              {getStatusIcon(webhook.status)}
                              <span className="text-sm capitalize">{webhook.status}</span>
                              <Switch
                                checked={webhook.is_active}
                                onCheckedChange={() => handleToggleWebhook(webhook.id, webhook.is_active)}
                              />
                            </div>
                          </TableCell>
                          <TableCell>
                            <div className="flex items-center gap-2">
                              {webhook.delivery_success_rate >= 0.9 ? (
                                <TrendingUp className="h-4 w-4 text-green-500" />
                              ) : webhook.delivery_success_rate >= 0.7 ? (
                                <TrendingUp className="h-4 w-4 text-yellow-500" />
                              ) : (
                                <TrendingDown className="h-4 w-4 text-red-500" />
                              )}
                              <span className="text-sm">
                                {Math.round(webhook.delivery_success_rate * 100)}%
                              </span>
                              <span className="text-xs text-muted-foreground">
                                ({webhook.total_deliveries})
                              </span>
                            </div>
                          </TableCell>
                          <TableCell className="text-sm text-muted-foreground">
                            {formatDate(webhook.last_delivery)}
                          </TableCell>
                          <TableCell>
                            <DropdownMenu>
                              <DropdownMenuTrigger asChild>
                                <Button variant="ghost" size="sm">
                                  <MoreHorizontal className="h-4 w-4" />
                                </Button>
                              </DropdownMenuTrigger>
                              <DropdownMenuContent align="end">
                                <DropdownMenuItem onClick={() => handleViewDeliveries(webhook)}>
                                  <Eye className="h-4 w-4 mr-2" />
                                  View Deliveries
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={() => handleTestWebhook(webhook)}>
                                  <Send className="h-4 w-4 mr-2" />
                                  Test Webhook
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                  onClick={() => handleDeleteWebhook(webhook.id)}
                                  className="text-destructive"
                                >
                                  <Trash2 className="h-4 w-4 mr-2" />
                                  Delete
                                </DropdownMenuItem>
                              </DropdownMenuContent>
                            </DropdownMenu>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </CardContent>
              </Card>
            )}
          </TabsContent>

          <TabsContent value="stats" className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <Card>
                <CardContent className="p-6 text-center">
                  <div className="text-2xl font-bold text-primary">{webhooks.length}</div>
                  <div className="text-sm text-muted-foreground">Total Webhooks</div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-6 text-center">
                  <div className="text-2xl font-bold text-green-600">
                    {webhooks.filter(w => w.is_active).length}
                  </div>
                  <div className="text-sm text-muted-foreground">Active Webhooks</div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-6 text-center">
                  <div className="text-2xl font-bold text-blue-600">
                    {webhooks.reduce((sum, w) => sum + w.total_deliveries, 0).toLocaleString()}
                  </div>
                  <div className="text-sm text-muted-foreground">Total Deliveries</div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-6 text-center">
                  <div className="text-2xl font-bold text-purple-600">
                    {webhooks.length > 0 
                      ? Math.round((webhooks.reduce((sum, w) => sum + w.delivery_success_rate, 0) / webhooks.length) * 100)
                      : 0}%
                  </div>
                  <div className="text-sm text-muted-foreground">Avg Success Rate</div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>
        </Tabs>

        {/* Deliveries Dialog */}
        <Dialog open={deliveriesDialogOpen} onOpenChange={setDeliveriesDialogOpen}>
          <DialogContent className="max-w-6xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle className="flex items-center gap-2">
                <Activity className="h-5 w-5" />
                {selectedWebhook?.name} - Recent Deliveries
              </DialogTitle>
              <DialogDescription>
                View recent webhook delivery attempts and their status.
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-4">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Event</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>HTTP Status</TableHead>
                    <TableHead>Attempts</TableHead>
                    <TableHead>Created</TableHead>
                    <TableHead>Next Retry</TableHead>
                    <TableHead></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {deliveries.map((delivery) => (
                    <TableRow key={delivery.id}>
                      <TableCell>
                        <Badge variant="outline">{delivery.event_type}</Badge>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          {getDeliveryStatusIcon(delivery.status)}
                          <span className="text-sm capitalize">{delivery.status}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        {delivery.http_status ? (
                          <Badge 
                            variant={delivery.http_status < 300 ? "default" : "destructive"}
                          >
                            {delivery.http_status}
                          </Badge>
                        ) : '-'}
                      </TableCell>
                      <TableCell>{delivery.attempt_count}</TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {formatDate(delivery.created_at)}
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {delivery.next_retry_at ? formatDate(delivery.next_retry_at) : '-'}
                      </TableCell>
                      <TableCell>
                        <Button variant="ghost" size="sm">
                          <Eye className="h-4 w-4" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>

            <DialogFooter>
              <Button onClick={() => setDeliveriesDialogOpen(false)}>Close</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  );
}