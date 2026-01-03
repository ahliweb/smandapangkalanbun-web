-- Migration: Consolidate and Optimize RLS
-- Merges redundant policies and ensures consistent application.

DO $$
BEGIN
    -- Consolidate Articles
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'articles' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "articles_select_policy" ON public.articles';
        EXECUTE 'DROP POLICY IF EXISTS "articles_modify_policy" ON public.articles';
        -- Add any new consolidated policies here if needed, or rely on 06
    END IF;

    -- Consolidate Pages
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pages' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "pages_select_policy" ON public.pages';
        EXECUTE 'DROP POLICY IF EXISTS "pages_modify_policy" ON public.pages';
    END IF;

    -- Consolidate Files
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'files' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "files_select_policy" ON public.files';
        EXECUTE 'DROP POLICY IF EXISTS "files_modify_policy" ON public.files';
    END IF;

END $$;
