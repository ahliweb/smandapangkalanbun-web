-- Migration: 20260104000010_cleanup_public_domain_alias.sql
-- Description: Only support hyphen format for public portal domain alias
-- Supported: primary-public.ahliweb.com -> primary.ahliweb.com
-- Removed: primary.public.ahliweb.com (dot format)

CREATE OR REPLACE FUNCTION public.get_tenant_id_by_host(lookup_host text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  target_host text;
BEGIN
  -- Handle Domain Alias: tenant-public.domain.tld -> tenant.domain.tld
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

-- Note: To completely remove primary.public.ahliweb.com, you need to:
-- 1. Delete the DNS record in Cloudflare for "primary.public" subdomain
-- 2. Only keep the DNS record for "primary-public" subdomain pointing to Cloudflare Pages
