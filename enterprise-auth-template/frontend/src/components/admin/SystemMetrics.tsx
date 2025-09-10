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
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Progress } from '@/components/ui/progress';
import { Skeleton } from '@/components/ui/skeleton';
import {
  LineChart,
  Line,
  AreaChart,
  Area,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import {
  Activity,
  Users,
  Shield,
  Database,
  AlertTriangle,
  CheckCircle,
  XCircle,
  RefreshCw,
  Download,
  Cpu,
  HardDrive,
  MemoryStick,
  Zap,
  Lock,
  UserX,
} from 'lucide-react';
import { format } from 'date-fns';
import { useToast } from '@/components/ui/use-toast';

interface SystemMetrics {
  overview: {
    totalUsers: number;
    activeUsers: number;
    newUsersToday: number;
    totalSessions: number;
    activeSessions: number;
    avgSessionDuration: number;
    totalApiCalls: number;
    apiCallsToday: number;
    errorRate: number;
  };
  performance: {
    cpuUsage: number;
    memoryUsage: number;
    diskUsage: number;
    networkLatency: number;
    databaseLatency: number;
    cacheHitRate: number;
    requestsPerSecond: number;
    averageResponseTime: number;
  };
  security: {
    failedLoginAttempts: number;
    blockedIPs: number;
    suspiciousActivities: number;
    twoFactorAdoption: number;
    passwordResets: number;
    accountLockouts: number;
    securityAlerts: number;
    vulnerabilities: number;
  };
  usage: {
    loginMethods: Array<{ method: string; count: number }>;
    topEndpoints: Array<{ endpoint: string; calls: number; avgTime: number }>;
    usersByCountry: Array<{ country: string; users: number }>;
    deviceTypes: Array<{ type: string; count: number }>;
    browserTypes: Array<{ browser: string; count: number }>;
  };
  trends: {
    userGrowth: Array<{ date: string; users: number; newUsers: number }>;
    apiUsage: Array<{ date: string; calls: number; errors: number }>;
    performance: Array<{ date: string; cpu: number; memory: number; responseTime: number }>;
    security: Array<{ date: string; threats: number; blocked: number }>;
  };
}

interface HealthCheck {
  service: string;
  status: 'healthy' | 'degraded' | 'down';
  latency: number;
  lastCheck: string;
  details?: string;
}

const COLORS = ['#8884d8', '#82ca9d', '#ffc658', '#ff7c7c', '#8dd1e1', '#d084d0'];

export default function SystemMetrics() {
  const [metrics, setMetrics] = useState<SystemMetrics | null>(null);
  const [healthChecks, setHealthChecks] = useState<HealthCheck[]>([]);
  const [loading, setLoading] = useState(true);
  const [timeRange, setTimeRange] = useState('24h');
  const [refreshInterval, setRefreshInterval] = useState(30000); // 30 seconds
  const [activeTab, setActiveTab] = useState('overview');
  const { toast } = useToast();

  const fetchMetrics = useCallback(async () => {
    try {
      const response = await fetch(`/api/v1/admin/metrics?range=${timeRange}`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setMetrics(data);
      }
    } catch {
      // Error details intentionally not logged in production for security
      toast({
        title: 'Error',
        description: 'Failed to fetch system metrics',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  }, [timeRange, toast]);

  const fetchHealthChecks = useCallback(async () => {
    try {
      const response = await fetch('/api/v1/admin/health', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('access_token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setHealthChecks(data.services);
      }
    } catch {
      // Error details intentionally not logged in production for security
      // Health checks are not critical, silently fail
    }
  }, []);

  useEffect(() => {
    fetchMetrics();
    fetchHealthChecks();

    const interval = setInterval(() => {
      fetchMetrics();
      fetchHealthChecks();
    }, refreshInterval);

    return () => clearInterval(interval);
  }, [timeRange, refreshInterval, fetchMetrics, fetchHealthChecks]);

  const exportMetrics = () => {
    if (!metrics) return;

    const data = JSON.stringify(metrics, null, 2);
    const blob = new Blob([data], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `metrics_${format(new Date(), 'yyyy-MM-dd_HH-mm')}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    toast({
      title: 'Success',
      description: 'Metrics exported successfully',
    });
  };

  const getHealthStatusBadge = (status: string) => {
    switch (status) {
      case 'healthy':
        return (
          <Badge variant="success" className="text-xs">
            <CheckCircle className="mr-1 h-3 w-3" />
            Healthy
          </Badge>
        );
      case 'degraded':
        return (
          <Badge variant="warning" className="text-xs">
            <AlertTriangle className="mr-1 h-3 w-3" />
            Degraded
          </Badge>
        );
      case 'down':
        return (
          <Badge variant="destructive" className="text-xs">
            <XCircle className="mr-1 h-3 w-3" />
            Down
          </Badge>
        );
      default:
        return null;
    }
  };

  // Utility function for trend indicators (available for future use)
  // const getTrendIndicator = (current: number, previous: number) => {
  //   const change = ((current - previous) / previous) * 100;
  //   const isPositive = change > 0;

  //   return (
  //     <div className={`flex items-center text-xs ${isPositive ? 'text-green-600' : 'text-red-600'}`}>
  //       {isPositive ? (
  //         <TrendingUp className="mr-1 h-3 w-3" />
  //       ) : (
  //         <TrendingDown className="mr-1 h-3 w-3" />
  //       )}
  //       {Math.abs(change).toFixed(1)}%
  //     </div>
  //   );
  // };

  if (loading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-12 w-full" />
        <div className="grid gap-4 md:grid-cols-4">
          <Skeleton className="h-32" />
          <Skeleton className="h-32" />
          <Skeleton className="h-32" />
          <Skeleton className="h-32" />
        </div>
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  if (!metrics) {
    return (
      <Alert>
        <AlertTriangle className="h-4 w-4" />
        <AlertTitle>No Data Available</AlertTitle>
        <AlertDescription>
          Unable to fetch system metrics. Please try again later.
        </AlertDescription>
      </Alert>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">System Metrics</h2>
          <p className="text-muted-foreground">
            Real-time monitoring and analytics dashboard
          </p>
        </div>
        <div className="flex items-center space-x-2">
          <Select value={timeRange} onValueChange={setTimeRange}>
            <SelectTrigger className="w-32">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="1h">Last Hour</SelectItem>
              <SelectItem value="24h">Last 24 Hours</SelectItem>
              <SelectItem value="7d">Last 7 Days</SelectItem>
              <SelectItem value="30d">Last 30 Days</SelectItem>
            </SelectContent>
          </Select>
          <Select
            value={refreshInterval.toString()}
            onValueChange={(value) => setRefreshInterval(parseInt(value))}
          >
            <SelectTrigger className="w-40">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="10000">Refresh: 10s</SelectItem>
              <SelectItem value="30000">Refresh: 30s</SelectItem>
              <SelectItem value="60000">Refresh: 1m</SelectItem>
              <SelectItem value="300000">Refresh: 5m</SelectItem>
            </SelectContent>
          </Select>
          <Button variant="outline" size="sm" onClick={fetchMetrics}>
            <RefreshCw className="mr-2 h-4 w-4" />
            Refresh
          </Button>
          <Button variant="outline" size="sm" onClick={exportMetrics}>
            <Download className="mr-2 h-4 w-4" />
            Export
          </Button>
        </div>
      </div>

      {/* Health Status */}
      <div className="grid gap-4 md:grid-cols-6">
        {healthChecks.map((check) => (
          <Card key={check.service}>
            <CardHeader className="pb-2">
              <CardDescription className="text-xs">{check.service}</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-1">
                {getHealthStatusBadge(check.status)}
                <p className="text-xs text-muted-foreground">{check.latency}ms</p>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="grid w-full grid-cols-5">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="performance">Performance</TabsTrigger>
          <TabsTrigger value="security">Security</TabsTrigger>
          <TabsTrigger value="usage">Usage</TabsTrigger>
          <TabsTrigger value="trends">Trends</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4">
          {/* Key Metrics */}
          <div className="grid gap-4 md:grid-cols-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Total Users</CardTitle>
                <Users className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {metrics.overview.totalUsers.toLocaleString()}
                </div>
                <div className="flex items-center pt-1">
                  <span className="text-xs text-muted-foreground">
                    +{metrics.overview.newUsersToday} today
                  </span>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Active Sessions</CardTitle>
                <Activity className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {metrics.overview.activeSessions.toLocaleString()}
                </div>
                <Progress
                  value={(metrics.overview.activeSessions / metrics.overview.totalSessions) * 100}
                  className="mt-2"
                />
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">API Calls</CardTitle>
                <Zap className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {metrics.overview.apiCallsToday.toLocaleString()}
                </div>
                <div className="flex items-center pt-1">
                  <span className="text-xs text-muted-foreground">
                    Total: {metrics.overview.totalApiCalls.toLocaleString()}
                  </span>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Error Rate</CardTitle>
                <AlertTriangle className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{metrics.overview.errorRate.toFixed(2)}%</div>
                <div className="flex items-center pt-1">
                  <Badge
                    variant={metrics.overview.errorRate < 1 ? 'success' : 'destructive'}
                    className="text-xs"
                  >
                    {metrics.overview.errorRate < 1 ? 'Healthy' : 'High'}
                  </Badge>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* User Activity Chart */}
          <Card>
            <CardHeader>
              <CardTitle>User Activity</CardTitle>
              <CardDescription>Active users over time</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <AreaChart data={metrics.trends.userGrowth}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Area
                    type="monotone"
                    dataKey="users"
                    stroke="#8884d8"
                    fill="#8884d8"
                    fillOpacity={0.6}
                  />
                  <Area
                    type="monotone"
                    dataKey="newUsers"
                    stroke="#82ca9d"
                    fill="#82ca9d"
                    fillOpacity={0.6}
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="performance" className="space-y-4">
          {/* Performance Metrics */}
          <div className="grid gap-4 md:grid-cols-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">CPU Usage</CardTitle>
                <Cpu className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{metrics.performance.cpuUsage}%</div>
                <Progress value={metrics.performance.cpuUsage} className="mt-2" />
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Memory Usage</CardTitle>
                <MemoryStick className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{metrics.performance.memoryUsage}%</div>
                <Progress value={metrics.performance.memoryUsage} className="mt-2" />
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Disk Usage</CardTitle>
                <HardDrive className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{metrics.performance.diskUsage}%</div>
                <Progress value={metrics.performance.diskUsage} className="mt-2" />
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Cache Hit Rate</CardTitle>
                <Database className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{metrics.performance.cacheHitRate}%</div>
                <Progress value={metrics.performance.cacheHitRate} className="mt-2" />
              </CardContent>
            </Card>
          </div>

          {/* Response Time Chart */}
          <Card>
            <CardHeader>
              <CardTitle>System Performance</CardTitle>
              <CardDescription>Resource utilization over time</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={metrics.trends.performance}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="cpu" stroke="#8884d8" name="CPU %" />
                  <Line type="monotone" dataKey="memory" stroke="#82ca9d" name="Memory %" />
                  <Line
                    type="monotone"
                    dataKey="responseTime"
                    stroke="#ffc658"
                    name="Response Time (ms)"
                  />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Top Endpoints */}
          <Card>
            <CardHeader>
              <CardTitle>Top API Endpoints</CardTitle>
              <CardDescription>Most frequently accessed endpoints</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {metrics.usage.topEndpoints.map((endpoint, index) => (
                  <div key={index} className="flex items-center justify-between">
                    <div className="flex-1">
                      <code className="text-sm">{endpoint.endpoint}</code>
                      <div className="flex items-center space-x-4 mt-1">
                        <span className="text-xs text-muted-foreground">
                          {endpoint.calls.toLocaleString()} calls
                        </span>
                        <span className="text-xs text-muted-foreground">
                          {endpoint.avgTime}ms avg
                        </span>
                      </div>
                    </div>
                    <Progress
                      value={(endpoint.calls / (metrics.usage.topEndpoints[0]?.calls || 1)) * 100}
                      className="w-24"
                    />
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="security" className="space-y-4">
          {/* Security Metrics */}
          <div className="grid gap-4 md:grid-cols-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Failed Logins</CardTitle>
                <UserX className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {metrics.security.failedLoginAttempts}
                </div>
                <p className="text-xs text-muted-foreground">Last 24 hours</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Blocked IPs</CardTitle>
                <Shield className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{metrics.security.blockedIPs}</div>
                <p className="text-xs text-muted-foreground">Currently blocked</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">2FA Adoption</CardTitle>
                <Lock className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{metrics.security.twoFactorAdoption}%</div>
                <Progress value={metrics.security.twoFactorAdoption} className="mt-2" />
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Security Alerts</CardTitle>
                <AlertTriangle className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{metrics.security.securityAlerts}</div>
                <Badge
                  variant={metrics.security.vulnerabilities > 0 ? 'destructive' : 'success'}
                  className="mt-2"
                >
                  {metrics.security.vulnerabilities} vulnerabilities
                </Badge>
              </CardContent>
            </Card>
          </div>

          {/* Security Trends */}
          <Card>
            <CardHeader>
              <CardTitle>Security Events</CardTitle>
              <CardDescription>Threats and blocked attempts over time</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={metrics.trends.security}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="threats" fill="#ff7c7c" name="Threats" />
                  <Bar dataKey="blocked" fill="#82ca9d" name="Blocked" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Security Summary */}
          <div className="grid gap-4 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>Recent Security Events</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-sm">Password Resets</span>
                    <Badge variant="outline">{metrics.security.passwordResets}</Badge>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm">Account Lockouts</span>
                    <Badge variant="outline">{metrics.security.accountLockouts}</Badge>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm">Suspicious Activities</span>
                    <Badge variant="outline">{metrics.security.suspiciousActivities}</Badge>
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle>Security Recommendations</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {metrics.security.twoFactorAdoption < 50 && (
                    <Alert>
                      <AlertTriangle className="h-4 w-4" />
                      <AlertDescription>
                        Low 2FA adoption. Consider enforcing 2FA for all users.
                      </AlertDescription>
                    </Alert>
                  )}
                  {metrics.security.vulnerabilities > 0 && (
                    <Alert variant="destructive">
                      <AlertTriangle className="h-4 w-4" />
                      <AlertDescription>
                        {metrics.security.vulnerabilities} security vulnerabilities detected.
                      </AlertDescription>
                    </Alert>
                  )}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="usage" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            {/* Login Methods */}
            <Card>
              <CardHeader>
                <CardTitle>Login Methods</CardTitle>
                <CardDescription>Authentication method distribution</CardDescription>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={250}>
                  <PieChart>
                    <Pie
                      data={metrics.usage.loginMethods}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={(entry) => `${entry['method']}: ${entry['count']}`}
                      outerRadius={80}
                      fill="#8884d8"
                      dataKey="count"
                    >
                      {metrics.usage.loginMethods.map((_entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            {/* Device Types */}
            <Card>
              <CardHeader>
                <CardTitle>Device Types</CardTitle>
                <CardDescription>User device distribution</CardDescription>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={250}>
                  <PieChart>
                    <Pie
                      data={metrics.usage.deviceTypes}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={(entry) => `${entry['type']}: ${entry['count']}`}
                      outerRadius={80}
                      fill="#82ca9d"
                      dataKey="count"
                    >
                      {metrics.usage.deviceTypes.map((_entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </div>

          {/* Users by Country */}
          <Card>
            <CardHeader>
              <CardTitle>Geographic Distribution</CardTitle>
              <CardDescription>Users by country</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={metrics.usage.usersByCountry}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="country" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="users" fill="#8884d8" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Browser Types */}
          <Card>
            <CardHeader>
              <CardTitle>Browser Usage</CardTitle>
              <CardDescription>Browser distribution among users</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {metrics.usage.browserTypes.map((browser, index) => (
                  <div key={index} className="flex items-center justify-between">
                    <span className="text-sm">{browser.browser}</span>
                    <div className="flex items-center space-x-2">
                      <Progress
                        value={(browser.count / metrics.overview.totalUsers) * 100}
                        className="w-32"
                      />
                      <span className="text-sm text-muted-foreground">
                        {((browser.count / metrics.overview.totalUsers) * 100).toFixed(1)}%
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="trends" className="space-y-4">
          {/* API Usage Trends */}
          <Card>
            <CardHeader>
              <CardTitle>API Usage Trends</CardTitle>
              <CardDescription>API calls and error rates over time</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={metrics.trends.apiUsage}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis yAxisId="left" />
                  <YAxis yAxisId="right" orientation="right" />
                  <Tooltip />
                  <Legend />
                  <Line
                    yAxisId="left"
                    type="monotone"
                    dataKey="calls"
                    stroke="#8884d8"
                    name="API Calls"
                  />
                  <Line
                    yAxisId="right"
                    type="monotone"
                    dataKey="errors"
                    stroke="#ff7c7c"
                    name="Errors"
                  />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* User Growth Trends */}
          <Card>
            <CardHeader>
              <CardTitle>User Growth</CardTitle>
              <CardDescription>User acquisition and growth metrics</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <AreaChart data={metrics.trends.userGrowth}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Area
                    type="monotone"
                    dataKey="users"
                    stackId="1"
                    stroke="#8884d8"
                    fill="#8884d8"
                    name="Total Users"
                  />
                  <Area
                    type="monotone"
                    dataKey="newUsers"
                    stackId="2"
                    stroke="#82ca9d"
                    fill="#82ca9d"
                    name="New Users"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}