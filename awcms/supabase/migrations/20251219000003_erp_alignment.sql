-- Migration: ERP Alignment (Roles, Permissions, Menus)
-- Generated based on docs/ABAC_SYSTEM.md and ERP Architecture

-- 1. Ensure Roles Exist
DO $$
DECLARE
    default_tenant_id UUID;
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'roles' AND table_schema = 'public') 
       AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tenants' AND table_schema = 'public') THEN
        
        -- Get primary tenant for system roles
        SELECT id INTO default_tenant_id FROM public.tenants WHERE slug = 'primary' LIMIT 1;
        
        IF default_tenant_id IS NOT NULL THEN
            INSERT INTO public.roles (name, description, is_system, tenant_id) VALUES
            ('owner', 'System Owner - Supreme Authority', true, default_tenant_id),
            ('author', 'Content Creator', true, default_tenant_id),
            ('member', 'Registered User', true, default_tenant_id),
            ('subscriber', 'Premium User', true, default_tenant_id)
            ON CONFLICT (name) DO NOTHING;
        END IF;
    END IF;
END $$;

-- 2. Define Permissions (Resource-based)
-- Uses dynamic sql to avoid errors if tables missing
DO $$
DECLARE
    perm text[]; -- Array slice
    perms text[][] := ARRAY[
        ['articles.read', 'Can read articles'],
        ['articles.create', 'Can create articles'],
        ['articles.edit', 'Can edit any article'],
        ['articles.delete', 'Can delete any article'],
        ['articles.publish', 'Can publish articles'],
        ['pages.read', 'Can read pages'],
        ['pages.manage', 'Can manage pages'],
        ['users.read', 'Can read user profiles'],
        ['users.manage', 'Can manage users'],
        ['roles.read', 'Can view roles'],
        ['roles.manage', 'Can manage roles'],
        ['settings.manage', 'Can manage system settings']
    ];
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'permissions' AND table_schema = 'public') THEN
        
        FOREACH perm SLICE 1 IN ARRAY perms
        LOOP
            -- Using split_part to populate NOT NULL columns (module, resource, action) from the permission name (e.g. 'articles.read')
            EXECUTE 'INSERT INTO public.permissions (name, description, module, resource, action) 
                     VALUES ($1, $2, split_part($1, ''.'', 1), split_part($1, ''.'', 1), split_part($1, ''.'', 2)) 
                     ON CONFLICT (name) DO NOTHING' 
            USING perm[1], perm[2];
        END LOOP;
    END IF;
END $$;


-- 3. Assign Permissions to Roles (Seed Logic)
-- Using dynamic SQL for safety
DO $$
DECLARE
    role_name text;
    perm_code text;
    v_role_id uuid;
    v_perm_id uuid;
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'roles' AND table_schema = 'public') 
       AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'permissions' AND table_schema = 'public') 
       AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'role_permissions' AND table_schema = 'public') THEN

        -- Author (Articles)
        SELECT id INTO v_role_id FROM public.roles WHERE name = 'author' LIMIT 1;
        IF v_role_id IS NOT NULL THEN
            FOR perm_code IN SELECT unnest(ARRAY['articles.read', 'articles.create', 'articles.edit', 'pages.read'])
            LOOP
                -- Lookup using 'name' column
                SELECT id INTO v_perm_id FROM public.permissions WHERE name = perm_code LIMIT 1;
                IF v_perm_id IS NOT NULL THEN
                    EXECUTE 'INSERT INTO public.role_permissions (role_id, permission_id) VALUES ($1, $2) ON CONFLICT DO NOTHING'
                    USING v_role_id, v_perm_id;
                END IF;
            END LOOP;
        END IF;

    END IF;
END $$;
