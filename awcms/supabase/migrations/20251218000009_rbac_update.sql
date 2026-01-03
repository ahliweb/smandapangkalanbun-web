-- Migration: 20251218_rbac_update.sql
-- Description: Adds Platform Admin Role and specific permissions for multi-tenant management.

DO $$
DECLARE
    default_tenant_id UUID := '469ed0e4-8e8c-4ace-8189-71c7c170994a'; -- Primary Tenant ID
BEGIN

  -- 1. Create 'super_super_admin' role if not exists
  INSERT INTO public.roles (name, description, is_system, tenant_id)
  VALUES ('super_super_admin', 'Platform Administrator. Full system access.', TRUE, default_tenant_id)
  ON CONFLICT (name) DO NOTHING;

  -- 2. Ensure Permissions Table has correct columns (Fix for missing columns in legacy DBs)
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'permissions') THEN
      
      -- Add 'module'
      IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'permissions' AND column_name = 'module') THEN
          EXECUTE 'ALTER TABLE public.permissions ADD COLUMN module TEXT';
          EXECUTE 'UPDATE public.permissions SET module = ''system'' WHERE module IS NULL';
          EXECUTE 'ALTER TABLE public.permissions ALTER COLUMN module SET NOT NULL';
      END IF;
      
      -- Add 'resource'
      IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'permissions' AND column_name = 'resource') THEN
          EXECUTE 'ALTER TABLE public.permissions ADD COLUMN resource TEXT';
          EXECUTE 'UPDATE public.permissions SET resource = ''system'' WHERE resource IS NULL';
          EXECUTE 'ALTER TABLE public.permissions ALTER COLUMN resource SET NOT NULL';
      END IF;

      -- Add 'action'
      IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'permissions' AND column_name = 'action') THEN
          EXECUTE 'ALTER TABLE public.permissions ADD COLUMN action TEXT';
          EXECUTE 'UPDATE public.permissions SET action = ''view'' WHERE action IS NULL';
          EXECUTE 'ALTER TABLE public.permissions ALTER COLUMN action SET NOT NULL';
      END IF;

      -- 3. Insert New Permissions
      INSERT INTO public.permissions (name, description, module, resource, action)
      VALUES
        ('manage_tenants', 'Create, Edit, Delete Tenants', 'tenants', 'tenants', 'manage'),
        ('manage_platform_settings', 'Manage Global Platform Config', 'settings', 'settings', 'manage'),
        ('view_system_audit_logs', 'View All System Logs', 'audit_logs', 'audit_logs', 'view')
      ON CONFLICT (name) DO UPDATE SET
        module = EXCLUDED.module,
        resource = EXCLUDED.resource,
        action = EXCLUDED.action;

      -- 4. Assign Permissions to 'super_super_admin'
      INSERT INTO public.role_permissions (role_id, permission_id)
      SELECT r.id, p.id
      FROM public.roles r, public.permissions p
      WHERE r.name = 'super_super_admin'
        AND p.name IN ('manage_tenants', 'manage_platform_settings', 'view_system_audit_logs')
      ON CONFLICT (role_id, permission_id) DO NOTHING;
  END IF;

END $$;
