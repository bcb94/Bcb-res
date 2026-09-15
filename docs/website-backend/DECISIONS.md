# Decisions — BCB Website Backend

Architecture decision log required by spec §32 ("Required working files").

Each entry: what was decided, why, what it costs, and what would reverse it.
Append new entries; do not rewrite history. Mark superseded entries rather than
deleting them.

---

## D-001 — Specs live in the repository, not only in Google Drive

**Date:** 2026-09-15 · **Status:** Accepted

The four BCB build specs existed only as Google Docs. Every one of them instructs
Claude to read the spec at the start of each session, and the website spec §33
names it as a file: *"Read `BCB_Website_Backend_Master_Build_Spec.md` completely
before making any changes."* A coding session cannot reliably do that when the
document lives behind a Drive connector that may not be attached.

**Decided:** transcribe all four specs into `docs/specs/` as Markdown and treat
the repository copy as the source of truth for builds.

**Cost:** the Drive originals and the repo copies can now drift.

**Mitigation:** each file carries a source header with the Drive file ID. When a
Drive doc changes, re-transcribe rather than hand-patching, and note the change
here.

**Reversed by:** the team deciding Drive is authoritative and wiring up an
automated export instead.

---

## D-002 — Stack is confirmed: Next static export + Supabase

**Date:** 2026-09-15 · **Status:** Accepted · **Revised 2026-09-15** (OPEN-1 resolved)

> This entry originally read *"Stack proposal is provisional and confined to the
> edges"* and proposed TypeScript + Next + PostgreSQL + S3-compatible storage
> under the assumption that the existing BCB app could not be reached. It said
> it would be revised rather than appended to if OPEN-1 resolved to a different
> stack. OPEN-1 resolved; this is that revision.

The existing BCB app is `bcb94/bcb-command-center` (private). Reviewed at
`b4bb8a7`. The stack is not a choice to be made.

**Decided:** match it exactly — TypeScript 5.5 strict, Next 14.2.35 App Router
with `output: 'export'`, React 18.3, Tailwind 3.4 over CSS-variable tokens,
Supabase (Postgres 17 + RLS + Storage + Deno edge functions), deployed to
Netlify as a static export.

**What survived the revision:** the §21 provider contracts, the §11 intake
ordering, and the §20 data model — exactly as the original entry predicted they
would.

**What did not:** Postgres-via-ORM, S3-compatible storage, SMTP, cookie
sessions, and the entire `src/app/api/**` layer. Under `output: 'export'` there
is no Next server to host them. See D-008.

**Cost:** none paid. The proposal was never built against.

**Reversed by:** nothing short of the app being rewritten.

## D-003 — Notification and AI enrichment sit outside the intake transaction

**Date:** 2026-09-15 · **Status:** Accepted

Spec §12 requires lead creation to survive AI failure; §27.14 requires it to
survive email delivery failure; §27.8 requires the submission to be recorded
before downstream processing; §28 Scenarios C and E test exactly this.

**Decided:** the intake transaction contains only *persist raw submission →
normalize → duplicate check → create or link lead*. `NotificationProvider` and
`EnrichmentProvider` are invoked after commit, and their failures are recorded as
delivery/enrichment state, never propagated as intake errors.

**Cost:** a lead can exist with no alert delivered. That is a visible operational
state, so it needs surfacing.

**Mitigation:** spec §6 already asks the dashboard for a "Failed form deliveries /
system errors" card. That card is the backstop and is not optional.

**Reversed by:** nothing reasonable. This is a durability requirement, not taste.

---

## D-004 — Capability checks, not role checks, at every enforcement point

**Date:** 2026-09-15 · **Status:** Accepted

Spec §15 asks for capability permissions "instead of relying only on role names",
and §29 expects auth to be replaced by the BCB app's own team auth later.

**Decided:** all authorization is `authorize(user, capability)`. Roles exist only
as named bundles of capabilities, resolved inside `AuthProvider`. No call site
branches on a role name.

**Cost:** slightly more ceremony than `if (user.role === 'admin')`.

**Benefit:** the merge only has to map BCB roles onto the same capability set
once, inside one provider, instead of auditing every call site. Spec §27.18 (a
user without publish permission cannot publish) becomes one test rather than a
sweep.

**Reversed by:** nothing. Reversing this is the expensive direction.

---

## D-005 — The import boundary is enforced by lint, not by discipline

**Date:** 2026-09-15 · **Status:** Accepted

Spec §21 says integration should "replace providers, not rewrite UI components".
That only holds if nothing outside the composition root imports a concrete
provider. In practice this decays silently — one direct import at a time.

**Decided:** add a lint rule in Checkpoint 1 forbidding imports from
`src/providers/**` and `src/db/**` anywhere except `src/providers/registry.ts`.
`src/domain/**` and `src/app/**` may import only from `src/contracts/**`.

**Cost:** occasional friction when a shortcut would be quicker.

**Benefit:** Checkpoint 10's "provider/interface inventory" becomes a mechanical
listing instead of an archaeology exercise.

**Reversed by:** nothing. If the rule is too strict in a specific case, the fix is
to widen the contract, not to bypass the rule.

---

## D-006 — Raw submissions are append-only

**Date:** 2026-09-15 · **Status:** Accepted

Spec §10 ("Never destroy the original raw submission"), §20 ("Do not
cascade-delete submissions because a temporary lead is deleted"), §27.10
("Duplicate logic never deletes the new raw submission"), §31 ("Delete raw
submissions after lead creation" — forbidden).

**Decided:** `form_submissions.raw_values` is written once and never updated.
Normalization writes to a separate column. Lead linkage lives in
`lead_submission_links`, so deleting a temp lead cannot cascade into submissions.
There is no delete path for submissions in the admin UI — only archive.

**Cost:** storage growth, including from spam that passes the filter.

**Mitigation:** acceptable; these are small text rows. Revisit only with evidence.

**Reversed by:** nothing. This is the spec's most repeated constraint.

---

## D-007 — Adopt the Command Center's design tokens verbatim

**Date:** 2026-09-15 · **Status:** Accepted · **Revised 2026-09-15** (was Proposed)

> Originally proposed inventing a token set (`surface`, `surface-nested`,
> `border`, `accent`, …) and noted: *"if the existing BCB app already ships
> tokens, adopt its names verbatim instead. Cheap now, expensive later."* It
> does. This is that adoption.

`bcb-command-center` already has the complete system. `app/globals.css` defines
the tokens for both themes, `tailwind.config.js` maps every colour utility onto
them including the full Tailwind ramps, `darkMode` is
`['class', '[data-theme="dark"]']`, and `lib/theme.ts` persists the choice to
`profiles.theme` with a localStorage cache so first paint is already correct.

**Decided:** use these names, unchanged:

```
--app-bg  --surface  --surface-raised  --surface-sunken
--border-subtle  --border-strong  --border-accent
--text-primary  --text-secondary  --text-inverse
--c-navy  --c-navy-ink  --c-navy-strong  --c-steel  --c-offwhite  --c-chip-ink
```

Note `surface-sunken`, not the guessed `surface-nested`; borders and text are
three tokens each, not one; and `--c-navy-ink` is a separate token from
`--c-navy` because ink and fill invert differently.

**Two rules that come with them**, both already paid for in that repo:

1. Never write a hex. A literal colour does not invert.
2. `text-navy` → `--c-navy-ink`, `bg-navy` → `--c-navy`. A fixed `text-white` on
   a token fill becomes unreadable when the fill inverts; `chip-ink` is for that.

**Consequence for the roadmap:** `BCB_Dark_Mode_Spec.md` is substantially
implemented already. Re-read it as a description of existing behaviour before
scheduling any of it as new work.

**Cost:** none. This is the cheap direction the original entry named.

---

## D-008 — Under static export, enforcement lives in RLS and edge functions

**Date:** 2026-09-15 · **Status:** Accepted

`next.config.js` sets `output: 'export'`. There is no Next server: no SSR, no
route handlers, no middleware. Several spec requirements — §15 server-side
permission checks, §22's public/admin API split, §23's "do not trust client-side
role checks", acceptance tests 1, 17 and 18 — were read in Checkpoint 0 as route
guards. They cannot be.

**Decided:** the enforcement boundary is the Postgres RLS policy, with role
checks inside edge functions for unauthenticated paths. TypeScript capability
checks are UI affordances that decide what to render, never the boundary. Tests
1, 17 and 18 are written against policies and functions, not against routes.

**Cost:** authorization logic lives in SQL, which is harder to read, harder to
test, and where `AGENT_HANDOFF.md` §3 documents five production incidents in one
day caused by inline sub-SELECTs in policies re-entering other tables' RLS.

**Mitigation:** that handoff also documents the fix pattern — move each branch
into a `SECURITY DEFINER` helper holding the identical body — and lists the
helpers that already exist. Reuse them; do not write new inline sub-SELECTs, and
do not substitute a similar-looking helper for the one a policy actually needs.

**Benefit:** stronger than the original design. A policy holds whatever the
caller believes, which is what §23 is actually asking for.

**Reversed by:** the app dropping static export. No reason to expect that.

---

## D-009 — Extend the existing intake pipeline; do not build a second one

**Date:** 2026-09-15 · **Status:** Proposed — gated on OPEN-6

`supabase/functions/website-intake/index.ts` is live in production and already
covers much of §10, §11 and §13: two entry paths (JSON POST and an HMAC-verified
Netlify Forms webhook), honeypot, origin allowlist, IP rate limit, a narrow
fixed-column insert into `leads` under the service role, then round-robin
assignment, a 2-hour follow-up todo and a team email — each best-effort and
independently caught. That post-insert ordering is already what D-003 requires.

Building §10/§11 as written would produce a *second* path from the same website
to the same `leads` table, with different spam rules, different assignment and
different idempotency.

**Decided (proposed):** extend the pipeline that exists, in this order:

1. Add the `form_submissions` store and write to it **before** the `leads`
   insert, on both entry paths (test 8, D-006). Additive; nothing existing
   changes behaviour.
2. Add email/phone normalization and duplicate detection between the submission
   write and the lead write (tests 9, 10, 11; Scenario B). Link, never merge;
   never delete the new submission.
3. Give the IP rate-limit key and the Netlify idempotency key their own columns.
   `internal_notes` currently carries three meanings — a human note,
   `intake_ip:<ip>`, and `netlify_form:<id>` — so a staff member editing that
   field on a website lead silently breaks both mechanisms for that row.
4. Only then a form builder, writing through the same path.

**Cost:** touches production code with no CI and no staging, and step 1 needs
DDL — which makes PostgREST reload its catalog and 500s every endpoint for
10–26s (`AGENT_HANDOFF.md` §1). Schedule it outside working hours.

**Benefit:** each step is independently shippable and testable, none needs the
marketing-site question (OPEN-4) answered, and step 1 alone closes the spec's
most-repeated constraint — that a raw submission is never lost.

**Blocked by:** OPEN-6. If the module is built standalone, this decision is moot
and the duplicate pipeline is unavoidable.

