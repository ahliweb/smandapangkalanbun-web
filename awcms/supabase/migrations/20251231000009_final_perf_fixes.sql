-- Migration: Final Performance Fixes & Security Hardening
-- Date: 2025-12-31
-- Description: Optimizes auth calls (using subqueries), restores strict user privacy for notifications, and adds missing Foreign Key indexes.

DO $$
BEGIN

    -- 1. FIX NOTIFICATIONS SECURITY (Privacy Regression Fix)
    -- Previous migration 08 accidentally made notifications visible to entire tenant.
    -- We must restrict to Own User OR Admin.
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "notifications_select_unified" ON public.notifications';
        EXECUTE 'DROP POLICY IF EXISTS "notifications_insert_unified" ON public.notifications';
        EXECUTE 'DROP POLICY IF EXISTS "notifications_update_unified" ON public.notifications';
        EXECUTE 'DROP POLICY IF EXISTS "notifications_delete_unified" ON public.notifications';
        
        EXECUTE 'CREATE POLICY "notifications_select_unified" ON public.notifications FOR SELECT USING (
            (user_id = (SELECT auth.uid())) 
            OR (tenant_id = public.current_tenant_id() AND public.is_admin_or_above())
            OR public.is_platform_admin()
        )';

        -- Write: System usually inserts. But if users can dismiss/delete?
        -- Assuming users can DELETE/UPDATE their own.
        EXECUTE 'CREATE POLICY "notifications_modify_unified" ON public.notifications FOR ALL USING (
             (user_id = (SELECT auth.uid())) 
            OR (tenant_id = public.current_tenant_id() AND public.is_admin_or_above())
            OR public.is_platform_admin()
        )';
    END IF;


    -- 2. OPTIMIZE USERS (Avoid auth.uid() volatile warning)
    -- Wrap auth.uid() in (SELECT ...)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "users_select_unified" ON public.users';
        
        EXECUTE 'CREATE POLICY "users_select_unified" ON public.users FOR SELECT USING (
            id = (SELECT auth.uid())
            OR (tenant_id = public.current_tenant_id() AND public.is_admin_or_above())
            OR public.is_platform_admin()
        )';
    END IF;
    
    -- 3. ADD MISSING INDEXES (Performance)
    -- sso_role_mappings
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sso_role_mappings' AND table_schema = 'public') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_sso_role_mappings_provider ON public.sso_role_mappings(provider_id)';
    END IF;
    
    -- role_policies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'role_policies' AND table_schema = 'public') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_role_policies_role ON public.role_policies(role_id)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_role_policies_policy ON public.role_policies(policy_id)';
    END IF;

    -- templates & widgets (Just to be safe, if missed)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'widgets') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_widgets_tenant_id ON public.widgets(tenant_id)';
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'template_assignments') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_template_assignments_tenant_id ON public.template_assignments(tenant_id)';
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'template_parts') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_template_parts_tenant_id ON public.template_parts(tenant_id)';
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'order_items') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_order_items_tenant_id ON public.order_items(tenant_id)';
    END IF;

END $$;
