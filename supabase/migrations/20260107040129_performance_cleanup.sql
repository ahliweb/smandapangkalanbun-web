-- Migration: Performance Advisor Cleanup
-- Date: 2026-01-07
-- Description: Removes unused indexes flagged by Supabase Performance Advisor.
-- Safety: Non-destructive. Dropping unused indexes saves storage and write overhead.
-- Rollback: See rollback section at the bottom of this file.

-- ============================================================================
-- DROP UNUSED INDEXES
-- ============================================================================

-- testimonies: published_at index never used
DROP INDEX IF EXISTS public.idx_testimonies_published_at;

-- template_parts: tenant index never used
DROP INDEX IF EXISTS public.idx_template_parts_tenant;

-- widgets: tenant and area indexes never used
DROP INDEX IF EXISTS public.idx_widgets_tenant;
DROP INDEX IF EXISTS public.idx_widgets_area;

-- notification_readers: user_id index never used
DROP INDEX IF EXISTS public.notification_readers_user_id_idx;

-- notifications: created_by index never used
DROP INDEX IF EXISTS public.notifications_created_by_idx;

-- two_factor_audit_logs: user_id index never used
DROP INDEX IF EXISTS public.two_factor_audit_logs_user_id_idx;

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================
-- To recreate these indexes if needed:
--
-- CREATE INDEX idx_testimonies_published_at ON public.testimonies(published_at);
-- CREATE INDEX idx_template_parts_tenant ON public.template_parts(tenant_id);
-- CREATE INDEX idx_widgets_tenant ON public.widgets(tenant_id);
-- CREATE INDEX idx_widgets_area ON public.widgets(area);
-- CREATE INDEX notification_readers_user_id_idx ON public.notification_readers(user_id);
-- CREATE INDEX notifications_created_by_idx ON public.notifications(created_by);
-- CREATE INDEX two_factor_audit_logs_user_id_idx ON public.two_factor_audit_logs(user_id);
