-- Migration: User Approval Workflow
-- Date: 2025-12-19
-- Description: Adds multi-stage approval workflow for public user registration
-- Flow: Register -> Admin Approval -> Super Admin Approval -> Email Verify -> Login

-- 1. Add approval workflow columns to users table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'approval_status') THEN
            EXECUTE 'ALTER TABLE public.users ADD COLUMN approval_status TEXT DEFAULT ''approved'' CHECK (approval_status IN (''pending_admin'', ''pending_super_admin'', ''approved'', ''rejected''))';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'admin_approved_at') THEN
            EXECUTE 'ALTER TABLE public.users ADD COLUMN admin_approved_at TIMESTAMPTZ';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'admin_approved_by') THEN
            EXECUTE 'ALTER TABLE public.users ADD COLUMN admin_approved_by UUID REFERENCES public.users(id)';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'super_admin_approved_at') THEN
            EXECUTE 'ALTER TABLE public.users ADD COLUMN super_admin_approved_at TIMESTAMPTZ';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'super_admin_approved_by') THEN
            EXECUTE 'ALTER TABLE public.users ADD COLUMN super_admin_approved_by UUID REFERENCES public.users(id)';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'rejection_reason') THEN
             EXECUTE 'ALTER TABLE public.users ADD COLUMN rejection_reason TEXT';
        END IF;

        -- 2. Set existing users to 'approved' (grandfathering existing users)
        EXECUTE 'UPDATE public.users SET approval_status = ''approved'' WHERE approval_status IS NULL';
        
        -- 3. Create index for efficient filtering by approval status
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_users_approval_status ON public.users(approval_status)';
    END IF;
END $$;


-- 4. Create a 'pending' role for newly registered users
DO $$
DECLARE
    default_tenant_id UUID;
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tenants' AND table_schema = 'public') AND
       EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'roles' AND table_schema = 'public') THEN
       
        SELECT id INTO default_tenant_id FROM public.tenants WHERE slug = 'primary' LIMIT 1;
        
        IF default_tenant_id IS NOT NULL THEN
            IF NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'pending') THEN
                INSERT INTO public.roles (tenant_id, name, description, is_system)
                VALUES (default_tenant_id, 'pending', 'Pending Registration Approval', TRUE);
            END IF;
        END IF;
    END IF;
END $$;

-- 5. Update handle_new_user function to handle public registrations
-- Function replacment is usually safe IF referenced types exist.
-- Assuming tenants/roles/users exist if we are here, or distinct failure.
-- We'll wrap in check just in case.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
        EXECUTE '
            CREATE OR REPLACE FUNCTION public.handle_new_user()
            RETURNS TRIGGER AS $F$
            DECLARE
                default_role_id UUID;
                pending_role_id UUID;
                target_tenant_id UUID;
                primary_tenant_id UUID;
                is_public_registration BOOLEAN;
                initial_approval_status TEXT;
            BEGIN
                -- 1. Determine if this is a public registration
                BEGIN
                    is_public_registration := COALESCE((NEW.raw_user_meta_data->>''public_registration'')::BOOLEAN, FALSE);
                EXCEPTION WHEN OTHERS THEN
                    is_public_registration := FALSE;
                END;

                -- 2. Determine Tenant
                BEGIN
                    target_tenant_id := (NEW.raw_user_meta_data->>''tenant_id'')::UUID;
                EXCEPTION WHEN OTHERS THEN
                    target_tenant_id := NULL;
                END;

                -- If no tenant in metadata, fallback to Primary Tenant
                -- Using dynamic SQL for table lookup inside function is tricky, so standard SQL is used.
                -- This presumes tenants/roles tables exist at RUNTIME.
                SELECT id INTO primary_tenant_id FROM public.tenants WHERE slug = ''primary'' LIMIT 1;
                
                IF target_tenant_id IS NULL THEN
                    target_tenant_id := primary_tenant_id;
                END IF;

                -- 3. Determine Role and Approval Status
                IF is_public_registration THEN
                    SELECT id INTO pending_role_id 
                    FROM public.roles 
                    WHERE name = ''pending'' 
                    LIMIT 1;
                    
                    default_role_id := pending_role_id;
                    initial_approval_status := ''pending_admin'';
                ELSE
                    SELECT id INTO default_role_id 
                    FROM public.roles 
                    WHERE name = ''user'' AND tenant_id = target_tenant_id
                    LIMIT 1;
                    
                    IF default_role_id IS NULL THEN
                        SELECT id INTO default_role_id 
                        FROM public.roles 
                        WHERE name = ''subscriber''
                        LIMIT 1;
                    END IF;
                    
                    initial_approval_status := ''approved'';
                END IF;

                -- 4. Insert into public.users
                INSERT INTO public.users (
                    id, 
                    email, 
                    full_name, 
                    role_id, 
                    tenant_id, 
                    approval_status,
                    created_at, 
                    updated_at
                )
                VALUES (
                    NEW.id,
                    NEW.email,
                    COALESCE(NEW.raw_user_meta_data->>''full_name'', NEW.email),
                    default_role_id,
                    target_tenant_id,
                    initial_approval_status,
                    NOW(),
                    NOW()
                )
                ON CONFLICT (id) DO UPDATE SET
                    email = EXCLUDED.email,
                    full_name = COALESCE(EXCLUDED.full_name, public.users.full_name),
                    updated_at = NOW();
                    
                RETURN NEW;
            END;
            $F$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '''';
        ';
    END IF;
END $$;


-- 6. Add RLS policies for approval workflow
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
        -- Allow admins to view pending users in their tenant
        EXECUTE 'DROP POLICY IF EXISTS "admins_view_pending_users" ON public.users';
        EXECUTE 'CREATE POLICY "admins_view_pending_users" ON public.users 
        FOR SELECT TO authenticated
        USING (
            (
                approval_status IN (''pending_admin'', ''pending_super_admin'') 
                AND tenant_id = public.current_tenant_id()
                AND public.is_admin_or_above()
            )
            OR public.is_platform_admin()
        )';

        -- Allow admins to update approval status
        EXECUTE 'DROP POLICY IF EXISTS "admins_approve_users" ON public.users';
        EXECUTE 'CREATE POLICY "admins_approve_users" ON public.users 
        FOR UPDATE TO authenticated
        USING (
            (
                approval_status = ''pending_admin'' 
                AND tenant_id = public.current_tenant_id()
                AND public.is_admin_or_above()
            )
            OR public.is_platform_admin()
        )
        WITH CHECK (
            (tenant_id = public.current_tenant_id() AND public.is_admin_or_above())
            OR public.is_platform_admin()
        )';
        
        EXECUTE 'COMMENT ON COLUMN public.users.approval_status IS ''Multi-stage approval status: pending_admin -> pending_super_admin -> approved/rejected''';
    END IF;
END $$;
