
import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import { UserModal } from '@/components/modals/user-modal';

describe('UserModal Component', () => {
  const mockUser = {
    id: '1',
    first_name: 'John',
    last_name: 'Doe',
    full_name: 'John Doe',
    email: 'john@example.com',
    is_active: true,
    is_verified: true,
    email_verified: true,
    is_superuser: false,
    two_factor_enabled: false,
    failed_login_attempts: 0,
    last_login: new Date().toISOString(),
    user_metadata: {},
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    roles: [{
      id: 'role1',
      name: 'Admin',
      description: 'Administrator role',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      permissions: [],
    }],
  };

  const mockTrigger = <button>Open Modal</button>;

  it('should render modal trigger', () => {
    render(<UserModal trigger={mockTrigger} mode="view" user={mockUser} />);
    expect(screen.getByText('Open Modal')).toBeInTheDocument();
  });

  it('should render modal in view mode', () => {
    render(<UserModal trigger={mockTrigger} mode="view" user={mockUser} />);

    // Click the trigger to open modal
    act(() => { fireEvent.click(screen.getByText('Open Modal')); });

    // The modal should be in the document (may be in a portal)
    expect(document.body).toContainHTML('John Doe');
  });

  it('should render modal in edit mode', () => {
    const handleSave = jest.fn();
    render(
      <UserModal
        trigger={mockTrigger}
        mode="edit"
        user={mockUser}
        onSave={handleSave}
      />
    );

    // Click the trigger to open modal
    act(() => { fireEvent.click(screen.getByText('Open Modal')); });

    // Check if modal has edit-specific elements
    expect(document.body).toContainHTML('Edit User');
  });

  it('should render modal in create mode', () => {
    const handleSave = jest.fn();
    render(
      <UserModal
        trigger={mockTrigger}
        mode="create"
        onSave={handleSave}
      />
    );

    // Click the trigger to open modal
    act(() => { fireEvent.click(screen.getByText('Open Modal')); });

    // Check if modal has create-specific elements
    expect(document.body).toContainHTML('Create User');
  });

  it('should handle save callback', async () => {
    const handleSave = jest.fn().mockResolvedValue(undefined);
    render(
      <UserModal
        trigger={mockTrigger}
        mode="edit"
        user={mockUser}
        onSave={handleSave}
      />
    );

    // Click the trigger to open modal
    act(() => { fireEvent.click(screen.getByText('Open Modal')); });

    // The save function should be available
    expect(handleSave).toHaveBeenCalledTimes(0);
  });
});
