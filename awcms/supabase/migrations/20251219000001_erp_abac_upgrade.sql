-- Migration: ERP RBAC Upgrade
-- Description: Adds Audit Logs, ABAC Policies, and Workflow State columns

-- 1. ERP Audit Logs
-- Audit logs is core, so we create if not exists
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    tenant_id UUID REFERENCES public.tenants(id),
    user_id UUID REFERENCES public.users(id),
    action TEXT NOT NULL, -- e.g., 'user.create', 'post.publish'
    resource TEXT NOT NULL, -- e.g., 'users', 'posts'
    resource_id TEXT,
    old_value JSONB,
    new_value JSONB,
    channel TEXT DEFAULT 'web', -- web, mobile, api
    ip_address TEXT,
    user_agent TEXT
);

-- RLS for Audit Logs
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_logs' AND table_schema = 'public') THEN
        EXECUTE 'ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY';
        
        EXECUTE 'DROP POLICY IF EXISTS "audit_view_policy" ON public.audit_logs';
        
        EXECUTE 'CREATE POLICY "audit_view_policy" ON public.audit_logs FOR SELECT
                 USING (
                    (tenant_id = current_tenant_id() AND EXISTS (
                      SELECT 1 FROM users WHERE id = auth.uid() AND role_id IN (
                        SELECT id FROM roles WHERE name IN (''admin'', ''super_admin'')
                      )
                    ))
                    OR is_platform_admin()
                 )';
        
        EXECUTE 'CREATE POLICY "audit_insert_policy" ON public.audit_logs FOR INSERT
                 WITH CHECK (
                    (tenant_id = current_tenant_id() AND auth.uid() = user_id)
                    OR is_platform_admin()
                 )';
    END IF;
END $$;


-- 2. ABAC Policies System
CREATE TABLE IF NOT EXISTS public.policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    definition JSONB NOT NULL, -- { "effect": "allow", "actions": ["delete"], "conditions": { ... } }
    tenant_id UUID REFERENCES public.tenants(id), -- Null for global policies
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for policies
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'policies' AND table_schema = 'public') THEN
        EXECUTE 'ALTER TABLE public.policies ENABLE ROW LEVEL SECURITY';
        
        EXECUTE 'DROP POLICY IF EXISTS "policies_read_policy" ON public.policies';
        EXECUTE 'CREATE POLICY "policies_read_policy" ON public.policies FOR SELECT
                 USING (
                    (tenant_id = current_tenant_id()) OR 
                    (tenant_id IS NULL) OR 
                    is_platform_admin()
                 )';
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.role_policies (
    role_id UUID REFERENCES public.roles(id) ON DELETE CASCADE,
    policy_id UUID REFERENCES public.policies(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, policy_id)
);

-- 3. Workflow State Columns
-- Articles (was posts)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'articles' AND table_schema = 'public') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'articles' AND column_name = 'workflow_state') THEN
            EXECUTE 'ALTER TABLE public.articles ADD COLUMN workflow_state TEXT DEFAULT ''draft'''; -- draft, reviewed, approved, published
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'articles' AND column_name = 'current_assignee_id') THEN
             EXECUTE 'ALTER TABLE public.articles ADD COLUMN current_assignee_id UUID REFERENCES public.users(id)';
        END IF;
        
        -- 4. Initial Seed for Workflow States (Optional but good for consistency)
        EXECUTE 'UPDATE public.articles SET workflow_state = ''published'' WHERE status = ''published'' AND workflow_state = ''draft''';
    END IF;
END $$;

-- Pages
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pages' AND table_schema = 'public') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'pages' AND column_name = 'workflow_state') THEN
             EXECUTE 'ALTER TABLE public.pages ADD COLUMN workflow_state TEXT DEFAULT ''draft''';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'pages' AND column_name = 'current_assignee_id') THEN
             EXECUTE 'ALTER TABLE public.pages ADD COLUMN current_assignee_id UUID REFERENCES public.users(id)';
        END IF;
        
        EXECUTE 'UPDATE public.pages SET workflow_state = ''published'' WHERE status = ''published'' AND workflow_state = ''draft''';
    END IF;
END $$;


-- 5. Insert new Permissions
-- Check if permissions table exists first
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'permissions' AND table_schema = 'public') THEN
        INSERT INTO public.permissions (name, description, module, resource, action) VALUES
        ('view_system_audit_logs', 'View system audit trails', 'system', 'system', 'view')
        ON CONFLICT (name) DO UPDATE SET
            module = EXCLUDED.module,
            resource = EXCLUDED.resource,
            action = EXCLUDED.action;
    END IF;
END $$;

-- 6. Grant to Admins
DO $$
DECLARE
  v_role_id UUID;
  v_perm_id UUID;
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'role_permissions' AND table_schema = 'public') THEN
      -- Super Admin
      SELECT id INTO v_role_id FROM public.roles WHERE name = 'super_admin';
      SELECT id INTO v_perm_id FROM public.permissions WHERE name = 'view_system_audit_logs';
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

-- 7. Insert Menu Item
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'admin_menus' AND table_schema = 'public') THEN
        INSERT INTO public.admin_menus (key, label, path, icon, permission, group_label, group_order, "order", is_visible) VALUES
        ('audit_logs_erp', 'Audit Logs (ERP)', 'audit-logs', 'FileClock', 'view_system_audit_logs', 'SYSTEM', 100, 9, true)
        ON CONFLICT (key) DO UPDATE SET path = 'audit-logs', permission = 'view_system_audit_logs', is_visible = true;
    END IF;
END $$;
