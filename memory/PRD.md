# PRD - Website SMAN 2 Pangkalan Bun

## Original Problem Statement
Build a school website template for SMAN 2 Pangkalan Bun based on AWCMS framework using Astro + React + Vite with multi-language support (Indonesian/English).

## Architecture
- **Frontend**: Astro 5.x + React + Vite + Tailwind CSS
- **Data**: JSON files (ready for Supabase migration)
- **i18n**: Custom implementation with locale files (id/en)
- **Icons**: astro-icon with @iconify-json/tabler

## User Personas
1. **Students & Parents**: View school info, news, achievements
2. **Teachers & Staff**: Access school profile, facilities info
3. **Prospective Students**: PPDB info, school profile, extracurricular
4. **Alumni**: Alumni network, school updates

## Core Requirements
- Multi-language support (ID/EN) ✅
- Responsive design ✅
- SEO-optimized pages ✅
- All menu structure as specified ✅

## What's Been Implemented

### Iteration 1 (Jan 20, 2026)
- Home page with hero, stats, about, news, CTA sections
- Profile overview page
- News listing page
- Finance transparency page
- Services overview
- Achievements page
- Alumni page
- Contact page with form

### Iteration 2 (Jan 20, 2026) - Sub-pages Added
**Profile Sub-pages:**
- /profil/sambutan-kepala-sekolah - Principal's welcome message
- /profil/sejarah - History with timeline and milestones
- /profil/visi-misi - Vision & Mission with detailed cards
- /profil/sarana-prasarana - Facilities with cards and stats
- /profil/adiwiyata - Adiwiyata environmental program
- /profil/tenaga-pendidik - Teaching & admin staff tables
- /profil/struktur-organisasi - Org structure (school, committee, OSIS, MPK)

**News Sub-pages:**
- /berita/[slug] - Dynamic news article detail pages
- /berita/galeri - Photo gallery page
- /berita/agenda - Agenda/events listing

**Services Sub-pages:**
- /layanan/ekstrakurikuler - All extracurricular activities list
- /layanan/laboratorium - Labs with images and rules
- /layanan/perpustakaan - Library with images and services

**Assets:**
- Integrated school images from Unsplash/Pexels
- Created /src/data/images.json for image management

## Data Files Structure
```
src/data/
├── site.json - School info, stats, social media
├── navigation.json - Menu structure (multi-language)
├── images.json - Image URLs for various sections
├── pages/
│   ├── profile.json - Principal message, history, vision, facilities
│   ├── organization.json - School, committee, OSIS, MPK structures
│   ├── staff.json - Teachers and admin staff lists
│   ├── services.json - Extracurricular, labs, library info
│   ├── achievements.json - Student achievements
│   ├── alumni.json - Featured alumni
│   └── contact.json - Contact info and social media
└── articles/
    ├── news.json - News articles, gallery, agenda
    └── finance.json - BOS, APBD, Committee finances
```

## Prioritized Backlog

### P0 - Critical (Next Sprint)
- [ ] Search functionality
- [ ] News pagination
- [ ] Real school images from Google Drive assets

### P1 - Important
- [ ] PPDB online registration form
- [ ] Gallery lightbox feature
- [ ] PDF report downloads
- [ ] Calendar integration

### P2 - Nice to Have
- [ ] Dark mode support
- [ ] E-learning integration
- [ ] Supabase database migration

## Testing Status
- Iteration 1: 100% passed (all pages load, navigation works)
- Iteration 2: 100% passed (all sub-pages, detail pages, images work)
