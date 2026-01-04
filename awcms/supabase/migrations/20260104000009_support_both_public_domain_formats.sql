-- Migration: 20260104000009_support_both_public_domain_formats.sql
-- Description: Support both domain formats for public portal
-- primary-public.ahliweb.com (hyphen) AND primary.public.ahliweb.com (dot)

CREATE OR REPLACE FUNCTION public.get_tenant_id_by_host(lookup_host text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  target_host text;
  tenant_name text;
BEGIN
  -- Handle Domain Aliases for Public Portal
  -- Format 1: tenant-public.domain.tld -> tenant.domain.tld (hyphen format)
  -- Format 2: tenant.public.domain.tld -> tenant.domain.tld (dot format)
  
  IF lookup_host LIKE '%-public.%' THEN
      -- Hyphen format: primary-public.ahliweb.com -> primary.ahliweb.com
      target_host := replace(lookup_host, '-public.', '.');
  ELSIF lookup_host LIKE '%.public.%' THEN
      -- Dot format: primary.public.ahliweb.com -> primary.ahliweb.com
      -- Extract tenant name (first part) and domain (parts after 'public')
      tenant_name := split_part(lookup_host, '.', 1);
      target_host := tenant_name || '.' || 
                     split_part(lookup_host, '.public.', 2);
  ELSE
      target_host := lookup_host;
  END IF;

  -- Lookup Tenant by host or domain
  RETURN (
    SELECT id 
    FROM tenants 
    WHERE host = target_host 
       OR domain = target_host 
    LIMIT 1
  );
END;
$$;
