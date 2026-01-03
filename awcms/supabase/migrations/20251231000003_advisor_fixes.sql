-- Migration: Supabase Advisor Fixes (Security & Performance)
-- Date: 2025-12-31
-- Description: Hardens SECURITY DEFINER functions and indexes foreign keys.

DO $$
BEGIN
    -- 1. Security: Set search_path for SECURITY DEFINER functions
    -- Only alter if function exists
    
    -- get_tenant_by_domain
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_tenant_by_domain') THEN
        ALTER FUNCTION public.get_tenant_by_domain(text) SET search_path = public;
    END IF;

    -- check_tenant_limit
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'check_tenant_limit') THEN
        ALTER FUNCTION public.check_tenant_limit(uuid, text, bigint) SET search_path = public;
    END IF;

    -- is_platform_admin
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_platform_admin') THEN
        ALTER FUNCTION public.is_platform_admin() SET search_path = public;
    END IF;

    -- current_tenant_id
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'current_tenant_id') THEN
        ALTER FUNCTION public.current_tenant_id() SET search_path = public;
    END IF;

    -- set_tenant_id
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'set_tenant_id') THEN
        ALTER FUNCTION public.set_tenant_id() SET search_path = public;
    END IF;

    -- create_tenant_with_defaults
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'create_tenant_with_defaults') THEN
        ALTER FUNCTION public.create_tenant_with_defaults(text, text, text, text) SET search_path = public;
    END IF;


    -- 2. Performance: Index Foreign Keys

    -- account_requests
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'account_requests' AND table_schema = 'public') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_account_requests_admin_approved_by ON public.account_requests(admin_approved_by)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_account_requests_super_admin_approved_by ON public.account_requests(super_admin_approved_by)';
    END IF;

    -- template_assignments
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'template_assignments' AND table_schema = 'public') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_template_assignments_tenant_id ON public.template_assignments(tenant_id)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_template_assignments_template_id ON public.template_assignments(template_id)';
    END IF;

    -- articles & pages (workflow)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'articles' AND table_schema = 'public') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_articles_current_assignee_id ON public.articles(current_assignee_id)';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pages' AND table_schema = 'public') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_pages_current_assignee_id ON public.pages(current_assignee_id)';
    END IF;

    -- testimonies
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'testimonies' AND table_schema = 'public') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_testimonies_category_id ON public.testimonies(category_id)';
    END IF;

    -- users (approval workflow)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_users_admin_approved_by ON public.users(admin_approved_by)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_users_super_admin_approved_by ON public.users(super_admin_approved_by)';
    END IF;

END $$;
