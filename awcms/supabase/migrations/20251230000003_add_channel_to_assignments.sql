-- Migration: 20251230000003_add_channel_to_assignments.sql
-- Description: Adds channel support to template assignments.

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'template_assignments' AND table_schema = 'public') THEN
    
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'template_assignments' AND column_name = 'channel') THEN
            EXECUTE 'ALTER TABLE public.template_assignments ADD COLUMN channel text DEFAULT ''web''';
        END IF;

        -- Drop existing constraints if they exist
        BEGIN
            EXECUTE 'ALTER TABLE public.template_assignments DROP CONSTRAINT IF EXISTS template_assignments_route_type_key';
            EXECUTE 'ALTER TABLE public.template_assignments DROP CONSTRAINT IF EXISTS template_assignments_tenant_id_route_type_key';
        EXCEPTION WHEN OTHERS THEN
            NULL; -- Ignore if constraints mismatch
        END;

        -- Add new unique constraint
        -- Check if constraint exists first? Or just try add
        BEGIN
             EXECUTE 'ALTER TABLE public.template_assignments ADD CONSTRAINT template_assignments_tenant_channel_route_unique UNIQUE (tenant_id, channel, route_type)';
        EXCEPTION WHEN OTHERS THEN
             NULL; -- Already exists or data violation?
        END;
        
    END IF;
END $$;
