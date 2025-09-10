'use client';

import { useMemo } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { BarChart3, TrendingUp, TrendingDown } from 'lucide-react';

// TODO: Replace with actual charting library (e.g., Recharts, Chart.js, D3)
// For now, this is a placeholder component that shows the structure

interface DataPoint {
  label: string;
  value: number;
  color?: string;
  metadata?: Record<string, unknown>;
}

interface BarChartProps {
  data: DataPoint[];
  title?: string;
  description?: string;
  showTrend?: boolean;
  height?: number;
  className?: string;
  orientation?: 'horizontal' | 'vertical';
  showGrid?: boolean;
  showTooltip?: boolean;
  showLegend?: boolean;
  formatValue?: (value: number) => string;
}

export function BarChart({
  data,
  title,
  description,
  showTrend = false,
  height = 300,
  className,
  orientation = 'vertical',
  showGrid = true,
  // _showTooltip = true,
  showLegend = false,
  formatValue = (value) => value.toString(),
}: BarChartProps) {
  const maxValue = useMemo(() => Math.max(...data.map(d => d.value)), [data]);
  const minValue = useMemo(() => Math.min(...data.map(d => d.value)), [data]);
  const totalValue = useMemo(() => data.reduce((sum, d) => sum + d.value, 0), [data]);
  
  // Calculate trend (simplified - comparing first and last values)
  const trendPercentage = useMemo(() => {
    if (data.length < 2) return 0;
    const first = data[0]?.value;
    const last = data[data.length - 1]?.value;
    if (!first || !last) return 0;
    return ((last - first) / first) * 100;
  }, [data]);

  const isPositiveTrend = trendPercentage > 0;

  if (!data.length) {
    return (
      <Card className={className}>
        <CardHeader>
          {title && <CardTitle>{title}</CardTitle>}
          {description && <CardDescription>{description}</CardDescription>}
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-center h-64 text-muted-foreground">
            <div className="text-center">
              <BarChart3 className="h-8 w-8 mx-auto mb-2 opacity-50" />
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
                <BarChart3 className="h-5 w-5" />
                {title}
              </CardTitle>
            )}
            {description && <CardDescription>{description}</CardDescription>}
          </div>
          {showTrend && (
            <div className="flex items-center gap-2">
              <Badge variant={isPositiveTrend ? 'default' : 'destructive'}>
                {isPositiveTrend ? (
                  <TrendingUp className="h-3 w-3 mr-1" />
                ) : (
                  <TrendingDown className="h-3 w-3 mr-1" />
                )}
                {Math.abs(trendPercentage).toFixed(1)}%
              </Badge>
            </div>
          )}
        </div>
      </CardHeader>
      <CardContent>
        {/* Chart Placeholder - TODO: Replace with actual chart library */}
        <div 
          className="relative w-full border rounded-lg bg-muted/20 p-4"
          style={{ height }}
        >
          {/* Simple CSS-based bar chart for demonstration */}
          <div className={`flex ${orientation === 'horizontal' ? 'flex-col' : 'flex-row'} items-end justify-between h-full gap-2`}>
            {data.map((point, index) => {
              const percentage = (point.value / maxValue) * 100;
              return (
                <div
                  key={index}
                  className="flex flex-col items-center gap-1 flex-1"
                  title={`${point.label}: ${formatValue(point.value)}`}
                >
                  {orientation === 'vertical' && (
                    <div className="text-xs text-muted-foreground">
                      {formatValue(point.value)}
                    </div>
                  )}
                  <div
                    className={`bg-primary rounded-sm transition-all hover:bg-primary/80 ${
                      orientation === 'horizontal' ? 'h-4 w-full' : 'w-8'
                    }`}
                    style={{
                      [orientation === 'horizontal' ? 'width' : 'height']: `${percentage}%`,
                      backgroundColor: point.color || undefined,
                    }}
                  />
                  <div className="text-xs text-muted-foreground text-center max-w-16 truncate">
                    {point.label}
                  </div>
                  {orientation === 'horizontal' && (
                    <div className="text-xs text-muted-foreground">
                      {formatValue(point.value)}
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          {/* Grid lines placeholder */}
          {showGrid && (
            <div className="absolute inset-0 pointer-events-none">
              {/* Horizontal grid lines */}
              {Array.from({ length: 5 }).map((_, i) => (
                <div
                  key={i}
                  className="absolute left-0 right-0 border-t border-muted-foreground/10"
                  style={{ top: `${(i / 4) * 100}%` }}
                />
              ))}
            </div>
          )}
        </div>

        {/* Summary Statistics */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-4 pt-4 border-t">
          <div className="text-center">
            <div className="text-sm font-medium">{formatValue(totalValue)}</div>
            <div className="text-xs text-muted-foreground">Total</div>
          </div>
          <div className="text-center">
            <div className="text-sm font-medium">{formatValue(maxValue)}</div>
            <div className="text-xs text-muted-foreground">Max</div>
          </div>
          <div className="text-center">
            <div className="text-sm font-medium">{formatValue(minValue)}</div>
            <div className="text-xs text-muted-foreground">Min</div>
          </div>
          <div className="text-center">
            <div className="text-sm font-medium">{formatValue(totalValue / data.length)}</div>
            <div className="text-xs text-muted-foreground">Average</div>
          </div>
        </div>

        {/* Legend */}
        {showLegend && (
          <div className="flex flex-wrap gap-2 mt-4 pt-4 border-t">
            {data.map((point, index) => (
              <div key={index} className="flex items-center gap-2">
                <div
                  className="w-3 h-3 rounded-sm"
                  style={{ backgroundColor: point.color || '#3b82f6' }}
                />
                <span className="text-xs text-muted-foreground">{point.label}</span>
              </div>
            ))}
          </div>
        )}

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

// Pre-configured bar chart components for common use cases
export function SimpleBarChart({ data, title }: { data: DataPoint[]; title?: string }) {
  return (
    <BarChart
      data={data}
      {...(title ? { title } : {})}
      height={200}
      showTrend={false}
      showGrid={false}
      showLegend={false}
    />
  );
}

export function TrendingBarChart({ data, title }: { data: DataPoint[]; title?: string }) {
  return (
    <BarChart
      data={data}
      {...(title ? { title } : {})}
      height={300}
      showTrend={true}
      showGrid={true}
      orientation="vertical"
    />
  );
}