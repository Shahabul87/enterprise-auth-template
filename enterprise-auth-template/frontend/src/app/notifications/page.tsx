'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRequireAuth } from '@/stores/auth.store';
import { notificationsService, NotificationForFrontend } from '@/services/notifications.service';
import { NotificationQueryParams, NotificationPreferencesResponse, NotificationCategory } from '@/types/api.types';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
// Avatar components not needed for this page
import { 
  Bell, 
  Check, 
  X, 
  Settings, 
  Mail, 
  MessageSquare, 
  Shield, 
  User,
  Clock,
  AlertTriangle,
  Info,
  CheckCircle,
  XCircle
} from 'lucide-react';
import { toast } from 'sonner';

// Use proper notification types from service
type Notification = NotificationForFrontend;

// Map API preferences to frontend format
interface NotificationSettings {
  email: {
    security: boolean;
    system: boolean;
    social: boolean;
    account: boolean;
  };
  push: {
    security: boolean;
    system: boolean;
    social: boolean;
    account: boolean;
  };
  frequency: 'immediate' | 'hourly' | 'daily' | 'weekly';
}

// Remove mock data - using real API

export default function NotificationsPage(): JSX.Element {
  const { user } = useRequireAuth();
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [settings, setSettings] = useState<NotificationSettings>({
    email: {
      security: true,
      system: true,
      social: false,
      account: true,
    },
    push: {
      security: true,
      system: false,
      social: false,
      account: false,
    },
    frequency: 'immediate',
  });
  const [activeTab, setActiveTab] = useState('all');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const unreadCount = notifications.filter(n => !n.isRead).length;

  // Load notifications from API
  const loadNotifications = useCallback(async (params?: NotificationQueryParams) => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await notificationsService.getNotificationsForFrontend({
        limit: 50,
        offset: 0,
        ...params,
      });
      
      if (response.success && response.data) {
        setNotifications(response.data.notifications);
      } else {
        setError(response.error?.message || 'Failed to load notifications');
      }
    } catch {
      setError('Failed to load notifications');
    } finally {
      setLoading(false);
    }
  }, []);

  // Load notification preferences
  const loadPreferences = useCallback(async () => {
    try {
      const response = await notificationsService.getPreferences();
      if (response.success && response.data) {
        const prefs = response.data;
        setSettings({
          email: {
            security: prefs.security_alerts && prefs.email_notifications,
            system: prefs.email_notifications,
            social: prefs.marketing_emails && prefs.email_notifications,
            account: prefs.email_notifications,
          },
          push: {
            security: prefs.security_alerts && prefs.push_notifications,
            system: prefs.push_notifications,
            social: prefs.marketing_emails && prefs.push_notifications,
            account: prefs.push_notifications,
          },
          frequency: (prefs.frequency_settings['default'] as 'immediate' | 'hourly' | 'daily' | 'weekly') || 'immediate',
        });
      }
    } catch {
      // Silently fail for preferences - not critical
    }
  }, []);

  // Initial load
  useEffect(() => {
    if (user) {
      loadNotifications();
      loadPreferences();
    }
  }, [user, loadNotifications, loadPreferences]);

  const getCategoryIcon = (category: Notification['category']) => {
    switch (category) {
      case 'security':
        return <Shield className="h-4 w-4" />;
      case 'social':
        return <MessageSquare className="h-4 w-4" />;
      case 'account':
        return <User className="h-4 w-4" />;
      default:
        return <Settings className="h-4 w-4" />;
    }
  };

  const markAsRead = async (notificationId: string) => {
    try {
      const response = await notificationsService.markAsRead(notificationId);
      if (response.success) {
        setNotifications(prev =>
          prev.map(n =>
            n.id === notificationId ? { ...n, isRead: true } : n
          )
        );
      } else {
        toast.error(response.error?.message || 'Failed to mark notification as read');
      }
    } catch {
      toast.error('Failed to mark notification as read');
    }
  };

  const markAllAsRead = async () => {
    try {
      const response = await notificationsService.markAllAsRead();
      if (response.success) {
        setNotifications(prev =>
          prev.map(n => ({ ...n, isRead: true }))
        );
        toast.success(response.data?.message || 'All notifications marked as read');
      } else {
        toast.error(response.error?.message || 'Failed to mark all notifications as read');
      }
    } catch {
      toast.error('Failed to mark all notifications as read');
    }
  };

  const deleteNotification = async (notificationId: string) => {
    try {
      const response = await notificationsService.deleteNotification(notificationId);
      if (response.success) {
        setNotifications(prev => prev.filter(n => n.id !== notificationId));
        toast.success(response.data?.message || 'Notification deleted');
      } else {
        toast.error(response.error?.message || 'Failed to delete notification');
      }
    } catch {
      toast.error('Failed to delete notification');
    }
  };

  const updateSettings = (category: keyof NotificationSettings['email'], type: 'email' | 'push', value: boolean) => {
    setSettings(prev => ({
      ...prev,
      [type]: {
        ...prev[type],
        [category]: value,
      },
    }));
  };

  const saveSettings = async () => {
    try {
      // Convert frontend settings to API format
      const apiPreferences: NotificationPreferencesResponse = {
        email_notifications: settings.email.account || settings.email.security || settings.email.system,
        push_notifications: settings.push.account || settings.push.security || settings.push.system,
        sms_notifications: false,
        in_app_notifications: true,
        marketing_emails: settings.email.social,
        security_alerts: settings.email.security || settings.push.security,
        frequency_settings: {
          default: settings.frequency,
          security: 'immediate',
          account: settings.frequency,
          billing: 'daily',
          marketing: 'weekly',
        },
      };
      
      const response = await notificationsService.updatePreferences(apiPreferences);
      if (response.success) {
        toast.success(response.data?.message || 'Notification settings saved');
      } else {
        toast.error(response.error?.message || 'Failed to save notification settings');
      }
    } catch {
      toast.error('Failed to save notification settings');
    }
  };

  const filteredNotifications = notifications.filter(notification => {
    if (activeTab === 'all') return true;
    if (activeTab === 'unread') return !notification.isRead;
    if (activeTab === 'settings') return true; // Settings tab doesn't filter notifications
    return notification.category === activeTab;
  });

  // Update tab filtering to reload data from API when needed
  const handleTabChange = useCallback(async (tab: string) => {
    setActiveTab(tab);
    
    if (tab === 'settings') return; // Settings tab doesn't need to reload notifications
    
    // Load specific data based on tab
    const params: NotificationQueryParams = {
      limit: 50,
      offset: 0,
    };
    
    if (tab === 'unread') {
      params.unread_only = true;
    } else if (tab !== 'all') {
      // Map frontend category to backend category
      const categoryMap: Record<string, string> = {
        'security': 'security',
        'system': 'system',
        'account': 'account',
        'social': 'general', // Map social to general category
      };
      
      if (categoryMap[tab]) {
        params.category_filter = categoryMap[tab] as NotificationCategory;
      }
    }
    
    await loadNotifications(params);
  }, [loadNotifications]);

  if (!user || loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-muted/50 p-4">
        <div className="container mx-auto">
          <div className="flex items-center justify-center min-h-[400px]">
            <div className="text-center">
              <p className="text-red-500 mb-4">{error}</p>
              <Button onClick={() => loadNotifications()} variant="outline">
                Try Again
              </Button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-muted/50">
      {/* Header */}
      <header className="border-b bg-background">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Bell className="h-6 w-6 text-primary" />
              <div>
                <h1 className="text-2xl font-bold text-primary">Notifications</h1>
                <p className="text-sm text-muted-foreground">
                  Stay updated with important events and updates
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              {unreadCount > 0 && (
                <Badge variant="secondary">
                  {unreadCount} unread
                </Badge>
              )}
              <Button onClick={markAllAsRead} variant="outline" size="sm">
                Mark all as read
              </Button>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        <Tabs value={activeTab} onValueChange={handleTabChange} className="space-y-6">
          <TabsList className="grid grid-cols-6 w-full max-w-2xl">
            <TabsTrigger value="all" className="flex items-center gap-2">
              <Bell className="h-4 w-4" />
              All
            </TabsTrigger>
            <TabsTrigger value="unread" className="flex items-center gap-2">
              <Clock className="h-4 w-4" />
              Unread
            </TabsTrigger>
            <TabsTrigger value="security" className="flex items-center gap-2">
              <Shield className="h-4 w-4" />
              Security
            </TabsTrigger>
            <TabsTrigger value="system" className="flex items-center gap-2">
              <Settings className="h-4 w-4" />
              System
            </TabsTrigger>
            <TabsTrigger value="account" className="flex items-center gap-2">
              <User className="h-4 w-4" />
              Account
            </TabsTrigger>
            <TabsTrigger value="settings" className="flex items-center gap-2">
              <Mail className="h-4 w-4" />
              Settings
            </TabsTrigger>
          </TabsList>

          <TabsContent value="all" className="space-y-4">
            <NotificationsList notifications={filteredNotifications} onMarkAsRead={markAsRead} onDelete={deleteNotification} />
          </TabsContent>

          <TabsContent value="unread" className="space-y-4">
            <NotificationsList notifications={filteredNotifications} onMarkAsRead={markAsRead} onDelete={deleteNotification} />
          </TabsContent>

          <TabsContent value="security" className="space-y-4">
            <NotificationsList notifications={filteredNotifications} onMarkAsRead={markAsRead} onDelete={deleteNotification} />
          </TabsContent>

          <TabsContent value="system" className="space-y-4">
            <NotificationsList notifications={filteredNotifications} onMarkAsRead={markAsRead} onDelete={deleteNotification} />
          </TabsContent>

          <TabsContent value="account" className="space-y-4">
            <NotificationsList notifications={filteredNotifications} onMarkAsRead={markAsRead} onDelete={deleteNotification} />
          </TabsContent>

          <TabsContent value="settings" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Settings className="h-5 w-5" />
                  Notification Preferences
                </CardTitle>
                <CardDescription>
                  Choose how and when you want to receive notifications.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid gap-6 md:grid-cols-2">
                  <div className="space-y-4">
                    <h3 className="text-lg font-medium flex items-center gap-2">
                      <Mail className="h-5 w-5" />
                      Email Notifications
                    </h3>
                    <div className="space-y-3">
                      {Object.entries(settings.email).map(([category, enabled]) => (
                        <div key={category} className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            {getCategoryIcon(category as Notification['category'])}
                            <Label className="capitalize">{category}</Label>
                          </div>
                          <Switch
                            checked={enabled}
                            onCheckedChange={(checked) => updateSettings(category as keyof NotificationSettings['email'], 'email', checked)}
                          />
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="space-y-4">
                    <h3 className="text-lg font-medium flex items-center gap-2">
                      <Bell className="h-5 w-5" />
                      Push Notifications
                    </h3>
                    <div className="space-y-3">
                      {Object.entries(settings.push).map(([category, enabled]) => (
                        <div key={category} className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            {getCategoryIcon(category as Notification['category'])}
                            <Label className="capitalize">{category}</Label>
                          </div>
                          <Switch
                            checked={enabled}
                            onCheckedChange={(checked) => updateSettings(category as keyof NotificationSettings['email'], 'push', checked)}
                          />
                        </div>
                      ))}
                    </div>
                  </div>
                </div>

                <Separator />

                <div className="space-y-4">
                  <h3 className="text-lg font-medium">Delivery Frequency</h3>
                  <div className="grid gap-2 md:grid-cols-4">
                    {(['immediate', 'hourly', 'daily', 'weekly'] as const).map((frequency) => (
                      <Button
                        key={frequency}
                        variant={settings.frequency === frequency ? 'default' : 'outline'}
                        onClick={() => setSettings(prev => ({ ...prev, frequency }))}
                        className="justify-start"
                      >
                        <Clock className="h-4 w-4 mr-2" />
                        {frequency.charAt(0).toUpperCase() + frequency.slice(1)}
                      </Button>
                    ))}
                  </div>
                </div>

                <Button onClick={saveSettings} className="w-full md:w-auto">
                  Save Preferences
                </Button>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}

interface NotificationsListProps {
  notifications: Notification[];
  onMarkAsRead: (id: string) => void;
  onDelete: (id: string) => void;
}

function NotificationsList({ notifications, onMarkAsRead, onDelete }: NotificationsListProps) {
  const getNotificationIcon = (type: Notification['type']) => {
    switch (type) {
      case 'success':
        return <CheckCircle className="h-5 w-5 text-green-500" />;
      case 'warning':
        return <AlertTriangle className="h-5 w-5 text-yellow-500" />;
      case 'error':
        return <XCircle className="h-5 w-5 text-red-500" />;
      default:
        return <Info className="h-5 w-5 text-blue-500" />;
    }
  };

  const formatTimeAgo = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (diffInSeconds < 60) return 'Just now';
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`;
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`;
    return `${Math.floor(diffInSeconds / 86400)}d ago`;
  };

  if (notifications.length === 0) {
    return (
      <Card>
        <CardContent className="py-12 text-center">
          <Bell className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
          <h3 className="text-lg font-medium text-muted-foreground mb-2">No notifications</h3>
          <p className="text-sm text-muted-foreground">
            You&apos;re all caught up! Check back later for updates.
          </p>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      {notifications.map((notification) => (
        <Card key={notification.id} className={`transition-colors ${!notification.isRead ? 'bg-muted/50' : ''}`}>
          <CardContent className="p-6">
            <div className="flex items-start gap-4">
              <div className="flex-shrink-0 mt-0.5">
                {getNotificationIcon(notification.type)}
              </div>
              
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className={`text-sm font-medium ${!notification.isRead ? 'text-foreground' : 'text-muted-foreground'}`}>
                        {notification.title}
                      </h3>
                      {!notification.isRead && (
                        <Badge variant="secondary" className="h-2 w-2 p-0 bg-primary"></Badge>
                      )}
                    </div>
                    <p className="text-sm text-muted-foreground mb-2">
                      {notification.message}
                    </p>
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                      <Badge variant="outline" className="text-xs">
                        {notification.category}
                      </Badge>
                      <span>•</span>
                      <span>{formatTimeAgo(notification.createdAt)}</span>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-2">
                    {notification.actionUrl && (
                      <Button variant="link" size="sm" className="p-0 h-auto text-xs">
                        View Details
                      </Button>
                    )}
                    {!notification.isRead && (
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => onMarkAsRead(notification.id)}
                        className="p-2 h-8 w-8"
                      >
                        <Check className="h-4 w-4" />
                      </Button>
                    )}
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => onDelete(notification.id)}
                      className="p-2 h-8 w-8 text-muted-foreground hover:text-destructive"
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}