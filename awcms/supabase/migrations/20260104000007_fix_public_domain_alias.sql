-- Migration: 20260104000007_fix_public_domain_alias.sql
-- Description: Support public portal domain alias (tenant-public.domain.tld -> tenant.domain.tld)

CREATE OR REPLACE FUNCTION public.get_tenant_id_by_host(lookup_host text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  target_host text;
BEGIN
  -- Handle Domain Aliases: tenant-public.domain.tld -> tenant.domain.tld
  -- Example: primary-public.ahliweb.com -> primary.ahliweb.com
  IF lookup_host LIKE '%-public.%' THEN
      target_host := replace(lookup_host, '-public.', '.');
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
