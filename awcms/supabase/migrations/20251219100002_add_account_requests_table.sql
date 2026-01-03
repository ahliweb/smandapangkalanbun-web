-- Migration: Account Requests Staging Table (Option B)
-- Date: 2025-12-19
-- Description: Creates a staging table for public account applications.
-- This supports the "Verify Email AFTER Approval" workflow by delaying Auth User creation.

-- 1. Create account_requests table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tenants' AND table_schema = 'public') 
       AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
       
        -- DDL inside dynamic SQL to prevent parser errors if referenced tables missing
        EXECUTE '
        CREATE TABLE IF NOT EXISTS public.account_requests (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            email TEXT NOT NULL,
            full_name TEXT NOT NULL,
            tenant_id UUID REFERENCES public.tenants(id),
            status TEXT DEFAULT ''pending_admin'' 
                CHECK (status IN (''pending_admin'', ''pending_super_admin'', ''approved'', ''rejected'', ''completed'')),
            admin_approved_at TIMESTAMPTZ,
            admin_approved_by UUID REFERENCES public.users(id),
            super_admin_approved_at TIMESTAMPTZ,
            super_admin_approved_by UUID REFERENCES public.users(id),
            rejection_reason TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW()
        )';

        -- 2. Indexes
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_account_requests_status ON public.account_requests(status)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_account_requests_tenant ON public.account_requests(tenant_id)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_account_requests_email ON public.account_requests(email)';

        -- 3. RLS Policies
        EXECUTE 'ALTER TABLE public.account_requests ENABLE ROW LEVEL SECURITY';

        -- Policy: Platform Admins can view/manage ALL requests
        EXECUTE 'DROP POLICY IF EXISTS "Platform Admins manage all requests" ON public.account_requests';
        EXECUTE 'CREATE POLICY "Platform Admins manage all requests"
        ON public.account_requests
        FOR ALL TO authenticated
        USING (public.is_platform_admin())
        WITH CHECK (public.is_platform_admin())';

        -- Policy: Tenant Admins can view/update requests for their tenant
        EXECUTE 'DROP POLICY IF EXISTS "Tenant Admins manage own requests" ON public.account_requests';
        EXECUTE 'CREATE POLICY "Tenant Admins manage own requests"
        ON public.account_requests
        FOR ALL TO authenticated
        USING (
            tenant_id = public.current_tenant_id() 
            AND public.is_admin_or_above()
        )
        WITH CHECK (
            tenant_id = public.current_tenant_id() 
            AND public.is_admin_or_above()
        )';

        -- 4. Audit Logging Trigger (Reuse existing)
        EXECUTE 'DROP TRIGGER IF EXISTS audit_account_requests ON public.account_requests';
        EXECUTE 'CREATE TRIGGER audit_account_requests
        AFTER INSERT OR UPDATE OR DELETE ON public.account_requests
        FOR EACH ROW EXECUTE FUNCTION public.log_audit_event()';
    END IF;
END $$;
