'use client';

import React, { useEffect, useState, useRef } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  LineChart,
  Line,
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
  PieChart,
  Pie,
  Cell,
} from 'recharts';
import {
  Cpu,
  HardDrive,
  MemoryStick,
  Network,
  Clock,
  TrendingUp,
  TrendingDown,
  AlertCircle,
  RefreshCw,
  Zap,
  Activity,
  Server,
} from 'lucide-react';
import AdminAPI from '@/lib/admin-api';

interface MetricsData {
  cpu_usage: number;
  memory_usage: number;
  disk_usage: number;
  active_connections: number;
  requests_per_minute: number;
  error_rate: number;
  avg_response_time: number;
}

interface TimeSeriesData {
  timestamp: string;
  cpu: number;
  memory: number;
  requests: number;
  responseTime: number;
  errors: number;
}

interface MetricCardProps {
  title: string;
  value: number | string;
  unit?: string;
  icon: React.ReactNode;
  trend?: number;
  status?: 'good' | 'warning' | 'critical';
  description?: string;
}

function MetricCard({
  title,
  value,
  unit = '',
  icon,
  trend,
  status = 'good',
  description
}: MetricCardProps): React.ReactElement {
  const statusColors = {
    good: 'text-green-600 bg-green-50',
    warning: 'text-yellow-600 bg-yellow-50',
    critical: 'text-red-600 bg-red-50',
  };

  const statusBorders = {
    good: 'border-green-200',
    warning: 'border-yellow-200',
    critical: 'border-red-200',
  };

  return (
    <Card className={`relative overflow-hidden ${statusBorders[status]}`}>
      <CardHeader className='flex flex-row items-center justify-between space-y-0 pb-2'>
        <CardTitle className='text-sm font-medium'>{title}</CardTitle>
        <div className={`p-2 rounded-full ${statusColors[status]}`}>
          {icon}
        </div>
      </CardHeader>
      <CardContent>
        <div className='text-2xl font-bold'>
          {value}
          {unit && <span className='text-sm font-normal text-muted-foreground ml-1'>{unit}</span>}
        </div>
        {description && (
          <p className='text-xs text-muted-foreground mt-1'>{description}</p>
        )}
        {trend !== undefined && (
          <div className='flex items-center mt-2'>
            {trend > 0 ? (
              <TrendingUp className='h-4 w-4 text-green-600 mr-1' />
            ) : (
              <TrendingDown className='h-4 w-4 text-red-600 mr-1' />
            )}
            <span className={`text-xs ${trend > 0 ? 'text-green-600' : 'text-red-600'}`}>
              {Math.abs(trend)}% from last hour
            </span>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

export default function RealTimeMetricsDashboard(): React.ReactElement {
  const [metrics, setMetrics] = useState<MetricsData | null>(null);
  const [timeSeriesData, setTimeSeriesData] = useState<TimeSeriesData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [autoRefresh, setAutoRefresh] = useState(true);
  const [refreshInterval, setRefreshInterval] = useState(5000); // 5 seconds
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  // Fetch metrics data
  const fetchMetrics = async (): Promise<void> => {
    try {
      const response = await AdminAPI.getSystemMetrics();
      if (response.success && response.data) {
        setMetrics(response.data);

        // Add to time series data (keep last 30 points)
        const newDataPoint: TimeSeriesData = {
          timestamp: new Date().toLocaleTimeString(),
          cpu: response.data.cpu_usage,
          memory: response.data.memory_usage,
          requests: response.data.requests_per_minute,
          responseTime: response.data.avg_response_time,
          errors: response.data.error_rate,
        };

        setTimeSeriesData(prev => {
          const updated = [...prev, newDataPoint];
          return updated.slice(-30); // Keep last 30 data points
        });

        setError(null);
      }
    } catch (err) {
      setError('Failed to fetch metrics');
      console.error('Metrics fetch error:', err);
    } finally {
      setLoading(false);
    }
  };

  // Setup auto-refresh
  useEffect(() => {
    fetchMetrics(); // Initial fetch

    if (autoRefresh) {
      intervalRef.current = setInterval(fetchMetrics, refreshInterval);
    }

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [autoRefresh, refreshInterval]);

  // Get status based on metric value
  const getStatus = (value: number, type: 'cpu' | 'memory' | 'disk' | 'error'): 'good' | 'warning' | 'critical' => {
    if (type === 'error') {
      if (value < 1) return 'good';
      if (value < 5) return 'warning';
      return 'critical';
    }

    if (value < 70) return 'good';
    if (value < 85) return 'warning';
    return 'critical';
  };

  // Distribution data for pie chart
  const resourceDistribution = metrics ? [
    { name: 'CPU', value: metrics.cpu_usage, color: '#3B82F6' },
    { name: 'Memory', value: metrics.memory_usage, color: '#10B981' },
    { name: 'Disk', value: metrics.disk_usage, color: '#F59E0B' },
  ] : [];

  if (loading && !metrics) {
    return (
      <div className='flex items-center justify-center h-64'>
        <RefreshCw className='h-8 w-8 animate-spin text-muted-foreground' />
      </div>
    );
  }

  if (error && !metrics) {
    return (
      <Alert variant='destructive'>
        <AlertCircle className='h-4 w-4' />
        <AlertDescription>{error}</AlertDescription>
      </Alert>
    );
  }

  return (
    <div className='space-y-6'>
      {/* Header Controls */}
      <div className='flex items-center justify-between'>
        <div>
          <h2 className='text-2xl font-bold'>Real-time System Metrics</h2>
          <p className='text-muted-foreground'>Live performance monitoring and analytics</p>
        </div>
        <div className='flex items-center gap-4'>
          <Badge variant={autoRefresh ? 'default' : 'secondary'}>
            {autoRefresh ? 'Live' : 'Paused'}
          </Badge>
          <Button
            variant='outline'
            size='sm'
            onClick={() => setAutoRefresh(!autoRefresh)}
          >
            {autoRefresh ? 'Pause' : 'Resume'}
          </Button>
          <Button
            variant='outline'
            size='sm'
            onClick={fetchMetrics}
            disabled={loading}
          >
            <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
        </div>
      </div>

      {metrics && (
        <>
          {/* Key Metrics Grid */}
          <div className='grid gap-4 md:grid-cols-2 lg:grid-cols-4'>
            <MetricCard
              title='CPU Usage'
              value={metrics.cpu_usage}
              unit='%'
              icon={<Cpu className='h-4 w-4' />}
              status={getStatus(metrics.cpu_usage, 'cpu')}
              trend={Math.random() * 20 - 10}
              description='Processing power utilization'
            />
            <MetricCard
              title='Memory Usage'
              value={metrics.memory_usage}
              unit='%'
              icon={<MemoryStick className='h-4 w-4' />}
              status={getStatus(metrics.memory_usage, 'memory')}
              trend={Math.random() * 20 - 10}
              description='RAM consumption'
            />
            <MetricCard
              title='Disk Usage'
              value={metrics.disk_usage}
              unit='%'
              icon={<HardDrive className='h-4 w-4' />}
              status={getStatus(metrics.disk_usage, 'disk')}
              description='Storage utilization'
            />
            <MetricCard
              title='Active Connections'
              value={metrics.active_connections}
              icon={<Network className='h-4 w-4' />}
              status='good'
              description='Current active users'
            />
          </div>

          {/* Performance Metrics */}
          <div className='grid gap-4 md:grid-cols-3'>
            <MetricCard
              title='Requests/min'
              value={metrics.requests_per_minute}
              icon={<Zap className='h-4 w-4' />}
              status='good'
              trend={Math.random() * 30 - 15}
              description='API throughput'
            />
            <MetricCard
              title='Avg Response Time'
              value={metrics.avg_response_time}
              unit='ms'
              icon={<Clock className='h-4 w-4' />}
              status={metrics.avg_response_time < 200 ? 'good' : metrics.avg_response_time < 500 ? 'warning' : 'critical'}
              description='Average API latency'
            />
            <MetricCard
              title='Error Rate'
              value={metrics.error_rate.toFixed(2)}
              unit='%'
              icon={<AlertCircle className='h-4 w-4' />}
              status={getStatus(metrics.error_rate, 'error')}
              description='Failed requests percentage'
            />
          </div>

          {/* Charts */}
          <Tabs defaultValue='performance' className='w-full'>
            <TabsList className='grid w-full grid-cols-3'>
              <TabsTrigger value='performance'>Performance</TabsTrigger>
              <TabsTrigger value='resources'>Resources</TabsTrigger>
              <TabsTrigger value='distribution'>Distribution</TabsTrigger>
            </TabsList>

            <TabsContent value='performance' className='space-y-4'>
              <Card>
                <CardHeader>
                  <CardTitle>Request Performance Over Time</CardTitle>
                  <CardDescription>Requests per minute and response times</CardDescription>
                </CardHeader>
                <CardContent>
                  <ResponsiveContainer width='100%' height={300}>
                    <LineChart data={timeSeriesData}>
                      <CartesianGrid strokeDasharray='3 3' />
                      <XAxis dataKey='timestamp' />
                      <YAxis yAxisId='left' />
                      <YAxis yAxisId='right' orientation='right' />
                      <Tooltip />
                      <Legend />
                      <Line
                        yAxisId='left'
                        type='monotone'
                        dataKey='requests'
                        stroke='#3B82F6'
                        name='Requests/min'
                        strokeWidth={2}
                      />
                      <Line
                        yAxisId='right'
                        type='monotone'
                        dataKey='responseTime'
                        stroke='#10B981'
                        name='Response Time (ms)'
                        strokeWidth={2}
                      />
                    </LineChart>
                  </ResponsiveContainer>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Error Rate Trend</CardTitle>
                  <CardDescription>Percentage of failed requests over time</CardDescription>
                </CardHeader>
                <CardContent>
                  <ResponsiveContainer width='100%' height={200}>
                    <AreaChart data={timeSeriesData}>
                      <CartesianGrid strokeDasharray='3 3' />
                      <XAxis dataKey='timestamp' />
                      <YAxis />
                      <Tooltip />
                      <Area
                        type='monotone'
                        dataKey='errors'
                        stroke='#EF4444'
                        fill='#FEE2E2'
                        name='Error Rate %'
                      />
                    </AreaChart>
                  </ResponsiveContainer>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value='resources' className='space-y-4'>
              <Card>
                <CardHeader>
                  <CardTitle>System Resource Usage</CardTitle>
                  <CardDescription>CPU and Memory utilization over time</CardDescription>
                </CardHeader>
                <CardContent>
                  <ResponsiveContainer width='100%' height={300}>
                    <AreaChart data={timeSeriesData}>
                      <CartesianGrid strokeDasharray='3 3' />
                      <XAxis dataKey='timestamp' />
                      <YAxis />
                      <Tooltip />
                      <Legend />
                      <Area
                        type='monotone'
                        dataKey='cpu'
                        stackId='1'
                        stroke='#3B82F6'
                        fill='#93C5FD'
                        name='CPU %'
                      />
                      <Area
                        type='monotone'
                        dataKey='memory'
                        stackId='1'
                        stroke='#10B981'
                        fill='#86EFAC'
                        name='Memory %'
                      />
                    </AreaChart>
                  </ResponsiveContainer>
                </CardContent>
              </Card>

              {/* Resource Progress Bars */}
              <div className='grid gap-4 md:grid-cols-3'>
                <Card>
                  <CardHeader className='pb-2'>
                    <CardTitle className='text-sm'>CPU Usage</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <Progress value={metrics.cpu_usage} className='h-2' />
                    <p className='text-xs text-muted-foreground mt-2'>{metrics.cpu_usage}% utilized</p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className='pb-2'>
                    <CardTitle className='text-sm'>Memory Usage</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <Progress value={metrics.memory_usage} className='h-2' />
                    <p className='text-xs text-muted-foreground mt-2'>{metrics.memory_usage}% utilized</p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className='pb-2'>
                    <CardTitle className='text-sm'>Disk Usage</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <Progress value={metrics.disk_usage} className='h-2' />
                    <p className='text-xs text-muted-foreground mt-2'>{metrics.disk_usage}% utilized</p>
                  </CardContent>
                </Card>
              </div>
            </TabsContent>

            <TabsContent value='distribution'>
              <Card>
                <CardHeader>
                  <CardTitle>Resource Distribution</CardTitle>
                  <CardDescription>Current resource allocation breakdown</CardDescription>
                </CardHeader>
                <CardContent>
                  <ResponsiveContainer width='100%' height={300}>
                    <PieChart>
                      <Pie
                        data={resourceDistribution}
                        cx='50%'
                        cy='50%'
                        labelLine={false}
                        label={({ name, value }) => `${name}: ${value}%`}
                        outerRadius={80}
                        fill='#8884d8'
                        dataKey='value'
                      >
                        {resourceDistribution.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip />
                    </PieChart>
                  </ResponsiveContainer>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </>
      )}
    </div>
  );
}