/**
 * @jest-environment jsdom
 */
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import OAuthProviders from '@/components/auth/oauth-providers';

// Type definitions for mock components
interface ButtonProps {
  children: React.ReactNode;
  disabled?: boolean;
  onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  className?: string;
  variant?: string;
  [key: string]: unknown;
}

interface AlertProps {
  children: React.ReactNode;
  variant?: string;
  className?: string;
  [key: string]: unknown;
}

interface AlertDescriptionProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface SeparatorProps {
  [key: string]: unknown;
}

interface IconProps {
  className?: string;
}

// Create a proper mock Response that implements the Response interface
const createMockResponse = (options: {
  ok: boolean;
  status?: number;
  statusText?: string;
  headers?: Headers;
  data?: Record<string, unknown>;
}): Response => {
  const mockResponse = {
    ok: options.ok,
    status: options.status ?? (options.ok ? 200 : 500),
    statusText: options.statusText ?? (options.ok ? 'OK' : 'Internal Server Error'),
    headers: options.headers ?? new Headers(),
    redirected: false,
    type: 'basic' as ResponseType,
    url: 'http://localhost',
    body: null,
    bodyUsed: false,
    json: jest.fn().mockResolvedValue(options.data ?? {}),
    text: jest.fn().mockResolvedValue(''),
    blob: jest.fn().mockResolvedValue(new Blob()),
    arrayBuffer: jest.fn().mockResolvedValue(new ArrayBuffer(0)),
    formData: jest.fn().mockResolvedValue(new FormData()),
    bytes: jest.fn().mockResolvedValue(new Uint8Array()),
    clone: jest.fn().mockReturnValue({} as Response),
  };
  return mockResponse as unknown as Response;
};

interface PromiseResolver {
  (value: Response): void;
}

// Mock UI components
jest.mock('@/components/ui/button', () => ({
  Button: ({ children, disabled, onClick, className, variant, ...props }: ButtonProps) => (
    <button
      disabled={disabled}
      onClick={onClick}
      className={className}
      data-variant={variant}
      {...props}
    >
      {children}
    </button>
  ),
}));

jest.mock('@/components/ui/alert', () => ({
  Alert: ({ children, variant, className, ...props }: AlertProps) => (
    <div data-testid='alert' data-variant={variant} className={className} {...props}>
      {children}
    </div>
  ),
  AlertDescription: ({ children, ...props }: AlertDescriptionProps) => (
    <div data-testid='alert-description' {...props}>
      {children}
    </div>
  ),
}));

jest.mock('@/components/ui/separator', () => ({
  Separator: (props: SeparatorProps) => <hr data-testid='separator' {...props} />,
}));

jest.mock('@/components/icons', () => ({
  Icons: {
    google: ({ className }: IconProps) => <div data-testid='google-icon' className={className} />,
    gitHub: ({ className }: IconProps) => <div data-testid='github-icon' className={className} />,
    microsoft: ({ className }: IconProps) => (
      <div data-testid='microsoft-icon' className={className} />
    ),
  },
}));

jest.mock('lucide-react', () => ({
  Loader2: ({ className }: IconProps) => <div data-testid='loader-icon' className={className} />,
  AlertCircle: ({ className }: IconProps) => (
    <div data-testid='alert-circle-icon' className={className} />
  ),
}));

// Mock fetch globally
global.fetch = jest.fn();
const mockFetch = global.fetch as jest.MockedFunction<typeof fetch>;

// Mock window.location
Object.defineProperty(window, 'location', {
  value: {
    href: 'http://localhost:3000/auth/login',
    pathname: '/auth/login',
    search: '',
  },
  writable: true,
});

// Mock sessionStorage
const mockSessionStorage = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
Object.defineProperty(window, 'sessionStorage', {
  value: mockSessionStorage,
});

describe('OAuthProviders', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFetch.mockClear();
    mockSessionStorage.setItem.mockClear();
  });

  it('renders OAuth providers section', () => {
    render(<OAuthProviders />);

    expect(screen.getByText('Or continue with')).toBeInTheDocument();
    expect(screen.getByTestId('separator')).toBeInTheDocument();
  });

  it('renders all OAuth provider buttons', () => {
    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    const githubButton = screen.getByText('Continue with GitHub');
    const microsoftButton = screen.getByText('Continue with Microsoft');

    expect(googleButton).toBeInTheDocument();
    expect(githubButton).toBeInTheDocument();
    expect(microsoftButton).toBeInTheDocument();
  });

  it('renders provider icons correctly', () => {
    render(<OAuthProviders />);

    expect(screen.getByTestId('google-icon')).toBeInTheDocument();
    expect(screen.getByTestId('github-icon')).toBeInTheDocument();
    expect(screen.getByTestId('microsoft-icon')).toBeInTheDocument();
  });

  it('applies correct CSS classes to provider buttons', () => {
    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    const githubButton = screen.getByText('Continue with GitHub');
    const microsoftButton = screen.getByText('Continue with Microsoft');

    expect(googleButton).toHaveClass('bg-white', 'hover:bg-gray-50', 'text-gray-700');
    expect(githubButton).toHaveClass('bg-gray-900', 'hover:bg-gray-800', 'text-white');
    expect(microsoftButton).toHaveClass('bg-blue-600', 'hover:bg-blue-700', 'text-white');
  });

  it('calls OAuth login API when button is clicked', async () => {
    const mockResponse = {
      authorization_url: 'https://accounts.google.com/oauth/authorize?client_id=test',
    };

    mockFetch.mockResolvedValueOnce(
      createMockResponse({ ok: true, data: mockResponse })
    );

    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    fireEvent.click(googleButton);

    await waitFor(() => {
      expect(mockFetch).toHaveBeenCalledWith(
        `${process.env['NEXT_PUBLIC_API_URL']}/api/v1/auth/oauth/google/init`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );
    });
  });

  it('stores provider info in session storage on successful API call', async () => {
    const mockResponse = {
      authorization_url: 'https://accounts.google.com/oauth/authorize?client_id=test',
    };

    mockFetch.mockResolvedValueOnce(
      createMockResponse({ ok: true, data: mockResponse })
    );

    // Mock window.location.href assignment
    const originalLocation = window.location;
    delete (window as unknown as Record<string, unknown>)['location'];
    (window as unknown as Record<string, unknown>)['location'] = { ...originalLocation, href: '' };

    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    fireEvent.click(googleButton);

    await waitFor(() => {
      expect(mockSessionStorage.setItem).toHaveBeenCalledWith('oauth_provider', 'google');
      expect(mockSessionStorage.setItem).toHaveBeenCalledWith('oauth_return_url', '/auth/login');
    });

    // Restore original location
    (window as unknown as Record<string, unknown>)['location'] = originalLocation;
  });

  it('redirects to OAuth provider authorization URL', async () => {
    const mockAuthUrl =
      'https://accounts.google.com/oauth/authorize?client_id=test&redirect_uri=callback';
    const mockResponse = {
      authorization_url: mockAuthUrl,
    };

    mockFetch.mockResolvedValueOnce(
      createMockResponse({ ok: true, data: mockResponse })
    );

    // Mock window.location.href assignment
    const originalLocation = window.location;
    delete (window as unknown as Record<string, unknown>)['location'];
    (window as unknown as Record<string, unknown>)['location'] = { ...originalLocation, href: '' };

    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    fireEvent.click(googleButton);

    await waitFor(() => {
      expect(window.location.href).toBe(mockAuthUrl);
    });

    // Restore original location
    (window as unknown as Record<string, unknown>)['location'] = originalLocation;
  });

  it('shows loading state for clicked provider', async () => {
    const mockResponse = {
      authorization_url: 'https://accounts.google.com/oauth/authorize?client_id=test',
    };

    // Make fetch hang to test loading state
    let resolvePromise: PromiseResolver;
    const pendingPromise = new Promise<Response>((resolve) => {
      resolvePromise = resolve;
    });

    mockFetch.mockReturnValueOnce(pendingPromise);

    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    fireEvent.click(googleButton);

    // Check loading state
    await waitFor(() => {
      expect(screen.getByTestId('loader-icon')).toBeInTheDocument();
      expect(googleButton).toBeDisabled();
    });

    // Resolve the promise to clean up
    resolvePromise!(
      createMockResponse({ ok: true, data: mockResponse })
    );
  });

  it('disables all buttons when one provider is loading', async () => {
    const mockResponse = {
      authorization_url: 'https://accounts.google.com/oauth/authorize?client_id=test',
    };

    // Make fetch hang to test loading state
    let resolvePromise: PromiseResolver;
    const pendingPromise = new Promise<Response>((resolve) => {
      resolvePromise = resolve;
    });

    mockFetch.mockReturnValueOnce(pendingPromise);

    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    const githubButton = screen.getByText('Continue with GitHub');
    const microsoftButton = screen.getByText('Continue with Microsoft');

    fireEvent.click(googleButton);

    await waitFor(() => {
      expect(googleButton).toBeDisabled();
      expect(githubButton).toBeDisabled();
      expect(microsoftButton).toBeDisabled();
    });

    // Resolve the promise to clean up
    resolvePromise!(
      createMockResponse({ ok: true, data: mockResponse })
    );
  });

  it('handles API error gracefully', async () => {
    mockFetch.mockResolvedValueOnce(
      createMockResponse({ ok: false, status: 500 })
    );

    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    fireEvent.click(googleButton);

    await waitFor(() => {
      const alert = screen.getByTestId('alert');
      expect(alert).toBeInTheDocument();
      expect(alert).toHaveAttribute('data-variant', 'destructive');
      expect(screen.getByText('OAuth initialization failed: 500')).toBeInTheDocument();
    });
  });

  it('handles network error gracefully', async () => {
    const networkError = new Error('Network error');
    mockFetch.mockRejectedValueOnce(networkError);

    render(<OAuthProviders />);

    const githubButton = screen.getByText('Continue with GitHub');
    fireEvent.click(githubButton);

    await waitFor(() => {
      const alert = screen.getByTestId('alert');
      expect(alert).toBeInTheDocument();
      expect(alert).toHaveAttribute('data-variant', 'destructive');
      expect(screen.getByText('Network error')).toBeInTheDocument();
    });
  });

  it('handles generic error gracefully', async () => {
    mockFetch.mockRejectedValueOnce('Unknown error');

    render(<OAuthProviders />);

    const microsoftButton = screen.getByText('Continue with Microsoft');
    fireEvent.click(microsoftButton);

    await waitFor(() => {
      const alert = screen.getByTestId('alert');
      expect(alert).toBeInTheDocument();
      expect(alert).toHaveAttribute('data-variant', 'destructive');
      expect(screen.getByText('OAuth login failed')).toBeInTheDocument();
    });
  });

  it('resets loading state after error', async () => {
    mockFetch.mockRejectedValueOnce(new Error('API Error'));

    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    fireEvent.click(googleButton);

    await waitFor(() => {
      expect(screen.getByTestId('alert')).toBeInTheDocument();
    });

    // Button should no longer be disabled after error
    expect(googleButton).not.toBeDisabled();
    expect(screen.queryByTestId('loader-icon')).not.toBeInTheDocument();
  });

  it('calls onSuccess callback when provided', async () => {
    const mockOnSuccess = jest.fn();
    const mockResponse = {
      authorization_url: 'https://accounts.google.com/oauth/authorize?client_id=test',
    };

    mockFetch.mockResolvedValueOnce(
      createMockResponse({ ok: true, data: mockResponse })
    );

    // Mock window.location.href assignment to prevent actual redirect
    const originalLocation = window.location;
    delete (window as unknown as Record<string, unknown>)['location'];
    (window as unknown as Record<string, unknown>)['location'] = { ...originalLocation, href: '' };

    render(<OAuthProviders onSuccess={mockOnSuccess} />);

    const googleButton = screen.getByText('Continue with Google');
    fireEvent.click(googleButton);

    await waitFor(() => {
      expect(window.location.href).toBe(mockResponse.authorization_url);
    });

    // Restore original location
    (window as unknown as Record<string, unknown>)['location'] = originalLocation;
  });

  it('applies custom className when provided', () => {
    render(<OAuthProviders className='custom-oauth-class' />);

    const container = screen.getByText('Or continue with').closest('div');
    expect(container).toHaveClass('custom-oauth-class');
  });

  it('handles missing environment variables gracefully', async () => {
    const originalEnv = process.env['NEXT_PUBLIC_API_URL'];
    delete (process.env as Record<string, unknown>)['NEXT_PUBLIC_API_URL'];

    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    fireEvent.click(googleButton);

    await waitFor(() => {
      expect(mockFetch).toHaveBeenCalledWith(
        'undefined/api/v1/auth/oauth/google/init',
        expect.any(Object)
      );
    });

    // Restore environment variable
    if (originalEnv) {
      (process.env as Record<string, unknown>)['NEXT_PUBLIC_API_URL'] = originalEnv;
    }
  });

  it('handles different provider types correctly', async () => {
    const providers = ['google', 'github', 'microsoft'];

    for (const provider of providers) {
      const mockResponse = {
        authorization_url: `https://oauth.${provider}.com/authorize`,
      };

      mockFetch.mockResolvedValueOnce(
        createMockResponse({ ok: true, data: mockResponse })
      );

      const originalLocation = window.location;
      delete (window as unknown as Record<string, unknown>)['location'];
      (window as unknown as Record<string, unknown>)['location'] = { ...originalLocation, href: '' };

      render(<OAuthProviders />);

      const button = screen.getByText(
        `Continue with ${provider.charAt(0).toUpperCase() + provider.slice(1)}`
      );
      fireEvent.click(button);

      await waitFor(() => {
        expect(mockSessionStorage.setItem).toHaveBeenCalledWith('oauth_provider', provider);
      });

      (window as unknown as Record<string, unknown>)['location'] = originalLocation;
      mockFetch.mockClear();
      mockSessionStorage.setItem.mockClear();
    }
  });

  it('preserves return URL with search parameters', async () => {
    // Mock window location with search parameters
    Object.defineProperty(window, 'location', {
      value: {
        href: 'http://localhost:3000/auth/login?redirect=/dashboard&tab=settings',
        pathname: '/auth/login',
        search: '?redirect=/dashboard&tab=settings',
      },
      writable: true,
    });

    const mockResponse = {
      authorization_url: 'https://accounts.google.com/oauth/authorize?client_id=test',
    };

    mockFetch.mockResolvedValueOnce(
      createMockResponse({ ok: true, data: mockResponse })
    );

    const originalLocation = window.location;
    delete (window as unknown as Record<string, unknown>)['location'];
    (window as unknown as Record<string, unknown>)['location'] = { ...originalLocation, href: '' };

    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    fireEvent.click(googleButton);

    await waitFor(() => {
      expect(mockSessionStorage.setItem).toHaveBeenCalledWith(
        'oauth_return_url',
        '/auth/login?redirect=/dashboard&tab=settings'
      );
    });

    // Restore original location
    (window as unknown as Record<string, unknown>)['location'] = originalLocation;
  });

  it('shows alert error with icon', async () => {
    mockFetch.mockRejectedValueOnce(new Error('Test error'));

    render(<OAuthProviders />);

    const googleButton = screen.getByText('Continue with Google');
    fireEvent.click(googleButton);

    await waitFor(() => {
      expect(screen.getByTestId('alert-circle-icon')).toBeInTheDocument();
      expect(screen.getByTestId('alert-description')).toBeInTheDocument();
    });
  });
});
