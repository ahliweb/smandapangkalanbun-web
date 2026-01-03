-- Migration: Security Hardening for Tags, Notifications, SSO
-- Description: Add tenant_id isolation and fix RLS policies for critical tables.

-- ==========================================
-- 1. HARDEN TAGS (Cleanup Legacy Policies)
-- ==========================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tags' AND table_schema = 'public') THEN
        -- Existing 'Tenant Read/Write Access' are good. Drop the loose ones.
        EXECUTE 'DROP POLICY IF EXISTS "tags_select_public" ON public.tags';
        EXECUTE 'DROP POLICY IF EXISTS "Allow delete tags" ON public.tags';
        EXECUTE 'DROP POLICY IF EXISTS "Allow insert tags" ON public.tags';
        EXECUTE 'DROP POLICY IF EXISTS "Allow update tags" ON public.tags';
    END IF;
END $$;


-- ==========================================
-- 2. HARDEN NOTIFICATIONS (Add Tenant Isolation)
-- ==========================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications' AND table_schema = 'public') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'notifications' AND column_name = 'tenant_id') THEN
            EXECUTE 'ALTER TABLE public.notifications ADD COLUMN tenant_id UUID REFERENCES public.tenants(id)';
            EXECUTE 'CREATE INDEX idx_notifications_tenant_id ON public.notifications(tenant_id)';

            -- Backfill tenant_id from users (best effort)
            EXECUTE 'UPDATE public.notifications n
                     SET tenant_id = u.tenant_id
                     FROM public.users u
                     WHERE n.user_id = u.id
                     AND n.tenant_id IS NULL';
        END IF;

        -- Enable RLS
        EXECUTE 'ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY';

        -- Drop legacy policies
        EXECUTE 'DROP POLICY IF EXISTS "notifications_select_policy" ON public.notifications';
        EXECUTE 'DROP POLICY IF EXISTS "notifications_insert_policy" ON public.notifications';
        EXECUTE 'DROP POLICY IF EXISTS "notifications_update_policy" ON public.notifications';
        EXECUTE 'DROP POLICY IF EXISTS "notifications_delete_policy" ON public.notifications';

        -- Create Strict Policies
        -- READ: Users see their own. Tenant Admins see their Tenant''s. Global Admins see ALL.
        EXECUTE 'CREATE POLICY "notifications_read_policy" ON public.notifications
                 FOR SELECT
                 USING (
                   (user_id = auth.uid()) OR
                   (tenant_id = current_tenant_id() AND is_admin_or_above()) OR
                   is_platform_admin()
                 )';

        -- WRITE (System/Insert): Usually handled by system functions, but allow admins to create announcements
        EXECUTE 'CREATE POLICY "notifications_write_policy" ON public.notifications
                 FOR ALL
                 USING (
                   (tenant_id = current_tenant_id() AND is_admin_or_above()) OR
                   is_platform_admin()
                 )';
    END IF;
END $$;


-- ==========================================
-- 3. HARDEN SSO PROVIDERS (Critical Security)
-- ==========================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sso_providers' AND table_schema = 'public') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sso_providers' AND column_name = 'tenant_id') THEN
             EXECUTE 'ALTER TABLE public.sso_providers ADD COLUMN tenant_id UUID REFERENCES public.tenants(id)';
             EXECUTE 'CREATE INDEX idx_sso_providers_tenant_id ON public.sso_providers(tenant_id)';
        END IF;

        -- Enable RLS
        EXECUTE 'ALTER TABLE public.sso_providers ENABLE ROW LEVEL SECURITY';

        -- Drop legacy policies
        EXECUTE 'DROP POLICY IF EXISTS "sso_providers_select" ON public.sso_providers';
        EXECUTE 'DROP POLICY IF EXISTS "sso_providers_modify" ON public.sso_providers';
        EXECUTE 'DROP POLICY IF EXISTS "sso_providers_update" ON public.sso_providers';
        EXECUTE 'DROP POLICY IF EXISTS "sso_providers_delete" ON public.sso_providers';

        -- Strict Policies
        EXECUTE 'DROP POLICY IF EXISTS "sso_providers_isolation_policy" ON public.sso_providers';
        EXECUTE 'CREATE POLICY "sso_providers_isolation_policy" ON public.sso_providers
                 FOR ALL
                 USING (
                   (tenant_id = current_tenant_id() AND is_admin_or_above()) OR
                   is_platform_admin()
                 )';
    END IF;
END $$;

-- 4. HARDEN SSO ROLE MAPPINGS
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sso_role_mappings' AND table_schema = 'public') THEN
         EXECUTE 'ALTER TABLE public.sso_role_mappings ENABLE ROW LEVEL SECURITY';
         EXECUTE 'DROP POLICY IF EXISTS "sso_mappings_isolation_policy" ON public.sso_role_mappings';
         
         -- Need to handle the cast carefully in dynamic SQL if needed, but standard SQL string is fine here.
         -- Note: provider_id might be text in some schemas, UUID in others. Casting to UUID is safe if it's UUID string.
         EXECUTE 'CREATE POLICY "sso_mappings_isolation_policy" ON public.sso_role_mappings
                 FOR ALL
                 USING (
                   EXISTS (
                     SELECT 1 FROM public.sso_providers p 
                     WHERE p.id = sso_role_mappings.provider_id::uuid
                     AND (
                       (p.tenant_id = current_tenant_id()) OR 
                       is_platform_admin()
                     )
                   )
                 )';
    END IF;
END $$;
