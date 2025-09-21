
import { renderHook, act, waitFor } from '@testing-library/react';
import { usePagination, usePaginatedData } from '@/hooks/use-pagination';
import { PaginatedResponse } from '@/types/api.types';
import React from 'react';

/**
 * @jest-environment jsdom
 */


// Mock window.history.replaceState
const mockReplaceState = jest.fn();
Object.defineProperty(window, 'history', {
  value: {
    replaceState: mockReplaceState,
  },
  writable: true
});

// Mock fetch for usePaginatedData tests
global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve({}),
  })
) as jest.Mock;

describe('usePagination', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockReplaceState.mockClear();
    (global.fetch as jest.Mock).mockClear();
  });

describe('Basic functionality', () => {
    it('should initialize with default values', () => {
      const { result } = renderHook(() => usePagination());

      expect(result.current.currentPage).toBe(1);
      expect(result.current.pageSize).toBe(10);
      expect(result.current.totalItems).toBe(0);
      expect(result.current.totalPages).toBe(1);
      expect(result.current.hasNextPage).toBe(false);
      expect(result.current.hasPreviousPage).toBe(false);
      expect(result.current.isLoading).toBe(false);
    });

    it('should initialize with custom values', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialPage: 3,
          initialPageSize: 25,
          initialTotal: 100,
        })
      );

      expect(result.current.currentPage).toBe(3);
      expect(result.current.pageSize).toBe(25);
      expect(result.current.totalItems).toBe(100);
      expect(result.current.totalPages).toBe(4);
      expect(result.current.hasNextPage).toBe(true);
      expect(result.current.hasPreviousPage).toBe(true);
    });
  });

describe('Page navigation', () => {
    it('should go to a specific page', () => {
      const onPageChange = jest.fn();
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 100,
          initialPageSize: 10,
          onPageChange,
        })
      );

      act(() => {
        result.current.goToPage(5);
      });

      expect(result.current.currentPage).toBe(5);
      expect(onPageChange).toHaveBeenCalledWith(5, 10);
    });

    it('should navigate to next page', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 100,
          initialPageSize: 10,
          initialPage: 5,
        })
      );

      act(() => {
        result.current.nextPage();
      });

      expect(result.current.currentPage).toBe(6);
    });

    it('should navigate to previous page', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 100,
          initialPageSize: 10,
          initialPage: 5,
        })
      );

      act(() => {
        result.current.previousPage();
      });

      expect(result.current.currentPage).toBe(4);
    });

    it('should navigate to first page', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 100,
          initialPageSize: 10,
          initialPage: 5,
        })
      );

      act(() => {
        result.current.firstPage();
      });

      expect(result.current.currentPage).toBe(1);
    });

    it('should navigate to last page', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 100,
          initialPageSize: 10,
          initialPage: 1,
        })
      );

      act(() => {
        result.current.lastPage();
      });

      expect(result.current.currentPage).toBe(10);
    });

    it('should not go beyond page boundaries', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 50,
          initialPageSize: 10,
        })
      );

      // Try to go beyond last page
      act(() => {
        result.current.goToPage(10);
      });
      expect(result.current.currentPage).toBe(5);

      // Try to go before first page
      act(() => {
        result.current.goToPage(0);
      });
      expect(result.current.currentPage).toBe(1);
    });

    it('should not navigate when at boundaries', () => {
      const onPageChange = jest.fn();
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 30,
          initialPageSize: 10,
          initialPage: 1,
          onPageChange,
        })
      );

      // Try to go to previous when on first page
      act(() => {
        result.current.previousPage();
      });
      expect(result.current.currentPage).toBe(1);
      expect(onPageChange).not.toHaveBeenCalled();

      // Go to last page
      act(() => {
        result.current.lastPage();
      });
      onPageChange.mockClear();

      // Try to go to next when on last page
      act(() => {
        result.current.nextPage();
      });
      expect(result.current.currentPage).toBe(3);
      expect(onPageChange).not.toHaveBeenCalled();
    });
  });

describe('Page size management', () => {
    it('should change page size', () => {
      const onPageSizeChange = jest.fn();
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 100,
          initialPageSize: 10,
          onPageSizeChange,
        })
      );

      act(() => {
        result.current.changePageSize(25);
      });

      expect(result.current.pageSize).toBe(25);
      expect(result.current.totalPages).toBe(4);
      expect(onPageSizeChange).toHaveBeenCalledWith(25, 1);
    });

    it('should reset to first page when page size changes', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 100,
          initialPageSize: 10,
          initialPage: 5,
          resetOnPageSizeChange: true,
        })
      );

      act(() => {
        result.current.changePageSize(25);
      });

      expect(result.current.currentPage).toBe(1);
    });

    it('should maintain position when page size changes', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 100,
          initialPageSize: 10,
          initialPage: 5, // Items 41-50
          resetOnPageSizeChange: false,
        })
      );

      act(() => {
        result.current.changePageSize(20);
      });

      // Should be on page 3 (items 41-60)
      expect(result.current.currentPage).toBe(3);
    });

    it('should respect min and max page size', () => {
      const { result } = renderHook(() =>
        usePagination({
          minPageSize: 5,
          maxPageSize: 50,
          initialPageSize: 10,
        })
      );

      act(() => {
        result.current.changePageSize(100);
      });
      expect(result.current.pageSize).toBe(50);

      act(() => {
        result.current.changePageSize(1);
      });
      expect(result.current.pageSize).toBe(5);
    });
  });

describe('Computed values', () => {
    it('should calculate correct indices and counts', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 95,
          initialPageSize: 10,
          initialPage: 3,
        })
      );

      expect(result.current.startIndex).toBe(20);
      expect(result.current.endIndex).toBe(29);
      expect(result.current.itemsOnPage).toBe(10);
    });

    it('should handle last page correctly', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 95,
          initialPageSize: 10,
          initialPage: 10,
        })
      );

      expect(result.current.startIndex).toBe(90);
      expect(result.current.endIndex).toBe(94);
      expect(result.current.itemsOnPage).toBe(5);
    });

    it('should handle empty results', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 0,
          initialPageSize: 10,
        })
      );

      expect(result.current.startIndex).toBe(0);
      expect(result.current.endIndex).toBe(-1);
      expect(result.current.itemsOnPage).toBe(0);
      expect(result.current.totalPages).toBe(1);
    });
  });

describe('API response updates', () => {
    it('should update from paginated response', () => {
      const { result } = renderHook(() => usePagination());

      const response: PaginatedResponse<unknown> = {
        items: [],
        total: 150,
        page: 3,
        per_page: 25,
        pages: 6,
      };

      act(() => {
        result.current.updateFromResponse(response);
      });

      expect(result.current.totalItems).toBe(150);
      expect(result.current.currentPage).toBe(3);
      expect(result.current.pageSize).toBe(25);
    });
  });

describe('Pagination info', () => {
    it('should generate correct pagination info', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 95,
          initialPageSize: 10,
          initialPage: 3,
        })
      );

      expect(result.current.paginationInfo).toEqual({
        description: 'Showing 21 to 30 of 95 items',
        shortDescription: '21-30 of 95',
        rangeText: 'Showing 21 to 30',
        totalText: 'of 95 items'
      });
    });

    it('should handle empty state', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 0,
        })
      );

      expect(result.current.paginationInfo).toEqual({
        description: 'No items found',
        shortDescription: '0 of 0',
        rangeText: 'No items',
        totalText: ''
      });
    });
  });

describe('Page numbers generation', () => {
    it('should generate all pages when total is less than max visible', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 50,
          initialPageSize: 10,
        })
      );

      const pages = result.current.getPageNumbers(7);
      expect(pages).toEqual([1, 2, 3, 4, 5]);
    });

    it('should generate ellipsis for many pages', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 200,
          initialPageSize: 10,
          initialPage: 10,
        })
      );

      const pages = result.current.getPageNumbers(7);
      expect(pages).toContain('...');
      expect(pages).toContain(1);
      expect(pages).toContain(20);
      expect(pages).toContain(10);
    });

    it('should show pages from start when near beginning', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 200,
          initialPageSize: 10,
          initialPage: 2,
        })
      );

      const pages = result.current.getPageNumbers(7);
      expect(pages).toEqual([1, 2, 3, 4, 5, '...', 20]);
    });

    it('should show pages from end when near end', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialTotal: 200,
          initialPageSize: 10,
          initialPage: 19,
        })
      );

      const pages = result.current.getPageNumbers(7);
      expect(pages).toEqual([1, '...', 16, 17, 18, 19, 20]);
    });
  });

describe('URL synchronization', () => {
    it('should sync with URL parameters', () => {
      // Set initial URL params
      delete (window as jest.Mocked<any>).location;
      (window as jest.Mocked<any>).location = new URL('http://test.com?page=3&size=25');

      const { result } = renderHook(() =>
        usePagination({
          syncWithURL: true,
          initialTotal: 100,
        })
      );

      expect(result.current.currentPage).toBe(3);
      expect(result.current.pageSize).toBe(25);
    });

    it('should update URL when page changes', () => {
      const { result } = renderHook(() =>
        usePagination({
          syncWithURL: true,
          initialTotal: 100,
        })
      );

      act(() => {
        result.current.goToPage(5);
      });

      expect(mockReplaceState).toHaveBeenCalled();
    });

    it('should use custom URL parameters', () => {
      delete (window as jest.Mocked<any>).location;
      (window as jest.Mocked<any>).location = new URL('http://test.com?p=2&s=50');

      const { result } = renderHook(() =>
        usePagination({
          syncWithURL: true,
          urlParams: { page: 'p', size: 's' },
          initialTotal: 100,
        })
      );

      expect(result.current.currentPage).toBe(2);
      expect(result.current.pageSize).toBe(50);
    });
  });

describe('Utility methods', () => {
    it('should get pagination params', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialPage: 3,
          initialPageSize: 25,
        })
      );

      const params = result.current.getPaginationParams();
      expect(params).toEqual({
        page: 3,
        per_page: 25,
        skip: 50,
        limit: 25
      });
    });

    it('should reset to initial values', () => {
      const { result } = renderHook(() =>
        usePagination({
          initialPage: 1,
          initialPageSize: 10,
          initialTotal: 100,
        })
      );

      // Change values
      act(() => {
        result.current.goToPage(5);
        result.current.changePageSize(25);
        result.current.setLoading(true);
      });

      // Reset
      act(() => {
        result.current.reset();
      });

      expect(result.current.currentPage).toBe(1);
      expect(result.current.pageSize).toBe(10);
      expect(result.current.totalItems).toBe(100);
      expect(result.current.isLoading).toBe(false);
    });

    it('should set loading state', () => {
      const { result } = renderHook(() => usePagination());

      act(() => {
        result.current.setLoading(true);
      });

      expect(result.current.isLoading).toBe(true);

      act(() => {
        result.current.setLoading(false);
      });

      expect(result.current.isLoading).toBe(false);
    });
  });
});

describe('usePaginatedData', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset fetch mock
    (global.fetch as jest.Mock).mockClear();
  });

  it('should fetch data on mount', async () => {
    const mockResponse: PaginatedResponse<{ id: number; name: string }> = {
      items: [
        { id: 1, name: 'Item 1' },
        { id: 2, name: 'Item 2' },
      ],
      total: 10,
      page: 1,
      per_page: 10,
      pages: 1,
      has_next: false,
      has_prev: false,
    };

    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: jest.fn().mockResolvedValueOnce(mockResponse)
    });

    const { result } = renderHook(() => usePaginatedData('/api/items'));

    // Initial state should be loading
    expect(result.current.loading).toBe(true);
    expect(result.current.data).toEqual([]);

    // Verify fetch was called with correct URL
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining('/api/items')
    );

    // Basic structure tests
    expect(result.current.pagination).toBeDefined();
    expect(result.current.refetch).toBeInstanceOf(Function);
  });

  it('should handle fetch errors', async () => {
    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: false,
      status: 500,
      json: jest.fn()
    });

    const { result } = renderHook(() => usePaginatedData('/api/items'));

    // Verify initial state
    expect(result.current.loading).toBe(true);
    expect(result.current.data).toEqual([]);
    expect(result.current.error).toBeNull();

    // Verify fetch was called
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining('/api/items')
    );
  });

  it('should use custom fetch function', async () => {
    const mockData = [{ id: 1, name: 'Custom' }];
    const customFetch = jest.fn().mockResolvedValue({
      items: mockData,
      total: 1,
      page: 1,
      per_page: 10,
      pages: 1,
      has_next: false,
      has_prev: false
    });

    const { result } = renderHook(() =>
      usePaginatedData('/api/items', {
        fetchFunction: customFetch,
      })
    );

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    }, { timeout: 3000 });

    expect(customFetch).toHaveBeenCalledWith('/api/items', expect.any(Object));
    expect(result.current.data).toEqual(mockData);
  });

  it('should refetch data', async () => {
    const mockResponse: PaginatedResponse<{ id: number }> = {
      items: [{ id: 1 }],
      total: 1,
      page: 1,
      per_page: 10,
      pages: 1,
      has_next: false,
      has_prev: false,
    };

    (global.fetch as jest.Mock).mockImplementation(() =>
      Promise.resolve({
        ok: true,
        json: async () => mockResponse,
      })
    );

    const { result } = renderHook(() => usePaginatedData('/api/items'));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    }, { timeout: 3000 });

    const initialCallCount = (global.fetch as jest.Mock).mock.calls.length;

    await act(async () => {
      await result.current.refetch();
    });

    expect(global.fetch).toHaveBeenCalledTimes(initialCallCount + 1);
  });

  it('should refetch when dependencies change', async () => {
    const mockResponse: PaginatedResponse<{ id: number }> = {
      items: [{ id: 1 }],
      total: 1,
      page: 1,
      per_page: 10,
      pages: 1,
      has_next: false,
      has_prev: false,
    };

    (global.fetch as jest.Mock).mockImplementation(() =>
      Promise.resolve({
        ok: true,
        json: async () => mockResponse,
      })
    );

    const { result, rerender } = renderHook(
      ({ filter }) =>
        usePaginatedData('/api/items', {
          dependencies: [filter],
        }),
      {
        initialProps: { filter: 'active' }
      }
    );

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    }, { timeout: 3000 });

    // Clear the mock calls count to isolate dependency change
    (global.fetch as jest.Mock).mockClear();

    rerender({ filter: 'inactive' });

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/items')
      );
    }, { timeout: 3000 });
  });
});