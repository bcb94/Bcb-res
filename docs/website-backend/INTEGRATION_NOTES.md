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

| Contract | Standalone impl | Future BCB impl | Status | Notes |
|---|---|---|---|---|
| `AuthProvider` | `StandaloneAuthProvider` | existing BCB Team/Auth | not started | §29 mapping: `team_users`/auth → existing Team/Auth. Map BCB roles → capability set (D-004). |
| `LeadProvider` | `TemporaryLeadAdapter` | existing BCB Leads module | not started | §29: `temp_leads` → Leads. Reconcile before import; §30 forbids bulk duplicate creation. |
| `TeamProvider` | `StandaloneTeamProvider` | existing BCB Team | not started | Notification recipients resolve through here, never hard-coded (§13). |
| `FileProvider` | `LocalFileProvider` | existing BCB Documents | not started | §30: replace only if BCB document storage should own lead uploads. Private-by-default must survive (§23). |
| `NotificationProvider` | `SmtpNotificationProvider` | BCB notification center | not started | §29: "Existing/future BCB notification center" — may not exist yet; keep standalone impl if so. |
| `AuditProvider` | `DbAuditProvider` | BCB audit log | not started | §19 revision history + §23 audit requirements. |
| `EnrichmentProvider` | `NoopEnrichmentProvider` | BCB AI services | not started | Must stay optional and non-blocking (§12, D-003). |

## Temporary tables

Retired at merge per spec §29/§30. Everything else in §20 is website-specific and
stays as Website-module tables in the unified backend.

| Table | Fate at merge | Risk |
|---|---|---|
| `temp_leads` | Migrate into BCB Leads, then drop | **Highest-risk step in the merge.** Reconcile against existing BCB leads first (§30). Do not bulk-insert. |
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
