'use client';

import React, { useState, useEffect, useRef } from 'react';
// Card components not currently used but may be needed for future UI enhancements
// import {
//   Card,
//   CardContent,
//   CardDescription,
//   CardHeader,
//   CardTitle,
// } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Switch } from '@/components/ui/switch';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Bell,
  BellOff,
  Check,
  CheckCheck,
  MoreVertical,
  Trash2,
  Archive,
  Volume2,
  VolumeX,
  Settings,
  Info,
  AlertTriangle,
  CheckCircle,
  XCircle,
  User,
  Shield,
  Mail,
  MessageSquare,
  Calendar,
  Clock,
  DollarSign,
  Package,
  FileText,
  WifiOff,
  Activity,
} from 'lucide-react';
import { formatDistanceToNow, format } from 'date-fns';
// import { useToast } from '@/components/ui/use-toast'; // TODO: Use for future toast notifications
import { useNotificationStore } from '@/stores/notificationStore';
import { cn } from '@/lib/utils';

const notificationIcons: Record<string, React.ComponentType<React.SVGProps<SVGSVGElement>>> = {
  info: Info,
  success: CheckCircle,
  warning: AlertTriangle,
  error: XCircle,
  security: Shield,
  user: User,
  message: MessageSquare,
  email: Mail,
  calendar: Calendar,
  payment: DollarSign,
  order: Package,
  document: FileText,
  system: Activity,
};

const priorityColors = {
  low: 'text-gray-500',
  medium: 'text-yellow-500',
  high: 'text-orange-500',
  critical: 'text-red-500',
  urgent: 'text-red-600',
};

export default function NotificationCenter() {
  const {
    notifications,
    unreadCount,
    preferences,
    isConnected,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    clearAll,
    archiveNotification,
    updatePreferences,
    fetchNotifications,
  } = useNotificationStore();

  const [isOpen, setIsOpen] = useState(false);
  const [activeTab, setActiveTab] = useState('all');
  const [filter, setFilter] = useState('all');
  const audioRef = useRef<HTMLAudioElement | null>(null);
  // const { toast } = useToast(); // TODO: Use for future toast notifications

  useEffect(() => {
    // Initialize audio for notifications
    if (typeof window !== 'undefined') {
      audioRef.current = new Audio('/notification-sound.mp3');
    }
  }, []);

  useEffect(() => {
    // Fetch initial notifications
    fetchNotifications();
  }, [fetchNotifications]);

  const playNotificationSound = () => {
    if (preferences.soundEnabled && audioRef.current) {
      audioRef.current.play().catch(() => {
        // Ignore audio play errors (e.g., user hasn't interacted with the page yet)
      });
    }
  };

  // TODO: Use playNotificationSound when appropriate notification events occur
  void playNotificationSound; // Prevent unused variable warning


  const getNotificationIcon = (type: string) => {
    const Icon = notificationIcons[type] || Bell;
    return Icon;
  };

  const filteredNotifications = notifications.filter((n) => {
    if (activeTab === 'unread' && n.read) return false;
    if (activeTab === 'archived' && !n.archived) return false;
    if (activeTab !== 'archived' && n.archived) return false;
    
    if (filter !== 'all' && n.category !== filter) return false;
    
    return true;
  });

  const groupedNotifications = filteredNotifications.reduce((acc, notification) => {
    const date = format(new Date(notification.createdAt), 'yyyy-MM-dd');
    if (!acc[date]) {
      acc[date] = [];
    }
    acc[date].push(notification);
    return acc;
  }, {} as Record<string, typeof notifications>);

  const NotificationItem = ({ notification }: { notification: typeof notifications[0] }) => {
    const Icon = getNotificationIcon(notification.type);
    
    return (
      <div
        className={cn(
          'flex items-start space-x-3 p-3 rounded-lg transition-colors',
          !notification.read && 'bg-muted/50',
          'hover:bg-muted'
        )}
      >
        <div
          className={cn(
            'mt-1 p-2 rounded-full',
            notification.type === 'error' && 'bg-red-100',
            notification.type === 'success' && 'bg-green-100',
            notification.type === 'warning' && 'bg-yellow-100',
            notification.type === 'info' && 'bg-blue-100'
          )}
        >
          <Icon
            className={cn(
              'h-4 w-4',
              notification.type === 'error' && 'text-red-600',
              notification.type === 'success' && 'text-green-600',
              notification.type === 'warning' && 'text-yellow-600',
              notification.type === 'info' && 'text-blue-600'
            )}
          />
        </div>
        
        <div className="flex-1 space-y-1">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium">{notification.title}</p>
              <p className="text-xs text-muted-foreground">{notification.message}</p>
            </div>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="icon" className="h-6 w-6">
                  <MoreVertical className="h-3 w-3" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                {!notification.read && (
                  <DropdownMenuItem onClick={() => markAsRead(notification.id)}>
                    <Check className="mr-2 h-4 w-4" />
                    Mark as read
                  </DropdownMenuItem>
                )}
                <DropdownMenuItem onClick={() => archiveNotification(notification.id)}>
                  <Archive className="mr-2 h-4 w-4" />
                  Archive
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  className="text-destructive"
                  onClick={() => deleteNotification(notification.id)}
                >
                  <Trash2 className="mr-2 h-4 w-4" />
                  Delete
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
          
          <div className="flex items-center space-x-2 text-xs text-muted-foreground">
            <Clock className="h-3 w-3" />
            <span>{formatDistanceToNow(new Date(notification.createdAt))} ago</span>
            {notification.priority && (
              <>
                <span>•</span>
                <span className={priorityColors[notification.priority]}>
                  {notification.priority.charAt(0).toUpperCase() + notification.priority.slice(1)}
                </span>
              </>
            )}
          </div>
          
          {notification.actions && notification.actions.length > 0 && (
            <div className="flex items-center space-x-2 mt-2">
              {notification.actions.map((action, index) => (
                <Button
                  key={index}
                  size="sm"
                  variant={action.variant || 'outline'}
                  className="h-7 text-xs"
                  onClick={() => action.action()}
                >
                  {action.label}
                </Button>
              ))}
            </div>
          )}
        </div>
      </div>
    );
  };

  return (
    <>
      <Popover open={isOpen} onOpenChange={setIsOpen}>
        <PopoverTrigger asChild>
          <Button variant="ghost" size="icon" className="relative">
            {preferences.notificationsEnabled ? (
              <Bell className="h-5 w-5" />
            ) : (
              <BellOff className="h-5 w-5" />
            )}
            {unreadCount > 0 && (
              <span className="absolute -top-1 -right-1 h-5 w-5 rounded-full bg-red-500 text-white text-xs flex items-center justify-center">
                {unreadCount > 99 ? '99+' : unreadCount}
              </span>
            )}
            {!isConnected && (
              <span className="absolute bottom-0 right-0 h-2 w-2 rounded-full bg-yellow-500" />
            )}
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-96 p-0" align="end">
          <div className="flex items-center justify-between p-4 border-b">
            <div>
              <h3 className="font-semibold">Notifications</h3>
              <p className="text-xs text-muted-foreground">
                {unreadCount} unread notifications
              </p>
            </div>
            <div className="flex items-center space-x-1">
              <Button
                variant="ghost"
                size="icon"
                className="h-8 w-8"
                onClick={() => updatePreferences({ soundEnabled: !preferences.soundEnabled })}
              >
                {preferences.soundEnabled ? (
                  <Volume2 className="h-4 w-4" />
                ) : (
                  <VolumeX className="h-4 w-4" />
                )}
              </Button>
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" size="icon" className="h-8 w-8">
                    <Settings className="h-4 w-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  <DropdownMenuLabel>Notification Settings</DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem onClick={markAllAsRead}>
                    <CheckCheck className="mr-2 h-4 w-4" />
                    Mark all as read
                  </DropdownMenuItem>
                  <DropdownMenuItem onClick={clearAll}>
                    <Trash2 className="mr-2 h-4 w-4" />
                    Clear all
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <div className="px-2 py-1.5">
                    <div className="flex items-center justify-between">
                      <span className="text-sm">Push notifications</span>
                      <Switch
                        checked={preferences.pushEnabled}
                        onCheckedChange={(checked) =>
                          updatePreferences({ pushEnabled: checked })
                        }
                      />
                    </div>
                  </div>
                  <div className="px-2 py-1.5">
                    <div className="flex items-center justify-between">
                      <span className="text-sm">Email notifications</span>
                      <Switch
                        checked={preferences.emailEnabled}
                        onCheckedChange={(checked) =>
                          updatePreferences({ emailEnabled: checked })
                        }
                      />
                    </div>
                  </div>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          </div>

          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList className="grid w-full grid-cols-3 h-10">
              <TabsTrigger value="all" className="text-xs">
                All
              </TabsTrigger>
              <TabsTrigger value="unread" className="text-xs">
                Unread ({unreadCount})
              </TabsTrigger>
              <TabsTrigger value="archived" className="text-xs">
                Archived
              </TabsTrigger>
            </TabsList>

            <div className="px-4 py-2 border-b">
              <Select value={filter} onValueChange={setFilter}>
                <SelectTrigger className="h-8 text-xs">
                  <SelectValue placeholder="Filter by category" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Categories</SelectItem>
                  <SelectItem value="security">Security</SelectItem>
                  <SelectItem value="user">User</SelectItem>
                  <SelectItem value="system">System</SelectItem>
                  <SelectItem value="billing">Billing</SelectItem>
                  <SelectItem value="general">General</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <TabsContent value={activeTab} className="m-0">
              <ScrollArea className="h-96">
                {Object.keys(groupedNotifications).length === 0 ? (
                  <div className="flex flex-col items-center justify-center py-12">
                    <Bell className="h-12 w-12 text-muted-foreground mb-4" />
                    <p className="text-sm text-muted-foreground">No notifications</p>
                  </div>
                ) : (
                  <div className="p-2">
                    {Object.entries(groupedNotifications).map(([date, dateNotifications]) => (
                      <div key={date} className="mb-4">
                        <div className="px-2 py-1 text-xs font-medium text-muted-foreground">
                          {date === format(new Date(), 'yyyy-MM-dd')
                            ? 'Today'
                            : date === format(new Date(Date.now() - 86400000), 'yyyy-MM-dd')
                            ? 'Yesterday'
                            : format(new Date(date), 'MMMM d, yyyy')}
                        </div>
                        <div className="space-y-1">
                          {dateNotifications.map((notification) => (
                            <NotificationItem
                              key={notification.id}
                              notification={notification}
                            />
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </ScrollArea>
            </TabsContent>
          </Tabs>

          <div className="p-3 border-t">
            <Button variant="outline" className="w-full" size="sm" asChild>
              <a href="/notifications">View all notifications</a>
            </Button>
          </div>
        </PopoverContent>
      </Popover>

      {/* WebSocket connection indicator */}
      {!isConnected && (
        <Badge variant="warning" className="fixed bottom-4 right-4">
          <WifiOff className="mr-1 h-3 w-3" />
          Reconnecting...
        </Badge>
      )}
    </>
  );
}