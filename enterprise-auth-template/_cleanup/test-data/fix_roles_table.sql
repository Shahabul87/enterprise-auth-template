-- Add missing columns to roles table
ALTER TABLE roles ADD COLUMN IF NOT EXISTS display_name VARCHAR(100);
ALTER TABLE roles ADD COLUMN IF NOT EXISTS is_system BOOLEAN DEFAULT FALSE;
ALTER TABLE roles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE roles ADD COLUMN IF NOT EXISTS priority INTEGER DEFAULT 0;

-- Update display_name for existing roles
UPDATE roles SET display_name = INITCAP(name) WHERE display_name IS NULL;

-- Insert default roles if they don't exist
INSERT INTO roles (id, name, display_name, description, is_system, is_active, priority)
VALUES
  (gen_random_uuid(), 'user', 'User', 'Standard user role', true, true, 0),
  (gen_random_uuid(), 'admin', 'Admin', 'Administrator role', true, true, 100),
  (gen_random_uuid(), 'superuser', 'Super User', 'Super administrator role', true, true, 200)
ON CONFLICT (name) DO UPDATE
SET display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    is_system = EXCLUDED.is_system,
    is_active = EXCLUDED.is_active,
    priority = EXCLUDED.priority;