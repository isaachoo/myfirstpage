# 李節街宿舍 · Browser-only CMS Demo

> **This is a design and interaction prototype, not a real secured CMS.** The original site at https://lch.sjs.org.hk/ remains untouched.

## Links

- [Demo administration dashboard](./index.html)
- [Public website design](../index.html)
- [Bridge script applying demo edits to the public design](./public-preview.js)

## What this demo demonstrates

- Choose **Editor** or **Viewer** for a role-based UI preview, **without password authentication**
- Edit homepage heading, description, service overview, accommodation fees, address and phone
- Save draft and publish page content
- Create, edit, publish, unpublish and delete news announcements
- Upload a small JPG/PNG/WebP image for the hero area, and publish or remove it
- Preview either draft or published website content
- View local activity history, export current demo data as JSON, or reset demo data

## How persistence works

Everything is stored in **this browser's localStorage** under the key \`lch-cms-demo-v1\`. No changes are written to GitHub, Supabase, Cloudflare, any backend, or the existing WordPress website. A different device/browser (or private browsing) has independent data. Clearing website data resets content. The iframe/public prototype must be loaded on the **same origin** as the dashboard for synchronized previews.

### Not included

- **No real staff accounts, credentials, access controls or MFA.** The Editor and Viewer selection buttons only demonstrate the intended interface; anyone who opens the demo can choose Editor.
- No server-side database, backups, approvals, collaboration, notifications or safe audit trail.
- No durable hosting guarantee from third-party HTML renderers.
- No real publishing to an internet-wide public site.
- No protection for draft previews; the \`?cmsPreview=draft\` URL is for local demo purposes only.

**Never put private resident information, staff passwords or production secrets in this demo.**

## Production path

Build a protected admin frontend integrated with Supabase Auth (invite-only individual accounts, secure password recovery and MFA), Supabase Postgres RLS, server-side audit/event logging and storage, and static publication via Cloudflare Pages.

The preliminary schema and intended security controls live in [../backend](../backend), and have **not** been deployed. These are separate from the demo.

## Demo-only content caution

The visible service details in the redesign (including accommodation fee information) are concept copy from the existing public website and need the service team's independent confirmation prior to real deployment.
