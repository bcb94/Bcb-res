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

## D-002 — Stack proposal is provisional and confined to the edges

**Date:** 2026-09-15 · **Status:** Accepted, pending OPEN-1

Spec §26 Checkpoint 0 requires "Confirm current tech stack", and §42-equivalent
guidance says to reuse the existing project's conventions. The existing BCB app is
not in this repository, so the stack cannot be confirmed — only proposed.

**Decided:** propose TypeScript + Next.js + PostgreSQL + S3-compatible storage
(CHECKPOINT_0 §1), and structure the code so the proposal is cheap to reverse.
Framework-specific code is confined to `src/app/` and `src/db/`. Contracts,
domain rules, and types have no framework imports.

**Cost:** if the existing app is Laravel/Rails/Django, `src/app/` and `src/db/`
are thrown away.

**Mitigation:** that is roughly the same work as porting any UI layer, and the
expensive parts — the §21 contracts, the §11 intake ordering, the §20 data model
— survive a stack change unchanged.

**Reversed by:** OPEN-1 resolving to a different stack. Revise, do not append.

---

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

## D-007 — Design tokens are shared with the dark-mode work

**Date:** 2026-09-15 · **Status:** Proposed

`docs/specs/BCB_Dark_Mode_Spec.md` requires a global token system for the BCB
Command Center and explicitly forbids per-page dark styling. The website backend
admin (spec §25) needs the same surface/border/text/accent hierarchy.

**Decided (proposed):** define tokens once with names matching the dark-mode
spec's hierarchy — `surface`, `surface-raised`, `surface-nested`, `border`,
`text-primary`, `text-secondary`, `accent` — so the two systems converge.

**Open:** if the existing BCB app already ships tokens, adopt its names verbatim
instead. Cheap now, expensive later. Blocked on OPEN-1.
