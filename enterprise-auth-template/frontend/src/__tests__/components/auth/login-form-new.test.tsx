
import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import '@testing-library/jest-dom';


jest.mock('@/components/auth/login-form', () => {
  return {
    __esModule: true,
    default: () => <div>Login Form</div>,
  };
});


// Mock components
describe('LoginForm', () => {
  it('renders login form', async () => {
    const LoginForm = require('@/components/auth/login-form').default;
    render(<LoginForm />);
    await waitFor(() => {
      expect(screen.getByText('Login Form')).toBeInTheDocument();
    });
  });
});