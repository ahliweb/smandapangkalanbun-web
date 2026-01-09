# Changelog

All notable changes to this project will be documented in this file.

## [2.9.1] - 2026-01-09

### Security

- **XSS Prevention**: Refactored `dangerouslySetInnerHTML` usage to use strict `DOMPurify` sanitization across all visual builder blocks and public pages.

### Infrastructure

- **CI/CD Fixes**: Corrected GitHub Actions workflow paths for caching (`awcms-public/primary`) and Flutter build (`awcms-mobile/primary`).
- **Cloudflare Support**: Added proxy configuration to support `awcms-public` build without root directory changes.

### Documentation

- **Folder Structure**: Updated docs to reflect the specific `primary` subdirectory structure for public and mobile apps.
- **Audited**: Verified alignment between documentation claims and codebase implementation.

## [2.9.0] - 2026-01-05

- Dashboard UI refactor to use standardized AdminPageLayout
- Resolved all remaining ESLint warnings
- Fixed Turnstile CAPTCHA validation flow
- Updated project dependencies to latest stable versions
- Released v2.9.0

## [2.8.0] - 2025-12-28

- Mobile admin module integration
- Esp32 IoT module enhancements
- Database schema updates for device management
