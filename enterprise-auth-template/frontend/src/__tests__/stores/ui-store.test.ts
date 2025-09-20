
import { act, renderHook } from '@testing-library/react';
import { useUIStore } from '@/stores/ui-store';

jest.mock('zustand/middleware', () => ({
  devtools: (fn: any) => fn,
  persist: (fn: any) => fn,
}));

/**
 * @jest-environment jsdom
 */


// Mock zustand persist
describe('UIStore', () => {
  beforeEach(() => {
    // Reset store before each test
    const { result } = renderHook(() => useUIStore());
    act(() => {
      result.current.reset();
    });
  });

describe('Initial State', () => {
    it('should have correct initial state', () => {
      const { result } = renderHook(() => useUIStore());
      expect(result.current.sidebarOpen).toBe(true);
      expect(result.current.sidebarCollapsed).toBe(false);
      expect(result.current.mobileMenuOpen).toBe(false);
      expect(result.current.commandPaletteOpen).toBe(false);
      expect(result.current.searchOpen).toBe(false);
      expect(result.current.currentModal).toBeNull();
      expect(result.current.currentDrawer).toBeNull();
      expect(result.current.breadcrumbs).toEqual([]);
      expect(result.current.activeTab).toBe('');
      expect(result.current.loading).toEqual({});
      expect(result.current.errors).toEqual({});
    });
  });

describe('Sidebar Management', () => {
    it('should toggle sidebar open state', () => {
      const { result } = renderHook(() => useUIStore());
      expect(result.current.sidebarOpen).toBe(true);
      act(() => {
        result.current.toggleSidebar();
      });
      expect(result.current.sidebarOpen).toBe(false);
      act(() => {
        result.current.toggleSidebar();
      });
      expect(result.current.sidebarOpen).toBe(true);
    });
    it('should set sidebar open state', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setSidebarOpen(false);
      });
      expect(result.current.sidebarOpen).toBe(false);
      act(() => {
        result.current.setSidebarOpen(true);
      });
      expect(result.current.sidebarOpen).toBe(true);
    });
    it('should toggle sidebar collapsed state', () => {
      const { result } = renderHook(() => useUIStore());
      expect(result.current.sidebarCollapsed).toBe(false);
      act(() => {
        result.current.toggleSidebarCollapsed();
      });
      expect(result.current.sidebarCollapsed).toBe(true);
      act(() => {
        result.current.toggleSidebarCollapsed();
      });
      expect(result.current.sidebarCollapsed).toBe(false);
    });
    it('should set sidebar collapsed state', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setSidebarCollapsed(true);
      });
      expect(result.current.sidebarCollapsed).toBe(true);
      act(() => {
        result.current.setSidebarCollapsed(false);
      });
      expect(result.current.sidebarCollapsed).toBe(false);
    });
  });

describe('Mobile Menu Management', () => {
    it('should toggle mobile menu', () => {
      const { result } = renderHook(() => useUIStore());
      expect(result.current.mobileMenuOpen).toBe(false);
      act(() => {
        result.current.toggleMobileMenu();
      });
      expect(result.current.mobileMenuOpen).toBe(true);
      act(() => {
        result.current.toggleMobileMenu();
      });
      expect(result.current.mobileMenuOpen).toBe(false);
    });
    it('should set mobile menu state', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setMobileMenuOpen(true);
      });
      expect(result.current.mobileMenuOpen).toBe(true);
      act(() => {
        result.current.setMobileMenuOpen(false);
      });
      expect(result.current.mobileMenuOpen).toBe(false);
    });
  });

describe('Command Palette Management', () => {
    it('should toggle command palette', () => {
      const { result } = renderHook(() => useUIStore());
      expect(result.current.commandPaletteOpen).toBe(false);
      act(() => {
        result.current.toggleCommandPalette();
      });
      expect(result.current.commandPaletteOpen).toBe(true);
      act(() => {
        result.current.toggleCommandPalette();
      });
      expect(result.current.commandPaletteOpen).toBe(false);
    });
    it('should set command palette state', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setCommandPaletteOpen(true);
      });
      expect(result.current.commandPaletteOpen).toBe(true);
      act(() => {
        result.current.setCommandPaletteOpen(false);
      });
      expect(result.current.commandPaletteOpen).toBe(false);
    });
  });

describe('Search Management', () => {
    it('should toggle search', () => {
      const { result } = renderHook(() => useUIStore());
      expect(result.current.searchOpen).toBe(false);
      act(() => {
        result.current.toggleSearch();
      });
      expect(result.current.searchOpen).toBe(true);
      act(() => {
        result.current.toggleSearch();
      });
      expect(result.current.searchOpen).toBe(false);
    });
    it('should set search state', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setSearchOpen(true);
      });
      expect(result.current.searchOpen).toBe(true);
      act(() => {
        result.current.setSearchOpen(false);
      });
      expect(result.current.searchOpen).toBe(false);
    });
  });

describe('Modal Management', () => {
    it('should open modal', () => {
      const { result } = renderHook(() => useUIStore());
      const modalData = {
        id: 'test-modal',
        title: 'Test Modal',
        content: 'Modal content',
      };
      act(() => {
        result.current.openModal(modalData);
      });
      expect(result.current.currentModal).toEqual(modalData);
    });
    it('should close modal', () => {
      const { result } = renderHook(() => useUIStore());
      const modalData = {
        id: 'test-modal',
        title: 'Test Modal',
      };
      act(() => {
        result.current.openModal(modalData);
      });
      expect(result.current.currentModal).toEqual(modalData);
      act(() => {
        result.current.closeModal();
      });
      expect(result.current.currentModal).toBeNull();
    });
    it('should replace modal when opening new one', () => {
      const { result } = renderHook(() => useUIStore());
      const firstModal = { id: 'modal-1', title: 'First' };
      const secondModal = { id: 'modal-2', title: 'Second' };
      act(() => {
        result.current.openModal(firstModal);
      });
      expect(result.current.currentModal).toEqual(firstModal);
      act(() => {
        result.current.openModal(secondModal);
      });
      expect(result.current.currentModal).toEqual(secondModal);
    });
  });

describe('Drawer Management', () => {
    it('should open drawer', () => {
      const { result } = renderHook(() => useUIStore());
      const drawerData = {
        id: 'test-drawer',
        title: 'Test Drawer',
        position: 'right' as const,
      };
      act(() => {
        result.current.openDrawer(drawerData);
      });
      expect(result.current.currentDrawer).toEqual(drawerData);
    });
    it('should close drawer', () => {
      const { result } = renderHook(() => useUIStore());
      const drawerData = {
        id: 'test-drawer',
        title: 'Test Drawer',
      };
      act(() => {
        result.current.openDrawer(drawerData);
      });
      expect(result.current.currentDrawer).toEqual(drawerData);
      act(() => {
        result.current.closeDrawer();
      });
      expect(result.current.currentDrawer).toBeNull();
    });
    it('should support different drawer positions', () => {
      const { result } = renderHook(() => useUIStore());
      const positions = ['left', 'right', 'top', 'bottom'] as const;
      positions.forEach(position => {
        const drawerData = {
          id: `drawer-${position}`,
          position,
        };
        act(() => {
          result.current.openDrawer(drawerData);
        });
        expect(result.current.currentDrawer?.position).toBe(position);
      });
    });
  });

describe('Breadcrumb Management', () => {
    it('should set breadcrumbs', () => {
      const { result } = renderHook(() => useUIStore());
      const breadcrumbs = [
        { label: 'Home', path: '/' },
        { label: 'Users', path: '/users' },
        { label: 'Profile', path: '/users/profile' },
      ];
      act(() => {
        result.current.setBreadcrumbs(breadcrumbs);
      });
      expect(result.current.breadcrumbs).toEqual(breadcrumbs);
    });
    it('should add breadcrumb', () => {
      const { result } = renderHook(() => useUIStore());
      const initialBreadcrumb = { label: 'Home', path: '/' };
      const newBreadcrumb = { label: 'Dashboard', path: '/dashboard' };
      act(() => {
        result.current.setBreadcrumbs([initialBreadcrumb]);
      });
      act(() => {
        result.current.addBreadcrumb(newBreadcrumb);
      });
      expect(result.current.breadcrumbs).toEqual([initialBreadcrumb, newBreadcrumb]);
    });
    it('should remove last breadcrumb', () => {
      const { result } = renderHook(() => useUIStore());
      const breadcrumbs = [
        { label: 'Home', path: '/' },
        { label: 'Users', path: '/users' },
        { label: 'Profile', path: '/users/profile' },
      ];
      act(() => {
        result.current.setBreadcrumbs(breadcrumbs);
      });
      act(() => {
        result.current.popBreadcrumb();
      });
      expect(result.current.breadcrumbs).toHaveLength(2);
      expect(result.current.breadcrumbs[1].label).toBe('Users');
    });
    it('should clear breadcrumbs', () => {
      const { result } = renderHook(() => useUIStore());
      const breadcrumbs = [
        { label: 'Home', path: '/' },
        { label: 'Users', path: '/users' },
      ];
      act(() => {
        result.current.setBreadcrumbs(breadcrumbs);
      });
      act(() => {
        result.current.clearBreadcrumbs();
      });
      expect(result.current.breadcrumbs).toEqual([]);
    });
  });

describe('Tab Management', () => {
    it('should set active tab', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setActiveTab('settings');
      });
      expect(result.current.activeTab).toBe('settings');
      act(() => {
        result.current.setActiveTab('profile');
      });
      expect(result.current.activeTab).toBe('profile');
    });
    it('should track multiple tabs', () => {
      const { result } = renderHook(() => useUIStore());
      const tabs = ['overview', 'analytics', 'reports'];
      tabs.forEach(tab => {
        act(() => {
          result.current.setActiveTab(tab);
        });
        expect(result.current.activeTab).toBe(tab);
      });
    });
  });

describe('Loading States', () => {
    it('should set loading state for key', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setLoading('fetchUsers', true);
      });
      expect(result.current.loading.fetchUsers).toBe(true);
      expect(result.current.isLoading('fetchUsers')).toBe(true);
      act(() => {
        result.current.setLoading('fetchUsers', false);
      });
      expect(result.current.loading.fetchUsers).toBe(false);
      expect(result.current.isLoading('fetchUsers')).toBe(false);
    });
    it('should handle multiple loading states', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setLoading('fetchUsers', true);
        result.current.setLoading('fetchPosts', true);
        result.current.setLoading('fetchComments', false);
      });
      expect(result.current.loading.fetchUsers).toBe(true);
      expect(result.current.loading.fetchPosts).toBe(true);
      expect(result.current.loading.fetchComments).toBe(false);
    });
    it('should clear specific loading state', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setLoading('fetchUsers', true);
        result.current.setLoading('fetchPosts', true);
      });
      act(() => {
        result.current.clearLoading('fetchUsers');
      });
      expect(result.current.loading.fetchUsers).toBeUndefined();
      expect(result.current.loading.fetchPosts).toBe(true);
    });
    it('should clear all loading states', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setLoading('fetchUsers', true);
        result.current.setLoading('fetchPosts', true);
        result.current.setLoading('fetchComments', true);
      });
      act(() => {
        result.current.clearAllLoading();
      });
      expect(result.current.loading).toEqual({});
    });
    it('should check if any loading is active', () => {
      const { result } = renderHook(() => useUIStore());
      expect(result.current.isAnyLoading()).toBe(false);
      act(() => {
        result.current.setLoading('fetchUsers', true);
      });
      expect(result.current.isAnyLoading()).toBe(true);
      act(() => {
        result.current.setLoading('fetchUsers', false);
      });
      expect(result.current.isAnyLoading()).toBe(false);
    });
  });

describe('Error Management', () => {
    it('should set error for key', () => {
      const { result } = renderHook(() => useUIStore());
      const error = { message: 'Failed to fetch', code: 'FETCH_ERROR' };
      act(() => {
        result.current.setError('fetchUsers', error);
      });
      expect(result.current.errors.fetchUsers).toEqual(error);
      expect(result.current.getError('fetchUsers')).toEqual(error);
    });
    it('should handle multiple errors', () => {
      const { result } = renderHook(() => useUIStore());
      const userError = { message: 'User error' };
      const postError = { message: 'Post error' };
      act(() => {
        result.current.setError('users', userError);
        result.current.setError('posts', postError);
      });
      expect(result.current.errors.users).toEqual(userError);
      expect(result.current.errors.posts).toEqual(postError);
    });
    it('should clear specific error', () => {
      const { result } = renderHook(() => useUIStore());
      const error = { message: 'Error' };
      act(() => {
        result.current.setError('test', error);
      });
      expect(result.current.errors.test).toEqual(error);
      act(() => {
        result.current.clearError('test');
      });
      expect(result.current.errors.test).toBeUndefined();
    });
    it('should clear all errors', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setError('error1', { message: 'Error 1' });
        result.current.setError('error2', { message: 'Error 2' });
        result.current.setError('error3', { message: 'Error 3' });
      });
      act(() => {
        result.current.clearAllErrors();
      });
      expect(result.current.errors).toEqual({});
    });
    it('should check if any errors exist', () => {
      const { result } = renderHook(() => useUIStore());
      expect(result.current.hasAnyError()).toBe(false);
      act(() => {
        result.current.setError('test', { message: 'Error' });
      });
      expect(result.current.hasAnyError()).toBe(true);
      act(() => {
        result.current.clearError('test');
      });
      expect(result.current.hasAnyError()).toBe(false);
    });
  });

describe('Toast Notifications', () => {
    it('should show toast notification', () => {
      const { result } = renderHook(() => useUIStore());
      const toast = {
        id: 'toast-1',
        title: 'Success',
        description: 'Operation completed',
        type: 'success' as const,
      };
      act(() => {
        result.current.showToast(toast);
      });
      expect(result.current.toasts).toContainEqual(toast);
    });
    it('should remove toast notification', () => {
      const { result } = renderHook(() => useUIStore());
      const toast = {
        id: 'toast-1',
        title: 'Info',
        type: 'info' as const,
      };
      act(() => {
        result.current.showToast(toast);
      });
      expect(result.current.toasts).toContainEqual(toast);
      act(() => {
        result.current.removeToast('toast-1');
      });
      expect(result.current.toasts).not.toContainEqual(toast);
    });
    it('should clear all toasts', () => {
      const { result } = renderHook(() => useUIStore());
      const toasts = [
        { id: '1', title: 'Toast 1', type: 'info' as const },
        { id: '2', title: 'Toast 2', type: 'success' as const },
        { id: '3', title: 'Toast 3', type: 'error' as const },
      ];
      act(() => {
        toasts.forEach(toast => result.current.showToast(toast));
      });
      expect(result.current.toasts).toHaveLength(3);
      act(() => {
        result.current.clearToasts();
      });
      expect(result.current.toasts).toHaveLength(0);
    });
  });

describe('Focus Management', () => {
    it('should set focused element', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setFocusedElement('input-email');
      });
      expect(result.current.focusedElement).toBe('input-email');
      act(() => {
        result.current.setFocusedElement('button-submit');
      });
      expect(result.current.focusedElement).toBe('button-submit');
    });
    it('should clear focused element', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setFocusedElement('input-test');
      });
      expect(result.current.focusedElement).toBe('input-test');
      act(() => {
        result.current.clearFocusedElement();
      });
      expect(result.current.focusedElement).toBeNull();
    });
  });

describe('Reset', () => {
    it('should reset entire UI state', () => {
      const { result } = renderHook(() => useUIStore());
      // Modify various states
      act(() => {
        result.current.setSidebarOpen(false);
        result.current.setMobileMenuOpen(true);
        result.current.setActiveTab('settings');
        result.current.setLoading('test', true);
        result.current.setError('test', { message: 'Error' });
        result.current.setBreadcrumbs([{ label: 'Test', path: '/test' }]);
        result.current.openModal({ id: 'test-modal' });
      });
      // Reset
      act(() => {
        result.current.reset();
      });
      expect(result.current.sidebarOpen).toBe(true);
      expect(result.current.mobileMenuOpen).toBe(false);
      expect(result.current.activeTab).toBe('');
      expect(result.current.loading).toEqual({});
      expect(result.current.errors).toEqual({});
      expect(result.current.breadcrumbs).toEqual([]);
      expect(result.current.currentModal).toBeNull();
    });
  });

describe('Responsive Behavior', () => {
    it('should adjust sidebar for mobile', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.setIsMobile(true);
      });
      expect(result.current.isMobile).toBe(true);
      // On mobile, sidebar should close when opening mobile menu
      act(() => {
        result.current.setMobileMenuOpen(true);
      });
      act(() => {
        result.current.setSidebarOpen(false);
      });
      expect(result.current.sidebarOpen).toBe(false);
    });
    it('should handle screen size changes', () => {
      const { result } = renderHook(() => useUIStore());
      act(() => {
        result.current.handleScreenResize(375); // Mobile width
      });
      expect(result.current.isMobile).toBe(true);
      expect(result.current.isTablet).toBe(false);
      expect(result.current.isDesktop).toBe(false);
      act(() => {
        result.current.handleScreenResize(768); // Tablet width
      });
      expect(result.current.isMobile).toBe(false);
      expect(result.current.isTablet).toBe(true);
      expect(result.current.isDesktop).toBe(false);
      act(() => {
        result.current.handleScreenResize(1920); // Desktop width
      });
      expect(result.current.isMobile).toBe(false);
      expect(result.current.isTablet).toBe(false);
      expect(result.current.isDesktop).toBe(true);
    });
  });
});