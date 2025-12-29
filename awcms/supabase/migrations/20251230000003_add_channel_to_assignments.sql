-- Migration: 20251230000003_add_channel_to_assignments.sql
-- Description: Adds channel support to template assignments.

-- 1. Add channel column
ALTER TABLE public.template_assignments
ADD COLUMN IF NOT EXISTS channel text DEFAULT 'web';

-- 2. Drop existing unique constraint if it exists (usually unique on (tenant_id, route_type))
-- Note: RLS handles tenant_id, so the unique constraint might just be (route_type) if we rely on RLS, 
-- but physically on DB it's (tenant_id, route_type).
-- Let's check what constraints might exist.
-- We will Try to drop likely named constraints.
ALTER TABLE public.template_assignments DROP CONSTRAINT IF EXISTS template_assignments_route_type_key; -- If simplistic
ALTER TABLE public.template_assignments DROP CONSTRAINT IF EXISTS template_assignments_tenant_id_route_type_key;

-- 3. Add new unique constraint
ALTER TABLE public.template_assignments
ADD CONSTRAINT template_assignments_tenant_channel_route_unique UNIQUE (tenant_id, channel, route_type);

-- 4. Update RLS (if needed)
-- RLS policies usually just check tenant_id, so adding a column doesn't break them.
