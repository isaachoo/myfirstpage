# 李節街宿舍 · CMS implementation plan

## Status (2026-11-23)
Architecture and database schema **prepared, not deployed**. Live site and existing static prototype are unchanged. This folder is development-only. Do not run the SQL on any production database until it has been reviewed and tested.

## Chosen architecture

- **Public site:** static HTML generated at build time and hosted on Cloudflare Pages (later migration of the HTML prototype to data-driven generation).
- **Staff admin:** dedicated web dashboard at a separate \`/admin/\` route or subdomain.
- **Identity:** Supabase Auth email + password with invite-only users, password reset and TOTP MFA. No GitHub or Microsoft account required for staff.
- **Content:** Supabase Postgres with Row Level Security (RLS), plus version/audit history.
- **Image upload:** Supabase Storage private management with curated public image publishing (future phase).
- **Publishing:** explicit draft/publish state. On publish, securely trigger a Cloudflare Pages rebuild (server-side edge function or trusted workflow) so public pages remain static and SEO-friendly.
- **Hosting:** managed Supabase service, Cloudflare Pages; no WordPress/PHP or publicly exposed on-prem admin database.

## Role matrix

| Action | Anonymous | Viewer | Editor | Owner |
| --- | --- | --- | --- | --- |
| See published site | Yes | Yes | Yes | Yes |
| Preview drafts | No | Yes | Yes | Yes |
| Edit & publish content | No | No | Yes, MFA required | Yes, MFA required |
| Manage staff roles | No | No | No | Server-side administrator operation only |
| Delete content/audit history | No | No | No | No direct browser permission |

## First migration

\`migrations/001_cms.sql\` provides:
- staff role registry linked to Supabase Auth user IDs
- editable site sections and announcements
- public-read only published content and staff preview
- editor writes requiring a valid auth session + TOTP MFA
- automatic timestamps and write history
- no self-registration, no user secrets, no service-role keys in the frontend

## Implementation sequence

1. Create an isolated Supabase project; **do not share or commit credentials**.
2. Review/apply and test schema; disable open user signups before inviting staff.
3. Invite first staff user, grant owner role via privileged console, enroll MFA.
4. Create admin sign-in and CMS editing UI, plus tests for unauthorized requests.
5. Move website content out of static HTML into structured sections; draft/review/publish flow.
6. Configure image storage with tight file limits/types and permissions.
7. Set up Cloudflare Pages build hooks, staging site and deployment history.
8. Security/backup/recovery testing, content owner verification, then consider DNS migration.

## Important security and operational notes

- \`service_role\` / secret keys must never be committed, shown in HTML, or sent to ChatGPT.
- Staff should use individual credentials and MFA; turn off public sign-up. Admin creation/role changes happen in a privileged interface.
- Supabase database RLS must be tested for anonymous, viewer, editor and owner roles before launch.
- SQL files are not a substitute for a running, configured Auth/DB service.
- The current prototype includes unconfirmed operational details and fees. Obtain written content approval before launching a public replacement.
- Supabase and Cloudflare are separate vendors; check organization approval, data handling, backups, regional hosting, and recurring costs.
- Public assets/content should contain no resident personal information, and access to editorial account data should be minimized.

## Official reference material

- https://supabase.com/docs/guides/auth
- https://supabase.com/docs/guides/auth/auth-mfa
- https://supabase.com/docs/guides/database/postgres/row-level-security
- https://supabase.com/docs/guides/security/production-checklist
- https://developers.cloudflare.com/pages/configuration/deploy-hooks/
