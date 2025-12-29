-- Migration: Overhaul Templates Schema
-- Date: 2025-12-30
-- Description: Adds tenant isolation to templates, and introduces template_parts, widgets, and template_assignments.

-- 1. Modify 'templates' table
ALTER TABLE public.templates 
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'page',
ADD COLUMN IF NOT EXISTS parts JSONB DEFAULT '{}'::jsonb;

CREATE INDEX IF NOT EXISTS idx_templates_tenant_id ON public.templates(tenant_id);

-- Update RLS for templates (enforce tenant isolation)
DROP POLICY IF EXISTS "Public can view active templates" ON public.templates;
DROP POLICY IF EXISTS "Authenticated users can view all templates" ON public.templates;
DROP POLICY IF EXISTS "Admins users can manage templates" ON public.templates;

CREATE POLICY "Tenant Isolation Select Templates" ON public.templates
FOR SELECT USING (
    tenant_id = COALESCE(
        current_setting('app.current_tenant_id', true)::uuid,
        (auth.jwt() ->> 'tenant_id')::uuid
    )
    OR (auth.jwt() ->> 'role' = 'super_admin')
);

CREATE POLICY "Tenant Isolation All Templates" ON public.templates
FOR ALL USING (
    tenant_id = COALESCE(
        current_setting('app.current_tenant_id', true)::uuid,
        (auth.jwt() ->> 'tenant_id')::uuid
    )
    OR (auth.jwt() ->> 'role' = 'super_admin')
);

-- 2. Create 'template_parts' table
CREATE TABLE IF NOT EXISTS public.template_parts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('header', 'footer', 'sidebar', 'widget_area')),
    content JSONB DEFAULT '{}'::jsonb, -- Puck data
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.template_parts ENABLE ROW LEVEL SECURITY;
CREATE INDEX idx_template_parts_tenant ON public.template_parts(tenant_id);

CREATE POLICY "Tenant Isolation Select Parts" ON public.template_parts
FOR SELECT USING (
    tenant_id = COALESCE(
        current_setting('app.current_tenant_id', true)::uuid,
        (auth.jwt() ->> 'tenant_id')::uuid
    )
    OR (auth.jwt() ->> 'role' = 'super_admin')
);

CREATE POLICY "Tenant Isolation All Parts" ON public.template_parts
FOR ALL USING (
    tenant_id = COALESCE(
        current_setting('app.current_tenant_id', true)::uuid,
        (auth.jwt() ->> 'tenant_id')::uuid
    )
    OR (auth.jwt() ->> 'role' = 'super_admin')
);

-- 3. Create 'widgets' table
CREATE TABLE IF NOT EXISTS public.widgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    area_id UUID REFERENCES public.template_parts(id) ON DELETE SET NULL, -- Where it lives
    type TEXT NOT NULL, -- e.g. 'core/text'
    config JSONB DEFAULT '{}'::jsonb,
    "order" INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.widgets ENABLE ROW LEVEL SECURITY;
CREATE INDEX idx_widgets_tenant ON public.widgets(tenant_id);
CREATE INDEX idx_widgets_area ON public.widgets(area_id);

CREATE POLICY "Tenant Isolation Select Widgets" ON public.widgets
FOR SELECT USING (
    tenant_id = COALESCE(
        current_setting('app.current_tenant_id', true)::uuid,
        (auth.jwt() ->> 'tenant_id')::uuid
    )
    OR (auth.jwt() ->> 'role' = 'super_admin')
);

CREATE POLICY "Tenant Isolation All Widgets" ON public.widgets
FOR ALL USING (
    tenant_id = COALESCE(
        current_setting('app.current_tenant_id', true)::uuid,
        (auth.jwt() ->> 'tenant_id')::uuid
    )
    OR (auth.jwt() ->> 'role' = 'super_admin')
);

-- 4. Create 'template_assignments' table
CREATE TABLE IF NOT EXISTS public.template_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    route_type TEXT NOT NULL, -- 'home', '404', 'archive', 'single'
    template_id UUID REFERENCES public.templates(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(tenant_id, route_type)
);

ALTER TABLE public.template_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tenant Isolation Select Assignments" ON public.template_assignments
FOR SELECT USING (
    tenant_id = COALESCE(
        current_setting('app.current_tenant_id', true)::uuid,
        (auth.jwt() ->> 'tenant_id')::uuid
    )
    OR (auth.jwt() ->> 'role' = 'super_admin')
);

CREATE POLICY "Tenant Isolation All Assignments" ON public.template_assignments
FOR ALL USING (
    tenant_id = COALESCE(
        current_setting('app.current_tenant_id', true)::uuid,
        (auth.jwt() ->> 'tenant_id')::uuid
    )
    OR (auth.jwt() ->> 'role' = 'super_admin')
);

-- 5. Trigger for updated_at
CREATE TRIGGER update_template_parts_updated_at
BEFORE UPDATE ON public.template_parts
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_widgets_updated_at
BEFORE UPDATE ON public.widgets
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_template_assignments_updated_at
BEFORE UPDATE ON public.template_assignments
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
