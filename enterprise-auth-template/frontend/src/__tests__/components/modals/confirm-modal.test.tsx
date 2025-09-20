
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { ConfirmModal } from '@/components/modals/confirm-modal';


describe('ConfirmModal Component', () => {
  const defaultProps = {
    isOpen: true,
    title: 'Confirm Action',
    message: 'Are you sure you want to proceed?',
    onConfirm: jest.fn(),
    onCancel: jest.fn(),
  };

  it('should render modal when open', () => {
    render(<ConfirmModal {...defaultProps} />);
    expect(screen.getByText('Confirm Action')).toBeInTheDocument();
    expect(screen.getByText('Are you sure you want to proceed?')).toBeInTheDocument();
  });

  it('should not render when closed', () => {
    render(<ConfirmModal {...defaultProps} isOpen={false} />);
    expect(screen.queryByText('Confirm Action')).not.toBeInTheDocument();
  });

  it('should call onConfirm when confirm button is clicked', () => {
    const handleConfirm = jest.fn();
    render(<ConfirmModal {...defaultProps} onConfirm={handleConfirm} />);

    act(() => { fireEvent.click(screen.getByRole('button', { name: 'Confirm' }) }));
    expect(handleConfirm).toHaveBeenCalledTimes(1);
  });

  it('should call onCancel when cancel button is clicked', () => {
    const handleCancel = jest.fn();
    render(<ConfirmModal {...defaultProps} onCancel={handleCancel} />);

    act(() => { fireEvent.click(screen.getByRole('button', { name: 'Cancel' }) }));
    expect(handleCancel).toHaveBeenCalledTimes(1);
  });

  it('should render with danger variant', () => {
    render(<ConfirmModal {...defaultProps} variant="danger" />);
    const confirmButton = screen.getByRole('button', { name: 'Confirm' });
    expect(confirmButton).toHaveClass('bg-red-600');
  });
});
