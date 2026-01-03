-- Migration: Seed ABAC Policies
-- Description: Inserts standard ABAC policies and assigns them to roles

DO $$
DECLARE
  v_policy_id UUID;
  v_admin_role_id UUID;
  v_author_role_id UUID;
  v_tenant_id UUID; 
BEGIN
  -- Only run if tables exist
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'policies' AND table_schema = 'public') 
     AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'role_policies' AND table_schema = 'public') 
     AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'roles' AND table_schema = 'public') THEN

      -- 1. Create "Restrict Mobile Deletion" Policy (Global)
      INSERT INTO public.policies (name, description, definition, tenant_id)
      VALUES (
        'Restrict Mobile Deletion',
        'Prevents deletion of resources when using mobile devices',
        '{
          "effect": "deny",
          "actions": ["delete", "delete_permanent"],
          "conditions": {
            "channel": "mobile"
          }
        }'::jsonb,
        NULL -- Global policy
      )
      ON CONFLICT DO NOTHING
      RETURNING id INTO v_policy_id;

      -- Verify/Get ID if it already existed
      IF v_policy_id IS NULL THEN
        SELECT id INTO v_policy_id FROM public.policies WHERE name = 'Restrict Mobile Deletion';
      END IF;

      -- 2. Assign to 'admin' role (Tenant Admin)
      SELECT id INTO v_admin_role_id FROM public.roles WHERE name = 'admin';

      IF v_admin_role_id IS NOT NULL AND v_policy_id IS NOT NULL THEN
        INSERT INTO public.role_policies (role_id, policy_id)
        VALUES (v_admin_role_id, v_policy_id)
        ON CONFLICT DO NOTHING;
      END IF;
      
  END IF;
END $$;
