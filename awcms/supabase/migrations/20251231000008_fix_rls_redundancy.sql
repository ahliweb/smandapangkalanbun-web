-- Migration: Fix RLS Redundancy
-- Final cleanup of duplicate policies.

DO $$
BEGIN
    -- Clean up Articles
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'articles' AND table_schema = 'public') THEN
        -- Remove legacy policies if they exist
        BEGIN
            EXECUTE 'DROP POLICY "Enable read access for all users" ON public.articles';
        EXCEPTION WHEN OTHERS THEN NULL; END;
        
        BEGIN
            EXECUTE 'DROP POLICY "Enable insert for authenticated users only" ON public.articles';
        EXCEPTION WHEN OTHERS THEN NULL; END;
    END IF;

     -- Clean up Pages
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pages' AND table_schema = 'public') THEN
        BEGIN
            EXECUTE 'DROP POLICY "Enable read access for all users" ON public.pages';
        EXCEPTION WHEN OTHERS THEN NULL; END;
    END IF;

END $$;
