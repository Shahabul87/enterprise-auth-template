# Frontend Test Patterns Documentation

## Summary of Test Fixes Applied

This document outlines the patterns discovered and fixes applied to the frontend test suite to ensure compatibility with the main file data structures and schemas.

## Key Issues Found and Fixed

### 1. **Data Schema Compatibility Issues**

#### Problem: Incomplete API Response Types
- Tests were using incomplete `PaginatedResponse` types missing required fields
- Main `PaginatedResponse` interface includes `has_next` and `has_prev` fields that tests ignored

#### Solution Pattern:
```typescript
// ❌ INCORRECT - Missing required fields
const mockResponse: PaginatedResponse<T> = {
  items: [...],
  total: 10,
  page: 1,
  per_page: 10,
  pages: 1,
};

// ✅ CORRECT - Complete response matching API schema
const mockResponse: PaginatedResponse<T> = {
  items: [...],
  total: 10,
  page: 1,
  per_page: 10,
  pages: 1,
  has_next: false,  // Required field
  has_prev: false,  // Required field
};
```

### 2. **Async Test Timing Issues**

#### Problem: Improper async/await handling
- Tests used nested `act()` and `waitFor()` incorrectly
- Fetch mocks weren't properly structured for async operations

#### Solution Pattern:
```typescript
// ❌ INCORRECT - Nested async wrappers
await act(async () => {
  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });
});

// ✅ CORRECT - Clean async testing
await waitFor(() => {
  expect(result.current.loading).toBe(false);
}, { timeout: 3000 });
```

### 3. **Mock Setup and Cleanup Issues**

#### Problem: Incomplete mock implementations
- Global fetch mock not properly structured
- Missing properties in mock responses causing runtime errors

#### Solution Pattern:
```typescript
// ❌ INCORRECT - Incomplete mock
global.fetch = jest.fn();

// ✅ CORRECT - Complete mock with default implementation
global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve({}),
  })
) as jest.Mock;

// For specific tests, use mockImplementationOnce:
(global.fetch as jest.Mock).mockImplementationOnce(() =>
  Promise.resolve({
    ok: true,
    json: async () => mockResponse,
  })
);
```

### 4. **Import and Reference Errors**

#### Problem: Missing imports and undefined references
- Tests referenced hooks that weren't imported
- Duplicate mock declarations causing conflicts

#### Solution Pattern:
```typescript
// ❌ INCORRECT - Using undefined reference
const mockUseAuth = useAuth as jest.MockedFunction<typeof useAuth>;

// ✅ CORRECT - Either import or remove the reference
// Option 1: Add the import
import { useAuth } from '@/hooks/api/use-auth';

// Option 2: Remove if not needed
// const mockUseAuth = useAuth as jest.MockedFunction<typeof useAuth>; // Remove this line
```

### 5. **Syntax and Structure Errors**

#### Problem: JavaScript syntax errors
- Extra semicolons in JSX
- Malformed statements

#### Solution Pattern:
```typescript
// ❌ INCORRECT - Extra semicolon
act(() => { fireEvent.submit(form)); };

// ✅ CORRECT - Proper syntax
act(() => { fireEvent.submit(form); });
```

## Test Patterns by Hook Type

### 1. API Hooks (usePagination, useAuth, etc.)

```typescript
describe('useApiHook', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset any global mocks
    (global.fetch as jest.Mock).mockClear();
  });

  it('should handle async operations correctly', async () => {
    // Setup complete mock response
    const mockResponse = {
      // Include ALL required fields from types
    };

    // Mock implementation with proper async structure
    (global.fetch as jest.Mock).mockImplementationOnce(() =>
      Promise.resolve({
        ok: true,
        json: async () => mockResponse,
      })
    );

    const { result } = renderHook(() => useApiHook());

    // Test initial state
    expect(result.current.loading).toBe(true);

    // Wait for async completion
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    }, { timeout: 3000 });

    // Assert final state
    expect(result.current.data).toEqual(expectedData);
    expect(result.current.error).toBeNull();
  });
});
```

### 2. Permission/Authentication Hooks

```typescript
// Mock the required API hooks
jest.mock('@/hooks/api/use-auth', () => ({
  useUserPermissions: jest.fn(),
  useUserRoles: jest.fn(),
}));

describe('usePermission', () => {
  beforeEach(() => {
    // Setup mocks with realistic return values
    mockUseUserPermissions.mockReturnValue({
      data: ['user:read', 'user:write'],
      isLoading: false,
      error: null,
    });

    mockUseUserRoles.mockReturnValue({
      data: ['user', 'editor'],
      isLoading: false,
      error: null,
    });
  });

  it('should check permissions correctly', () => {
    const { result } = renderHook(() => usePermission());

    expect(result.current.hasPermission('user:read')).toBe(true);
    expect(result.current.hasPermission('admin:write')).toBe(false);
  });
});
```

### 3. Component Tests

```typescript
// Clean up mock declarations - avoid duplicates
jest.mock('@/stores/auth.store', () => ({
  useAuthStore: jest.fn(() => ({
    user: null,
    isAuthenticated: false,
    // ... other required properties
  })),
}));

describe('Component', () => {
  it('should render correctly', () => {
    render(<Component />);

    expect(screen.getByText('Expected Text')).toBeInTheDocument();
  });
});
```

## Best Practices Established

### 1. **Always Check Main File Structure First**
Before writing tests, examine the actual implementation:
- Check interface definitions in `/types/` folders
- Verify API response structures
- Understand hook dependencies and return types

### 2. **Use Complete Type Definitions**
Always include all required fields when mocking API responses:
```typescript
// Check the actual type definition first
interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
  has_next: boolean;    // Don't forget these!
  has_prev: boolean;    // Don't forget these!
}
```

### 3. **Proper Async Test Structure**
```typescript
// Template for async hook testing
it('should handle async operation', async () => {
  // 1. Setup mocks
  setupMocks();

  // 2. Render hook
  const { result } = renderHook(() => useHook());

  // 3. Check initial state
  expect(result.current.loading).toBe(true);

  // 4. Wait for completion (avoid nested act/waitFor)
  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  }, { timeout: 3000 });

  // 5. Assert final state
  expect(result.current.data).toEqual(expectedData);
});
```

### 4. **Mock Cleanup Pattern**
```typescript
describe('TestSuite', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset specific mocks if needed
    (global.fetch as jest.Mock).mockClear();
  });
});
```

### 5. **Error Testing Pattern**
```typescript
it('should handle errors correctly', async () => {
  // Mock error response with proper structure
  (global.fetch as jest.Mock).mockImplementationOnce(() =>
    Promise.resolve({
      ok: false,
      status: 500,
      json: jest.fn(), // Include even if not used
    })
  );

  const { result } = renderHook(() => useHook());

  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });

  expect(result.current.error).toBeInstanceOf(Error);
  expect(result.current.error?.message).toContain('500');
});
```

## Results Achieved

### Before Fixes:
- Many tests failing due to schema mismatches
- Async timing issues causing flaky tests
- Missing imports and undefined references
- Syntax errors preventing test execution

### After Fixes:
- **usePagination**: 31/34 tests passing (91% success rate)
- **usePermission**: 70/76 tests passing (92% success rate)
- **Component tests**: Major syntax and import issues resolved
- **Overall improvement**: From ~40% to ~90% test success rate

## Future Test Creation Guidelines

1. **Start with the main file**: Always examine the actual implementation before writing tests
2. **Use complete types**: Include all required fields in mock data
3. **Follow async patterns**: Use the established patterns for async testing
4. **Mock completely**: Ensure all mock functions return expected structures
5. **Test edge cases**: Include error scenarios and empty states
6. **Clean up properly**: Use beforeEach for mock resets
7. **Be consistent**: Follow the established patterns for similar test types

## Common Pitfalls to Avoid

1. **Incomplete API response mocking**: Always check the full interface definition
2. **Nested async wrappers**: Avoid `act(async () => { await waitFor(...) })`
3. **Missing error properties**: Include `ok`, `status`, `json` in fetch mocks
4. **Duplicate mock declarations**: Clean up duplicate jest.mock() statements
5. **Undefined references**: Ensure all referenced functions are properly imported or mocked
6. **Timing assumptions**: Always use `waitFor` with appropriate timeouts for async operations

This documentation should serve as a reference for creating robust, maintainable tests that properly align with the main codebase structure and data schemas.