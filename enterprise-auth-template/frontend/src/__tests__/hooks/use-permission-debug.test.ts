
import { renderHook } from '@testing-library/react';
import { usePermission } from '../../hooks/use-permission';
import { useUserPermissions, useUserRoles } from '@/hooks/api/use-auth';
import React from 'react';


jest.mock('@/hooks/api/use-auth', () => ({
  useUserPermissions: jest.fn(),
  useUserRoles: jest.fn(),
}));
/**
 * Debug test for usePermission hook
 */


// Mock the API hooks

const mockUseUserPermissions = useUserPermissions as jest.MockedFunction<typeof useUserPermissions>;
const mockUseUserRoles = useUserRoles as jest.MockedFunction<typeof useUserRoles>;
describe('usePermission Debug', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockUseUserPermissions.mockReturnValue({
      data: ['user:read', 'user:write', 'post:read', 'admin:read'],
      isLoading: false,
      error: null,
    } as jest.Mocked<any>);
    mockUseUserRoles.mockReturnValue({
      data: ['user', 'editor'],
      isLoading: false,
      error: null,
    } as jest.Mocked<any>);
  });
  it('should debug canPerform logic', () => {
    const { result } = renderHook(() => usePermission());
    console.log('Permissions:', result.current.permissions);
    console.log('Roles:', result.current.roles);
    // Test hasPermission directly
    console.log('hasPermission(admin:write):', result.current.hasPermission('admin:write'));
    console.log('hasPermission(admin:read):', result.current.hasPermission('admin:read'));
    // Test hasPermissions directly
    console.log('hasPermissions([admin:write]):', result.current.hasPermissions(['admin:write']));
    // Test canPerform
    const canPerformResult = result.current.canPerform({
      permissions: ['admin:write'],
      requireAll: true
    });
    console.log('canPerform result:', canPerformResult);
    expect(canPerformResult).toBe(false);
  });
});