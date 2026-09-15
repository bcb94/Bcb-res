# Checkpoint 0 — Architecture & Repository Review

**Spec:** [`docs/specs/BCB_Website_Backend_Master_Build_Spec.md`](../specs/BCB_Website_Backend_Master_Build_Spec.md) §26
**Status:** Complete · **revised 2026-09-15** after the existing BCB app was located
**Date:** 2026-09-15 (original) · 2026-09-15 (revision)

Per spec §26, Checkpoint 0 has six deliverables and one exit criterion. Each is
addressed below.

> **Revision note.** Sections 0, 1, 2, 5 and 6 and the open questions were
> rewritten once `bcb94/bcb-command-center` was located and reviewed. The
> original text proposed a stack because none could be confirmed; that proposal
> is withdrawn, not appended to (DECISIONS.md D-002). Sections 3 and 4 survive
> with the amendments noted inside them.

> **Exit criteria:** Architecture is documented and supports adapter-based future
> integration.

---

## 0. Repository review (finding)

Two repositories were reviewed.

**`bcb94/Bcb-res`** (this repo) at commit `faa612b` contains `README.md` and
`docs/`. No application code.

**`bcb94/bcb-command-center`** at commit `b4bb8a7` **is the existing BCB app.**
It is private, ~22 MB, and substantial: 31 module route groups under `app/(app)/`,
72 edge-function directories, 90 migration files, and a documented engineering
handoff (`AGENT_HANDOFF.md`).

This answers the question Checkpoint 0 could not: the spec's "existing BCB app"
is real, in version control, and reachable. [OPEN-1](#open-1-resolved-location-of-the-existing-bcb-app)
is resolved, and the three Checkpoint 0 deliverables that depended on it —
confirm the stack, identify reusable components, confirm nothing is modified —
can now be answered properly rather than deferred.

It also changes the shape of the work. The app already owns Leads, Team,
Clients, Projects and Documents, already ships a light/dark token system, and
**already runs a live website intake pipeline** (§2.4 below). The Website
Backend is therefore not a greenfield build that later merges into an app; it
is a CMS and form system being added alongside an app that already does the
lead half of this spec. See [OPEN-5](#open-5-two-intake-pipelines-for-one-website).

> **Caution on `AGENT_HANDOFF.md`.** It is the best orientation document in
> either repo and worth reading in full before touching the app — but its
> counts are stale. It reports 32 migration files and 11 sourced edge functions;
> the repo now has 90 and 72. Treat its *mechanisms* as current and its
> *numbers* as of 4 September 2026.

---

## 1. Confirm current tech stack

**Confirmed** from `bcb-command-center` at `b4bb8a7`. This replaces the
provisional proposal that Checkpoint 0 originally recorded here (DECISIONS.md
D-002, revised).

| Concern | Actual | Evidence |
|---|---|---|
| Language | TypeScript 5.5, strict | `tsconfig.json`, `package.json` |
| Framework | **Next 14.2.35, App Router, `output: 'export'`** | `next.config.js` |
| UI | React 18.3, Tailwind 3.4, `lucide-react` | `package.json` |
| Database | Supabase — Postgres 17, RLS-enforced | `@supabase/supabase-js` 2.45; DB `lvsobajewvpsjdrokrny` per `AGENT_HANDOFF.md` |
| Server code | Supabase **edge functions** (Deno), 72 in repo | `supabase/functions/` |
| Migrations | `supabase/migrations/` + `apply_migration` MCP | 90 files; history authoritative in `supabase_migrations.schema_migrations` |
| File storage | Supabase Storage, RLS on `storage.objects` | `private.can_see_conversation_object`, `can_read_portal_document_object` |
| Email / push | Edge functions (`send-*`), web push via VAPID + `pg_net` | `supabase/functions/send-push`, `send-invoice-email` |
| Auth | Supabase Auth (GoTrue) + `profiles.role` + RLS | `lib/supabase/client.ts`, `components/AuthGate.tsx` |
| Hosting | Netlify, **static export, manual deploy, no CI** | `netlify.toml`, `AGENT_HANDOFF.md` §2 |

### The one finding that changes the architecture

**`output: 'export'` means there is no Next server.** No SSR, no route handlers,
no middleware, no `src/app/api/**`. The bundle is static files on Netlify.

Everything the original Checkpoint 0 assigned to "the server" therefore has to
live somewhere else, and in this app it already does:

| Spec asks for | Original CP0 assumed | Where it actually goes |
|---|---|---|
| Server-side capability checks (§15, §23, test 1, test 18) | Next middleware / route guards | **RLS policies** in Postgres, plus role checks inside edge functions |
| Public API contract (§22) | `src/app/api/public/*` | Edge functions (`public-*`, `website-intake`) |
| Admin API contract (§22) | `src/app/api/admin/*` | PostgREST under RLS, plus RPCs |
| Server-rendered public pages (§24) | Next SSR | Not available here — see [OPEN-4](#open-4-where-does-bcbblue-the-marketing-site-live) |

This is not a downgrade. The app's enforcement boundary is *stronger* than route
guards: a policy in Postgres is checked whatever the caller believes, which is
exactly what §23 ("do not trust client-side role checks") is asking for. But it
does mean **test 1 and test 18 must be written against RLS and edge functions,
not against route middleware**, and it means the §26 Checkpoint 1 phrase
"route guards" has to be read as "`AuthGate` + policy", not as server routing.

Spec §24's server-rendered/static public site is the one genuine gap. The app
is static-exported to `app.bcb.blue`; the marketing site at `bcb.blue` is a
separate property that posts to Netlify Forms. Where it lives is
[OPEN-4](#open-4-where-does-bcbblue-the-marketing-site-live).

## 2. Identify reusable components

Substantial, and mostly non-obvious. The original answer ("none available") is
withdrawn.

### 2.1 Design tokens — adopt verbatim, do not invent

`app/globals.css` defines the complete token set and `tailwind.config.js` maps
every colour utility onto it, including the full Tailwind ramps. `darkMode` is
`['class', '[data-theme="dark"]']`; `lib/theme.ts` persists the choice to
`profiles.theme` with a localStorage cache.

Real token names — use these, not the ones Checkpoint 0 guessed:

```
--app-bg  --surface  --surface-raised  --surface-sunken
--border-subtle  --border-strong  --border-accent
--text-primary  --text-secondary  --text-inverse
--c-navy  --c-navy-ink  --c-navy-strong  --c-steel  --c-offwhite  --c-chip-ink
```

Two traps documented in the config, both already paid for once:

- **Never write a hex.** A literal colour does not invert.
- `text-navy` resolves to `--c-navy-ink`, `bg-navy` to `--c-navy`. Ink and fill
  are separate tokens; a fixed `text-white` on a token fill becomes unreadable
  when the fill inverts. `chip-ink` exists for that case.

D-007 is resolved on this basis, and `BCB_Dark_Mode_Spec.md` is substantially
**already built** — it should be re-read as a description of existing behaviour
before any of it is scheduled as new work.

### 2.2 Role and capability model — already exists

`lib/supabase/client.ts` defines 13 roles; `lib/roles.ts` defines the two sets
that matter and states where each is mirrored in the database:

- `INTERNAL_ROLES` (8) mirrors `private.is_internal()`
- `FINANCIAL_APPROVER_ROLES` (3) mirrors `private.can_approve_financials()`
- field: `crew_leader`, `laborer` · external: `subcontractor`, `vendor`, `client`

This is role-based, not capability-based, so D-004 still stands as a *design*
decision — but the mapping is no longer hypothetical, and the comment on
`FINANCIAL_APPROVER_ROLES` is the strongest argument in either repo for D-004:
a duplicated role list in one edge function is exactly how a "send invoice"
endpoint came to admit `price_book_manager`.

### 2.3 Reusable infrastructure

| Need (spec §) | Already in the app |
|---|---|
| Auth + session (§15) | Supabase Auth, `components/AuthGate.tsx` |
| Notifications, in-app + push (§13, §14) | notifications tables, `enqueue_message_push`, `send-push` |
| Email (§13) | `send-estimate-email`, `send-invoice-email` patterns |
| File storage, private by default (§16, §23) | Supabase Storage + `documents` module + storage RLS helpers |
| Audit (§19, §23) | `lib/auditLog.ts` |
| Toasts / confirmation (§25) | `lib/toast.ts` |
| Leads (§11) | `app/(app)/leads/`, `leads` table, `assign_lead_round_robin()` |

### 2.4 A website intake pipeline is already in production

`supabase/functions/website-intake/index.ts` (420 lines) is live and covers a
meaningful share of spec §10, §11 and §13:

- two entry paths — a JSON POST from the marketing site, and a **Netlify Forms
  webhook** verified by HMAC (`NETLIFY_FORM_WEBHOOK_SECRET`, JWS/HS256, body
  hash checked, timing-safe compare)
- spam controls: honeypot on both paths, origin/referer allowlist, IP rate limit
  of 5 leads / 10 minutes
- inserts a **narrow fixed column set** into `leads` — never passthrough of the
  request body — using the service role for exactly that one insert
- after insert, all best-effort and independently caught: round-robin assignment
  to an intake person, a 2-hour follow-up todo, a team email naming the owner
- idempotent on the Netlify submission id, so a webhook retry is not a second
  lead

The post-insert ordering is **already** what D-003 requires: the lead is saved
first, and assignment, task creation and email each fail independently without
becoming a 500 to the customer.

### 2.5 What that pipeline does *not* do — the real Checkpoint 4/5 gap

Measured against the spec, three things are missing, and they are the durability
requirements the spec repeats most:

1. **No raw submission is preserved.** The function maps the payload onto ~10
   `leads` columns and discards the rest. There is no `form_submissions` row.
   This is what spec §10 ("never destroy the original raw submission"), D-006,
   and acceptance tests **8** and **10** are about. A field the form collects but
   `leads` has no column for is currently lost.
2. **No duplicate detection.** The only idempotency is on the Netlify submission
   id. Two submissions from the same email or phone create two unrelated leads.
   Tests **9** and **11**, and Scenario B, fail against production today.
3. **`internal_notes` carries three meanings** — a human note field, the rate
   limit key (`intake_ip:<ip>`), and the Netlify idempotency key
   (`netlify_form:<id>`). Any staff member editing that field on a website lead
   silently breaks both mechanisms for that row. Recorded as a finding, not a
   live defect: nothing observed says it has happened.

There is also no CMS, no form builder, and no upload path on intake. Those are
genuinely new work; the intake pipeline is not.

---

## 3. Define folders / modules

Layered so that the framework sits at the edges and the contracts sit at the core.
The paths below were drawn against the stack Checkpoint 0 originally proposed and
are kept for the layering they express, which is the actual deliverable. See the
amendment after the tree for what the confirmed stack changes.

```text
/
├── docs/
│   ├── specs/                      # source-of-truth build specs (committed)
│   └── website-backend/
│       ├── CHECKPOINT_0.md         # this file
│       ├── DECISIONS.md            # ADR log            (spec §32)
│       ├── INTEGRATION_NOTES.md    # adapter inventory  (spec §32)
│       └── TEST_CHECKLIST.md       # acceptance tests   (spec §32)
│
├── src/
│   ├── contracts/                  # ← THE MERGE BOUNDARY. No framework imports.
│   │   ├── auth.ts                 #   AuthProvider
│   │   ├── lead.ts                 #   LeadProvider
│   │   ├── team.ts                 #   TeamProvider
│   │   ├── file.ts                 #   FileProvider
│   │   ├── notification.ts         #   NotificationProvider
│   │   ├── audit.ts                #   AuditProvider
│   │   ├── enrichment.ts           #   EnrichmentProvider (AI, §12)
│   │   └── types.ts                #   shared domain types
│   │
│   ├── providers/
│   │   ├── standalone/             # ← TEMPORARY. Every file here is deleted at merge.
│   │   │   ├── StandaloneAuthProvider.ts
│   │   │   ├── TemporaryLeadAdapter.ts
│   │   │   ├── StandaloneTeamProvider.ts
│   │   │   ├── LocalFileProvider.ts
│   │   │   ├── SmtpNotificationProvider.ts
│   │   │   ├── DbAuditProvider.ts
│   │   │   └── NoopEnrichmentProvider.ts
│   │   ├── bcb/                    # ← FUTURE. Empty until Checkpoint 10.
│   │   └── registry.ts             # single composition root; the only place
│   │                               #   that decides which impl is live
│   │
│   ├── domain/                     # ← PERMANENT. Business rules. No framework, no DB.
│   │   ├── content/                #   page/section/publish-state rules (§7, §19)
│   │   ├── forms/                  #   field validation, submission shaping (§10)
│   │   ├── leads/                  #   normalization + duplicate detection (§11)
│   │   ├── notifications/          #   recipient resolution (§13, §14)
│   │   └── seo/                    #   slug, canonical, redirect rules (§17)
│   │
│   ├── db/                         # ← TEMPORARY-ISH. Schema + repositories.
│   │   ├── schema/
│   │   └── repositories/
│   │
│   └── app/                        # ← FRAMEWORK EDGE.
│       ├── (public)/               #   SSG/SSR marketing site (§24)
│       ├── (admin)/                #   authenticated admin portal (§5)
│       └── api/
│           ├── public/             #   §22 public contract
│           └── admin/              #   §22 admin contract
│
└── seed/
    └── live-site-baseline.ts       # §3 content as seed data
```

### Amendment after the stack was confirmed

Two parts of the tree above cannot exist as drawn:

- **`src/app/api/**` is impossible.** `output: 'export'` means there is no Next
  server (§1). The §22 public and admin API contracts are edge functions and
  PostgREST-under-RLS respectively.
- **`src/db/`** is not a repository layer here. Schema lives in
  `supabase/migrations/`, and access goes through PostgREST and RPCs, policed by
  RLS rather than by application code.

If the module is built inside the Command Center (OPEN-6 option B), this tree is
replaced wholesale by that app's existing layout — `app/(app)/<module>/`,
`components/`, `lib/`, `supabase/functions/`, `supabase/migrations/`.

The layering rule below is the part worth keeping either way.

### The rule that makes the merge cheap

> `src/domain/**` and `src/app/**` may import from `src/contracts/**`.
> They may **never** import from `src/providers/**` or `src/db/**`.

Providers are injected via `registry.ts`. This is the mechanical expression of
spec §4 ("The Website module should not care which adapter is behind the
interface") and §21 ("Integration later should replace providers, not rewrite UI
components"). It should be enforced by lint rule, not by discipline — see
DECISIONS.md D-005.

## 4. Define service interfaces / adapters

> **Amendment after the stack was confirmed.** Five of the seven contracts below
> survive as written. Two do not:
>
> - **`AuthProvider.authenticate(email, password)`** does not fit this app.
>   Supabase Auth (GoTrue) owns credentials; the app never sees a password. The
>   method should be dropped in favour of reading the current session, and
>   `authorize()` should be understood as *mirroring* an RLS policy, never as
>   replacing it — a capability check in TypeScript is a UI affordance, and the
>   policy is the boundary (§23).
> - **`RoleName`** is a guess and is wrong. The real set is the 13 roles in
>   `lib/supabase/client.ts`: `owner, admin, pm, estimator, superintendent,
>   office, accountant, price_book_manager` (internal) · `crew_leader, laborer`
>   (field) · `subcontractor, vendor, client` (external). Use those names
>   verbatim. The `Capability` union stays as a design goal (D-004), resolved
>   from those roles inside one place.
>
> `LeadProvider`, `TeamProvider`, `FileProvider`, `NotificationProvider`,
> `AuditProvider` and `EnrichmentProvider` are unchanged, and all six now have a
> named implementation target in `INTEGRATION_NOTES.md` instead of a placeholder.


These are the contracts named in spec §21, expressed concretely. They are the
most important output of Checkpoint 0: everything in Checkpoints 1–9 is written
against them, and Checkpoint 10 consists of reimplementing them.

```ts
// contracts/types.ts
export type Id = string;

export type Capability =
  | 'website.view'            | 'website.edit_content'
  | 'website.publish'         | 'website.manage_navigation'
  | 'website.manage_forms'    | 'website.view_submissions'
  | 'website.manage_seo'      | 'website.manage_settings'
  | 'leads.view'              | 'leads.assign'
  | 'notifications.manage'    | 'team.manage_access';

export type RoleName =
  | 'owner_admin' | 'management' | 'sales_estimator'
  | 'project_manager' | 'accounting' | 'employee';

export interface User {
  id: Id;
  name: string;
  email: string;
  roles: RoleName[];
  active: boolean;
}

/** Never thrown away. Spec §10, §31. */
export interface RawSubmission {
  id: Id;
  formId: Id;
  formVersion: number;
  rawValues: Record<string, unknown>;
  normalizedValues: Record<string, unknown>;
  sourcePage: string | null;
  referrer: string | null;
  utm: Record<string, string> | null;
  fileRefs: Id[];
  createdAt: Date;
}
```

```ts
// contracts/auth.ts — spec §15, §21
export interface AuthProvider {
  authenticate(email: string, password: string): Promise<User | null>;
  getCurrentUser(request: unknown): Promise<User | null>;
  /** Server-side only. Spec §23 forbids trusting client-side role checks. */
  authorize(user: User, capability: Capability): Promise<boolean>;
  listRoles(user: User): Promise<RoleName[]>;
}
```

```ts
// contracts/lead.ts — spec §11, §21
export interface LeadIdentity { email?: string; phone?: string; }

export type DuplicateConfidence = 'exact_email' | 'exact_phone' | 'email_and_phone' | 'fuzzy';

export interface DuplicateMatch {
  leadId: Id;
  confidence: DuplicateConfidence;
  /** Fuzzy matches are review suggestions only. Spec §11 forbids auto-merge. */
  requiresReview: boolean;
}

export interface Lead {
  id: Id;
  firstName: string; lastName: string;
  email: string | null; phone: string | null;
  serviceInterest: string | null;
  projectAddress: string | null;
  projectDescription: string | null;
  leadSourceDetail: string | null;
  originatingFormId: Id | null;
  stage: string;
  assignedUserId: Id | null;
  createdAt: Date;
}

export interface LeadProvider {
  findDuplicate(identity: LeadIdentity): Promise<DuplicateMatch[]>;
  createLead(input: Omit<Lead, 'id' | 'createdAt'>): Promise<Lead>;
  updateLead(id: Id, patch: Partial<Lead>): Promise<Lead>;
  /** Links, never merges. The submission always survives. Spec §10, §27.10. */
  attachSubmission(leadId: Id, submissionId: Id): Promise<void>;
  assignLead(leadId: Id, userId: Id): Promise<void>;
  /** Must deep-link to the exact lead. Spec §13, §27.13. */
  getLeadUrl(leadId: Id): string;
}
```

```ts
// contracts/team.ts — spec §13, §21
export interface TeamProvider {
  listActiveUsers(): Promise<User[]>;
  listUsersByRole(role: RoleName): Promise<User[]>;
  /** Resolves a NotificationRule to concrete users. Never "all team members". */
  getNotificationRecipients(ruleId: Id): Promise<User[]>;
}
```

```ts
// contracts/file.ts — spec §16, §23
export type FileVisibility = 'private' | 'public_web';

export interface StoredFile {
  id: Id;
  filename: string;
  contentType: string;
  byteSize: number;
  visibility: FileVisibility;
}

export interface FileProvider {
  /** Form uploads MUST default to 'private'. Spec §23, §27.16. */
  upload(input: {
    filename: string; contentType: string;
    body: Uint8Array; visibility: FileVisibility;
  }): Promise<StoredFile>;
  /** Short-lived signed URL for private files. */
  getSecureRef(id: Id, ttlSeconds: number): Promise<string>;
  archive(id: Id): Promise<void>;
  /** Responsive derivative for public media only. Spec §16. */
  createWebDerivative(id: Id, width: number): Promise<StoredFile>;
}
```

```ts
// contracts/notification.ts — spec §13, §14
export type DeliveryStatus = 'queued' | 'sent' | 'failed';

export interface DeliveryResult {
  status: DeliveryStatus;
  error?: string;
  attemptedAt: Date;
}

export interface NotificationProvider {
  createInApp(input: { userId: Id; subject: string; body: string; href: string }): Promise<void>;
  sendEmail(input: {
    to: string[]; cc?: string[]; bcc?: string[];
    subject: string; html: string;
    /** Customer's address as Reply-To only — never spoof From. Spec §13. */
    replyTo?: string;
  }): Promise<DeliveryResult>;
  recordDelivery(notificationId: Id, result: DeliveryResult): Promise<void>;
}
```

```ts
// contracts/audit.ts — spec §19, §23
export interface AuditProvider {
  recordContentChange(input: { userId: Id; entity: string; entityId: Id; before: unknown; after: unknown }): Promise<void>;
  recordPublish(input: { userId: Id; pageId: Id; versionId: Id }): Promise<void>;
  recordSensitiveAction(input: { userId: Id; action: string; detail: unknown }): Promise<void>;
}
```

```ts
// contracts/enrichment.ts — spec §12
export interface EnrichmentResult {
  summary?: string;
  probableProjectType?: string;
  location?: string;
  urgency?: string;
  serviceTags?: string[];
  suggestedPriority?: string;
  missingInformation?: string[];
}

/**
 * Spec §12: "The form submission must still create successfully if AI
 * processing fails or is unavailable." Callers MUST treat this as
 * fire-and-forget, outside the intake transaction. Never await it in the
 * request path that persists the submission.
 */
export interface EnrichmentProvider {
  enrichLead(leadId: Id, submission: RawSubmission): Promise<EnrichmentResult | null>;
}
```

### Why intake ordering is a contract concern, not an implementation detail

Spec §11 fixes the order of operations and §27.8/§27.14/§27.15 make it testable.
The provider split above enforces it: `LeadProvider` and `FileProvider` are called
inside the intake transaction; `NotificationProvider` and `EnrichmentProvider` are
called strictly *after* commit. A notification failure or an AI outage therefore
cannot roll back a submission, because they are not in the transaction.

```text
persist RawSubmission ─┐
normalize + dedupe     ├─ transaction (must succeed)
create/link Lead       ─┘
        │  commit
        v
notify (may fail) ─── enrich (may fail) ─── both recorded, neither fatal
```

## 5. Define environment variables

Revised against the real stack. The original table assumed a Next server with a
direct Postgres connection and its own session cookies; none of those exist
under `output: 'export'` + Supabase.

Three distinct places hold configuration, and confusing them is how this app has
already lost time (`AGENT_HANDOFF.md` §2, §5):

**A. Baked into the bundle at build time** — `NEXT_PUBLIC_*`, read from the
local `.env.local`. The build happens on a developer machine, so **Netlify's own
env vars never reach the bundle**. Changing one of these requires a rebuild and
redeploy, not an env update.

| Variable | Required | Purpose |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | yes | Supabase project URL. |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | yes | Anon key. Safe to publish **only because RLS is the boundary** (§23). |
| `NEXT_PUBLIC_VAPID_PUBLIC_KEY` | no | Web push. Build-time — see handoff §5. |
| `NEXT_PUBLIC_SITE_URL` | yes | Canonical public base URL (§18) — canonicals, sitemap, absolute OG URLs. |
| `NEXT_PUBLIC_ADMIN_BASE_URL` | yes | Builds the `View Lead` deep link (§13, test 13). |

**B. Edge-function secrets** — set in the Supabase dashboard only; there is no
API for them without a CLI token. Never in the repo, never in the bundle.

| Variable | Required | Purpose |
|---|---|---|
| `SUPABASE_SERVICE_ROLE_KEY` | yes | Bypasses RLS. Only ever for one narrow insert (see `website-intake`). |
| `NETLIFY_FORM_WEBHOOK_SECRET` | yes | Verifies the Netlify Forms webhook JWS. Already in use. |
| `MAIL_FROM_ADDRESS` | yes | Authenticated system sender — §13 forbids spoofing the customer. |
| `LEAD_ALERT_FALLBACK_TO` | yes | Safety net when a notification rule resolves to zero recipients. |
| `SPAM_PROVIDER_SECRET` | no | Turnstile/hCaptcha (§10, §23), if added alongside the existing honeypot. |
| `ENRICHMENT_API_KEY` | no | AI enrichment (§12). Absent ⇒ no-op provider. Server-side only. |
| `ENRICHMENT_ENABLED` | no | Kill switch for §28 Scenario E. Default `false`. |

**C. Supabase Vault** — read by database triggers, not by application code.
`project_url`, `anon_key`, `push_dispatch_secret` already exist and gate the push
chain; a missing entry makes push fail silently and safely rather than breaking
messaging.

Withdrawn from the original table: `DATABASE_URL`, `SESSION_SECRET`,
`STORAGE_*`, `SMTP_URL`. Supabase owns the connection, the session and the
bucket; there is no SMTP transport in this app, only edge functions.

Rate limiting is currently **hard-coded** in `website-intake` (5 per 10 minutes)
rather than configured. Promoting it to `RATE_LIMIT_WINDOW_SECONDS` /
`RATE_LIMIT_MAX_SUBMISSIONS` is a reasonable Checkpoint 4 change, not a
prerequisite.

`.env.example` should be committed with every key in group **A** present and
every value blank. Groups B and C do not belong in a `.env` file at all.

## 6. Confirm no existing BCB app code will be modified

**Confirmed, and now meaningfully.** The production app is
`bcb94/bcb-command-center`, cloned read-only at `/home/user/bcb-command-center`
for this review. Nothing in it has been created, modified or deleted; no
migration was applied, no edge function deployed, no query run against the
production database. All work in this checkpoint is documentation inside
`bcb94/Bcb-res`.

Two standing hazards make this worth restating rather than assuming, both from
`AGENT_HANDOFF.md`:

- **Any DDL briefly breaks the app.** A schema change makes PostgREST reload its
  catalog and serve nothing meanwhile — measured at 10.7s and 26s. Requests queue
  past the 8s `statement_timeout` and every endpoint 500s at once. Diagnostic DDL
  against production, including `CREATE TEMP TABLE`, is not safe during working
  hours.
- **There is no CI and no staging.** Nothing gates a deploy. Verification is
  manual, and a Supabase branch is the only safe place to test schema work.

Any future checkpoint that touches the app must say so explicitly and restate
this section, rather than inheriting the confirmation.

---

## Open questions

### OPEN-1 (RESOLVED): Location of the existing BCB app

`bcb94/bcb-command-center`, private, reviewed at `b4bb8a7`. Outcome 1 of the
three the original Checkpoint 0 anticipated: it exists in another repo, and the
stack is confirmed in §1 above. D-002 is revised accordingly; §1 and §2 of this
document are rewritten rather than appended to.

### OPEN-2 (REVISED): Which build is actually next

The original recommendation — that whichever module ships first should own auth,
capabilities, files, notifications and tokens, and expose them as contracts —
is **already satisfied by the Command Center**. It owns all five. The cross-module
duplication risk recorded in `INTEGRATION_NOTES.md` is therefore mostly averted,
provided the Builders and Accounting modules are built *inside* the app rather
than standalone.

The remaining question is narrower and is [OPEN-6](#open-6-where-does-this-module-get-built).

### OPEN-3 (UNCHANGED): `bcb.blue/builders` ownership

Still undecided, and still worth deciding before Checkpoint 4 builds the form
system. The recommendation stands: one intake pipeline owns the form, the
submission record and the durability guarantees; Builders registers as a
*destination*. What has changed is that the pipeline now has a name —
`website-intake` — and a live implementation to extend rather than a design to
invent.

### OPEN-4: Where does `bcb.blue`, the marketing site, live?

**Blocking for Checkpoints 2, 7 and 8.**

The Command Center is `app.bcb.blue`. The public marketing site is a separate
property: `website-intake` allowlists `https://bcb.blue` and
`https://www.bcb.blue` as origins, and accepts a Netlify Forms webhook, which
means the public site is Netlify-hosted and its quote form is a Netlify form
today. Its source is in neither repository this session can see.

This is the new blocker, and it is the same shape as OPEN-1 was. The CMS in
spec §7/§19 has no meaning until it is known what it publishes *to*:

1. **Another repo we can reach** → best case; the CMS renders it and §24's
   static/server-rendered requirement is satisfiable.
2. **A hosted builder (Squarespace, Wix, Framer)** → the CMS cannot own its
   rendering. Either the site is rebuilt, or the "backend" reduces to forms and
   intake and Checkpoints 2/3/7/8 are largely void as written.
3. **Netlify Drop / hand-maintained HTML** → rebuild it; treat §3's content
   inventory as the seed data.

Ask before Checkpoint 2. Checkpoints 4–6 can proceed without the answer.

### OPEN-5: Two intake pipelines for one website

**Blocking for Checkpoint 4.**

Spec §10/§11 describe building a form system, a submission store and lead
intake. Production already has intake (§2.4). Building the spec as written
produces a *second* path from the same website to the same `leads` table —
different spam rules, different assignment, different idempotency.

That is the single largest avoidable risk in this build, and the cheap answer is
not to build a parallel pipeline but to **extend the one that exists**:

1. Add the missing `form_submissions` store and write to it **first**, before the
   `leads` insert, in both entry paths. That is test 8 and D-006, and it is
   additive — no existing behaviour changes.
2. Add email/phone normalization and duplicate detection between the submission
   write and the lead write (tests 9, 10, 11; Scenario B). Link, never merge;
   never delete the new submission.
3. Give the rate limit and the Netlify idempotency key their own columns so
   `internal_notes` goes back to meaning what staff think it means (§2.5).
4. Only then consider a form builder, and make it write through the same path.

Each step is independently shippable and independently testable, and none of
them requires the marketing site question (OPEN-4) to be answered first.

### OPEN-6: Where does this module get built?

**Blocking for any Checkpoint 1 code.**

The spec's framing — build standalone, merge later, abstract the app behind
provider contracts (§21, §29, §30) — was written when the app's reachability was
unknown. It is reachable, and it already owns Leads, Team, Documents,
notifications and tokens. Two options:

| | **A. Standalone in `Bcb-res`** | **B. Inside `bcb-command-center`** |
|---|---|---|
| Follows the spec as written | yes | no — §29/§30 merge plan becomes moot |
| Provider contracts (§21) | load-bearing | mostly ceremony |
| Duplicate auth / roles / tokens | yes, temporarily | none |
| Second lead pipeline (OPEN-5) | hard to avoid | avoided by construction |
| Risk to production | none | real — no CI, no staging, DDL causes brief outages |
| Checkpoint 10 | a large migration, incl. `temp_leads` — the merge's highest-risk step | does not exist |

**Recommendation: B, with A's discipline.** Build inside the app, but keep
D-004 (capabilities, not role-name branching) and D-005 (a single composition
root) because they are cheap and they are what makes Builders and Accounting
avoid re-litigating the same foundation. That trades the spec's letter for its
intent, and it deletes the migration the spec itself calls the highest-risk step
in the plan.

The cost of B is honest and should be stated: production has no CI, no staging,
and a deploy path with four documented ways to ship an outage. Working inside it
demands the handoff's discipline — isolated builds, full build output, verify the
site after deploying, check `git log -1` twice.

**This is the user's call, not the spec's.** It changes what Checkpoint 1 is, so
it is asked before any code is written.

---

## What Checkpoint 1 should do first

OPEN-1 is answered. OPEN-6 now gates the code.

1. **Decide OPEN-6** — standalone, or inside the app. Everything below branches
   on it.
2. Re-read `BCB_Dark_Mode_Spec.md` against §2.1. Much of it is built; scheduling
   it as new work would be duplicated effort.
3. If **B**: no scaffold, no `.env.example`, no provider registry. Checkpoint 1
   reduces to confirming what already holds — `AuthGate` plus RLS already satisfy
   the exit criterion — and writing tests **1** and **18** against RLS and the
   edge functions, which is where enforcement actually lives. Then go straight at
   OPEN-5 step 1, which is the highest-value change in the whole spec.
4. If **A**: scaffold §3, add the D-005 lint rule, commit the §4 contracts with
   `AuthProvider` reshaped for Supabase sessions and `RoleName` set to the 13
   real roles, commit `.env.example` from §5 group A, then build the shell.
5. Either way, do not start Checkpoint 2 until OPEN-4 is answered — a CMS with no
   known target renders nothing.

The Checkpoint 1 exit criterion is unchanged: *unauthorized users cannot access
admin pages*, verified server-side. Under this stack "server-side" means a
Postgres policy or an edge-function check — never `AuthGate` alone, which is a
client-side convenience.
