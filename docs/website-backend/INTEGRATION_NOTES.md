# Integration Notes — BCB Website Backend

Required working file per spec §32.8: *"Keep an integration-notes file updated
when a temporary implementation will later need replacement."*

This is the running inventory that Checkpoint 10 (§26) turns into the merge
package. Every temporary thing gets a row **when it is written**, not at the end.

---

## How to use this file

When you add anything that will not survive the merge into the BCB app, add a row
in the right table below and mark it in code:

```ts
// TEMPORARY(website-backend): replaced by BCBLeadProvider at Checkpoint 10.
// See docs/website-backend/INTEGRATION_NOTES.md#providers
```

`grep -rn "TEMPORARY(website-backend)" src/` must match this file exactly. If it
doesn't, this file is wrong.

---

## Providers

The merge boundary from spec §21. Standalone implementations are disposable; the
contracts are not.

> **Updated 2026-09-15.** Every "future BCB impl" below was a placeholder until
> `bcb94/bcb-command-center` was located. All seven now name a real target,
> reviewed at `b4bb8a7`. If the module is built inside that app (CHECKPOINT_0
> OPEN-6, option B), this table stops describing a merge and starts describing
> what to call instead of writing.

| Contract | Standalone impl | Real BCB implementation | Status | Notes |
|---|---|---|---|---|
| `AuthProvider` | `StandaloneAuthProvider` | Supabase Auth + `profiles.role` + `components/AuthGate.tsx` | target identified | No password path — GoTrue owns credentials. `authenticate()` should be dropped; see CHECKPOINT_0 §4 amendment. |
| `LeadProvider` | `TemporaryLeadAdapter` | `leads` table + `app/(app)/leads/` + `assign_lead_round_robin()` | **already live** | `temp_leads` may never need to exist. The lead half of this spec is in production — see D-009. |
| `TeamProvider` | `StandaloneTeamProvider` | `profiles` + `lib/roles.ts` (`INTERNAL_ROLES`, mirrors `private.is_internal()`) | target identified | Do not re-type the role arrays; `lib/roles.ts` documents why (a duplicated list is how a send-invoice endpoint admitted `price_book_manager`). |
| `FileProvider` | `LocalFileProvider` | Supabase Storage + `app/(app)/documents/` + storage RLS helpers | target identified | `private.can_read_portal_document_object` is the existing private-by-default pattern (§23). |
| `NotificationProvider` | `SmtpNotificationProvider` | notifications tables → `private.enqueue_message_push()` → `pg_net` → `send-push`; email via `send-*` edge functions | **exists** | No SMTP anywhere in this app. Push fails silently and safely when a Vault entry is missing — by design, not a bug. |
| `AuditProvider` | `DbAuditProvider` | `lib/auditLog.ts` | target identified | §19 revision history + §23 audit requirements. |
| `EnrichmentProvider` | `NoopEnrichmentProvider` | `ai-assistant`, `builder-ai`, `blue-*` edge functions | target identified | Must stay optional and non-blocking (§12, D-003). |

## What already exists in production

Recorded so that no checkpoint rebuilds it. Reviewed at `b4bb8a7`.

| Spec area | Status in the Command Center |
|---|---|
| §10 public form intake | **Live** — `supabase/functions/website-intake/` (JSON POST + HMAC-verified Netlify Forms webhook) |
| §10 spam / rate limiting | **Live** — honeypot on both paths, origin allowlist, 5 leads / 10 min per IP (hard-coded) |
| §11 lead creation | **Live** — narrow fixed-column insert into `leads`, service role, `lead_no` minted |
| §11 assignment | **Live** — `assign_lead_round_robin()` picks the intake person idle longest |
| §13 team alert | **Live** — team email naming the owner, plus a 2-hour follow-up todo |
| §12/§27.14 failure isolation | **Live** — every post-insert step independently caught; a failure never 500s the customer |
| §25 design tokens, light/dark | **Live** — see D-007 |
| §15 auth, roles | **Live** — Supabase Auth, 13 roles, RLS |
| §10 raw submission store | **Missing** — the highest-value gap (D-009 step 1, test 8) |
| §11 duplicate detection | **Missing** — only Netlify-submission-id idempotency (tests 9/10/11, Scenario B) |
| §7/§19 CMS, page versions, publish state | **Missing** — genuinely new work |
| §10 form builder | **Missing** — genuinely new work |
| §16 uploads on intake | **Missing** |

## Temporary tables

Retired at merge per spec §29/§30. Everything else in §20 is website-specific and
stays as Website-module tables in the unified backend.

| Table | Fate at merge | Risk |
|---|---|---|
| `temp_leads` | Migrate into BCB Leads, then drop | **Highest-risk step in the merge.** Reconcile against existing BCB leads first (§30). Do not bulk-insert. **May be avoidable entirely** — `leads` already exists and already receives website leads (D-009). |
| `lead_submission_links` | Repoint to BCB lead IDs, keep | Must survive — it is how a submission traces to a lead. |
| `team_users` | Drop; map to BCB users | Preserve a user-ID mapping table through the migration or audit history loses its authors. |
| `roles` / `permissions` / `role_permissions` | Drop; map to BCB roles | Capability set must map 1:1 or §27.18 regresses. |
| `notifications` / `notification_deliveries` | Keep or migrate | Depends on whether a BCB notification center exists. |
| `audit_events` | Keep | Never rewrite history (§19). |

## Retained tables (no merge action)

`site_settings`, `pages`, `page_versions`, `page_sections`, `services`,
`navigation_menus`, `navigation_items`, `media_assets`, `forms`, `form_versions`,
`form_fields`, `form_submissions`, `submission_files`, `seo_metadata`,
`redirects`.

Per §29: *"Website-specific entities … can remain as dedicated Website-module
tables inside the unified BCB backend."*

## Deferred / not built

Recorded so they are not mistaken for oversights.

| Item | Spec ref | Why deferred |
|---|---|---|
| SMS / push notifications | §14 | Spec: "Do not build SMS/push in the first phase unless specifically requested." Interface is channel-ready. |
| Raw-code content block | §7 | Spec: reserved as an admin-only future feature. |
| Deep analytics | §6 | Spec: "Do not overbuild analytics in Phase 1." |
| Additional intake forms | §10 | Only Get a Quote in Phase 1; the form builder must not hard-code it. |
| `bcb.blue/builders` intake | §30 (Builders spec) | Ownership undecided — CHECKPOINT_0 OPEN-3. Decide before Checkpoint 4. |

## Cross-module overlap

Three BCB specs independently require auth, capabilities, file storage,
notifications, and design tokens. Building them three times is the main avoidable
cost in this roadmap (CHECKPOINT_0 OPEN-2).

**Largely averted, as of 2026-09-15.** The Command Center already owns all five.
The duplication risk now only materialises if a module is built *outside* it.

| Shared concern | Website Backend | Builders Module | Accounting Module |
|---|---|---|---|
| Auth + roles | §15 | §32 | §6 (admin-only) |
| Capability model | §15 | §32 | §6 |
| File/document storage | §16, §23 | §21 (plan uploads) | §28 (receipts, statements) |
| Notifications | §13, §14 | §31 | — |
| AI provider abstraction | §12 | §13–§16 | §18 |
| Design tokens | §25 | §3 | §41 |

Whichever module ships first should own these and expose them as contracts.

## Environment variables

Canonical list in [`CHECKPOINT_0.md` §5](./CHECKPOINT_0.md#5-define-environment-variables).
Mirror every change there into `.env.example` with a blank value. No secrets in
source control (§23).

## Merge checklist

Spec §30 is the authoritative list. Reproduced here so Checkpoint 10 has one page
to work from:

- [ ] Freeze schema changes in standalone branch
- [ ] Inventory production/test website content
- [ ] Map auth to existing BCB users
- [ ] Replace `AuthProvider`
- [ ] Replace `TeamProvider`
- [ ] Replace `LeadProvider`
- [ ] Replace `FileProvider` (if BCB Documents should own lead uploads)
- [ ] Replace/merge `NotificationProvider`
- [ ] Migrate website-specific CMS records into unified DB
- [ ] Reconcile temporary leads against existing app leads **before** import
- [ ] Do not bulk-create duplicates
- [ ] Validate deep links from lead-alert emails
- [ ] Re-run permission tests
- [ ] Re-run public/private API tests
- [ ] Verify public form submission end-to-end
- [ ] Verify rollback plan before cutover
