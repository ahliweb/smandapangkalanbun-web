-- Migration: 20251218_auto_set_tenant_id
-- Description: Create trigger to automatically set tenant_id from current_tenant_id() if not provided.
-- Force Refresh: Safe Record Loop with Dynamic SQL (Cache Cleared)

-- 1. Create the trigger function
CREATE OR REPLACE FUNCTION public.set_tenant_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Only set if not already provided (allows explicit override by platform admins)
    IF NEW.tenant_id IS NULL THEN
        NEW.tenant_id := current_tenant_id();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Apply trigger to all multi-tenant tables (Safe Version)
DO $$
DECLARE
    r record;
    target_tables text[] := ARRAY[
        -- Core
        'articles', 'pages', 'files', 'products', 'orders',
        -- Marketing
        'announcements', 'promotions', 'testimonies', 'portfolio',
        -- Content
        'menus', 'tags', 'categories',
        -- System
        'contact_messages', 'product_types', 
        'themes', 'templates', 
        'extensions', 'extension_routes', 
        'photo_gallery', 'video_gallery'
    ];
BEGIN
    -- Iterate only over tables that actually exist to avoid "relation does not exist" errors
    -- This allows the migration to run even if some tables haven't been created yet (dependency ordering robustness)
    -- We cast table_name to text to be explicit to avoid any ambiguity
    FOR r IN 
        SELECT table_name::text 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = ANY(target_tables)
    LOOP
        -- Drop if exists
        EXECUTE format('DROP TRIGGER IF EXISTS trg_set_tenant_id ON public.%I;', r.table_name);
        
        -- Create Trigger
        EXECUTE format(
            'CREATE TRIGGER trg_set_tenant_id
             BEFORE INSERT ON public.%I
             FOR EACH ROW
             EXECUTE FUNCTION public.set_tenant_id();',
            r.table_name
        );
    END LOOP;
END $$;
