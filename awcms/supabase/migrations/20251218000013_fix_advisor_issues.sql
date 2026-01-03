-- 1. Fix Function Search Path Mutable (Security Advisor)
-- Set strict search_path for security-critical functions to prevent schema hijacking

DO $$
DECLARE
    func_name text;
    funcs text[] := ARRAY[
        'log_audit_event',
        'is_platform_admin',
        'current_tenant_id',
        'verify_isolation_debug',
        'get_tenant_by_domain',
        'check_tenant_limit',
        'enforce_user_limit',
        'enforce_storage_limit',
        'set_tenant_id',
        'is_super_admin',
        'is_admin_or_above'
    ];
BEGIN
    FOREACH func_name IN ARRAY funcs LOOP
        IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = func_name) THEN
            EXECUTE format('ALTER FUNCTION public.%I SET search_path = public, extensions', func_name);
        END IF;
    END LOOP;
END $$;

-- 2. Consolidate RLS Policies (Performance & Security)

-- A. Video Gallery
-- Remove overly permissive legacy policies that bypass tenant isolation
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'video_gallery' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "video_gallery_select_policy" ON video_gallery';
        EXECUTE 'DROP POLICY IF EXISTS "video_gallery_insert_policy" ON video_gallery';
        EXECUTE 'DROP POLICY IF EXISTS "video_gallery_update_policy" ON video_gallery';
        EXECUTE 'DROP POLICY IF EXISTS "video_gallery_delete_policy" ON video_gallery';
    END IF;
END $$;

-- Ensure Tenant Isolation policies exist (re-asserting them or ensuring no duplicates)
-- The existing "Tenant Read Access" and "Tenant Write Access" usually cover this.
-- we don't need to re-create them if they exist and are correct (based on audit they appeared to be correct but shadowed by the permissive ones).

-- B. Templates
-- Remove redundant policies
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'templates' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "Authenticated users can view all templates" ON templates'; 
        EXECUTE 'DROP POLICY IF EXISTS "templates_select_policy" ON templates'; -- Redundant if "Tenant Read Access" exists
        
        -- 3. Optimize RLS performance (Auth calls)
        -- Wrap auth calls in (SELECT ...) to prevent row-by-row re-evaluation where possible.
        -- Note: Changing existing policies requires DROP + CREATE.
        -- For "Tenant Read Access" on templates:
        EXECUTE 'DROP POLICY IF EXISTS "Tenant Read Access" ON templates';
        EXECUTE 'CREATE POLICY "Tenant Read Access" ON templates
                    FOR SELECT TO authenticated
                    USING (
                      (tenant_id = (SELECT public.current_tenant_id())) 
                      OR (tenant_id IS NULL) 
                      OR (SELECT public.is_platform_admin())
                    )';

        -- Optimize "Admins users can manage templates" -> "Tenant Write Access"
        -- We will rely on the standard "Tenant Write Access" for administrative tasks.
        EXECUTE 'DROP POLICY IF EXISTS "Admins users can manage templates" ON templates';
        EXECUTE 'DROP POLICY IF EXISTS "Tenant Write Access" ON templates';

        EXECUTE 'CREATE POLICY "Tenant Write Access" ON templates
                    FOR ALL TO authenticated
                    USING (
                      (
                        (tenant_id = (SELECT public.current_tenant_id())) 
                        AND (SELECT public.is_admin_or_above())
                      ) 
                      OR (SELECT public.is_platform_admin())
                    )';
    END IF;
END $$;
