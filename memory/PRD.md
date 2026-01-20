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

## What's Been Implemented (Jan 20, 2026)
### Pages Created:
- [x] Home (/) - Hero, stats, about, news, CTA
- [x] Profile (/profil) - Vision/Mission, history timeline, facilities
- [x] News (/berita) - Articles list, agenda, gallery
- [x] Finance (/keuangan) - BOS, APBD, Committee
- [x] Services (/layanan) - Extracurricular, labs, library
- [x] Achievements (/prestasi) - Categorized achievements
- [x] Alumni (/alumni) - Featured alumni, association
- [x] Contact (/kontak) - Form, map, social media
- [x] English version (/en/)

### Data Files:
- site.json, navigation.json
- profile.json, organization.json, staff.json
- news.json, finance.json, services.json
- achievements.json, alumni.json, contact.json
- locales/id.json, locales/en.json

## Prioritized Backlog (P0/P1/P2)

### P0 - Critical (Next Sprint)
- [ ] Sub-pages for profile (sambutan-kepala-sekolah, sejarah, visi-misi, etc.)
- [ ] Individual news article pages
- [ ] Image optimization with real school photos

### P1 - Important
- [ ] Search functionality
- [ ] News pagination
- [ ] Gallery lightbox
- [ ] PPDB integration form

### P2 - Nice to Have
- [ ] Dark mode support
- [ ] PDF report downloads
- [ ] Calendar integration
- [ ] E-learning integration

## Next Tasks
1. Create detailed sub-pages for profile section
2. Add real school images from Google Drive assets
3. Implement news article detail pages
4. Add search functionality
