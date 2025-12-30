-- Migration: 20251231000030_fix_function_search_path
-- Description: Fixes Security Advisor warnings by setting search_path on SECURITY DEFINER functions.
-- This prevents potential search path hijacking attacks.

-- Fix is_super_admin function
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
DECLARE
  _role_name TEXT;
BEGIN
  _role_name := (auth.jwt() ->> 'role')::TEXT;
  IF _role_name IN ('super_admin', 'owner') THEN
    RETURN TRUE;
  END IF;
  RETURN EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.name IN ('super_admin', 'owner')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- Fix is_admin_or_above function
CREATE OR REPLACE FUNCTION public.is_admin_or_above()
RETURNS BOOLEAN AS $$
DECLARE
  _role_name TEXT;
BEGIN
  _role_name := (auth.jwt() ->> 'role')::TEXT;
  IF _role_name IN ('admin', 'super_admin', 'owner') THEN
    RETURN TRUE;
  END IF;
  RETURN EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.name IN ('admin', 'super_admin', 'owner')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- Also fix other common helper functions if they exist

-- Fix is_platform_admin if it exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_platform_admin') THEN
    EXECUTE $func$
      CREATE OR REPLACE FUNCTION public.is_platform_admin()
      RETURNS BOOLEAN AS $inner$
      BEGIN
        RETURN public.is_super_admin();
      END;
      $inner$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';
    $func$;
  END IF;
END $$;

-- Fix current_tenant_id if it exists and has the issue
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'current_tenant_id' AND pronamespace = 'public'::regnamespace) THEN
    -- Check if it's a SECURITY DEFINER function
    IF EXISTS (
      SELECT 1 FROM pg_proc 
      WHERE proname = 'current_tenant_id' 
      AND pronamespace = 'public'::regnamespace 
      AND prosecdef = true
    ) THEN
      -- Recreate with search_path
      EXECUTE $func$
        CREATE OR REPLACE FUNCTION public.current_tenant_id()
        RETURNS UUID AS $inner$
        BEGIN
          RETURN COALESCE(
            (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid,
            (SELECT tenant_id FROM public.users WHERE id = auth.uid())
          );
        END;
        $inner$ LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = '';
      $func$;
    END IF;
  END IF;
END $$;
