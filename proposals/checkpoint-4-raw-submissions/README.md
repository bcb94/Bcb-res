# Proposal — preserve the raw website submission

**Status: not applied.** Nothing here has been run against any database, and no
file in `bcb94/bcb-command-center` has been modified. This is a reviewable
package, written to be read before it is trusted.

| | |
|---|---|
| Target | `bcb94/bcb-command-center` @ `b4bb8a7` |
| Supabase project | `lvsobajewvpsjdrokrny` (BCB Command Center) |
| Spec | §10, §11, §20, §27.10, §31 · acceptance tests **8** and **10** |
| Decisions | D-003, D-006, D-008, **D-009 step 1** |
| Files | `0001_website_form_submissions.sql` · `website-intake.patch.md` |

## The problem, in one paragraph

`supabase/functions/website-intake` is live and does most of what the spec asks:
two entry paths, honeypot, origin allowlist, IP rate limit, a narrow fixed-column
insert into `leads`, then round-robin assignment, a two-hour follow-up todo and a
team email — each best-effort and independently caught, which is already the
post-commit ordering D-003 requires. What it does not do is keep the payload. It
maps the request onto about ten `leads` columns and discards the remainder, so a
field the form collects but `leads` has no column for is lost the moment the
function returns. There is no `form_submissions` table anywhere in the repo —
verified by grep across `supabase/`, `app/` and `lib/`. Acceptance tests 8 and 10
fail against production today.

This is the spec's most repeated constraint, and closing it is additive: two new
tables, no change to `leads`, no change to any existing policy, function or
trigger.

## Read before applying

**I could not verify this against the live database.** Direct SQL access was
declined in the session that wrote it, so the SQL is written from the repo — and
per `AGENT_HANDOFF.md` §1, *the migrations directory lies*: 213 migrations are
applied to production and 90 files exist. Three assumptions are load-bearing and
each is one query:

```sql
-- 1. private.is_internal() exists and takes no arguments (the RLS policies call it).
select p.proname, pg_get_function_identity_arguments(p.oid)
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
 where n.nspname = 'private' and p.proname = 'is_internal';

-- 2. public.leads.id is uuid (the link table's FK assumes it).
select column_name, data_type
  from information_schema.columns
 where table_schema = 'public' and table_name = 'leads' and column_name = 'id';

-- 3. Neither table name is already taken.
select table_name from information_schema.tables
 where table_schema = 'public'
   and table_name in ('website_form_submissions', 'lead_submission_links');
```

If `leads.id` is not `uuid`, change `lead_submission_links.lead_id` to match. If
`private.is_internal()` is absent or takes an argument, fix the two policies —
do **not** substitute a similar-looking helper. `AGENT_HANDOFF.md` §3 is explicit
that `private.can_access_project` and `is_crew_assigned_project` look
interchangeable with narrower helpers and are not, and that either substitution
silently changes who can see what.

**Run it outside working hours.** It is DDL, and DDL on this database makes
PostgREST reload its catalog and serve nothing while it does — 10.7s and 26s,
measured. Every endpoint 500s at once and it clears itself.

**Apply it the way this repo applies migrations:** Supabase MCP
`apply_migration`, then write the matching file into `supabase/migrations/` by
hand. Both halves, every time — the file is the only human-readable record of
why.

## Order of work

1. Run the preflight above. Fix anything it contradicts.
2. Apply `0001_website_form_submissions.sql`. Nothing changes behaviourally;
   the function still writes only to `leads`.
3. Run the verification block at the foot of that file — anon sees nothing,
   `raw_values` refuses to be rewritten, a deleted lead leaves its submission
   intact.
4. Apply `website-intake.patch.md` to the edge function and deploy. Diff the
   *deployed* body against the repo copy first; they are not guaranteed to match.
5. Run the six checks in that document, then confirm the public site still
   submits end to end.

Steps 2 and 4 are separately shippable and separately reversible. Step 2 is
reversible by dropping two tables nothing reads yet; step 4 by redeploying the
previous function body.

## What this deliberately leaves out

**Duplicate detection** — tests 9, 10, 11 and Scenario B — is D-009 step 2 and is
not in this package. The design is settled: normalize email and phone (casing,
`+1`, punctuation, whitespace), look for an exact match on either, and link the
new submission to the existing lead through `lead_submission_links` with
`link_reason = 'linked'` rather than merging. Section 11 forbids auto-merge, and
D-006 forbids touching the new submission either way, so both the second
submission and the first lead survive untouched.

What stops it shipping here is that it is the part that has to touch `leads` —
expression indexes on normalized email and phone, on the app's busiest table —
and I could not see that table's current columns, types or indexes. Writing
unverified DDL against it would be the opposite of the care the rest of this
package is arguing for. It needs one look at the live schema, and then it is a
short migration.

**A form builder, a CMS, and upload handling** are genuinely new work and are
Checkpoints 2, 3 and 7. They also wait on OPEN-4 — the public marketing site is
in neither repository, and a CMS with no known target renders nothing.
