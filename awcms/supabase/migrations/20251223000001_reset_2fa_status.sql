-- Migration: Reset 2FA Status for All Users
-- Reason: To resolve potential lockout/sync issues during system overhaul.

-- Use DO block for conditional execution
DO $$
BEGIN
    -- Only update if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'two_factor_auth' AND table_schema = 'public') THEN
        
        -- 1. Disable 2FA for all users
        UPDATE public.two_factor_auth
        SET enabled = false,
        updated_at = NOW();

    END IF;
END $$;
