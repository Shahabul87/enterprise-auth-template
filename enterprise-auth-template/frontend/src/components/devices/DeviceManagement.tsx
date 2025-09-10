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
import {
  Laptop,
  Smartphone,
  Tablet,
  Monitor,
  MoreVertical,
  LogOut,
  Shield,
  ShieldOff,
  AlertTriangle,
  Clock,
  Activity,
  RefreshCw,
  Trash2,
} from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { useToast } from '@/components/ui/use-toast';

interface DeviceInfo {
  device_id: string;
  device_name: string;
  device_type: string;
  os_name?: string;
  os_version?: string;
  browser_name?: string;
  browser_version?: string;
  is_trusted: boolean;
}

interface SessionInfo {
  session_id: string;
  device_id?: string;
  device_name?: string;
  device_type?: string;
  ip_address?: string;
  user_agent?: string;
  location?: string;
  created_at: string;
  last_activity: string;
  is_current: boolean;
  expires_at?: string;
}

interface SessionListResponse {
  sessions: SessionInfo[];
  total: number;
  active_count: number;
}

interface DeviceListResponse {
  devices: DeviceInfo[];
  total: number;
}

export default function DeviceManagement() {
  const [sessions, setSessions] = useState<SessionInfo[]>([]);
  const [devices, setDevices] = useState<DeviceInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('sessions');
  // const [selectedSession, setSelectedSession] = useState<SessionInfo | null>(null);
  const [showForceLogoutDialog, setShowForceLogoutDialog] = useState(false);
  const [activeCount, setActiveCount] = useState(0);
  const { toast } = useToast();

  const fetchSessions = useCallback(async () => {
    try {
      const response = await fetch('/api/v1/devices/sessions', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data: SessionListResponse = await response.json();
        setSessions(data.sessions);
        setActiveCount(data.active_count);
      }
    } catch {
      
      toast({
        title: 'Error',
        description: 'Failed to fetch sessions',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  }, [toast]);

  const fetchDevices = useCallback(async () => {
    try {
      const response = await fetch('/api/v1/devices/devices', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data: DeviceListResponse = await response.json();
        setDevices(data.devices);
      }
    } catch {
      
    }
  }, []);

  useEffect(() => {
    fetchSessions();
    fetchDevices();
  }, [fetchSessions, fetchDevices]);

  const handleRevokeSession = async (sessionId: string) => {
    try {
      const response = await fetch(`/api/v1/devices/sessions/${sessionId}`, {
        method: 'DELETE',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        toast({
          title: 'Success',
          description: 'Session revoked successfully',
        });
        await fetchSessions();
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to revoke session',
        variant: 'destructive',
      });
    }
  };

  const handleForceLogout = async (exceptCurrent: boolean = true) => {
    try {
      const response = await fetch('/api/v1/devices/force-logout', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
        body: JSON.stringify({
          except_current: exceptCurrent,
          reason: 'User initiated force logout',
        }),
      });

      if (response.ok) {
        const data = await response.json();
        toast({
          title: 'Success',
          description: `Logged out from ${data.sessions_terminated} sessions`,
        });
        await fetchSessions();
        setShowForceLogoutDialog(false);
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to force logout',
        variant: 'destructive',
      });
    }
  };

  const handleTrustDevice = async (deviceId: string, isTrusted: boolean) => {
    try {
      const response = await fetch('/api/v1/devices/trust', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
        body: JSON.stringify({
          device_id: deviceId,
          is_trusted: isTrusted,
          require_2fa: true,
        }),
      });

      if (response.ok) {
        toast({
          title: 'Success',
          description: `Device ${isTrusted ? 'trusted' : 'untrusted'} successfully`,
        });
        await fetchDevices();
      }
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to update device trust',
        variant: 'destructive',
      });
    }
  };

  const getDeviceIcon = (deviceType?: string) => {
    switch (deviceType) {
      case 'mobile':
        return <Smartphone className="h-5 w-5" />;
      case 'tablet':
        return <Tablet className="h-5 w-5" />;
      case 'desktop':
        return <Monitor className="h-5 w-5" />;
      default:
        return <Laptop className="h-5 w-5" />;
    }
  };

  const SessionCard = ({ session }: { session: SessionInfo }) => (
    <Card className={session.is_current ? 'border-primary' : ''}>
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            {getDeviceIcon(session.device_type)}
            <div>
              <CardTitle className="text-base">
                {session.device_name || 'Unknown Device'}
              </CardTitle>
              <CardDescription className="text-xs">
                {session.ip_address || 'Unknown IP'}
                {session.location && ` • ${session.location}`}
              </CardDescription>
            </div>
          </div>
          <div className="flex items-center space-x-2">
            {session.is_current && (
              <Badge variant="default" className="text-xs">
                Current
              </Badge>
            )}
            {!session.is_current && (
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
                    className="text-destructive"
                    onClick={() => handleRevokeSession(session.session_id)}
                  >
                    <LogOut className="mr-2 h-4 w-4" />
                    Revoke Session
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            )}
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-2 gap-2 text-sm">
          <div className="flex items-center text-muted-foreground">
            <Clock className="mr-1 h-3 w-3" />
            <span className="text-xs">
              Active {formatDistanceToNow(new Date(session.last_activity))} ago
            </span>
          </div>
          <div className="flex items-center text-muted-foreground">
            <Activity className="mr-1 h-3 w-3" />
            <span className="text-xs">
              Started {formatDistanceToNow(new Date(session.created_at))} ago
            </span>
          </div>
        </div>
        {session.user_agent && (
          <p className="mt-2 text-xs text-muted-foreground truncate">
            {session.user_agent}
          </p>
        )}
      </CardContent>
    </Card>
  );

  const DeviceCard = ({ device }: { device: DeviceInfo }) => (
    <Card>
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            {getDeviceIcon(device.device_type)}
            <div>
              <CardTitle className="text-base">{device.device_name}</CardTitle>
              <CardDescription className="text-xs">
                {device.os_name} {device.os_version}
                {device.browser_name && ` • ${device.browser_name}`}
              </CardDescription>
            </div>
          </div>
          <div className="flex items-center space-x-2">
            {device.is_trusted ? (
              <Badge variant="success" className="text-xs">
                <Shield className="mr-1 h-3 w-3" />
                Trusted
              </Badge>
            ) : (
              <Badge variant="secondary" className="text-xs">
                <ShieldOff className="mr-1 h-3 w-3" />
                Not Trusted
              </Badge>
            )}
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
                  onClick={() => handleTrustDevice(device.device_id, !device.is_trusted)}
                >
                  {device.is_trusted ? (
                    <>
                      <ShieldOff className="mr-2 h-4 w-4" />
                      Remove Trust
                    </>
                  ) : (
                    <>
                      <Shield className="mr-2 h-4 w-4" />
                      Trust Device
                    </>
                  )}
                </DropdownMenuItem>
                <DropdownMenuItem className="text-destructive">
                  <Trash2 className="mr-2 h-4 w-4" />
                  Remove Device
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </CardHeader>
    </Card>
  );

  if (loading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-12 w-full" />
        <Skeleton className="h-32 w-full" />
        <Skeleton className="h-32 w-full" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">Device Management</h2>
          <p className="text-muted-foreground">
            Manage your devices and active sessions
          </p>
        </div>
        <div className="flex space-x-2">
          <Button variant="outline" size="sm" onClick={fetchSessions}>
            <RefreshCw className="mr-2 h-4 w-4" />
            Refresh
          </Button>
          <Dialog open={showForceLogoutDialog} onOpenChange={setShowForceLogoutDialog}>
            <DialogTrigger asChild>
              <Button variant="destructive" size="sm">
                <LogOut className="mr-2 h-4 w-4" />
                Logout All Devices
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Logout from all devices?</DialogTitle>
                <DialogDescription>
                  This will log you out from all devices except the current one.
                  You&apos;ll need to sign in again on other devices.
                </DialogDescription>
              </DialogHeader>
              <DialogFooter>
                <Button variant="outline" onClick={() => setShowForceLogoutDialog(false)}>
                  Cancel
                </Button>
                <Button variant="destructive" onClick={() => handleForceLogout(true)}>
                  Logout All Devices
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      {activeCount > 3 && (
        <Alert>
          <AlertTriangle className="h-4 w-4" />
          <AlertTitle>Multiple Active Sessions</AlertTitle>
          <AlertDescription>
            You have {activeCount} active sessions. Consider reviewing and revoking
            unused sessions for better security.
          </AlertDescription>
        </Alert>
      )}

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="sessions">
            Active Sessions ({sessions.length})
          </TabsTrigger>
          <TabsTrigger value="devices">
            Registered Devices ({devices.length})
          </TabsTrigger>
        </TabsList>

        <TabsContent value="sessions" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            {sessions.map((session) => (
              <SessionCard key={session.session_id} session={session} />
            ))}
          </div>
          {sessions.length === 0 && (
            <Card>
              <CardContent className="py-8 text-center">
                <p className="text-muted-foreground">No active sessions found</p>
              </CardContent>
            </Card>
          )}
        </TabsContent>

        <TabsContent value="devices" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            {devices.map((device) => (
              <DeviceCard key={device.device_id} device={device} />
            ))}
          </div>
          {devices.length === 0 && (
            <Card>
              <CardContent className="py-8 text-center">
                <p className="text-muted-foreground">No registered devices found</p>
              </CardContent>
            </Card>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}