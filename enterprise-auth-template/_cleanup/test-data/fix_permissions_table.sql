-- Add missing columns to permissions table
ALTER TABLE permissions ADD COLUMN IF NOT EXISTS name VARCHAR(100);
ALTER TABLE permissions ADD COLUMN IF NOT EXISTS display_name VARCHAR(100);
ALTER TABLE permissions ADD COLUMN IF NOT EXISTS scope VARCHAR(50) DEFAULT 'global';
ALTER TABLE permissions ADD COLUMN IF NOT EXISTS is_system BOOLEAN DEFAULT FALSE;
ALTER TABLE permissions ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Update name from resource and action if not set
UPDATE permissions
SET name = CONCAT(resource, ':', action)
WHERE name IS NULL;

-- Update display_name if not set
UPDATE permissions
SET display_name = INITCAP(REPLACE(CONCAT(resource, ' ', action), '_', ' '))
WHERE display_name IS NULL;

-- Insert basic permissions if they don't exist
INSERT INTO permissions (id, name, display_name, description, resource, action, scope, is_system, is_active)
VALUES
  (gen_random_uuid(), 'users:read', 'Read Users', 'View user information', 'users', 'read', 'global', true, true),
  (gen_random_uuid(), 'users:write', 'Write Users', 'Create and update users', 'users', 'write', 'global', true, true),
  (gen_random_uuid(), 'users:delete', 'Delete Users', 'Delete users', 'users', 'delete', 'global', true, true),
  (gen_random_uuid(), 'profile:read', 'Read Profile', 'View own profile', 'profile', 'read', 'own', true, true),
  (gen_random_uuid(), 'profile:write', 'Write Profile', 'Update own profile', 'profile', 'write', 'own', true, true)
ON CONFLICT (resource, action) DO UPDATE
SET name = EXCLUDED.name,
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    scope = EXCLUDED.scope,
    is_system = EXCLUDED.is_system,
    is_active = EXCLUDED.is_active;