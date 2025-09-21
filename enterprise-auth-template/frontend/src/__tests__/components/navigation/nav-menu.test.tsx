
import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import { NavMenu } from '@/components/navigation/nav-menu';

// Mock Next.js navigation
jest.mock('next/navigation', () => ({
  usePathname: jest.fn(() => '/dashboard'),
}));

describe('NavMenu Component', () => {
  it('should render navigation menu', () => {
    render(<NavMenu />);

    // Check for common navigation items that should be present
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
  });

  it('should highlight active dashboard item', () => {
    render(<NavMenu />);

    // Dashboard should be active based on mocked pathname
    const dashboardLink = screen.getByText('Dashboard').closest('a');
    expect(dashboardLink).toHaveClass('bg-accent');
  });

  it('should handle navigation callback', () => {
    const handleNavigate = jest.fn();
    render(<NavMenu onNavigate={handleNavigate} />);

    // Click on a navigation item
    act(() => {
      const dashboardLink = screen.getByText('Dashboard');
      fireEvent.click(dashboardLink);
    });

    // Check if navigation was triggered
    expect(handleNavigate).toHaveBeenCalledWith('/dashboard');
  });

  it('should render with custom className', () => {
    const customClass = 'custom-nav-class';
    render(<NavMenu className={customClass} />);

    // Check if the nav element has the custom class
    const navElement = screen.getByRole('navigation');
    expect(navElement).toHaveClass(customClass);
  });

  it('should show different navigation sections', () => {
    render(<NavMenu />);

    // Check for presence of key navigation sections
    expect(screen.getByText('Dashboard')).toBeInTheDocument();

    // Use getAllByText for items that might appear multiple times
    const settingsElements = screen.getAllByText('Settings');
    expect(settingsElements.length).toBeGreaterThan(0);
  });
});
