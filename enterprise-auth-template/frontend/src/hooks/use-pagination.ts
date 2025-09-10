'use client';

import { useState, useCallback, useMemo, useEffect } from 'react';
import { PaginatedResponse, PaginationParams } from '@/types/api.types';

/**
 * Pagination logic hook with comprehensive state management
 * 
 * Provides complete pagination functionality including:
 * - Page navigation (first, previous, next, last)
 * - Page size management
 * - URL synchronization
 * - Loading states
 * - Data transformation utilities
 * 
 * @example
 * ```typescript
 * // Basic usage
 * const {
 *   currentPage,
 *   pageSize,
 *   totalItems,
 *   totalPages,
 *   goToPage,
 *   nextPage,
 *   previousPage,
 *   changePageSize,
 *   paginationInfo
 * } = usePagination({
 *   initialPage: 1,
 *   initialPageSize: 10
 * });
 * 
 * // With API integration
 * const { execute } = useApi<PaginatedResponse<User>>();
 * const pagination = usePagination({
 *   onPageChange: async (page, size) => {
 *     const result = await execute(`/api/users?page=${page}&size=${size}`);
 *     if (result.success && result.data) {
 *       pagination.updateFromResponse(result.data);
 *     }
 *   }
 * });
 * ```
 */

export interface PaginationConfig {
  /** Initial page number (1-based) */
  initialPage?: number;
  /** Initial page size */
  initialPageSize?: number;
  /** Total number of items (if known upfront) */
  initialTotal?: number;
  /** Available page size options */
  pageSizeOptions?: number[];
  /** Maximum page size allowed */
  maxPageSize?: number;
  /** Minimum page size allowed */
  minPageSize?: number;
  /** Whether to sync with URL parameters */
  syncWithURL?: boolean;
  /** URL parameter names */
  urlParams?: {
    page?: string;
    size?: string;
  };
  /** Callback when page changes */
  onPageChange?: (page: number, pageSize: number) => void | Promise<void>;
  /** Callback when page size changes */
  onPageSizeChange?: (pageSize: number, currentPage: number) => void | Promise<void>;
  /** Whether to reset to first page when page size changes */
  resetOnPageSizeChange?: boolean;
}

export interface PaginationState {
  /** Current page number (1-based) */
  currentPage: number;
  /** Current page size */
  pageSize: number;
  /** Total number of items */
  totalItems: number;
  /** Total number of pages */
  totalPages: number;
  /** Whether there is a next page */
  hasNextPage: boolean;
  /** Whether there is a previous page */
  hasPreviousPage: boolean;
  /** Whether pagination is loading */
  isLoading: boolean;
  /** Start index of current page (0-based) */
  startIndex: number;
  /** End index of current page (0-based) */
  endIndex: number;
  /** Items shown on current page */
  itemsOnPage: number;
}

export interface PaginationActions {
  /** Go to specific page */
  goToPage: (page: number) => void;
  /** Go to next page */
  nextPage: () => void;
  /** Go to previous page */
  previousPage: () => void;
  /** Go to first page */
  firstPage: () => void;
  /** Go to last page */
  lastPage: () => void;
  /** Change page size */
  changePageSize: (size: number) => void;
  /** Update pagination from API response */
  updateFromResponse: (response: PaginatedResponse<unknown>) => void;
  /** Set loading state */
  setLoading: (loading: boolean) => void;
  /** Reset to initial state */
  reset: () => void;
  /** Get pagination parameters for API requests */
  getPaginationParams: () => PaginationParams;
  /** Generate page numbers for display */
  getPageNumbers: (maxVisible?: number) => (number | '...')[];
}

export interface PaginationInfo {
  /** Descriptive text for current pagination state */
  description: string;
  /** Short description (e.g., "1-10 of 100") */
  shortDescription: string;
  /** Range text (e.g., "Showing 1 to 10") */
  rangeText: string;
  /** Total text (e.g., "of 100 items") */
  totalText: string;
}

export interface UsePaginationReturn extends PaginationState, PaginationActions {
  /** Formatted pagination information */
  paginationInfo: PaginationInfo;
}

export function usePagination(config: PaginationConfig = {}): UsePaginationReturn {
  const {
    initialPage = 1,
    initialPageSize = 10,
    initialTotal = 0,
    // pageSizeOptions = [5, 10, 25, 50, 100],
    maxPageSize = 100,
    minPageSize = 1,
    syncWithURL = false,
    urlParams = { page: 'page', size: 'size' },
    onPageChange,
    onPageSizeChange,
    resetOnPageSizeChange = true,
  } = config;

  // Initialize state from URL if syncing
  const getInitialState = useCallback(() => {
    if (syncWithURL && typeof window !== 'undefined') {
      const urlSearchParams = new URLSearchParams(window.location.search);
      const pageFromURL = urlSearchParams.get(urlParams.page || 'page');
      const sizeFromURL = urlSearchParams.get(urlParams.size || 'size');

      return {
        currentPage: pageFromURL ? Math.max(1, parseInt(pageFromURL, 10)) : initialPage,
        pageSize: sizeFromURL ? Math.max(minPageSize, Math.min(maxPageSize, parseInt(sizeFromURL, 10))) : initialPageSize,
      };
    }

    return {
      currentPage: initialPage,
      pageSize: initialPageSize,
    };
  }, [syncWithURL, urlParams, initialPage, initialPageSize, minPageSize, maxPageSize]);

  const [currentPage, setCurrentPage] = useState<number>(getInitialState().currentPage);
  const [pageSize, setPageSize] = useState<number>(getInitialState().pageSize);
  const [totalItems, setTotalItems] = useState<number>(initialTotal);
  const [isLoading, setIsLoading] = useState<boolean>(false);

  // Update URL when page or size changes
  useEffect(() => {
    if (syncWithURL && typeof window !== 'undefined') {
      const url = new URL(window.location.href);
      url.searchParams.set(urlParams.page || 'page', currentPage.toString());
      url.searchParams.set(urlParams.size || 'size', pageSize.toString());
      
      // Update URL without triggering navigation
      window.history.replaceState({}, '', url.toString());
    }
  }, [currentPage, pageSize, syncWithURL, urlParams]);

  // Computed values
  const totalPages = useMemo(() => {
    return Math.ceil(totalItems / pageSize) || 1;
  }, [totalItems, pageSize]);

  const hasNextPage = useMemo(() => {
    return currentPage < totalPages;
  }, [currentPage, totalPages]);

  const hasPreviousPage = useMemo(() => {
    return currentPage > 1;
  }, [currentPage]);

  const startIndex = useMemo(() => {
    return (currentPage - 1) * pageSize;
  }, [currentPage, pageSize]);

  const endIndex = useMemo(() => {
    return Math.min(startIndex + pageSize - 1, totalItems - 1);
  }, [startIndex, pageSize, totalItems]);

  const itemsOnPage = useMemo(() => {
    return totalItems > 0 ? endIndex - startIndex + 1 : 0;
  }, [startIndex, endIndex, totalItems]);

  // Actions
  const goToPage = useCallback(
    (page: number) => {
      const targetPage = Math.max(1, Math.min(totalPages, page));
      
      if (targetPage !== currentPage) {
        setCurrentPage(targetPage);
        
        if (onPageChange) {
          onPageChange(targetPage, pageSize);
        }
      }
    },
    [currentPage, totalPages, pageSize, onPageChange]
  );

  const nextPage = useCallback(() => {
    if (hasNextPage) {
      goToPage(currentPage + 1);
    }
  }, [hasNextPage, currentPage, goToPage]);

  const previousPage = useCallback(() => {
    if (hasPreviousPage) {
      goToPage(currentPage - 1);
    }
  }, [hasPreviousPage, currentPage, goToPage]);

  const firstPage = useCallback(() => {
    goToPage(1);
  }, [goToPage]);

  const lastPage = useCallback(() => {
    goToPage(totalPages);
  }, [goToPage, totalPages]);

  const changePageSize = useCallback(
    (size: number) => {
      const newSize = Math.max(minPageSize, Math.min(maxPageSize, size));
      
      if (newSize !== pageSize) {
        setPageSize(newSize);
        
        // Calculate what the current page should be with new page size
        const currentStartIndex = startIndex;
        const newPage = resetOnPageSizeChange 
          ? 1 
          : Math.max(1, Math.floor(currentStartIndex / newSize) + 1);
        
        setCurrentPage(newPage);
        
        if (onPageSizeChange) {
          onPageSizeChange(newSize, newPage);
        }
        
        if (onPageChange) {
          onPageChange(newPage, newSize);
        }
      }
    },
    [pageSize, minPageSize, maxPageSize, startIndex, resetOnPageSizeChange, onPageSizeChange, onPageChange]
  );

  const updateFromResponse = useCallback(
    (response: PaginatedResponse<unknown>) => {
      setTotalItems(response.total);
      setCurrentPage(response.page);
      // Only update page size if it&apos;s different (API might return actual page size used)
      if (response.per_page !== pageSize) {
        setPageSize(response.per_page);
      }
    },
    [pageSize]
  );

  const reset = useCallback(() => {
    setCurrentPage(initialPage);
    setPageSize(initialPageSize);
    setTotalItems(initialTotal);
    setIsLoading(false);
  }, [initialPage, initialPageSize, initialTotal]);

  const getPaginationParams = useCallback((): PaginationParams => {
    return {
      page: currentPage,
      per_page: pageSize,
      skip: startIndex,
      limit: pageSize,
    };
  }, [currentPage, pageSize, startIndex]);

  const getPageNumbers = useCallback(
    (maxVisible = 7): (number | '...')[] => {
      if (totalPages <= maxVisible) {
        return Array.from({ length: totalPages }, (_, i) => i + 1);
      }

      const halfVisible = Math.floor(maxVisible / 2);
      const pages: (number | '...')[] = [];

      if (currentPage <= halfVisible + 1) {
        // Show pages from start
        for (let i = 1; i <= maxVisible - 2; i++) {
          pages.push(i);
        }
        pages.push('...');
        pages.push(totalPages);
      } else if (currentPage >= totalPages - halfVisible) {
        // Show pages from end
        pages.push(1);
        pages.push('...');
        for (let i = totalPages - maxVisible + 3; i <= totalPages; i++) {
          pages.push(i);
        }
      } else {
        // Show pages around current page
        pages.push(1);
        pages.push('...');
        for (let i = currentPage - halfVisible + 1; i <= currentPage + halfVisible - 1; i++) {
          pages.push(i);
        }
        pages.push('...');
        pages.push(totalPages);
      }

      return pages;
    },
    [currentPage, totalPages]
  );

  // Pagination info
  const paginationInfo = useMemo((): PaginationInfo => {
    if (totalItems === 0) {
      return {
        description: 'No items found',
        shortDescription: '0 of 0',
        rangeText: 'No items',
        totalText: '',
      };
    }

    const start = startIndex + 1;
    const end = Math.min(startIndex + pageSize, totalItems);
    
    return {
      description: `Showing ${start} to ${end} of ${totalItems} items`,
      shortDescription: `${start}-${end} of ${totalItems}`,
      rangeText: `Showing ${start} to ${end}`,
      totalText: `of ${totalItems} items`,
    };
  }, [startIndex, pageSize, totalItems]);

  return {
    // State
    currentPage,
    pageSize,
    totalItems,
    totalPages,
    hasNextPage,
    hasPreviousPage,
    isLoading,
    startIndex,
    endIndex,
    itemsOnPage,
    paginationInfo,
    
    // Actions
    goToPage,
    nextPage,
    previousPage,
    firstPage,
    lastPage,
    changePageSize,
    updateFromResponse,
    setLoading: setIsLoading,
    reset,
    getPaginationParams,
    getPageNumbers,
  };
}

/**
 * Hook for paginated data fetching with automatic pagination management
 * 
 * @example
 * ```typescript
 * const {
 *   data,
 *   loading,
 *   error,
 *   pagination,
 *   refetch,
 * } = usePaginatedData<User>(
 *   '/api/users',
 *   { initialPageSize: 20 }
 * );
 * ```
 */
export function usePaginatedData<T>(
  url: string,
  config: PaginationConfig & {
    fetchFunction?: (url: string, params: PaginationParams) => Promise<PaginatedResponse<T>>;
    dependencies?: unknown[];
  } = {}
) {
  const { fetchFunction, dependencies = [], ...paginationConfig } = config;
  const [data, setData] = useState<T[]>([]);
  const [error, setError] = useState<Error | null>(null);

  const pagination = usePagination({
    ...paginationConfig,
    onPageChange: async (page, size) => {
      await fetchData(page, size);
    },
    onPageSizeChange: async (size, page) => {
      await fetchData(page, size);
    },
  });

  const fetchData = useCallback(
    async (page?: number, size?: number) => {
      try {
        pagination.setLoading(true);
        setError(null);

        const params = {
          page: page || pagination.currentPage,
          size: size || pagination.pageSize,
          skip: ((page || pagination.currentPage) - 1) * (size || pagination.pageSize),
          limit: size || pagination.pageSize,
        };

        let response: PaginatedResponse<T>;
        
        if (fetchFunction) {
          response = await fetchFunction(url, params);
        } else {
          // Default fetch implementation
          const queryString = new URLSearchParams(
            Object.entries(params).reduce((acc, [key, value]) => {
              acc[key] = String(value);
              return acc;
            }, {} as Record<string, string>)
          ).toString();
          
          const res = await fetch(`${url}?${queryString}`);
          if (!res.ok) {
            throw new Error(`HTTP error! status: ${res.status}`);
          }
          response = await res.json();
        }

        setData(response.items);
        pagination.updateFromResponse(response);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
      } finally {
        pagination.setLoading(false);
      }
    },
    [url, fetchFunction, pagination]
  );

  // Initial fetch and refetch on dependencies change
  // We use JSON.stringify to create a stable dependency
  const depsString = JSON.stringify(dependencies);
  useEffect(() => {
    fetchData();
  }, [fetchData, depsString]);

  const refetch = useCallback(() => {
    return fetchData();
  }, [fetchData]);

  return {
    data,
    loading: pagination.isLoading,
    error,
    pagination,
    refetch,
  };
}