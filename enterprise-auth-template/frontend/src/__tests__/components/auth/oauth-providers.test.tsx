
import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import OAuthProviders from '@/components/auth/oauth-providers';

/**
 * @jest-environment jsdom
 */

jest.mock('@/components/icons', () => ({
  Icons: {
    google: ({ className }: { className?: string }) => (
      <div data-testid="google-icon" className={className}>Google</div>
    ),
    gitHub: ({ className }: { className?: string }) => (
      <div data-testid="github-icon" className={className}>GitHub</div>
    ),
    discord: ({ className }: { className?: string }) => (
      <div data-testid="discord-icon" className={className}>Discord</div>
    ),
  },
}));

/**
 * Comprehensive test suite for OAuthProviders component
 * Tests OAuth provider integration, error handling, and UI interactions
 */

// Mock fetch globally
global.fetch = jest.fn() as jest.MockedFunction<typeof fetch>;
// Mock window.location
const mockLocation = {
  href: '',
  pathname: '/login',
  search: '',
};
Object.defineProperty(window, 'location', {
  value: mockLocation,
  writable: true
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
  writable: true
});

describe('OAuthProviders Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockLocation.href = '';
    mockLocation.pathname = '/login';
    mockLocation.search = '';
    (global.fetch as jest.Mock).mockClear();
  });
});
describe('Basic Rendering', () => {
    it('should render all OAuth providers', async () => {
      render(<OAuthProviders />);
      expect(screen.getByText('Continue with Google')).toBeInTheDocument();
      expect(screen.getByText('Continue with GitHub')).toBeInTheDocument();
      expect(screen.getByText('Continue with Discord')).toBeInTheDocument();
    });
    it('should render separator with text', async () => {
      render(<OAuthProviders />);
      expect(screen.getByText('Or continue with')).toBeInTheDocument();
    });
    it('should render provider icons', async () => {
      render(<OAuthProviders />);
      expect(screen.getByTestId('google-icon')).toBeInTheDocument();
      expect(screen.getByTestId('github-icon')).toBeInTheDocument();
      expect(screen.getByTestId('discord-icon')).toBeInTheDocument();
    });
    it('should accept custom className', async () => {
      const { container } = render(<OAuthProviders className="custom-oauth-class" />);
      const oauthContainer = container.querySelector('.custom-oauth-class');
      expect(oauthContainer).toBeInTheDocument();
    });
  });

describe('OAuth Login Flow', () => {
    it('should handle Google OAuth login successfully', async () => {
      const mockAuthUrl = 'https://accounts.google.com/oauth/authorize?client_id=123';
      (global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({ authorization_url: mockAuthUrl })
      });
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await waitFor(() => {
        expect(global.fetch).toHaveBeenCalledWith(
          'http://localhost:8000/api/v1/oauth/google/init',
          {
            method: 'GET',
            headers: {
              'Content-Type': 'application/json',
            }
          }
        );
      });
      expect(mockSessionStorage.setItem).toHaveBeenCalledWith('oauth_provider', 'google');
      expect(mockSessionStorage.setItem).toHaveBeenCalledWith('oauth_return_url', '/login');
      expect(mockLocation.href).toBe(mockAuthUrl);
    });
    it('should handle GitHub OAuth login successfully', async () => {
      const mockAuthUrl = 'https://github.com/login/oauth/authorize?client_id=456';
      (global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({ authorization_url: mockAuthUrl })
      });
      render(<OAuthProviders />);
      const githubButton = screen.getByText('Continue with GitHub');
      act(() => { fireEvent.click(githubButton) });
      await waitFor(() => {
        expect(global.fetch).toHaveBeenCalledWith(
          'http://localhost:8000/api/v1/oauth/github/init',
          expect.any(Object)
        );
      });
      expect(mockSessionStorage.setItem).toHaveBeenCalledWith('oauth_provider', 'github');
      expect(mockLocation.href).toBe(mockAuthUrl);
    });
    it('should handle Discord OAuth login successfully', async () => {
      const mockAuthUrl = 'https://discord.com/oauth/authorize?client_id=789';
      (global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({ authorization_url: mockAuthUrl })
      });
      render(<OAuthProviders />);
      const discordButton = screen.getByText('Continue with Discord');
      act(() => { fireEvent.click(discordButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(global.fetch).toHaveBeenCalledWith(
          'http://localhost:8000/api/v1/oauth/discord/init',
          expect.any(Object)
        );
      }); });
      expect(mockSessionStorage.setItem).toHaveBeenCalledWith('oauth_provider', 'discord');
      expect(mockLocation.href).toBe(mockAuthUrl);
    });
    it('should store return URL with query parameters', async () => {
      mockLocation.pathname = '/dashboard';
      mockLocation.search = '?ref=email';
      const mockAuthUrl = 'https://accounts.google.com/oauth/authorize';
      (global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({ authorization_url: mockAuthUrl })
      });
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(mockSessionStorage.setItem).toHaveBeenCalledWith(
          'oauth_return_url',
          '/dashboard?ref=email'
        );
      }); });
    });
    it('should use custom API URL from environment variable', async () => {
      const originalEnv = process.env['NEXT_PUBLIC_API_URL'];
      process.env['NEXT_PUBLIC_API_URL'] = 'https://api.example.com';
      (global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({ authorization_url: 'https://oauth.example.com' })
      });
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(global.fetch).toHaveBeenCalledWith(
          'https://api.example.com/api/v1/oauth/google/init',
          expect.any(Object)
        );
      }); });
      process.env['NEXT_PUBLIC_API_URL'] = originalEnv;
    });
  });

describe('Loading States', () => {
    it('should show loading spinner when provider is clicked', async () => {
      (global.fetch as jest.Mock).mockImplementation(
        () => new Promise(() => {}) // Never resolves to keep loading state
      );
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        const spinner = googleButton.querySelector('.animate-spin');
        expect(spinner).toBeInTheDocument();
      }); });
    });
    it('should disable all buttons when one provider is loading', async () => {
      (global.fetch as jest.Mock).mockImplementation(
        () => new Promise(() => {}) // Never resolves to keep loading state
      );
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      const githubButton = screen.getByText('Continue with GitHub');
      const discordButton = screen.getByText('Continue with Discord');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(googleButton).toBeDisabled();
        expect(githubButton).toBeDisabled();
        expect(discordButton).toBeDisabled();
      }); });
    });
    it('should only show loading spinner for clicked provider', async () => {
      (global.fetch as jest.Mock).mockImplementation(
        () => new Promise(() => {}) // Never resolves to keep loading state
      );
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      const githubButton = screen.getByText('Continue with GitHub');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        const googleSpinner = googleButton.querySelector('.animate-spin');
        const githubSpinner = githubButton.querySelector('.animate-spin');
        expect(googleSpinner).toBeInTheDocument();
        expect(githubSpinner).not.toBeInTheDocument();
      }); });
    });
  });

describe('Error Handling', () => {
    it('should display error when OAuth initialization fails', async () => {
      (global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: false,
        status: 500
      });
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText('OAuth initialization failed: 500')).toBeInTheDocument();
      }); });
    });
    it('should display network error message', async () => {
      (global.fetch as jest.Mock).mockRejectedValueOnce(new Error('Network error'));
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText('Network error')).toBeInTheDocument();
      }); });
    });
    it('should display generic error for non-Error exceptions', async () => {
      (global.fetch as jest.Mock).mockRejectedValueOnce('Unknown error');
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText('OAuth login failed')).toBeInTheDocument();
      }); });
    });
    it('should clear loading state on error', async () => {
      (global.fetch as jest.Mock).mockRejectedValueOnce(new Error('Network error'));
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText('Network error')).toBeInTheDocument();
      }); });
      // Check that loading spinner is removed
      const spinner = googleButton.querySelector('.animate-spin');
      expect(spinner).not.toBeInTheDocument();
      // Check that buttons are enabled again
      expect(googleButton).not.toBeDisabled();
    });
    it('should clear previous errors when trying another provider', async () => {
      // First request fails
      (global.fetch as jest.Mock).mockRejectedValueOnce(new Error('First error'));
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.getByText('First error')).toBeInTheDocument();
      }); });
      // Second request succeeds
      (global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({ authorization_url: 'https://github.com/oauth' })
      });
      const githubButton = screen.getByText('Continue with GitHub');
      act(() => { fireEvent.click(githubButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(screen.queryByText('First error')).not.toBeInTheDocument();
      }); });
    });
  });

describe('Button Styling', () => {
    it('should apply correct styling to Google button', async () => {
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      expect(googleButton).toHaveClass('bg-white', 'hover:bg-gray-50', 'text-gray-700');
    });
    it('should apply correct styling to GitHub button', async () => {
      render(<OAuthProviders />);
      const githubButton = screen.getByText('Continue with GitHub');
      expect(githubButton).toHaveClass('bg-gray-900', 'hover:bg-gray-800', 'text-white');
    });
    it('should apply correct styling to Discord button', async () => {
      render(<OAuthProviders />);
      const discordButton = screen.getByText('Continue with Discord');
      expect(discordButton).toHaveClass('bg-indigo-600', 'hover:bg-indigo-700', 'text-white');
    });
  });

describe('Security Considerations', () => {
    it('should not store OAuth state in session storage', async () => {
      const mockAuthUrl = 'https://accounts.google.com/oauth/authorize?state=abc123';
      (global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          authorization_url: mockAuthUrl,
          state: 'abc123' // Server might return state, but we shouldn't store it
        })
      });
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        // Should only store provider and return URL, not state
        expect(mockSessionStorage.setItem).toHaveBeenCalledTimes(2);
        expect(mockSessionStorage.setItem).toHaveBeenCalledWith('oauth_provider', 'google');
        expect(mockSessionStorage.setItem).toHaveBeenCalledWith('oauth_return_url', '/login');
        // Should not store state
        expect(mockSessionStorage.setItem).not.toHaveBeenCalledWith(
          expect.stringContaining('state'),
          expect.anything()
        );
      }); });
    });
    it('should handle window undefined for SSR', async () => {
      const originalWindow = global.window;
      // @ts-ignore - Testing SSR scenario
      delete global.window;
      render(<OAuthProviders />);
      // Should render without errors
      expect(screen.getByText('Continue with Google')).toBeInTheDocument();
      global.window = originalWindow;
    });
  });

describe('Callback Prop', () => {
    it('should call onSuccess callback after successful OAuth init', async () => {
      const onSuccess = jest.fn();
      const mockAuthUrl = 'https://accounts.google.com/oauth/authorize';
      (global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({ authorization_url: mockAuthUrl })
      });
      render(<OAuthProviders onSuccess={onSuccess} />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      // Note: onSuccess is not called in current implementation
      // This test documents current behavior
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(mockLocation.href).toBe(mockAuthUrl);
      }); });
      expect(onSuccess).not.toHaveBeenCalled();
    });
  });

describe('Accessibility', () => {
    it('should have accessible button labels', async () => {
      render(<OAuthProviders />);
      const googleButton = screen.getByRole('button', { name: /Continue with Google/i });
      const githubButton = screen.getByRole('button', { name: /Continue with GitHub/i });
      const discordButton = screen.getByRole('button', { name: /Continue with Discord/i });
      expect(googleButton).toBeInTheDocument();
      expect(githubButton).toBeInTheDocument();
      expect(discordButton).toBeInTheDocument();
    });
    it('should indicate loading state accessibly', async () => {
      (global.fetch as jest.Mock).mockImplementation(
        () => new Promise(() => {}) // Never resolves
      );
      render(<OAuthProviders />);
      const googleButton = screen.getByText('Continue with Google');
      act(() => { fireEvent.click(googleButton) });
      await act(async () => { await act(async () => { await waitFor(() => {
        const spinner = googleButton.querySelector('.animate-spin');
        expect(spinner).toBeInTheDocument();
        expect(googleButton).toBeDisabled();
      }); });
    });
  });
});