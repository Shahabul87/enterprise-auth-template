
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { NavMenu } from '@/components/navigation/nav-menu';
describe('NavMenu Component', () => {
  const menuItems = [
    { label: 'Dashboard', href: '/dashboard', icon: 'home' },
    { label: 'Profile', href: '/profile', icon: 'user' },
    { label: 'Settings', href: '/settings', icon: 'settings' },
  ];

  it('should render all menu items', () => {
    render(<NavMenu items={menuItems} />);
    menuItems.forEach(item => {
      expect(screen.getByText(item.label)).toBeInTheDocument();
    });
  });

  it('should highlight active item', () => {
    render(<NavMenu items={menuItems} activeItem="/profile" />);
    const profileItem = screen.getByText('Profile').closest('a');
    expect(profileItem).toHaveClass('active');
  });

  it('should handle item click', () => {
    const handleClick = jest.fn();
    render(<NavMenu items={menuItems} onItemClick={handleClick} />);

    act(() => { fireEvent.click(screen.getByText('Dashboard') }));
    expect(handleClick).toHaveBeenCalledWith('/dashboard');
  });

  it('should render icons when provided', () => {
    render(<NavMenu items={menuItems} />);
    const icons = screen.getAllByTestId(/icon-/);
    expect(icons).toHaveLength(menuItems.length);
  });
});
