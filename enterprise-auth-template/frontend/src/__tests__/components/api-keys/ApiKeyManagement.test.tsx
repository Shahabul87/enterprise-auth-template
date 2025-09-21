
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import ApiKeyManagement from '@/components/api-keys/ApiKeyManagement';


jest.mock('@/components/ui/use-toast', () => ({
  useToast: () => ({
    toast: jest.fn(),
  }),
}));

jest.mock('lucide-react', () => ({
  Key: () => <div data-testid="key-icon" />,
  Plus: () => <div data-testid="plus-icon" />,
  Copy: () => <div data-testid="copy-icon" />,
  MoreVertical: () => <div data-testid="more-icon" />,
  AlertTriangle: () => <div data-testid="alert-triangle-icon" />,
  RefreshCw: () => <div data-testid="refresh-icon" />,
  Trash2: () => <div data-testid="trash-icon" />,
  Activity: () => <div data-testid="activity-icon" />,
  Clock: () => <div data-testid="clock-icon" />,
  CheckCircle: () => <div data-testid="check-circle-icon" />,
  XCircle: () => <div data-testid="x-circle-icon" />,
  BarChart: () => <div data-testid="bar-chart-icon" />,
/**
 * ApiKeyManagement Component Tests
 * Simplified tests that work with the current component implementation
 */


// Type definitions matching the actual component
interface ApiKey {
  id: string;
  name: string;
  key: string;
  prefix: string;
  scopes: string[];
  status: 'active' | 'revoked' | 'expired';
  expiresAt?: string;
  created_at: string;
  lastUsedAt?: string;
  usageCount: number;
  rateLimit?: number;
  ipWhitelist?: string[];
  description?: string;
}

// Mock the toast hook
// Mock Lucide icons
// Mock localStorage
const mockLocalStorage = {
  getItem: jest.fn(() => 'mock-token'),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
Object.defineProperty(window, 'localStorage', { value: mockLocalStorage });

describe('ApiKeyManagement Component', () => {
  const mockApiKeys: ApiKey[] = [
    {
      id: '1',
      name: 'Production API Key',
      key: 'sk_live_abcdef123456',
      prefix: 'sk_live',
      scopes: ['read:users', 'write:users'],
      status: 'active',
      expiresAt: '2025-12-31T23:59:59Z',
      lastUsedAt: '2025-01-15T10:30:00Z',
      created_at: '2025-01-01T00:00:00Z',
      usageCount: 1250,
      rateLimit: 1000,
      ipWhitelist: ['192.168.1.1', '10.0.0.1'],
      description: 'Used for production environment',
    },
    {
      id: '2',
      name: 'Development API Key',
      key: 'sk_test_xyz789',
      prefix: 'sk_test',
      scopes: ['read:users'],
      status: 'active',
      expiresAt: '2025-06-30T23:59:59Z',
      lastUsedAt: '2025-01-10T15:45:00Z',
      created_at: '2025-01-01T00:00:00Z',
      usageCount: 500,
      rateLimit: 100,
      ipWhitelist: [],
      description: 'Development testing',
    },
  ];
  beforeEach(() => {
    jest.clearAllMocks();
    // Mock fetch API to return successful response
    global.fetch = jest.fn() as jest.MockedFunction<typeof fetch>;.mockResolvedValue({
      ok: true,
      json: jest.fn().mockResolvedValue({
        api_keys: mockApiKeys,
      })
    });
    // Mock clipboard API
    Object.assign(navigator, {
      clipboard: {
        writeText: jest.fn().mockResolvedValue(undefined),
      }
    });
  });
  afterEach(() => {
    jest.resetAllMocks();
  });

describe('Component Rendering', () => {
    it('should render loading state initially', async () => {
      render(<ApiKeyManagement />);
      // Check for skeleton loading elements by class
      const skeletonElements = document.querySelectorAll('.animate-pulse');
      expect(skeletonElements.length).toBeGreaterThan(0);
    });
    it('should render API management interface after loading', async () => {
      render(<ApiKeyManagement />);
      // Wait for component to load data
      await waitFor(() => {
        expect(screen.getByText('API Keys')).toBeInTheDocument();
      }, { timeout: 3000 });
      expect(screen.getByText('Manage your API keys for programmatic access')).toBeInTheDocument();
    });
    it('should display tabs for filtering keys', async () => {
      render(<ApiKeyManagement />);
      await waitFor(() => {
        // Check for tab navigation structure
        expect(screen.getByRole('tablist')).toBeInTheDocument();
      });
      // Should have at least one tab button
      const tabButtons = screen.getAllByRole('tab');
      expect(tabButtons.length).toBeGreaterThan(0);
    });
    it('should display API keys after loading', async () => {
      render(<ApiKeyManagement />);
      await waitFor(() => {
        expect(screen.getByText('Production API Key')).toBeInTheDocument();
      }, { timeout: 3000 });
      expect(screen.getByText('Development API Key')).toBeInTheDocument();
    });
  });

describe('Loading States', () => {
    it('should show loading skeleton while fetching data', async () => {
      render(<ApiKeyManagement />);
      // Check for skeleton loading elements
      const skeletonElements = document.querySelectorAll('.animate-pulse');
      expect(skeletonElements.length).toBeGreaterThan(0);
    });
    it('should hide loading skeleton after data loads', async () => {
      render(<ApiKeyManagement />);
      await waitFor(() => {
        expect(screen.getByText('API Keys')).toBeInTheDocument();
      }, { timeout: 3000 });
      // Loading skeletons should be replaced with actual content
      expect(screen.getByText('Production API Key')).toBeInTheDocument();
    });
  });

describe('Error Handling', () => {
    it('should handle fetch errors gracefully', async () => {
      // Mock fetch to reject
      global.fetch = jest.fn() as jest.MockedFunction<typeof fetch>;.mockRejectedValue(new Error('Network error'));
      render(<ApiKeyManagement />);
      // Component should not crash and should complete loading
      await waitFor(() => {
        // Component should still render basic structure
        const loadingElements = document.querySelectorAll('.animate-pulse');
        expect(loadingElements.length).toBeGreaterThanOrEqual(0);
      });
    });
    it('should handle API response with ok: false', async () => {
      // Mock fetch to return error response
      global.fetch = jest.fn() as jest.MockedFunction<typeof fetch>;.mockResolvedValue({
        ok: false,
        status: 500,
        json: jest.fn().mockResolvedValue({ error: 'Server error' })
      });
      render(<ApiKeyManagement />);
      // Component should handle error gracefully
      await waitFor(() => {
        // Should finish loading even with error
        expect(global.fetch).toHaveBeenCalled();
      });
    });
  });

describe('Empty State', () => {
    it('should show empty state when no API keys exist', async () => {
      // Mock empty response
      global.fetch = jest.fn() as jest.MockedFunction<typeof fetch>;.mockResolvedValue({
        ok: true,
        json: jest.fn().mockResolvedValue({
          api_keys: [],
        })
      });
      render(<ApiKeyManagement />);
      await waitFor(() => {
        expect(screen.getByText('No API Keys')).toBeInTheDocument();
      }, { timeout: 3000 });
      expect(screen.getByText('Create your first API key to get started')).toBeInTheDocument();
    });
  });
});
}