'use client';

import { useMemo } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { TrendingUp, TrendingDown, Activity } from 'lucide-react';

// TODO: Replace with actual charting library (e.g., Recharts, Chart.js, D3)
// For now, this is a placeholder component that shows the structure

interface DataSeries {
  name: string;
  data: Array<{ x: string | number; y: number; metadata?: Record<string, unknown> }>;
  color?: string;
  strokeWidth?: number;
  fill?: boolean;
}

interface LineChartProps {
  series: DataSeries[];
  title?: string;
  description?: string;
  showTrend?: boolean;
  height?: number;
  className?: string;
  showGrid?: boolean;
  showTooltip?: boolean;
  showLegend?: boolean;
  timeRange?: string;
  onTimeRangeChange?: (range: string) => void;
  formatValue?: (value: number) => string;
  formatXAxis?: (value: string | number) => string;
}

const timeRangeOptions = [
  { label: 'Last 7 days', value: '7d' },
  { label: 'Last 30 days', value: '30d' },
  { label: 'Last 90 days', value: '90d' },
  { label: 'Last 12 months', value: '12m' },
];

export function LineChart({
  series,
  title,
  description,
  showTrend = false,
  height = 300,
  className,
  showGrid = true,
  // _showTooltip = true,
  showLegend = true,
  timeRange,
  onTimeRangeChange,
  formatValue = (value) => value.toString(),
  formatXAxis = (value) => value.toString(),
}: LineChartProps) {
  const { maxValue, minValue, trend } = useMemo(() => {
    if (!series.length) return { maxValue: 0, minValue: 0, trend: 0 };
    
    const allValues = series.flatMap(s => s.data.map(d => d.y));
    const max = Math.max(...allValues);
    const min = Math.min(...allValues);
    
    // Calculate trend for the first series
    const firstSeries = series[0];
    let trendValue = 0;
    if (firstSeries && firstSeries.data && firstSeries.data.length > 1) {
      const first = firstSeries.data[0]?.y;
      const last = firstSeries.data[firstSeries.data.length - 1]?.y;
      if (first && last) {
        trendValue = ((last - first) / first) * 100;
      }
    }
    
    return { maxValue: max, minValue: min, trend: trendValue };
  }, [series]);

  const isPositiveTrend = trend > 0;

  if (!series.length || !series[0]?.data.length) {
    return (
      <Card className={className}>
        <CardHeader>
          {title && <CardTitle>{title}</CardTitle>}
          {description && <CardDescription>{description}</CardDescription>}
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-center h-64 text-muted-foreground">
            <div className="text-center">
              <Activity className="h-8 w-8 mx-auto mb-2 opacity-50" />
              <p className="text-sm">No data available</p>
            </div>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            {title && (
              <CardTitle className="flex items-center gap-2">
                <Activity className="h-5 w-5" />
                {title}
              </CardTitle>
            )}
            {description && <CardDescription>{description}</CardDescription>}
          </div>
          <div className="flex items-center gap-2">
            {showTrend && (
              <Badge variant={isPositiveTrend ? 'default' : 'destructive'}>
                {isPositiveTrend ? (
                  <TrendingUp className="h-3 w-3 mr-1" />
                ) : (
                  <TrendingDown className="h-3 w-3 mr-1" />
                )}
                {Math.abs(trend).toFixed(1)}%
              </Badge>
            )}
            {timeRange && onTimeRangeChange && (
              <Select value={timeRange} onValueChange={onTimeRangeChange}>
                <SelectTrigger className="w-32">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {timeRangeOptions.map(option => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            )}
          </div>
        </div>
      </CardHeader>
      <CardContent>
        {/* Chart Placeholder - TODO: Replace with actual chart library */}
        <div 
          className="relative w-full border rounded-lg bg-muted/20 p-4"
          style={{ height }}
        >
          {/* Simple SVG-based line chart for demonstration */}
          <svg
            width="100%"
            height="100%"
            viewBox={`0 0 400 ${height - 32}`}
            className="overflow-visible"
          >
            {/* Grid lines */}
            {showGrid && (
              <g className="opacity-20">
                {/* Horizontal grid lines */}
                {Array.from({ length: 5 }).map((_, i) => (
                  <line
                    key={`h-${i}`}
                    x1="0"
                    y1={(i / 4) * (height - 32)}
                    x2="400"
                    y2={(i / 4) * (height - 32)}
                    stroke="currentColor"
                    strokeWidth="1"
                  />
                ))}
                {/* Vertical grid lines */}
                {Array.from({ length: 6 }).map((_, i) => (
                  <line
                    key={`v-${i}`}
                    x1={(i / 5) * 400}
                    y1="0"
                    x2={(i / 5) * 400}
                    y2={height - 32}
                    stroke="currentColor"
                    strokeWidth="1"
                  />
                ))}
              </g>
            )}

            {/* Data series */}
            {series.map((serie, serieIndex) => {
              const points = serie.data.map((point, i) => ({
                x: (i / Math.max(serie.data.length - 1, 1)) * 400,
                y: ((maxValue - point.y) / Math.max(maxValue - minValue, 1)) * (height - 32),
              }));

              const pathData = points
                .map((point, i) => `${i === 0 ? 'M' : 'L'} ${point.x} ${point.y}`)
                .join(' ');

              return (
                <g key={serieIndex}>
                  {/* Line */}
                  <path
                    d={pathData}
                    fill="none"
                    stroke={serie.color || `hsl(${serieIndex * 60}, 70%, 50%)`}
                    strokeWidth={serie.strokeWidth || 2}
                    className="transition-all hover:stroke-width-3"
                  />
                  
                  {/* Data points */}
                  {points.map((point, i) => (
                    <circle
                      key={i}
                      cx={point.x}
                      cy={point.y}
                      r="3"
                      fill={serie.color || `hsl(${serieIndex * 60}, 70%, 50%)`}
                      className="transition-all hover:r-4"
                    />
                  ))}

                  {/* Fill area (if enabled) */}
                  {serie.fill && (
                    <path
                      d={`${pathData} L 400 ${height - 32} L 0 ${height - 32} Z`}
                      fill={serie.color || `hsl(${serieIndex * 60}, 70%, 50%)`}
                      fillOpacity="0.1"
                    />
                  )}
                </g>
              );
            })}
          </svg>

          {/* Y-axis labels */}
          <div className="absolute left-0 top-0 h-full flex flex-col justify-between text-xs text-muted-foreground -ml-12">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="text-right">
                {formatValue(maxValue - (i / 4) * (maxValue - minValue))}
              </div>
            ))}
          </div>
        </div>

        {/* X-axis labels */}
        {series[0] && (
          <div className="flex justify-between mt-2 text-xs text-muted-foreground">
            {series[0].data.map((point, i) => (
              <div key={i} className="text-center">
                {formatXAxis(point.x)}
              </div>
            ))}
          </div>
        )}

        {/* Legend */}
        {showLegend && series.length > 1 && (
          <div className="flex flex-wrap gap-4 mt-4 pt-4 border-t">
            {series.map((serie, index) => (
              <div key={index} className="flex items-center gap-2">
                <div
                  className="w-3 h-3 rounded-sm"
                  style={{ backgroundColor: serie.color || `hsl(${index * 60}, 70%, 50%)` }}
                />
                <span className="text-sm text-muted-foreground">{serie.name}</span>
              </div>
            ))}
          </div>
        )}

        {/* Summary Statistics */}
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mt-4 pt-4 border-t">
          <div className="text-center">
            <div className="text-sm font-medium">{formatValue(maxValue)}</div>
            <div className="text-xs text-muted-foreground">Peak</div>
          </div>
          <div className="text-center">
            <div className="text-sm font-medium">{formatValue(minValue)}</div>
            <div className="text-xs text-muted-foreground">Low</div>
          </div>
          <div className="text-center">
            <div className="text-sm font-medium">
              {formatValue((maxValue + minValue) / 2)}
            </div>
            <div className="text-xs text-muted-foreground">Average</div>
          </div>
        </div>

        {/* Development Note */}
        <div className="mt-4 p-2 bg-yellow-50 border border-yellow-200 rounded-md">
          <p className="text-xs text-yellow-800">
            <strong>TODO:</strong> Replace with actual chart library (Recharts, Chart.js, or D3) for production use.
            This is a placeholder implementation for demonstration.
          </p>
        </div>
      </CardContent>
    </Card>
  );
}

// Pre-configured line chart components for common use cases
export function SimpleLineChart({ 
  data, 
  title 
}: { 
  data: Array<{ x: string | number; y: number }>; 
  title?: string;
}) {
  const series: DataSeries[] = [
    {
      name: 'Data',
      data,
    },
  ];

  return (
    <LineChart
      series={series}
      {...(title ? { title } : {})}
      height={200}
      showTrend={false}
      showGrid={false}
      showLegend={false}
    />
  );
}

export function TrendLineChart({ 
  data, 
  title,
  timeRange,
  onTimeRangeChange,
}: { 
  data: Array<{ x: string | number; y: number }>; 
  title?: string;
  timeRange?: string;
  onTimeRangeChange?: (range: string) => void;
}) {
  const series: DataSeries[] = [
    {
      name: 'Trend',
      data,
      fill: true,
    },
  ];

  return (
    <LineChart
      series={series}
      {...(title ? { title } : {})}
      height={300}
      showTrend={true}
      showGrid={true}
      {...(timeRange ? { timeRange } : {})}
      {...(onTimeRangeChange ? { onTimeRangeChange } : {})}
    />
  );
}

export function MultiSeriesLineChart({ 
  series, 
  title,
  timeRange,
  onTimeRangeChange,
}: { 
  series: DataSeries[];
  title?: string;
  timeRange?: string;
  onTimeRangeChange?: (range: string) => void;
}) {
  return (
    <LineChart
      series={series}
      {...(title ? { title } : {})}
      height={350}
      showTrend={true}
      showGrid={true}
      showLegend={true}
      {...(timeRange ? { timeRange } : {})}
      {...(onTimeRangeChange ? { onTimeRangeChange } : {})}
    />
  );
}