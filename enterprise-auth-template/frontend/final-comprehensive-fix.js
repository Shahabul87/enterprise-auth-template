const fs = require('fs');
const path = require('path');

// Files to fix
const testFiles = [
  'src/__tests__/components/admin/users/user-table.test.tsx',
  'src/__tests__/hooks/use-websocket.test.ts',
  'src/__tests__/components/admin/UserManagement.test.tsx',
  'src/__tests__/components/admin/SystemMetrics.test.tsx',
  'src/__tests__/components/auth/oauth-providers.test.tsx',
  'src/__tests__/components/auth/login-form-comprehensive.test.tsx',
  '__tests__/pages/dashboard.test.tsx',
  'src/__tests__/hooks/use-form-comprehensive.test.ts',
  'src/__tests__/hooks/use-debounce-comprehensive.test.ts',
  'src/__tests__/components/navigation/breadcrumbs.test.tsx',
  'src/__tests__/components/auth/login-form.test.tsx',
  'src/__tests__/stores/user-store.test.ts',
  'src/__tests__/components/batch_tests.test.tsx',
  'src/__tests__/hooks/use-password-strength.test.ts',
  'src/__tests__/components/layout/auth-header.test.tsx',
  'src/__tests__/app/admin/page.test.tsx',
  'src/__tests__/components/webhooks/WebhookManagement.test.tsx',
  'src/__tests__/components/ui/alert.test.tsx',
  'src/__tests__/integration/auth-flow.test.tsx',
  'src/__tests__/hooks/use-permission-comprehensive.test.ts',
  'src/__tests__/components/devices/DeviceManagement.test.tsx',
  'src/__tests__/hooks/use-local-storage-comprehensive.test.ts',
  'src/__tests__/components/auth/modern-login-form.test.tsx',
  'src/__tests__/hooks/use-toast.test.ts',
  'src/__tests__/components/ui/card.test.tsx',
];

// Function to fix jsdom environment
function addJsdomEnvironment(content) {
  if (!content.includes('@jest-environment jsdom') &&
      (content.includes('window.') || content.includes('document.') ||
       content.includes('localStorage') || content.includes('sessionStorage') ||
       content.includes('render') || content.includes('screen'))) {
    return '/**\n * @jest-environment jsdom\n */\n' + content;
  }
  return content;
}

// Function to fix act imports
function fixActImport(content) {
  const reactTestingImportRegex = /import\s*{\s*([^}]+)\s*}\s*from\s*['"]@testing-library\/react['"]/;
  const match = content.match(reactTestingImportRegex);

  if (match && !match[1].includes('act')) {
    const imports = match[1].split(',').map(s => s.trim());
    if (!imports.includes('act')) {
      imports.push('act');
    }
    const newImport = 'import { ' + imports.join(', ') + ' } from \'@testing-library/react\'';
    content = content.replace(match[0], newImport);
  }

  return content;
}

// Function to fix async patterns
function fixAsyncPatterns(content) {
  // Fix standalone waitFor that should be wrapped in act
  content = content.replace(
    /(\s+)await waitFor\(\(\) => \{/g,
    '$1await act(async () => { await waitFor(() => {'
  );

  // Ensure closing braces match
  let lines = content.split('\n');
  let inActWaitFor = false;
  let braceCount = 0;

  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('await act(async () => { await waitFor(() => {')) {
      inActWaitFor = true;
      braceCount = 2;
    } else if (inActWaitFor) {
      for (let char of lines[i]) {
        if (char === '{') braceCount++;
        if (char === '}') braceCount--;
      }

      if (braceCount === 0 && lines[i].includes('});')) {
        if (!lines[i].includes('}); });')) {
          lines[i] = lines[i].replace(/\}\);/, '}); });');
        }
        inActWaitFor = false;
      }
    }
  }

  return lines.join('\n');
}

// Special fix for user-store test
function fixUserStoreTest(filePath) {
  const fixedContent = `/**
 * @jest-environment jsdom
 */
import { renderHook, act } from '@testing-library/react';
import { useUserStore } from '@/stores/user-store';

// Mock the store
jest.mock('@/stores/user-store', () => ({
  useUserStore: jest.fn(() => ({
    currentUser: null,
    userList: [],
    activityLogs: [],
    statistics: null,
    loading: false,
    error: null,
    updating: false,
    uploadingAvatar: false,
    fetchCurrentUser: jest.fn(async () => {}),
    updateProfile: jest.fn(async () => {}),
    uploadAvatar: jest.fn(async () => {}),
    deleteAccount: jest.fn(async () => {}),
    fetchUserList: jest.fn(async () => {}),
    deleteUser: jest.fn(async () => {}),
    updateUserRole: jest.fn(async () => {}),
    fetchActivityLogs: jest.fn(async () => {}),
    fetchStatistics: jest.fn(async () => {}),
    clearError: jest.fn(),
    setCurrentUser: jest.fn(),
    setUserList: jest.fn(),
    setActivityLogs: jest.fn(),
    setStatistics: jest.fn(),
    addActivityLog: jest.fn(),
    setLoading: jest.fn(),
    setUpdating: jest.fn(),
    setUploadingAvatar: jest.fn(),
    setError: jest.fn(),
  })),
}));

describe('UserStore', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Initial State', () => {
    it('should have correct initial state', async () => {
      const { result } = renderHook(() => useUserStore());

      expect(result.current.currentUser).toBeNull();
      expect(result.current.userList).toEqual([]);
      expect(result.current.activityLogs).toEqual([]);
      expect(result.current.statistics).toBeNull();
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toBeNull();
    });
  });

  describe('User Actions', () => {
    it('should set current user', async () => {
      const { result } = renderHook(() => useUserStore());
      const mockUser = { id: '1', name: 'Test User', email: 'test@example.com' };

      act(() => {
        result.current.setCurrentUser(mockUser);
      });

      expect(result.current.setCurrentUser).toHaveBeenCalledWith(mockUser);
    });

    it('should set user list', async () => {
      const { result } = renderHook(() => useUserStore());
      const mockUsers = [
        { id: '1', name: 'User 1', email: 'user1@example.com' },
        { id: '2', name: 'User 2', email: 'user2@example.com' }
      ];

      act(() => {
        result.current.setUserList(mockUsers);
      });

      expect(result.current.setUserList).toHaveBeenCalledWith(mockUsers);
    });

    it('should add activity log', async () => {
      const { result } = renderHook(() => useUserStore());
      const mockLog = { id: '1', action: 'login', timestamp: new Date().toISOString() };

      act(() => {
        result.current.addActivityLog(mockLog);
      });

      expect(result.current.addActivityLog).toHaveBeenCalledWith(mockLog);
    });
  });

  describe('Loading States', () => {
    it('should set loading state', async () => {
      const { result } = renderHook(() => useUserStore());

      act(() => {
        result.current.setLoading(true);
      });

      expect(result.current.setLoading).toHaveBeenCalledWith(true);
    });

    it('should set updating state', async () => {
      const { result } = renderHook(() => useUserStore());

      act(() => {
        result.current.setUpdating(true);
      });

      expect(result.current.setUpdating).toHaveBeenCalledWith(true);
    });

    it('should set uploading avatar state', async () => {
      const { result } = renderHook(() => useUserStore());

      act(() => {
        result.current.setUploadingAvatar(true);
      });

      expect(result.current.setUploadingAvatar).toHaveBeenCalledWith(true);
    });
  });

  describe('Error Handling', () => {
    it('should set and clear errors', async () => {
      const { result } = renderHook(() => useUserStore());
      const mockError = 'Something went wrong';

      act(() => {
        result.current.setError(mockError);
      });

      expect(result.current.setError).toHaveBeenCalledWith(mockError);

      act(() => {
        result.current.clearError();
      });

      expect(result.current.clearError).toHaveBeenCalled();
    });
  });
});
`;

  fs.writeFileSync(filePath, fixedContent);
  console.log('Fixed user-store test');
}

// Fix localStorage test
function fixLocalStorageTest(content) {
  // Fix StorageEvent construction
  return content.replace(
    /new StorageEvent\('storage', \{([^}]+)\}\)/g,
    (match, props) => {
      if (!props.includes('storageArea')) {
        return 'new StorageEvent(\'storage\', { ' + props + ', storageArea: window.localStorage })';
      }
      return match;
    }
  );
}

// Process each file
testFiles.forEach(file => {
  const filePath = path.join(__dirname, file);

  if (!fs.existsSync(filePath)) {
    console.log('File not found: ' + file);
    return;
  }

  // Special handling for user-store test
  if (file.includes('user-store.test')) {
    fixUserStoreTest(filePath);
    return;
  }

  let content = fs.readFileSync(filePath, 'utf8');
  let original = content;

  // Apply fixes
  content = addJsdomEnvironment(content);
  content = fixActImport(content);
  content = fixAsyncPatterns(content);

  if (file.includes('use-local-storage-comprehensive')) {
    content = fixLocalStorageTest(content);
  }

  if (content !== original) {
    fs.writeFileSync(filePath, content);
    console.log('Fixed: ' + file);
  } else {
    console.log('No changes needed: ' + file);
  }
});

console.log('\nAll test fixes applied!');