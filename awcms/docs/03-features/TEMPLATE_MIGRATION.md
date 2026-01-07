# Template System Migration Guide

This guide explains how to migrate existing templates from the old system to the new Template System architecture.

## Overview of Changes

| Old System | New System |
| --- | --- |
| `templates` table with basic fields | `templates` table with `tenant_id`, `type`, `parts` columns |
| No reusable parts | `template_parts` for Headers, Footers, Sidebars |
| No route-to-template mapping | `template_assignments` for Home, 404, etc. |
| No widget areas | `widgets` table for Widget Area content |
| No multi-language | `template_strings` for translations |

## Migration Steps

### Step 1: Run Database Migrations

Apply the new migrations in order:

```bash
supabase migration up
```

Files:

- `20251230000001_overhaul_templates_schema.sql`
- `20251230000002_add_template_languages.sql`
- `20251230000003_add_channel_to_assignments.sql`
- `20251230000004_seed_default_templates.sql`

### Step 2: Assign tenant_id to Existing Templates

If you have existing templates without `tenant_id`, you need to update them:

```sql
UPDATE public.templates 
SET tenant_id = '<your_tenant_uuid>' 
WHERE tenant_id IS NULL;
```

### Step 3: Convert Old Templates to New Format

1. Open the Templates Manager (`/cmspanel/templates`).
2. For each template, click "Edit" to open the Template Editor.
3. Assign Headers/Footers from the "Template Parts" section.
4. Save the template.

### Step 4: Create Template Parts

If you have shared headers or footers:

1. Go to "Template Parts" tab.
2. Click "Create Part".
3. Use the Visual Editor to design the Header/Footer.
4. Assign to templates.

### Step 5: Setup Route Assignments

1. Go to "Assignments" tab.
2. For each system route (Home, 404, Search), select the appropriate template.
3. Select the channel (Web, Mobile, ESP32).
4. Save.

## Compatibility Notes

- Old templates with `data` (Puck JSON) will continue to work.
- The `type` column defaults to `'page'`.
- The `parts` column defaults to `{}`.

## Rollback

If needed, you can rollback migrations:

```bash
supabase migration down --to 20251229xxxxx
```

Replace with the timestamp of the last migration before the overhaul.
