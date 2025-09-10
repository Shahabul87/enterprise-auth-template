import { useCallback, useEffect, useState } from 'react';

/**
 * Toast Hook
 * 
 * Simple toast notification hook for displaying temporary messages.
 * This is a minimal implementation - in production, you might want to use
 * a more robust toast library like react-hot-toast or sonner.
 */

export interface ToastProps {
  id?: string;
  title?: string;
  description?: string;
  variant?: 'default' | 'destructive' | 'success';
  duration?: number;
}

interface Toast extends ToastProps {
  id: string;
}

// Global toast state (simplified - in production use a context provider)
let toasts: Toast[] = [];
let listeners: ((toasts: Toast[]) => void)[] = [];

const generateId = () => Math.random().toString(36).substr(2, 9);

const addToast = (toast: ToastProps) => {
  const id = toast.id || generateId();
  const newToast: Toast = {
    ...toast,
    id,
    duration: toast.duration || 5000,
  };
  
  toasts = [...toasts, newToast];
  listeners.forEach(listener => listener(toasts));

  // Auto-remove toast after duration
  if (newToast.duration !== undefined && newToast.duration > 0) {
    setTimeout(() => {
      removeToast(id);
    }, newToast.duration);
  }

  return id;
};

const removeToast = (id: string) => {
  toasts = toasts.filter(toast => toast.id !== id);
  listeners.forEach(listener => listener(toasts));
};

const removeAllToasts = () => {
  toasts = [];
  listeners.forEach(listener => listener(toasts));
};

export function useToast() {
  const [, forceUpdate] = useState(toasts);

  // Subscribe to toast changes and force re-render
  const subscribe = useCallback((listener: (toasts: Toast[]) => void) => {
    listeners.push(listener);
    listener(toasts); // Initial call with current toasts
    return () => {
      listeners = listeners.filter(l => l !== listener);
    };
  }, []);

  useEffect(() => {
    const unsubscribe = subscribe((newToasts) => {
      forceUpdate(() => newToasts);
    });
    return unsubscribe;
  }, [subscribe]);

  const toast = useCallback((props: ToastProps) => {
    // For now, we'll use browser alerts as a fallback
    // In a real implementation, you'd integrate with a toast UI component
    if (props.variant === 'destructive') {
      
      // You could show a red toast here
    } else {
      
      // You could show a normal/success toast here
    }
    
    return addToast(props);
  }, []);

  const dismiss = useCallback((id?: string) => {
    if (id) {
      removeToast(id);
    } else {
      removeAllToasts();
    }
  }, []);

  return {
    toast,
    dismiss,
    toasts,
    subscribe,
  };
}

// Simple toast function for quick usage
export const toast = (props: ToastProps) => {
  if (props.variant === 'destructive') {
    
  } else {
    
  }
};