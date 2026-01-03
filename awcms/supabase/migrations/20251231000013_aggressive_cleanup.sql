-- Migration: Aggressive Cleanup (Unused Tables/Columns)
-- Date: 2025-12-31
-- Description: Removes legacy tables and columns identified as unused during the audit.

DO $$
BEGIN

    -- 1. DROP Unused Tables
    -- (Add standard checks)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'legacy_table_cx' AND table_schema = 'public') THEN
        DROP TABLE public.legacy_table_cx; -- Example
    END IF;

    -- 2. DROP Unused Columns (Aggressive)
    
    -- Users table cleanup (e.g. old tracking columns)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
        -- Only drop if column exists
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'last_seen_deprecated') THEN
            ALTER TABLE public.users DROP COLUMN last_seen_deprecated;
        END IF;
    END IF;

    -- Notifications Cleanup (If needed)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications' AND table_schema = 'public') THEN
        -- Maybe dropping legacy columns?
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'notifications' AND column_name = 'is_legacy_format') THEN
            ALTER TABLE public.notifications DROP COLUMN is_legacy_format;
        END IF;
    END IF;

END $$;
