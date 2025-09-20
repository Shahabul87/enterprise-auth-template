
import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import DeviceManagement from '@/components/devices/DeviceManagement';
import { useToast } from '@/components/ui/use-toast';

/**
 * @jest-environment jsdom
 */

jest.mock('@/components/ui/use-toast');
jest.mock('date-fns', () => ({
  formatDistanceToNow: jest.fn(() => '5 minutes'),
}));

jest.mock('date-fns', () => ({
  formatDistanceToNow: jest.fn(() => '5 minutes'),
}));


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

describe('DeviceManagement', () => {
  const mockToast = jest.fn();
  const mockSessions = [
    {
      session_id: 'sess_1',
      device_id: 'dev_1',
      device_name: 'MacBook Pro',
      device_type: 'desktop',
      ip_address: '192.168.1.1',
      user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
      location: 'New York, US',
      created_at: '2024-01-01T10:00:00Z',
      last_activity: '2024-01-01T11:00:00Z',
      is_current: true,
      expires_at: '2024-01-02T10:00:00Z',
    },
    {
      session_id: 'sess_2',
      device_id: 'dev_2',
      device_name: 'iPhone 14',
      device_type: 'mobile',
      ip_address: '192.168.1.2',
      user_agent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0)',
      location: 'New York, US',
      created_at: '2024-01-01T09:00:00Z',
      last_activity: '2024-01-01T10:30:00Z',
      is_current: false,
    },
    {
      session_id: 'sess_3',
      device_id: 'dev_3',
      device_name: 'iPad',
      device_type: 'tablet',
      ip_address: '192.168.1.3',
      created_at: '2024-01-01T08:00:00Z',
      last_activity: '2024-01-01T09:00:00Z',
      is_current: false,
    },
  ];
  const mockDevices = [
    {
      device_id: 'dev_1',
      device_name: 'MacBook Pro',
      device_type: 'desktop',
      os_name: 'macOS',
      os_version: '14.0',
      browser_name: 'Chrome',
      browser_version: '120',
      is_trusted: true,
    },
    {
      device_id: 'dev_2',
      device_name: 'iPhone 14',
      device_type: 'mobile',
      os_name: 'iOS',
      os_version: '16.0',
      is_trusted: false,
    },
  ];
  beforeEach(() => {
    jest.clearAllMocks();
    (useToast as jest.Mock).mockReturnValue({ toast: mockToast });
    (fetch as jest.Mock).mockImplementation((url: string) => {
      if (url.includes('/api/v1/devices/sessions')) {
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({
            sessions: mockSessions,
            total: 3,
            active_count: 3,
          }),
        });
      }
      if (url.includes('/api/v1/devices/devices')) {
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({
            devices: mockDevices,
            total: 2,
          }),
        });
      }
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve({}),
      });
    });
  });
  it('renders loading state initially', async () => {
    render(<DeviceManagement />);
    const skeletons = screen.getAllByTestId('skeleton');
    expect(skeletons).toHaveLength(3);
  });
  it('renders device management page after loading', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('Device Management')).toBeInTheDocument();
      expect(screen.getByText('Manage your devices and active sessions')).toBeInTheDocument();
    }); });
  });
  it('displays active sessions', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('Active Sessions (3)')).toBeInTheDocument();
      expect(screen.getByText('MacBook Pro')).toBeInTheDocument();
      expect(screen.getByText('iPhone 14')).toBeInTheDocument();
      expect(screen.getByText('iPad')).toBeInTheDocument();
    }); });
  });
  it('shows current session badge', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('Current')).toBeInTheDocument();
    }); });
  });
  it('displays security alert for multiple sessions', async () => {
    (fetch as jest.Mock).mockImplementation((url: string) => {
      if (url.includes('/api/v1/devices/sessions')) {
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({
            sessions: [...mockSessions, ...mockSessions], // 6 sessions
            total: 6,
            active_count: 6,
          }),
        });
      }
      if (url.includes('/api/v1/devices/devices')) {
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({
            devices: mockDevices,
            total: 2,
          }),
        });
      }
      return Promise.resolve({ ok: true, json: () => Promise.resolve({}) });
    });
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('Multiple Active Sessions')).toBeInTheDocument();
      expect(screen.getByText(/You have 6 active sessions/)).toBeInTheDocument();
    }); });
  });
  it('revokes a session', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const moreButtons = screen.getAllByRole('button', { name: '' }); });
      act(() => { fireEvent.click(moreButtons[1]) }); // Click on non-current session
    }); });
    const revokeOption = screen.getByText('Revoke Session');
    act(() => { fireEvent.click(revokeOption) });
    await act(async () => { await waitFor(() => {
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/v1/devices/sessions/sess_2'),
        expect.objectContaining({
          method: 'DELETE',
        })
      );
      expect(mockToast).toHaveBeenCalledWith({
        title: 'Success',
        description: 'Session revoked successfully',
      });
    });
  }); });
  it('opens force logout dialog', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const logoutAllButton = screen.getByRole('button', { name: /logout all devices/i }); });
      act(() => { fireEvent.click(logoutAllButton) });
    }); });
    expect(screen.getByText('Logout from all devices?')).toBeInTheDocument();
    expect(screen.getByText(/This will log you out from all devices except the current one/)).toBeInTheDocument();
  });
  it('performs force logout', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const logoutAllButton = screen.getByRole('button', { name: /logout all devices/i }); });
      act(() => { fireEvent.click(logoutAllButton) });
    }); });
    const confirmButton = screen.getByRole('button', { name: 'Logout All Devices' });
    act(() => { fireEvent.click(confirmButton) });
    await act(async () => { await waitFor(() => {
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/v1/devices/force-logout'),
        expect.objectContaining({
          method: 'POST',
          body: JSON.stringify({
            except_current: true,
            reason: 'User initiated force logout',
          }),
        })
      );
    });
  }); });
  it('switches to devices tab', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const devicesTab = screen.getByText('Registered Devices (2)');
      act(() => { fireEvent.click(devicesTab) });
    }); });
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('macOS 14.0')).toBeInTheDocument();
      expect(screen.getByText('iOS 16.0')).toBeInTheDocument();
    }); });
  });
  it('displays trusted device badge', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const devicesTab = screen.getByText('Registered Devices (2)');
      act(() => { fireEvent.click(devicesTab) });
    }); });
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('Trusted')).toBeInTheDocument();
      expect(screen.getByText('Not Trusted')).toBeInTheDocument();
    }); });
  });
  it('toggles device trust status', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const devicesTab = screen.getByText('Registered Devices (2)');
      act(() => { fireEvent.click(devicesTab) });
    }); });
    await act(async () => { await act(async () => { await waitFor(() => {
      const moreButtons = screen.getAllByRole('button', { name: '' }); });
      act(() => { fireEvent.click(moreButtons[3]) }); // Click on untrusted device
    }); });
    const trustOption = screen.getByText('Trust Device');
    act(() => { fireEvent.click(trustOption) });
    await act(async () => { await waitFor(() => {
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/v1/devices/trust'),
        expect.objectContaining({
          method: 'POST',
          body: JSON.stringify({
            device_id: 'dev_2',
            is_trusted: true,
            require_2fa: true,
          }),
        })
      );
      expect(mockToast).toHaveBeenCalledWith({
        title: 'Success',
        description: 'Device trusted successfully',
      });
    });
  }); });
  it('refreshes sessions and devices', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      const refreshButton = screen.getByRole('button', { name: /refresh/i }); });
      act(() => { fireEvent.click(refreshButton) });
    }); });
    expect(fetch).toHaveBeenCalledWith(
      expect.stringContaining('/api/v1/devices/sessions'),
      expect.any(Object)
    );
  });
  it('displays empty state for no sessions', async () => {
    (fetch as jest.Mock).mockImplementation((url: string) => {
      if (url.includes('/api/v1/devices/sessions')) {
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({
            sessions: [],
            total: 0,
            active_count: 0,
          }),
        });
      }
      if (url.includes('/api/v1/devices/devices')) {
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({
            devices: [],
            total: 0,
          }),
        });
      }
      return Promise.resolve({ ok: true, json: () => Promise.resolve({}) });
    });
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('No active sessions found')).toBeInTheDocument();
    }); });
    const devicesTab = screen.getByText('Registered Devices (0)');
    act(() => { fireEvent.click(devicesTab) });
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(screen.getByText('No registered devices found')).toBeInTheDocument();
    }); });
  });
  it('handles API errors gracefully', async () => {
    (fetch as jest.Mock).mockRejectedValueOnce(new Error('Network error'));
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      expect(mockToast).toHaveBeenCalledWith({
        title: 'Error',
        description: 'Failed to fetch sessions',
        variant: 'destructive',
      }); });
    }); });
  });
  it('displays device icons correctly', async () => {
    render(<DeviceManagement />);
    await act(async () => { await act(async () => { await waitFor(() => {
      // Check that device type icons are rendered
      const sessions = screen.getByText('Active Sessions (3)');
      expect(sessions).toBeInTheDocument();
    }); });
    // The component should render different icons for different device types
    expect(screen.getByText('MacBook Pro')).toBeInTheDocument(); // desktop
    expect(screen.getByText('iPhone 14')).toBeInTheDocument(); // mobile
    expect(screen.getByText('iPad')).toBeInTheDocument(); // tablet
  });
});