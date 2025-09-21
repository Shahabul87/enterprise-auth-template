
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { LineChart, SimpleLineChart } from '@/components/charts/line-chart';
describe('LineChart Component', () => {
  const mockSeries = [
    {
      name: 'Series 1',
      data: [
        { x: 'Jan', y: 10 },
        { x: 'Feb', y: 20 },
        { x: 'Mar', y: 15 },
      ],
    },
  ];

  const multipleSeries = [
    {
      name: 'Series 1',
      data: [
        { x: 'Jan', y: 10 },
        { x: 'Feb', y: 20 },
        { x: 'Mar', y: 15 },
      ],
    },
    {
      name: 'Series 2',
      data: [
        { x: 'Jan', y: 15 },
        { x: 'Feb', y: 25 },
        { x: 'Mar', y: 20 },
      ],
    },
  ];

  it('should render chart with data', () => {
    render(<LineChart series={mockSeries} title="Test Line Chart" />);
    // Check for chart title
    expect(screen.getByText('Test Line Chart')).toBeInTheDocument();
    // Check for statistics
    expect(screen.getByText('Peak')).toBeInTheDocument();
    expect(screen.getByText('Low')).toBeInTheDocument();
    expect(screen.getByText('Average')).toBeInTheDocument();
  });

  it('should handle empty data', () => {
    render(<LineChart series={[]} />);
    expect(screen.getByText('No data available')).toBeInTheDocument();
  });

  it('should handle empty series data', () => {
    render(<LineChart series={[{ name: 'Empty', data: [] }]} />);
    expect(screen.getByText('No data available')).toBeInTheDocument();
  });

  it('should render SimpleLineChart variant', () => {
    const simpleData = [
      { x: 'Jan', y: 10 },
      { x: 'Feb', y: 20 },
      { x: 'Mar', y: 15 },
    ];
    render(<SimpleLineChart data={simpleData} title="Simple Line Chart" />);
    expect(screen.getByText('Simple Line Chart')).toBeInTheDocument();
  });

  it('should render multiple series', () => {
    render(<LineChart series={multipleSeries} title="Comparison Chart" showLegend={true} />);
    expect(screen.getByText('Comparison Chart')).toBeInTheDocument();
    // Check for multiple series in legend
    expect(screen.getByText('Series 1')).toBeInTheDocument();
    expect(screen.getByText('Series 2')).toBeInTheDocument();
  });
});
