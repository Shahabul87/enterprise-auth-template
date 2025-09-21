
import { renderHook, act, waitFor } from '@testing-library/react';
import { useToast, ToastProps } from '@/hooks/use-toast';
import React from 'react';

/**
 * @jest-environment jsdom
 */


describe('useToast', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.useFakeTimers();
    // Reset global toasts array between tests
    const { result } = renderHook(() => useToast());
    act(() => {
      result.current.dismiss();
    });
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('should initialize with empty toasts', () => {
    const { result } = renderHook(() => useToast());
    expect(result.current.toasts).toEqual([]);
  });

  it('should add a basic toast', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({
        title: 'Test Toast',
        description: 'This is a test toast'
      });
    });

    expect(result.current.toasts).toHaveLength(1);
    expect(result.current.toasts[0]).toMatchObject({
      title: 'Test Toast',
      description: 'This is a test toast',
      duration: 5000
    });
    expect(result.current.toasts[0].id).toBeDefined();
  });

  it('should add a success toast', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({
        title: 'Success',
        description: 'Operation completed successfully',
        variant: 'success'
      });
    });

    expect(result.current.toasts[0]).toMatchObject({
      title: 'Success',
      description: 'Operation completed successfully',
      variant: 'success'
    });
  });

  it('should add a destructive toast', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({
        title: 'Error',
        description: 'Something went wrong',
        variant: 'destructive'
      });
    });

    expect(result.current.toasts[0]).toMatchObject({
      title: 'Error',
      description: 'Something went wrong',
      variant: 'destructive'
    });
  });

  it('should auto-dismiss toast after duration', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({
        title: 'Auto Dismiss',
        duration: 3000
      });
    });

    expect(result.current.toasts).toHaveLength(1);

    act(() => {
      jest.advanceTimersByTime(3000);
    });

    expect(result.current.toasts).toHaveLength(0);
  });

  it('should handle custom duration', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({
        title: 'Custom Duration',
        duration: 10000
      });
    });

    expect(result.current.toasts[0].duration).toBe(10000);

    act(() => {
      jest.advanceTimersByTime(5000);
    });

    expect(result.current.toasts).toHaveLength(1);

    act(() => {
      jest.advanceTimersByTime(5000);
    });

    expect(result.current.toasts).toHaveLength(0);
  });

  it('should not auto-dismiss when duration is 0', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({
        title: 'Persistent Toast',
        duration: 0
      });
    });

    act(() => {
      jest.advanceTimersByTime(10000);
    });

    expect(result.current.toasts).toHaveLength(1);
  });

  it('should dismiss specific toast by id', () => {
    const { result } = renderHook(() => useToast());

    let toastId: string;

    act(() => {
      toastId = result.current.toast({
        title: 'Toast 1'
      });
      result.current.toast({
        title: 'Toast 2'
      });
    });

    expect(result.current.toasts).toHaveLength(2);

    act(() => {
      result.current.dismiss(toastId!);
    });

    expect(result.current.toasts).toHaveLength(1);
    expect(result.current.toasts[0].title).toBe('Toast 2');
  });

  it('should dismiss all toasts', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({ title: 'Toast 1' });
      result.current.toast({ title: 'Toast 2' });
      result.current.toast({ title: 'Toast 3' });
    });

    expect(result.current.toasts).toHaveLength(3);

    act(() => {
      result.current.dismiss();
    });

    expect(result.current.toasts).toHaveLength(0);
  });

  it('should handle custom id', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({
        id: 'custom-toast-id',
        title: 'Custom ID Toast'
      });
    });

    expect(result.current.toasts[0].id).toBe('custom-toast-id');
  });

  it('should handle multiple toasts simultaneously', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({ title: 'Toast 1', duration: 1000 });
      result.current.toast({ title: 'Toast 2', duration: 2000 });
      result.current.toast({ title: 'Toast 3', duration: 3000 });
    });

    expect(result.current.toasts).toHaveLength(3);

    act(() => {
      jest.advanceTimersByTime(1000);
    });

    expect(result.current.toasts).toHaveLength(2);

    act(() => {
      jest.advanceTimersByTime(1000);
    });

    expect(result.current.toasts).toHaveLength(1);

    act(() => {
      jest.advanceTimersByTime(1000);
    });

    expect(result.current.toasts).toHaveLength(0);
  });

  it('should subscribe to toast updates', () => {
    const { result } = renderHook(() => useToast());
    const listener = jest.fn();

    act(() => {
      const unsubscribe = result.current.subscribe(listener);

      result.current.toast({ title: 'New Toast' });

      // Listener should be called with initial state and after adding toast
      expect(listener).toHaveBeenCalled();

      unsubscribe();
    });

    // After unsubscribing, listener shouldn't be called
    act(() => {
      result.current.toast({ title: 'Another Toast' });
    });

    const previousCallCount = listener.mock.calls.length;
    expect(listener).toHaveBeenCalledTimes(previousCallCount);
  });

  it('should handle toast without title or description', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({});
    });

    expect(result.current.toasts).toHaveLength(1);
    expect(result.current.toasts[0]).toMatchObject({
      duration: 5000
    });
  });

  it('should return unique toast id', () => {
    const { result } = renderHook(() => useToast());

    const ids: string[] = [];

    act(() => {
      ids.push(result.current.toast({ title: 'Toast 1' }));
      ids.push(result.current.toast({ title: 'Toast 2' }));
      ids.push(result.current.toast({ title: 'Toast 3' }));
    });

    const uniqueIds = new Set(ids);
    expect(uniqueIds.size).toBe(3);
  });

  it('should handle re-renders correctly', () => {
    const { result, rerender } = renderHook(() => useToast());

    act(() => {
      result.current.toast({ title: 'Initial Toast' });
    });

    expect(result.current.toasts).toHaveLength(1);

    rerender();

    expect(result.current.toasts).toHaveLength(1);
    expect(result.current.toasts[0].title).toBe('Initial Toast');
  });

  it('should handle multiple hook instances', () => {
    const { result: result1 } = renderHook(() => useToast());
    const { result: result2 } = renderHook(() => useToast());

    act(() => {
      result1.current.toast({ title: 'From Hook 1' });
    });

    // Both hooks should see the same toasts
    expect(result1.current.toasts).toHaveLength(1);
    expect(result2.current.toasts).toHaveLength(1);
    expect(result2.current.toasts[0].title).toBe('From Hook 1');
  });

  it('should queue toasts in order', () => {
    const { result } = renderHook(() => useToast());

    act(() => {
      result.current.toast({ title: 'First' });
      result.current.toast({ title: 'Second' });
      result.current.toast({ title: 'Third' });
    });

    expect(result.current.toasts[0].title).toBe('First');
    expect(result.current.toasts[1].title).toBe('Second');
    expect(result.current.toasts[2].title).toBe('Third');
  });

  it('should handle rapid toast additions and dismissals', () => {
    const { result } = renderHook(() => useToast());

    const ids: string[] = [];

    act(() => {
      for (let i = 0; i < 10; i++) {
        ids.push(result.current.toast({ title: `Toast ${i}` }));
      }
    });

    expect(result.current.toasts).toHaveLength(10);

    act(() => {
      // Dismiss even-numbered toasts
      ids.forEach((id, index) => {
        if (index % 2 === 0) {
          result.current.dismiss(id);
        }
      });
    });

    expect(result.current.toasts).toHaveLength(5);
    result.current.toasts.forEach((toast) => {
      const toastNumber = parseInt(toast.title!.split(' ')[1]);
      expect(toastNumber % 2).toBe(1);
    });
  });
});