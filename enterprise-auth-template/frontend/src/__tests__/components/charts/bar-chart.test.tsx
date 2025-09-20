
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { BarChart, SimpleBarChart, TrendingBarChart } from '@/components/charts/bar-chart';


describe('BarChart Component', () => {
  const mockData = [
    { label: 'Jan', value: 100 },
    { label: 'Feb', value: 200 },
    { label: 'Mar', value: 150 },
  ];

  it('should render chart with data', () => {
    render(<BarChart data={mockData} title="Test Chart" />);
    // Check for chart title
    expect(screen.getByText('Test Chart')).toBeInTheDocument();
    // Check for data labels
    expect(screen.getByText('Jan')).toBeInTheDocument();
    expect(screen.getByText('Feb')).toBeInTheDocument();
    expect(screen.getByText('Mar')).toBeInTheDocument();
  });

  it('should render summary statistics', () => {
    const { container } = render(<BarChart data={mockData} />);
    // Check for summary statistics labels
    expect(screen.getByText('Total')).toBeInTheDocument();
    expect(screen.getByText('Max')).toBeInTheDocument();
    expect(screen.getByText('Min')).toBeInTheDocument();
    expect(screen.getByText('Average')).toBeInTheDocument();

    // Check that statistics section exists with the expected structure
    const statsSection = container.querySelector('.grid.grid-cols-2.md\\:grid-cols-4');
    expect(statsSection).toBeInTheDocument();

    // Verify that we have 4 stat items
    const statItems = statsSection?.querySelectorAll('.text-center');
    expect(statItems).toHaveLength(4);
  });

  it('should handle empty data', () => {
    render(<BarChart data={[]} />);
    expect(screen.getByText('No data available')).toBeInTheDocument();
  });

  it('should render with custom colors in data points', () => {
    const dataWithColors = [
      { label: 'Jan', value: 100, color: '#FF5733' },
      { label: 'Feb', value: 200, color: '#33FF57' },
    ];

    const { container } = render(<BarChart data={dataWithColors} />);
    // Check that bars are rendered with custom colors via inline styles
    const bars = container.querySelectorAll('[style*="background-color"]');
    expect(bars.length).toBeGreaterThan(0);
  });

  it('should render SimpleBarChart variant', () => {
    render(<SimpleBarChart data={mockData} title="Simple Chart" />);
    expect(screen.getByText('Simple Chart')).toBeInTheDocument();
  });

  it('should render TrendingBarChart variant', () => {
    render(<TrendingBarChart data={mockData} title="Trending Chart" />);
    expect(screen.getByText('Trending Chart')).toBeInTheDocument();
  });
});
