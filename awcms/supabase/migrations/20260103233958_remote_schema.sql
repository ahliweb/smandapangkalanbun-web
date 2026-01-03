create extension if not exists "hypopg" with schema "extensions";

create extension if not exists "index_advisor" with schema "extensions";

create sequence "public"."auth_hibp_events_id_seq";

drop policy "Platform Admins manage all requests" on "public"."account_requests";

drop policy "Tenant Admins manage own requests" on "public"."account_requests";

drop policy "Authenticated users view admin_menus" on "public"."admin_menus";

drop policy "Platform admins manage admin_menus" on "public"."admin_menus";

drop policy "admin_menus_read" on "public"."admin_menus";

drop policy "admin_menus_write" on "public"."admin_menus";

drop policy "audit_insert_policy" on "public"."audit_logs";

drop policy "audit_view_policy" on "public"."audit_logs";

drop policy "policies_all_policy" on "public"."policies";

drop policy "policies_read_policy" on "public"."policies";

drop policy "Admins can manage role_policies" on "public"."role_policies";

drop policy "Authenticated can read role_policies" on "public"."role_policies";

drop policy "roles_select_policy" on "public"."roles";

drop policy "Tenant Isolation All Assignments" on "public"."template_assignments";

drop policy "Tenant Isolation Select Assignments" on "public"."template_assignments";

drop policy "Tenant Isolation All Parts" on "public"."template_parts";

drop policy "Tenant Isolation Select Parts" on "public"."template_parts";

drop policy "Admins can delete" on "public"."template_strings";

drop policy "Admins can insert" on "public"."template_strings";

drop policy "Admins can update" on "public"."template_strings";

drop policy "Enable read access for all users" on "public"."template_strings";

drop policy "Public read access" on "public"."template_strings";

drop policy "Tenant Isolation All Templates" on "public"."templates";

drop policy "Tenant Isolation Select Templates" on "public"."templates";

drop policy "Tenant Read Access" on "public"."templates";

drop policy "Tenant Write Access" on "public"."templates";

drop policy "Platform Admin Manage Tenants" on "public"."tenants";

drop policy "Users View Own Tenant" on "public"."tenants";

drop policy "admins_approve_users" on "public"."users";

drop policy "admins_view_pending_users" on "public"."users";

drop policy "users_insert_policy" on "public"."users";

drop policy "users_select_policy" on "public"."users";

drop policy "Tenant Isolation All Widgets" on "public"."widgets";

drop policy "Tenant Isolation Select Widgets" on "public"."widgets";

alter table "public"."users" drop constraint "users_role_id_fkey";

alter table "public"."role_permissions" drop constraint "role_permissions_pkey";

drop index if exists "public"."idx_role_policies_policy";

drop index if exists "public"."idx_role_policies_role";

drop index if exists "public"."idx_template_parts_tenant_id";

drop index if exists "public"."idx_widgets_tenant_id";

drop index if exists "public"."role_permissions_pkey";


  create table "public"."announcement_tags" (
    "announcement_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."announcement_tags" enable row level security;


  create table "public"."announcements" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "content" text,
    "priority" text default 'normal'::text,
    "status" text default 'draft'::text,
    "published_at" timestamp with time zone,
    "expires_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "category_id" uuid,
    "tags" text[],
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."announcements" enable row level security;


  create table "public"."article_tags" (
    "article_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."article_tags" enable row level security;


  create table "public"."articles" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "slug" text not null,
    "content" text,
    "excerpt" text,
    "featured_image" text,
    "author_id" uuid,
    "status" text default 'draft'::text,
    "published_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "category_id" uuid,
    "tags" text[],
    "is_active" boolean default true,
    "is_public" boolean default true,
    "meta_title" text,
    "meta_description" text,
    "meta_keywords" text,
    "og_image" text,
    "created_by" uuid,
    "canonical_url" text,
    "robots" text default 'index, follow'::text,
    "og_title" text,
    "og_description" text,
    "twitter_card_type" text default 'summary_large_image'::text,
    "twitter_image" text,
    "views" integer default 0,
    "tenant_id" uuid not null,
    "workflow_state" text default 'draft'::text,
    "puck_layout_jsonb" jsonb default '{}'::jsonb,
    "tiptap_doc_jsonb" jsonb default '{}'::jsonb,
    "region_id" uuid,
    "current_assignee_id" uuid
      );


alter table "public"."articles" enable row level security;


  create table "public"."auth_hibp_events" (
    "id" bigint not null default nextval('public.auth_hibp_events_id_seq'::regclass),
    "event_type" text not null,
    "created_at" timestamp with time zone not null default now(),
    "user_id" uuid,
    "created_by" uuid
      );


alter table "public"."auth_hibp_events" enable row level security;


  create table "public"."backup_logs" (
    "id" uuid not null default gen_random_uuid(),
    "backup_id" uuid,
    "action" text not null,
    "status" text not null,
    "message" text,
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "tenant_id" uuid not null
      );


alter table "public"."backup_logs" enable row level security;


  create table "public"."backup_schedules" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "frequency" text not null,
    "time" time without time zone not null,
    "is_active" boolean default true,
    "last_run" timestamp with time zone,
    "next_run" timestamp with time zone,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "tenant_id" uuid
      );


alter table "public"."backup_schedules" enable row level security;


  create table "public"."backups" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "backup_type" text not null default 'full'::text,
    "size" bigint,
    "status" text default 'pending'::text,
    "file_path" text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "expires_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "tenant_id" uuid not null
      );


alter table "public"."backups" enable row level security;


  create table "public"."cart_items" (
    "id" uuid not null default gen_random_uuid(),
    "cart_id" uuid not null,
    "product_id" uuid not null,
    "quantity" integer not null default 1,
    "price_snapshot" numeric not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "tenant_id" uuid not null
      );


alter table "public"."cart_items" enable row level security;


  create table "public"."carts" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "session_id" text,
    "status" text default 'active'::text,
    "tenant_id" uuid not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."carts" enable row level security;


  create table "public"."categories" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" text not null,
    "description" text,
    "type" text not null,
    "created_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "updated_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "deleted_at" timestamp with time zone,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."categories" enable row level security;


  create table "public"."contact_message_tags" (
    "message_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."contact_message_tags" enable row level security;


  create table "public"."contact_messages" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "email" text not null,
    "phone" text,
    "subject" text,
    "message" text not null,
    "status" text default 'new'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "tags" text[],
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."contact_messages" enable row level security;


  create table "public"."contact_tags" (
    "contact_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."contact_tags" enable row level security;


  create table "public"."contacts" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "email" text,
    "phone" text,
    "address" text,
    "city" text,
    "province" text,
    "postal_code" text,
    "country" text,
    "latitude" numeric,
    "longitude" numeric,
    "website" text,
    "social_media" jsonb default '{}'::jsonb,
    "business_hours" jsonb default '{}'::jsonb,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "tags" text[],
    "created_by" uuid,
    "tenant_id" uuid not null
      );


alter table "public"."contacts" enable row level security;


  create table "public"."devices" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "device_id" text not null,
    "device_name" text,
    "device_type" text default 'esp32'::text,
    "ip_address" text,
    "mac_address" text,
    "firmware_version" text default '1.0.0'::text,
    "is_online" boolean default false,
    "last_seen" timestamp with time zone,
    "config" jsonb default '{}'::jsonb,
    "owner_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone
      );


alter table "public"."devices" enable row level security;


  create table "public"."email_logs" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid,
    "event_type" text not null,
    "recipient" text not null,
    "subject" text,
    "template_id" text,
    "metadata" jsonb default '{}'::jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."email_logs" enable row level security;


  create table "public"."extension_logs" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "extension_id" uuid,
    "extension_slug" text not null,
    "action" text not null,
    "details" jsonb default '{}'::jsonb,
    "user_id" uuid,
    "ip_address" text,
    "user_agent" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."extension_logs" enable row level security;


  create table "public"."extension_menu_items" (
    "id" uuid not null default gen_random_uuid(),
    "extension_id" uuid,
    "label" text not null,
    "path" text not null,
    "icon" text,
    "order" integer default 0,
    "is_active" boolean default true,
    "parent_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid
      );


alter table "public"."extension_menu_items" enable row level security;


  create table "public"."extension_permissions" (
    "id" uuid not null default gen_random_uuid(),
    "extension_id" uuid,
    "permission_name" text not null,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "created_by" uuid
      );


alter table "public"."extension_permissions" enable row level security;


  create table "public"."extension_rbac_integration" (
    "id" uuid not null default gen_random_uuid(),
    "extension_id" uuid,
    "role_id" uuid,
    "permission_id" uuid,
    "created_at" timestamp with time zone default now(),
    "created_by" uuid
      );


alter table "public"."extension_rbac_integration" enable row level security;


  create table "public"."extension_routes" (
    "id" uuid not null default gen_random_uuid(),
    "extension_id" uuid,
    "path" text not null,
    "component_key" text not null,
    "name" text not null,
    "icon" text,
    "order" integer default 0,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."extension_routes" enable row level security;


  create table "public"."extension_routes_registry" (
    "id" uuid not null default gen_random_uuid(),
    "extension_id" uuid,
    "path" text not null,
    "component_key" text not null,
    "name" text not null,
    "icon" text,
    "requires_auth" boolean default true,
    "required_permissions" text[],
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid
      );


alter table "public"."extension_routes_registry" enable row level security;


  create table "public"."extensions" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" text not null,
    "description" text,
    "version" text not null default '1.0.0'::text,
    "author" text,
    "is_active" boolean default false,
    "is_system" boolean default false,
    "config" jsonb default '{}'::jsonb,
    "icon" text,
    "created_by" uuid,
    "deleted_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "tenant_id" uuid,
    "extension_type" text default 'core'::text,
    "external_path" text,
    "manifest" jsonb default '{}'::jsonb
      );


alter table "public"."extensions" enable row level security;


  create table "public"."file_permissions" (
    "id" uuid not null default gen_random_uuid(),
    "file_id" uuid,
    "user_id" uuid,
    "permission_type" text not null,
    "created_at" timestamp with time zone default now(),
    "tenant_id" uuid
      );


alter table "public"."file_permissions" enable row level security;


  create table "public"."files" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "file_path" text not null,
    "file_size" bigint,
    "file_type" text,
    "bucket_name" text default 'cms-uploads'::text,
    "folder_id" uuid,
    "is_public" boolean default true,
    "uploaded_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "tenant_id" uuid not null
      );


alter table "public"."files" enable row level security;


  create table "public"."menu_permissions" (
    "id" uuid not null default gen_random_uuid(),
    "menu_id" uuid,
    "role_id" uuid,
    "can_view" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."menu_permissions" enable row level security;


  create table "public"."mobile_app_config" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "app_name" text,
    "app_logo_url" text,
    "app_icon_url" text,
    "primary_color" text default '#3b82f6'::text,
    "secondary_color" text default '#10b981'::text,
    "force_update_version" text,
    "recommended_version" text,
    "maintenance_mode" boolean default false,
    "maintenance_message" text,
    "features" jsonb default '{"offline": true, "articles": true, "notifications": true}'::jsonb,
    "config" jsonb default '{}'::jsonb,
    "updated_at" timestamp with time zone default now(),
    "updated_by" uuid
      );


alter table "public"."mobile_app_config" enable row level security;


  create table "public"."mobile_users" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "user_id" uuid,
    "device_token" text,
    "device_type" text,
    "device_name" text,
    "app_version" text,
    "os_version" text,
    "last_active" timestamp with time zone,
    "push_enabled" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."mobile_users" enable row level security;


  create table "public"."notification_readers" (
    "id" uuid not null default gen_random_uuid(),
    "notification_id" uuid,
    "user_id" uuid,
    "read_at" timestamp with time zone default now()
      );


alter table "public"."notification_readers" enable row level security;


  create table "public"."notifications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "title" text not null,
    "message" text not null,
    "type" text default 'info'::text,
    "is_read" boolean default false,
    "link" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "priority" text default 'normal'::text,
    "category" text default 'system'::text,
    "deleted_at" timestamp with time zone,
    "tenant_id" uuid
      );


alter table "public"."notifications" enable row level security;


  create table "public"."order_items" (
    "id" uuid not null default gen_random_uuid(),
    "order_id" uuid,
    "product_id" uuid,
    "quantity" integer default 1,
    "price" numeric(12,2) default 0,
    "created_at" timestamp with time zone default now(),
    "tenant_id" uuid not null
      );


alter table "public"."order_items" enable row level security;


  create table "public"."orders" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "total_amount" numeric(12,2) default 0,
    "status" text default 'pending'::text,
    "shipping_address" text,
    "tracking_number" text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "tenant_id" uuid not null,
    "deleted_at" timestamp with time zone,
    "payment_status" text default 'unpaid'::text,
    "payment_method" text,
    "shipping_cost" numeric default 0,
    "subtotal" numeric default 0,
    "order_number" text
      );


alter table "public"."orders" enable row level security;


  create table "public"."page_categories" (
    "page_id" uuid not null,
    "category_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."page_categories" enable row level security;


  create table "public"."page_tags" (
    "page_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."page_tags" enable row level security;


  create table "public"."pages" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "slug" text not null,
    "content" text,
    "layout_data" jsonb,
    "status" text default 'draft'::text,
    "published_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "category_id" uuid,
    "tags" text[],
    "created_by" uuid,
    "excerpt" text,
    "featured_image" text,
    "meta_title" text,
    "meta_description" text,
    "meta_keywords" text,
    "og_image" text,
    "canonical_url" text,
    "robots" text,
    "is_public" boolean default true,
    "is_active" boolean default true,
    "og_title" text,
    "og_description" text,
    "twitter_card_type" text default 'summary_large_image'::text,
    "twitter_image" text,
    "views" integer default 0,
    "content_draft" jsonb default '{}'::jsonb,
    "content_published" jsonb default '{}'::jsonb,
    "editor_type" text default 'richtext'::text,
    "template" text default 'default'::text,
    "page_type" text default 'regular'::text,
    "tenant_id" uuid not null,
    "parent_id" uuid,
    "puck_layout_jsonb" jsonb default '{}'::jsonb,
    "workflow_state" text default 'draft'::text,
    "current_assignee_id" uuid
      );


alter table "public"."pages" enable row level security;


  create table "public"."payment_methods" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "type" text not null,
    "description" text,
    "icon" text,
    "config" jsonb default '{}'::jsonb,
    "is_active" boolean default true,
    "sort_order" integer default 0,
    "tenant_id" uuid not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone
      );


alter table "public"."payment_methods" enable row level security;


  create table "public"."payments" (
    "id" uuid not null default gen_random_uuid(),
    "order_id" uuid not null,
    "payment_method_id" uuid,
    "amount" numeric not null,
    "status" text default 'pending'::text,
    "transaction_id" text,
    "gateway_response" jsonb default '{}'::jsonb,
    "paid_at" timestamp with time zone,
    "expires_at" timestamp with time zone,
    "metadata" jsonb default '{}'::jsonb,
    "tenant_id" uuid not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."payments" enable row level security;


  create table "public"."photo_gallery" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "google_album_id" text,
    "google_album_url" text,
    "description" text,
    "photos" jsonb,
    "status" text default 'draft'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "category_id" uuid,
    "tags" text[],
    "created_by" uuid,
    "slug" text,
    "views" integer default 0,
    "photo_count" integer default 0,
    "cover_image" text,
    "tenant_id" uuid
      );


alter table "public"."photo_gallery" enable row level security;


  create table "public"."photo_gallery_tags" (
    "photo_gallery_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."photo_gallery_tags" enable row level security;


  create table "public"."portfolio" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "slug" text not null,
    "description" text,
    "images" jsonb,
    "client" text,
    "project_date" date,
    "tags" jsonb,
    "status" text default 'draft'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "category_id" uuid,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."portfolio" enable row level security;


  create table "public"."portfolio_tags" (
    "portfolio_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."portfolio_tags" enable row level security;


  create table "public"."product_tags" (
    "product_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."product_tags" enable row level security;


  create table "public"."product_type_tags" (
    "product_type_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."product_type_tags" enable row level security;


  create table "public"."product_types" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" text not null,
    "description" text,
    "icon" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "tags" text[],
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."product_types" enable row level security;


  create table "public"."products" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" text not null,
    "description" text,
    "price" numeric(10,2),
    "images" jsonb,
    "status" text default 'draft'::text,
    "stock" integer default 0,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "category_id" uuid,
    "tags" text[],
    "product_type_id" uuid,
    "discount_price" numeric,
    "sku" text,
    "weight" numeric,
    "dimensions" text,
    "shipping_cost" numeric,
    "is_available" boolean default true,
    "created_by" uuid,
    "tenant_id" uuid not null,
    "published_at" timestamp with time zone,
    "featured_image" text
      );


alter table "public"."products" enable row level security;


  create table "public"."promotion_tags" (
    "promotion_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."promotion_tags" enable row level security;


  create table "public"."promotions" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "description" text,
    "discount_percentage" numeric(5,2),
    "discount_amount" numeric(10,2),
    "code" text,
    "start_date" timestamp with time zone,
    "end_date" timestamp with time zone,
    "status" text default 'draft'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "category_id" uuid,
    "tags" text[],
    "created_by" uuid,
    "featured_image" text,
    "tenant_id" uuid
      );


alter table "public"."promotions" enable row level security;


  create table "public"."push_notifications" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "title" text not null,
    "body" text,
    "image_url" text,
    "action_url" text,
    "data" jsonb default '{}'::jsonb,
    "target_type" text default 'all'::text,
    "target_ids" uuid[],
    "target_topics" text[],
    "scheduled_at" timestamp with time zone,
    "sent_at" timestamp with time zone,
    "sent_count" integer default 0,
    "failed_count" integer default 0,
    "status" text default 'draft'::text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."push_notifications" enable row level security;


  create table "public"."region_levels" (
    "id" uuid not null default gen_random_uuid(),
    "key" text not null,
    "name" text not null,
    "level_order" integer not null,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."region_levels" enable row level security;


  create table "public"."regions" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid,
    "level_id" uuid,
    "parent_id" uuid,
    "code" text,
    "name" text not null,
    "full_path" text,
    "metadata" jsonb default '{}'::jsonb,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone
      );


alter table "public"."regions" enable row level security;


  create table "public"."sensor_readings" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "device_id" text not null,
    "gas_ppm" double precision,
    "gas_level" text,
    "temperature" double precision,
    "humidity" double precision,
    "raw_data" jsonb default '{}'::jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."sensor_readings" enable row level security;


  create table "public"."seo_metadata" (
    "id" uuid not null default gen_random_uuid(),
    "resource_type" text not null,
    "resource_id" uuid,
    "meta_title" text,
    "meta_description" text,
    "meta_keywords" text,
    "og_image" text,
    "canonical_url" text,
    "robots" text default 'index, follow'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "tenant_id" uuid not null
      );


alter table "public"."seo_metadata" enable row level security;


  create table "public"."settings" (
    "key" text not null,
    "value" text,
    "type" text default 'string'::text,
    "description" text,
    "is_public" boolean default false,
    "updated_at" timestamp with time zone default now(),
    "tenant_id" uuid not null
      );


alter table "public"."settings" enable row level security;


  create table "public"."sso_audit_logs" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "provider" text not null,
    "event_type" text not null,
    "ip_address" text,
    "user_agent" text,
    "details" jsonb,
    "created_at" timestamp with time zone default now(),
    "tenant_id" uuid
      );


alter table "public"."sso_audit_logs" enable row level security;


  create table "public"."sso_providers" (
    "id" uuid not null default gen_random_uuid(),
    "provider_id" text not null,
    "name" text not null,
    "client_id" text,
    "is_active" boolean default true,
    "config" jsonb default '{}'::jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."sso_providers" enable row level security;


  create table "public"."sso_role_mappings" (
    "id" uuid not null default gen_random_uuid(),
    "provider_id" text not null,
    "external_role_name" text not null,
    "internal_role_id" uuid,
    "created_at" timestamp with time zone default now(),
    "created_by" uuid
      );


alter table "public"."sso_role_mappings" enable row level security;


  create table "public"."tags" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" text not null,
    "created_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "updated_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "deleted_at" timestamp with time zone,
    "description" text,
    "color" text default '#3b82f6'::text,
    "icon" text,
    "is_active" boolean default true,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."tags" enable row level security;


  create table "public"."testimonies" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "content" text,
    "author_name" text not null,
    "author_position" text,
    "author_image" text,
    "rating" integer,
    "category_id" uuid,
    "tags" text[],
    "status" text default 'draft'::text,
    "slug" text not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "created_by" uuid,
    "tenant_id" uuid,
    "published_at" timestamp with time zone
      );


alter table "public"."testimonies" enable row level security;


  create table "public"."testimony_tags" (
    "testimony_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."testimony_tags" enable row level security;


  create table "public"."themes" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" text not null,
    "description" text,
    "config" jsonb default '{}'::jsonb,
    "is_active" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."themes" enable row level security;


  create table "public"."two_factor_audit_logs" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "event_type" text not null,
    "ip_address" text,
    "user_agent" text,
    "created_at" timestamp with time zone default now(),
    "tenant_id" uuid
      );


alter table "public"."two_factor_audit_logs" enable row level security;


  create table "public"."two_factor_auth" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "secret" text not null,
    "backup_codes" text[] default ARRAY[]::text[],
    "enabled" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "tenant_id" uuid
      );


alter table "public"."two_factor_auth" enable row level security;


  create table "public"."video_gallery" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "youtube_playlist_id" text,
    "youtube_playlist_url" text,
    "description" text,
    "videos" jsonb,
    "status" text default 'draft'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "category_id" uuid,
    "tags" text[],
    "created_by" uuid,
    "slug" text,
    "views" integer default 0,
    "duration" text,
    "thumbnail_image" text,
    "tenant_id" uuid
      );


alter table "public"."video_gallery" enable row level security;


  create table "public"."video_gallery_tags" (
    "video_gallery_id" uuid not null,
    "tag_id" uuid not null,
    "created_by" uuid,
    "tenant_id" uuid
      );


alter table "public"."video_gallery_tags" enable row level security;

alter table "public"."admin_menus" add column "is_core" boolean default true;

alter table "public"."admin_menus" add column "parent_key" text;

alter table "public"."admin_menus" alter column "group_order" set default 0;

alter table "public"."admin_menus" alter column "icon" set not null;

alter table "public"."admin_menus" alter column "id" set default gen_random_uuid();

alter table "public"."admin_menus" alter column "is_visible" set not null;

alter table "public"."admin_menus" alter column "order" set not null;

alter table "public"."admin_menus" alter column "path" set not null;

alter table "public"."audit_logs" drop column "new_value";

alter table "public"."audit_logs" drop column "old_value";

alter table "public"."audit_logs" drop column "resource_id";

alter table "public"."audit_logs" drop column "user_agent";

alter table "public"."audit_logs" add column "details" jsonb default '{}'::jsonb;

alter table "public"."audit_logs" alter column "channel" drop default;

alter table "public"."menus" add column "created_by" uuid;

alter table "public"."menus" add column "deleted_at" timestamp with time zone;

alter table "public"."menus" add column "icon" text;

alter table "public"."menus" add column "name" text not null;

alter table "public"."menus" add column "parent_id" uuid;

alter table "public"."menus" add column "role_id" uuid;

alter table "public"."menus" add column "slug" text;

alter table "public"."menus" alter column "label" set not null;

alter table "public"."menus" enable row level security;

alter table "public"."permissions" add column "created_by" uuid;

alter table "public"."permissions" add column "deleted_at" timestamp with time zone;

alter table "public"."permissions" add column "updated_at" timestamp with time zone default now();

alter table "public"."permissions" alter column "action" set not null;

alter table "public"."permissions" alter column "id" set default gen_random_uuid();

alter table "public"."role_permissions" add column "created_at" timestamp with time zone default now();

alter table "public"."role_permissions" add column "created_by" uuid;

alter table "public"."role_permissions" add column "id" uuid not null default gen_random_uuid();

alter table "public"."role_permissions" add column "tenant_id" uuid;

alter table "public"."role_permissions" alter column "permission_id" drop not null;

alter table "public"."role_permissions" alter column "role_id" drop not null;

alter table "public"."roles" add column "deleted_at" timestamp with time zone;

alter table "public"."roles" alter column "id" set default gen_random_uuid();

alter table "public"."roles" alter column "tenant_id" drop not null;

alter table "public"."tenants" add column "billing_amount" numeric(10,2) default 0;

alter table "public"."tenants" add column "billing_cycle" text default 'monthly'::text;

alter table "public"."tenants" add column "contact_email" text;

alter table "public"."tenants" add column "currency" text default 'USD'::text;

alter table "public"."tenants" add column "host" text;

alter table "public"."tenants" add column "locale" text default 'en'::text;

alter table "public"."tenants" add column "notes" text;

alter table "public"."tenants" add column "subscription_expires_at" timestamp with time zone;

alter table "public"."users" add column "created_by" uuid;

alter table "public"."users" add column "language" text default 'id'::text;

alter table "public"."users" add column "region_id" uuid;

alter table "public"."users" alter column "email" set not null;

alter table "public"."users" alter column "id" set default gen_random_uuid();

alter table "public"."users" alter column "tenant_id" drop not null;

alter sequence "public"."auth_hibp_events_id_seq" owned by "public"."auth_hibp_events"."id";

CREATE UNIQUE INDEX announcement_tags_pkey ON public.announcement_tags USING btree (announcement_id, tag_id);

CREATE UNIQUE INDEX announcements_pkey ON public.announcements USING btree (id);

CREATE UNIQUE INDEX article_tags_pkey ON public.article_tags USING btree (article_id, tag_id);

CREATE UNIQUE INDEX articles_pkey ON public.articles USING btree (id);

CREATE UNIQUE INDEX articles_slug_key ON public.articles USING btree (slug);

CREATE UNIQUE INDEX auth_hibp_events_pkey ON public.auth_hibp_events USING btree (id);

CREATE UNIQUE INDEX backup_logs_pkey ON public.backup_logs USING btree (id);

CREATE UNIQUE INDEX backup_schedules_pkey ON public.backup_schedules USING btree (id);

CREATE UNIQUE INDEX backups_pkey ON public.backups USING btree (id);

CREATE UNIQUE INDEX cart_items_cart_id_product_id_key ON public.cart_items USING btree (cart_id, product_id);

CREATE UNIQUE INDEX cart_items_pkey ON public.cart_items USING btree (id);

CREATE UNIQUE INDEX carts_pkey ON public.carts USING btree (id);

CREATE UNIQUE INDEX categories_pkey ON public.categories USING btree (id);

CREATE UNIQUE INDEX categories_slug_key ON public.categories USING btree (slug);

CREATE UNIQUE INDEX contact_message_tags_pkey ON public.contact_message_tags USING btree (message_id, tag_id);

CREATE UNIQUE INDEX contact_messages_pkey ON public.contact_messages USING btree (id);

CREATE UNIQUE INDEX contact_tags_pkey ON public.contact_tags USING btree (contact_id, tag_id);

CREATE UNIQUE INDEX contacts_pkey ON public.contacts USING btree (id);

CREATE UNIQUE INDEX devices_pkey ON public.devices USING btree (id);

CREATE UNIQUE INDEX devices_tenant_id_device_id_key ON public.devices USING btree (tenant_id, device_id);

CREATE UNIQUE INDEX email_logs_pkey ON public.email_logs USING btree (id);

CREATE UNIQUE INDEX extension_logs_pkey ON public.extension_logs USING btree (id);

CREATE UNIQUE INDEX extension_menu_items_pkey ON public.extension_menu_items USING btree (id);

CREATE UNIQUE INDEX extension_permissions_ext_perm_key ON public.extension_permissions USING btree (extension_id, permission_name);

CREATE UNIQUE INDEX extension_permissions_pkey ON public.extension_permissions USING btree (id);

CREATE UNIQUE INDEX extension_rbac_integration_extension_id_role_id_permission__key ON public.extension_rbac_integration USING btree (extension_id, role_id, permission_id);

CREATE UNIQUE INDEX extension_rbac_integration_pkey ON public.extension_rbac_integration USING btree (id);

CREATE UNIQUE INDEX extension_routes_pkey ON public.extension_routes USING btree (id);

CREATE UNIQUE INDEX extension_routes_registry_pkey ON public.extension_routes_registry USING btree (id);

CREATE UNIQUE INDEX extensions_pkey ON public.extensions USING btree (id);

CREATE UNIQUE INDEX extensions_slug_key ON public.extensions USING btree (slug);

CREATE UNIQUE INDEX file_permissions_pkey ON public.file_permissions USING btree (id);

CREATE UNIQUE INDEX files_pkey ON public.files USING btree (id);

CREATE INDEX idx_announcement_tags_announcement_id ON public.announcement_tags USING btree (announcement_id);

CREATE INDEX idx_announcement_tags_created_by ON public.announcement_tags USING btree (created_by);

CREATE INDEX idx_announcement_tags_tag_id ON public.announcement_tags USING btree (tag_id);

CREATE INDEX idx_announcement_tags_tenant_id ON public.announcement_tags USING btree (tenant_id);

CREATE INDEX idx_announcements_category_id ON public.announcements USING btree (category_id);

CREATE INDEX idx_announcements_created_by ON public.announcements USING btree (created_by);

CREATE INDEX idx_announcements_pagination ON public.announcements USING btree (status, created_at DESC);

CREATE INDEX idx_announcements_status ON public.announcements USING btree (status);

CREATE INDEX idx_announcements_tenant_id ON public.announcements USING btree (tenant_id);

CREATE INDEX idx_article_tags_article_id ON public.article_tags USING btree (article_id);

CREATE INDEX idx_article_tags_created_by ON public.article_tags USING btree (created_by);

CREATE INDEX idx_article_tags_tag_id ON public.article_tags USING btree (tag_id);

CREATE INDEX idx_article_tags_tenant_id ON public.article_tags USING btree (tenant_id);

CREATE INDEX idx_articles_author_id ON public.articles USING btree (author_id);

CREATE INDEX idx_articles_category_id ON public.articles USING btree (category_id);

CREATE INDEX idx_articles_created_by ON public.articles USING btree (created_by);

CREATE INDEX idx_articles_current_assignee_id ON public.articles USING btree (current_assignee_id);

CREATE INDEX idx_articles_deleted_at ON public.articles USING btree (deleted_at);

CREATE INDEX idx_articles_region ON public.articles USING btree (region_id);

CREATE INDEX idx_articles_status ON public.articles USING btree (status);

CREATE INDEX idx_articles_tenant_id ON public.articles USING btree (tenant_id);

CREATE INDEX idx_articles_tenant_slug ON public.articles USING btree (tenant_id, slug);

CREATE INDEX idx_articles_tenant_status ON public.articles USING btree (tenant_id, status);

CREATE INDEX idx_articles_workflow_state ON public.articles USING btree (workflow_state);

CREATE INDEX idx_audit_logs_action ON public.audit_logs USING btree (action);

CREATE INDEX idx_audit_logs_created_at ON public.audit_logs USING btree (created_at DESC);

CREATE INDEX idx_audit_logs_tenant_id ON public.audit_logs USING btree (tenant_id);

CREATE INDEX idx_audit_logs_user_id ON public.audit_logs USING btree (user_id);

CREATE INDEX idx_auth_hibp_events_created_by ON public.auth_hibp_events USING btree (created_by);

CREATE INDEX idx_auth_hibp_events_user_id ON public.auth_hibp_events USING btree (user_id);

CREATE INDEX idx_backup_logs_backup_id ON public.backup_logs USING btree (backup_id);

CREATE INDEX idx_backup_logs_created_by ON public.backup_logs USING btree (created_by);

CREATE INDEX idx_backup_logs_tenant_id ON public.backup_logs USING btree (tenant_id);

CREATE INDEX idx_backup_schedules_created_by ON public.backup_schedules USING btree (created_by);

CREATE INDEX idx_backup_schedules_tenant_id ON public.backup_schedules USING btree (tenant_id);

CREATE INDEX idx_backups_created_by ON public.backups USING btree (created_by);

CREATE INDEX idx_backups_tenant_id ON public.backups USING btree (tenant_id);

CREATE INDEX idx_cart_items_cart_id ON public.cart_items USING btree (cart_id);

CREATE INDEX idx_cart_items_product_id ON public.cart_items USING btree (product_id);

CREATE INDEX idx_cart_items_tenant_id ON public.cart_items USING btree (tenant_id);

CREATE INDEX idx_carts_session_id ON public.carts USING btree (session_id);

CREATE INDEX idx_carts_tenant_id ON public.carts USING btree (tenant_id);

CREATE INDEX idx_carts_user_id ON public.carts USING btree (user_id);

CREATE INDEX idx_categories_created_by ON public.categories USING btree (created_by);

CREATE INDEX idx_categories_deleted_at ON public.categories USING btree (deleted_at);

CREATE INDEX idx_categories_tenant_id ON public.categories USING btree (tenant_id);

CREATE INDEX idx_categories_tenant_slug ON public.categories USING btree (tenant_id, slug);

CREATE INDEX idx_categories_type ON public.categories USING btree (type);

CREATE INDEX idx_contact_message_tags_created_by ON public.contact_message_tags USING btree (created_by);

CREATE INDEX idx_contact_message_tags_message_id ON public.contact_message_tags USING btree (message_id);

CREATE INDEX idx_contact_message_tags_tag_id ON public.contact_message_tags USING btree (tag_id);

CREATE INDEX idx_contact_message_tags_tenant_id ON public.contact_message_tags USING btree (tenant_id);

CREATE INDEX idx_contact_messages_created_by ON public.contact_messages USING btree (created_by);

CREATE INDEX idx_contact_messages_tenant_id ON public.contact_messages USING btree (tenant_id);

CREATE INDEX idx_contact_tags_contact_id ON public.contact_tags USING btree (contact_id);

CREATE INDEX idx_contact_tags_created_by ON public.contact_tags USING btree (created_by);

CREATE INDEX idx_contact_tags_tag_id ON public.contact_tags USING btree (tag_id);

CREATE INDEX idx_contact_tags_tenant_id ON public.contact_tags USING btree (tenant_id);

CREATE INDEX idx_contacts_created_by ON public.contacts USING btree (created_by);

CREATE INDEX idx_contacts_tenant_id ON public.contacts USING btree (tenant_id);

CREATE INDEX idx_devices_device_id ON public.devices USING btree (device_id);

CREATE INDEX idx_devices_owner_id ON public.devices USING btree (owner_id);

CREATE INDEX idx_devices_tenant ON public.devices USING btree (tenant_id);

CREATE INDEX idx_email_logs_created_at ON public.email_logs USING btree (created_at DESC);

CREATE INDEX idx_email_logs_event_type ON public.email_logs USING btree (event_type);

CREATE INDEX idx_email_logs_recipient ON public.email_logs USING btree (recipient);

CREATE INDEX idx_email_logs_tenant ON public.email_logs USING btree (tenant_id);

CREATE INDEX idx_extension_logs_action ON public.extension_logs USING btree (action);

CREATE INDEX idx_extension_logs_created ON public.extension_logs USING btree (created_at DESC);

CREATE INDEX idx_extension_logs_extension ON public.extension_logs USING btree (extension_id);

CREATE INDEX idx_extension_logs_tenant ON public.extension_logs USING btree (tenant_id);

CREATE INDEX idx_extension_logs_user_id ON public.extension_logs USING btree (user_id);

CREATE INDEX idx_extension_menu_items_created_by ON public.extension_menu_items USING btree (created_by);

CREATE INDEX idx_extension_menu_items_extension_id ON public.extension_menu_items USING btree (extension_id);

CREATE INDEX idx_extension_menu_items_parent_id ON public.extension_menu_items USING btree (parent_id);

CREATE INDEX idx_extension_rbac_integration_created_by ON public.extension_rbac_integration USING btree (created_by);

CREATE INDEX idx_extension_rbac_integration_extension_id ON public.extension_rbac_integration USING btree (extension_id);

CREATE INDEX idx_extension_rbac_integration_permission_id ON public.extension_rbac_integration USING btree (permission_id);

CREATE INDEX idx_extension_rbac_integration_role_id ON public.extension_rbac_integration USING btree (role_id);

CREATE INDEX idx_extension_routes_created_by ON public.extension_routes USING btree (created_by);

CREATE INDEX idx_extension_routes_extension_id ON public.extension_routes USING btree (extension_id);

CREATE INDEX idx_extension_routes_registry_created_by ON public.extension_routes_registry USING btree (created_by);

CREATE INDEX idx_extension_routes_registry_extension_id ON public.extension_routes_registry USING btree (extension_id);

CREATE INDEX idx_extension_routes_tenant_id ON public.extension_routes USING btree (tenant_id);

CREATE INDEX idx_extensions_created_by ON public.extensions USING btree (created_by);

CREATE INDEX idx_extensions_tenant_id ON public.extensions USING btree (tenant_id);

CREATE INDEX idx_file_permissions_file_id ON public.file_permissions USING btree (file_id);

CREATE INDEX idx_file_permissions_tenant_id ON public.file_permissions USING btree (tenant_id);

CREATE INDEX idx_file_permissions_user_id ON public.file_permissions USING btree (user_id);

CREATE INDEX idx_files_tenant_id ON public.files USING btree (tenant_id);

CREATE INDEX idx_files_uploaded_by ON public.files USING btree (uploaded_by);

CREATE INDEX idx_menu_permissions_created_by ON public.menu_permissions USING btree (created_by);

CREATE INDEX idx_menu_permissions_menu_id ON public.menu_permissions USING btree (menu_id);

CREATE INDEX idx_menu_permissions_role_id ON public.menu_permissions USING btree (role_id);

CREATE INDEX idx_menu_permissions_tenant_id ON public.menu_permissions USING btree (tenant_id);

CREATE INDEX idx_menus_created_by ON public.menus USING btree (created_by);

CREATE INDEX idx_menus_parent_id ON public.menus USING btree (parent_id);

CREATE INDEX idx_menus_role_id ON public.menus USING btree (role_id);

CREATE INDEX idx_menus_tenant_id ON public.menus USING btree (tenant_id);

CREATE INDEX idx_mobile_app_config_updated_by ON public.mobile_app_config USING btree (updated_by);

CREATE INDEX idx_mobile_users_tenant ON public.mobile_users USING btree (tenant_id);

CREATE INDEX idx_mobile_users_user_id ON public.mobile_users USING btree (user_id);

CREATE INDEX idx_notifications_created_at ON public.notifications USING btree (created_at DESC);

CREATE INDEX idx_notifications_tenant_id ON public.notifications USING btree (tenant_id);

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);

CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);

CREATE INDEX idx_order_items_product_id ON public.order_items USING btree (product_id);

CREATE INDEX idx_order_items_tenant_id ON public.order_items USING btree (tenant_id);

CREATE INDEX idx_orders_created_at ON public.orders USING btree (created_at DESC);

CREATE INDEX idx_orders_payment_status ON public.orders USING btree (payment_status);

CREATE INDEX idx_orders_status ON public.orders USING btree (status);

CREATE INDEX idx_orders_tenant_id ON public.orders USING btree (tenant_id);

CREATE INDEX idx_orders_user_id ON public.orders USING btree (user_id);

CREATE INDEX idx_page_categories_category_id ON public.page_categories USING btree (category_id);

CREATE INDEX idx_page_categories_created_by ON public.page_categories USING btree (created_by);

CREATE INDEX idx_page_categories_page_id ON public.page_categories USING btree (page_id);

CREATE INDEX idx_page_categories_tenant_id ON public.page_categories USING btree (tenant_id);

CREATE INDEX idx_page_tags_created_by ON public.page_tags USING btree (created_by);

CREATE INDEX idx_page_tags_page_id ON public.page_tags USING btree (page_id);

CREATE INDEX idx_page_tags_tag_id ON public.page_tags USING btree (tag_id);

CREATE INDEX idx_page_tags_tenant_id ON public.page_tags USING btree (tenant_id);

CREATE INDEX idx_pages_category_id ON public.pages USING btree (category_id);

CREATE INDEX idx_pages_created_by ON public.pages USING btree (created_by);

CREATE INDEX idx_pages_current_assignee_id ON public.pages USING btree (current_assignee_id);

CREATE INDEX idx_pages_page_type ON public.pages USING btree (page_type);

CREATE INDEX idx_pages_pagination ON public.pages USING btree (status, updated_at DESC);

CREATE INDEX idx_pages_parent_id ON public.pages USING btree (parent_id);

CREATE INDEX idx_pages_status ON public.pages USING btree (status);

CREATE INDEX idx_pages_status_deleted_at ON public.pages USING btree (status, deleted_at);

CREATE INDEX idx_pages_tenant_id ON public.pages USING btree (tenant_id);

CREATE INDEX idx_pages_tenant_slug ON public.pages USING btree (tenant_id, slug);

CREATE UNIQUE INDEX idx_pages_unique_system_type ON public.pages USING btree (page_type) WHERE ((page_type = ANY (ARRAY['homepage'::text, 'header'::text, 'footer'::text, '404'::text])) AND (status = 'published'::text) AND (deleted_at IS NULL));

CREATE INDEX idx_pages_updated_at ON public.pages USING btree (updated_at DESC);

CREATE INDEX idx_payment_methods_tenant_id ON public.payment_methods USING btree (tenant_id);

CREATE INDEX idx_payments_order_id ON public.payments USING btree (order_id);

CREATE INDEX idx_payments_payment_method_id ON public.payments USING btree (payment_method_id);

CREATE INDEX idx_payments_status ON public.payments USING btree (status);

CREATE INDEX idx_payments_tenant_id ON public.payments USING btree (tenant_id);

CREATE INDEX idx_permissions_created_by ON public.permissions USING btree (created_by);

CREATE INDEX idx_permissions_resource ON public.permissions USING btree (resource);

CREATE INDEX idx_photo_gallery_category_id ON public.photo_gallery USING btree (category_id);

CREATE INDEX idx_photo_gallery_created_by ON public.photo_gallery USING btree (created_by);

CREATE INDEX idx_photo_gallery_pagination ON public.photo_gallery USING btree (status, created_at DESC);

CREATE INDEX idx_photo_gallery_tags_created_by ON public.photo_gallery_tags USING btree (created_by);

CREATE INDEX idx_photo_gallery_tags_photo_gallery_id ON public.photo_gallery_tags USING btree (photo_gallery_id);

CREATE INDEX idx_photo_gallery_tags_tag_id ON public.photo_gallery_tags USING btree (tag_id);

CREATE INDEX idx_photo_gallery_tags_tenant_id ON public.photo_gallery_tags USING btree (tenant_id);

CREATE INDEX idx_photo_gallery_tenant_id ON public.photo_gallery USING btree (tenant_id);

CREATE INDEX idx_portfolio_category_id ON public.portfolio USING btree (category_id);

CREATE INDEX idx_portfolio_created_by ON public.portfolio USING btree (created_by);

CREATE INDEX idx_portfolio_pagination ON public.portfolio USING btree (status, created_at DESC);

CREATE INDEX idx_portfolio_tags_created_by ON public.portfolio_tags USING btree (created_by);

CREATE INDEX idx_portfolio_tags_portfolio_id ON public.portfolio_tags USING btree (portfolio_id);

CREATE INDEX idx_portfolio_tags_tag_id ON public.portfolio_tags USING btree (tag_id);

CREATE INDEX idx_portfolio_tags_tenant_id ON public.portfolio_tags USING btree (tenant_id);

CREATE INDEX idx_portfolio_tenant_id ON public.portfolio USING btree (tenant_id);

CREATE INDEX idx_product_tags_created_by ON public.product_tags USING btree (created_by);

CREATE INDEX idx_product_tags_product_id ON public.product_tags USING btree (product_id);

CREATE INDEX idx_product_tags_tag_id ON public.product_tags USING btree (tag_id);

CREATE INDEX idx_product_tags_tenant_id ON public.product_tags USING btree (tenant_id);

CREATE INDEX idx_product_type_tags_created_by ON public.product_type_tags USING btree (created_by);

CREATE INDEX idx_product_type_tags_product_type_id ON public.product_type_tags USING btree (product_type_id);

CREATE INDEX idx_product_type_tags_tag_id ON public.product_type_tags USING btree (tag_id);

CREATE INDEX idx_product_type_tags_tenant_id ON public.product_type_tags USING btree (tenant_id);

CREATE INDEX idx_product_types_created_by ON public.product_types USING btree (created_by);

CREATE INDEX idx_product_types_deleted_at ON public.product_types USING btree (deleted_at);

CREATE INDEX idx_product_types_tenant_id ON public.product_types USING btree (tenant_id);

CREATE INDEX idx_products_category_id ON public.products USING btree (category_id);

CREATE INDEX idx_products_created_by ON public.products USING btree (created_by);

CREATE INDEX idx_products_pagination ON public.products USING btree (status, created_at DESC);

CREATE INDEX idx_products_product_type_id ON public.products USING btree (product_type_id);

CREATE INDEX idx_products_status ON public.products USING btree (status);

CREATE INDEX idx_products_tenant_id ON public.products USING btree (tenant_id);

CREATE INDEX idx_products_tenant_slug ON public.products USING btree (tenant_id, slug);

CREATE INDEX idx_products_tenant_status ON public.products USING btree (tenant_id, status);

CREATE INDEX idx_promotion_tags_created_by ON public.promotion_tags USING btree (created_by);

CREATE INDEX idx_promotion_tags_promotion_id ON public.promotion_tags USING btree (promotion_id);

CREATE INDEX idx_promotion_tags_tag_id ON public.promotion_tags USING btree (tag_id);

CREATE INDEX idx_promotion_tags_tenant_id ON public.promotion_tags USING btree (tenant_id);

CREATE INDEX idx_promotions_category_id ON public.promotions USING btree (category_id);

CREATE INDEX idx_promotions_created_by ON public.promotions USING btree (created_by);

CREATE INDEX idx_promotions_pagination ON public.promotions USING btree (status, created_at DESC);

CREATE INDEX idx_promotions_status ON public.promotions USING btree (status);

CREATE INDEX idx_promotions_tenant_id ON public.promotions USING btree (tenant_id);

CREATE INDEX idx_push_notifications_created_by ON public.push_notifications USING btree (created_by);

CREATE INDEX idx_push_notifications_tenant ON public.push_notifications USING btree (tenant_id);

CREATE INDEX idx_regions_code ON public.regions USING btree (code);

CREATE INDEX idx_regions_level ON public.regions USING btree (level_id);

CREATE INDEX idx_regions_parent ON public.regions USING btree (parent_id);

CREATE INDEX idx_regions_tenant ON public.regions USING btree (tenant_id);

CREATE INDEX idx_role_permissions_created_by ON public.role_permissions USING btree (created_by);

CREATE INDEX idx_role_permissions_permission_id ON public.role_permissions USING btree (permission_id);

CREATE INDEX idx_role_permissions_role_id ON public.role_permissions USING btree (role_id);

CREATE INDEX idx_role_permissions_tenant_id ON public.role_permissions USING btree (tenant_id);

CREATE INDEX idx_role_policies_role_id ON public.role_policies USING btree (role_id);

CREATE INDEX idx_roles_created_by ON public.roles USING btree (created_by);

CREATE INDEX idx_sensor_readings_device ON public.sensor_readings USING btree (device_id);

CREATE INDEX idx_sensor_readings_tenant ON public.sensor_readings USING btree (tenant_id);

CREATE UNIQUE INDEX idx_seo_items ON public.seo_metadata USING btree (resource_type, resource_id) WHERE (resource_id IS NOT NULL);

CREATE UNIQUE INDEX idx_seo_main_pages ON public.seo_metadata USING btree (resource_type) WHERE (resource_id IS NULL);

CREATE INDEX idx_seo_metadata_created_by ON public.seo_metadata USING btree (created_by);

CREATE INDEX idx_seo_metadata_tenant_id ON public.seo_metadata USING btree (tenant_id);

CREATE INDEX idx_settings_tenant_id ON public.settings USING btree (tenant_id);

CREATE INDEX idx_sso_audit_logs_tenant_id ON public.sso_audit_logs USING btree (tenant_id);

CREATE INDEX idx_sso_audit_logs_user_id ON public.sso_audit_logs USING btree (user_id);

CREATE INDEX idx_sso_providers_created_by ON public.sso_providers USING btree (created_by);

CREATE INDEX idx_sso_providers_tenant_id ON public.sso_providers USING btree (tenant_id);

CREATE INDEX idx_sso_role_mappings_created_by ON public.sso_role_mappings USING btree (created_by);

CREATE INDEX idx_sso_role_mappings_internal_role_id ON public.sso_role_mappings USING btree (internal_role_id);

CREATE INDEX idx_sso_role_mappings_provider ON public.sso_role_mappings USING btree (provider_id);

CREATE INDEX idx_tags_created_by ON public.tags USING btree (created_by);

CREATE INDEX idx_tags_is_active ON public.tags USING btree (is_active) WHERE (deleted_at IS NULL);

CREATE INDEX idx_tags_slug ON public.tags USING btree (slug);

CREATE INDEX idx_tags_tenant_id ON public.tags USING btree (tenant_id);

CREATE UNIQUE INDEX idx_tags_tenant_slug ON public.tags USING btree (tenant_id, slug);

CREATE INDEX idx_tenants_host ON public.tenants USING btree (host);

CREATE INDEX idx_testimonies_category_id ON public.testimonies USING btree (category_id);

CREATE INDEX idx_testimonies_created_by ON public.testimonies USING btree (created_by);

CREATE INDEX idx_testimonies_published_at ON public.testimonies USING btree (published_at);

CREATE INDEX idx_testimonies_status ON public.testimonies USING btree (status);

CREATE INDEX idx_testimonies_tenant_id ON public.testimonies USING btree (tenant_id);

CREATE INDEX idx_testimony_tags_created_by ON public.testimony_tags USING btree (created_by);

CREATE INDEX idx_testimony_tags_tag_id ON public.testimony_tags USING btree (tag_id);

CREATE INDEX idx_testimony_tags_tenant_id ON public.testimony_tags USING btree (tenant_id);

CREATE INDEX idx_testimony_tags_testimony_id ON public.testimony_tags USING btree (testimony_id);

CREATE INDEX idx_themes_created_by ON public.themes USING btree (created_by);

CREATE INDEX idx_themes_tenant_id ON public.themes USING btree (tenant_id);

CREATE INDEX idx_two_factor_audit_logs_tenant_id ON public.two_factor_audit_logs USING btree (tenant_id);

CREATE INDEX idx_two_factor_auth_tenant_id ON public.two_factor_auth USING btree (tenant_id);

CREATE INDEX idx_users_created_at ON public.users USING btree (created_at DESC);

CREATE INDEX idx_users_created_by ON public.users USING btree (created_by);

CREATE INDEX idx_users_deleted_at ON public.users USING btree (deleted_at);

CREATE INDEX idx_users_region ON public.users USING btree (region_id);

CREATE INDEX idx_users_role_id ON public.users USING btree (role_id);

CREATE INDEX idx_users_tenant_role ON public.users USING btree (tenant_id, role_id);

CREATE INDEX idx_video_gallery_category_id ON public.video_gallery USING btree (category_id);

CREATE INDEX idx_video_gallery_created_by ON public.video_gallery USING btree (created_by);

CREATE INDEX idx_video_gallery_tags_created_by ON public.video_gallery_tags USING btree (created_by);

CREATE INDEX idx_video_gallery_tags_tag_id ON public.video_gallery_tags USING btree (tag_id);

CREATE INDEX idx_video_gallery_tags_tenant_id ON public.video_gallery_tags USING btree (tenant_id);

CREATE INDEX idx_video_gallery_tags_video_gallery_id ON public.video_gallery_tags USING btree (video_gallery_id);

CREATE INDEX idx_video_gallery_tenant_id ON public.video_gallery USING btree (tenant_id);

CREATE UNIQUE INDEX menu_permissions_menu_id_role_id_key ON public.menu_permissions USING btree (menu_id, role_id);

CREATE UNIQUE INDEX menu_permissions_pkey ON public.menu_permissions USING btree (id);

CREATE UNIQUE INDEX mobile_app_config_pkey ON public.mobile_app_config USING btree (id);

CREATE UNIQUE INDEX mobile_app_config_tenant_id_key ON public.mobile_app_config USING btree (tenant_id);

CREATE UNIQUE INDEX mobile_users_pkey ON public.mobile_users USING btree (id);

CREATE UNIQUE INDEX notification_readers_notification_id_user_id_key ON public.notification_readers USING btree (notification_id, user_id);

CREATE UNIQUE INDEX notification_readers_pkey ON public.notification_readers USING btree (id);

CREATE INDEX notification_readers_user_id_idx ON public.notification_readers USING btree (user_id);

CREATE INDEX notifications_created_by_idx ON public.notifications USING btree (created_by);

CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id);

CREATE UNIQUE INDEX order_items_pkey ON public.order_items USING btree (id);

CREATE UNIQUE INDEX orders_pkey ON public.orders USING btree (id);

CREATE UNIQUE INDEX page_categories_pkey ON public.page_categories USING btree (page_id, category_id);

CREATE UNIQUE INDEX page_tags_pkey ON public.page_tags USING btree (page_id, tag_id);

CREATE UNIQUE INDEX pages_pkey ON public.pages USING btree (id);

CREATE UNIQUE INDEX pages_slug_key ON public.pages USING btree (slug);

CREATE UNIQUE INDEX payment_methods_pkey ON public.payment_methods USING btree (id);

CREATE UNIQUE INDEX payments_pkey ON public.payments USING btree (id);

CREATE UNIQUE INDEX photo_gallery_pkey ON public.photo_gallery USING btree (id);

CREATE UNIQUE INDEX photo_gallery_slug_key ON public.photo_gallery USING btree (slug);

CREATE UNIQUE INDEX photo_gallery_tags_pkey ON public.photo_gallery_tags USING btree (photo_gallery_id, tag_id);

CREATE UNIQUE INDEX portfolio_pkey ON public.portfolio USING btree (id);

CREATE UNIQUE INDEX portfolio_slug_key ON public.portfolio USING btree (slug);

CREATE UNIQUE INDEX portfolio_tags_pkey ON public.portfolio_tags USING btree (portfolio_id, tag_id);

CREATE UNIQUE INDEX product_tags_pkey ON public.product_tags USING btree (product_id, tag_id);

CREATE UNIQUE INDEX product_type_tags_pkey ON public.product_type_tags USING btree (product_type_id, tag_id);

CREATE UNIQUE INDEX product_types_pkey ON public.product_types USING btree (id);

CREATE UNIQUE INDEX product_types_slug_key ON public.product_types USING btree (slug);

CREATE UNIQUE INDEX products_pkey ON public.products USING btree (id);

CREATE UNIQUE INDEX products_slug_key ON public.products USING btree (slug);

CREATE UNIQUE INDEX promotion_tags_pkey ON public.promotion_tags USING btree (promotion_id, tag_id);

CREATE UNIQUE INDEX promotions_code_key ON public.promotions USING btree (code);

CREATE UNIQUE INDEX promotions_pkey ON public.promotions USING btree (id);

CREATE UNIQUE INDEX push_notifications_pkey ON public.push_notifications USING btree (id);

CREATE UNIQUE INDEX region_levels_key_key ON public.region_levels USING btree (key);

CREATE UNIQUE INDEX region_levels_pkey ON public.region_levels USING btree (id);

CREATE UNIQUE INDEX regions_pkey ON public.regions USING btree (id);

CREATE UNIQUE INDEX role_permissions_role_id_permission_id_key ON public.role_permissions USING btree (role_id, permission_id);

CREATE UNIQUE INDEX sensor_readings_pkey ON public.sensor_readings USING btree (id);

CREATE UNIQUE INDEX seo_metadata_pkey ON public.seo_metadata USING btree (id);

CREATE UNIQUE INDEX seo_metadata_resource_type_resource_id_key ON public.seo_metadata USING btree (resource_type, resource_id);

CREATE UNIQUE INDEX seo_metadata_unique_idx ON public.seo_metadata USING btree (resource_type, COALESCE(resource_id, '00000000-0000-0000-0000-000000000000'::uuid));

CREATE UNIQUE INDEX settings_pkey ON public.settings USING btree (tenant_id, key);

CREATE UNIQUE INDEX sso_audit_logs_pkey ON public.sso_audit_logs USING btree (id);

CREATE UNIQUE INDEX sso_providers_pkey ON public.sso_providers USING btree (id);

CREATE UNIQUE INDEX sso_role_mappings_pkey ON public.sso_role_mappings USING btree (id);

CREATE UNIQUE INDEX tags_pkey ON public.tags USING btree (id);

CREATE UNIQUE INDEX tenants_host_key ON public.tenants USING btree (host);

CREATE UNIQUE INDEX testimonies_pkey ON public.testimonies USING btree (id);

CREATE UNIQUE INDEX testimonies_slug_key ON public.testimonies USING btree (slug);

CREATE UNIQUE INDEX testimony_tags_pkey ON public.testimony_tags USING btree (testimony_id, tag_id);

CREATE UNIQUE INDEX themes_pkey ON public.themes USING btree (id);

CREATE UNIQUE INDEX themes_slug_key ON public.themes USING btree (slug);

CREATE UNIQUE INDEX two_factor_audit_logs_pkey ON public.two_factor_audit_logs USING btree (id);

CREATE INDEX two_factor_audit_logs_user_id_idx ON public.two_factor_audit_logs USING btree (user_id);

CREATE UNIQUE INDEX two_factor_auth_pkey ON public.two_factor_auth USING btree (id);

CREATE UNIQUE INDEX unique_user_2fa ON public.two_factor_auth USING btree (user_id);

CREATE UNIQUE INDEX video_gallery_pkey ON public.video_gallery USING btree (id);

CREATE UNIQUE INDEX video_gallery_slug_key ON public.video_gallery USING btree (slug);

CREATE UNIQUE INDEX video_gallery_tags_pkey ON public.video_gallery_tags USING btree (video_gallery_id, tag_id);

CREATE UNIQUE INDEX role_permissions_pkey ON public.role_permissions USING btree (id);

alter table "public"."announcement_tags" add constraint "announcement_tags_pkey" PRIMARY KEY using index "announcement_tags_pkey";

alter table "public"."announcements" add constraint "announcements_pkey" PRIMARY KEY using index "announcements_pkey";

alter table "public"."article_tags" add constraint "article_tags_pkey" PRIMARY KEY using index "article_tags_pkey";

alter table "public"."articles" add constraint "articles_pkey" PRIMARY KEY using index "articles_pkey";

alter table "public"."auth_hibp_events" add constraint "auth_hibp_events_pkey" PRIMARY KEY using index "auth_hibp_events_pkey";

alter table "public"."backup_logs" add constraint "backup_logs_pkey" PRIMARY KEY using index "backup_logs_pkey";

alter table "public"."backup_schedules" add constraint "backup_schedules_pkey" PRIMARY KEY using index "backup_schedules_pkey";

alter table "public"."backups" add constraint "backups_pkey" PRIMARY KEY using index "backups_pkey";

alter table "public"."cart_items" add constraint "cart_items_pkey" PRIMARY KEY using index "cart_items_pkey";

alter table "public"."carts" add constraint "carts_pkey" PRIMARY KEY using index "carts_pkey";

alter table "public"."categories" add constraint "categories_pkey" PRIMARY KEY using index "categories_pkey";

alter table "public"."contact_message_tags" add constraint "contact_message_tags_pkey" PRIMARY KEY using index "contact_message_tags_pkey";

alter table "public"."contact_messages" add constraint "contact_messages_pkey" PRIMARY KEY using index "contact_messages_pkey";

alter table "public"."contact_tags" add constraint "contact_tags_pkey" PRIMARY KEY using index "contact_tags_pkey";

alter table "public"."contacts" add constraint "contacts_pkey" PRIMARY KEY using index "contacts_pkey";

alter table "public"."devices" add constraint "devices_pkey" PRIMARY KEY using index "devices_pkey";

alter table "public"."email_logs" add constraint "email_logs_pkey" PRIMARY KEY using index "email_logs_pkey";

alter table "public"."extension_logs" add constraint "extension_logs_pkey" PRIMARY KEY using index "extension_logs_pkey";

alter table "public"."extension_menu_items" add constraint "extension_menu_items_pkey" PRIMARY KEY using index "extension_menu_items_pkey";

alter table "public"."extension_permissions" add constraint "extension_permissions_pkey" PRIMARY KEY using index "extension_permissions_pkey";

alter table "public"."extension_rbac_integration" add constraint "extension_rbac_integration_pkey" PRIMARY KEY using index "extension_rbac_integration_pkey";

alter table "public"."extension_routes" add constraint "extension_routes_pkey" PRIMARY KEY using index "extension_routes_pkey";

alter table "public"."extension_routes_registry" add constraint "extension_routes_registry_pkey" PRIMARY KEY using index "extension_routes_registry_pkey";

alter table "public"."extensions" add constraint "extensions_pkey" PRIMARY KEY using index "extensions_pkey";

alter table "public"."file_permissions" add constraint "file_permissions_pkey" PRIMARY KEY using index "file_permissions_pkey";

alter table "public"."files" add constraint "files_pkey" PRIMARY KEY using index "files_pkey";

alter table "public"."menu_permissions" add constraint "menu_permissions_pkey" PRIMARY KEY using index "menu_permissions_pkey";

alter table "public"."mobile_app_config" add constraint "mobile_app_config_pkey" PRIMARY KEY using index "mobile_app_config_pkey";

alter table "public"."mobile_users" add constraint "mobile_users_pkey" PRIMARY KEY using index "mobile_users_pkey";

alter table "public"."notification_readers" add constraint "notification_readers_pkey" PRIMARY KEY using index "notification_readers_pkey";

alter table "public"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "public"."order_items" add constraint "order_items_pkey" PRIMARY KEY using index "order_items_pkey";

alter table "public"."orders" add constraint "orders_pkey" PRIMARY KEY using index "orders_pkey";

alter table "public"."page_categories" add constraint "page_categories_pkey" PRIMARY KEY using index "page_categories_pkey";

alter table "public"."page_tags" add constraint "page_tags_pkey" PRIMARY KEY using index "page_tags_pkey";

alter table "public"."pages" add constraint "pages_pkey" PRIMARY KEY using index "pages_pkey";

alter table "public"."payment_methods" add constraint "payment_methods_pkey" PRIMARY KEY using index "payment_methods_pkey";

alter table "public"."payments" add constraint "payments_pkey" PRIMARY KEY using index "payments_pkey";

alter table "public"."photo_gallery" add constraint "photo_gallery_pkey" PRIMARY KEY using index "photo_gallery_pkey";

alter table "public"."photo_gallery_tags" add constraint "photo_gallery_tags_pkey" PRIMARY KEY using index "photo_gallery_tags_pkey";

alter table "public"."portfolio" add constraint "portfolio_pkey" PRIMARY KEY using index "portfolio_pkey";

alter table "public"."portfolio_tags" add constraint "portfolio_tags_pkey" PRIMARY KEY using index "portfolio_tags_pkey";

alter table "public"."product_tags" add constraint "product_tags_pkey" PRIMARY KEY using index "product_tags_pkey";

alter table "public"."product_type_tags" add constraint "product_type_tags_pkey" PRIMARY KEY using index "product_type_tags_pkey";

alter table "public"."product_types" add constraint "product_types_pkey" PRIMARY KEY using index "product_types_pkey";

alter table "public"."products" add constraint "products_pkey" PRIMARY KEY using index "products_pkey";

alter table "public"."promotion_tags" add constraint "promotion_tags_pkey" PRIMARY KEY using index "promotion_tags_pkey";

alter table "public"."promotions" add constraint "promotions_pkey" PRIMARY KEY using index "promotions_pkey";

alter table "public"."push_notifications" add constraint "push_notifications_pkey" PRIMARY KEY using index "push_notifications_pkey";

alter table "public"."region_levels" add constraint "region_levels_pkey" PRIMARY KEY using index "region_levels_pkey";

alter table "public"."regions" add constraint "regions_pkey" PRIMARY KEY using index "regions_pkey";

alter table "public"."sensor_readings" add constraint "sensor_readings_pkey" PRIMARY KEY using index "sensor_readings_pkey";

alter table "public"."seo_metadata" add constraint "seo_metadata_pkey" PRIMARY KEY using index "seo_metadata_pkey";

alter table "public"."settings" add constraint "settings_pkey" PRIMARY KEY using index "settings_pkey";

alter table "public"."sso_audit_logs" add constraint "sso_audit_logs_pkey" PRIMARY KEY using index "sso_audit_logs_pkey";

alter table "public"."sso_providers" add constraint "sso_providers_pkey" PRIMARY KEY using index "sso_providers_pkey";

alter table "public"."sso_role_mappings" add constraint "sso_role_mappings_pkey" PRIMARY KEY using index "sso_role_mappings_pkey";

alter table "public"."tags" add constraint "tags_pkey" PRIMARY KEY using index "tags_pkey";

alter table "public"."testimonies" add constraint "testimonies_pkey" PRIMARY KEY using index "testimonies_pkey";

alter table "public"."testimony_tags" add constraint "testimony_tags_pkey" PRIMARY KEY using index "testimony_tags_pkey";

alter table "public"."themes" add constraint "themes_pkey" PRIMARY KEY using index "themes_pkey";

alter table "public"."two_factor_audit_logs" add constraint "two_factor_audit_logs_pkey" PRIMARY KEY using index "two_factor_audit_logs_pkey";

alter table "public"."two_factor_auth" add constraint "two_factor_auth_pkey" PRIMARY KEY using index "two_factor_auth_pkey";

alter table "public"."video_gallery" add constraint "video_gallery_pkey" PRIMARY KEY using index "video_gallery_pkey";

alter table "public"."video_gallery_tags" add constraint "video_gallery_tags_pkey" PRIMARY KEY using index "video_gallery_tags_pkey";

alter table "public"."role_permissions" add constraint "role_permissions_pkey" PRIMARY KEY using index "role_permissions_pkey";

alter table "public"."announcement_tags" add constraint "announcement_tags_announcement_id_fkey" FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE not valid;

alter table "public"."announcement_tags" validate constraint "announcement_tags_announcement_id_fkey";

alter table "public"."announcement_tags" add constraint "announcement_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."announcement_tags" validate constraint "announcement_tags_tag_id_fkey";

alter table "public"."announcement_tags" add constraint "announcement_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."announcement_tags" validate constraint "announcement_tags_tenant_id_fkey";

alter table "public"."announcements" add constraint "announcements_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) not valid;

alter table "public"."announcements" validate constraint "announcements_category_id_fkey";

alter table "public"."announcements" add constraint "announcements_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."announcements" validate constraint "announcements_created_by_fkey";

alter table "public"."announcements" add constraint "announcements_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."announcements" validate constraint "announcements_tenant_id_fkey";

alter table "public"."article_tags" add constraint "article_tags_article_id_fkey" FOREIGN KEY (article_id) REFERENCES public.articles(id) ON DELETE CASCADE not valid;

alter table "public"."article_tags" validate constraint "article_tags_article_id_fkey";

alter table "public"."article_tags" add constraint "article_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."article_tags" validate constraint "article_tags_tag_id_fkey";

alter table "public"."article_tags" add constraint "article_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."article_tags" validate constraint "article_tags_tenant_id_fkey";

alter table "public"."articles" add constraint "articles_author_id_fkey" FOREIGN KEY (author_id) REFERENCES public.users(id) not valid;

alter table "public"."articles" validate constraint "articles_author_id_fkey";

alter table "public"."articles" add constraint "articles_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) not valid;

alter table "public"."articles" validate constraint "articles_category_id_fkey";

alter table "public"."articles" add constraint "articles_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."articles" validate constraint "articles_created_by_fkey";

alter table "public"."articles" add constraint "articles_current_assignee_id_fkey" FOREIGN KEY (current_assignee_id) REFERENCES public.users(id) not valid;

alter table "public"."articles" validate constraint "articles_current_assignee_id_fkey";

alter table "public"."articles" add constraint "articles_region_id_fkey" FOREIGN KEY (region_id) REFERENCES public.regions(id) ON DELETE SET NULL not valid;

alter table "public"."articles" validate constraint "articles_region_id_fkey";

alter table "public"."articles" add constraint "articles_slug_key" UNIQUE using index "articles_slug_key";

alter table "public"."articles" add constraint "articles_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."articles" validate constraint "articles_tenant_id_fkey";

alter table "public"."auth_hibp_events" add constraint "auth_hibp_events_event_type_check" CHECK ((event_type = ANY (ARRAY['blocked'::text, 'allowed'::text]))) not valid;

alter table "public"."auth_hibp_events" validate constraint "auth_hibp_events_event_type_check";

alter table "public"."auth_hibp_events" add constraint "auth_hibp_events_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."auth_hibp_events" validate constraint "auth_hibp_events_user_id_fkey";

alter table "public"."backup_logs" add constraint "backup_logs_backup_id_fkey" FOREIGN KEY (backup_id) REFERENCES public.backups(id) ON DELETE SET NULL not valid;

alter table "public"."backup_logs" validate constraint "backup_logs_backup_id_fkey";

alter table "public"."backup_logs" add constraint "backup_logs_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."backup_logs" validate constraint "backup_logs_tenant_id_fkey";

alter table "public"."backup_schedules" add constraint "backup_schedules_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."backup_schedules" validate constraint "backup_schedules_created_by_fkey";

alter table "public"."backup_schedules" add constraint "backup_schedules_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."backup_schedules" validate constraint "backup_schedules_tenant_id_fkey";

alter table "public"."backups" add constraint "backups_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."backups" validate constraint "backups_created_by_fkey";

alter table "public"."backups" add constraint "backups_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."backups" validate constraint "backups_tenant_id_fkey";

alter table "public"."cart_items" add constraint "cart_items_cart_id_fkey" FOREIGN KEY (cart_id) REFERENCES public.carts(id) ON DELETE CASCADE not valid;

alter table "public"."cart_items" validate constraint "cart_items_cart_id_fkey";

alter table "public"."cart_items" add constraint "cart_items_cart_id_product_id_key" UNIQUE using index "cart_items_cart_id_product_id_key";

alter table "public"."cart_items" add constraint "cart_items_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE not valid;

alter table "public"."cart_items" validate constraint "cart_items_product_id_fkey";

alter table "public"."cart_items" add constraint "cart_items_quantity_check" CHECK ((quantity > 0)) not valid;

alter table "public"."cart_items" validate constraint "cart_items_quantity_check";

alter table "public"."cart_items" add constraint "cart_items_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."cart_items" validate constraint "cart_items_tenant_id_fkey";

alter table "public"."carts" add constraint "carts_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'abandoned'::text, 'converted'::text]))) not valid;

alter table "public"."carts" validate constraint "carts_status_check";

alter table "public"."carts" add constraint "carts_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."carts" validate constraint "carts_tenant_id_fkey";

alter table "public"."carts" add constraint "carts_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL not valid;

alter table "public"."carts" validate constraint "carts_user_id_fkey";

alter table "public"."categories" add constraint "categories_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."categories" validate constraint "categories_created_by_fkey";

alter table "public"."categories" add constraint "categories_slug_key" UNIQUE using index "categories_slug_key";

alter table "public"."categories" add constraint "categories_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."categories" validate constraint "categories_tenant_id_fkey";

alter table "public"."contact_message_tags" add constraint "contact_message_tags_message_id_fkey" FOREIGN KEY (message_id) REFERENCES public.contact_messages(id) ON DELETE CASCADE not valid;

alter table "public"."contact_message_tags" validate constraint "contact_message_tags_message_id_fkey";

alter table "public"."contact_message_tags" add constraint "contact_message_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."contact_message_tags" validate constraint "contact_message_tags_tag_id_fkey";

alter table "public"."contact_message_tags" add constraint "contact_message_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."contact_message_tags" validate constraint "contact_message_tags_tenant_id_fkey";

alter table "public"."contact_messages" add constraint "contact_messages_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."contact_messages" validate constraint "contact_messages_created_by_fkey";

alter table "public"."contact_messages" add constraint "contact_messages_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."contact_messages" validate constraint "contact_messages_tenant_id_fkey";

alter table "public"."contact_tags" add constraint "contact_tags_contact_id_fkey" FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE CASCADE not valid;

alter table "public"."contact_tags" validate constraint "contact_tags_contact_id_fkey";

alter table "public"."contact_tags" add constraint "contact_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."contact_tags" validate constraint "contact_tags_tag_id_fkey";

alter table "public"."contact_tags" add constraint "contact_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."contact_tags" validate constraint "contact_tags_tenant_id_fkey";

alter table "public"."contacts" add constraint "contacts_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."contacts" validate constraint "contacts_created_by_fkey";

alter table "public"."contacts" add constraint "contacts_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."contacts" validate constraint "contacts_tenant_id_fkey";

alter table "public"."devices" add constraint "devices_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES auth.users(id) not valid;

alter table "public"."devices" validate constraint "devices_owner_id_fkey";

alter table "public"."devices" add constraint "devices_tenant_id_device_id_key" UNIQUE using index "devices_tenant_id_device_id_key";

alter table "public"."devices" add constraint "devices_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."devices" validate constraint "devices_tenant_id_fkey";

alter table "public"."email_logs" add constraint "email_logs_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."email_logs" validate constraint "email_logs_tenant_id_fkey";

alter table "public"."extension_logs" add constraint "extension_logs_action_check" CHECK ((action = ANY (ARRAY['install'::text, 'uninstall'::text, 'activate'::text, 'deactivate'::text, 'update'::text, 'config_change'::text, 'error'::text]))) not valid;

alter table "public"."extension_logs" validate constraint "extension_logs_action_check";

alter table "public"."extension_logs" add constraint "extension_logs_extension_id_fkey" FOREIGN KEY (extension_id) REFERENCES public.extensions(id) ON DELETE SET NULL not valid;

alter table "public"."extension_logs" validate constraint "extension_logs_extension_id_fkey";

alter table "public"."extension_logs" add constraint "extension_logs_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."extension_logs" validate constraint "extension_logs_tenant_id_fkey";

alter table "public"."extension_logs" add constraint "extension_logs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."extension_logs" validate constraint "extension_logs_user_id_fkey";

alter table "public"."extension_menu_items" add constraint "extension_menu_items_extension_id_fkey" FOREIGN KEY (extension_id) REFERENCES public.extensions(id) ON DELETE CASCADE not valid;

alter table "public"."extension_menu_items" validate constraint "extension_menu_items_extension_id_fkey";

alter table "public"."extension_permissions" add constraint "extension_permissions_ext_perm_key" UNIQUE using index "extension_permissions_ext_perm_key";

alter table "public"."extension_permissions" add constraint "extension_permissions_extension_id_fkey" FOREIGN KEY (extension_id) REFERENCES public.extensions(id) ON DELETE CASCADE not valid;

alter table "public"."extension_permissions" validate constraint "extension_permissions_extension_id_fkey";

alter table "public"."extension_rbac_integration" add constraint "extension_rbac_integration_extension_id_fkey" FOREIGN KEY (extension_id) REFERENCES public.extensions(id) ON DELETE CASCADE not valid;

alter table "public"."extension_rbac_integration" validate constraint "extension_rbac_integration_extension_id_fkey";

alter table "public"."extension_rbac_integration" add constraint "extension_rbac_integration_extension_id_role_id_permission__key" UNIQUE using index "extension_rbac_integration_extension_id_role_id_permission__key";

alter table "public"."extension_rbac_integration" add constraint "extension_rbac_integration_permission_id_fkey" FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE not valid;

alter table "public"."extension_rbac_integration" validate constraint "extension_rbac_integration_permission_id_fkey";

alter table "public"."extension_rbac_integration" add constraint "extension_rbac_integration_role_id_fkey" FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE not valid;

alter table "public"."extension_rbac_integration" validate constraint "extension_rbac_integration_role_id_fkey";

alter table "public"."extension_routes" add constraint "extension_routes_extension_id_fkey" FOREIGN KEY (extension_id) REFERENCES public.extensions(id) ON DELETE CASCADE not valid;

alter table "public"."extension_routes" validate constraint "extension_routes_extension_id_fkey";

alter table "public"."extension_routes" add constraint "extension_routes_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."extension_routes" validate constraint "extension_routes_tenant_id_fkey";

alter table "public"."extension_routes_registry" add constraint "extension_routes_registry_extension_id_fkey" FOREIGN KEY (extension_id) REFERENCES public.extensions(id) ON DELETE CASCADE not valid;

alter table "public"."extension_routes_registry" validate constraint "extension_routes_registry_extension_id_fkey";

alter table "public"."extensions" add constraint "extensions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."extensions" validate constraint "extensions_created_by_fkey";

alter table "public"."extensions" add constraint "extensions_extension_type_check" CHECK ((extension_type = ANY (ARRAY['core'::text, 'external'::text]))) not valid;

alter table "public"."extensions" validate constraint "extensions_extension_type_check";

alter table "public"."extensions" add constraint "extensions_slug_key" UNIQUE using index "extensions_slug_key";

alter table "public"."extensions" add constraint "extensions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."extensions" validate constraint "extensions_tenant_id_fkey";

alter table "public"."file_permissions" add constraint "file_permissions_file_id_fkey" FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE not valid;

alter table "public"."file_permissions" validate constraint "file_permissions_file_id_fkey";

alter table "public"."file_permissions" add constraint "file_permissions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."file_permissions" validate constraint "file_permissions_tenant_id_fkey";

alter table "public"."file_permissions" add constraint "file_permissions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."file_permissions" validate constraint "file_permissions_user_id_fkey";

alter table "public"."files" add constraint "files_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."files" validate constraint "files_tenant_id_fkey";

alter table "public"."files" add constraint "files_uploaded_by_fkey" FOREIGN KEY (uploaded_by) REFERENCES public.users(id) ON DELETE SET NULL not valid;

alter table "public"."files" validate constraint "files_uploaded_by_fkey";

alter table "public"."menu_permissions" add constraint "menu_permissions_menu_id_fkey" FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON DELETE CASCADE not valid;

alter table "public"."menu_permissions" validate constraint "menu_permissions_menu_id_fkey";

alter table "public"."menu_permissions" add constraint "menu_permissions_menu_id_role_id_key" UNIQUE using index "menu_permissions_menu_id_role_id_key";

alter table "public"."menu_permissions" add constraint "menu_permissions_role_id_fkey" FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE not valid;

alter table "public"."menu_permissions" validate constraint "menu_permissions_role_id_fkey";

alter table "public"."menu_permissions" add constraint "menu_permissions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."menu_permissions" validate constraint "menu_permissions_tenant_id_fkey";

alter table "public"."menus" add constraint "menus_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."menus" validate constraint "menus_created_by_fkey";

alter table "public"."menus" add constraint "menus_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.menus(id) not valid;

alter table "public"."menus" validate constraint "menus_parent_id_fkey";

alter table "public"."menus" add constraint "menus_role_id_fkey" FOREIGN KEY (role_id) REFERENCES public.roles(id) not valid;

alter table "public"."menus" validate constraint "menus_role_id_fkey";

alter table "public"."mobile_app_config" add constraint "mobile_app_config_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."mobile_app_config" validate constraint "mobile_app_config_tenant_id_fkey";

alter table "public"."mobile_app_config" add constraint "mobile_app_config_tenant_id_key" UNIQUE using index "mobile_app_config_tenant_id_key";

alter table "public"."mobile_app_config" add constraint "mobile_app_config_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "public"."mobile_app_config" validate constraint "mobile_app_config_updated_by_fkey";

alter table "public"."mobile_users" add constraint "mobile_users_device_type_check" CHECK ((device_type = ANY (ARRAY['ios'::text, 'android'::text, 'web'::text]))) not valid;

alter table "public"."mobile_users" validate constraint "mobile_users_device_type_check";

alter table "public"."mobile_users" add constraint "mobile_users_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."mobile_users" validate constraint "mobile_users_tenant_id_fkey";

alter table "public"."mobile_users" add constraint "mobile_users_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."mobile_users" validate constraint "mobile_users_user_id_fkey";

alter table "public"."notification_readers" add constraint "notification_readers_notification_id_fkey" FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON DELETE CASCADE not valid;

alter table "public"."notification_readers" validate constraint "notification_readers_notification_id_fkey";

alter table "public"."notification_readers" add constraint "notification_readers_notification_id_user_id_key" UNIQUE using index "notification_readers_notification_id_user_id_key";

alter table "public"."notification_readers" add constraint "notification_readers_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE not valid;

alter table "public"."notification_readers" validate constraint "notification_readers_user_id_fkey";

alter table "public"."notifications" add constraint "notifications_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."notifications" validate constraint "notifications_created_by_fkey";

alter table "public"."notifications" add constraint "notifications_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."notifications" validate constraint "notifications_tenant_id_fkey";

alter table "public"."notifications" add constraint "notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) not valid;

alter table "public"."notifications" validate constraint "notifications_user_id_fkey";

alter table "public"."order_items" add constraint "order_items_order_id_fkey" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE not valid;

alter table "public"."order_items" validate constraint "order_items_order_id_fkey";

alter table "public"."order_items" add constraint "order_items_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) not valid;

alter table "public"."order_items" validate constraint "order_items_product_id_fkey";

alter table "public"."order_items" add constraint "order_items_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."order_items" validate constraint "order_items_tenant_id_fkey";

alter table "public"."orders" add constraint "orders_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."orders" validate constraint "orders_tenant_id_fkey";

alter table "public"."orders" add constraint "orders_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) not valid;

alter table "public"."orders" validate constraint "orders_user_id_fkey";

alter table "public"."page_categories" add constraint "page_categories_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE not valid;

alter table "public"."page_categories" validate constraint "page_categories_category_id_fkey";

alter table "public"."page_categories" add constraint "page_categories_page_id_fkey" FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE not valid;

alter table "public"."page_categories" validate constraint "page_categories_page_id_fkey";

alter table "public"."page_categories" add constraint "page_categories_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."page_categories" validate constraint "page_categories_tenant_id_fkey";

alter table "public"."page_tags" add constraint "page_tags_page_id_fkey" FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE not valid;

alter table "public"."page_tags" validate constraint "page_tags_page_id_fkey";

alter table "public"."page_tags" add constraint "page_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."page_tags" validate constraint "page_tags_tag_id_fkey";

alter table "public"."page_tags" add constraint "page_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."page_tags" validate constraint "page_tags_tenant_id_fkey";

alter table "public"."pages" add constraint "pages_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) not valid;

alter table "public"."pages" validate constraint "pages_category_id_fkey";

alter table "public"."pages" add constraint "pages_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."pages" validate constraint "pages_created_by_fkey";

alter table "public"."pages" add constraint "pages_current_assignee_id_fkey" FOREIGN KEY (current_assignee_id) REFERENCES public.users(id) not valid;

alter table "public"."pages" validate constraint "pages_current_assignee_id_fkey";

alter table "public"."pages" add constraint "pages_editor_type_check" CHECK ((editor_type = ANY (ARRAY['richtext'::text, 'visual'::text]))) not valid;

alter table "public"."pages" validate constraint "pages_editor_type_check";

alter table "public"."pages" add constraint "pages_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.pages(id) not valid;

alter table "public"."pages" validate constraint "pages_parent_id_fkey";

alter table "public"."pages" add constraint "pages_slug_key" UNIQUE using index "pages_slug_key";

alter table "public"."pages" add constraint "pages_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."pages" validate constraint "pages_tenant_id_fkey";

alter table "public"."payment_methods" add constraint "payment_methods_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."payment_methods" validate constraint "payment_methods_tenant_id_fkey";

alter table "public"."payment_methods" add constraint "payment_methods_type_check" CHECK ((type = ANY (ARRAY['midtrans'::text, 'bank_transfer'::text, 'cod'::text, 'manual'::text]))) not valid;

alter table "public"."payment_methods" validate constraint "payment_methods_type_check";

alter table "public"."payments" add constraint "payments_order_id_fkey" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE not valid;

alter table "public"."payments" validate constraint "payments_order_id_fkey";

alter table "public"."payments" add constraint "payments_payment_method_id_fkey" FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(id) not valid;

alter table "public"."payments" validate constraint "payments_payment_method_id_fkey";

alter table "public"."payments" add constraint "payments_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'success'::text, 'failed'::text, 'expired'::text, 'refunded'::text]))) not valid;

alter table "public"."payments" validate constraint "payments_status_check";

alter table "public"."payments" add constraint "payments_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."payments" validate constraint "payments_tenant_id_fkey";

alter table "public"."permissions" add constraint "permissions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."permissions" validate constraint "permissions_created_by_fkey";

alter table "public"."photo_gallery" add constraint "photo_gallery_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) not valid;

alter table "public"."photo_gallery" validate constraint "photo_gallery_category_id_fkey";

alter table "public"."photo_gallery" add constraint "photo_gallery_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."photo_gallery" validate constraint "photo_gallery_created_by_fkey";

alter table "public"."photo_gallery" add constraint "photo_gallery_slug_key" UNIQUE using index "photo_gallery_slug_key";

alter table "public"."photo_gallery" add constraint "photo_gallery_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."photo_gallery" validate constraint "photo_gallery_tenant_id_fkey";

alter table "public"."photo_gallery_tags" add constraint "photo_gallery_tags_photo_gallery_id_fkey" FOREIGN KEY (photo_gallery_id) REFERENCES public.photo_gallery(id) ON DELETE CASCADE not valid;

alter table "public"."photo_gallery_tags" validate constraint "photo_gallery_tags_photo_gallery_id_fkey";

alter table "public"."photo_gallery_tags" add constraint "photo_gallery_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."photo_gallery_tags" validate constraint "photo_gallery_tags_tag_id_fkey";

alter table "public"."photo_gallery_tags" add constraint "photo_gallery_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."photo_gallery_tags" validate constraint "photo_gallery_tags_tenant_id_fkey";

alter table "public"."portfolio" add constraint "portfolio_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) not valid;

alter table "public"."portfolio" validate constraint "portfolio_category_id_fkey";

alter table "public"."portfolio" add constraint "portfolio_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."portfolio" validate constraint "portfolio_created_by_fkey";

alter table "public"."portfolio" add constraint "portfolio_slug_key" UNIQUE using index "portfolio_slug_key";

alter table "public"."portfolio" add constraint "portfolio_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."portfolio" validate constraint "portfolio_tenant_id_fkey";

alter table "public"."portfolio_tags" add constraint "portfolio_tags_portfolio_id_fkey" FOREIGN KEY (portfolio_id) REFERENCES public.portfolio(id) ON DELETE CASCADE not valid;

alter table "public"."portfolio_tags" validate constraint "portfolio_tags_portfolio_id_fkey";

alter table "public"."portfolio_tags" add constraint "portfolio_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."portfolio_tags" validate constraint "portfolio_tags_tag_id_fkey";

alter table "public"."portfolio_tags" add constraint "portfolio_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."portfolio_tags" validate constraint "portfolio_tags_tenant_id_fkey";

alter table "public"."product_tags" add constraint "product_tags_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE not valid;

alter table "public"."product_tags" validate constraint "product_tags_product_id_fkey";

alter table "public"."product_tags" add constraint "product_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."product_tags" validate constraint "product_tags_tag_id_fkey";

alter table "public"."product_tags" add constraint "product_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."product_tags" validate constraint "product_tags_tenant_id_fkey";

alter table "public"."product_type_tags" add constraint "product_type_tags_product_type_id_fkey" FOREIGN KEY (product_type_id) REFERENCES public.product_types(id) ON DELETE CASCADE not valid;

alter table "public"."product_type_tags" validate constraint "product_type_tags_product_type_id_fkey";

alter table "public"."product_type_tags" add constraint "product_type_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."product_type_tags" validate constraint "product_type_tags_tag_id_fkey";

alter table "public"."product_type_tags" add constraint "product_type_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."product_type_tags" validate constraint "product_type_tags_tenant_id_fkey";

alter table "public"."product_types" add constraint "product_types_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."product_types" validate constraint "product_types_created_by_fkey";

alter table "public"."product_types" add constraint "product_types_slug_key" UNIQUE using index "product_types_slug_key";

alter table "public"."product_types" add constraint "product_types_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."product_types" validate constraint "product_types_tenant_id_fkey";

alter table "public"."products" add constraint "products_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) not valid;

alter table "public"."products" validate constraint "products_category_id_fkey";

alter table "public"."products" add constraint "products_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."products" validate constraint "products_created_by_fkey";

alter table "public"."products" add constraint "products_product_type_id_fkey" FOREIGN KEY (product_type_id) REFERENCES public.product_types(id) not valid;

alter table "public"."products" validate constraint "products_product_type_id_fkey";

alter table "public"."products" add constraint "products_slug_key" UNIQUE using index "products_slug_key";

alter table "public"."products" add constraint "products_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."products" validate constraint "products_tenant_id_fkey";

alter table "public"."promotion_tags" add constraint "promotion_tags_promotion_id_fkey" FOREIGN KEY (promotion_id) REFERENCES public.promotions(id) ON DELETE CASCADE not valid;

alter table "public"."promotion_tags" validate constraint "promotion_tags_promotion_id_fkey";

alter table "public"."promotion_tags" add constraint "promotion_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."promotion_tags" validate constraint "promotion_tags_tag_id_fkey";

alter table "public"."promotion_tags" add constraint "promotion_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."promotion_tags" validate constraint "promotion_tags_tenant_id_fkey";

alter table "public"."promotions" add constraint "promotions_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) not valid;

alter table "public"."promotions" validate constraint "promotions_category_id_fkey";

alter table "public"."promotions" add constraint "promotions_code_key" UNIQUE using index "promotions_code_key";

alter table "public"."promotions" add constraint "promotions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."promotions" validate constraint "promotions_created_by_fkey";

alter table "public"."promotions" add constraint "promotions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."promotions" validate constraint "promotions_tenant_id_fkey";

alter table "public"."push_notifications" add constraint "push_notifications_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."push_notifications" validate constraint "push_notifications_created_by_fkey";

alter table "public"."push_notifications" add constraint "push_notifications_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'scheduled'::text, 'sending'::text, 'sent'::text, 'failed'::text]))) not valid;

alter table "public"."push_notifications" validate constraint "push_notifications_status_check";

alter table "public"."push_notifications" add constraint "push_notifications_target_type_check" CHECK ((target_type = ANY (ARRAY['all'::text, 'user'::text, 'segment'::text, 'topic'::text]))) not valid;

alter table "public"."push_notifications" validate constraint "push_notifications_target_type_check";

alter table "public"."push_notifications" add constraint "push_notifications_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."push_notifications" validate constraint "push_notifications_tenant_id_fkey";

alter table "public"."region_levels" add constraint "region_levels_key_key" UNIQUE using index "region_levels_key_key";

alter table "public"."regions" add constraint "regions_level_id_fkey" FOREIGN KEY (level_id) REFERENCES public.region_levels(id) not valid;

alter table "public"."regions" validate constraint "regions_level_id_fkey";

alter table "public"."regions" add constraint "regions_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.regions(id) not valid;

alter table "public"."regions" validate constraint "regions_parent_id_fkey";

alter table "public"."regions" add constraint "regions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."regions" validate constraint "regions_tenant_id_fkey";

alter table "public"."role_permissions" add constraint "role_permissions_role_id_permission_id_key" UNIQUE using index "role_permissions_role_id_permission_id_key";

alter table "public"."role_permissions" add constraint "role_permissions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."role_permissions" validate constraint "role_permissions_tenant_id_fkey";

alter table "public"."roles" add constraint "roles_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."roles" validate constraint "roles_created_by_fkey";

alter table "public"."sensor_readings" add constraint "sensor_readings_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."sensor_readings" validate constraint "sensor_readings_tenant_id_fkey";

alter table "public"."seo_metadata" add constraint "seo_metadata_resource_type_resource_id_key" UNIQUE using index "seo_metadata_resource_type_resource_id_key";

alter table "public"."seo_metadata" add constraint "seo_metadata_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."seo_metadata" validate constraint "seo_metadata_tenant_id_fkey";

alter table "public"."settings" add constraint "settings_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."settings" validate constraint "settings_tenant_id_fkey";

alter table "public"."sso_audit_logs" add constraint "sso_audit_logs_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."sso_audit_logs" validate constraint "sso_audit_logs_tenant_id_fkey";

alter table "public"."sso_audit_logs" add constraint "sso_audit_logs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL not valid;

alter table "public"."sso_audit_logs" validate constraint "sso_audit_logs_user_id_fkey";

alter table "public"."sso_providers" add constraint "sso_providers_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."sso_providers" validate constraint "sso_providers_created_by_fkey";

alter table "public"."sso_providers" add constraint "sso_providers_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."sso_providers" validate constraint "sso_providers_tenant_id_fkey";

alter table "public"."sso_role_mappings" add constraint "sso_role_mappings_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."sso_role_mappings" validate constraint "sso_role_mappings_created_by_fkey";

alter table "public"."sso_role_mappings" add constraint "sso_role_mappings_internal_role_id_fkey" FOREIGN KEY (internal_role_id) REFERENCES public.roles(id) ON DELETE CASCADE not valid;

alter table "public"."sso_role_mappings" validate constraint "sso_role_mappings_internal_role_id_fkey";

alter table "public"."tags" add constraint "tags_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."tags" validate constraint "tags_created_by_fkey";

alter table "public"."tags" add constraint "tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."tags" validate constraint "tags_tenant_id_fkey";

alter table "public"."tenants" add constraint "tenants_host_key" UNIQUE using index "tenants_host_key";

alter table "public"."testimonies" add constraint "testimonies_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) not valid;

alter table "public"."testimonies" validate constraint "testimonies_category_id_fkey";

alter table "public"."testimonies" add constraint "testimonies_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."testimonies" validate constraint "testimonies_created_by_fkey";

alter table "public"."testimonies" add constraint "testimonies_rating_check" CHECK (((rating >= 1) AND (rating <= 5))) not valid;

alter table "public"."testimonies" validate constraint "testimonies_rating_check";

alter table "public"."testimonies" add constraint "testimonies_slug_key" UNIQUE using index "testimonies_slug_key";

alter table "public"."testimonies" add constraint "testimonies_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."testimonies" validate constraint "testimonies_tenant_id_fkey";

alter table "public"."testimony_tags" add constraint "testimony_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."testimony_tags" validate constraint "testimony_tags_tag_id_fkey";

alter table "public"."testimony_tags" add constraint "testimony_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."testimony_tags" validate constraint "testimony_tags_tenant_id_fkey";

alter table "public"."testimony_tags" add constraint "testimony_tags_testimony_id_fkey" FOREIGN KEY (testimony_id) REFERENCES public.testimonies(id) ON DELETE CASCADE not valid;

alter table "public"."testimony_tags" validate constraint "testimony_tags_testimony_id_fkey";

alter table "public"."themes" add constraint "themes_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."themes" validate constraint "themes_created_by_fkey";

alter table "public"."themes" add constraint "themes_slug_key" UNIQUE using index "themes_slug_key";

alter table "public"."themes" add constraint "themes_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."themes" validate constraint "themes_tenant_id_fkey";

alter table "public"."two_factor_audit_logs" add constraint "two_factor_audit_logs_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."two_factor_audit_logs" validate constraint "two_factor_audit_logs_tenant_id_fkey";

alter table "public"."two_factor_audit_logs" add constraint "two_factor_audit_logs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) not valid;

alter table "public"."two_factor_audit_logs" validate constraint "two_factor_audit_logs_user_id_fkey";

alter table "public"."two_factor_auth" add constraint "two_factor_auth_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."two_factor_auth" validate constraint "two_factor_auth_tenant_id_fkey";

alter table "public"."two_factor_auth" add constraint "two_factor_auth_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE not valid;

alter table "public"."two_factor_auth" validate constraint "two_factor_auth_user_id_fkey";

alter table "public"."two_factor_auth" add constraint "unique_user_2fa" UNIQUE using index "unique_user_2fa";

alter table "public"."users" add constraint "users_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."users" validate constraint "users_created_by_fkey";

alter table "public"."users" add constraint "users_region_id_fkey" FOREIGN KEY (region_id) REFERENCES public.regions(id) ON DELETE SET NULL not valid;

alter table "public"."users" validate constraint "users_region_id_fkey";

alter table "public"."video_gallery" add constraint "video_gallery_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) not valid;

alter table "public"."video_gallery" validate constraint "video_gallery_category_id_fkey";

alter table "public"."video_gallery" add constraint "video_gallery_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."video_gallery" validate constraint "video_gallery_created_by_fkey";

alter table "public"."video_gallery" add constraint "video_gallery_slug_key" UNIQUE using index "video_gallery_slug_key";

alter table "public"."video_gallery" add constraint "video_gallery_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."video_gallery" validate constraint "video_gallery_tenant_id_fkey";

alter table "public"."video_gallery_tags" add constraint "video_gallery_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE not valid;

alter table "public"."video_gallery_tags" validate constraint "video_gallery_tags_tag_id_fkey";

alter table "public"."video_gallery_tags" add constraint "video_gallery_tags_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."video_gallery_tags" validate constraint "video_gallery_tags_tenant_id_fkey";

alter table "public"."video_gallery_tags" add constraint "video_gallery_tags_video_gallery_id_fkey" FOREIGN KEY (video_gallery_id) REFERENCES public.video_gallery(id) ON DELETE CASCADE not valid;

alter table "public"."video_gallery_tags" validate constraint "video_gallery_tags_video_gallery_id_fkey";

alter table "public"."users" add constraint "users_role_id_fkey" FOREIGN KEY (role_id) REFERENCES public.roles(id) not valid;

alter table "public"."users" validate constraint "users_role_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.analyze_file_usage()
 RETURNS TABLE(file_path text, usage_count bigint, modules text[])
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    RETURN QUERY
    WITH all_content AS (
        SELECT 'articles'::text as module, featured_image as content FROM articles WHERE featured_image IS NOT NULL
        UNION ALL SELECT 'articles', content FROM articles WHERE content IS NOT NULL
        UNION ALL SELECT 'pages', featured_image FROM pages WHERE featured_image IS NOT NULL
        UNION ALL SELECT 'pages', content FROM pages WHERE content IS NOT NULL
        UNION ALL SELECT 'products', images::text FROM products WHERE images IS NOT NULL
        UNION ALL SELECT 'portfolio', images::text FROM portfolio WHERE images IS NOT NULL
        UNION ALL SELECT 'photo_gallery', photos::text FROM photo_gallery WHERE photos IS NOT NULL
        UNION ALL SELECT 'testimonies', author_image FROM testimonies WHERE author_image IS NOT NULL
    ),
    file_matches AS (
        SELECT 
            f.file_path,
            ac.module
        FROM files f
        JOIN all_content ac ON ac.content ILIKE '%' || f.file_path || '%'
    )
    SELECT 
        fm.file_path,
        COUNT(*)::bigint as usage_count,
        array_agg(DISTINCT fm.module) as modules
    FROM file_matches fm
    GROUP BY fm.file_path;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.can_delete_resource(resource_name text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.has_permission('delete_' || resource_name); $function$
;

CREATE OR REPLACE FUNCTION public.can_edit_resource(resource_name text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.has_permission('edit_' || resource_name); $function$
;

CREATE OR REPLACE FUNCTION public.can_manage_backups()
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.get_my_role() = 'super_admin'; $function$
;

CREATE OR REPLACE FUNCTION public.can_manage_extension()
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.get_my_role() = 'super_admin'; $function$
;

CREATE OR REPLACE FUNCTION public.can_manage_extensions()
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.get_my_role() = 'super_admin'; $function$
;

CREATE OR REPLACE FUNCTION public.can_manage_logs()
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.get_my_role() = 'super_admin'; $function$
;

CREATE OR REPLACE FUNCTION public.can_manage_monitoring()
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.get_my_role() = 'super_admin'; $function$
;

CREATE OR REPLACE FUNCTION public.can_manage_resource()
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.get_my_role() IN ('super_admin', 'admin'); $function$
;

CREATE OR REPLACE FUNCTION public.can_manage_roles()
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.has_permission('view_roles') AND public.has_permission('edit_roles'); $function$
;

CREATE OR REPLACE FUNCTION public.can_manage_settings()
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.get_my_role() = 'super_admin'; $function$
;

CREATE OR REPLACE FUNCTION public.can_manage_users()
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.has_permission('view_users') AND public.has_permission('edit_users'); $function$
;

CREATE OR REPLACE FUNCTION public.can_publish_resource(resource_name text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.has_permission('publish_' || resource_name); $function$
;

CREATE OR REPLACE FUNCTION public.can_restore_resource(resource_name text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.has_permission('restore_' || resource_name); $function$
;

CREATE OR REPLACE FUNCTION public.can_view_resource(resource_name text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT public.has_permission('view_' || resource_name); $function$
;

CREATE OR REPLACE FUNCTION public.check_access(resource_owner_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_role text;
    v_uid uuid;
BEGIN
    v_uid := (SELECT auth.uid());
    -- Use the existing efficient get_my_role function
    v_role := (SELECT public.get_my_role());
    
    -- Super admins and admins have full access
    IF v_role IN ('super_admin', 'admin') THEN
        RETURN true;
    END IF;
    
    -- Editors/Users can access their own resources
    IF v_uid = resource_owner_id THEN
        RETURN true;
    END IF;
    
    RETURN false;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_public_permission(permission_name text)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  has_perm boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM role_permissions rp
    JOIN roles r ON r.id = rp.role_id
    JOIN permissions p ON p.id = rp.permission_id
    WHERE r.name = 'public'
    AND p.name = permission_name
  ) INTO has_perm;
  RETURN has_perm;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ensure_single_active_theme()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  IF NEW.is_active = true THEN
    UPDATE themes SET is_active = false WHERE id != NEW.id AND is_active = true;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_detailed_tag_usage()
 RETURNS TABLE(tag_id uuid, tag_name text, tag_slug text, tag_color text, tag_icon text, tag_is_active boolean, tag_description text, tag_created_at timestamp with time zone, tag_updated_at timestamp with time zone, module text, count bigint)
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
BEGIN
    RETURN QUERY
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'articles'::text, count(at.tag_id)::bigint FROM tags t JOIN article_tags at ON t.id = at.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'pages'::text, count(pt.tag_id)::bigint FROM tags t JOIN page_tags pt ON t.id = pt.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'products'::text, count(prt.tag_id)::bigint FROM tags t JOIN product_tags prt ON t.id = prt.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'portfolio'::text, count(pot.tag_id)::bigint FROM tags t JOIN portfolio_tags pot ON t.id = pot.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'announcements'::text, count(ant.tag_id)::bigint FROM tags t JOIN announcement_tags ant ON t.id = ant.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'promotions'::text, count(prmt.tag_id)::bigint FROM tags t JOIN promotion_tags prmt ON t.id = prmt.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'testimonies'::text, count(tt.tag_id)::bigint FROM tags t JOIN testimony_tags tt ON t.id = tt.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'photo_gallery'::text, count(pgt.tag_id)::bigint FROM tags t JOIN photo_gallery_tags pgt ON t.id = pgt.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'video_gallery'::text, count(vgt.tag_id)::bigint FROM tags t JOIN video_gallery_tags vgt ON t.id = vgt.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'contacts'::text, count(ct.tag_id)::bigint FROM tags t JOIN contact_tags ct ON t.id = ct.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'contact_messages'::text, count(cmt.tag_id)::bigint FROM tags t JOIN contact_message_tags cmt ON t.id = cmt.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id
    UNION ALL
    SELECT t.id, t.name, t.slug, t.color, t.icon, t.is_active, t.description, t.created_at, t.updated_at, 'product_types'::text, count(ptt.tag_id)::bigint FROM tags t JOIN product_type_tags ptt ON t.id = ptt.tag_id WHERE t.deleted_at IS NULL GROUP BY t.id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_permissions()
 RETURNS text[]
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  perms text[];
BEGIN
  SELECT ARRAY_AGG(p.name)
  INTO perms
  FROM public.users u
  JOIN public.roles r ON u.role_id = r.id
  JOIN public.role_permissions rp ON r.id = rp.role_id
  JOIN public.permissions p ON rp.permission_id = p.id
  WHERE u.id = (SELECT auth.uid());
  
  RETURN COALESCE(perms, ARRAY[]::text[]);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_role()
 RETURNS text
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  role_name text;
  user_email text;
BEGIN
  -- Wrap current_setting in a subquery for safety, though STABLE handles it well
  user_email := (SELECT current_setting('request.jwt.claims', true)::jsonb ->> 'email');
  
  -- Hardcoded super admin check for safety
  IF user_email = 'cms@ahliweb.com' THEN
    RETURN 'super_admin';
  END IF;

  -- Efficient query for role name
  SELECT r.name INTO role_name
  FROM public.users u
  JOIN public.roles r ON u.role_id = r.id
  WHERE u.id = (SELECT auth.uid());
  
  RETURN COALESCE(role_name, 'guest');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_role_name()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT r.name
  FROM public.users u
  JOIN public.roles r ON u.role_id = r.id
  WHERE u.id = (select auth.uid()) -- Wrap here too just in case
  LIMIT 1;
$function$
;

CREATE OR REPLACE FUNCTION public.get_storage_stats()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    total_files bigint;
    total_size bigint;
    image_count bigint;
    video_count bigint;
    doc_count bigint;
BEGIN
    -- Basic counts
    SELECT 
        count(*), 
        COALESCE(sum(file_size), 0)
    INTO 
        total_files, 
        total_size
    FROM files
    WHERE deleted_at IS NULL;

    -- Type counts
    SELECT count(*) INTO image_count 
    FROM files 
    WHERE file_type ILIKE 'image/%' AND deleted_at IS NULL;

    SELECT count(*) INTO video_count 
    FROM files 
    WHERE file_type ILIKE 'video/%' AND deleted_at IS NULL;

    SELECT count(*) INTO doc_count 
    FROM files 
    WHERE file_type NOT ILIKE 'image/%' 
      AND file_type NOT ILIKE 'video/%' 
      AND deleted_at IS NULL;

    RETURN jsonb_build_object(
        'total_files', total_files,
        'total_size', total_size,
        'image_count', image_count,
        'video_count', video_count,
        'doc_count', doc_count
    );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_tags_with_counts()
 RETURNS TABLE(tag text, cnt bigint)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_temp'
AS $function$
BEGIN
  RETURN QUERY
  WITH all_tag_links AS (
    SELECT tag_id FROM public.product_type_tags
    UNION ALL SELECT tag_id FROM public.article_tags
    UNION ALL SELECT tag_id FROM public.page_tags
    UNION ALL SELECT tag_id FROM public.product_tags
    UNION ALL SELECT tag_id FROM public.promotion_tags
    UNION ALL SELECT tag_id FROM public.portfolio_tags
    UNION ALL SELECT tag_id FROM public.photo_gallery_tags
    UNION ALL SELECT tag_id FROM public.video_gallery_tags
    UNION ALL SELECT tag_id FROM public.contact_message_tags
    UNION ALL SELECT tag_id FROM public.testimony_tags
    UNION ALL SELECT tag_id FROM public.announcement_tags
  )
  SELECT t.name::text AS tag, COUNT(1)::bigint AS cnt
  FROM all_tag_links l
  JOIN public.tags t ON t.id = l.tag_id
  GROUP BY t.name
  ORDER BY cnt DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_tenant_id_by_host(lookup_host text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  RETURN (SELECT id FROM tenants WHERE host = lookup_host LIMIT 1);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_role_name(user_uuid uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  role_name text;
BEGIN
  SELECT r.name INTO role_name
  FROM public.users u
  JOIN public.roles r ON u.role_id = r.id
  WHERE u.id = user_uuid;
  
  RETURN role_name;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.has_permission(permission_name text)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  has_perm boolean;
  v_role text;
BEGIN
  v_role := (SELECT public.get_my_role());
  
  IF v_role = 'super_admin' THEN
    RETURN true;
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    JOIN public.role_permissions rp ON r.id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    WHERE u.id = (SELECT auth.uid())
      AND p.name = permission_name
  ) INTO has_perm;
  
  RETURN has_perm;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.has_role(role_name text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$ SELECT (public.get_my_role() = role_name); $function$
;

CREATE OR REPLACE FUNCTION public.increment_article_view(article_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  UPDATE articles
  SET views = COALESCE(views, 0) + 1
  WHERE id = article_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.increment_page_view(page_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  UPDATE pages
  SET views = COALESCE(views, 0) + 1
  WHERE id = page_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.lock_created_by()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
BEGIN
  IF NEW.created_by IS DISTINCT FROM OLD.created_by THEN
    NEW.created_by := OLD.created_by;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.log_extension_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
BEGIN
  -- On UPDATE, log the change
  IF TG_OP = 'UPDATE' THEN
    -- Log activation/deactivation
    IF OLD.is_active IS DISTINCT FROM NEW.is_active THEN
      INSERT INTO extension_logs (tenant_id, extension_id, extension_slug, action, details, user_id)
      VALUES (
        NEW.tenant_id,
        NEW.id,
        NEW.slug,
        CASE WHEN NEW.is_active THEN 'activate' ELSE 'deactivate' END,
        jsonb_build_object(
          'previous_state', OLD.is_active,
          'new_state', NEW.is_active,
          'version', NEW.version
        ),
        auth.uid()
      );
    END IF;
    
    -- Log config changes
    IF OLD.config IS DISTINCT FROM NEW.config THEN
      INSERT INTO extension_logs (tenant_id, extension_id, extension_slug, action, details, user_id)
      VALUES (
        NEW.tenant_id,
        NEW.id,
        NEW.slug,
        'config_change',
        jsonb_build_object(
          'previous_config', OLD.config,
          'new_config', NEW.config
        ),
        auth.uid()
      );
    END IF;
    
    RETURN NEW;
  END IF;
  
  -- On INSERT (install)
  IF TG_OP = 'INSERT' THEN
    INSERT INTO extension_logs (tenant_id, extension_id, extension_slug, action, details, user_id)
    VALUES (
      NEW.tenant_id,
      NEW.id,
      NEW.slug,
      'install',
      jsonb_build_object(
        'version', NEW.version,
        'extension_type', NEW.extension_type
      ),
      auth.uid()
    );
    RETURN NEW;
  END IF;
  
  -- On DELETE (uninstall)
  IF TG_OP = 'DELETE' THEN
    INSERT INTO extension_logs (tenant_id, extension_id, extension_slug, action, details, user_id)
    VALUES (
      OLD.tenant_id,
      OLD.id,
      OLD.slug,
      'uninstall',
      jsonb_build_object(
        'version', OLD.version,
        'was_active', OLD.is_active
      ),
      auth.uid()
    );
    RETURN OLD;
  END IF;
  
  RETURN NULL;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.log_sso_event(p_provider text, p_event_type text, p_details jsonb DEFAULT '{}'::jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_log_id uuid;
BEGIN
    INSERT INTO public.sso_audit_logs (user_id, provider, event_type, details)
    VALUES ((select auth.uid()), p_provider, p_event_type, p_details)
    RETURNING id INTO v_log_id;
    RETURN v_log_id;
END;
$function$
;

create or replace view "public"."published_articles_view" as  SELECT id,
    tenant_id,
    title,
    content,
    excerpt,
    featured_image,
    status,
    author_id,
    created_at,
    updated_at
   FROM public.articles
  WHERE ((status = 'published'::text) AND (deleted_at IS NULL));


CREATE OR REPLACE FUNCTION public.remove_duplicates(table_name text, column_name text)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  normalized_table regclass;
  sch text;
  tbl text;
  unsafe_schemas text[] := ARRAY['pg_catalog','information_schema','extensions','pg_toast','pg_temp'];
BEGIN
  -- Basic identifier checks
  IF table_name IS NULL OR table_name = '' THEN
    RAISE EXCEPTION 'table_name must be provided';
  END IF;
  IF column_name IS NULL OR column_name = '' THEN
    RAISE EXCEPTION 'column_name must be provided';
  END IF;

  -- Try to resolve the table name to regclass (allows schema qualified or unqualified)
  BEGIN
    normalized_table := table_name::regclass;
  EXCEPTION WHEN undefined_table THEN
    RAISE EXCEPTION 'table "%" does not exist or is not visible to this function', table_name;
  END;

  -- Extract schema and table
  sch := split_part((normalized_table::text),'.',1);
  tbl := split_part((normalized_table::text),'.',2);

  -- Prevent dangerous schemas
  IF sch = ANY(unsafe_schemas) THEN
    RAISE EXCEPTION 'operation not allowed on schema %', sch;
  END IF;

  -- Ensure the column exists on the resolved table
  IF NOT EXISTS (
    SELECT 1 FROM pg_attribute a
    JOIN pg_class c ON a.attrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = sch
      AND c.relname = tbl
      AND a.attname = column_name
      AND a.attnum > 0
      AND NOT a.attisdropped
  ) THEN
    RAISE EXCEPTION 'column "%" does not exist on table %I.%I', column_name, sch, tbl;
  END IF;

  -- Perform delete using fully qualified names
  EXECUTE format(
    'DELETE FROM %I.%I a USING %I.%I b
     WHERE a.id < b.id
       AND a.%I = b.%I;',
    sch, tbl, sch, tbl, column_name, column_name
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.seed_permissions()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  resources text[] := ARRAY[
    'articles', 'pages', 'products', 'portfolio', 'announcements', 
    'promotions', 'testimonies', 'photo_gallery', 'video_gallery', 
    'contacts', 'contact_messages', 'users', 'roles', 'permissions',
    'categories', 'tags', 'menus', 'themes', 'files', 'notifications'
  ];
  actions text[] := ARRAY['view', 'create', 'edit', 'delete', 'restore', 'permanent_delete'];
  r text;
  a text;
  perm_name text;
BEGIN
  FOREACH r IN ARRAY resources
  LOOP
    FOREACH a IN ARRAY actions
    LOOP
      perm_name := a || '_' || r;
      -- Insert if not exists
      IF NOT EXISTS (SELECT 1 FROM permissions WHERE name = perm_name) THEN
        INSERT INTO permissions (name, resource, action, description, created_at, updated_at)
        VALUES (
          perm_name, 
          r, 
          a, 
          'Can ' || a || ' ' || replace(r, '_', ' '), 
          NOW(), 
          NOW()
        );
      END IF;
    END LOOP;
    
    -- Add publish permission for specific content types
    IF r IN ('articles', 'pages', 'products', 'portfolio', 'announcements', 'promotions', 'testimonies', 'photo_gallery', 'video_gallery') THEN
       perm_name := 'publish_' || r;
       IF NOT EXISTS (SELECT 1 FROM permissions WHERE name = perm_name) THEN
          INSERT INTO permissions (name, resource, action, description, created_at, updated_at)
          VALUES (perm_name, r, 'publish', 'Can publish ' || replace(r, '_', ' '), NOW(), NOW());
       END IF;
    END IF;
  END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.set_created_by()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
BEGIN
  IF NEW.created_by IS NULL THEN
    NEW.created_by := auth.uid();
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.sync_resource_tags(p_resource_id uuid, p_resource_type text, p_tags text[], p_tenant_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_tag_id uuid;
    v_tag_name text;
    v_tag_ids uuid[] := ARRAY[]::uuid[];
    v_slug text;
BEGIN
    -- Strict Tenant Check
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION 'Tenant ID is required for tag synchronization';
    END IF;

    IF p_tags IS NOT NULL THEN
        FOREACH v_tag_name IN ARRAY p_tags
        LOOP
            IF length(trim(v_tag_name)) > 0 THEN
                v_tag_name := trim(v_tag_name);
                v_slug := lower(regexp_replace(v_tag_name, '[^a-zA-Z0-9]+', '-', 'g'));
                v_slug := regexp_replace(v_slug, '^-+|-+$', '', 'g');
                
                -- Insert with tenant_id, conflict on (tenant_id, slug)
                INSERT INTO tags (name, slug, tenant_id, created_at, updated_at)
                VALUES (v_tag_name, v_slug, p_tenant_id, NOW(), NOW())
                ON CONFLICT (tenant_id, slug) DO UPDATE SET updated_at = NOW()
                RETURNING id INTO v_tag_id;
                
                -- Fallback lookup if simple update/insert didn't return (shouldn't happen with RETURNING but strict safety)
                IF v_tag_id IS NULL THEN
                    SELECT id INTO v_tag_id FROM tags WHERE slug = v_slug AND tenant_id = p_tenant_id;
                END IF;

                IF v_tag_id IS NOT NULL THEN
                    v_tag_ids := array_append(v_tag_ids, v_tag_id);
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- Update Junction Tables
    -- Note: Junction tables use resource_id which is already tenant-scoped via RLS on the resource table.
    -- However, we only link tags that belong to the tenant (enforced by v_tag_id logic above)
    
    IF p_resource_type = 'articles' THEN
        DELETE FROM article_tags WHERE article_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
            INSERT INTO article_tags (article_id, tag_id)
            SELECT p_resource_id, unnest(v_tag_ids)
            ON CONFLICT (article_id, tag_id) DO NOTHING;
        END IF;
    ELSIF p_resource_type = 'pages' THEN
        DELETE FROM page_tags WHERE page_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
            INSERT INTO page_tags (page_id, tag_id)
            SELECT p_resource_id, unnest(v_tag_ids)
            ON CONFLICT (page_id, tag_id) DO NOTHING;
        END IF;
    ELSIF p_resource_type = 'video_gallery' THEN
        DELETE FROM video_gallery_tags WHERE video_gallery_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
             INSERT INTO video_gallery_tags (video_gallery_id, tag_id)
             SELECT p_resource_id, unnest(v_tag_ids)
             ON CONFLICT (video_gallery_id, tag_id) DO NOTHING;
        END IF;
    ELSIF p_resource_type = 'contacts' THEN
        DELETE FROM contact_tags WHERE contact_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
             INSERT INTO contact_tags (contact_id, tag_id)
             SELECT p_resource_id, unnest(v_tag_ids)
             ON CONFLICT (contact_id, tag_id) DO NOTHING;
        END IF;
    ELSIF p_resource_type = 'contact_messages' THEN
        DELETE FROM contact_message_tags WHERE message_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
             INSERT INTO contact_message_tags (message_id, tag_id)
             SELECT p_resource_id, unnest(v_tag_ids)
             ON CONFLICT (message_id, tag_id) DO NOTHING;
        END IF;
    ELSIF p_resource_type = 'product_types' THEN
        DELETE FROM product_type_tags WHERE product_type_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
             INSERT INTO product_type_tags (product_type_id, tag_id)
             SELECT p_resource_id, unnest(v_tag_ids)
             ON CONFLICT (product_type_id, tag_id) DO NOTHING;
        END IF;
    END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.sync_storage_files()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'storage', 'extensions'
AS $function$
DECLARE
    inserted_count int;
BEGIN
    WITH new_files AS (
        INSERT INTO public.files (
            name,
            file_path,
            file_size,
            file_type,
            bucket_name,
            uploaded_by,
            created_at,
            updated_at
        )
        SELECT
            substring(name from '[^/]+$'), -- Extract filename
            name,
            (metadata->>'size')::bigint,
            coalesce(metadata->>'mimetype', 'application/octet-stream'),
            bucket_id,
            -- Only link user if they exist in public.users, otherwise NULL
            CASE 
                WHEN EXISTS(SELECT 1 FROM public.users WHERE id = owner) THEN owner 
                ELSE NULL 
            END,
            created_at,
            updated_at
        FROM storage.objects
        WHERE bucket_id = 'cms-uploads'
        AND NOT EXISTS (
            SELECT 1 FROM public.files WHERE file_path = storage.objects.name
        )
        RETURNING 1
    )
    SELECT count(*) INTO inserted_count FROM new_files;

    RETURN jsonb_build_object(
        'success', true,
        'synced_count', inserted_count
    );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_menu_order(payload jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  item jsonb;
BEGIN
  FOR item IN SELECT * FROM jsonb_array_elements(payload)
  LOOP
    UPDATE menus
    SET "order" = (item->>'order')::int,
        updated_at = NOW()
    WHERE id = (item->>'id')::uuid;
  END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.verify_isolation_debug()
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
DECLARE
    tenant_a_id UUID;
    tenant_b_id UUID;
    user_a_id UUID;
    user_b_id UUID;
    prod_a_id UUID;
    prod_b_id UUID;
    safe_role_id UUID;
    count_result INTEGER;
    debug_tid UUID;
    debug_is_admin BOOLEAN;
    
    orig_tid_a UUID;
    orig_role_a UUID;
    orig_tid_b UUID;
    orig_role_b UUID;
    
    log_text TEXT := '';
    
    a_count INT;
    b_count INT;
    other_count INT;
BEGIN
    log_text := log_text || 'Starting Multi-Tenancy Isolation Test (Function Mode - FORCE RLS)...' || E'\n';

    -- 1. Get Existing Users
    SELECT id INTO user_a_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
    SELECT id INTO user_b_id FROM auth.users ORDER BY created_at ASC OFFSET 1 LIMIT 1;
    
    -- Save Original State
    SELECT tenant_id, role_id INTO orig_tid_a, orig_role_a FROM public.users WHERE id = user_a_id;
    SELECT tenant_id, role_id INTO orig_tid_b, orig_role_b FROM public.users WHERE id = user_b_id;

    -- 2. Safe Role
    SELECT id INTO safe_role_id FROM public.roles WHERE name = 'viewer' LIMIT 1;

    -- 3. Create Tenants
    INSERT INTO public.tenants (name, slug, status, subscription_tier) 
    VALUES ('VOLATILE-TEST-A', 'volatile-test-a', 'active', 'free') 
    RETURNING id INTO tenant_a_id;

    INSERT INTO public.tenants (name, slug, status, subscription_tier) 
    VALUES ('VOLATILE-TEST-B', 'volatile-test-b', 'active', 'free') 
    RETURNING id INTO tenant_b_id;

    -- 4. Update Users
    UPDATE public.users SET tenant_id = tenant_a_id, role_id = safe_role_id WHERE id = user_a_id;
    UPDATE public.users SET tenant_id = tenant_b_id, role_id = safe_role_id WHERE id = user_b_id;

    -- 5. Create Data
    INSERT INTO public.products (name, slug, tenant_id, status, is_available, price) 
    VALUES ('Product A', 'prod-a', tenant_a_id, 'active', true, 100)
    RETURNING id INTO prod_a_id;

    INSERT INTO public.products (name, slug, tenant_id, status, is_available, price) 
    VALUES ('Product B', 'prod-b', tenant_b_id, 'active', true, 200)
    RETURNING id INTO prod_b_id;

    -- FORCE RLS (To test as superuser)
    ALTER TABLE public.products FORCE ROW LEVEL SECURITY;

    -- DEBUG: Check Context
    PERFORM set_config('request.jwt.claim.sub', user_a_id::text, true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

    SELECT public.current_tenant_id() INTO debug_tid;
    SELECT public.is_platform_admin() INTO debug_is_admin;
    
    log_text := log_text || format('DEBUG: User A (%s), TenantDB: %s, CurrentTenantFunc: %s, IsAdmin: %s', user_a_id, tenant_a_id, debug_tid, debug_is_admin) || E'\n';

    -- Verify Products
    SELECT count(*) INTO count_result FROM public.products;
    log_text := log_text || format('DEBUG: User A sees %s products.', count_result) || E'\n';
    
    -- Breakdown
    SELECT count(*) INTO a_count FROM public.products WHERE tenant_id = tenant_a_id;
    SELECT count(*) INTO b_count FROM public.products WHERE tenant_id = tenant_b_id;
    SELECT count(*) INTO other_count FROM public.products WHERE tenant_id NOT IN (tenant_a_id, tenant_b_id);
    
    log_text := log_text || format('DEBUG Breakdown: Tenant A Rows: %s, Tenant B Rows: %s, Other Rows: %s', a_count, b_count, other_count) || E'\n';

    -- DISABLE FORCE RLS
    ALTER TABLE public.products NO FORCE ROW LEVEL SECURITY;

    -- CLEANUP
    
    -- RESET CONTEXT TO SUPERUSER (Bypass RLS execution context, but we are already superuser)
    PERFORM set_config('request.jwt.claim.sub', NULL, true);
    PERFORM set_config('request.jwt.claim.role', NULL, true);

    -- 1. Restore Users
    UPDATE public.users SET tenant_id = orig_tid_a, role_id = orig_role_a WHERE id = user_a_id;
    UPDATE public.users SET tenant_id = orig_tid_b, role_id = orig_role_b WHERE id = user_b_id;
    
    -- 2. Delete Data
    DELETE FROM public.products WHERE id IN (prod_a_id, prod_b_id);
    
    -- 3. Delete Audit Logs
    DELETE FROM public.audit_logs WHERE tenant_id IN (tenant_a_id, tenant_b_id);
    
    -- 4. Delete Tenants
    DELETE FROM public.tenants WHERE id IN (tenant_a_id, tenant_b_id);

    RETURN log_text;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_tenant_limit(check_tenant_id uuid, feature_key text, proposed_usage bigint DEFAULT 0)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    tier TEXT;
    current_usage BIGINT := 0;
    max_limit BIGINT;
BEGIN
    -- Get Tenant Tier
    SELECT subscription_tier INTO tier
    FROM public.tenants
    WHERE id = check_tenant_id;

    -- Define Limits based on Tier
    -- Users Limit (count)
    IF feature_key = 'max_users' THEN
        IF tier = 'enterprise' THEN max_limit := -1; -- Unlimited
        ELSIF tier = 'pro' THEN max_limit := 50;
        ELSE max_limit := 5; -- Free
        END IF;
        
        -- Get Current Usage
        SELECT count(*) INTO current_usage
        FROM public.users
        WHERE tenant_id = check_tenant_id;

    -- Storage Limit (bytes)
    ELSIF feature_key = 'max_storage' THEN
        IF tier = 'enterprise' THEN max_limit := -1; -- Unlimited
        ELSIF tier = 'pro' THEN max_limit := 10737418240; -- 10GB
        ELSE max_limit := 104857600; -- 100MB
        END IF;

        -- Get Current Usage
        SELECT COALESCE(SUM(file_size), 0) INTO current_usage
        FROM public.files
        WHERE tenant_id = check_tenant_id AND deleted_at IS NULL;
    END IF;

    -- Check Limit (-1 means unlimited)
    IF max_limit = -1 THEN
        RETURN TRUE;
    END IF;

    -- For storage, we add the proposed file size. For users, the trigger happens BEFORE insert, so current usage is existing users.
    -- If adding a user, proposed_usage should be 1.
    -- If adding a file, proposed_usage is the file size.
    
    IF (current_usage + proposed_usage) > max_limit THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.current_tenant_id()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
        BEGIN
          RETURN COALESCE(
            (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid,
            (SELECT tenant_id FROM public.users WHERE id = auth.uid())
          );
        END;
        $function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    default_role_id UUID;
    pending_role_id UUID;
    target_tenant_id UUID;
    primary_tenant_id UUID;
    is_public_registration BOOLEAN;
    initial_approval_status TEXT;
BEGIN
    -- 1. Determine if this is a public registration
    -- Public registrations will have 'public_registration' = true in metadata
    BEGIN
        is_public_registration := COALESCE((NEW.raw_user_meta_data->>'public_registration')::BOOLEAN, FALSE);
    EXCEPTION WHEN OTHERS THEN
        is_public_registration := FALSE;
    END;

    -- 2. Determine Tenant
    -- Try to get from metadata (if invited to specific tenant)
    BEGIN
        target_tenant_id := (NEW.raw_user_meta_data->>'tenant_id')::UUID;
    EXCEPTION WHEN OTHERS THEN
        target_tenant_id := NULL;
    END;

    -- If no tenant in metadata, fallback to Primary Tenant
    SELECT id INTO primary_tenant_id FROM public.tenants WHERE slug = 'primary' LIMIT 1;
    
    IF target_tenant_id IS NULL THEN
        target_tenant_id := primary_tenant_id;
    END IF;

    -- 3. Determine Role and Approval Status
    IF is_public_registration THEN
        -- Public registration: assign 'pending' role and set approval_status
        SELECT id INTO pending_role_id 
        FROM public.roles 
        WHERE name = 'pending' 
        LIMIT 1;
        
        default_role_id := pending_role_id;
        initial_approval_status := 'pending_admin';
    ELSE
        -- Admin-created/invited user: assign 'user' role with immediate approval
        SELECT id INTO default_role_id 
        FROM public.roles 
        WHERE name = 'user' AND tenant_id = target_tenant_id
        LIMIT 1;
        
        -- Fallback if no 'user' role in tenant
        IF default_role_id IS NULL THEN
            SELECT id INTO default_role_id 
            FROM public.roles 
            WHERE name = 'subscriber'
            LIMIT 1;
        END IF;
        
        initial_approval_status := 'approved';
    END IF;

    -- 4. Insert into public.users
    INSERT INTO public.users (
        id, 
        email, 
        full_name, 
        role_id, 
        tenant_id, 
        approval_status,
        created_at, 
        updated_at
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        default_role_id,
        target_tenant_id,
        initial_approval_status,
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = COALESCE(EXCLUDED.full_name, public.users.full_name),
        updated_at = NOW();
        
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin_or_above()
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  _role_name TEXT;
BEGIN
  _role_name := (auth.jwt() ->> 'role')::TEXT;
  IF _role_name IN ('admin', 'super_admin', 'owner') THEN
    RETURN TRUE;
  END IF;
  RETURN EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.name IN ('admin', 'super_admin', 'owner')
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_platform_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
      BEGIN
        RETURN public.is_super_admin();
      END;
      $function$
;

CREATE OR REPLACE FUNCTION public.is_super_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  _role_name TEXT;
BEGIN
  _role_name := (auth.jwt() ->> 'role')::TEXT;
  IF _role_name IN ('super_admin', 'owner') THEN
    RETURN TRUE;
  END IF;
  RETURN EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.name IN ('super_admin', 'owner')
  );
END;
$function$
;

grant delete on table "public"."announcement_tags" to "anon";

grant insert on table "public"."announcement_tags" to "anon";

grant references on table "public"."announcement_tags" to "anon";

grant select on table "public"."announcement_tags" to "anon";

grant trigger on table "public"."announcement_tags" to "anon";

grant truncate on table "public"."announcement_tags" to "anon";

grant update on table "public"."announcement_tags" to "anon";

grant delete on table "public"."announcement_tags" to "authenticated";

grant insert on table "public"."announcement_tags" to "authenticated";

grant references on table "public"."announcement_tags" to "authenticated";

grant select on table "public"."announcement_tags" to "authenticated";

grant trigger on table "public"."announcement_tags" to "authenticated";

grant truncate on table "public"."announcement_tags" to "authenticated";

grant update on table "public"."announcement_tags" to "authenticated";

grant delete on table "public"."announcement_tags" to "service_role";

grant insert on table "public"."announcement_tags" to "service_role";

grant references on table "public"."announcement_tags" to "service_role";

grant select on table "public"."announcement_tags" to "service_role";

grant trigger on table "public"."announcement_tags" to "service_role";

grant truncate on table "public"."announcement_tags" to "service_role";

grant update on table "public"."announcement_tags" to "service_role";

grant delete on table "public"."announcements" to "anon";

grant insert on table "public"."announcements" to "anon";

grant references on table "public"."announcements" to "anon";

grant select on table "public"."announcements" to "anon";

grant trigger on table "public"."announcements" to "anon";

grant truncate on table "public"."announcements" to "anon";

grant update on table "public"."announcements" to "anon";

grant delete on table "public"."announcements" to "authenticated";

grant insert on table "public"."announcements" to "authenticated";

grant references on table "public"."announcements" to "authenticated";

grant select on table "public"."announcements" to "authenticated";

grant trigger on table "public"."announcements" to "authenticated";

grant truncate on table "public"."announcements" to "authenticated";

grant update on table "public"."announcements" to "authenticated";

grant delete on table "public"."announcements" to "service_role";

grant insert on table "public"."announcements" to "service_role";

grant references on table "public"."announcements" to "service_role";

grant select on table "public"."announcements" to "service_role";

grant trigger on table "public"."announcements" to "service_role";

grant truncate on table "public"."announcements" to "service_role";

grant update on table "public"."announcements" to "service_role";

grant delete on table "public"."article_tags" to "anon";

grant insert on table "public"."article_tags" to "anon";

grant references on table "public"."article_tags" to "anon";

grant select on table "public"."article_tags" to "anon";

grant trigger on table "public"."article_tags" to "anon";

grant truncate on table "public"."article_tags" to "anon";

grant update on table "public"."article_tags" to "anon";

grant delete on table "public"."article_tags" to "authenticated";

grant insert on table "public"."article_tags" to "authenticated";

grant references on table "public"."article_tags" to "authenticated";

grant select on table "public"."article_tags" to "authenticated";

grant trigger on table "public"."article_tags" to "authenticated";

grant truncate on table "public"."article_tags" to "authenticated";

grant update on table "public"."article_tags" to "authenticated";

grant delete on table "public"."article_tags" to "service_role";

grant insert on table "public"."article_tags" to "service_role";

grant references on table "public"."article_tags" to "service_role";

grant select on table "public"."article_tags" to "service_role";

grant trigger on table "public"."article_tags" to "service_role";

grant truncate on table "public"."article_tags" to "service_role";

grant update on table "public"."article_tags" to "service_role";

grant delete on table "public"."articles" to "anon";

grant insert on table "public"."articles" to "anon";

grant references on table "public"."articles" to "anon";

grant select on table "public"."articles" to "anon";

grant trigger on table "public"."articles" to "anon";

grant truncate on table "public"."articles" to "anon";

grant update on table "public"."articles" to "anon";

grant delete on table "public"."articles" to "authenticated";

grant insert on table "public"."articles" to "authenticated";

grant references on table "public"."articles" to "authenticated";

grant select on table "public"."articles" to "authenticated";

grant trigger on table "public"."articles" to "authenticated";

grant truncate on table "public"."articles" to "authenticated";

grant update on table "public"."articles" to "authenticated";

grant delete on table "public"."articles" to "service_role";

grant insert on table "public"."articles" to "service_role";

grant references on table "public"."articles" to "service_role";

grant select on table "public"."articles" to "service_role";

grant trigger on table "public"."articles" to "service_role";

grant truncate on table "public"."articles" to "service_role";

grant update on table "public"."articles" to "service_role";

grant delete on table "public"."auth_hibp_events" to "anon";

grant insert on table "public"."auth_hibp_events" to "anon";

grant references on table "public"."auth_hibp_events" to "anon";

grant select on table "public"."auth_hibp_events" to "anon";

grant trigger on table "public"."auth_hibp_events" to "anon";

grant truncate on table "public"."auth_hibp_events" to "anon";

grant update on table "public"."auth_hibp_events" to "anon";

grant delete on table "public"."auth_hibp_events" to "authenticated";

grant insert on table "public"."auth_hibp_events" to "authenticated";

grant references on table "public"."auth_hibp_events" to "authenticated";

grant select on table "public"."auth_hibp_events" to "authenticated";

grant trigger on table "public"."auth_hibp_events" to "authenticated";

grant truncate on table "public"."auth_hibp_events" to "authenticated";

grant update on table "public"."auth_hibp_events" to "authenticated";

grant delete on table "public"."auth_hibp_events" to "service_role";

grant insert on table "public"."auth_hibp_events" to "service_role";

grant references on table "public"."auth_hibp_events" to "service_role";

grant select on table "public"."auth_hibp_events" to "service_role";

grant trigger on table "public"."auth_hibp_events" to "service_role";

grant truncate on table "public"."auth_hibp_events" to "service_role";

grant update on table "public"."auth_hibp_events" to "service_role";

grant delete on table "public"."backup_logs" to "anon";

grant insert on table "public"."backup_logs" to "anon";

grant references on table "public"."backup_logs" to "anon";

grant select on table "public"."backup_logs" to "anon";

grant trigger on table "public"."backup_logs" to "anon";

grant truncate on table "public"."backup_logs" to "anon";

grant update on table "public"."backup_logs" to "anon";

grant delete on table "public"."backup_logs" to "authenticated";

grant insert on table "public"."backup_logs" to "authenticated";

grant references on table "public"."backup_logs" to "authenticated";

grant select on table "public"."backup_logs" to "authenticated";

grant trigger on table "public"."backup_logs" to "authenticated";

grant truncate on table "public"."backup_logs" to "authenticated";

grant update on table "public"."backup_logs" to "authenticated";

grant delete on table "public"."backup_logs" to "service_role";

grant insert on table "public"."backup_logs" to "service_role";

grant references on table "public"."backup_logs" to "service_role";

grant select on table "public"."backup_logs" to "service_role";

grant trigger on table "public"."backup_logs" to "service_role";

grant truncate on table "public"."backup_logs" to "service_role";

grant update on table "public"."backup_logs" to "service_role";

grant delete on table "public"."backup_schedules" to "anon";

grant insert on table "public"."backup_schedules" to "anon";

grant references on table "public"."backup_schedules" to "anon";

grant select on table "public"."backup_schedules" to "anon";

grant trigger on table "public"."backup_schedules" to "anon";

grant truncate on table "public"."backup_schedules" to "anon";

grant update on table "public"."backup_schedules" to "anon";

grant delete on table "public"."backup_schedules" to "authenticated";

grant insert on table "public"."backup_schedules" to "authenticated";

grant references on table "public"."backup_schedules" to "authenticated";

grant select on table "public"."backup_schedules" to "authenticated";

grant trigger on table "public"."backup_schedules" to "authenticated";

grant truncate on table "public"."backup_schedules" to "authenticated";

grant update on table "public"."backup_schedules" to "authenticated";

grant delete on table "public"."backup_schedules" to "service_role";

grant insert on table "public"."backup_schedules" to "service_role";

grant references on table "public"."backup_schedules" to "service_role";

grant select on table "public"."backup_schedules" to "service_role";

grant trigger on table "public"."backup_schedules" to "service_role";

grant truncate on table "public"."backup_schedules" to "service_role";

grant update on table "public"."backup_schedules" to "service_role";

grant delete on table "public"."backups" to "anon";

grant insert on table "public"."backups" to "anon";

grant references on table "public"."backups" to "anon";

grant select on table "public"."backups" to "anon";

grant trigger on table "public"."backups" to "anon";

grant truncate on table "public"."backups" to "anon";

grant update on table "public"."backups" to "anon";

grant delete on table "public"."backups" to "authenticated";

grant insert on table "public"."backups" to "authenticated";

grant references on table "public"."backups" to "authenticated";

grant select on table "public"."backups" to "authenticated";

grant trigger on table "public"."backups" to "authenticated";

grant truncate on table "public"."backups" to "authenticated";

grant update on table "public"."backups" to "authenticated";

grant delete on table "public"."backups" to "service_role";

grant insert on table "public"."backups" to "service_role";

grant references on table "public"."backups" to "service_role";

grant select on table "public"."backups" to "service_role";

grant trigger on table "public"."backups" to "service_role";

grant truncate on table "public"."backups" to "service_role";

grant update on table "public"."backups" to "service_role";

grant delete on table "public"."cart_items" to "anon";

grant insert on table "public"."cart_items" to "anon";

grant references on table "public"."cart_items" to "anon";

grant select on table "public"."cart_items" to "anon";

grant trigger on table "public"."cart_items" to "anon";

grant truncate on table "public"."cart_items" to "anon";

grant update on table "public"."cart_items" to "anon";

grant delete on table "public"."cart_items" to "authenticated";

grant insert on table "public"."cart_items" to "authenticated";

grant references on table "public"."cart_items" to "authenticated";

grant select on table "public"."cart_items" to "authenticated";

grant trigger on table "public"."cart_items" to "authenticated";

grant truncate on table "public"."cart_items" to "authenticated";

grant update on table "public"."cart_items" to "authenticated";

grant delete on table "public"."cart_items" to "service_role";

grant insert on table "public"."cart_items" to "service_role";

grant references on table "public"."cart_items" to "service_role";

grant select on table "public"."cart_items" to "service_role";

grant trigger on table "public"."cart_items" to "service_role";

grant truncate on table "public"."cart_items" to "service_role";

grant update on table "public"."cart_items" to "service_role";

grant delete on table "public"."carts" to "anon";

grant insert on table "public"."carts" to "anon";

grant references on table "public"."carts" to "anon";

grant select on table "public"."carts" to "anon";

grant trigger on table "public"."carts" to "anon";

grant truncate on table "public"."carts" to "anon";

grant update on table "public"."carts" to "anon";

grant delete on table "public"."carts" to "authenticated";

grant insert on table "public"."carts" to "authenticated";

grant references on table "public"."carts" to "authenticated";

grant select on table "public"."carts" to "authenticated";

grant trigger on table "public"."carts" to "authenticated";

grant truncate on table "public"."carts" to "authenticated";

grant update on table "public"."carts" to "authenticated";

grant delete on table "public"."carts" to "service_role";

grant insert on table "public"."carts" to "service_role";

grant references on table "public"."carts" to "service_role";

grant select on table "public"."carts" to "service_role";

grant trigger on table "public"."carts" to "service_role";

grant truncate on table "public"."carts" to "service_role";

grant update on table "public"."carts" to "service_role";

grant delete on table "public"."categories" to "anon";

grant insert on table "public"."categories" to "anon";

grant references on table "public"."categories" to "anon";

grant select on table "public"."categories" to "anon";

grant trigger on table "public"."categories" to "anon";

grant truncate on table "public"."categories" to "anon";

grant update on table "public"."categories" to "anon";

grant delete on table "public"."categories" to "authenticated";

grant insert on table "public"."categories" to "authenticated";

grant references on table "public"."categories" to "authenticated";

grant select on table "public"."categories" to "authenticated";

grant trigger on table "public"."categories" to "authenticated";

grant truncate on table "public"."categories" to "authenticated";

grant update on table "public"."categories" to "authenticated";

grant delete on table "public"."categories" to "service_role";

grant insert on table "public"."categories" to "service_role";

grant references on table "public"."categories" to "service_role";

grant select on table "public"."categories" to "service_role";

grant trigger on table "public"."categories" to "service_role";

grant truncate on table "public"."categories" to "service_role";

grant update on table "public"."categories" to "service_role";

grant delete on table "public"."contact_message_tags" to "anon";

grant insert on table "public"."contact_message_tags" to "anon";

grant references on table "public"."contact_message_tags" to "anon";

grant select on table "public"."contact_message_tags" to "anon";

grant trigger on table "public"."contact_message_tags" to "anon";

grant truncate on table "public"."contact_message_tags" to "anon";

grant update on table "public"."contact_message_tags" to "anon";

grant delete on table "public"."contact_message_tags" to "authenticated";

grant insert on table "public"."contact_message_tags" to "authenticated";

grant references on table "public"."contact_message_tags" to "authenticated";

grant select on table "public"."contact_message_tags" to "authenticated";

grant trigger on table "public"."contact_message_tags" to "authenticated";

grant truncate on table "public"."contact_message_tags" to "authenticated";

grant update on table "public"."contact_message_tags" to "authenticated";

grant delete on table "public"."contact_message_tags" to "service_role";

grant insert on table "public"."contact_message_tags" to "service_role";

grant references on table "public"."contact_message_tags" to "service_role";

grant select on table "public"."contact_message_tags" to "service_role";

grant trigger on table "public"."contact_message_tags" to "service_role";

grant truncate on table "public"."contact_message_tags" to "service_role";

grant update on table "public"."contact_message_tags" to "service_role";

grant delete on table "public"."contact_messages" to "anon";

grant insert on table "public"."contact_messages" to "anon";

grant references on table "public"."contact_messages" to "anon";

grant select on table "public"."contact_messages" to "anon";

grant trigger on table "public"."contact_messages" to "anon";

grant truncate on table "public"."contact_messages" to "anon";

grant update on table "public"."contact_messages" to "anon";

grant delete on table "public"."contact_messages" to "authenticated";

grant insert on table "public"."contact_messages" to "authenticated";

grant references on table "public"."contact_messages" to "authenticated";

grant select on table "public"."contact_messages" to "authenticated";

grant trigger on table "public"."contact_messages" to "authenticated";

grant truncate on table "public"."contact_messages" to "authenticated";

grant update on table "public"."contact_messages" to "authenticated";

grant delete on table "public"."contact_messages" to "service_role";

grant insert on table "public"."contact_messages" to "service_role";

grant references on table "public"."contact_messages" to "service_role";

grant select on table "public"."contact_messages" to "service_role";

grant trigger on table "public"."contact_messages" to "service_role";

grant truncate on table "public"."contact_messages" to "service_role";

grant update on table "public"."contact_messages" to "service_role";

grant delete on table "public"."contact_tags" to "anon";

grant insert on table "public"."contact_tags" to "anon";

grant references on table "public"."contact_tags" to "anon";

grant select on table "public"."contact_tags" to "anon";

grant trigger on table "public"."contact_tags" to "anon";

grant truncate on table "public"."contact_tags" to "anon";

grant update on table "public"."contact_tags" to "anon";

grant delete on table "public"."contact_tags" to "authenticated";

grant insert on table "public"."contact_tags" to "authenticated";

grant references on table "public"."contact_tags" to "authenticated";

grant select on table "public"."contact_tags" to "authenticated";

grant trigger on table "public"."contact_tags" to "authenticated";

grant truncate on table "public"."contact_tags" to "authenticated";

grant update on table "public"."contact_tags" to "authenticated";

grant delete on table "public"."contact_tags" to "service_role";

grant insert on table "public"."contact_tags" to "service_role";

grant references on table "public"."contact_tags" to "service_role";

grant select on table "public"."contact_tags" to "service_role";

grant trigger on table "public"."contact_tags" to "service_role";

grant truncate on table "public"."contact_tags" to "service_role";

grant update on table "public"."contact_tags" to "service_role";

grant delete on table "public"."contacts" to "anon";

grant insert on table "public"."contacts" to "anon";

grant references on table "public"."contacts" to "anon";

grant select on table "public"."contacts" to "anon";

grant trigger on table "public"."contacts" to "anon";

grant truncate on table "public"."contacts" to "anon";

grant update on table "public"."contacts" to "anon";

grant delete on table "public"."contacts" to "authenticated";

grant insert on table "public"."contacts" to "authenticated";

grant references on table "public"."contacts" to "authenticated";

grant select on table "public"."contacts" to "authenticated";

grant trigger on table "public"."contacts" to "authenticated";

grant truncate on table "public"."contacts" to "authenticated";

grant update on table "public"."contacts" to "authenticated";

grant delete on table "public"."contacts" to "service_role";

grant insert on table "public"."contacts" to "service_role";

grant references on table "public"."contacts" to "service_role";

grant select on table "public"."contacts" to "service_role";

grant trigger on table "public"."contacts" to "service_role";

grant truncate on table "public"."contacts" to "service_role";

grant update on table "public"."contacts" to "service_role";

grant delete on table "public"."devices" to "anon";

grant insert on table "public"."devices" to "anon";

grant references on table "public"."devices" to "anon";

grant select on table "public"."devices" to "anon";

grant trigger on table "public"."devices" to "anon";

grant truncate on table "public"."devices" to "anon";

grant update on table "public"."devices" to "anon";

grant delete on table "public"."devices" to "authenticated";

grant insert on table "public"."devices" to "authenticated";

grant references on table "public"."devices" to "authenticated";

grant select on table "public"."devices" to "authenticated";

grant trigger on table "public"."devices" to "authenticated";

grant truncate on table "public"."devices" to "authenticated";

grant update on table "public"."devices" to "authenticated";

grant delete on table "public"."devices" to "service_role";

grant insert on table "public"."devices" to "service_role";

grant references on table "public"."devices" to "service_role";

grant select on table "public"."devices" to "service_role";

grant trigger on table "public"."devices" to "service_role";

grant truncate on table "public"."devices" to "service_role";

grant update on table "public"."devices" to "service_role";

grant delete on table "public"."email_logs" to "anon";

grant insert on table "public"."email_logs" to "anon";

grant references on table "public"."email_logs" to "anon";

grant select on table "public"."email_logs" to "anon";

grant trigger on table "public"."email_logs" to "anon";

grant truncate on table "public"."email_logs" to "anon";

grant update on table "public"."email_logs" to "anon";

grant delete on table "public"."email_logs" to "authenticated";

grant insert on table "public"."email_logs" to "authenticated";

grant references on table "public"."email_logs" to "authenticated";

grant select on table "public"."email_logs" to "authenticated";

grant trigger on table "public"."email_logs" to "authenticated";

grant truncate on table "public"."email_logs" to "authenticated";

grant update on table "public"."email_logs" to "authenticated";

grant delete on table "public"."email_logs" to "service_role";

grant insert on table "public"."email_logs" to "service_role";

grant references on table "public"."email_logs" to "service_role";

grant select on table "public"."email_logs" to "service_role";

grant trigger on table "public"."email_logs" to "service_role";

grant truncate on table "public"."email_logs" to "service_role";

grant update on table "public"."email_logs" to "service_role";

grant delete on table "public"."extension_logs" to "anon";

grant insert on table "public"."extension_logs" to "anon";

grant references on table "public"."extension_logs" to "anon";

grant select on table "public"."extension_logs" to "anon";

grant trigger on table "public"."extension_logs" to "anon";

grant truncate on table "public"."extension_logs" to "anon";

grant update on table "public"."extension_logs" to "anon";

grant delete on table "public"."extension_logs" to "authenticated";

grant insert on table "public"."extension_logs" to "authenticated";

grant references on table "public"."extension_logs" to "authenticated";

grant select on table "public"."extension_logs" to "authenticated";

grant trigger on table "public"."extension_logs" to "authenticated";

grant truncate on table "public"."extension_logs" to "authenticated";

grant update on table "public"."extension_logs" to "authenticated";

grant delete on table "public"."extension_logs" to "service_role";

grant insert on table "public"."extension_logs" to "service_role";

grant references on table "public"."extension_logs" to "service_role";

grant select on table "public"."extension_logs" to "service_role";

grant trigger on table "public"."extension_logs" to "service_role";

grant truncate on table "public"."extension_logs" to "service_role";

grant update on table "public"."extension_logs" to "service_role";

grant delete on table "public"."extension_menu_items" to "anon";

grant insert on table "public"."extension_menu_items" to "anon";

grant references on table "public"."extension_menu_items" to "anon";

grant select on table "public"."extension_menu_items" to "anon";

grant trigger on table "public"."extension_menu_items" to "anon";

grant truncate on table "public"."extension_menu_items" to "anon";

grant update on table "public"."extension_menu_items" to "anon";

grant delete on table "public"."extension_menu_items" to "authenticated";

grant insert on table "public"."extension_menu_items" to "authenticated";

grant references on table "public"."extension_menu_items" to "authenticated";

grant select on table "public"."extension_menu_items" to "authenticated";

grant trigger on table "public"."extension_menu_items" to "authenticated";

grant truncate on table "public"."extension_menu_items" to "authenticated";

grant update on table "public"."extension_menu_items" to "authenticated";

grant delete on table "public"."extension_menu_items" to "service_role";

grant insert on table "public"."extension_menu_items" to "service_role";

grant references on table "public"."extension_menu_items" to "service_role";

grant select on table "public"."extension_menu_items" to "service_role";

grant trigger on table "public"."extension_menu_items" to "service_role";

grant truncate on table "public"."extension_menu_items" to "service_role";

grant update on table "public"."extension_menu_items" to "service_role";

grant delete on table "public"."extension_permissions" to "anon";

grant insert on table "public"."extension_permissions" to "anon";

grant references on table "public"."extension_permissions" to "anon";

grant select on table "public"."extension_permissions" to "anon";

grant trigger on table "public"."extension_permissions" to "anon";

grant truncate on table "public"."extension_permissions" to "anon";

grant update on table "public"."extension_permissions" to "anon";

grant delete on table "public"."extension_permissions" to "authenticated";

grant insert on table "public"."extension_permissions" to "authenticated";

grant references on table "public"."extension_permissions" to "authenticated";

grant select on table "public"."extension_permissions" to "authenticated";

grant trigger on table "public"."extension_permissions" to "authenticated";

grant truncate on table "public"."extension_permissions" to "authenticated";

grant update on table "public"."extension_permissions" to "authenticated";

grant delete on table "public"."extension_permissions" to "service_role";

grant insert on table "public"."extension_permissions" to "service_role";

grant references on table "public"."extension_permissions" to "service_role";

grant select on table "public"."extension_permissions" to "service_role";

grant trigger on table "public"."extension_permissions" to "service_role";

grant truncate on table "public"."extension_permissions" to "service_role";

grant update on table "public"."extension_permissions" to "service_role";

grant delete on table "public"."extension_rbac_integration" to "anon";

grant insert on table "public"."extension_rbac_integration" to "anon";

grant references on table "public"."extension_rbac_integration" to "anon";

grant select on table "public"."extension_rbac_integration" to "anon";

grant trigger on table "public"."extension_rbac_integration" to "anon";

grant truncate on table "public"."extension_rbac_integration" to "anon";

grant update on table "public"."extension_rbac_integration" to "anon";

grant delete on table "public"."extension_rbac_integration" to "authenticated";

grant insert on table "public"."extension_rbac_integration" to "authenticated";

grant references on table "public"."extension_rbac_integration" to "authenticated";

grant select on table "public"."extension_rbac_integration" to "authenticated";

grant trigger on table "public"."extension_rbac_integration" to "authenticated";

grant truncate on table "public"."extension_rbac_integration" to "authenticated";

grant update on table "public"."extension_rbac_integration" to "authenticated";

grant delete on table "public"."extension_rbac_integration" to "service_role";

grant insert on table "public"."extension_rbac_integration" to "service_role";

grant references on table "public"."extension_rbac_integration" to "service_role";

grant select on table "public"."extension_rbac_integration" to "service_role";

grant trigger on table "public"."extension_rbac_integration" to "service_role";

grant truncate on table "public"."extension_rbac_integration" to "service_role";

grant update on table "public"."extension_rbac_integration" to "service_role";

grant delete on table "public"."extension_routes" to "anon";

grant insert on table "public"."extension_routes" to "anon";

grant references on table "public"."extension_routes" to "anon";

grant select on table "public"."extension_routes" to "anon";

grant trigger on table "public"."extension_routes" to "anon";

grant truncate on table "public"."extension_routes" to "anon";

grant update on table "public"."extension_routes" to "anon";

grant delete on table "public"."extension_routes" to "authenticated";

grant insert on table "public"."extension_routes" to "authenticated";

grant references on table "public"."extension_routes" to "authenticated";

grant select on table "public"."extension_routes" to "authenticated";

grant trigger on table "public"."extension_routes" to "authenticated";

grant truncate on table "public"."extension_routes" to "authenticated";

grant update on table "public"."extension_routes" to "authenticated";

grant delete on table "public"."extension_routes" to "service_role";

grant insert on table "public"."extension_routes" to "service_role";

grant references on table "public"."extension_routes" to "service_role";

grant select on table "public"."extension_routes" to "service_role";

grant trigger on table "public"."extension_routes" to "service_role";

grant truncate on table "public"."extension_routes" to "service_role";

grant update on table "public"."extension_routes" to "service_role";

grant delete on table "public"."extension_routes_registry" to "anon";

grant insert on table "public"."extension_routes_registry" to "anon";

grant references on table "public"."extension_routes_registry" to "anon";

grant select on table "public"."extension_routes_registry" to "anon";

grant trigger on table "public"."extension_routes_registry" to "anon";

grant truncate on table "public"."extension_routes_registry" to "anon";

grant update on table "public"."extension_routes_registry" to "anon";

grant delete on table "public"."extension_routes_registry" to "authenticated";

grant insert on table "public"."extension_routes_registry" to "authenticated";

grant references on table "public"."extension_routes_registry" to "authenticated";

grant select on table "public"."extension_routes_registry" to "authenticated";

grant trigger on table "public"."extension_routes_registry" to "authenticated";

grant truncate on table "public"."extension_routes_registry" to "authenticated";

grant update on table "public"."extension_routes_registry" to "authenticated";

grant delete on table "public"."extension_routes_registry" to "service_role";

grant insert on table "public"."extension_routes_registry" to "service_role";

grant references on table "public"."extension_routes_registry" to "service_role";

grant select on table "public"."extension_routes_registry" to "service_role";

grant trigger on table "public"."extension_routes_registry" to "service_role";

grant truncate on table "public"."extension_routes_registry" to "service_role";

grant update on table "public"."extension_routes_registry" to "service_role";

grant delete on table "public"."extensions" to "anon";

grant insert on table "public"."extensions" to "anon";

grant references on table "public"."extensions" to "anon";

grant select on table "public"."extensions" to "anon";

grant trigger on table "public"."extensions" to "anon";

grant truncate on table "public"."extensions" to "anon";

grant update on table "public"."extensions" to "anon";

grant delete on table "public"."extensions" to "authenticated";

grant insert on table "public"."extensions" to "authenticated";

grant references on table "public"."extensions" to "authenticated";

grant select on table "public"."extensions" to "authenticated";

grant trigger on table "public"."extensions" to "authenticated";

grant truncate on table "public"."extensions" to "authenticated";

grant update on table "public"."extensions" to "authenticated";

grant delete on table "public"."extensions" to "service_role";

grant insert on table "public"."extensions" to "service_role";

grant references on table "public"."extensions" to "service_role";

grant select on table "public"."extensions" to "service_role";

grant trigger on table "public"."extensions" to "service_role";

grant truncate on table "public"."extensions" to "service_role";

grant update on table "public"."extensions" to "service_role";

grant delete on table "public"."file_permissions" to "anon";

grant insert on table "public"."file_permissions" to "anon";

grant references on table "public"."file_permissions" to "anon";

grant select on table "public"."file_permissions" to "anon";

grant trigger on table "public"."file_permissions" to "anon";

grant truncate on table "public"."file_permissions" to "anon";

grant update on table "public"."file_permissions" to "anon";

grant delete on table "public"."file_permissions" to "authenticated";

grant insert on table "public"."file_permissions" to "authenticated";

grant references on table "public"."file_permissions" to "authenticated";

grant select on table "public"."file_permissions" to "authenticated";

grant trigger on table "public"."file_permissions" to "authenticated";

grant truncate on table "public"."file_permissions" to "authenticated";

grant update on table "public"."file_permissions" to "authenticated";

grant delete on table "public"."file_permissions" to "service_role";

grant insert on table "public"."file_permissions" to "service_role";

grant references on table "public"."file_permissions" to "service_role";

grant select on table "public"."file_permissions" to "service_role";

grant trigger on table "public"."file_permissions" to "service_role";

grant truncate on table "public"."file_permissions" to "service_role";

grant update on table "public"."file_permissions" to "service_role";

grant delete on table "public"."files" to "anon";

grant insert on table "public"."files" to "anon";

grant references on table "public"."files" to "anon";

grant select on table "public"."files" to "anon";

grant trigger on table "public"."files" to "anon";

grant truncate on table "public"."files" to "anon";

grant update on table "public"."files" to "anon";

grant delete on table "public"."files" to "authenticated";

grant insert on table "public"."files" to "authenticated";

grant references on table "public"."files" to "authenticated";

grant select on table "public"."files" to "authenticated";

grant trigger on table "public"."files" to "authenticated";

grant truncate on table "public"."files" to "authenticated";

grant update on table "public"."files" to "authenticated";

grant delete on table "public"."files" to "service_role";

grant insert on table "public"."files" to "service_role";

grant references on table "public"."files" to "service_role";

grant select on table "public"."files" to "service_role";

grant trigger on table "public"."files" to "service_role";

grant truncate on table "public"."files" to "service_role";

grant update on table "public"."files" to "service_role";

grant delete on table "public"."menu_permissions" to "anon";

grant insert on table "public"."menu_permissions" to "anon";

grant references on table "public"."menu_permissions" to "anon";

grant select on table "public"."menu_permissions" to "anon";

grant trigger on table "public"."menu_permissions" to "anon";

grant truncate on table "public"."menu_permissions" to "anon";

grant update on table "public"."menu_permissions" to "anon";

grant delete on table "public"."menu_permissions" to "authenticated";

grant insert on table "public"."menu_permissions" to "authenticated";

grant references on table "public"."menu_permissions" to "authenticated";

grant select on table "public"."menu_permissions" to "authenticated";

grant trigger on table "public"."menu_permissions" to "authenticated";

grant truncate on table "public"."menu_permissions" to "authenticated";

grant update on table "public"."menu_permissions" to "authenticated";

grant delete on table "public"."menu_permissions" to "service_role";

grant insert on table "public"."menu_permissions" to "service_role";

grant references on table "public"."menu_permissions" to "service_role";

grant select on table "public"."menu_permissions" to "service_role";

grant trigger on table "public"."menu_permissions" to "service_role";

grant truncate on table "public"."menu_permissions" to "service_role";

grant update on table "public"."menu_permissions" to "service_role";

grant delete on table "public"."mobile_app_config" to "anon";

grant insert on table "public"."mobile_app_config" to "anon";

grant references on table "public"."mobile_app_config" to "anon";

grant select on table "public"."mobile_app_config" to "anon";

grant trigger on table "public"."mobile_app_config" to "anon";

grant truncate on table "public"."mobile_app_config" to "anon";

grant update on table "public"."mobile_app_config" to "anon";

grant delete on table "public"."mobile_app_config" to "authenticated";

grant insert on table "public"."mobile_app_config" to "authenticated";

grant references on table "public"."mobile_app_config" to "authenticated";

grant select on table "public"."mobile_app_config" to "authenticated";

grant trigger on table "public"."mobile_app_config" to "authenticated";

grant truncate on table "public"."mobile_app_config" to "authenticated";

grant update on table "public"."mobile_app_config" to "authenticated";

grant delete on table "public"."mobile_app_config" to "service_role";

grant insert on table "public"."mobile_app_config" to "service_role";

grant references on table "public"."mobile_app_config" to "service_role";

grant select on table "public"."mobile_app_config" to "service_role";

grant trigger on table "public"."mobile_app_config" to "service_role";

grant truncate on table "public"."mobile_app_config" to "service_role";

grant update on table "public"."mobile_app_config" to "service_role";

grant delete on table "public"."mobile_users" to "anon";

grant insert on table "public"."mobile_users" to "anon";

grant references on table "public"."mobile_users" to "anon";

grant select on table "public"."mobile_users" to "anon";

grant trigger on table "public"."mobile_users" to "anon";

grant truncate on table "public"."mobile_users" to "anon";

grant update on table "public"."mobile_users" to "anon";

grant delete on table "public"."mobile_users" to "authenticated";

grant insert on table "public"."mobile_users" to "authenticated";

grant references on table "public"."mobile_users" to "authenticated";

grant select on table "public"."mobile_users" to "authenticated";

grant trigger on table "public"."mobile_users" to "authenticated";

grant truncate on table "public"."mobile_users" to "authenticated";

grant update on table "public"."mobile_users" to "authenticated";

grant delete on table "public"."mobile_users" to "service_role";

grant insert on table "public"."mobile_users" to "service_role";

grant references on table "public"."mobile_users" to "service_role";

grant select on table "public"."mobile_users" to "service_role";

grant trigger on table "public"."mobile_users" to "service_role";

grant truncate on table "public"."mobile_users" to "service_role";

grant update on table "public"."mobile_users" to "service_role";

grant delete on table "public"."notification_readers" to "anon";

grant insert on table "public"."notification_readers" to "anon";

grant references on table "public"."notification_readers" to "anon";

grant select on table "public"."notification_readers" to "anon";

grant trigger on table "public"."notification_readers" to "anon";

grant truncate on table "public"."notification_readers" to "anon";

grant update on table "public"."notification_readers" to "anon";

grant delete on table "public"."notification_readers" to "authenticated";

grant insert on table "public"."notification_readers" to "authenticated";

grant references on table "public"."notification_readers" to "authenticated";

grant select on table "public"."notification_readers" to "authenticated";

grant trigger on table "public"."notification_readers" to "authenticated";

grant truncate on table "public"."notification_readers" to "authenticated";

grant update on table "public"."notification_readers" to "authenticated";

grant delete on table "public"."notification_readers" to "service_role";

grant insert on table "public"."notification_readers" to "service_role";

grant references on table "public"."notification_readers" to "service_role";

grant select on table "public"."notification_readers" to "service_role";

grant trigger on table "public"."notification_readers" to "service_role";

grant truncate on table "public"."notification_readers" to "service_role";

grant update on table "public"."notification_readers" to "service_role";

grant delete on table "public"."notifications" to "anon";

grant insert on table "public"."notifications" to "anon";

grant references on table "public"."notifications" to "anon";

grant select on table "public"."notifications" to "anon";

grant trigger on table "public"."notifications" to "anon";

grant truncate on table "public"."notifications" to "anon";

grant update on table "public"."notifications" to "anon";

grant delete on table "public"."notifications" to "authenticated";

grant insert on table "public"."notifications" to "authenticated";

grant references on table "public"."notifications" to "authenticated";

grant select on table "public"."notifications" to "authenticated";

grant trigger on table "public"."notifications" to "authenticated";

grant truncate on table "public"."notifications" to "authenticated";

grant update on table "public"."notifications" to "authenticated";

grant delete on table "public"."notifications" to "service_role";

grant insert on table "public"."notifications" to "service_role";

grant references on table "public"."notifications" to "service_role";

grant select on table "public"."notifications" to "service_role";

grant trigger on table "public"."notifications" to "service_role";

grant truncate on table "public"."notifications" to "service_role";

grant update on table "public"."notifications" to "service_role";

grant delete on table "public"."order_items" to "anon";

grant insert on table "public"."order_items" to "anon";

grant references on table "public"."order_items" to "anon";

grant select on table "public"."order_items" to "anon";

grant trigger on table "public"."order_items" to "anon";

grant truncate on table "public"."order_items" to "anon";

grant update on table "public"."order_items" to "anon";

grant delete on table "public"."order_items" to "authenticated";

grant insert on table "public"."order_items" to "authenticated";

grant references on table "public"."order_items" to "authenticated";

grant select on table "public"."order_items" to "authenticated";

grant trigger on table "public"."order_items" to "authenticated";

grant truncate on table "public"."order_items" to "authenticated";

grant update on table "public"."order_items" to "authenticated";

grant delete on table "public"."order_items" to "service_role";

grant insert on table "public"."order_items" to "service_role";

grant references on table "public"."order_items" to "service_role";

grant select on table "public"."order_items" to "service_role";

grant trigger on table "public"."order_items" to "service_role";

grant truncate on table "public"."order_items" to "service_role";

grant update on table "public"."order_items" to "service_role";

grant delete on table "public"."orders" to "anon";

grant insert on table "public"."orders" to "anon";

grant references on table "public"."orders" to "anon";

grant select on table "public"."orders" to "anon";

grant trigger on table "public"."orders" to "anon";

grant truncate on table "public"."orders" to "anon";

grant update on table "public"."orders" to "anon";

grant delete on table "public"."orders" to "authenticated";

grant insert on table "public"."orders" to "authenticated";

grant references on table "public"."orders" to "authenticated";

grant select on table "public"."orders" to "authenticated";

grant trigger on table "public"."orders" to "authenticated";

grant truncate on table "public"."orders" to "authenticated";

grant update on table "public"."orders" to "authenticated";

grant delete on table "public"."orders" to "service_role";

grant insert on table "public"."orders" to "service_role";

grant references on table "public"."orders" to "service_role";

grant select on table "public"."orders" to "service_role";

grant trigger on table "public"."orders" to "service_role";

grant truncate on table "public"."orders" to "service_role";

grant update on table "public"."orders" to "service_role";

grant delete on table "public"."page_categories" to "anon";

grant insert on table "public"."page_categories" to "anon";

grant references on table "public"."page_categories" to "anon";

grant select on table "public"."page_categories" to "anon";

grant trigger on table "public"."page_categories" to "anon";

grant truncate on table "public"."page_categories" to "anon";

grant update on table "public"."page_categories" to "anon";

grant delete on table "public"."page_categories" to "authenticated";

grant insert on table "public"."page_categories" to "authenticated";

grant references on table "public"."page_categories" to "authenticated";

grant select on table "public"."page_categories" to "authenticated";

grant trigger on table "public"."page_categories" to "authenticated";

grant truncate on table "public"."page_categories" to "authenticated";

grant update on table "public"."page_categories" to "authenticated";

grant delete on table "public"."page_categories" to "service_role";

grant insert on table "public"."page_categories" to "service_role";

grant references on table "public"."page_categories" to "service_role";

grant select on table "public"."page_categories" to "service_role";

grant trigger on table "public"."page_categories" to "service_role";

grant truncate on table "public"."page_categories" to "service_role";

grant update on table "public"."page_categories" to "service_role";

grant delete on table "public"."page_tags" to "anon";

grant insert on table "public"."page_tags" to "anon";

grant references on table "public"."page_tags" to "anon";

grant select on table "public"."page_tags" to "anon";

grant trigger on table "public"."page_tags" to "anon";

grant truncate on table "public"."page_tags" to "anon";

grant update on table "public"."page_tags" to "anon";

grant delete on table "public"."page_tags" to "authenticated";

grant insert on table "public"."page_tags" to "authenticated";

grant references on table "public"."page_tags" to "authenticated";

grant select on table "public"."page_tags" to "authenticated";

grant trigger on table "public"."page_tags" to "authenticated";

grant truncate on table "public"."page_tags" to "authenticated";

grant update on table "public"."page_tags" to "authenticated";

grant delete on table "public"."page_tags" to "service_role";

grant insert on table "public"."page_tags" to "service_role";

grant references on table "public"."page_tags" to "service_role";

grant select on table "public"."page_tags" to "service_role";

grant trigger on table "public"."page_tags" to "service_role";

grant truncate on table "public"."page_tags" to "service_role";

grant update on table "public"."page_tags" to "service_role";

grant delete on table "public"."pages" to "anon";

grant insert on table "public"."pages" to "anon";

grant references on table "public"."pages" to "anon";

grant select on table "public"."pages" to "anon";

grant trigger on table "public"."pages" to "anon";

grant truncate on table "public"."pages" to "anon";

grant update on table "public"."pages" to "anon";

grant delete on table "public"."pages" to "authenticated";

grant insert on table "public"."pages" to "authenticated";

grant references on table "public"."pages" to "authenticated";

grant select on table "public"."pages" to "authenticated";

grant trigger on table "public"."pages" to "authenticated";

grant truncate on table "public"."pages" to "authenticated";

grant update on table "public"."pages" to "authenticated";

grant delete on table "public"."pages" to "service_role";

grant insert on table "public"."pages" to "service_role";

grant references on table "public"."pages" to "service_role";

grant select on table "public"."pages" to "service_role";

grant trigger on table "public"."pages" to "service_role";

grant truncate on table "public"."pages" to "service_role";

grant update on table "public"."pages" to "service_role";

grant delete on table "public"."payment_methods" to "anon";

grant insert on table "public"."payment_methods" to "anon";

grant references on table "public"."payment_methods" to "anon";

grant select on table "public"."payment_methods" to "anon";

grant trigger on table "public"."payment_methods" to "anon";

grant truncate on table "public"."payment_methods" to "anon";

grant update on table "public"."payment_methods" to "anon";

grant delete on table "public"."payment_methods" to "authenticated";

grant insert on table "public"."payment_methods" to "authenticated";

grant references on table "public"."payment_methods" to "authenticated";

grant select on table "public"."payment_methods" to "authenticated";

grant trigger on table "public"."payment_methods" to "authenticated";

grant truncate on table "public"."payment_methods" to "authenticated";

grant update on table "public"."payment_methods" to "authenticated";

grant delete on table "public"."payment_methods" to "service_role";

grant insert on table "public"."payment_methods" to "service_role";

grant references on table "public"."payment_methods" to "service_role";

grant select on table "public"."payment_methods" to "service_role";

grant trigger on table "public"."payment_methods" to "service_role";

grant truncate on table "public"."payment_methods" to "service_role";

grant update on table "public"."payment_methods" to "service_role";

grant delete on table "public"."payments" to "anon";

grant insert on table "public"."payments" to "anon";

grant references on table "public"."payments" to "anon";

grant select on table "public"."payments" to "anon";

grant trigger on table "public"."payments" to "anon";

grant truncate on table "public"."payments" to "anon";

grant update on table "public"."payments" to "anon";

grant delete on table "public"."payments" to "authenticated";

grant insert on table "public"."payments" to "authenticated";

grant references on table "public"."payments" to "authenticated";

grant select on table "public"."payments" to "authenticated";

grant trigger on table "public"."payments" to "authenticated";

grant truncate on table "public"."payments" to "authenticated";

grant update on table "public"."payments" to "authenticated";

grant delete on table "public"."payments" to "service_role";

grant insert on table "public"."payments" to "service_role";

grant references on table "public"."payments" to "service_role";

grant select on table "public"."payments" to "service_role";

grant trigger on table "public"."payments" to "service_role";

grant truncate on table "public"."payments" to "service_role";

grant update on table "public"."payments" to "service_role";

grant delete on table "public"."photo_gallery" to "anon";

grant insert on table "public"."photo_gallery" to "anon";

grant references on table "public"."photo_gallery" to "anon";

grant select on table "public"."photo_gallery" to "anon";

grant trigger on table "public"."photo_gallery" to "anon";

grant truncate on table "public"."photo_gallery" to "anon";

grant update on table "public"."photo_gallery" to "anon";

grant delete on table "public"."photo_gallery" to "authenticated";

grant insert on table "public"."photo_gallery" to "authenticated";

grant references on table "public"."photo_gallery" to "authenticated";

grant select on table "public"."photo_gallery" to "authenticated";

grant trigger on table "public"."photo_gallery" to "authenticated";

grant truncate on table "public"."photo_gallery" to "authenticated";

grant update on table "public"."photo_gallery" to "authenticated";

grant delete on table "public"."photo_gallery" to "service_role";

grant insert on table "public"."photo_gallery" to "service_role";

grant references on table "public"."photo_gallery" to "service_role";

grant select on table "public"."photo_gallery" to "service_role";

grant trigger on table "public"."photo_gallery" to "service_role";

grant truncate on table "public"."photo_gallery" to "service_role";

grant update on table "public"."photo_gallery" to "service_role";

grant delete on table "public"."photo_gallery_tags" to "anon";

grant insert on table "public"."photo_gallery_tags" to "anon";

grant references on table "public"."photo_gallery_tags" to "anon";

grant select on table "public"."photo_gallery_tags" to "anon";

grant trigger on table "public"."photo_gallery_tags" to "anon";

grant truncate on table "public"."photo_gallery_tags" to "anon";

grant update on table "public"."photo_gallery_tags" to "anon";

grant delete on table "public"."photo_gallery_tags" to "authenticated";

grant insert on table "public"."photo_gallery_tags" to "authenticated";

grant references on table "public"."photo_gallery_tags" to "authenticated";

grant select on table "public"."photo_gallery_tags" to "authenticated";

grant trigger on table "public"."photo_gallery_tags" to "authenticated";

grant truncate on table "public"."photo_gallery_tags" to "authenticated";

grant update on table "public"."photo_gallery_tags" to "authenticated";

grant delete on table "public"."photo_gallery_tags" to "service_role";

grant insert on table "public"."photo_gallery_tags" to "service_role";

grant references on table "public"."photo_gallery_tags" to "service_role";

grant select on table "public"."photo_gallery_tags" to "service_role";

grant trigger on table "public"."photo_gallery_tags" to "service_role";

grant truncate on table "public"."photo_gallery_tags" to "service_role";

grant update on table "public"."photo_gallery_tags" to "service_role";

grant delete on table "public"."portfolio" to "anon";

grant insert on table "public"."portfolio" to "anon";

grant references on table "public"."portfolio" to "anon";

grant select on table "public"."portfolio" to "anon";

grant trigger on table "public"."portfolio" to "anon";

grant truncate on table "public"."portfolio" to "anon";

grant update on table "public"."portfolio" to "anon";

grant delete on table "public"."portfolio" to "authenticated";

grant insert on table "public"."portfolio" to "authenticated";

grant references on table "public"."portfolio" to "authenticated";

grant select on table "public"."portfolio" to "authenticated";

grant trigger on table "public"."portfolio" to "authenticated";

grant truncate on table "public"."portfolio" to "authenticated";

grant update on table "public"."portfolio" to "authenticated";

grant delete on table "public"."portfolio" to "service_role";

grant insert on table "public"."portfolio" to "service_role";

grant references on table "public"."portfolio" to "service_role";

grant select on table "public"."portfolio" to "service_role";

grant trigger on table "public"."portfolio" to "service_role";

grant truncate on table "public"."portfolio" to "service_role";

grant update on table "public"."portfolio" to "service_role";

grant delete on table "public"."portfolio_tags" to "anon";

grant insert on table "public"."portfolio_tags" to "anon";

grant references on table "public"."portfolio_tags" to "anon";

grant select on table "public"."portfolio_tags" to "anon";

grant trigger on table "public"."portfolio_tags" to "anon";

grant truncate on table "public"."portfolio_tags" to "anon";

grant update on table "public"."portfolio_tags" to "anon";

grant delete on table "public"."portfolio_tags" to "authenticated";

grant insert on table "public"."portfolio_tags" to "authenticated";

grant references on table "public"."portfolio_tags" to "authenticated";

grant select on table "public"."portfolio_tags" to "authenticated";

grant trigger on table "public"."portfolio_tags" to "authenticated";

grant truncate on table "public"."portfolio_tags" to "authenticated";

grant update on table "public"."portfolio_tags" to "authenticated";

grant delete on table "public"."portfolio_tags" to "service_role";

grant insert on table "public"."portfolio_tags" to "service_role";

grant references on table "public"."portfolio_tags" to "service_role";

grant select on table "public"."portfolio_tags" to "service_role";

grant trigger on table "public"."portfolio_tags" to "service_role";

grant truncate on table "public"."portfolio_tags" to "service_role";

grant update on table "public"."portfolio_tags" to "service_role";

grant delete on table "public"."product_tags" to "anon";

grant insert on table "public"."product_tags" to "anon";

grant references on table "public"."product_tags" to "anon";

grant select on table "public"."product_tags" to "anon";

grant trigger on table "public"."product_tags" to "anon";

grant truncate on table "public"."product_tags" to "anon";

grant update on table "public"."product_tags" to "anon";

grant delete on table "public"."product_tags" to "authenticated";

grant insert on table "public"."product_tags" to "authenticated";

grant references on table "public"."product_tags" to "authenticated";

grant select on table "public"."product_tags" to "authenticated";

grant trigger on table "public"."product_tags" to "authenticated";

grant truncate on table "public"."product_tags" to "authenticated";

grant update on table "public"."product_tags" to "authenticated";

grant delete on table "public"."product_tags" to "service_role";

grant insert on table "public"."product_tags" to "service_role";

grant references on table "public"."product_tags" to "service_role";

grant select on table "public"."product_tags" to "service_role";

grant trigger on table "public"."product_tags" to "service_role";

grant truncate on table "public"."product_tags" to "service_role";

grant update on table "public"."product_tags" to "service_role";

grant delete on table "public"."product_type_tags" to "anon";

grant insert on table "public"."product_type_tags" to "anon";

grant references on table "public"."product_type_tags" to "anon";

grant select on table "public"."product_type_tags" to "anon";

grant trigger on table "public"."product_type_tags" to "anon";

grant truncate on table "public"."product_type_tags" to "anon";

grant update on table "public"."product_type_tags" to "anon";

grant delete on table "public"."product_type_tags" to "authenticated";

grant insert on table "public"."product_type_tags" to "authenticated";

grant references on table "public"."product_type_tags" to "authenticated";

grant select on table "public"."product_type_tags" to "authenticated";

grant trigger on table "public"."product_type_tags" to "authenticated";

grant truncate on table "public"."product_type_tags" to "authenticated";

grant update on table "public"."product_type_tags" to "authenticated";

grant delete on table "public"."product_type_tags" to "service_role";

grant insert on table "public"."product_type_tags" to "service_role";

grant references on table "public"."product_type_tags" to "service_role";

grant select on table "public"."product_type_tags" to "service_role";

grant trigger on table "public"."product_type_tags" to "service_role";

grant truncate on table "public"."product_type_tags" to "service_role";

grant update on table "public"."product_type_tags" to "service_role";

grant delete on table "public"."product_types" to "anon";

grant insert on table "public"."product_types" to "anon";

grant references on table "public"."product_types" to "anon";

grant select on table "public"."product_types" to "anon";

grant trigger on table "public"."product_types" to "anon";

grant truncate on table "public"."product_types" to "anon";

grant update on table "public"."product_types" to "anon";

grant delete on table "public"."product_types" to "authenticated";

grant insert on table "public"."product_types" to "authenticated";

grant references on table "public"."product_types" to "authenticated";

grant select on table "public"."product_types" to "authenticated";

grant trigger on table "public"."product_types" to "authenticated";

grant truncate on table "public"."product_types" to "authenticated";

grant update on table "public"."product_types" to "authenticated";

grant delete on table "public"."product_types" to "service_role";

grant insert on table "public"."product_types" to "service_role";

grant references on table "public"."product_types" to "service_role";

grant select on table "public"."product_types" to "service_role";

grant trigger on table "public"."product_types" to "service_role";

grant truncate on table "public"."product_types" to "service_role";

grant update on table "public"."product_types" to "service_role";

grant delete on table "public"."products" to "anon";

grant insert on table "public"."products" to "anon";

grant references on table "public"."products" to "anon";

grant select on table "public"."products" to "anon";

grant trigger on table "public"."products" to "anon";

grant truncate on table "public"."products" to "anon";

grant update on table "public"."products" to "anon";

grant delete on table "public"."products" to "authenticated";

grant insert on table "public"."products" to "authenticated";

grant references on table "public"."products" to "authenticated";

grant select on table "public"."products" to "authenticated";

grant trigger on table "public"."products" to "authenticated";

grant truncate on table "public"."products" to "authenticated";

grant update on table "public"."products" to "authenticated";

grant delete on table "public"."products" to "service_role";

grant insert on table "public"."products" to "service_role";

grant references on table "public"."products" to "service_role";

grant select on table "public"."products" to "service_role";

grant trigger on table "public"."products" to "service_role";

grant truncate on table "public"."products" to "service_role";

grant update on table "public"."products" to "service_role";

grant delete on table "public"."promotion_tags" to "anon";

grant insert on table "public"."promotion_tags" to "anon";

grant references on table "public"."promotion_tags" to "anon";

grant select on table "public"."promotion_tags" to "anon";

grant trigger on table "public"."promotion_tags" to "anon";

grant truncate on table "public"."promotion_tags" to "anon";

grant update on table "public"."promotion_tags" to "anon";

grant delete on table "public"."promotion_tags" to "authenticated";

grant insert on table "public"."promotion_tags" to "authenticated";

grant references on table "public"."promotion_tags" to "authenticated";

grant select on table "public"."promotion_tags" to "authenticated";

grant trigger on table "public"."promotion_tags" to "authenticated";

grant truncate on table "public"."promotion_tags" to "authenticated";

grant update on table "public"."promotion_tags" to "authenticated";

grant delete on table "public"."promotion_tags" to "service_role";

grant insert on table "public"."promotion_tags" to "service_role";

grant references on table "public"."promotion_tags" to "service_role";

grant select on table "public"."promotion_tags" to "service_role";

grant trigger on table "public"."promotion_tags" to "service_role";

grant truncate on table "public"."promotion_tags" to "service_role";

grant update on table "public"."promotion_tags" to "service_role";

grant delete on table "public"."promotions" to "anon";

grant insert on table "public"."promotions" to "anon";

grant references on table "public"."promotions" to "anon";

grant select on table "public"."promotions" to "anon";

grant trigger on table "public"."promotions" to "anon";

grant truncate on table "public"."promotions" to "anon";

grant update on table "public"."promotions" to "anon";

grant delete on table "public"."promotions" to "authenticated";

grant insert on table "public"."promotions" to "authenticated";

grant references on table "public"."promotions" to "authenticated";

grant select on table "public"."promotions" to "authenticated";

grant trigger on table "public"."promotions" to "authenticated";

grant truncate on table "public"."promotions" to "authenticated";

grant update on table "public"."promotions" to "authenticated";

grant delete on table "public"."promotions" to "service_role";

grant insert on table "public"."promotions" to "service_role";

grant references on table "public"."promotions" to "service_role";

grant select on table "public"."promotions" to "service_role";

grant trigger on table "public"."promotions" to "service_role";

grant truncate on table "public"."promotions" to "service_role";

grant update on table "public"."promotions" to "service_role";

grant delete on table "public"."push_notifications" to "anon";

grant insert on table "public"."push_notifications" to "anon";

grant references on table "public"."push_notifications" to "anon";

grant select on table "public"."push_notifications" to "anon";

grant trigger on table "public"."push_notifications" to "anon";

grant truncate on table "public"."push_notifications" to "anon";

grant update on table "public"."push_notifications" to "anon";

grant delete on table "public"."push_notifications" to "authenticated";

grant insert on table "public"."push_notifications" to "authenticated";

grant references on table "public"."push_notifications" to "authenticated";

grant select on table "public"."push_notifications" to "authenticated";

grant trigger on table "public"."push_notifications" to "authenticated";

grant truncate on table "public"."push_notifications" to "authenticated";

grant update on table "public"."push_notifications" to "authenticated";

grant delete on table "public"."push_notifications" to "service_role";

grant insert on table "public"."push_notifications" to "service_role";

grant references on table "public"."push_notifications" to "service_role";

grant select on table "public"."push_notifications" to "service_role";

grant trigger on table "public"."push_notifications" to "service_role";

grant truncate on table "public"."push_notifications" to "service_role";

grant update on table "public"."push_notifications" to "service_role";

grant delete on table "public"."region_levels" to "anon";

grant insert on table "public"."region_levels" to "anon";

grant references on table "public"."region_levels" to "anon";

grant select on table "public"."region_levels" to "anon";

grant trigger on table "public"."region_levels" to "anon";

grant truncate on table "public"."region_levels" to "anon";

grant update on table "public"."region_levels" to "anon";

grant delete on table "public"."region_levels" to "authenticated";

grant insert on table "public"."region_levels" to "authenticated";

grant references on table "public"."region_levels" to "authenticated";

grant select on table "public"."region_levels" to "authenticated";

grant trigger on table "public"."region_levels" to "authenticated";

grant truncate on table "public"."region_levels" to "authenticated";

grant update on table "public"."region_levels" to "authenticated";

grant delete on table "public"."region_levels" to "service_role";

grant insert on table "public"."region_levels" to "service_role";

grant references on table "public"."region_levels" to "service_role";

grant select on table "public"."region_levels" to "service_role";

grant trigger on table "public"."region_levels" to "service_role";

grant truncate on table "public"."region_levels" to "service_role";

grant update on table "public"."region_levels" to "service_role";

grant delete on table "public"."regions" to "anon";

grant insert on table "public"."regions" to "anon";

grant references on table "public"."regions" to "anon";

grant select on table "public"."regions" to "anon";

grant trigger on table "public"."regions" to "anon";

grant truncate on table "public"."regions" to "anon";

grant update on table "public"."regions" to "anon";

grant delete on table "public"."regions" to "authenticated";

grant insert on table "public"."regions" to "authenticated";

grant references on table "public"."regions" to "authenticated";

grant select on table "public"."regions" to "authenticated";

grant trigger on table "public"."regions" to "authenticated";

grant truncate on table "public"."regions" to "authenticated";

grant update on table "public"."regions" to "authenticated";

grant delete on table "public"."regions" to "service_role";

grant insert on table "public"."regions" to "service_role";

grant references on table "public"."regions" to "service_role";

grant select on table "public"."regions" to "service_role";

grant trigger on table "public"."regions" to "service_role";

grant truncate on table "public"."regions" to "service_role";

grant update on table "public"."regions" to "service_role";

grant delete on table "public"."sensor_readings" to "anon";

grant insert on table "public"."sensor_readings" to "anon";

grant references on table "public"."sensor_readings" to "anon";

grant select on table "public"."sensor_readings" to "anon";

grant trigger on table "public"."sensor_readings" to "anon";

grant truncate on table "public"."sensor_readings" to "anon";

grant update on table "public"."sensor_readings" to "anon";

grant delete on table "public"."sensor_readings" to "authenticated";

grant insert on table "public"."sensor_readings" to "authenticated";

grant references on table "public"."sensor_readings" to "authenticated";

grant select on table "public"."sensor_readings" to "authenticated";

grant trigger on table "public"."sensor_readings" to "authenticated";

grant truncate on table "public"."sensor_readings" to "authenticated";

grant update on table "public"."sensor_readings" to "authenticated";

grant delete on table "public"."sensor_readings" to "service_role";

grant insert on table "public"."sensor_readings" to "service_role";

grant references on table "public"."sensor_readings" to "service_role";

grant select on table "public"."sensor_readings" to "service_role";

grant trigger on table "public"."sensor_readings" to "service_role";

grant truncate on table "public"."sensor_readings" to "service_role";

grant update on table "public"."sensor_readings" to "service_role";

grant delete on table "public"."seo_metadata" to "anon";

grant insert on table "public"."seo_metadata" to "anon";

grant references on table "public"."seo_metadata" to "anon";

grant select on table "public"."seo_metadata" to "anon";

grant trigger on table "public"."seo_metadata" to "anon";

grant truncate on table "public"."seo_metadata" to "anon";

grant update on table "public"."seo_metadata" to "anon";

grant delete on table "public"."seo_metadata" to "authenticated";

grant insert on table "public"."seo_metadata" to "authenticated";

grant references on table "public"."seo_metadata" to "authenticated";

grant select on table "public"."seo_metadata" to "authenticated";

grant trigger on table "public"."seo_metadata" to "authenticated";

grant truncate on table "public"."seo_metadata" to "authenticated";

grant update on table "public"."seo_metadata" to "authenticated";

grant delete on table "public"."seo_metadata" to "service_role";

grant insert on table "public"."seo_metadata" to "service_role";

grant references on table "public"."seo_metadata" to "service_role";

grant select on table "public"."seo_metadata" to "service_role";

grant trigger on table "public"."seo_metadata" to "service_role";

grant truncate on table "public"."seo_metadata" to "service_role";

grant update on table "public"."seo_metadata" to "service_role";

grant delete on table "public"."settings" to "anon";

grant insert on table "public"."settings" to "anon";

grant references on table "public"."settings" to "anon";

grant select on table "public"."settings" to "anon";

grant trigger on table "public"."settings" to "anon";

grant truncate on table "public"."settings" to "anon";

grant update on table "public"."settings" to "anon";

grant delete on table "public"."settings" to "authenticated";

grant insert on table "public"."settings" to "authenticated";

grant references on table "public"."settings" to "authenticated";

grant select on table "public"."settings" to "authenticated";

grant trigger on table "public"."settings" to "authenticated";

grant truncate on table "public"."settings" to "authenticated";

grant update on table "public"."settings" to "authenticated";

grant delete on table "public"."settings" to "service_role";

grant insert on table "public"."settings" to "service_role";

grant references on table "public"."settings" to "service_role";

grant select on table "public"."settings" to "service_role";

grant trigger on table "public"."settings" to "service_role";

grant truncate on table "public"."settings" to "service_role";

grant update on table "public"."settings" to "service_role";

grant delete on table "public"."sso_audit_logs" to "anon";

grant insert on table "public"."sso_audit_logs" to "anon";

grant references on table "public"."sso_audit_logs" to "anon";

grant select on table "public"."sso_audit_logs" to "anon";

grant trigger on table "public"."sso_audit_logs" to "anon";

grant truncate on table "public"."sso_audit_logs" to "anon";

grant update on table "public"."sso_audit_logs" to "anon";

grant delete on table "public"."sso_audit_logs" to "authenticated";

grant insert on table "public"."sso_audit_logs" to "authenticated";

grant references on table "public"."sso_audit_logs" to "authenticated";

grant select on table "public"."sso_audit_logs" to "authenticated";

grant trigger on table "public"."sso_audit_logs" to "authenticated";

grant truncate on table "public"."sso_audit_logs" to "authenticated";

grant update on table "public"."sso_audit_logs" to "authenticated";

grant delete on table "public"."sso_audit_logs" to "service_role";

grant insert on table "public"."sso_audit_logs" to "service_role";

grant references on table "public"."sso_audit_logs" to "service_role";

grant select on table "public"."sso_audit_logs" to "service_role";

grant trigger on table "public"."sso_audit_logs" to "service_role";

grant truncate on table "public"."sso_audit_logs" to "service_role";

grant update on table "public"."sso_audit_logs" to "service_role";

grant delete on table "public"."sso_providers" to "anon";

grant insert on table "public"."sso_providers" to "anon";

grant references on table "public"."sso_providers" to "anon";

grant select on table "public"."sso_providers" to "anon";

grant trigger on table "public"."sso_providers" to "anon";

grant truncate on table "public"."sso_providers" to "anon";

grant update on table "public"."sso_providers" to "anon";

grant delete on table "public"."sso_providers" to "authenticated";

grant insert on table "public"."sso_providers" to "authenticated";

grant references on table "public"."sso_providers" to "authenticated";

grant select on table "public"."sso_providers" to "authenticated";

grant trigger on table "public"."sso_providers" to "authenticated";

grant truncate on table "public"."sso_providers" to "authenticated";

grant update on table "public"."sso_providers" to "authenticated";

grant delete on table "public"."sso_providers" to "service_role";

grant insert on table "public"."sso_providers" to "service_role";

grant references on table "public"."sso_providers" to "service_role";

grant select on table "public"."sso_providers" to "service_role";

grant trigger on table "public"."sso_providers" to "service_role";

grant truncate on table "public"."sso_providers" to "service_role";

grant update on table "public"."sso_providers" to "service_role";

grant delete on table "public"."sso_role_mappings" to "anon";

grant insert on table "public"."sso_role_mappings" to "anon";

grant references on table "public"."sso_role_mappings" to "anon";

grant select on table "public"."sso_role_mappings" to "anon";

grant trigger on table "public"."sso_role_mappings" to "anon";

grant truncate on table "public"."sso_role_mappings" to "anon";

grant update on table "public"."sso_role_mappings" to "anon";

grant delete on table "public"."sso_role_mappings" to "authenticated";

grant insert on table "public"."sso_role_mappings" to "authenticated";

grant references on table "public"."sso_role_mappings" to "authenticated";

grant select on table "public"."sso_role_mappings" to "authenticated";

grant trigger on table "public"."sso_role_mappings" to "authenticated";

grant truncate on table "public"."sso_role_mappings" to "authenticated";

grant update on table "public"."sso_role_mappings" to "authenticated";

grant delete on table "public"."sso_role_mappings" to "service_role";

grant insert on table "public"."sso_role_mappings" to "service_role";

grant references on table "public"."sso_role_mappings" to "service_role";

grant select on table "public"."sso_role_mappings" to "service_role";

grant trigger on table "public"."sso_role_mappings" to "service_role";

grant truncate on table "public"."sso_role_mappings" to "service_role";

grant update on table "public"."sso_role_mappings" to "service_role";

grant delete on table "public"."tags" to "anon";

grant insert on table "public"."tags" to "anon";

grant references on table "public"."tags" to "anon";

grant select on table "public"."tags" to "anon";

grant trigger on table "public"."tags" to "anon";

grant truncate on table "public"."tags" to "anon";

grant update on table "public"."tags" to "anon";

grant delete on table "public"."tags" to "authenticated";

grant insert on table "public"."tags" to "authenticated";

grant references on table "public"."tags" to "authenticated";

grant select on table "public"."tags" to "authenticated";

grant trigger on table "public"."tags" to "authenticated";

grant truncate on table "public"."tags" to "authenticated";

grant update on table "public"."tags" to "authenticated";

grant delete on table "public"."tags" to "service_role";

grant insert on table "public"."tags" to "service_role";

grant references on table "public"."tags" to "service_role";

grant select on table "public"."tags" to "service_role";

grant trigger on table "public"."tags" to "service_role";

grant truncate on table "public"."tags" to "service_role";

grant update on table "public"."tags" to "service_role";

grant delete on table "public"."testimonies" to "anon";

grant insert on table "public"."testimonies" to "anon";

grant references on table "public"."testimonies" to "anon";

grant select on table "public"."testimonies" to "anon";

grant trigger on table "public"."testimonies" to "anon";

grant truncate on table "public"."testimonies" to "anon";

grant update on table "public"."testimonies" to "anon";

grant delete on table "public"."testimonies" to "authenticated";

grant insert on table "public"."testimonies" to "authenticated";

grant references on table "public"."testimonies" to "authenticated";

grant select on table "public"."testimonies" to "authenticated";

grant trigger on table "public"."testimonies" to "authenticated";

grant truncate on table "public"."testimonies" to "authenticated";

grant update on table "public"."testimonies" to "authenticated";

grant delete on table "public"."testimonies" to "service_role";

grant insert on table "public"."testimonies" to "service_role";

grant references on table "public"."testimonies" to "service_role";

grant select on table "public"."testimonies" to "service_role";

grant trigger on table "public"."testimonies" to "service_role";

grant truncate on table "public"."testimonies" to "service_role";

grant update on table "public"."testimonies" to "service_role";

grant delete on table "public"."testimony_tags" to "anon";

grant insert on table "public"."testimony_tags" to "anon";

grant references on table "public"."testimony_tags" to "anon";

grant select on table "public"."testimony_tags" to "anon";

grant trigger on table "public"."testimony_tags" to "anon";

grant truncate on table "public"."testimony_tags" to "anon";

grant update on table "public"."testimony_tags" to "anon";

grant delete on table "public"."testimony_tags" to "authenticated";

grant insert on table "public"."testimony_tags" to "authenticated";

grant references on table "public"."testimony_tags" to "authenticated";

grant select on table "public"."testimony_tags" to "authenticated";

grant trigger on table "public"."testimony_tags" to "authenticated";

grant truncate on table "public"."testimony_tags" to "authenticated";

grant update on table "public"."testimony_tags" to "authenticated";

grant delete on table "public"."testimony_tags" to "service_role";

grant insert on table "public"."testimony_tags" to "service_role";

grant references on table "public"."testimony_tags" to "service_role";

grant select on table "public"."testimony_tags" to "service_role";

grant trigger on table "public"."testimony_tags" to "service_role";

grant truncate on table "public"."testimony_tags" to "service_role";

grant update on table "public"."testimony_tags" to "service_role";

grant delete on table "public"."themes" to "anon";

grant insert on table "public"."themes" to "anon";

grant references on table "public"."themes" to "anon";

grant select on table "public"."themes" to "anon";

grant trigger on table "public"."themes" to "anon";

grant truncate on table "public"."themes" to "anon";

grant update on table "public"."themes" to "anon";

grant delete on table "public"."themes" to "authenticated";

grant insert on table "public"."themes" to "authenticated";

grant references on table "public"."themes" to "authenticated";

grant select on table "public"."themes" to "authenticated";

grant trigger on table "public"."themes" to "authenticated";

grant truncate on table "public"."themes" to "authenticated";

grant update on table "public"."themes" to "authenticated";

grant delete on table "public"."themes" to "service_role";

grant insert on table "public"."themes" to "service_role";

grant references on table "public"."themes" to "service_role";

grant select on table "public"."themes" to "service_role";

grant trigger on table "public"."themes" to "service_role";

grant truncate on table "public"."themes" to "service_role";

grant update on table "public"."themes" to "service_role";

grant delete on table "public"."two_factor_audit_logs" to "anon";

grant insert on table "public"."two_factor_audit_logs" to "anon";

grant references on table "public"."two_factor_audit_logs" to "anon";

grant select on table "public"."two_factor_audit_logs" to "anon";

grant trigger on table "public"."two_factor_audit_logs" to "anon";

grant truncate on table "public"."two_factor_audit_logs" to "anon";

grant update on table "public"."two_factor_audit_logs" to "anon";

grant delete on table "public"."two_factor_audit_logs" to "authenticated";

grant insert on table "public"."two_factor_audit_logs" to "authenticated";

grant references on table "public"."two_factor_audit_logs" to "authenticated";

grant select on table "public"."two_factor_audit_logs" to "authenticated";

grant trigger on table "public"."two_factor_audit_logs" to "authenticated";

grant truncate on table "public"."two_factor_audit_logs" to "authenticated";

grant update on table "public"."two_factor_audit_logs" to "authenticated";

grant delete on table "public"."two_factor_audit_logs" to "service_role";

grant insert on table "public"."two_factor_audit_logs" to "service_role";

grant references on table "public"."two_factor_audit_logs" to "service_role";

grant select on table "public"."two_factor_audit_logs" to "service_role";

grant trigger on table "public"."two_factor_audit_logs" to "service_role";

grant truncate on table "public"."two_factor_audit_logs" to "service_role";

grant update on table "public"."two_factor_audit_logs" to "service_role";

grant delete on table "public"."two_factor_auth" to "anon";

grant insert on table "public"."two_factor_auth" to "anon";

grant references on table "public"."two_factor_auth" to "anon";

grant select on table "public"."two_factor_auth" to "anon";

grant trigger on table "public"."two_factor_auth" to "anon";

grant truncate on table "public"."two_factor_auth" to "anon";

grant update on table "public"."two_factor_auth" to "anon";

grant delete on table "public"."two_factor_auth" to "authenticated";

grant insert on table "public"."two_factor_auth" to "authenticated";

grant references on table "public"."two_factor_auth" to "authenticated";

grant select on table "public"."two_factor_auth" to "authenticated";

grant trigger on table "public"."two_factor_auth" to "authenticated";

grant truncate on table "public"."two_factor_auth" to "authenticated";

grant update on table "public"."two_factor_auth" to "authenticated";

grant delete on table "public"."two_factor_auth" to "service_role";

grant insert on table "public"."two_factor_auth" to "service_role";

grant references on table "public"."two_factor_auth" to "service_role";

grant select on table "public"."two_factor_auth" to "service_role";

grant trigger on table "public"."two_factor_auth" to "service_role";

grant truncate on table "public"."two_factor_auth" to "service_role";

grant update on table "public"."two_factor_auth" to "service_role";

grant delete on table "public"."video_gallery" to "anon";

grant insert on table "public"."video_gallery" to "anon";

grant references on table "public"."video_gallery" to "anon";

grant select on table "public"."video_gallery" to "anon";

grant trigger on table "public"."video_gallery" to "anon";

grant truncate on table "public"."video_gallery" to "anon";

grant update on table "public"."video_gallery" to "anon";

grant delete on table "public"."video_gallery" to "authenticated";

grant insert on table "public"."video_gallery" to "authenticated";

grant references on table "public"."video_gallery" to "authenticated";

grant select on table "public"."video_gallery" to "authenticated";

grant trigger on table "public"."video_gallery" to "authenticated";

grant truncate on table "public"."video_gallery" to "authenticated";

grant update on table "public"."video_gallery" to "authenticated";

grant delete on table "public"."video_gallery" to "service_role";

grant insert on table "public"."video_gallery" to "service_role";

grant references on table "public"."video_gallery" to "service_role";

grant select on table "public"."video_gallery" to "service_role";

grant trigger on table "public"."video_gallery" to "service_role";

grant truncate on table "public"."video_gallery" to "service_role";

grant update on table "public"."video_gallery" to "service_role";

grant delete on table "public"."video_gallery_tags" to "anon";

grant insert on table "public"."video_gallery_tags" to "anon";

grant references on table "public"."video_gallery_tags" to "anon";

grant select on table "public"."video_gallery_tags" to "anon";

grant trigger on table "public"."video_gallery_tags" to "anon";

grant truncate on table "public"."video_gallery_tags" to "anon";

grant update on table "public"."video_gallery_tags" to "anon";

grant delete on table "public"."video_gallery_tags" to "authenticated";

grant insert on table "public"."video_gallery_tags" to "authenticated";

grant references on table "public"."video_gallery_tags" to "authenticated";

grant select on table "public"."video_gallery_tags" to "authenticated";

grant trigger on table "public"."video_gallery_tags" to "authenticated";

grant truncate on table "public"."video_gallery_tags" to "authenticated";

grant update on table "public"."video_gallery_tags" to "authenticated";

grant delete on table "public"."video_gallery_tags" to "service_role";

grant insert on table "public"."video_gallery_tags" to "service_role";

grant references on table "public"."video_gallery_tags" to "service_role";

grant select on table "public"."video_gallery_tags" to "service_role";

grant trigger on table "public"."video_gallery_tags" to "service_role";

grant truncate on table "public"."video_gallery_tags" to "service_role";

grant update on table "public"."video_gallery_tags" to "service_role";


  create policy "account_requests_delete_unified"
  on "public"."account_requests"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "account_requests_insert_unified"
  on "public"."account_requests"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "account_requests_select_unified"
  on "public"."account_requests"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "account_requests_update_unified"
  on "public"."account_requests"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "admin_menus_delete_unified"
  on "public"."admin_menus"
  as permissive
  for delete
  to public
using (public.is_platform_admin());



  create policy "admin_menus_insert_unified"
  on "public"."admin_menus"
  as permissive
  for insert
  to public
with check (public.is_platform_admin());



  create policy "admin_menus_select_unified"
  on "public"."admin_menus"
  as permissive
  for select
  to authenticated
using (true);



  create policy "admin_menus_update_unified"
  on "public"."admin_menus"
  as permissive
  for update
  to public
using (public.is_platform_admin());



  create policy "announcement_tags_select_public"
  on "public"."announcement_tags"
  as permissive
  for select
  to public
using (true);



  create policy "announcements_delete_unified"
  on "public"."announcements"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "announcements_insert_unified"
  on "public"."announcements"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "announcements_select_unified"
  on "public"."announcements"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "announcements_update_unified"
  on "public"."announcements"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "article_tags_select_public"
  on "public"."article_tags"
  as permissive
  for select
  to public
using (true);



  create policy "articles_delete_unified"
  on "public"."articles"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "articles_insert_unified"
  on "public"."articles"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "articles_select_unified"
  on "public"."articles"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "articles_update_unified"
  on "public"."articles"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "audit_logs_insert_unified"
  on "public"."audit_logs"
  as permissive
  for insert
  to public
with check ((tenant_id = public.current_tenant_id()));



  create policy "audit_logs_select_unified"
  on "public"."audit_logs"
  as permissive
  for select
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR ((tenant_id IS NULL) AND public.is_platform_admin()) OR public.is_platform_admin()));



  create policy "auth_hibp_events_select_own_v2"
  on "public"."auth_hibp_events"
  as permissive
  for select
  to public
using ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "backup_logs_insert_auth"
  on "public"."backup_logs"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "backup_logs_select_auth"
  on "public"."backup_logs"
  as permissive
  for select
  to authenticated
using (true);



  create policy "backup_schedules_delete_owner"
  on "public"."backup_schedules"
  as permissive
  for delete
  to authenticated
using ((created_by = ( SELECT auth.uid() AS uid)));



  create policy "backup_schedules_insert_owner"
  on "public"."backup_schedules"
  as permissive
  for insert
  to authenticated
with check ((created_by = ( SELECT auth.uid() AS uid)));



  create policy "backup_schedules_select_auth"
  on "public"."backup_schedules"
  as permissive
  for select
  to authenticated
using (((created_by IS NULL) OR (created_by = ( SELECT auth.uid() AS uid))));



  create policy "backup_schedules_update_owner"
  on "public"."backup_schedules"
  as permissive
  for update
  to authenticated
using ((created_by = ( SELECT auth.uid() AS uid)))
with check ((created_by = ( SELECT auth.uid() AS uid)));



  create policy "backups_delete_unified"
  on "public"."backups"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "backups_insert_unified"
  on "public"."backups"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "backups_select_unified"
  on "public"."backups"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "backups_update_unified"
  on "public"."backups"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "cart_items_delete_unified"
  on "public"."cart_items"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "cart_items_insert_unified"
  on "public"."cart_items"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "cart_items_select_unified"
  on "public"."cart_items"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "cart_items_update_unified"
  on "public"."cart_items"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "Users can insert own carts"
  on "public"."carts"
  as permissive
  for insert
  to public
with check (((user_id = ( SELECT auth.uid() AS uid)) OR (session_id IS NOT NULL)));



  create policy "Users can update own carts"
  on "public"."carts"
  as permissive
  for update
  to public
using (((user_id = ( SELECT auth.uid() AS uid)) OR (session_id IS NOT NULL)));



  create policy "carts_select_policy"
  on "public"."carts"
  as permissive
  for select
  to public
using (((user_id = ( SELECT auth.uid() AS uid)) OR (session_id IS NOT NULL) OR (EXISTS ( SELECT 1
   FROM public.users u
  WHERE ((u.id = ( SELECT auth.uid() AS uid)) AND (u.role_id IN ( SELECT roles.id
           FROM public.roles
          WHERE (roles.name = ANY (ARRAY['owner'::text, 'super_admin'::text, 'admin'::text])))))))));



  create policy "categories_delete_unified"
  on "public"."categories"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "categories_insert_unified"
  on "public"."categories"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "categories_select_unified"
  on "public"."categories"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "categories_update_unified"
  on "public"."categories"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "contact_message_tags_select_public"
  on "public"."contact_message_tags"
  as permissive
  for select
  to public
using (true);



  create policy "contact_messages_delete_admin"
  on "public"."contact_messages"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "contact_messages_insert_public"
  on "public"."contact_messages"
  as permissive
  for insert
  to public
with check (true);



  create policy "contact_messages_modify_admin"
  on "public"."contact_messages"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "contact_messages_select_unified"
  on "public"."contact_messages"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "contact_tags_select_public"
  on "public"."contact_tags"
  as permissive
  for select
  to public
using (true);



  create policy "contacts_delete_unified"
  on "public"."contacts"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "contacts_insert_unified"
  on "public"."contacts"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "contacts_select_unified"
  on "public"."contacts"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "contacts_update_unified"
  on "public"."contacts"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "devices_delete_policy"
  on "public"."devices"
  as permissive
  for delete
  to public
using ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND (owner_id = ( SELECT auth.uid() AS uid))) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "devices_insert_policy"
  on "public"."devices"
  as permissive
  for insert
  to public
with check ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "devices_select_policy"
  on "public"."devices"
  as permissive
  for select
  to public
using ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND (owner_id = ( SELECT auth.uid() AS uid))) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "devices_update_policy"
  on "public"."devices"
  as permissive
  for update
  to public
using ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND (owner_id = ( SELECT auth.uid() AS uid))) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "email_logs_insert_unified"
  on "public"."email_logs"
  as permissive
  for insert
  to public
with check ((public.is_admin_or_above() OR public.is_platform_admin()));



  create policy "email_logs_select_unified"
  on "public"."email_logs"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "Authenticated Insert"
  on "public"."extension_logs"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "No Updates"
  on "public"."extension_logs"
  as permissive
  for update
  to public
using (false);



  create policy "Platform Admin Delete Only"
  on "public"."extension_logs"
  as permissive
  for delete
  to public
using (public.is_platform_admin());



  create policy "Tenant Read Own Logs"
  on "public"."extension_logs"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "Admins manage extension_menu_items"
  on "public"."extension_menu_items"
  as permissive
  for all
  to authenticated
using (public.is_admin_or_above())
with check (public.is_admin_or_above());



  create policy "extension_permissions_delete_admin"
  on "public"."extension_permissions"
  as permissive
  for delete
  to public
using ((( SELECT public.get_my_role() AS get_my_role) = ANY (ARRAY['super_admin'::text, 'admin'::text])));



  create policy "extension_permissions_insert_admin"
  on "public"."extension_permissions"
  as permissive
  for insert
  to public
with check ((( SELECT public.get_my_role() AS get_my_role) = ANY (ARRAY['super_admin'::text, 'admin'::text])));



  create policy "extension_permissions_select_auth"
  on "public"."extension_permissions"
  as permissive
  for select
  to public
using ((( SELECT auth.role() AS role) = 'authenticated'::text));



  create policy "extension_permissions_update_admin"
  on "public"."extension_permissions"
  as permissive
  for update
  to public
using ((( SELECT public.get_my_role() AS get_my_role) = ANY (ARRAY['super_admin'::text, 'admin'::text])));



  create policy "extension_rbac_delete"
  on "public"."extension_rbac_integration"
  as permissive
  for delete
  to public
using ((( SELECT public.get_my_role() AS get_my_role) = 'super_admin'::text));



  create policy "extension_rbac_insert"
  on "public"."extension_rbac_integration"
  as permissive
  for insert
  to public
with check ((( SELECT public.get_my_role() AS get_my_role) = 'super_admin'::text));



  create policy "extension_rbac_select"
  on "public"."extension_rbac_integration"
  as permissive
  for select
  to public
using (true);



  create policy "extension_rbac_update"
  on "public"."extension_rbac_integration"
  as permissive
  for update
  to public
using ((( SELECT public.get_my_role() AS get_my_role) = 'super_admin'::text));



  create policy "extension_routes_delete_unified"
  on "public"."extension_routes"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "extension_routes_insert_unified"
  on "public"."extension_routes"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "extension_routes_select_unified"
  on "public"."extension_routes"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "extension_routes_update_unified"
  on "public"."extension_routes"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "extension_routes_registry_select"
  on "public"."extension_routes_registry"
  as permissive
  for select
  to public
using (((is_active = true) OR (( SELECT public.get_my_role() AS get_my_role) = 'super_admin'::text)));



  create policy "extensions_delete_unified"
  on "public"."extensions"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "extensions_insert_unified"
  on "public"."extensions"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "extensions_select_unified"
  on "public"."extensions"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL) OR public.is_platform_admin()));



  create policy "extensions_update_unified"
  on "public"."extensions"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "File permissions tenant isolation"
  on "public"."file_permissions"
  as permissive
  for all
  to authenticated
using ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.files f
  WHERE ((f.id = file_permissions.file_id) AND (f.tenant_id = public.current_tenant_id()))))))
with check ((public.is_platform_admin() OR (EXISTS ( SELECT 1
   FROM public.files f
  WHERE ((f.id = file_permissions.file_id) AND (f.tenant_id = public.current_tenant_id()))))));



  create policy "files_delete_unified"
  on "public"."files"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "files_insert_unified"
  on "public"."files"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "files_select_unified"
  on "public"."files"
  as permissive
  for select
  to public
using ((((tenant_id = public.current_tenant_id()) AND (deleted_at IS NULL)) OR public.is_platform_admin()));



  create policy "files_update_unified"
  on "public"."files"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "menu_permissions_select_public"
  on "public"."menu_permissions"
  as permissive
  for select
  to public
using (true);



  create policy "menus_delete_unified"
  on "public"."menus"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "menus_insert_unified"
  on "public"."menus"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "menus_select_unified"
  on "public"."menus"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "menus_update_unified"
  on "public"."menus"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "mobile_app_config_access"
  on "public"."mobile_app_config"
  as permissive
  for all
  to public
using (((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "mobile_users_access"
  on "public"."mobile_users"
  as permissive
  for all
  to public
using ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND (user_id = ( SELECT auth.uid() AS uid))) OR ( SELECT public.is_admin_or_above() AS is_admin_or_above) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "notification_readers_delete_policy"
  on "public"."notification_readers"
  as permissive
  for delete
  to public
using ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "notification_readers_insert_policy"
  on "public"."notification_readers"
  as permissive
  for insert
  to public
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "notification_readers_select_policy"
  on "public"."notification_readers"
  as permissive
  for select
  to public
using (((user_id = ( SELECT auth.uid() AS uid)) OR (( SELECT public.get_my_role() AS get_my_role) = ANY (ARRAY['super_admin'::text, 'admin'::text]))));



  create policy "notifications_delete_unified"
  on "public"."notifications"
  as permissive
  for delete
  to public
using (((user_id = ( SELECT auth.uid() AS uid)) OR ((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "notifications_insert_unified"
  on "public"."notifications"
  as permissive
  for insert
  to public
with check (((user_id = ( SELECT auth.uid() AS uid)) OR ((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "notifications_select_unified"
  on "public"."notifications"
  as permissive
  for select
  to public
using (((user_id = ( SELECT auth.uid() AS uid)) OR ((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "notifications_update_unified"
  on "public"."notifications"
  as permissive
  for update
  to public
using (((user_id = ( SELECT auth.uid() AS uid)) OR ((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "order_items_delete_unified"
  on "public"."order_items"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "order_items_insert_unified"
  on "public"."order_items"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "order_items_select_unified"
  on "public"."order_items"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "order_items_update_unified"
  on "public"."order_items"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "Users create own orders"
  on "public"."orders"
  as permissive
  for insert
  to public
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users view own orders"
  on "public"."orders"
  as permissive
  for select
  to public
using (((user_id = ( SELECT auth.uid() AS uid)) OR (( SELECT public.get_my_role_name() AS get_my_role_name) = ANY (ARRAY['super_admin'::text, 'admin'::text, 'editor'::text]))));



  create policy "page_categories_select_public"
  on "public"."page_categories"
  as permissive
  for select
  to authenticated, anon
using (true);



  create policy "page_tags_select_public"
  on "public"."page_tags"
  as permissive
  for select
  to public
using (true);



  create policy "pages_delete_unified"
  on "public"."pages"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "pages_insert_unified"
  on "public"."pages"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "pages_select_unified"
  on "public"."pages"
  as permissive
  for select
  to public
using ((((tenant_id = public.current_tenant_id()) AND (deleted_at IS NULL)) OR public.is_platform_admin()));



  create policy "pages_update_unified"
  on "public"."pages"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "Payment methods Delete"
  on "public"."payment_methods"
  as permissive
  for delete
  to public
using ((EXISTS ( SELECT 1
   FROM public.users u
  WHERE ((u.id = ( SELECT auth.uid() AS uid)) AND (u.role_id IN ( SELECT roles.id
           FROM public.roles
          WHERE (roles.name = ANY (ARRAY['owner'::text, 'super_admin'::text, 'admin'::text]))))))));



  create policy "Payment methods Insert"
  on "public"."payment_methods"
  as permissive
  for insert
  to public
with check ((EXISTS ( SELECT 1
   FROM public.users u
  WHERE ((u.id = ( SELECT auth.uid() AS uid)) AND (u.role_id IN ( SELECT roles.id
           FROM public.roles
          WHERE (roles.name = ANY (ARRAY['owner'::text, 'super_admin'::text, 'admin'::text]))))))));



  create policy "Payment methods Select"
  on "public"."payment_methods"
  as permissive
  for select
  to public
using ((((is_active = true) AND (deleted_at IS NULL)) OR (EXISTS ( SELECT 1
   FROM public.users u
  WHERE ((u.id = ( SELECT auth.uid() AS uid)) AND (u.role_id IN ( SELECT roles.id
           FROM public.roles
          WHERE (roles.name = ANY (ARRAY['owner'::text, 'super_admin'::text, 'admin'::text])))))))));



  create policy "Payment methods Update"
  on "public"."payment_methods"
  as permissive
  for update
  to public
using ((EXISTS ( SELECT 1
   FROM public.users u
  WHERE ((u.id = ( SELECT auth.uid() AS uid)) AND (u.role_id IN ( SELECT roles.id
           FROM public.roles
          WHERE (roles.name = ANY (ARRAY['owner'::text, 'super_admin'::text, 'admin'::text]))))))));



  create policy "Payments Delete"
  on "public"."payments"
  as permissive
  for delete
  to public
using ((EXISTS ( SELECT 1
   FROM public.users u
  WHERE ((u.id = ( SELECT auth.uid() AS uid)) AND (u.role_id IN ( SELECT roles.id
           FROM public.roles
          WHERE (roles.name = ANY (ARRAY['owner'::text, 'super_admin'::text, 'admin'::text]))))))));



  create policy "Payments Insert"
  on "public"."payments"
  as permissive
  for insert
  to public
with check ((EXISTS ( SELECT 1
   FROM public.users u
  WHERE ((u.id = ( SELECT auth.uid() AS uid)) AND (u.role_id IN ( SELECT roles.id
           FROM public.roles
          WHERE (roles.name = ANY (ARRAY['owner'::text, 'super_admin'::text, 'admin'::text]))))))));



  create policy "Payments Select"
  on "public"."payments"
  as permissive
  for select
  to public
using (((EXISTS ( SELECT 1
   FROM public.users u
  WHERE ((u.id = ( SELECT auth.uid() AS uid)) AND (u.role_id IN ( SELECT roles.id
           FROM public.roles
          WHERE (roles.name = ANY (ARRAY['owner'::text, 'super_admin'::text, 'admin'::text]))))))) OR (EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = payments.order_id) AND (o.user_id = ( SELECT auth.uid() AS uid)))))));



  create policy "Payments Update"
  on "public"."payments"
  as permissive
  for update
  to public
using ((EXISTS ( SELECT 1
   FROM public.users u
  WHERE ((u.id = ( SELECT auth.uid() AS uid)) AND (u.role_id IN ( SELECT roles.id
           FROM public.roles
          WHERE (roles.name = ANY (ARRAY['owner'::text, 'super_admin'::text, 'admin'::text]))))))));



  create policy "permissions_delete_policy"
  on "public"."permissions"
  as permissive
  for delete
  to authenticated
using (public.is_super_admin());



  create policy "permissions_insert_policy"
  on "public"."permissions"
  as permissive
  for insert
  to authenticated
with check (public.is_super_admin());



  create policy "permissions_select_policy"
  on "public"."permissions"
  as permissive
  for select
  to authenticated
using (true);



  create policy "permissions_update_policy"
  on "public"."permissions"
  as permissive
  for update
  to authenticated
using (public.is_super_admin())
with check (true);



  create policy "photo_gallery_delete_unified"
  on "public"."photo_gallery"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "photo_gallery_insert_unified"
  on "public"."photo_gallery"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "photo_gallery_select_unified"
  on "public"."photo_gallery"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "photo_gallery_update_unified"
  on "public"."photo_gallery"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "photo_gallery_tags_select_public"
  on "public"."photo_gallery_tags"
  as permissive
  for select
  to public
using (true);



  create policy "policies_delete_unified"
  on "public"."policies"
  as permissive
  for delete
  to public
using (public.is_platform_admin());



  create policy "policies_insert_unified"
  on "public"."policies"
  as permissive
  for insert
  to public
with check (public.is_platform_admin());



  create policy "policies_select_unified"
  on "public"."policies"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL) OR public.is_platform_admin()));



  create policy "policies_update_unified"
  on "public"."policies"
  as permissive
  for update
  to public
using (public.is_platform_admin());



  create policy "portfolio_delete_unified"
  on "public"."portfolio"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "portfolio_insert_unified"
  on "public"."portfolio"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "portfolio_select_unified"
  on "public"."portfolio"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "portfolio_update_unified"
  on "public"."portfolio"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "portfolio_tags_select_public"
  on "public"."portfolio_tags"
  as permissive
  for select
  to public
using (true);



  create policy "product_tags_select_public"
  on "public"."product_tags"
  as permissive
  for select
  to public
using (true);



  create policy "product_type_tags_select_public"
  on "public"."product_type_tags"
  as permissive
  for select
  to public
using (true);



  create policy "product_types_delete_unified"
  on "public"."product_types"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "product_types_insert_unified"
  on "public"."product_types"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "product_types_select_unified"
  on "public"."product_types"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "product_types_update_unified"
  on "public"."product_types"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "products_delete_unified"
  on "public"."products"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "products_insert_unified"
  on "public"."products"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "products_select_unified"
  on "public"."products"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "products_update_unified"
  on "public"."products"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "promotion_tags_select_public"
  on "public"."promotion_tags"
  as permissive
  for select
  to public
using (true);



  create policy "promotions_delete_unified"
  on "public"."promotions"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "promotions_insert_unified"
  on "public"."promotions"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "promotions_select_unified"
  on "public"."promotions"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "promotions_update_unified"
  on "public"."promotions"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "push_notifications_access"
  on "public"."push_notifications"
  as permissive
  for all
  to public
using (((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "Region levels viewable by authenticated"
  on "public"."region_levels"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Regions tenant isolation"
  on "public"."regions"
  as permissive
  for all
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "role_permissions_delete_policy"
  on "public"."role_permissions"
  as permissive
  for delete
  to authenticated
using (public.is_super_admin());



  create policy "role_permissions_insert_policy"
  on "public"."role_permissions"
  as permissive
  for insert
  to authenticated
with check (public.is_super_admin());



  create policy "role_permissions_select_policy"
  on "public"."role_permissions"
  as permissive
  for select
  to authenticated
using (true);



  create policy "role_permissions_update_policy"
  on "public"."role_permissions"
  as permissive
  for update
  to authenticated
using (public.is_super_admin())
with check (true);



  create policy "role_policies_delete_unified"
  on "public"."role_policies"
  as permissive
  for delete
  to public
using (public.is_platform_admin());



  create policy "role_policies_insert_unified"
  on "public"."role_policies"
  as permissive
  for insert
  to public
with check (public.is_platform_admin());



  create policy "role_policies_select_unified"
  on "public"."role_policies"
  as permissive
  for select
  to authenticated
using (true);



  create policy "role_policies_update_unified"
  on "public"."role_policies"
  as permissive
  for update
  to public
using (public.is_platform_admin());



  create policy "roles_delete_unified"
  on "public"."roles"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "roles_insert_unified"
  on "public"."roles"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "roles_select_unified"
  on "public"."roles"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL) OR public.is_platform_admin()));



  create policy "roles_update_unified"
  on "public"."roles"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "sensor_readings_access"
  on "public"."sensor_readings"
  as permissive
  for all
  to public
using (((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "seo_metadata_select_public"
  on "public"."seo_metadata"
  as permissive
  for select
  to public
using (true);



  create policy "settings_delete_unified"
  on "public"."settings"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "settings_insert_unified"
  on "public"."settings"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "settings_select_unified"
  on "public"."settings"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL) OR public.is_platform_admin()));



  create policy "settings_update_unified"
  on "public"."settings"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "Admins View SSO Logs"
  on "public"."sso_audit_logs"
  as permissive
  for select
  to public
using ((public.get_my_role() = ANY (ARRAY['super_admin'::text, 'admin'::text])));



  create policy "System Insert SSO Logs"
  on "public"."sso_audit_logs"
  as permissive
  for insert
  to public
with check (true);



  create policy "sso_providers_isolation_policy"
  on "public"."sso_providers"
  as permissive
  for all
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "sso_role_mappings_delete_unified"
  on "public"."sso_role_mappings"
  as permissive
  for delete
  to public
using ((EXISTS ( SELECT 1
   FROM public.sso_providers p
  WHERE ((p.id = (sso_role_mappings.provider_id)::uuid) AND (((p.tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin())))));



  create policy "sso_role_mappings_insert_unified"
  on "public"."sso_role_mappings"
  as permissive
  for insert
  to public
with check ((EXISTS ( SELECT 1
   FROM public.sso_providers p
  WHERE ((p.id = (sso_role_mappings.provider_id)::uuid) AND (((p.tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin())))));



  create policy "sso_role_mappings_select_unified"
  on "public"."sso_role_mappings"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.sso_providers p
  WHERE ((p.id = (sso_role_mappings.provider_id)::uuid) AND ((p.tenant_id = public.current_tenant_id()) OR public.is_platform_admin())))));



  create policy "sso_role_mappings_update_unified"
  on "public"."sso_role_mappings"
  as permissive
  for update
  to public
using ((EXISTS ( SELECT 1
   FROM public.sso_providers p
  WHERE ((p.id = (sso_role_mappings.provider_id)::uuid) AND (((p.tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin())))));



  create policy "tags_delete_unified"
  on "public"."tags"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "tags_insert_unified"
  on "public"."tags"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "tags_select_unified"
  on "public"."tags"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "tags_update_unified"
  on "public"."tags"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "template_assignments_delete_unified"
  on "public"."template_assignments"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "template_assignments_modify_unified"
  on "public"."template_assignments"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "template_assignments_select_unified"
  on "public"."template_assignments"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "template_assignments_update_unified"
  on "public"."template_assignments"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "template_parts_delete_unified"
  on "public"."template_parts"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "template_parts_modify_unified"
  on "public"."template_parts"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "template_parts_select_unified"
  on "public"."template_parts"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "template_parts_update_unified"
  on "public"."template_parts"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "template_strings_delete_unified"
  on "public"."template_strings"
  as permissive
  for delete
  to public
using (public.is_platform_admin());



  create policy "template_strings_insert_unified"
  on "public"."template_strings"
  as permissive
  for insert
  to public
with check (public.is_platform_admin());



  create policy "template_strings_select_unified"
  on "public"."template_strings"
  as permissive
  for select
  to public
using (true);



  create policy "template_strings_update_unified"
  on "public"."template_strings"
  as permissive
  for update
  to public
using (public.is_platform_admin());



  create policy "templates_delete_unified"
  on "public"."templates"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "templates_modify_unified"
  on "public"."templates"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "templates_select_unified"
  on "public"."templates"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "templates_update_unified"
  on "public"."templates"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "tenants_delete_unified"
  on "public"."tenants"
  as permissive
  for delete
  to public
using (public.is_platform_admin());



  create policy "tenants_insert_unified"
  on "public"."tenants"
  as permissive
  for insert
  to public
with check (public.is_platform_admin());



  create policy "tenants_select_unified"
  on "public"."tenants"
  as permissive
  for select
  to public
using (((id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "tenants_update_unified"
  on "public"."tenants"
  as permissive
  for update
  to public
using (public.is_platform_admin());



  create policy "testimonies_delete_unified"
  on "public"."testimonies"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "testimonies_insert_unified"
  on "public"."testimonies"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "testimonies_select_unified"
  on "public"."testimonies"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "testimonies_update_unified"
  on "public"."testimonies"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "testimony_tags_delete"
  on "public"."testimony_tags"
  as permissive
  for delete
  to public
using ((( SELECT public.get_my_role() AS get_my_role) = ANY (ARRAY['super_admin'::text, 'admin'::text, 'editor'::text])));



  create policy "testimony_tags_insert"
  on "public"."testimony_tags"
  as permissive
  for insert
  to public
with check ((( SELECT public.get_my_role() AS get_my_role) = ANY (ARRAY['super_admin'::text, 'admin'::text, 'editor'::text])));



  create policy "testimony_tags_select"
  on "public"."testimony_tags"
  as permissive
  for select
  to public
using (true);



  create policy "testimony_tags_update"
  on "public"."testimony_tags"
  as permissive
  for update
  to public
using ((( SELECT public.get_my_role() AS get_my_role) = ANY (ARRAY['super_admin'::text, 'admin'::text, 'editor'::text])));



  create policy "themes_delete_unified"
  on "public"."themes"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "themes_insert_unified"
  on "public"."themes"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "themes_select_unified"
  on "public"."themes"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL) OR public.is_platform_admin()));



  create policy "themes_update_unified"
  on "public"."themes"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "System can insert 2fa logs"
  on "public"."two_factor_audit_logs"
  as permissive
  for insert
  to public
with check (true);



  create policy "Users can view own 2fa logs"
  on "public"."two_factor_audit_logs"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can delete own 2fa"
  on "public"."two_factor_auth"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can modify own 2fa"
  on "public"."two_factor_auth"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can update own 2fa"
  on "public"."two_factor_auth"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can view own 2fa"
  on "public"."two_factor_auth"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) = user_id));



  create policy "users_delete_unified"
  on "public"."users"
  as permissive
  for delete
  to public
using ((public.is_admin_or_above() OR public.is_platform_admin()));



  create policy "users_insert_unified"
  on "public"."users"
  as permissive
  for insert
  to public
with check ((public.is_admin_or_above() OR public.is_platform_admin()));



  create policy "users_update_unified"
  on "public"."users"
  as permissive
  for update
  to public
using ((public.is_admin_or_above() OR public.is_platform_admin()));



  create policy "video_gallery_delete_unified"
  on "public"."video_gallery"
  as permissive
  for delete
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "video_gallery_insert_unified"
  on "public"."video_gallery"
  as permissive
  for insert
  to public
with check ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "video_gallery_select_unified"
  on "public"."video_gallery"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "video_gallery_update_unified"
  on "public"."video_gallery"
  as permissive
  for update
  to public
using ((((tenant_id = public.current_tenant_id()) AND public.is_admin_or_above()) OR public.is_platform_admin()));



  create policy "video_gallery_tags_select_public"
  on "public"."video_gallery_tags"
  as permissive
  for select
  to public
using (true);



  create policy "widgets_delete_unified"
  on "public"."widgets"
  as permissive
  for delete
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "widgets_modify_unified"
  on "public"."widgets"
  as permissive
  for insert
  to public
with check (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "widgets_select_unified"
  on "public"."widgets"
  as permissive
  for select
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));



  create policy "widgets_update_unified"
  on "public"."widgets"
  as permissive
  for update
  to public
using (((tenant_id = public.current_tenant_id()) OR public.is_platform_admin()));


CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.announcement_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.announcement_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.announcements FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.announcements FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.announcements FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON public.announcements FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.article_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.article_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.articles FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.articles FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_articles_audit AFTER INSERT OR DELETE OR UPDATE ON public.articles FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.articles FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_articles_updated_at BEFORE UPDATE ON public.articles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.auth_hibp_events FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.auth_hibp_events FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.backup_logs FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.backup_logs FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.backup_schedules FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.backup_schedules FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.backups FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.backups FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.categories FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.categories FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.contact_message_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.contact_message_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.contact_messages FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.contact_messages FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.contact_messages FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.contact_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.contact_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.contacts FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.contacts FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.extension_menu_items FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.extension_menu_items FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.extension_permissions FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.extension_permissions FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.extension_rbac_integration FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.extension_rbac_integration FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.extension_routes FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.extension_routes FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.extension_routes FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_extension_routes_updated_at BEFORE UPDATE ON public.extension_routes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.extension_routes_registry FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.extension_routes_registry FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER extension_audit_trigger AFTER INSERT OR DELETE OR UPDATE ON public.extensions FOR EACH ROW EXECUTE FUNCTION public.log_extension_change();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.extensions FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.extensions FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.extensions FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_extensions_updated_at BEFORE UPDATE ON public.extensions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER tr_enforce_storage_limit BEFORE INSERT ON public.files FOR EACH ROW EXECUTE FUNCTION public.enforce_storage_limit();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.files FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_files_updated_at BEFORE UPDATE ON public.files FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.menu_permissions FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.menu_permissions FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.menus FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.menus FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.menus FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER audit_orders AFTER INSERT OR DELETE OR UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.orders FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.page_categories FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.page_categories FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.page_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.page_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.pages FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.pages FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.pages FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_pages_updated_at BEFORE UPDATE ON public.pages FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.permissions FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.permissions FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.photo_gallery FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.photo_gallery FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.photo_gallery FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_photo_gallery_updated_at BEFORE UPDATE ON public.photo_gallery FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.photo_gallery_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.photo_gallery_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.portfolio FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.portfolio FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.portfolio FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_portfolio_updated_at BEFORE UPDATE ON public.portfolio FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.portfolio_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.portfolio_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.product_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.product_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.product_type_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.product_type_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.product_types FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.product_types FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.product_types FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER audit_products AFTER INSERT OR DELETE OR UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.products FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.products FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.promotion_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.promotion_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.promotions FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.promotions FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.promotions FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_promotions_updated_at BEFORE UPDATE ON public.promotions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER audit_role_permissions AFTER INSERT OR DELETE OR UPDATE ON public.role_permissions FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.role_permissions FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.role_permissions FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER audit_roles AFTER INSERT OR DELETE OR UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.roles FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.seo_metadata FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.seo_metadata FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER update_seo_metadata_updated_at BEFORE UPDATE ON public.seo_metadata FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER audit_settings AFTER INSERT OR DELETE OR UPDATE ON public.settings FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.tags FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.testimonies FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.testimonies FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.testimonies FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_testimonies_updated_at BEFORE UPDATE ON public.testimonies FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.testimony_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.testimony_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.themes FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER trigger_ensure_single_active_theme BEFORE INSERT OR UPDATE OF is_active ON public.themes FOR EACH ROW EXECUTE FUNCTION public.ensure_single_active_theme();

CREATE TRIGGER audit_users AFTER INSERT OR DELETE OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.video_gallery FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.video_gallery FOR EACH ROW EXECUTE FUNCTION public.set_created_by();

CREATE TRIGGER trg_set_tenant_id BEFORE INSERT ON public.video_gallery FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

CREATE TRIGGER update_video_gallery_updated_at BEFORE UPDATE ON public.video_gallery FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER lock_created_by_trg BEFORE UPDATE ON public.video_gallery_tags FOR EACH ROW EXECUTE FUNCTION public.lock_created_by();

CREATE TRIGGER set_created_by_trg BEFORE INSERT ON public.video_gallery_tags FOR EACH ROW EXECUTE FUNCTION public.set_created_by();


  create policy "public_read_files"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'cms-uploads'::text));



  create policy "tenant_delete_isolation"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using (((bucket_id = 'cms-uploads'::text) AND ((name ~~ (public.current_tenant_id() || '/%'::text)) OR public.is_platform_admin())));



  create policy "tenant_select_isolation"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using (((bucket_id = 'cms-uploads'::text) AND ((name ~~ (public.current_tenant_id() || '/%'::text)) OR public.is_platform_admin())));



  create policy "tenant_update_isolation"
  on "storage"."objects"
  as permissive
  for update
  to authenticated
using (((bucket_id = 'cms-uploads'::text) AND ((name ~~ (public.current_tenant_id() || '/%'::text)) OR public.is_platform_admin())));



  create policy "tenant_upload_isolation"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'cms-uploads'::text) AND ((name ~~ (public.current_tenant_id() || '/%'::text)) OR public.is_platform_admin())));



