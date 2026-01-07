-- Migration: Security Advisor Remediation
-- Date: 2026-01-07
-- Description: Fixes 4 security warnings related to overly permissive RLS policies.
-- Safety: Non-destructive. Tightens access only. No data loss.
-- Rollback: See rollback section at the bottom of this file.

-- ============================================================================
-- FIX 1: sso_audit_logs - Revoke public INSERT, System-only write
-- ============================================================================
-- Drop the permissive policy that allows anyone to insert
DROP POLICY IF EXISTS "System Insert SSO Logs" ON public.sso_audit_logs;

-- Revoke INSERT grants from roles that should not write directly
REVOKE INSERT ON public.sso_audit_logs FROM public;
REVOKE INSERT ON public.sso_audit_logs FROM anon;
REVOKE INSERT ON public.sso_audit_logs FROM authenticated;

-- Note: service_role bypasses RLS by default, so Edge Functions can still write.
-- If you need a policy for service_role explicitly (not required in Supabase):
-- CREATE POLICY "service_role_insert_sso_logs" ON public.sso_audit_logs
--   FOR INSERT TO service_role WITH CHECK (true);

-- ============================================================================
-- FIX 2: two_factor_audit_logs - Revoke public INSERT, System-only write
-- ============================================================================
-- Drop the permissive policy that allows anyone to insert
DROP POLICY IF EXISTS "System can insert 2fa logs" ON public.two_factor_audit_logs;

-- Revoke INSERT grants from roles that should not write directly
REVOKE INSERT ON public.two_factor_audit_logs FROM public;
REVOKE INSERT ON public.two_factor_audit_logs FROM anon;
REVOKE INSERT ON public.two_factor_audit_logs FROM authenticated;

-- Note: service_role bypasses RLS by default, so Edge Functions can still write.

-- ============================================================================
-- FIX 3: backup_logs - Enforce tenant_id = current_tenant_id() on INSERT
-- ============================================================================
-- Drop the old permissive policy
DROP POLICY IF EXISTS "backup_logs_insert_auth" ON public.backup_logs;

-- Create a new, tenant-scoped INSERT policy
CREATE POLICY "backup_logs_insert_tenant_scoped" ON public.backup_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (
    (tenant_id = current_tenant_id()) OR is_platform_admin()
  );

-- ============================================================================
-- FIX 4: contact_messages - Enforce tenant_id IS NOT NULL on public INSERT
-- ============================================================================
-- Drop the old permissive policy
DROP POLICY IF EXISTS "contact_messages_insert_public" ON public.contact_messages;

-- Create a new policy requiring tenant_id to be present
-- This allows public contact form submissions but requires tenant context
CREATE POLICY "contact_messages_insert_with_tenant" ON public.contact_messages
  FOR INSERT
  TO public
  WITH CHECK (
    tenant_id IS NOT NULL
  );

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================
-- To revert these changes (NOT RECOMMENDED unless there's an issue):
--
-- -- Restore sso_audit_logs
-- GRANT INSERT ON public.sso_audit_logs TO public, anon, authenticated;
-- CREATE POLICY "System Insert SSO Logs" ON public.sso_audit_logs
--   FOR INSERT TO public WITH CHECK (true);
--
-- -- Restore two_factor_audit_logs
-- GRANT INSERT ON public.two_factor_audit_logs TO public, anon, authenticated;
-- CREATE POLICY "System can insert 2fa logs" ON public.two_factor_audit_logs
--   FOR INSERT TO public WITH CHECK (true);
--
-- -- Restore backup_logs
-- DROP POLICY IF EXISTS "backup_logs_insert_tenant_scoped" ON public.backup_logs;
-- CREATE POLICY "backup_logs_insert_auth" ON public.backup_logs
--   FOR INSERT TO authenticated WITH CHECK (true);
--
-- -- Restore contact_messages
-- DROP POLICY IF EXISTS "contact_messages_insert_with_tenant" ON public.contact_messages;
-- CREATE POLICY "contact_messages_insert_public" ON public.contact_messages
--   FOR INSERT TO public WITH CHECK (true);
