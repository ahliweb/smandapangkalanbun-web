# Admin Menu System

> **Version**: 2.12.0 | **Last Updated**: 2026-01-12

## Overview

AWCMS menggunakan sistem menu admin yang dinamis dan terpusat. Struktur menu disimpan dalam database (`admin_menus`) dan memiliki fallback configuration di frontend (`useAdminMenu.js`). The system also supports menu injection from **Extensions** and **Core Plugins**.

---

## Menu Groups

Menu dibagi menjadi beberapa grup logis untuk memudahkan navigasi:

| Group | Order | Description | Key Modules |
|-------|-------|-------------|-------------|
| **CONTENT** | 10 | Core content management | Dashboard, Articles, Pages, Visual Builder, Themes, Widgets, Portfolio, Testimonials, Announcements, Promotions, Contact Messages, Contacts CRM |
| **MEDIA** | 20 | File and gallery management | Media Library, Photo Gallery, Video Gallery |
| **COMMERCE** | 30 | E-commerce features | Products, Product Types, Orders |
| **NAVIGATION** | 40 | Site navigation settings | Menu Manager, Categories, Tags |
| **USERS** | 50 | User and access management | Users, Roles & Permissions, Policies |
| **SYSTEM** | 60 | System tools and settings | SEO Manager, Languages, Extensions, Sidebar Manager, Notifications, Audit Logs |
| **CONFIGURATION** | 70 | Global tenant settings | General Settings, Branding, SSO & Security |
| **IoT** | 80 | Internet of Things | IoT Devices |
| **MOBILE** | 85 | Mobile app management | Mobile Users, Push Notifications, App Config |
| **PLATFORM** | 100 | Super Admin functions | Tenant Management |

---

## Complete Menu Items

### CONTENT Group (order: 10)

| Key | Label | Path | Icon | Permission |
|-----|-------|------|------|------------|
| `home` | Dashboard | `home` | LayoutDashboard | *none* |
| `articles` | Articles | `articles` | FileText | `tenant.article.read` |
| `pages` | Pages | `pages` | FileEdit | `tenant.page.read` |
| `visual_builder` | Visual Builder | `visual-pages` | Layout | `tenant.page.read` |
| `themes` | Themes | `themes` | Palette | `tenant.theme.read` |
| `widgets` | Widgets | `widgets` | Layers | `tenant.theme.read` |
| `portfolio` | Portfolio | `portfolio` | Briefcase | `tenant.portfolio.read` |
| `testimonials` | Testimonials | `testimonies` | MessageSquareQuote | `tenant.testimonies.read` |
| `announcements` | Announcements | `announcements` | Megaphone | `tenant.announcements.read` |
| `promotions` | Promotions | `promotions` | Tag | `tenant.promotions.read` |
| `contact_messages` | Contact Messages | `messages` | Inbox | `tenant.contact_messages.read` |
| `contacts` | Contacts CRM | `contacts` | Contact | `tenant.contacts.read` |

### MEDIA Group (order: 20)

| Key | Label | Path | Icon | Permission |
|-----|-------|------|------|------------|
| `files` | Media Library | `files` | FolderOpen | `tenant.media.read` |
| `photo_gallery` | Photo Gallery | `photo-gallery` | Image | `tenant.photo_gallery.read` |
| `video_gallery` | Video Gallery | `video-gallery` | Video | `tenant.video_gallery.read` |

### COMMERCE Group (order: 30)

| Key | Label | Path | Icon | Permission |
|-----|-------|------|------|------------|
| `products` | Products | `products` | Package | `tenant.products.read` |
| `product_types` | Product Types | `product-types` | Box | `tenant.product_types.read` |
| `orders` | Orders | `orders` | ShoppingCart | `tenant.orders.read` |

### NAVIGATION Group (order: 40)

| Key | Label | Path | Icon | Permission |
|-----|-------|------|------|------------|
| `menus` | Menu Manager | `menus` | Menu | `tenant.menu.read` |
| `categories` | Categories | `categories` | FolderTree | `tenant.categories.read` |
| `tags` | Tags | `tags` | Hash | `tenant.tag.read` |

### USERS Group (order: 50)

| Key | Label | Path | Icon | Permission |
|-----|-------|------|------|------------|
| `users` | Users | `users` | Users | `tenant.user.read` |
| `roles` | Roles & Permissions | `roles` | Shield | `tenant.role.read` |
| `policies` | Policies | `policies` | ShieldCheck | `tenant.policy.read` |

### SYSTEM Group (order: 60)

| Key | Label | Path | Icon | Permission |
|-----|-------|------|------|------------|
| `seo_manager` | SEO Manager | `seo` | Search | `tenant.setting.read` |
| `languages` | Languages | `languages` | Languages | `tenant.setting.read` |
| `extensions` | Extensions | `extensions` | Puzzle | `platform.module.read` |
| `sidebar_manager` | Sidebar Manager | `admin-navigation` | List | `tenant.setting.update` |
| `notifications` | Notifications | `notifications` | MessageSquareQuote | `tenant.notification.read` |
| `audit_logs` | Audit Logs | `audit-logs` | FileClock | `tenant.audit.read` |

### CONFIGURATION Group (order: 70)

| Key | Label | Path | Icon | Permission |
|-----|-------|------|------|------------|
| `settings_general` | General Settings | `settings/general` | Settings | `tenant.setting.read` |
| `settings_branding` | Branding | `settings/branding` | Palette | `tenant.setting.update` |
| `sso` | SSO & Security | `sso` | Lock | `platform.setting.read` |

### IoT Group (order: 80)

| Key | Label | Path | Icon | Permission |
|-----|-------|------|------|------------|
| `iot_devices` | IoT Devices | `devices` | Cpu | `tenant.setting.read` |

### MOBILE Group (order: 85)

| Key | Label | Path | Icon | Permission |
|-----|-------|------|------|------------|
| `mobile_users` | Mobile Users | `mobile/users` | Smartphone | `tenant.setting.read` |
| `push_notifications` | Push Notifications | `mobile/push` | Bell | `tenant.setting.update` |
| `mobile_config` | App Config | `mobile/config` | Settings | `tenant.setting.update` |

### PLATFORM Group (order: 100)

| Key | Label | Path | Icon | Permission |
|-----|-------|------|------|------------|
| `tenants` | Tenant Management | `tenants` | Building | `platform.tenant.read` |

---

## Configuration Layers

Menu dikonfigurasi melalui tiga layer:

### 1. Database (`admin_menus` table)

Source of truth utama.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `key` | TEXT | Unique identifier |
| `label` | TEXT | Display name |
| `path` | TEXT | Route path |
| `icon` | TEXT | Lucide icon name |
| `permission` | TEXT | Required permission key |
| `group_label` | TEXT | Group name |
| `group_order` | INT | Group sort order |
| `order` | INT | Item sort within group |
| `is_visible` | BOOLEAN | Visibility toggle |
| `created_at` | TIMESTAMPTZ | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last update timestamp |

### 2. Frontend Fallback (`src/hooks/useAdminMenu.js`)

Used when database is empty or unavailable. The `DEFAULT_MENU_CONFIG` array provides all menu items with their default configuration.

### 3. Extension & Plugin Injection

Extensions and plugins can inject menu items dynamically:

```javascript
// Extension menus from database
// Fetched from extension_menu_items table
// Group label = Extension name
// Group order = 900 (at bottom)

// Plugin menus via hook system
const pluginMenuItems = hooks.applyFilters('admin_menu_items', []);
// Group label = 'PLUGINS' or item.parent
// Group order = 75
```

---

## useAdminMenu Hook

The `useAdminMenu` hook provides full menu management capabilities.

### API

```javascript
import { useAdminMenu } from '@/hooks/useAdminMenu';

const {
  menuItems,        // Array of all menu items
  loading,          // Boolean loading state
  error,            // Error object if any
  fetchMenu,        // Refresh menu from database
  updateMenuOrder,  // Reorder menu items
  toggleVisibility, // Toggle item visibility
  updateMenuItem,   // Update item properties
  updateGroup       // Update group label/order
} = useAdminMenu();
```

### Menu Item Structure

```javascript
{
  id: 'uuid-or-key',     // Unique identifier
  key: 'articles',       // Short key
  label: 'Articles',     // Display name
  path: 'articles',      // Route path (appended to /cmspanel/)
  icon: 'FileText',      // Lucide icon name
  permission: 'tenant.article.read', // ABAC permission
  group_label: 'CONTENT',// Group name
  group_order: 10,       // Group sort order
  order: 20,             // Item sort within group
  is_visible: true,      // Show/hide
  source: 'core'         // 'core' | 'extension' | 'plugin'
}
```

---

## Permissions

Setiap item menu dilindungi oleh permission key (ABAC). Format standar:

| Scope | Format | Example |
|-------|--------|---------|
| Tenant | `tenant.{module}.{action}` | `tenant.article.read` |
| Platform | `platform.{module}.{action}` | `platform.tenant.read` |

### Permission Examples

| Menu Item | Permission Key |
|-----------|----------------|
| Articles | `tenant.article.read` |
| Users | `tenant.user.read` |
| Settings | `tenant.setting.update` |
| Tenant Management | `platform.tenant.read` |
| Extensions | `platform.module.read` |

---

## Menu Visibility Logic

```javascript
// In Sidebar.jsx
const visibleMenus = menuItems.filter(item => {
  // Hidden items are never shown
  if (!item.is_visible) return false;
  
  // Super admin/owner sees everything
  if (['super_admin', 'owner'].includes(userRole)) return true;
  
  // No permission required
  if (!item.permission) return true;
  
  // Check user has permission
  return hasPermission(item.permission);
});
```

---

## Adding New Menu Items

### Option 1: Database (Recommended)

Insert directly into `admin_menus` table:

```sql
INSERT INTO admin_menus (key, label, path, icon, permission, group_label, group_order, order, is_visible)
VALUES ('my_module', 'My Module', 'my-module', 'Star', 'tenant.my_module.read', 'CONTENT', 10, 100, true);
```

### Option 2: Via Plugin Hook

Register in your plugin's initialization:

```javascript
import { hooks } from '@/lib/hooks';

hooks.addFilter('admin_menu_items', 'my_plugin', (items) => {
  return [
    ...items,
    {
      id: 'my-plugin-menu',
      label: 'My Plugin',
      path: 'my-plugin',
      icon: 'Puzzle',
      permission: 'tenant.setting.read',
      group: 'PLUGINS',
      groupOrder: 75,
      order: 10
    }
  ];
});
```

### Option 3: Update Fallback Config

Add to `DEFAULT_MENU_CONFIG` in `useAdminMenu.js`:

```javascript
{ 
  id: 'my_module', 
  key: 'my_module', 
  label: 'My Module', 
  path: 'my-module', 
  icon: 'Star', 
  permission: 'tenant.my_module.read', 
  group_label: 'CONTENT', 
  group_order: 10, 
  order: 100, 
  is_visible: true 
},
```

---

## Sidebar Manager

The **Sidebar Manager** (`/cmspanel/admin-navigation`) provides a UI for:

- Reordering menu items via drag-and-drop
- Toggling item visibility
- Renaming menu labels
- Changing group assignments
- Editing group labels and order

Changes are persisted to the `admin_menus` table.
