
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { SimpleBreadcrumbs } from '@/components/navigation/breadcrumbs';
// Mock next/navigation
jest.mock('next/navigation', () => ({
  usePathname: () => '/settings/profile',
}));

/**
 * @jest-environment jsdom
 */


describe('Breadcrumbs Component', () => {
  const pages = [
    { name: 'Home', href: '/' },
    { name: 'Settings', href: '/settings' },
    { name: 'Profile' }, // No href for current page
  ];

  it('should render all breadcrumb items', () => {
    render(<SimpleBreadcrumbs pages={pages} />);
    pages.forEach(page => {
      expect(screen.getByText(page.name)).toBeInTheDocument();
    });
  });

  it('should render links for non-current items', () => {
    render(<SimpleBreadcrumbs pages={pages} />);
    const homeLink = screen.getByRole('link', { name: 'Home' });
    expect(homeLink).toHaveAttribute('href', '/');
    const settingsLink = screen.getByRole('link', { name: 'Settings' });
    expect(settingsLink).toHaveAttribute('href', '/settings');
  });

  it('should render current item without link', () => {
    render(<SimpleBreadcrumbs pages={pages} />);
    const profileItem = screen.getByText('Profile');
    // Profile should be a span, not a link
    expect(profileItem.tagName.toLowerCase()).toBe('span');
    expect(profileItem.closest('a')).toBeNull();
  });

  it('should render separators between items', () => {
    const { container } = render(<SimpleBreadcrumbs pages={pages} />);
    // Looking for ChevronRight icons as separators
    const separators = container.querySelectorAll('svg');
    // Should have n-1 separators for n items
    expect(separators.length).toBe(pages.length - 1);
  });

  it('should handle single item', () => {
    render(<SimpleBreadcrumbs pages={[{ name: 'Home', href: '/' }]} />);
    expect(screen.getByText('Home')).toBeInTheDocument();
    // No separators for single item
    const { container } = render(<SimpleBreadcrumbs pages={[{ name: 'Home', href: '/' }]} />);
    const separators = container.querySelectorAll('svg');
    expect(separators.length).toBe(0);
  });
});
