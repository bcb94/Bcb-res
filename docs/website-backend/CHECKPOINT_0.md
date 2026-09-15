# Checkpoint 0 — Architecture & Repository Review

**Spec:** [`docs/specs/BCB_Website_Backend_Master_Build_Spec.md`](../specs/BCB_Website_Backend_Master_Build_Spec.md) §26
**Status:** Complete — awaiting review before Checkpoint 1
**Date:** 2026-09-15

Per spec §26, Checkpoint 0 has six deliverables and one exit criterion. Each is
addressed below.

> **Exit criteria:** Architecture is documented and supports adapter-based future
> integration.

---

## 0. Repository review (finding)

`bcb94/Bcb-res` was inspected at commit `3d3a57a`. It contains:

```
README.md    ("# Bcb-res\nNot sure")
```

That is the entire repository. There is **no existing BCB application code here** —
no framework, no package manifest, no styling system, no components, no database
schema, no auth model.

This matters because several spec instructions assume an existing codebase:

- §32.3 "Inspect the existing repository before creating new systems."
- §32.5 "Reuse existing patterns where they do not violate this spec."
- §26 Checkpoint 0 "Confirm current tech stack" / "Identify reusable components"
- §26 Checkpoint 0 "Confirm no existing BCB app code will be modified"

**Conclusion:** the "existing BCB app" referenced throughout the spec lives
somewhere other than this repository. The standalone-first instruction is
therefore trivially satisfied here — there is nothing in this repo to modify —
but the stack-matching instruction *cannot* be satisfied from this repo alone.

See [OPEN-1](#open-1-location-of-the-existing-bcb-app) below. This is the single
blocking question for Checkpoint 1.

---

## 1. Confirm current tech stack

**Cannot be confirmed from this repository.** Recorded as [OPEN-1](#open-1-location-of-the-existing-bcb-app).

A stack is *proposed* below under the explicit assumption that it will be
replaced by whatever the existing BCB app uses, if that app is reachable before
Checkpoint 1 starts. The architecture is deliberately arranged so that the
proposal is cheap to reverse: all framework-specific code is confined to the
`app/` and `db/` layers, and none of the provider contracts, domain types, or
business rules depend on it.

### Proposed stack (provisional — see DECISIONS.md D-002)

| Concern | Proposal | Why |
|---|---|---|
| Language | TypeScript (strict) | Spec §20/§21 are contract-heavy; the provider-swap model in §29 is far safer with compile-time interfaces. |
| Framework | Next.js (App Router) | Spec §24 requires server-rendered/static public pages *and* §5 requires an app-like authenticated admin, in one project. Next is the mainstream way to get both without two deployments. |
| Database | PostgreSQL | Spec §20 needs relational integrity (`page_versions`, `lead_submission_links`, `role_permissions`) and §10 needs a JSON column for raw submission payloads. Postgres does both. |
| ORM / migrations | Prisma or Drizzle | Spec §30 requires a migration plan; both give checked-in, reviewable migrations. |
| File storage | S3-compatible, private-by-default bucket | Spec §23 requires private uploads with signed access. Local disk is not viable for §27.16. |
| Email | Provider-agnostic behind `NotificationProvider` | Spec §13 forbids hard-coding recipients and §27.14 requires delivery failure to be non-fatal. |
| Auth | Session cookie + capability check, behind `AuthProvider` | Spec §15 mandates the interface boundary; the implementation is explicitly temporary. |

**Nothing here is load-bearing for the architecture.** If the existing BCB app is
Laravel, Rails, or Django, the module boundaries and provider contracts in §3–§4
below survive unchanged; only the `app/` and `db/` layers are rewritten.

## 2. Identify reusable components

**None available in this repository.** There are zero components, styles, or
utilities to reuse at commit `3d3a57a`.

Two reusable assets exist *outside* code and should be treated as inputs:

1. **Live site content and structure** — spec §3 fixes the baseline (4 nav items,
   4 services, 6 trust statements, 7 quote-form fields, contact details). This is
   the seed data for Checkpoints 2–4 and must not be re-invented.
2. **BCB design language** — spec §25 plus the dark-mode token work described in
   [`docs/specs/BCB_Dark_Mode_Spec.md`](../specs/BCB_Dark_Mode_Spec.md). That
   document specifies a *token-based* theme system ("Do not manually style Dark
   Mode separately on every page"). The website backend admin should consume the
   same token names so the two systems converge rather than diverge.

**Recommendation:** define the design tokens once, in this module, using the names
the dark-mode spec implies (surface / surface-raised / surface-nested / border /
text-primary / text-secondary / accent). If the existing BCB app already has
tokens, adopt its names verbatim instead — that is a five-minute change now and a
large one later.

## 3. Define folders / modules

Layered so that the framework sits at the edges and the contracts sit at the core.
Paths are illustrative for the proposed stack; the *layering* is the deliverable.

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

### The rule that makes the merge cheap

> `src/domain/**` and `src/app/**` may import from `src/contracts/**`.
> They may **never** import from `src/providers/**` or `src/db/**`.

Providers are injected via `registry.ts`. This is the mechanical expression of
spec §4 ("The Website module should not care which adapter is behind the
interface") and §21 ("Integration later should replace providers, not rewrite UI
components"). It should be enforced by lint rule, not by discipline — see
DECISIONS.md D-005.

## 4. Define service interfaces / adapters

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

No secrets in source control (spec §23). All secrets injected at runtime.

| Variable | Required | Purpose |
|---|---|---|
| `DATABASE_URL` | yes | Postgres connection string. |
| `SESSION_SECRET` | yes | Signs admin session cookies. Rotate on suspicion. |
| `PUBLIC_SITE_URL` | yes | Canonical public base URL (§18) — used for canonicals, sitemap, absolute OG URLs. |
| `ADMIN_BASE_URL` | yes | Used to build the `View Lead` deep link (§13, §27.13). |
| `STORAGE_ENDPOINT` | yes | S3-compatible endpoint. |
| `STORAGE_BUCKET_PRIVATE` | yes | Form uploads. Never public-read (§23). |
| `STORAGE_BUCKET_PUBLIC` | yes | Website media only. |
| `STORAGE_ACCESS_KEY_ID` | yes | Storage credential. |
| `STORAGE_SECRET_ACCESS_KEY` | yes | Storage credential. |
| `SMTP_URL` | yes | Outbound mail transport. |
| `MAIL_FROM_ADDRESS` | yes | Authenticated system sender (§13 — never the customer's address). |
| `LEAD_ALERT_FALLBACK_TO` | yes | Safety net if a notification rule resolves to zero recipients. |
| `SPAM_PROVIDER_SECRET` | no | Turnstile/hCaptcha secret (§10, §23). |
| `RATE_LIMIT_WINDOW_SECONDS` | no | Public form throttle window (§23). Default 60. |
| `RATE_LIMIT_MAX_SUBMISSIONS` | no | Public form throttle count (§23). Default 5. |
| `ENRICHMENT_API_KEY` | no | AI enrichment (§12). Absent ⇒ `NoopEnrichmentProvider`. Server-side only. |
| `ENRICHMENT_ENABLED` | no | Kill switch for §28 Scenario E. Default `false`. |

`.env.example` should be committed with every key present and every value blank.

## 6. Confirm no existing BCB app code will be modified

**Confirmed, trivially.** This repository contains no BCB application code. No
file outside `docs/` has been created or modified by Checkpoint 0.

This confirmation is weaker than the spec intends, because it is satisfied by the
repo being empty rather than by a boundary being respected. Once [OPEN-1](#open-1-location-of-the-existing-bcb-app)
is answered, restate it properly: name the production app's repo/path and confirm
it is untouched.

---

## Open questions

### OPEN-1: Location of the existing BCB app

**Blocking for Checkpoint 1.**

The spec repeatedly refers to "the existing BCB app" — its framework, styling
system, component patterns, auth model, database conventions, Leads/Team/Clients/
Projects/Documents modules, and an "existing dark-mode system". None of it is in
this repository.

Three possibilities, each changing Checkpoint 1 materially:

1. **It exists in another repo.** → Best case. Add that repo to the session
   read-only, match its stack and tokens, and revise §1–§2 above before writing
   any Checkpoint 1 code. This is the outcome the spec assumes.
2. **It exists but is not in version control here** (e.g. built in a hosted
   builder). → Match its visual language from screenshots; the stack proposal in
   §1 stands on its own.
3. **It does not meaningfully exist yet.** → The stack proposal in §1 becomes the
   BCB stack, and the "standalone-first / merge-later" framing collapses into
   "build it right the first time". The adapter boundary is still worth keeping
   (it is cheap and it is how the spec wants Leads/Team/Documents to be owned),
   but Checkpoint 10 becomes a much smaller exercise.

### OPEN-2: Which build is actually next

Four BCB specs are now committed under `docs/specs/`, all written as Claude
handoffs, all "standalone first, merge later":

| Spec | Scope | Entry point |
|---|---|---|
| Website Backend | CMS + lead intake for bcb.blue | Checkpoint 0 ← **done here** |
| Builders Module | Builder-partnerships CRM | Phase 1 Foundation |
| Accounting Module | Bookkeeping / job costing / QuickBooks | Milestone 1 Foundation |
| Dark Mode | Global theme tokens for BCB Command Center | n/a — extends existing app |

They overlap: all three large ones need auth, roles/capabilities, a document/file
store, notifications, and a design-token system. Building those three times is
the main avoidable cost across this roadmap.

**Recommendation:** whichever module goes first should own the shared foundation
(auth, capabilities, files, notifications, tokens) and expose it through
contracts, exactly as `src/contracts/` does above. The Website Backend is a
reasonable first mover because its §21 interface list is already the superset.

### OPEN-3: `bcb.blue/builders` ownership

Builders spec §30 describes a public `bcb.blue/builders` intake page that creates
a Builder + Opportunity. Website Backend spec §10 owns public forms and §11 owns
intake. These are the same mechanism pointed at different destinations.

**Recommendation:** the Website Backend owns the form, the submission record, and
the durability guarantees; the Builders module registers as a *destination* for
lead-generating forms. That keeps one intake pipeline and one spam/rate-limit
story. Decide before Checkpoint 4 builds the form system.

---

## What Checkpoint 1 should do first

In order, once OPEN-1 is answered:

1. Revise §1–§2 of this document against the real BCB stack.
2. Scaffold the folder layout in §3 and add the import-boundary lint rule (D-005).
3. Commit `src/contracts/**` verbatim from §4 — these compile with zero runtime deps.
4. Commit `.env.example` from §5.
5. Then, and only then, build the Checkpoint 1 shell: login, admin layout,
   sidebar, route guards, server-side capability checks, responsive layout.

Do not start Checkpoint 2 until the Checkpoint 1 exit criterion is demonstrated:
*unauthorized users cannot access admin pages*, verified server-side.
