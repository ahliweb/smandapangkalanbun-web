-- Add missing created_by index for notifications table
-- This resolves the remaining "Unindexed Foreign Keys" advisor warning
-- Date: 2026-01-09

CREATE INDEX IF NOT EXISTS idx_notifications_created_by 
  ON public.notifications(created_by);

COMMENT ON INDEX idx_notifications_created_by IS 'Performance: Index for FK constraint lookups';
