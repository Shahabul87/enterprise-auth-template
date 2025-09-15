# Unified State Management & Error Handling Migration Guide

## Overview

This guide explains the new unified state management system using Zustand and the standardized error handling implementation for the frontend application.

## ✅ What's Been Implemented

### 1. **Unified Auth Store (Zustand)**
- **Location**: `frontend/src/stores/auth.store.ts`
- **Features**:
  - Single source of truth for authentication state
  - Built-in error handling
  - Session management
  - Permission & role management
  - Automatic token refresh
  - Persistent state (non-sensitive data only)
  - TypeScript support with full typing

### 2. **Global Error Boundary**
- **Location**: `frontend/src/components/error-boundary/auth-error-boundary.tsx`
- **Features**:
  - Catches and handles React component errors
  - Special handling for authentication errors
  - Development vs production modes
  - User-friendly error messages
  - Recovery actions (retry, logout, reload)

### 3. **Standardized Error Handler**
- **Location**: `frontend/src/lib/error-handler.ts`
- **Features**:
  - Consistent error parsing and categorization
  - User-friendly error messages
  - Error severity levels
  - Retryable error detection
  - Toast notifications integration

### 4. **Error Handling Hooks**
- **Location**: `frontend/src/hooks/use-error-handler.ts`
- **Hooks**:
  - `useErrorHandler()` - General error handling
  - `useAsyncOperation()` - Async operations with loading/error states
  - `useFormErrorHandler()` - Form-specific error handling
  - `useMutation()` - API mutations with optimistic updates

### 5. **Example Implementation**
- **Location**: `frontend/src/components/auth/login-form-unified.tsx`
- Shows how to use the new unified system

## 🔄 Migration Steps

### Step 1: Install Zustand

```bash
npm install zustand
```

### Step 2: Replace Context Usage

#### Before (Using Context):
```tsx
import { useAuth } from '@/contexts/auth-context';

function Component() {
  const { user, isAuthenticated, login, logout } = useAuth();
  // ...
}
```

#### After (Using Zustand Store):
```tsx
import { useAuthStore } from '@/stores/auth.store';

function Component() {
  const { user, isAuthenticated, login, logout } = useAuthStore();
  // ...
}
```

### Step 3: Update Error Handling

#### Before (Inconsistent):
```tsx
try {
  const result = await apiCall();
} catch (error) {
  console.error(error);
  setError('Something went wrong');
}
```

#### After (Standardized):
```tsx
import { useErrorHandler } from '@/hooks/use-error-handler';

function Component() {
  const { handleError } = useErrorHandler();
  
  try {
    const result = await apiCall();
  } catch (error) {
    handleError(error); // Automatically shows toast, logs, etc.
  }
}
```

### Step 4: Use Error Boundary

Wrap your app or specific sections with the error boundary:

```tsx
// In app/layout.tsx or specific pages
import { AuthErrorBoundary } from '@/components/error-boundary/auth-error-boundary';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <AuthErrorBoundary>
          {children}
        </AuthErrorBoundary>
      </body>
    </html>
  );
}
```

### Step 5: Update Components

#### Login Form Example:
```tsx
import { useAuthStore } from '@/stores/auth.store';
import { useFormErrorHandler } from '@/hooks/use-error-handler';

function LoginForm() {
  const { login } = useAuthStore();
  const { fieldErrors, handleFormError } = useFormErrorHandler();
  
  const onSubmit = async (data) => {
    try {
      const response = await login(data);
      if (response.success) {
        router.push('/dashboard');
      }
    } catch (error) {
      handleFormError(error);
    }
  };
}
```

#### Protected Route Example:
```tsx
import { useAuthStore } from '@/stores/auth.store';

function ProtectedPage() {
  const { isAuthenticated, hasPermission } = useAuthStore();
  
  if (!isAuthenticated) {
    return <Redirect to="/login" />;
  }
  
  if (!hasPermission('page:view')) {
    return <Unauthorized />;
  }
  
  return <PageContent />;
}
```

## 📊 Benefits of the New System

### 1. **Centralized State Management**
- Single source of truth for auth state
- No prop drilling
- Consistent state across components
- Better performance with selective subscriptions

### 2. **Consistent Error Handling**
- Standardized error format
- Automatic error categorization
- User-friendly messages
- Proper error recovery options

### 3. **Better Developer Experience**
- Full TypeScript support
- DevTools integration
- Clear separation of concerns
- Reusable hooks and utilities

### 4. **Improved User Experience**
- Consistent error messages
- Automatic session management
- Better error recovery
- Loading states handled properly

## 🎯 Usage Examples

### Basic Authentication
```tsx
const { 
  user, 
  isAuthenticated, 
  login, 
  logout,
  isLoading 
} = useAuthStore();
```

### Permission Checking
```tsx
const { hasPermission, hasRole, hasAnyRole } = useAuthStore();

if (hasPermission('users:write')) {
  // Show edit button
}

if (hasRole('admin')) {
  // Show admin panel
}
```

### Error Handling
```tsx
const { execute, isLoading, error } = useAsyncOperation();

const fetchData = async () => {
  await execute(
    async () => apiCall(),
    {
      onSuccess: (data) => console.log('Success:', data),
      onError: (error) => console.log('Error:', error),
      showToast: true
    }
  );
};
```

### Form Errors
```tsx
const { 
  fieldErrors, 
  getFieldError, 
  handleFormError 
} = useFormErrorHandler();

// In form field
<Input 
  className={getFieldError('email') ? 'error' : ''}
/>
{getFieldError('email') && (
  <span>{getFieldError('email')}</span>
)}
```

## 🔧 Configuration

### Store Configuration
The auth store can be configured in `frontend/src/stores/auth.store.ts`:
- Token refresh interval
- Persistence settings
- DevTools options

### Error Messages
Custom error messages can be added in `frontend/src/lib/error-handler.ts`:
```ts
const ERROR_MESSAGES: Record<string, string> = {
  'CUSTOM_ERROR': 'Your custom error message',
  // ...
};
```

## 🐛 Troubleshooting

### Issue: State not persisting
- Check browser storage permissions
- Verify persistence configuration in store
- Check for SSR/hydration issues

### Issue: Errors not displaying
- Ensure error boundary is wrapping components
- Check toast provider is configured
- Verify error handler is being called

### Issue: Token refresh not working
- Check refresh token validity
- Verify API endpoint configuration
- Check network requests in DevTools

## 📝 Best Practices

1. **Use store selectors for performance**:
   ```tsx
   // Good - only re-renders when user changes
   const user = useAuthStore((state) => state.user);
   
   // Avoid - re-renders on any state change
   const { user } = useAuthStore();
   ```

2. **Handle loading states**:
   ```tsx
   const { isLoading } = useAuthStore();
   
   if (isLoading) return <Spinner />;
   ```

3. **Clear errors on component unmount**:
   ```tsx
   useEffect(() => {
     return () => clearError();
   }, []);
   ```

4. **Use error boundaries strategically**:
   - Wrap feature modules
   - Provide fallback UI
   - Log errors to monitoring service

## 🚀 Next Steps

1. **Complete Migration**:
   - Update all components to use unified store
   - Remove old context providers
   - Update tests

2. **Add Monitoring**:
   - Integrate error tracking service (Sentry, etc.)
   - Add performance monitoring
   - Track user interactions

3. **Enhance Features**:
   - Add offline support
   - Implement optimistic updates
   - Add real-time sync

## 📚 Resources

- [Zustand Documentation](https://docs.pmnd.rs/zustand/getting-started/introduction)
- [React Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

---

**Status**: ✅ Implementation Complete
**Version**: 1.0.0
**Last Updated**: Current Session