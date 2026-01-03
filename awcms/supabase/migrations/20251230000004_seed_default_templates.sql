-- Migration: 20251230000004_seed_default_templates.sql
-- Description: Creates default templates for each page type.

DO $$
DECLARE
    target_tenant_id UUID;
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'templates' AND table_schema = 'public') 
       AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tenants' AND table_schema = 'public') THEN
       
       SELECT id INTO target_tenant_id FROM public.tenants ORDER BY created_at ASC LIMIT 1;
       
       IF target_tenant_id IS NOT NULL THEN
            -- 1. Default Home Template
            INSERT INTO public.templates (name, slug, description, type, is_active, data, tenant_id)
            VALUES (
                'Default Home',
                'default-home',
                'A simple home page layout with Hero and sections.',
                'page',
                true,
                '{"content":[{"type":"Hero","props":{"title":"Welcome!","subtitle":"This is your homepage."}},{"type":"Section","props":{"title":"About Us"}}],"root":{}}'::jsonb,
                target_tenant_id
            ) ON CONFLICT (slug) DO NOTHING;

            -- 2. Default 404 Template
            INSERT INTO public.templates (name, slug, description, type, is_active, data, tenant_id)
            VALUES (
                'Default 404',
                'default-404',
                'Standard 404 Not Found page.',
                'error',
                true,
                '{"content":[{"type":"Hero","props":{"title":"404 - Page Not Found","subtitle":"Sorry, the page you are looking for does not exist."}}],"root":{}}'::jsonb,
                target_tenant_id
            ) ON CONFLICT (slug) DO NOTHING;

            -- 3. Default Archive Template
            INSERT INTO public.templates (name, slug, description, type, is_active, data, tenant_id)
            VALUES (
                'Default Archive',
                'default-archive',
                'Standard archive listing template.',
                'archive',
                true,
                '{"content":[{"type":"Section","props":{"title":"Archive"}}],"root":{}}'::jsonb,
                target_tenant_id
            ) ON CONFLICT (slug) DO NOTHING;

            -- 4. Default Single Post Template
            INSERT INTO public.templates (name, slug, description, type, is_active, data, tenant_id)
            VALUES (
                'Default Single',
                'default-single',
                'Standard single post template.',
                'single',
                true,
                '{"content":[{"type":"Section","props":{"title":"Post Title"}}],"root":{}}'::jsonb,
                target_tenant_id
            ) ON CONFLICT (slug) DO NOTHING;
            
            IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'template_parts' AND table_schema = 'public') THEN
                -- 5. Default Header Part
                INSERT INTO public.template_parts (name, type, content, tenant_id)
                VALUES (
                    'Default Header',
                    'header',
                    '{"content":[{"type":"core/menu","props":{"menuId":""}}]}'::jsonb,
                    target_tenant_id
                ) ON CONFLICT DO NOTHING;

                -- 6. Default Footer Part
                INSERT INTO public.template_parts (name, type, content, tenant_id)
                VALUES (
                    'Default Footer',
                    'footer',
                    '{"content":[{"type":"core/text","props":{"content":"© 2024 My Website","isHtml":false}}]}'::jsonb,
                    target_tenant_id
                ) ON CONFLICT DO NOTHING;
            END IF;
       END IF;
    END IF;
END $$;
