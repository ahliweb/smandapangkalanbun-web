-- Migration: 20251230000002_add_template_languages.sql
-- Description: Adds language support to templates and creates a table for template string translations.

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'templates' AND table_schema = 'public') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'templates' AND column_name = 'language') THEN
             EXECUTE 'ALTER TABLE public.templates ADD COLUMN language text DEFAULT ''en''';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'templates' AND column_name = 'translation_group_id') THEN
             EXECUTE 'ALTER TABLE public.templates ADD COLUMN translation_group_id uuid DEFAULT gen_random_uuid()';
        END IF;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'template_parts' AND table_schema = 'public') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'template_parts' AND column_name = 'language') THEN
             EXECUTE 'ALTER TABLE public.template_parts ADD COLUMN language text DEFAULT ''en''';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'template_parts' AND column_name = 'translation_group_id') THEN
             EXECUTE 'ALTER TABLE public.template_parts ADD COLUMN translation_group_id uuid DEFAULT gen_random_uuid()';
        END IF;
    END IF;

    -- Create template_strings table for granular string translations
    EXECUTE 'CREATE TABLE IF NOT EXISTS public.template_strings (
        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
        tenant_id uuid NOT NULL,
        key text NOT NULL,
        locale text NOT NULL,
        value text,
        context text DEFAULT ''default'',
        created_at timestamptz DEFAULT now(),
        updated_at timestamptz DEFAULT now(),
        UNIQUE(tenant_id, key, locale, context)
    )';

    EXECUTE 'ALTER TABLE public.template_strings ENABLE ROW LEVEL SECURITY';

    -- Create RLS Policies for template_strings
    EXECUTE 'DROP POLICY IF EXISTS "Enable read access for all users" ON public.template_strings';
    EXECUTE 'CREATE POLICY "Enable read access for all users" ON public.template_strings FOR SELECT USING (true)'; 

    EXECUTE 'DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.template_strings';
    EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation for select" ON public.template_strings';
    EXECUTE 'DROP POLICY IF EXISTS "Enable read access for tenant" ON public.template_strings';
    EXECUTE 'DROP POLICY IF EXISTS "Public read access" ON public.template_strings';

    EXECUTE 'CREATE POLICY "Public read access" ON public.template_strings FOR SELECT USING (true)';

    -- Write Policies
    EXECUTE 'DROP POLICY IF EXISTS "Admins can insert" ON public.template_strings';
    EXECUTE 'CREATE POLICY "Admins can insert" ON public.template_strings
        FOR INSERT WITH CHECK (
            auth.role() = ''authenticated'' AND 
            (EXISTS (
                SELECT 1 FROM public.users u
                JOIN public.roles r ON u.role_id = r.id
                WHERE u.id = auth.uid() 
                AND (r.name IN (''owner'', ''admin'', ''super_admin''))
            ))
        )';

    EXECUTE 'DROP POLICY IF EXISTS "Admins can update" ON public.template_strings';
    EXECUTE 'CREATE POLICY "Admins can update" ON public.template_strings
        FOR UPDATE USING (
            auth.role() = ''authenticated'' AND 
            (EXISTS (
                SELECT 1 FROM public.users u
                JOIN public.roles r ON u.role_id = r.id
                WHERE u.id = auth.uid() 
                AND (r.name IN (''owner'', ''admin'', ''super_admin''))
            ))
        )';

    EXECUTE 'DROP POLICY IF EXISTS "Admins can delete" ON public.template_strings';
    EXECUTE 'CREATE POLICY "Admins can delete" ON public.template_strings
        FOR DELETE USING (
            auth.role() = ''authenticated'' AND 
            (EXISTS (
                SELECT 1 FROM public.users u
                JOIN public.roles r ON u.role_id = r.id
                WHERE u.id = auth.uid() 
                AND (r.name IN (''owner'', ''admin'', ''super_admin''))
            ))
        )';

    -- Add trigger for updated_at
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
         EXECUTE 'DROP TRIGGER IF EXISTS update_template_strings_updated_at ON public.template_strings';
         EXECUTE 'CREATE TRIGGER update_template_strings_updated_at
            BEFORE UPDATE ON public.template_strings
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column()';
    END IF;
END $$;
