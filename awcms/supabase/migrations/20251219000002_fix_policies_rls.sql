-- Migration: Fix Policies RLS, Add Manager Permissions, and Finalize Admin Menus RLS
-- Date: 2025-12-19

-- 1. Create permission for managing policies
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'permissions' AND table_schema = 'public') THEN
        INSERT INTO public.permissions (name, description, module, resource, action) VALUES
        ('manage_abac_policies', 'Manage ABAC JSON Policies', 'system', 'system', 'edit')
        ON CONFLICT (name) DO UPDATE SET
            module = EXCLUDED.module,
            resource = EXCLUDED.resource,
            action = EXCLUDED.action;
    END IF;
END $$;

-- 2. Grant to Admins
DO $$
DECLARE
  v_role_id UUID;
  v_perm_id UUID;
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'role_permissions' AND table_schema = 'public') THEN
    -- Super Admin
    SELECT id INTO v_role_id FROM public.roles WHERE name = 'super_admin';
    SELECT id INTO v_perm_id FROM public.permissions WHERE name = 'manage_abac_policies';
    IF v_role_id IS NOT NULL AND v_perm_id IS NOT NULL THEN
      INSERT INTO public.role_permissions (role_id, permission_id) VALUES (v_role_id, v_perm_id)
      ON CONFLICT DO NOTHING;
    END IF;

    -- Admin
    SELECT id INTO v_role_id FROM public.roles WHERE name = 'admin';
    IF v_role_id IS NOT NULL AND v_perm_id IS NOT NULL THEN
      INSERT INTO public.role_permissions (role_id, permission_id) VALUES (v_role_id, v_perm_id)
      ON CONFLICT DO NOTHING;
    END IF;
  END IF;
END $$;

-- 3. Add RLS for Policies Write Operations
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'policies' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "policies_all_policy" ON public.policies';
        EXECUTE 'CREATE POLICY "policies_all_policy" ON public.policies FOR ALL
                 USING (
                   (tenant_id = current_tenant_id() AND EXISTS (
                     SELECT 1 FROM users WHERE id = auth.uid() AND role_id IN (
                       SELECT id FROM roles WHERE name IN (''admin'', ''super_admin'')
                     )
                   ))
                   OR is_platform_admin()
                 )';
    END IF;
END $$;

-- 4. Add Policy Manager to Menu
DO $$
BEGIN
     IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'admin_menus' AND table_schema = 'public') THEN
        INSERT INTO public.admin_menus (key, label, path, icon, permission, group_label, group_order, "order", is_visible) VALUES
        ('abac_policies', 'Policy Manager', 'policies', 'ShieldCheck', 'manage_abac_policies', 'SYSTEM', 100, 10, true)
        ON CONFLICT (key) DO UPDATE SET path = 'policies', permission = 'manage_abac_policies', is_visible = true;
     END IF;
END $$;

-- 5. Finalize Admin Menus Write Policy (Deferred from 2023 migration)
DO $$
BEGIN
     IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'admin_menus' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "admin_menus_write" ON public.admin_menus';
        EXECUTE 'CREATE POLICY "admin_menus_write" ON public.admin_menus FOR ALL
                 USING (
                   (EXISTS (
                     SELECT 1 FROM users WHERE id = auth.uid() AND role_id IN (
                         SELECT id FROM roles WHERE name IN (''super_admin'', ''super_super_admin'')
                     )
                   ))
                   OR is_platform_admin()
                 )';
     END IF;
END $$;
