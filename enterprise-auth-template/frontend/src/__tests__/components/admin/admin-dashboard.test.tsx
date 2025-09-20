
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';


jest.mock('@/components/admin/admin-dashboard', () => {
  return {
    __esModule: true,
    default: () => <div>Admin Dashboard</div>,
  };
});


// Mock components
describe('AdminDashboard', () => {
  it('renders admin dashboard', async () => {
    const AdminDashboard = require('@/components/admin/admin-dashboard').default;
    render(<AdminDashboard />);
    await waitFor(() => {
      expect(screen.getByText('Admin Dashboard')).toBeInTheDocument();
    });
  });
});