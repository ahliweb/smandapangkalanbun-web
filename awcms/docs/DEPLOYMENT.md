# Deployment Guide

AWCMS is a **Monorepo** containing two distinct applications. You will deploy them separately to different hosting providers (or the same one as separate projects), connecting to the **same GitHub Repository**.

---

## 1. Public Portal (`awcms-public`)

**Recommended Host**: Cloudflare Pages
**Why**: Native support for Astro Edge SSR and high performance.

### Setup Steps

1. Log in to [Cloudflare Dashboard](https://dash.cloudflare.com) > **Workers & Pages**.
2. Click **Create Application** > **Connect to Git**.
3. Select your GitHub Repository (`ahliweb/awcms`).
4. **Configure Build Settings** (Crucial!):
    * **Project Name**: `your-brand-portal`
    * **Production Branch**: `main`
    * **Framework Preset**: Select `Astro`
    * **Root Directory**: `/awcms-public` (⚠️ Important: Do not leave empty)
    * **Build Command**: `npm run build`
    * **Output Directory**: `dist`
5. **Environment Variables**:
    * `PUBLIC_SUPABASE_URL`: Your Supabase Project URL.
    * `PUBLIC_SUPABASE_ANON_KEY`: Your Supabase Anon Key.
6. Click **Save and Deploy**.

---

## 2. Admin Panel (`awcms`)

**Recommended Host**: Vercel (easiest for React SPA) or Netlify.

### Setup Steps (Vercel)

1. Log in to [Vercel](https://vercel.com/new).
2. Import the **Same GitHub Repository** (`ahliweb/awcms`).
3. **Configure Project**:
    * **Framework Preset**: `Vite`
    * **Root Directory**: Edit and select `awcms` folder.
4. **Environment Variables**:
    * `VITE_SUPABASE_URL`: Your Supabase URL.
    * `VITE_SUPABASE_ANON_KEY`: Your Supabase Anon Key.
5. Click **Deploy**.

---

## 3. Connect the Dots (Supabase)

Once both sites are live, you need to update Supabase Authentication settings.

1. Go to Supabase Dashboard > **Authentication** > **URL Configuration**.
2. **Site URL**: Set to your **Admin Panel** URL (e.g., `https://admin.your-project.vercel.app`).
    * This is where "Magic Links" and Password Resets will redirect by default.
3. **Redirect URLs**: Add your Public Portal URL(s).
    * `https://your-brand-portal.pages.dev/*`
    * `https://*.your-brand-portal.pages.dev/*` (If using wildcards for tenants)

---

## 4. DNS & Custom Domains (Multi-Tenancy)

### For Public Portal (Tenants)

To allow tenants to use subdomains (e.g., `tenant1.yoursite.com`) or custom domains (`tenant.com`):

1. In Cloudflare Pages > **Custom Domains**, add your main domain (`yoursite.com`).
2. For subdomains: Add a CNAME record `*` pointing to `your-brand-portal.pages.dev` in your DNS provider.
3. **AWCMS Configuration**:
    * Go to Admin Panel > **Tenants**.
    * Edit a Tenant -> Update **Subdomain** or **Custom Domain** field.
    * The Public Portal Middleware (`src/middleware.ts`) will automatically resolve the host.

### For Admin Panel

Typically lives on a secure subdomain like `admin.yoursite.com` or `app.yoursite.com`.
