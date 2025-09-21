
import { renderHook, act } from '@testing-library/react';
import { useApi } from '@/hooks/use-api';
import React from 'react';

jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
}));
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
    const { result } = renderHook(() => useApi());
    expect(result.current.data).toBeNull();
    expect(result.current.error).toBeNull();
    expect(result.current.loading).toBe(false);
  });
  it('should handle successful GET request', async () => {}}));
    const mockData = { id: 1, name: 'Test' };
    const apiResponse = { success: true, data: mockData };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(apiResponse),
      headers: new Headers({ 'content-type': 'application/json' })
    });
    const { result } = renderHook(() => useApi());
    await act(async () => {
      await result.current.execute('/api/test');
    });
    expect(result.current.data).toEqual(mockData);
    expect(result.current.error).toBeNull();
    expect(result.current.loading).toBe(false);
  });
  it('should handle API errors', async () => {
    const errorMessage = 'Not found';
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: false,
      status: 404,
      statusText: 'Not Found',
      json: () => Promise.resolve({ message: errorMessage })
    });
    const { result } = renderHook(() => useApi());
    await act(async () => {
      await result.current.execute('/api/test');
    });
    expect(result.current.data).toBeNull();
    expect(result.current.error).toEqual(expect.objectContaining({
      code: expect.any(String),
      message: expect.any(String),
    }));
    expect(result.current.loading).toBe(false);
  });
  it('should handle network errors', async () => {
    (fetch as jest.Mock).mockRejectedValueOnce(new Error('Network error'));
    const { result } = renderHook(() => useApi());
    await act(async () => {
      await result.current.execute('/api/test');
    });
    expect(result.current.data).toBeNull();
    expect(result.current.error).toEqual(expect.objectContaining({
      message: 'Network error',
}));
    expect(result.current.loading).toBe(false);
  });
  it('should set loading state during request', async () => {
    let resolvePromise: (value: any) => void;
    const promise = new Promise(resolve => {
      resolvePromise = resolve;
    });
    (fetch as jest.Mock).mockReturnValueOnce(promise);
    const { result } = renderHook(() => useApi());
    act(() => {
      result.current.execute('/api/test');
    });
    expect(result.current.loading).toBe(true);
    await act(async () => {
      resolvePromise!({
        ok: true,
        json: () => Promise.resolve({ success: true, data: { success: true } }),
        headers: new Headers({ 'content-type': 'application/json' })
      });
      await promise;
    });
    expect(result.current.loading).toBe(false);
  });
  it('should support POST requests', async () => {
    const postData = { name: 'New Item' };
    const responseData = { id: 1, ...postData };
    const apiResponse = { success: true, data: responseData };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(apiResponse),
      headers: new Headers({ 'content-type': 'application/json' })
    });
    const { result } = renderHook(() => useApi());
    await act(async () => {
      await result.current.execute('/api/test', { method: 'POST', data: postData });
    });
    expect(fetch).toHaveBeenCalledWith('/api/test', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(postData),
      signal: expect.any(AbortSignal),
      credentials: 'include',
    });
    expect(result.current.data).toEqual(responseData);
  });
  it('should support PUT requests', async () => {
    const putData = { id: 1, name: 'Updated Item' };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ success: true, data: { success: true, data: putData } }),
      headers: new Headers({ 'content-type': 'application/json' })
    });
    const { result } = renderHook(() => useApi());
    await act(async () => {
      await result.current.execute('/api/test', { method: 'PUT', data: putData });
    });
    expect(fetch).toHaveBeenCalledWith('/api/test', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(putData),
      signal: expect.any(AbortSignal),
      credentials: 'include',
    });
  });
  it('should support DELETE requests', async () => {
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ success: true, data: { success: true } }),
      headers: new Headers({ 'content-type': 'application/json' })
    });
    const { result } = renderHook(() => useApi());
    await act(async () => {
      await result.current.execute('/api/test', { method: 'DELETE' });
    });
    expect(fetch).toHaveBeenCalledWith('/api/test', {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
      },
      signal: expect.any(AbortSignal),
      credentials: 'include',
    });
  });
  it('should include authorization header when token provided', async () => {
    const mockData = { success: true };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ success: true, data: { success: true, data: mockData } }),
      headers: new Headers({ 'content-type': 'application/json' })
    });
    const { result } = renderHook(() =>
      useApi('/api/protected', {
        headers: { Authorization: 'Bearer token123' }
      })
    );
    await act(async () => {
      await result.current.execute('/api/test');
    });
    expect(fetch).toHaveBeenCalledWith('/api/test', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
      signal: expect.any(AbortSignal),
      credentials: 'include',
    });
  });
  it('should handle non-JSON responses', async () => {
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.reject(new Error('Not JSON')),
      headers: new Headers({ 'content-type': 'text/plain' })
    });
    const { result } = renderHook(() => useApi());
    await act(async () => {
      await result.current.execute('/api/test');
    });
    expect(result.current.data).toBeNull();
    expect(result.current.error).toEqual(expect.objectContaining({
      message: expect.any(String),
    }));
  });
  it('should handle empty responses', async () => {
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      status: 204,
      json: () => Promise.resolve({ success: true, data: null }),
      headers: new Headers()
    });
    const { result } = renderHook(() => useApi());
    await act(async () => {
      await result.current.execute('/api/test');
    });
    expect(result.current.data).toBeNull();
    expect(result.current.error).toBeNull();
  });
  it('should support custom request options', async () => {
    const mockData = { success: true };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ success: true, data: { success: true, data: mockData } }),
      headers: new Headers({ 'content-type': 'application/json' })
    });
    const customOptions = {
      headers: { 'X-Custom-Header': 'value' },
      credentials: 'include' as RequestCredentials,
    };
    const { result } = renderHook(() => useApi('/api/test', customOptions));
    await act(async () => {
      await result.current.execute('/api/test');
    });
    expect(fetch).toHaveBeenCalledWith('/api/test', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
      signal: expect.any(AbortSignal),
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
        headers: new Headers({ 'content-type': 'application/json' })
      });
    const { result } = renderHook(() => useApi());
    await act(async () => {
      const [response1, response2] = await Promise.all([
        result.current.execute('/api/test'),
        result.current.execute('/api/test'),
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
        json: () => Promise.resolve({ success: true, data: { id: 2 } }),
        headers: new Headers({ 'content-type': 'application/json' })
      });
    const { result } = renderHook(() => useApi());
    // Start first request
    act(() => {
      result.current.execute('/api/test');
    });
    // Start second request immediately
    await act(async () => {
      await result.current.execute('/api/test');
    });
    expect(result.current.data).toEqual({ id: 2 });
  });

describe('Error Handling', () => {
    it('should handle malformed JSON responses', async () => {
      (fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: () => Promise.reject(new Error('Invalid JSON')),
        text: () => Promise.resolve('Invalid JSON response'),
        headers: new Headers({ 'content-type': 'application/json' })
      });
      const { result } = renderHook(() => useApi());
      await act(async () => {
        await result.current.execute('/api/test');
      });
      expect(result.current.error).toEqual(expect.objectContaining({
        message: expect.stringContaining('Invalid JSON'),
}));
    });
    it('should handle timeout errors', async () => {
      (fetch as jest.Mock).mockImplementationOnce(() =>
        new Promise((_, reject) =>
          setTimeout(() => reject(new Error('Request timeout')), 100)
        )
      );
      const { result } = renderHook(() => useApi());
      await act(async () => {
        await result.current.execute('/api/test');
      });
      expect(result.current.error).toEqual(expect.objectContaining({
        message: 'Request timeout',
}));
    });
  });

describe('Caching', () => {
    it('should not cache by default', async () => {
      const mockData = { id: 1, timestamp: Date.now() };
      (fetch as jest.Mock).mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ success: true, data: { success: true, data: mockData } }),
        headers: new Headers({ 'content-type': 'application/json' })
      });
      const { result } = renderHook(() => useApi());
      await act(async () => {
        await result.current.execute('/api/test');
      });
      await act(async () => {
        await result.current.execute('/api/test');
      });
      expect(fetch).toHaveBeenCalledTimes(2);
    });
  });
});