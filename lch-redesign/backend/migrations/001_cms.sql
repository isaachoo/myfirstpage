-- Li Chit Street Hostel CMS – schema v1
-- Run on a NEW, non-production Supabase project only after review.
-- No users, passwords, API keys, or personal data are seeded by this migration.
-- Separate staff email/password accounts are managed by Supabase Auth.
-- Disable public signup and invite accounts through Supabase Auth admin tools.

begin;

create table if not exists public.cms_staff (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'editor', 'viewer')),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.site_sections (
  section_key text primary key
    check (section_key ~ '^[a-z][a-z0-9_]{1,63}$'),
  title text not null,
  content jsonb not null default '{}'::jsonb,
  status text not null default 'draft'
    check (status in ('draft', 'published')),
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id),
  published_at timestamptz
);

create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9][a-z0-9-]{0,127}$'),
  title text not null,
  summary text not null default '',
  body text not null default '',
  status text not null default 'draft'
    check (status in ('draft', 'published')),
  published_at timestamptz,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

create index if not exists announcements_public_idx
  on public.announcements (published_at desc)
  where status = 'published';

create table if not exists public.content_history (
  id bigint generated always as identity primary key,
  table_name text not null check (table_name in ('site_sections', 'announcements')),
  item_key text not null,
  operation text not null check (operation in ('INSERT', 'UPDATE')),
  changed_by uuid references auth.users(id) on delete set null,
  changed_at timestamptz not null default now(),
  before_data jsonb,
  after_data jsonb
);

-- Security-definer helper reads the trusted staff table, NOT editable JWT metadata.
create or replace function public.cms_role()
returns text
language sql stable security definer
set search_path = ''
as $$
  select s.role
  from public.cms_staff as s
  where s.user_id = (select auth.uid()) and s.active = true
  limit 1
$$;

-- Publication/content writes require TOTP MFA (AAL2) as well as editor/owner role.
create or replace function public.cms_can_edit()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select coalesce(public.cms_role() in ('owner', 'editor'), false)
     and coalesce((select auth.jwt() ->> 'aal') = 'aal2', false)
$$;

revoke all on function public.cms_role() from public;
revoke all on function public.cms_can_edit() from public;
grant execute on function public.cms_role() to authenticated;
grant execute on function public.cms_can_edit() to authenticated;

-- The browser may read only its own staff membership. All membership changes
-- must be made by trusted administrators through a privileged server/Dashboard.
alter table public.cms_staff enable row level security;
create policy "staff may read own role" on public.cms_staff
  for select to authenticated
  using (user_id = (select auth.uid()));

alter table public.site_sections enable row level security;
create policy "visitors read published sections" on public.site_sections
  for select to anon, authenticated
  using (status = 'published');
create policy "staff can preview sections" on public.site_sections
  for select to authenticated
  using (public.cms_role() in ('owner', 'editor', 'viewer'));
create policy "editors insert sections with MFA" on public.site_sections
  for insert to authenticated
  with check (public.cms_can_edit());
create policy "editors update sections with MFA" on public.site_sections
  for update to authenticated
  using (public.cms_can_edit())
  with check (public.cms_can_edit());

alter table public.announcements enable row level security;
create policy "visitors read published announcements" on public.announcements
  for select to anon, authenticated
  using (status = 'published' and published_at <= now());
create policy "staff can preview announcements" on public.announcements
  for select to authenticated
  using (public.cms_role() in ('owner', 'editor', 'viewer'));
create policy "editors insert announcements with MFA" on public.announcements
  for insert to authenticated
  with check (public.cms_can_edit());
create policy "editors update announcements with MFA" on public.announcements
  for update to authenticated
  using (public.cms_can_edit())
  with check (public.cms_can_edit());

-- Prevent the public or editors from erasing content history.
alter table public.content_history enable row level security;
create policy "staff can read content history" on public.content_history
  for select to authenticated
  using (public.cms_role() in ('owner', 'editor', 'viewer'));

-- Auditable change history and server-derived authorship.
create or replace function public.cms_stamp_change()
returns trigger language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();
  if new.status = 'published' and
     (tg_op = 'INSERT' or old.status <> 'published') then
    new.published_at := now();
  end if;
  return new;
end
$$;

create or replace function public.cms_record_history()
returns trigger language plpgsql security definer
set search_path = ''
as $$
begin
  insert into public.content_history
    (table_name, item_key, operation, changed_by, before_data, after_data)
  values
    (tg_table_name,
     case when tg_table_name = 'site_sections' then new.section_key
          else new.id::text end,
     tg_op, auth.uid(),
     case when tg_op = 'INSERT' then null else to_jsonb(old) end,
     to_jsonb(new));
  return new;
end
$$;

create trigger site_sections_stamp
  before insert or update on public.site_sections
  for each row execute function public.cms_stamp_change();
create trigger site_sections_history
  after insert or update on public.site_sections
  for each row execute function public.cms_record_history();

create trigger announcements_stamp
  before insert or update on public.announcements
  for each row execute function public.cms_stamp_change();
create trigger announcements_history
  after insert or update on public.announcements
  for each row execute function public.cms_record_history();

-- Defense in depth: deliberately no client write privileges to staff/history
-- and no content deletion policy. service_role keys must never be in a browser.
revoke all on public.cms_staff from anon, authenticated;
revoke all on public.site_sections from anon, authenticated;
revoke all on public.announcements from anon, authenticated;
revoke all on public.content_history from anon, authenticated;

grant select on public.cms_staff to authenticated;
grant select on public.site_sections to anon, authenticated;
grant insert, update on public.site_sections to authenticated;
grant select on public.announcements to anon, authenticated;
grant insert, update on public.announcements to authenticated;
grant select on public.content_history to authenticated;

commit;
