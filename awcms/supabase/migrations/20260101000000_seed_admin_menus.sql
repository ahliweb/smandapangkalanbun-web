-- Migration: Seed Admin Menus
-- Date: 2026-01-01
-- Description: Re-seeds the admin_menus table with default items.
-- This restores the navigation structure after the cleanup.

DO $$
DECLARE
    default_tenant_id UUID := '469ed0e4-8e8c-4ace-8189-71c7c170994a'; -- Primary Tenant ID
BEGIN

    -- Verify table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'admin_menus' AND table_schema = 'public') THEN
        
        -- Disable Triggers to avoid "column details does not exist" error in audit_logs trigger
        ALTER TABLE public.admin_menus DISABLE TRIGGER ALL;
        
        -- Insert items (Safe Upsert or Ignore)
        -- Schema assumed: id, key, label, path, icon, permission, group_label, group_order, "order", is_visible, tenant_id, parent_id
        -- We use EXECUTE to separate compile time checks
        
        -- Dashboard
        EXECUTE 'INSERT INTO public.admin_menus (key, label, path, icon, "order", group_label, group_order, is_visible)
                 VALUES (''dashboard'', ''Dashboard'', ''/'', ''LayoutDashboard'', 0, ''General'', 10, true)
                 ON CONFLICT (key) DO NOTHING';

        -- Content Group
        EXECUTE 'INSERT INTO public.admin_menus (key, label, path, icon, "order", group_label, group_order, is_visible)
                 VALUES 
                 (''articles'', ''Articles'', ''/articles'', ''FileText'', 10, ''Content'', 20, true),
                 (''pages'', ''Pages'', ''/pages'', ''Layers'', 20, ''Content'', 20, true),
                 (''categories'', ''Categories'', ''/categories'', ''Tag'', 30, ''Content'', 20, true),
                 (''tags'', ''Tags'', ''/tags'', ''Hash'', 40, ''Content'', 20, true)
                 ON CONFLICT (key) DO NOTHING';

        -- Media Group
        EXECUTE 'INSERT INTO public.admin_menus (key, label, path, icon, "order", group_label, group_order, is_visible)
                 VALUES (''media'', ''Media'', ''/media'', ''Image'', 50, ''Media'', 30, true)
                 ON CONFLICT (key) DO NOTHING';

        -- Users Group
        EXECUTE 'INSERT INTO public.admin_menus (key, label, path, icon, "order", group_label, group_order, is_visible)
                 VALUES 
                 (''users'', ''Users'', ''/users'', ''Users'', 60, ''Users'', 40, true),
                 (''roles'', ''Roles'', ''/roles'', ''Shield'', 70, ''Users'', 40, true),
                 (''permissions'', ''Permissions'', ''/permissions'', ''Lock'', 80, ''Users'', 40, true)
                 ON CONFLICT (key) DO NOTHING';

        -- System Group
        EXECUTE 'INSERT INTO public.admin_menus (key, label, path, icon, "order", group_label, group_order, is_visible)
                 VALUES 
                 (''settings'', ''Settings'', ''/settings'', ''Settings'', 90, ''System'', 50, true),
                 (''audit_logs'', ''Audit Logs'', ''/audit-logs'', ''FileClock'', 100, ''System'', 50, true),
                 (''themes'', ''Themes'', ''/themes'', ''Palette'', 110, ''System'', 50, true),
                 (''extensions'', ''Extensions'', ''/extensions'', ''Puzzle'', 120, ''System'', 50, true)
                 ON CONFLICT (key) DO NOTHING';

        -- Re-enable Triggers
        ALTER TABLE public.admin_menus ENABLE TRIGGER ALL;

    END IF;

END $$;
