-- Migration: Global RLS Performance Fix (Optimized)
-- Replaces STABLE functions with proper policy logic where possible, or updates policies to use better functions.

DO $$
BEGIN

    -- Articles
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'articles' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "Tenant Read Access" ON public.articles';
        EXECUTE 'CREATE POLICY "Tenant Read Access" ON public.articles FOR SELECT TO authenticated USING (tenant_id = public.current_tenant_id())';
        
        EXECUTE 'DROP POLICY IF EXISTS "Tenant Write Access" ON public.articles';
        EXECUTE 'CREATE POLICY "Tenant Write Access" ON public.articles FOR ALL TO authenticated USING (tenant_id = public.current_tenant_id())';
    END IF;

    -- Pages
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pages' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "Tenant Read Access" ON public.pages';
        EXECUTE 'CREATE POLICY "Tenant Read Access" ON public.pages FOR SELECT TO authenticated USING (tenant_id = public.current_tenant_id())';
    
        EXECUTE 'DROP POLICY IF EXISTS "Tenant Write Access" ON public.pages';
        EXECUTE 'CREATE POLICY "Tenant Write Access" ON public.pages FOR ALL TO authenticated USING (tenant_id = public.current_tenant_id())';
    END IF;

END $$;
