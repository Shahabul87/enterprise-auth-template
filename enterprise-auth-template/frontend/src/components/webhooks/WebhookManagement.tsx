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
import { Switch } from '@/components/ui/switch';
import { Textarea } from '@/components/ui/textarea';
import { ScrollArea } from '@/components/ui/scroll-area';
import {
  Webhook,
  Plus,
  Copy,
  MoreVertical,
  Send,
  AlertTriangle,
  CheckCircle,
  XCircle,
  RefreshCw,
  Trash2,
  // Activity,
  Clock,
  Info,
  // PlayCircle,
  // PauseCircle,
  RotateCw,
  Zap,
  // Shield,
  // Link,
  Code,
  // FileText,
  // ArrowRight,
} from 'lucide-react';
import { formatDistanceToNow, format } from 'date-fns';
import { useToast } from '@/components/ui/use-toast';

interface WebhookEndpoint {
  id: string;
  name: string;
  url: string;
  secret?: string;
  events: string[];
  status: 'active' | 'inactive' | 'failed';
  enabled: boolean;
  description?: string;
  headers?: Record<string, string>;
  retryPolicy: {
    maxRetries: number;
    retryDelay: number;
    backoffMultiplier: number;
  };
  createdAt: string;
  lastTriggeredAt?: string;
  successCount: number;
  failureCount: number;
  averageResponseTime?: number;
}

interface WebhookEvent {
  id: string;
  name: string;
  category: string;
  description: string;
  samplePayload: Record<string, unknown>;
}

interface WebhookDelivery {
  id: string;
  webhookId: string;
  event: string;
  status: 'pending' | 'success' | 'failed';
  statusCode?: number;
  responseTime?: number;
  error?: string;
  payload: Record<string, unknown>;
  response?: string;
  attempts: number;
  createdAt: string;
  completedAt?: string;
}

const availableEvents: WebhookEvent[] = [
  {
    id: 'user.created',
    name: 'User Created',
    category: 'Users',
    description: 'Triggered when a new user is created',
    samplePayload: {
      event: 'user.created',
      data: {
        userId: 'usr_123',
        email: 'user@example.com',
        createdAt: '2024-01-01T00:00:00Z',
      },
    },
  },
  {
    id: 'user.updated',
    name: 'User Updated',
    category: 'Users',
    description: 'Triggered when user information is updated',
    samplePayload: {
      event: 'user.updated',
      data: {
        userId: 'usr_123',
        changes: ['email', 'profile'],
        updatedAt: '2024-01-01T00:00:00Z',
      },
    },
  },
  {
    id: 'auth.login',
    name: 'User Login',
    category: 'Authentication',
    description: 'Triggered when a user logs in',
    samplePayload: {
      event: 'auth.login',
      data: {
        userId: 'usr_123',
        method: 'password',
        ip: '192.168.1.1',
        timestamp: '2024-01-01T00:00:00Z',
      },
    },
  },
  {
    id: 'auth.logout',
    name: 'User Logout',
    category: 'Authentication',
    description: 'Triggered when a user logs out',
    samplePayload: {
      event: 'auth.logout',
      data: {
        userId: 'usr_123',
        sessionId: 'sess_456',
        timestamp: '2024-01-01T00:00:00Z',
      },
    },
  },
  {
    id: 'security.alert',
    name: 'Security Alert',
    category: 'Security',
    description: 'Triggered on security events',
    samplePayload: {
      event: 'security.alert',
      data: {
        type: 'suspicious_login',
        userId: 'usr_123',
        details: 'Multiple failed login attempts',
        severity: 'high',
      },
    },
  },
];

export default function WebhookManagement() {
  const [webhooks, setWebhooks] = useState<WebhookEndpoint[]>([]);
  const [deliveries, setDeliveries] = useState<WebhookDelivery[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreateDialog, setShowCreateDialog] = useState(false);
  const [showTestDialog, setShowTestDialog] = useState(false);
  const [showDeliveryDialog, setShowDeliveryDialog] = useState(false);
  const [selectedWebhook, setSelectedWebhook] = useState<WebhookEndpoint | null>(null);
  const [selectedDelivery, setSelectedDelivery] = useState<WebhookDelivery | null>(null);
  const [activeTab, setActiveTab] = useState('endpoints');
  const { toast } = useToast();

  // Form state for creating new webhook
  const [formData, setFormData] = useState({
    name: '',
    url: '',
    description: '',
    events: [] as string[],
    secret: '',
    headers: '',
    maxRetries: '3',
    retryDelay: '1000',
    backoffMultiplier: '2',
  });

  // Test event state
  const [testEvent, setTestEvent] = useState('user.created');
  const [testPayload, setTestPayload] = useState('');

  const fetchWebhooks = useCallback(async () => {
    try {
      const response = await fetch('/api/v1/webhooks', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setWebhooks(data.webhooks);
      }
    } catch {
      
      toast({
        title: 'Error',
        description: 'Failed to fetch webhooks',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  }, [toast]);

  const fetchDeliveries = useCallback(async () => {
    try {
      const response = await fetch('/api/v1/webhooks/deliveries', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setDeliveries(data.deliveries);
      }
    } catch {
      
    }
  }, []);

  useEffect(() => {
    fetchWebhooks();
    fetchDeliveries();
  }, [fetchWebhooks, fetchDeliveries]);

  const handleCreateWebhook = async () => {
    try {
      const headers = formData.headers
        ? JSON.parse(formData.headers)
        : undefined;

      const response = await fetch('/api/v1/webhooks', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
        body: JSON.stringify({
          name: formData.name,
          url: formData.url,
          description: formData.description,
          events: formData.events,
          secret: formData.secret || undefined,
          headers,
          retry_policy: {
            max_retries: parseInt(formData.maxRetries),
            retry_delay: parseInt(formData.retryDelay),
            backoff_multiplier: parseFloat(formData.backoffMultiplier),
          },
        }),
      });

      if (response.ok) {
        toast({
          title: 'Success',
          description: 'Webhook created successfully',
        });
        setShowCreateDialog(false);
        await fetchWebhooks();
        
        // Reset form
        setFormData({
          name: '',
          url: '',
          description: '',
          events: [],
          secret: '',
          headers: '',
          maxRetries: '3',
          retryDelay: '1000',
          backoffMultiplier: '2',
        });
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to create webhook',
        variant: 'destructive',
      });
    }
  };

  const handleToggleWebhook = async (webhookId: string, enabled: boolean) => {
    try {
      const response = await fetch(`/api/v1/webhooks/${webhookId}/toggle`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
        body: JSON.stringify({ enabled }),
      });

      if (response.ok) {
        toast({
          title: 'Success',
          description: `Webhook ${enabled ? 'enabled' : 'disabled'} successfully`,
        });
        await fetchWebhooks();
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to toggle webhook',
        variant: 'destructive',
      });
    }
  };

  const handleDeleteWebhook = async (webhookId: string) => {
    try {
      const response = await fetch(`/api/v1/webhooks/${webhookId}`, {
        method: 'DELETE',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        toast({
          title: 'Success',
          description: 'Webhook deleted successfully',
        });
        await fetchWebhooks();
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to delete webhook',
        variant: 'destructive',
      });
    }
  };

  const handleTestWebhook = async () => {
    if (!selectedWebhook) return;

    try {
      const payload = testPayload
        ? JSON.parse(testPayload)
        : availableEvents.find(e => e.id === testEvent)?.samplePayload;

      const response = await fetch(`/api/v1/webhooks/${selectedWebhook.id}/test`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
        body: JSON.stringify({
          event: testEvent,
          payload,
        }),
      });

      if (response.ok) {
        const data = await response.json();
        toast({
          title: 'Test Sent',
          description: `Status: ${data.status}, Response Time: ${data.response_time}ms`,
        });
        setShowTestDialog(false);
        await fetchDeliveries();
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to test webhook',
        variant: 'destructive',
      });
    }
  };

  const handleRetryDelivery = async (deliveryId: string) => {
    try {
      const response = await fetch(`/api/v1/webhooks/deliveries/${deliveryId}/retry`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        toast({
          title: 'Success',
          description: 'Delivery retry initiated',
        });
        await fetchDeliveries();
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to retry delivery',
        variant: 'destructive',
      });
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'active':
      case 'success':
        return (
          <Badge variant="success" className="text-xs">
            <CheckCircle className="mr-1 h-3 w-3" />
            {status.charAt(0).toUpperCase() + status.slice(1)}
          </Badge>
        );
      case 'inactive':
      case 'pending':
        return (
          <Badge variant="secondary" className="text-xs">
            <Clock className="mr-1 h-3 w-3" />
            {status.charAt(0).toUpperCase() + status.slice(1)}
          </Badge>
        );
      case 'failed':
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

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    toast({
      title: 'Copied',
      description: 'Copied to clipboard',
    });
  };

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
          <h2 className="text-2xl font-bold tracking-tight">Webhooks</h2>
          <p className="text-muted-foreground">
            Configure webhooks to receive real-time event notifications
          </p>
        </div>
        <div className="flex space-x-2">
          <Button variant="outline" size="sm" onClick={() => {
            fetchWebhooks();
            fetchDeliveries();
          }}>
            <RefreshCw className="mr-2 h-4 w-4" />
            Refresh
          </Button>
          <Dialog open={showCreateDialog} onOpenChange={setShowCreateDialog}>
            <DialogTrigger asChild>
              <Button size="sm">
                <Plus className="mr-2 h-4 w-4" />
                Add Webhook
              </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[600px]">
              <DialogHeader>
                <DialogTitle>Create Webhook Endpoint</DialogTitle>
                <DialogDescription>
                  Configure a new webhook endpoint to receive event notifications
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
                    placeholder="Production Webhook"
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="url">URL</Label>
                  <Input
                    id="url"
                    type="url"
                    value={formData.url}
                    onChange={(e) =>
                      setFormData({ ...formData, url: e.target.value })
                    }
                    placeholder="https://example.com/webhook"
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
                    placeholder="Webhook for production environment"
                  />
                </div>
                <div className="grid gap-2">
                  <Label>Events</Label>
                  <ScrollArea className="h-48 border rounded-md p-2">
                    <div className="space-y-2">
                      {availableEvents.map((event) => (
                        <div key={event.id} className="flex items-start space-x-2">
                          <Checkbox
                            id={event.id}
                            checked={formData.events.includes(event.id)}
                            onCheckedChange={(checked) => {
                              if (checked) {
                                setFormData({
                                  ...formData,
                                  events: [...formData.events, event.id],
                                });
                              } else {
                                setFormData({
                                  ...formData,
                                  events: formData.events.filter(
                                    (e) => e !== event.id
                                  ),
                                });
                              }
                            }}
                          />
                          <div className="flex-1">
                            <label
                              htmlFor={event.id}
                              className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                            >
                              {event.name}
                            </label>
                            <p className="text-xs text-muted-foreground">
                              {event.description}
                            </p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </ScrollArea>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="secret">Secret (optional)</Label>
                  <Input
                    id="secret"
                    type="password"
                    value={formData.secret}
                    onChange={(e) =>
                      setFormData({ ...formData, secret: e.target.value })
                    }
                    placeholder="Webhook signing secret"
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="headers">
                    Custom Headers (JSON, optional)
                  </Label>
                  <Textarea
                    id="headers"
                    value={formData.headers}
                    onChange={(e) =>
                      setFormData({ ...formData, headers: e.target.value })
                    }
                    placeholder='{"X-Custom-Header": "value"}'
                    className="font-mono text-sm"
                  />
                </div>
                <div className="grid grid-cols-3 gap-4">
                  <div className="grid gap-2">
                    <Label htmlFor="maxRetries">Max Retries</Label>
                    <Input
                      id="maxRetries"
                      type="number"
                      value={formData.maxRetries}
                      onChange={(e) =>
                        setFormData({ ...formData, maxRetries: e.target.value })
                      }
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="retryDelay">Retry Delay (ms)</Label>
                    <Input
                      id="retryDelay"
                      type="number"
                      value={formData.retryDelay}
                      onChange={(e) =>
                        setFormData({ ...formData, retryDelay: e.target.value })
                      }
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="backoffMultiplier">Backoff</Label>
                    <Input
                      id="backoffMultiplier"
                      type="number"
                      step="0.1"
                      value={formData.backoffMultiplier}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          backoffMultiplier: e.target.value,
                        })
                      }
                    />
                  </div>
                </div>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setShowCreateDialog(false)}>
                  Cancel
                </Button>
                <Button onClick={handleCreateWebhook}>Create Webhook</Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="endpoints">
            Endpoints ({webhooks.length})
          </TabsTrigger>
          <TabsTrigger value="deliveries">
            Recent Deliveries ({deliveries.length})
          </TabsTrigger>
          <TabsTrigger value="events">
            Available Events
          </TabsTrigger>
        </TabsList>

        <TabsContent value="endpoints" className="space-y-4">
          {webhooks.length === 0 ? (
            <Card>
              <CardContent className="py-12 text-center">
                <Webhook className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
                <h3 className="text-lg font-semibold mb-2">No Webhooks</h3>
                <p className="text-muted-foreground mb-4">
                  Create your first webhook to receive event notifications
                </p>
                <Button onClick={() => setShowCreateDialog(true)}>
                  <Plus className="mr-2 h-4 w-4" />
                  Add Webhook
                </Button>
              </CardContent>
            </Card>
          ) : (
            <div className="space-y-4">
              {webhooks.map((webhook) => (
                <Card key={webhook.id}>
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4">
                        <div
                          className={`h-2 w-2 rounded-full ${
                            webhook.enabled ? 'bg-green-500' : 'bg-gray-400'
                          }`}
                        />
                        <div>
                          <CardTitle className="text-base">{webhook.name}</CardTitle>
                          <CardDescription className="text-xs">
                            {webhook.url}
                          </CardDescription>
                        </div>
                      </div>
                      <div className="flex items-center space-x-2">
                        {getStatusBadge(webhook.status)}
                        <Switch
                          checked={webhook.enabled}
                          onCheckedChange={(checked) =>
                            handleToggleWebhook(webhook.id, checked)
                          }
                        />
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
                                setSelectedWebhook(webhook);
                                setShowTestDialog(true);
                              }}
                            >
                              <Send className="mr-2 h-4 w-4" />
                              Test Webhook
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => copyToClipboard(webhook.url)}
                            >
                              <Copy className="mr-2 h-4 w-4" />
                              Copy URL
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              className="text-destructive"
                              onClick={() => handleDeleteWebhook(webhook.id)}
                            >
                              <Trash2 className="mr-2 h-4 w-4" />
                              Delete
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      {webhook.description && (
                        <p className="text-sm text-muted-foreground">
                          {webhook.description}
                        </p>
                      )}
                      <div className="flex flex-wrap gap-2">
                        {webhook.events.map((event) => (
                          <Badge key={event} variant="outline" className="text-xs">
                            {event}
                          </Badge>
                        ))}
                      </div>
                      <div className="grid grid-cols-4 gap-4 text-sm">
                        <div>
                          <p className="text-muted-foreground">Success Rate</p>
                          <p className="font-medium">
                            {webhook.successCount + webhook.failureCount > 0
                              ? `${(
                                  (webhook.successCount /
                                    (webhook.successCount + webhook.failureCount)) *
                                  100
                                ).toFixed(1)}%`
                              : 'N/A'}
                          </p>
                        </div>
                        <div>
                          <p className="text-muted-foreground">Total Calls</p>
                          <p className="font-medium">
                            {webhook.successCount + webhook.failureCount}
                          </p>
                        </div>
                        <div>
                          <p className="text-muted-foreground">Avg Response</p>
                          <p className="font-medium">
                            {webhook.averageResponseTime
                              ? `${webhook.averageResponseTime}ms`
                              : 'N/A'}
                          </p>
                        </div>
                        <div>
                          <p className="text-muted-foreground">Last Triggered</p>
                          <p className="font-medium">
                            {webhook.lastTriggeredAt
                              ? formatDistanceToNow(new Date(webhook.lastTriggeredAt)) +
                                ' ago'
                              : 'Never'}
                          </p>
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </TabsContent>

        <TabsContent value="deliveries" className="space-y-4">
          <Card>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Event</TableHead>
                  <TableHead>Webhook</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Response</TableHead>
                  <TableHead>Attempts</TableHead>
                  <TableHead>Time</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {deliveries.map((delivery) => (
                  <TableRow key={delivery.id}>
                    <TableCell>
                      <Badge variant="outline" className="text-xs">
                        {delivery.event}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <span className="text-sm">
                        {webhooks.find((w) => w.id === delivery.webhookId)?.name ||
                          'Unknown'}
                      </span>
                    </TableCell>
                    <TableCell>{getStatusBadge(delivery.status)}</TableCell>
                    <TableCell>
                      {delivery.statusCode ? (
                        <Badge
                          variant={
                            delivery.statusCode >= 200 && delivery.statusCode < 300
                              ? 'success'
                              : 'destructive'
                          }
                          className="text-xs"
                        >
                          {delivery.statusCode}
                        </Badge>
                      ) : (
                        <span className="text-xs text-muted-foreground">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <span className="text-xs">{delivery.attempts}</span>
                    </TableCell>
                    <TableCell>
                      <span className="text-xs">
                        {formatDistanceToNow(new Date(delivery.createdAt))} ago
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
                              setSelectedDelivery(delivery);
                              setShowDeliveryDialog(true);
                            }}
                          >
                            <Info className="mr-2 h-4 w-4" />
                            View Details
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => handleRetryDelivery(delivery.id)}
                            disabled={delivery.status !== 'failed'}
                          >
                            <RotateCw className="mr-2 h-4 w-4" />
                            Retry
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            {deliveries.length === 0 && (
              <CardContent className="py-8 text-center">
                <p className="text-muted-foreground">No deliveries yet</p>
              </CardContent>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="events" className="space-y-4">
          <div className="grid gap-4">
            {Object.entries(
              availableEvents.reduce((acc, event) => {
                if (!acc[event.category]) {
                  acc[event.category] = [];
                }
                acc[event.category]!.push(event);
                return acc;
              }, {} as Record<string, WebhookEvent[]>)
            ).map(([category, events]) => (
              <Card key={category}>
                <CardHeader>
                  <CardTitle className="text-base">{category}</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    {events.map((event) => (
                      <div
                        key={event.id}
                        className="flex items-start justify-between space-x-4"
                      >
                        <div className="flex-1">
                          <div className="flex items-center space-x-2">
                            <Zap className="h-4 w-4 text-muted-foreground" />
                            <code className="text-sm font-medium">{event.id}</code>
                          </div>
                          <p className="text-sm text-muted-foreground mt-1">
                            {event.description}
                          </p>
                        </div>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => copyToClipboard(JSON.stringify(event.samplePayload, null, 2))}
                        >
                          <Code className="mr-2 h-3 w-3" />
                          Sample
                        </Button>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </TabsContent>
      </Tabs>

      {/* Test Webhook Dialog */}
      <Dialog open={showTestDialog} onOpenChange={setShowTestDialog}>
        <DialogContent className="sm:max-w-[600px]">
          <DialogHeader>
            <DialogTitle>Test Webhook</DialogTitle>
            <DialogDescription>
              Send a test event to {selectedWebhook?.name}
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid gap-2">
              <Label htmlFor="testEvent">Event Type</Label>
              <Select value={testEvent} onValueChange={setTestEvent}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {availableEvents.map((event) => (
                    <SelectItem key={event.id} value={event.id}>
                      {event.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="grid gap-2">
              <Label htmlFor="payload">Payload (JSON)</Label>
              <Textarea
                id="payload"
                value={
                  testPayload ||
                  JSON.stringify(
                    availableEvents.find((e) => e.id === testEvent)?.samplePayload,
                    null,
                    2
                  )
                }
                onChange={(e) => setTestPayload(e.target.value)}
                className="font-mono text-sm h-48"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowTestDialog(false)}>
              Cancel
            </Button>
            <Button onClick={handleTestWebhook}>
              <Send className="mr-2 h-4 w-4" />
              Send Test
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delivery Details Dialog */}
      <Dialog open={showDeliveryDialog} onOpenChange={setShowDeliveryDialog}>
        <DialogContent className="sm:max-w-[700px]">
          <DialogHeader>
            <DialogTitle>Delivery Details</DialogTitle>
            <DialogDescription>
              Event delivery information and response
            </DialogDescription>
          </DialogHeader>
          {selectedDelivery && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label>Event</Label>
                  <p className="text-sm">{selectedDelivery.event}</p>
                </div>
                <div>
                  <Label>Status</Label>
                  <div className="mt-1">{getStatusBadge(selectedDelivery.status)}</div>
                </div>
                <div>
                  <Label>Status Code</Label>
                  <p className="text-sm">{selectedDelivery.statusCode || 'N/A'}</p>
                </div>
                <div>
                  <Label>Response Time</Label>
                  <p className="text-sm">
                    {selectedDelivery.responseTime
                      ? `${selectedDelivery.responseTime}ms`
                      : 'N/A'}
                  </p>
                </div>
                <div>
                  <Label>Attempts</Label>
                  <p className="text-sm">{selectedDelivery.attempts}</p>
                </div>
                <div>
                  <Label>Timestamp</Label>
                  <p className="text-sm">
                    {format(new Date(selectedDelivery.createdAt), 'PPpp')}
                  </p>
                </div>
              </div>
              {selectedDelivery.error && (
                <Alert variant="destructive">
                  <AlertTriangle className="h-4 w-4" />
                  <AlertTitle>Error</AlertTitle>
                  <AlertDescription>{selectedDelivery.error}</AlertDescription>
                </Alert>
              )}
              <div>
                <Label>Request Payload</Label>
                <ScrollArea className="h-48 mt-2">
                  <pre className="text-xs bg-muted p-3 rounded-md">
                    {JSON.stringify(selectedDelivery.payload, null, 2)}
                  </pre>
                </ScrollArea>
              </div>
              {selectedDelivery.response && (
                <div>
                  <Label>Response</Label>
                  <ScrollArea className="h-48 mt-2">
                    <pre className="text-xs bg-muted p-3 rounded-md">
                      {selectedDelivery.response}
                    </pre>
                  </ScrollArea>
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}