-- Website form submissions: preserve the raw payload.
--
-- NOT APPLIED. This file is a proposal in bcb94/Bcb-res, written against
-- bcb94/bcb-command-center @ b4bb8a7 without live database access. Read
-- ../README.md before running it -- there is a preflight that must pass first.
--
-- WHY
--
-- supabase/functions/website-intake maps an inbound payload onto about ten
-- `leads` columns and drops the rest. There is no record of what the customer
-- actually sent. A field the form collects but `leads` has no column for is
-- gone the moment the function returns.
--
-- The Website Backend spec says not to do that more times than it says anything
-- else: section 10 ("never destroy the original raw submission"), section 20
-- ("do not cascade-delete submissions because a temporary lead is deleted"),
-- section 27.10 ("duplicate logic never deletes the new raw submission"),
-- section 31 (deleting raw submissions after lead creation: forbidden).
-- Acceptance tests 8 and 10 are exactly this. Both fail today.
--
-- WHAT THIS DOES NOT DO
--
-- Nothing here changes an existing table, policy, function or trigger. It adds
-- two tables and their policies. `leads` is untouched; the intake function keeps
-- working unchanged until the patch in ../website-intake.patch.md is deployed.
-- Duplicate detection is deliberately a separate migration (0002) because it is
-- the part that has to touch `leads`.
--
-- COST, STATED PLAINLY
--
-- This is DDL. Per AGENT_HANDOFF.md section 1, a schema change makes PostgREST
-- reload its catalog and serve nothing while it does -- measured at 10.7s and
-- 26s on this database. Requests queue past the 8s statement_timeout and every
-- endpoint 500s at once. It clears itself. Run this outside working hours.

begin;

-- ---------------------------------------------------------------------------
-- 1. The raw submission. Append-only by construction.
-- ---------------------------------------------------------------------------
create table if not exists public.website_form_submissions (
  id                 uuid primary key default gen_random_uuid(),

  -- Which form, and which shape of it. Phase 1 has one form, but section 10
  -- forbids hard-coding it: a submission must still be readable after the form
  -- it came from is edited, which is what form_version is for.
  form_key           text        not null default 'quote',
  form_version       integer     not null default 1,

  -- The payload as received. Written once. See the guard below.
  raw_values         jsonb       not null,

  -- Normalization writes HERE, never back into raw_values (D-006). Null until
  -- 0002 lands; nullable on purpose so this migration stays additive.
  normalized_values  jsonb,

  -- Provenance (section 10). All nullable: the Netlify webhook path carries
  -- none of it.
  source_page        text,
  referrer           text,
  utm                jsonb,

  -- Replaces the two meanings currently overloaded onto leads.internal_notes.
  --
  -- Today the intake function stores 'intake_ip:<ip>' or 'netlify_form:<id>' in
  -- that column and then queries it back for the rate limit and the webhook
  -- idempotency check. internal_notes is also a human note field on the Leads
  -- page, so a staff member who types into it on a website lead silently breaks
  -- both mechanisms for that row. Nothing observed says that has happened; it
  -- is a trap, not an incident.
  intake_ip          text,

  -- Netlify's submission id. UNIQUE, and nullable -- Postgres permits many
  -- NULLs in a unique index, so the JSON path is unaffected while the webhook
  -- path gets its idempotency from the database instead of from a string
  -- prefix. A webhook retry becomes a duplicate-key error the function can
  -- treat as success.
  external_source    text,
  external_id        text,

  created_at         timestamptz not null default now()
);

create unique index if not exists website_form_submissions_external_key
  on public.website_form_submissions (external_source, external_id)
  where external_id is not null;

-- Rate-limit lookup: "how many from this IP since <t>". Partial, because the
-- overwhelming majority of rows will have an IP and we only ever scan recent
-- ones.
create index if not exists website_form_submissions_intake_ip_created_at
  on public.website_form_submissions (intake_ip, created_at desc)
  where intake_ip is not null;

create index if not exists website_form_submissions_created_at
  on public.website_form_submissions (created_at desc);

comment on table public.website_form_submissions is
  'Raw public-form payloads, append-only. Never deleted, never overwritten. A lead is derived from one of these; the submission outlives the lead.';

-- ---------------------------------------------------------------------------
-- 2. raw_values is written once.
--
-- The app already has a pin-the-old-value trigger (chat_notification_before_update
-- pins `preview` so a recipient cannot rewrite what they were sent). This one
-- RAISES instead of pinning, deliberately: that case is adversarial and silence
-- is the guard, this one is our own code and a silent no-op would hide the bug
-- it is meant to catch.
-- ---------------------------------------------------------------------------
create or replace function private.website_submission_immutable_raw()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.raw_values is distinct from old.raw_values then
    raise exception
      'website_form_submissions.raw_values is append-only (spec 10, 27.10, 31; DECISIONS D-006). Write normalization to normalized_values instead.'
      using errcode = 'restrict_violation';
  end if;
  if new.created_at is distinct from old.created_at then
    raise exception 'website_form_submissions.created_at is immutable'
      using errcode = 'restrict_violation';
  end if;
  return new;
end;
$$;

drop trigger if exists website_form_submissions_immutable_raw
  on public.website_form_submissions;
create trigger website_form_submissions_immutable_raw
  before update on public.website_form_submissions
  for each row execute function private.website_submission_immutable_raw();

-- ---------------------------------------------------------------------------
-- 3. Submission <-> lead. A link table, never a foreign key on `leads`.
--
-- Section 20 forbids a deleted lead taking submissions with it. A link row with
-- a nullable lead_id gives that for free: delete the lead and the link survives
-- with lead_id NULL, so the submission is still there and still visibly came
-- through this path. `on delete restrict` on the submission side states the
-- other half -- submissions are not deleted.
-- ---------------------------------------------------------------------------
create table if not exists public.lead_submission_links (
  id             uuid primary key default gen_random_uuid(),
  submission_id  uuid not null references public.website_form_submissions(id) on delete restrict,
  lead_id        uuid          references public.leads(id)                    on delete set null,

  -- How this link came to be. 'created' = this submission created the lead;
  -- 'linked' = duplicate detection attached it to an existing one (0002).
  -- Section 11 forbids auto-merge, so 'linked' never rewrites the lead.
  link_reason    text not null default 'created'
                 check (link_reason in ('created', 'linked', 'manual')),

  created_at     timestamptz not null default now()
);

create index if not exists lead_submission_links_lead_id
  on public.lead_submission_links (lead_id) where lead_id is not null;
create index if not exists lead_submission_links_submission_id
  on public.lead_submission_links (submission_id);

comment on table public.lead_submission_links is
  'Traces a lead back to the submissions it came from. lead_id goes NULL if the lead is deleted; the submission is never touched (spec 20).';

-- ---------------------------------------------------------------------------
-- 4. Grants, then RLS.
--
-- Convention from AGENT_HANDOFF.md section 7: a new public table starts with
-- ALL granted to `authenticated`. Revoke, then grant explicitly. Note RLS does
-- not police TRUNCATE -- the revoke is what does.
--
-- Nobody gets INSERT. Both intake paths run as service_role inside the edge
-- function, which bypasses RLS; a browser session has no business writing here.
-- No UPDATE either: normalized_values is written by service_role in the same
-- request. No DELETE, ever -- that is the whole point of the table.
-- ---------------------------------------------------------------------------
revoke all on public.website_form_submissions from anon, authenticated;
revoke all on public.lead_submission_links     from anon, authenticated;

grant select on public.website_form_submissions to authenticated;
grant select on public.lead_submission_links     to authenticated;

alter table public.website_form_submissions enable row level security;
alter table public.lead_submission_links     enable row level security;

-- private.is_internal() already exists and reads auth.uid(); it is the same
-- definition lib/roles.ts INTERNAL_ROLES mirrors. A flat function call, not an
-- inline sub-SELECT -- see AGENT_HANDOFF.md section 3 for why that distinction
-- has cost this database five production incidents in one day.
drop policy if exists website_form_submissions_select on public.website_form_submissions;
create policy website_form_submissions_select
  on public.website_form_submissions
  for select to authenticated
  using (private.is_internal());

drop policy if exists lead_submission_links_select on public.lead_submission_links;
create policy lead_submission_links_select
  on public.lead_submission_links
  for select to authenticated
  using (private.is_internal());

commit;

-- ---------------------------------------------------------------------------
-- Verifying this did what it says
--
--   -- test 17: a public caller sees nothing
--   set role anon;
--   select count(*) from public.website_form_submissions;  -- expect: permission denied
--   reset role;
--
--   -- test 8 / D-006: raw_values cannot be rewritten
--   update public.website_form_submissions set raw_values = '{}'::jsonb
--    where id = '<some id>';                                -- expect: restrict_violation
--
--   -- test 10 / spec 20: deleting a lead leaves the submission intact
--   begin;
--     delete from public.leads where id = '<a test lead>';
--     select count(*) from public.website_form_submissions where id = '<its submission>';
--     -- expect: 1, and its link row present with lead_id null
--   rollback;
-- ---------------------------------------------------------------------------
