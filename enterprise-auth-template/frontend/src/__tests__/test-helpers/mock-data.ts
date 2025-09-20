/**
 * Test Helper - Mock Data Factory
 * Provides properly typed mock data for testing
 */

import type { User, Role, Permission } from '@/types/auth.types';

export function createMockPermission(overrides?: Partial<Permission>): Permission {
  return {
    id: '1',
    name: 'default.permission',
    resource: 'default',
    action: 'read',
    description: 'Default permission',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    ...overrides,
  };
}

export function createMockRole(overrides?: Partial<Role>): Role {
  return {
    id: '1',
    name: 'user',
    description: 'Default user role',
    is_active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    permissions: [],
    ...overrides,
  };
}

export function createMockUser(overrides?: Partial<User>): User {
  return {
    id: '123',
    email: 'test@example.com',
    full_name: 'Test User',
    username: 'testuser',
    is_active: true,
    is_verified: true,
    email_verified: true,
    is_superuser: false,
    two_factor_enabled: false,
    failed_login_attempts: 0,
    last_login: null,
    profile_picture: undefined,
    avatar_url: undefined,
    phone_number: undefined,
    is_phone_verified: false,
    user_metadata: {},
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    roles: [createMockRole()],
    ...overrides,
  };
}

export function createAdminUser(overrides?: Partial<User>): User {
  return createMockUser({
    id: 'admin-123',
    email: 'admin@example.com',
    full_name: 'Admin User',
    username: 'adminuser',
    is_superuser: true,
    roles: [
      createMockRole({
        id: 'admin-role',
        name: 'admin',
        description: 'Administrator role',
      }),
    ],
    ...overrides,
  });
}