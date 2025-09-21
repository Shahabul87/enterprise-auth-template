
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { UserModal } from '@/components/modals/user-modal';
describe('UserModal Component', () => {
  const mockUser = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'admin',
  };

  it('should render modal when open', () => {
    render(<UserModal isOpen={true} user={mockUser} onClose={jest.fn()} />);
    expect(screen.getByText('User Details')).toBeInTheDocument();
  });

  it('should not render when closed', () => {
    render(<UserModal isOpen={false} user={mockUser} onClose={jest.fn()} />);
    expect(screen.queryByText('User Details')).not.toBeInTheDocument();
  });

  it('should display user information', () => {
    render(<UserModal isOpen={true} user={mockUser} onClose={jest.fn()} />);
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
    expect(screen.getByText('admin')).toBeInTheDocument();
  });

  it('should call onClose when close button is clicked', () => {
    const handleClose = jest.fn();
    render(<UserModal isOpen={true} user={mockUser} onClose={handleClose} />);

    act(() => { fireEvent.click(screen.getByRole('button', { name: 'Close' }) }));
    expect(handleClose).toHaveBeenCalledTimes(1);
  });

  it('should handle edit mode', () => {
    const handleSave = jest.fn();
    render(
      <UserModal
        isOpen={true}
        user={mockUser}
        mode="edit"
        onSave={handleSave}
        onClose={jest.fn()}
      />
    );

    expect(screen.getByLabelText('Name')).toHaveValue('John Doe');
    expect(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
  });
});
