
import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import WebhookManagement from '@/components/webhooks/WebhookManagement';
import { useToast } from '@/components/ui/use-toast';
/**
 * @jest-environment jsdom
 */

jest.mock('@/components/ui/use-toast');
jest.mock('date-fns', () => ({
  formatDistanceToNow: jest.fn(() => '5 minutes'),
  format: jest.fn(() => 'Jan 1, 2024, 12:00 PM'),
jest.mock('date-fns', () => ({
  formatDistanceToNow: jest.fn(() => '5 minutes'),
  format: jest.fn(() => 'Jan 1, 2024, 12:00 PM'),
// Mock dependencies
// Mock fetch globally
global.fetch = jest.fn() as jest.MockedFunction<typeof fetch>;
// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(() => 'test-token'),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
Object.defineProperty(window, 'localStorage', { value: localStorageMock });
// Mock navigator.clipboard
Object.defineProperty(navigator, 'clipboard', {
  value: {
    writeText: jest.fn(),
  },
  writable: true
});

describe('WebhookManagement', () => {
  const mockToast = jest.fn();
  const mockWebhooks = [
    {
      id: '1',
      name: 'Test Webhook',
      url: 'https://example.com/webhook',
      secret: 'secret123',
      events: ['user.created', 'user.updated'],
      status: 'active' as const,
      enabled: true,
      description: 'Test webhook description',
      headers: { 'X-Custom': 'header' },
      retryPolicy: {
        maxRetries: 3,
        retryDelay: 1000,
        backoffMultiplier: 2,
      },
      created_at: '2024-01-01T00:00:00Z',
      lastTriggeredAt: '2024-01-01T12:00:00Z',
      successCount: 100,
      failureCount: 5,
      averageResponseTime: 250,
    },
  ];
  const mockDeliveries = [
    {
      id: '1',
      webhookId: '1',
      event: 'user.created',
      status: 'success' as const,
      statusCode: 200,
      responseTime: 150,
      payload: { user_id: '123' },
      response: '{"success": true}',
      attempts: 1,
      created_at: '2024-01-01T12:00:00Z',
    },
    {
      id: '2',
      webhookId: '1',
      event: 'user.updated',
      status: 'failed' as const,
      statusCode: 500,
      responseTime: 300,
      error: 'Internal Server Error',
      payload: { user_id: '456' },
      attempts: 3,
      created_at: '2024-01-01T11:00:00Z',
    },
  ];
  beforeEach(() => {
    jest.clearAllMocks();
    (useToast as jest.Mock).mockReturnValue({ toast: mockToast });
    (fetch as jest.Mock).mockImplementation((url: string) => {
      if (url.includes('/api/v1/webhooks/deliveries')) {
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({ deliveries: mockDeliveries })
        });
      }
      if (url.includes('/api/v1/webhooks')) {
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({ webhooks: mockWebhooks })
        });
      }
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve({})
      });
    });
  });
  it('renders loading state initially', async () => {
    render(<WebhookManagement />);
    expect(screen.getByTestId('skeleton')).toBeInTheDocument();
  });
  it('renders webhooks after loading', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('Webhooks')).toBeInTheDocument();
      expect(screen.getByText('Test Webhook')).toBeInTheDocument();
    }); });
  });
  it('displays empty state when no webhooks', async () => {
    (fetch as jest.Mock).mockImplementation(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ webhooks: [], deliveries: [] }),
      })
    );
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('No Webhooks')).toBeInTheDocument();
      expect(screen.getByText('Create your first webhook to receive event notifications')).toBeInTheDocument();
    }); });
  });
  it('opens create webhook dialog', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const addButton = screen.getByRole('button', { name: /add webhook/i }); });
      act(() => { fireEvent.click(addButton) });
    }); });
    expect(screen.getByText('Create Webhook Endpoint')).toBeInTheDocument();
    expect(screen.getByLabelText('Name')).toBeInTheDocument();
    expect(screen.getByLabelText('URL')).toBeInTheDocument();
  });
  it('creates new webhook', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const addButton = screen.getByRole('button', { name: /add webhook/i }); });
      act(() => { fireEvent.click(addButton) });
    }); });
    const nameInput = screen.getByLabelText('Name');
    const urlInput = screen.getByLabelText('URL');
    act(() => { fireEvent.change(nameInput, { target: { value: 'New Webhook' } }) });
    act(() => { fireEvent.change(urlInput, { target: { value: 'https://new-webhook.com' } }) });
    const createButton = screen.getByRole('button', { name: /create webhook/i });
    act(() => { fireEvent.click(createButton) });
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(mockToast).toHaveBeenCalledWith({
        title: 'Success',
        description: 'Webhook created successfully'
      }); });
    }); });
  });
  it('toggles webhook enabled state', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const switchElement = screen.getByRole('switch');
      act(() => { fireEvent.click(switchElement) });
    }); });
    await act(async () => { await waitFor(() => {
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/v1/webhooks/1/toggle'),
        expect.objectContaining({
          method: 'POST',
        })
      );
    });
  }); });
  it('deletes webhook', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const moreButton = screen.getByRole('button', { name: '' }); });
      act(() => { fireEvent.click(moreButton) });
    }); });
    const deleteOption = screen.getByText('Delete');
    act(() => { fireEvent.click(deleteOption) });
    await act(async () => { await waitFor(() => {
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/v1/webhooks/1'),
        expect.objectContaining({
          method: 'DELETE',
        })
      );
      expect(mockToast).toHaveBeenCalledWith({
        title: 'Success',
        description: 'Webhook deleted successfully'
      });
    });
  }); });
  it('switches between tabs', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('Endpoints (1)')).toBeInTheDocument();
    }); });
    const deliveriesTab = screen.getByText('Recent Deliveries (2)');
    act(() => { fireEvent.click(deliveriesTab) });
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('user.created')).toBeInTheDocument();
    }); });
    const eventsTab = screen.getByText('Available Events');
    act(() => { fireEvent.click(eventsTab) });
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('User Created')).toBeInTheDocument();
      expect(screen.getByText('Authentication')).toBeInTheDocument();
    }); });
  });
  it('tests webhook', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const moreButton = screen.getByRole('button', { name: '' }); });
      act(() => { fireEvent.click(moreButton) });
    }); });
    const testOption = screen.getByText('Test Webhook');
    act(() => { fireEvent.click(testOption) });
    expect(screen.getByText('Test Webhook')).toBeInTheDocument();
    expect(screen.getByText('Send a test event to Test Webhook')).toBeInTheDocument();
    const sendButton = screen.getByRole('button', { name: /send test/i });
    act(() => { fireEvent.click(sendButton) });
    await act(async () => { await waitFor(() => {
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/v1/webhooks/1/test'),
        expect.objectContaining({
          method: 'POST',
        })
      );
    });
  }); });
  it('retries failed delivery', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const deliveriesTab = screen.getByText('Recent Deliveries (2)');
      act(() => { fireEvent.click(deliveriesTab) });
    }); });
    await act(async () => { await act(async () => { await waitFor(() => {
      const moreButtons = screen.getAllByRole('button', { name: '' }); });
      act(() => { fireEvent.click(moreButtons[1]) }); // Click on failed delivery
    }); });
    const retryOption = screen.getByText('Retry');
    act(() => { fireEvent.click(retryOption) });
    await act(async () => { await waitFor(() => {
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/v1/webhooks/deliveries/2/retry'),
        expect.objectContaining({
          method: 'POST',
        })
      );
      expect(mockToast).toHaveBeenCalledWith({
        title: 'Success',
        description: 'Delivery retry initiated'
      });
    });
  }); });
  it('copies webhook URL to clipboard', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const moreButton = screen.getByRole('button', { name: '' }); });
      act(() => { fireEvent.click(moreButton) });
    }); });
    const copyOption = screen.getByText('Copy URL');
    act(() => { fireEvent.click(copyOption) });
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith('https://example.com/webhook');
    expect(mockToast).toHaveBeenCalledWith({
      title: 'Copied',
      description: 'Copied to clipboard'
    });
  });
  it('views delivery details', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const deliveriesTab = screen.getByText('Recent Deliveries (2)');
      act(() => { fireEvent.click(deliveriesTab) });
    }); });
    await act(async () => { await act(async () => { await waitFor(() => {
      const moreButtons = screen.getAllByRole('button', { name: '' }); });
      act(() => { fireEvent.click(moreButtons[0]) });
    }); });
    const viewOption = screen.getByText('View Details');
    act(() => { fireEvent.click(viewOption) });
    expect(screen.getByText('Delivery Details')).toBeInTheDocument();
    expect(screen.getByText('Event delivery information and response')).toBeInTheDocument();
  });
  it('refreshes data', async () => {
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const refreshButton = screen.getByRole('button', { name: /refresh/i }); });
      act(() => { fireEvent.click(refreshButton) });
    }); });
    expect(fetch).toHaveBeenCalledWith(
      expect.stringContaining('/api/v1/webhooks'),
      expect.any(Object)
    );
    expect(fetch).toHaveBeenCalledWith(
      expect.stringContaining('/api/v1/webhooks/deliveries'),
      expect.any(Object)
    );
  });
  it('handles API errors gracefully', async () => {
    (fetch as jest.Mock).mockRejectedValueOnce(new Error('Network error'));
    render(<WebhookManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(mockToast).toHaveBeenCalledWith({
        title: 'Error',
        description: 'Failed to fetch webhooks',
        variant: 'destructive'
      }); });
    }); });
  });
});
}}}}}}}}}}