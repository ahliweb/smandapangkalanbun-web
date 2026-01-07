-- Migration: Fix Permissions UPDATE Policies
-- Date: 2026-01-07
-- Description: Fixes WITH CHECK (true) clauses on permissions and role_permissions UPDATE policies.
-- Safety: Non-destructive. Tightens access only.
-- Rollback: See rollback section at the bottom of this file.

-- ============================================================================
-- FIX: permissions and role_permissions - Match WITH CHECK to USING clause
-- ============================================================================
-- The UPDATE policies had `USING (is_super_admin())` but `WITH CHECK (true)`.
-- This is inconsistent and flags a Security Advisor warning.
-- We now fix WITH CHECK to also require is_super_admin().

-- Fix permissions table UPDATE policy
DROP POLICY IF EXISTS "permissions_update_policy" ON public.permissions;
CREATE POLICY "permissions_update_policy" ON public.permissions
  FOR UPDATE
  TO authenticated
  USING (is_super_admin())
  WITH CHECK (is_super_admin());

-- Fix role_permissions table UPDATE policy
DROP POLICY IF EXISTS "role_permissions_update_policy" ON public.role_permissions;
CREATE POLICY "role_permissions_update_policy" ON public.role_permissions
  FOR UPDATE
  TO authenticated
  USING (is_super_admin())
  WITH CHECK (is_super_admin());

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================
-- To revert these changes:
--
-- DROP POLICY IF EXISTS "permissions_update_policy" ON public.permissions;
-- CREATE POLICY "permissions_update_policy" ON public.permissions
--   FOR UPDATE TO authenticated
--   USING (is_super_admin())
--   WITH CHECK (true);
--
-- DROP POLICY IF EXISTS "role_permissions_update_policy" ON public.role_permissions;
-- CREATE POLICY "role_permissions_update_policy" ON public.role_permissions
--   FOR UPDATE TO authenticated
--   USING (is_super_admin())
--   WITH CHECK (true);
