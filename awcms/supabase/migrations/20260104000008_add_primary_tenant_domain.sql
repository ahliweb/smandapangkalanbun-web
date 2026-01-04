-- Migration: 20260104000008_add_primary_tenant_domain.sql
-- Description: Ensure primary tenant exists with correct host configuration

-- Update or insert the primary tenant with host = 'primary.ahliweb.com'
-- The RPC get_tenant_id_by_host will automatically alias 'primary-public.ahliweb.com' to this

DO $$
DECLARE
    existing_tenant_id uuid;
BEGIN
    -- Check if tenant with host 'primary.ahliweb.com' exists
    SELECT id INTO existing_tenant_id 
    FROM tenants 
    WHERE host = 'primary.ahliweb.com' OR name ILIKE '%primary%'
    LIMIT 1;
    
    IF existing_tenant_id IS NULL THEN
        -- Insert new tenant
        INSERT INTO tenants (name, host, domain, is_active)
        VALUES ('Primary', 'primary.ahliweb.com', 'primary.ahliweb.com', true);
        RAISE NOTICE 'Created new primary tenant';
    ELSE
        -- Update existing tenant to ensure host is correct
        UPDATE tenants 
        SET host = 'primary.ahliweb.com',
            domain = COALESCE(domain, 'primary.ahliweb.com')
        WHERE id = existing_tenant_id;
        RAISE NOTICE 'Updated existing tenant % with host primary.ahliweb.com', existing_tenant_id;
    END IF;
END $$;
