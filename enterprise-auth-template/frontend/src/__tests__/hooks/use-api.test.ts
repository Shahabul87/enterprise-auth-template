
import { renderHook, act } from '@testing-library/react';
import { useApi } from '@/hooks/use-api';
import React from 'react';

jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
// Orphaned closing removed
/**
 * @jest-environment jsdom
 */


// Mock fetch globally
global.fetch = jest.fn() as jest.MockedFunction<typeof fetch>;

// Mock Next.js navigation
describe('useApi', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (fetch as jest.Mock).mockReset();
  });
  it('should initialize with default state', async () => {
    const { result } = renderHook(() => useApi('/api/test'));
    expect(result.current.data).toBeNull();
    expect(result.current.error).toBeNull();
    expect(result.current.isLoading).toBe(false);
  });
  it('should handle successful GET request', async () => {
    const mockData = { id: 1, name: 'Test' };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(mockData),
      headers: new Headers({ 'content-type': 'application/json' }),
    });
    const { result } = renderHook(() => useApi('/api/test'));
    await act(async () => {
      await result.current.refetch();
    });
    expect(result.current.data).toEqual(mockData);
    expect(result.current.error).toBeNull();
    expect(result.current.isLoading).toBe(false);
  });
  it('should handle API errors', async () => {
    const errorMessage = 'Not found';
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: false,
      status: 404,
      statusText: 'Not Found',
      json: () => Promise.resolve({ error: errorMessage }),
    });
    const { result } = renderHook(() => useApi('/api/test'));
    await act(async () => {
      await result.current.refetch();
    });
    expect(result.current.data).toBeNull();
    expect(result.current.error).toEqual(expect.objectContaining({
      message: expect.stringContaining('404'),
// Orphaned closing removed
    expect(result.current.isLoading).toBe(false);
  });
  it('should handle network errors', async () => {
    (fetch as jest.Mock).mockRejectedValueOnce(new Error('Network error'));
    const { result } = renderHook(() => useApi('/api/test'));
    await act(async () => {
      await result.current.refetch();
    });
    expect(result.current.data).toBeNull();
    expect(result.current.error).toEqual(expect.objectContaining({
      message: 'Network error',
// Orphaned closing removed
    expect(result.current.isLoading).toBe(false);
  });
  it('should set loading state during request', async () => {
    let resolvePromise: (value: any) => void;
    const promise = new Promise(resolve => {
      resolvePromise = resolve;
    });
    (fetch as jest.Mock).mockReturnValueOnce(promise);
    const { result } = renderHook(() => useApi('/api/test'));
    act(() => {
      result.current.refetch();
    });
    expect(result.current.isLoading).toBe(true);
    await act(async () => {
      resolvePromise!({
        ok: true,
        json: () => Promise.resolve({ success: true }),
        headers: new Headers({ 'content-type': 'application/json' }),
      });
      await promise;
    });
    expect(result.current.isLoading).toBe(false);
  });
  it('should support POST requests', async () => {
    const postData = { name: 'New Item' };
    const responseData = { id: 1, ...postData };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(responseData),
      headers: new Headers({ 'content-type': 'application/json' }),
    });
    const { result } = renderHook(() => useApi('/api/test'));
    await act(async () => {
      await result.current.post(postData);
    });
    expect(fetch).toHaveBeenCalledWith('/api/test', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(postData),
    });
    expect(result.current.data).toEqual(responseData);
  });
  it('should support PUT requests', async () => {
    const putData = { id: 1, name: 'Updated Item' };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(putData),
      headers: new Headers({ 'content-type': 'application/json' }),
    });
    const { result } = renderHook(() => useApi('/api/test'));
    await act(async () => {
      await result.current.put(putData);
    });
    expect(fetch).toHaveBeenCalledWith('/api/test', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(putData),
    });
  });
  it('should support DELETE requests', async () => {
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ success: true }),
      headers: new Headers({ 'content-type': 'application/json' }),
    });
    const { result } = renderHook(() => useApi('/api/test/1'));
    await act(async () => {
      await result.current.delete();
    });
    expect(fetch).toHaveBeenCalledWith('/api/test/1', {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
      },
    });
  });
  it('should include authorization header when token provided', async () => {
    const mockData = { success: true };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(mockData),
      headers: new Headers({ 'content-type': 'application/json' }),
    });
    const { result } = renderHook(() =>
      useApi('/api/protected', {
        headers: { Authorization: 'Bearer token123' }
      })
    );
    await act(async () => {
      await result.current.refetch();
    });
    expect(fetch).toHaveBeenCalledWith('/api/protected', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer token123',
      },
    });
  });
  it('should handle non-JSON responses', async () => {
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      text: () => Promise.resolve('Plain text response'),
      headers: new Headers({ 'content-type': 'text/plain' }),
    });
    const { result } = renderHook(() => useApi('/api/text'));
    await act(async () => {
      await result.current.refetch();
    });
    expect(result.current.data).toBe('Plain text response');
  });
  it('should handle empty responses', async () => {
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      status: 204,
      text: () => Promise.resolve(''),
      headers: new Headers(),
    });
    const { result } = renderHook(() => useApi('/api/empty'));
    await act(async () => {
      await result.current.refetch();
    });
    expect(result.current.data).toBe('');
    expect(result.current.error).toBeNull();
  });
  it('should support custom request options', async () => {
    const mockData = { success: true };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(mockData),
      headers: new Headers({ 'content-type': 'application/json' }),
    });
    const customOptions = {
      headers: { 'X-Custom-Header': 'value' },
      credentials: 'include' as RequestCredentials,
    };
    const { result } = renderHook(() => useApi('/api/test', customOptions));
    await act(async () => {
      await result.current.refetch();
    });
    expect(fetch).toHaveBeenCalledWith('/api/test', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'X-Custom-Header': 'value',
      },
      credentials: 'include',
    });
  });
  it('should handle concurrent requests properly', async () => {
    const mockData1 = { id: 1 };
    const mockData2 = { id: 2 };
    (fetch as jest.Mock)
      .mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockData1),
        headers: new Headers({ 'content-type': 'application/json' }),
      })
      .mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockData2),
        headers: new Headers({ 'content-type': 'application/json' }),
      });
    const { result } = renderHook(() => useApi('/api/test'));
    await act(async () => {
      const [response1, response2] = await Promise.all([
        result.current.refetch(),
        result.current.refetch(),
      ]);
    });
    expect(fetch).toHaveBeenCalledTimes(2);
  });
  it('should cancel previous request when new one is made', async () => {
    const controller1 = new AbortController();
    const controller2 = new AbortController();
    (fetch as jest.Mock)
      .mockImplementationOnce(() => new Promise(resolve => setTimeout(resolve, 1000)))
      .mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ id: 2 }),
        headers: new Headers({ 'content-type': 'application/json' }),
      });
    const { result } = renderHook(() => useApi('/api/test'));
    // Start first request
    act(() => {
      result.current.refetch();
    });
    // Start second request immediately
    await act(async () => {
      await result.current.refetch();
    });
    expect(result.current.data).toEqual({ id: 2 });
  });

describe('Error Handling', () => {
    it('should handle malformed JSON responses', async () => {
      (fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: () => Promise.reject(new Error('Invalid JSON')),
        text: () => Promise.resolve('Invalid JSON response'),
        headers: new Headers({ 'content-type': 'application/json' }),
      });
      const { result } = renderHook(() => useApi('/api/test'));
      await act(async () => {
        await result.current.refetch();
      });
      expect(result.current.error).toEqual(expect.objectContaining({
        message: expect.stringContaining('Invalid JSON'),
// Orphaned closing removed
    });
    it('should handle timeout errors', async () => {
      (fetch as jest.Mock).mockImplementationOnce(() =>
        new Promise((_, reject) =>
          setTimeout(() => reject(new Error('Request timeout')), 100)
        )
      );
      const { result } = renderHook(() => useApi('/api/test'));
      await act(async () => {
        await result.current.refetch();
      });
      expect(result.current.error).toEqual(expect.objectContaining({
        message: 'Request timeout',
// Orphaned closing removed
    });
  });

describe('Caching', () => {
    it('should not cache by default', async () => {
      const mockData = { id: 1, timestamp: Date.now() };
      (fetch as jest.Mock).mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(mockData),
        headers: new Headers({ 'content-type': 'application/json' }),
      });
      const { result } = renderHook(() => useApi('/api/test'));
      await act(async () => {
        await result.current.refetch();
      });
      await act(async () => {
        await result.current.refetch();
      });
      expect(fetch).toHaveBeenCalledTimes(2);
    });
  });
});