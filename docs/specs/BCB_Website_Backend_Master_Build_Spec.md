# BCB Website Backend — Master Build Specification

**Project:** Blue Collar Built unified website administration system
**Primary build phase:** Standalone website backend / admin portal
**Future phase:** Merge into the existing BCB business app
**Public website:** https://bcb.blue/
**Prepared:** September 1, 2026
**Status:** Source-of-truth implementation roadmap for Claude

> Source: Google Doc "Bcb config" (`1-3saRtUXmpUtxBa06jMpeFEJAhT7YxNWCWYZYyJ5-IU`).
> Transcribed verbatim into the repository so coding sessions can read it as a file,
> per §32 Claude Execution Protocol and §33 Recommended Starter Prompt.

---

## 1. Purpose of This Document

This document is the implementation roadmap for rebuilding the Blue Collar Built website infrastructure so the BCB app ultimately becomes the one backend for the public website and the internal business system.

The immediate goal is not to merge anything into the existing BCB app yet. Claude should first build the website backend/admin portal as an independent, testable system. It must be designed so it can later be connected to the existing BCB app without rewriting the CMS, public website, forms, or notification logic.

### Non-negotiable direction

- Do not use Squarespace.
- Do not build a second permanent business operating system.
- Do not modify the existing BCB app during the standalone build phase.
- Build the website admin/backend separately first.
- Use modular services/adapters so temporary standalone data sources can later be replaced by the existing BCB app's Leads, Team, Clients, Projects, Documents, Sales, and other modules.
- The final architecture must allow the BCB app to become the single system of record.
- The public website must remain fast, secure, responsive, and SEO-friendly.

## 2. Product Vision

Blue Collar Built should ultimately operate with two user-facing interfaces over one backend:

```text
PUBLIC CUSTOMER EXPERIENCE                 INTERNAL TEAM EXPERIENCE
bcb.blue                                   BCB App
     |                                         |
     |                                         |
     +------------- BCB BACKEND ---------------+
                    |
                    +-- Website CMS
                    +-- Leads / CRM
                    +-- Clients & Projects
                    +-- Sales / Estimates / Invoices
                    +-- Schedule
                    +-- Documents
                    +-- Accounting
                    +-- Team / Permissions
                    +-- Notifications
```

During the current standalone phase, use this temporary architecture:

```text
bcb.blue / development public site
              |
              v
      Website Backend API
              |
       Service / Adapter Layer
              |
              v
    Temporary Development DB
              |
              v
 Standalone Website Admin Portal
```

Later, the temporary adapters are replaced with BCB app services:

```text
Website Backend API
       |
       v
BCB App Service Layer
       |
       v
Existing BCB Database
```

The objective is **swap the data source, not rebuild the product**.

## 3. Current Live Website — Required Baseline

Claude must use the actual current Blue Collar Built website as the baseline for public structure and content. Do not substitute a generic contractor website structure.

### Current primary navigation

- Services
- Barns
- Why Us
- Get a Quote

### Current brand positioning

- Location emphasis: Dickson, Tennessee / Middle Tennessee
- Primary tagline: Built on Grit. Powered by Trust.
- Current hero focus: framing, remodeling, additions, and custom builds

### Current service structure

**Framing Construction** — current focus includes:

- Site prep for slabs, grading and leveling
- Structural framing and repairs
- Custom carpentry and build-outs

**Remodeling & Renovations** — current focus includes:

- Bathroom remodels, tile and plumbing
- Kitchen upgrades, cabinets through countertops
- Complete home renovations

**Additions & New Builds** — current focus includes:

- Home additions
- Custom decks, porches and outdoor spaces
- Garage or workshop construction

**Specialty — Barns & Barndominiums** — current focus is custom barns and barndominiums that balance function and appearance.

### Current trust / why-us content

Current website messaging includes:

- Licensed & Insured
- Local Crew — No Outsourcing
- Honest Quotes, No Trip-Fee Surprises
- Quick Turnaround
- Clean Tear-Off & Fast Install
- One Call Handles It All

> **Content review note:** The CMS must make these statements easy to edit because public messaging may evolve as the company structure and subcontractor model evolves. Do not hard-code these claims into layout components.

### Current public contact/form structure

The current quote/contact form captures:

- First Name
- Last Name
- Email
- Phone
- What do you need help with? / Service Needed
- Project Address
- Project Description

Current public contact data displayed on the site:

- Email: j@bcb.blue
- Phone: (615) 326-5991
- Serving: Middle Tennessee

### Planned contact-email change

The new backend should support `info@bcb.blue` as the public company contact email.

`info@bcb.blue` may operate as a shared inbox, distribution group, or forwarding address for general inbound email. However, it must not serve as the primary website lead-processing system. Website form submissions must be processed by the BCB backend first.

## 4. Current Build Boundary — Read Before Coding

### Build now

Build a standalone:

1. Website administration portal
2. Website content-management system
3. Website backend API
4. Temporary development database
5. Form/submission system
6. Lead intake and temporary lead records
7. Notification-routing system
8. Media management
9. SEO management
10. Role/permission framework
11. Public website integration layer
12. App-integration adapters/interfaces

### Do not build now

Do not:

- Merge this project into the existing BCB app.
- Replace existing BCB app modules.
- Modify the production app database.
- Duplicate the entire CRM/ERP permanently.
- Build accounting, estimating, scheduling, or project management again inside the website backend.
- Make the temporary lead database the long-term source of truth.
- Hard-code future app IDs or schemas into the CMS UI.

### Required architecture principle

Whenever a piece of information will eventually belong to an existing BCB app module, access it through a service interface / adapter.

Example:

```text
LeadIntakeService
  createLead()
  findDuplicate()
  updateLead()
  attachSubmission()
  assignLead()
```

Standalone implementation:

```text
TemporaryLeadAdapter -> Development Database
```

Future implementation:

```text
BCBLeadAdapter -> Existing BCB Leads Module
```

The Website module should not care which adapter is behind the interface.

## 5. Recommended Product Structure

The standalone admin should feel familiar to anyone who has used Squarespace: clean, simple, low-friction, clear hierarchy, and good mobile behavior. It should not visually copy Squarespace. Use the Blue Collar Built application's design language.

### Primary standalone navigation

- Dashboard
- Website
- Leads / Submissions
- Notifications
- Team & Access
- Settings

Once merged into the BCB app, the Website area should become a primary app module alongside the existing business modules.

### Website module navigation

- Overview
- Pages
- Navigation
- Services
- Forms
- Media
- SEO
- Contact Info
- Site Settings

## 6. Website Overview Dashboard

The Website Overview should answer: *What happened on the website and does anything need attention?*

### Recommended cards

- New website leads — today / 7 days / 30 days
- Unread form submissions
- Published pages
- Draft changes
- Recently edited pages
- Form conversion snapshot
- Failed form deliveries / system errors
- Latest team activity

### Quick actions

- Edit Homepage
- Add Page
- Add Service
- View Form Submissions
- Upload Media
- Edit Contact Information
- Preview Website
- Publish Changes

Do not overbuild analytics in Phase 1. Favor operational usefulness.

## 7. Pages CMS

### Page hierarchy

The Pages interface should support parent/child organization and drag-and-drop or simple reorder controls.

Example baseline:

```text
Home
Services
  Framing Construction
  Remodeling & Renovations
  Additions & New Builds
Barns & Barndominiums
Why Us
Get a Quote / Contact
```

The current live site uses primarily anchored sections. The new system may preserve a one-page presentation initially while representing major sections as editable CMS records. The content model must also support independent pages later without a rebuild.

### Page capabilities

Authorized admins can:

- Create a page
- Duplicate a page
- Edit a page
- Rename a page
- Change slug
- Set parent
- Reorder
- Hide from navigation
- Save draft
- Preview draft
- Publish
- Unpublish
- Archive
- Restore archived page

### Structured page fields

At minimum:

- Internal page name
- Public page title
- URL slug
- Navigation label
- Hero eyebrow / location label
- Hero heading
- Hero description
- Hero image/video
- Primary CTA label
- Primary CTA destination
- Secondary CTA label
- Secondary CTA destination
- Content sections
- SEO title
- Meta description
- Social share image
- Index/no-index option
- Published state
- Published timestamp
- Last edited by

### Content sections

Use modular content blocks rather than raw HTML as the default editing experience.

Initial block types:

- Hero
- Rich text
- Image
- Image + text
- Services grid
- Service detail
- CTA band
- Why-us / trust grid
- Project gallery
- Testimonials
- FAQ
- Contact form
- Spacer / divider

Advanced raw code can be reserved for an admin-only future feature. Normal content management must not require code.

## 8. Services Management

Services should exist as structured records, not repeated hard-coded text.

### Initial service records

1. Framing Construction
2. Remodeling & Renovations
3. Additions & New Builds
4. Barns & Barndominiums

### Service fields

- Service name
- Internal label
- Short description
- Long description
- Hero image
- Card image
- Bullet points
- CTA label
- CTA destination/form preset
- Display order
- Active/inactive
- Featured flag
- SEO title
- Meta description
- URL slug

### Form integration

When a customer clicks a service-specific CTA such as *Start a Framing Project*, the quote form should be able to preselect that service.

## 9. Navigation Management

The admin must be able to manage public navigation without editing source code.

Capabilities:

- Add navigation item
- Remove navigation item
- Reorder
- Create dropdown/nested item
- Link to page
- Link to page section/anchor
- Link externally
- Hide item on desktop/mobile if required
- Configure CTA-style navigation button

Default navigation should mirror the current website until intentionally changed.

## 10. Forms Management

Forms are a core business feature, not just website widgets.

### Initial forms

- Get a Quote / General Lead Form

System must be able to add later:

- Custom Build Intake
- Barndominium Intake
- Remodeling Intake
- Subcontractor Application
- Warranty / Service Request
- Client Document Upload

### Form builder — Phase 1

Support common field types:

- Short text
- Long text
- Email
- Phone
- Address
- Select
- Multi-select
- Radio buttons
- Checkboxes
- Date
- File upload
- Hidden/source field

### Required settings

- Form name
- Public title
- Description
- Active/inactive
- Success message
- Redirect destination
- Lead-generating: yes/no
- Required fields
- Notification routing
- Spam protection
- File rules
- Source tracking

### Submission record

Every submission should preserve:

- Submission ID
- Form ID/version
- Raw submitted values
- Normalized values
- Created timestamp
- Source page
- Referrer / UTM values when available
- Lead source
- IP/risk metadata only as needed for security and spam prevention
- Uploaded file references
- Processing status
- Lead/customer linkage
- Notification status
- Error/retry information

**Never destroy the original raw submission when data is normalized or mapped to a lead.**

## 11. Website Lead Workflow

### Required workflow

```text
Customer submits website form
        |
        v
Validate + spam protection
        |
        v
Persist original submission
        |
        v
Normalize email / phone / address
        |
        v
Duplicate check
        |
        +--> Possible existing lead/customer -> link or flag for review
        |
        +--> No match -> create temporary standalone lead
        |
        v
Map form data into lead profile
        |
        v
AI enrichment / organization hook
        |
        v
Place in New Lead stage
        |
        v
Generate in-app/admin alert
        |
        v
Send email alert to configured recipients
        |
        v
Team member opens View Lead
```

### Current quote-form mapping

| Website Field | Lead Field |
|---|---|
| First Name | `first_name` |
| Last Name | `last_name` |
| Email | `email` |
| Phone | `phone` |
| Service Needed | `service_interest` / `project_type` |
| Project Address | `project_address` |
| Project Description | `lead_notes` / `project_description` |
| Source Page | `lead_source_detail` |
| Form ID | `originating_form_id` |
| Submitted At | `created_at` / `intake_timestamp` |

### Duplicate detection — Phase 1

Normalize values before matching. Check in this order:

1. Exact normalized email
2. Exact normalized phone
3. Email + phone combination
4. Optional fuzzy name/address match as a review suggestion, never as an automatic destructive merge

If a likely duplicate exists, preserve the submission and flag it for linking/review.

## 12. AI Lead-Profile Hook

Claude should prepare an AI-processing interface, but not make lead creation depend on AI availability.

### AI can later assist with

- Summarizing project description
- Identifying probable project type
- Extracting location
- Identifying urgency/timeline if supplied
- Tagging services/trades
- Suggesting lead priority
- Creating a concise lead overview
- Identifying missing information for follow-up

### Reliability rule

The form submission must still create successfully if AI processing fails or is unavailable. AI enrichment is asynchronous/optional enrichment, not the transaction boundary.

## 13. Email & Lead Alert Strategy

### Public inbox

Use `info@bcb.blue` as the intended public-facing general contact address.

Recommended use:

```text
Customer manually emails info@bcb.blue
                |
                v
Shared inbox / forwarding group
                |
                v
Configured management recipients
```

This is appropriate for general inbound correspondence.

### Website leads

Do not route website form submissions by simply emailing `info@bcb.blue` and relying on forwarding.

Required flow:

```text
Website form
    |
    v
BCB backend creates submission + lead
    |
    +--> In-app/admin alert
    |
    +--> Email lead alert to configured team recipients
```

The database/app state is authoritative. Email is a notification channel.

### Lead-alert email

Suggested structure — Subject: `New Website Lead - {Name} - {Service}`

Include:

- Lead name
- Phone
- Email
- Service requested
- Project location
- Short description
- Submitted time
- Source/form
- View Lead button

The View Lead link must deep-link to the exact lead profile in the admin portal.

### Reply behavior

Where useful, the alert can use the customer's email as Reply-To while still being sent by an authenticated BCB system sender. Do not spoof the customer's From address.

### Notification recipients

Do not permanently hard-code "all team members." Build configurable routing.

Initial routing can support:

- Everyone in Management
- Everyone in Sales/Estimating
- Specific users
- Role + specific overrides

Later routing can support rules by service, geography, lead source, or assigned estimator.

## 14. Notification Settings

Create a simple admin experience:

```text
Website -> Forms -> Get a Quote -> Notifications
```

Settings:

- Send in-app alert: on/off
- Send email alert: on/off
- Recipient roles
- Specific recipients
- Optional CC/BCC
- Alert subject template
- Quiet-hours behavior for future push/SMS

Prepare the notification service for future channels: Email, In-app, Push, SMS.

Do not build SMS/push in the first phase unless specifically requested.

## 15. Team, Authentication & Permissions

The standalone build needs its own temporary secure authentication so the admin can be tested independently.

However, authentication must be isolated behind an auth interface so it can later be replaced by the existing BCB app's team authentication.

### Initial roles

**Owner / Admin** — full website control; forms/submissions; team/access; notification rules; publish/unpublish; system settings.

**Management** — website content; forms/submissions; lead review; notification access as granted.

**Sales / Estimator** — leads/submissions; contact information; no site-wide design/settings unless granted.

**Project Manager** — limited website administration by default; relevant lead/client linkage later.

**Accounting** — no website editing by default.

**Employee** — no website administration by default.

### Permission model

Use capability permissions instead of relying only on role names. Examples:

- `website.view`
- `website.edit_content`
- `website.publish`
- `website.manage_navigation`
- `website.manage_forms`
- `website.view_submissions`
- `website.manage_seo`
- `website.manage_settings`
- `leads.view`
- `leads.assign`
- `notifications.manage`
- `team.manage_access`

This will make integration with the BCB app easier.

## 16. Media Library

Create a centralized media manager for website assets.

### Capabilities

- Upload image
- Upload multiple images
- Drag/drop
- Replace asset
- Search
- Filter by type/tag
- Edit title/alt text
- Copy asset URL/reference
- See where asset is used
- Archive/delete with safe-use checks

### Image handling

Where supported:

- Generate web-friendly derivatives
- Preserve original
- Compress without obvious quality loss
- Use responsive sizes
- Support modern formats where appropriate
- Require/encourage alt text

The public website should not load full-resolution originals when smaller optimized assets are appropriate.

## 17. SEO Management

SEO should be simple enough for a non-developer to use.

### Per page/service

- SEO title
- Meta description
- Canonical URL
- Slug
- Social title
- Social description
- Social image
- Index/no-index

### Global

- Business name
- Default social image
- Default title pattern
- Site description
- Organization/local-business structured data inputs
- Sitemap generation
- Robots rules

Preserve redirect capability when slugs change.

## 18. Contact Info & Site Settings

Create one global source for business contact details used across the website.

### Contact info

- Public email — planned `info@bcb.blue`
- Primary phone — (615) 326-5991
- Location label — Dickson, Tennessee
- Service area — Middle Tennessee
- Business hours if later used
- Social profiles

A contact-info change should update every public component that references the global field, unless a page intentionally overrides it.

### Global site settings

- Site name
- Logo variants
- Favicon
- Brand tagline
- Default CTA text
- Footer content
- Copyright
- Analytics IDs
- Form spam settings
- Maintenance mode
- Public-site base URL

## 19. Content Publishing Model

Avoid a workflow where every keystroke immediately changes production.

### Required states

- Draft
- Published
- Archived

### Recommended behavior

1. Admin edits draft.
2. Admin previews draft.
3. Authorized publisher presses Publish.
4. System stores published version and timestamp.
5. Public site receives/revalidates updated content.
6. Audit event records user and action.

### Revision history

At minimum, keep a lightweight change history for published website content so accidental edits can be understood and ideally restored.

## 20. Temporary Standalone Data Model

Exact naming can follow the existing technology stack, but preserve these logical entities.

### Core website entities

`site_settings`, `pages`, `page_versions`, `page_sections`, `services`, `navigation_menus`, `navigation_items`, `media_assets`, `forms`, `form_versions`, `form_fields`, `form_submissions`, `submission_files`, `seo_metadata`, `redirects`

### Temporary business/integration entities

`temp_leads`, `lead_submission_links`, `notification_rules`, `notifications`, `notification_deliveries`, `team_users`, `roles`, `permissions`, `role_permissions`, `audit_events`

### Important database rules

- Use stable unique IDs.
- Preserve created/updated timestamps.
- Prefer soft-delete/archive for business records.
- Do not cascade-delete submissions because a temporary lead is deleted.
- Preserve raw submission payloads.
- Store file metadata in DB; store actual files in object/file storage.
- Keep published content distinguishable from draft content.

## 21. Integration Interfaces — Required for Future Merge

Create clear interfaces/contracts for systems that will later be replaced by existing BCB app services.

### Required interfaces

**AuthProvider** — authenticate user; get current user; authorize capability; list relevant user roles.

**LeadProvider** — find by email/phone; create lead; update lead; attach submission; assign lead; get lead URL.

**TeamProvider** — list active users; list users by role; get notification recipients.

**FileProvider** — upload file; get secure file reference; delete/archive file; create public website derivative when appropriate.

**NotificationProvider** — create in-app notification; send email alert; record delivery result.

**AuditProvider** — record content changes; record publishing events; record permission-sensitive actions.

The standalone implementation may use local providers. Integration later should replace providers, not rewrite UI components.

## 22. API Contract — Public Website

Use secure public endpoints only for data that must be public.

Illustrative API organization:

```text
GET  /api/public/site
GET  /api/public/navigation
GET  /api/public/pages/:slug
GET  /api/public/services
GET  /api/public/forms/:publicId
POST /api/public/forms/:publicId/submissions
```

Authenticated admin API examples:

```text
GET    /api/admin/pages
POST   /api/admin/pages
PATCH  /api/admin/pages/:id
POST   /api/admin/pages/:id/publish
GET    /api/admin/forms
GET    /api/admin/forms/:id/submissions
GET    /api/admin/submissions/:id
GET    /api/admin/leads/:id
PATCH  /api/admin/notification-rules/:id
```

These are examples, not mandatory route names. Follow the existing project conventions where appropriate.

### Public API rule

Never expose: internal user lists; private lead data; internal notes; private submission lists; client/project records; estimate/invoice data; documents not explicitly public; permission configuration; API keys or internal secrets.

## 23. Security Requirements

Minimum requirements:

- Authentication for all admin routes
- Server-side authorization checks
- CSRF protection where relevant to framework/session model
- Rate limiting for public forms
- Bot/spam protection
- Input validation and sanitization
- Secure file-type/size validation
- Private storage for form uploads by default
- Signed/authorized access to private files
- Secret management via environment configuration
- No secrets committed to source control
- Secure cookies/session/token handling
- Audit log for publish/settings/access changes
- Generic public errors; detailed internal logs

Do not trust hidden fields or client-side role checks.

## 24. Public Website Performance & SEO Requirements

The website admin can be app-like, but the public website must be optimized for customers and search engines.

Target behavior:

- Mobile-first responsive layout
- Fast initial render
- Optimized images
- Semantic headings
- Accessible controls/forms
- Crawlable public content
- Server-rendered/static-generated public content where supported by chosen stack
- Sitemap
- Metadata
- Stable canonical URLs
- Redirects after slug changes
- Form usability on mobile

Do not make the public site depend on an authenticated app bundle.

## 25. Visual / UX Direction

### Brand qualities

The BCB system should feel: rugged, premium, blue-collar, professional, structural, trustworthy.

Avoid a generic SaaS template feel and avoid making the admin overly decorative.

### Admin visual behavior

- Clean sidebar navigation
- Strong hierarchy
- Navy/steel-blue accent treatment consistent with the BCB app
- White/light surfaces with subtle tinted cards
- Smooth tab, accordion, dropdown, and page transitions
- Clear hover/focus/active states
- Generous spacing
- Mobile/tablet usability
- Minimal modal abuse
- Confirmation for destructive actions
- Autosave only where safe; explicit Publish for live content

### Design reference principle

Take inspiration from the clarity and organization of Squarespace's backend, especially page hierarchy and straightforward settings. Do not clone Squarespace branding or UI one-for-one.

## 26. Build Checkpoints

Claude should work in checkpoints and verify each before proceeding.

### Checkpoint 0 — Architecture & repository review

Deliverables:

- Confirm current tech stack
- Identify reusable components
- Define folders/modules
- Define service interfaces/adapters
- Define environment variables
- Confirm no existing BCB app code will be modified

**Exit criteria:** Architecture is documented and supports adapter-based future integration.

### Checkpoint 1 — Standalone shell, auth & permissions

Build: secure login; admin shell; sidebar navigation; route guards; role/capability checks; responsive layout.

**Exit criteria:** Unauthorized users cannot access admin pages.

### Checkpoint 2 — Pages & content editor

Build: page list/hierarchy; create/edit/archive; structured sections; draft/publish states; preview.

**Exit criteria:** Admin can recreate/edit the current homepage structure without code.

### Checkpoint 3 — Services & navigation

Build: structured service records; service cards/details; navigation manager; CTA/form preselection support.

**Exit criteria:** Current four service categories are manageable from admin.

### Checkpoint 4 — Forms & submissions

Build: Get a Quote form definition; current public fields; submission storage; upload handling architecture; submission list/detail; spam protection.

**Exit criteria:** Test customer can submit a quote request and admin can view the preserved submission.

### Checkpoint 5 — Temporary lead creation & duplicate detection

Build: LeadProvider interface; temporary lead adapter; field mapping; duplicate checks; lead/submission linkage; New Lead state.

**Exit criteria:** A form submission reliably creates or links a temporary lead without losing original submission data.

### Checkpoint 6 — Notifications & routing

Build: NotificationProvider interface; in-admin notifications; email lead alerts; recipient rules by role/user; delivery logging; View Lead deep link.

**Exit criteria:** Configured recipients receive a test alert and link to the correct lead.

### Checkpoint 7 — Media, SEO, contact info & settings

Build: media library; global contact fields; `info@bcb.blue` readiness; SEO fields; site settings; redirect infrastructure.

**Exit criteria:** Common website content/settings can be changed without source edits.

### Checkpoint 8 — Public website connection

Build: public content API/data layer; render content from CMS; wire current site structure to backend; wire quote form to backend; preserve/upgrade responsive design.

**Exit criteria:** Public site displays CMS-managed content and form submissions enter the backend.

### Checkpoint 9 — QA, security & production readiness

Verify: mobile layouts; accessibility basics; auth/authz; public/private API boundaries; error states; form retry behavior; spam/rate limiting; draft vs publish behavior; SEO metadata; performance.

**Exit criteria:** No critical security, data-loss, or publish-state defects.

### Checkpoint 10 — BCB app integration package

Do not merge yet. Produce: provider/interface inventory; temporary tables that should be retired; mapping to existing BCB modules; migration scripts/plan; endpoint changes required; auth migration plan; file-storage mapping; notification mapping; data reconciliation checklist.

**Exit criteria:** A future Claude session can merge the Website module into the BCB app using a documented adapter-replacement plan.

## 27. Acceptance Tests

Before Phase 1 is considered complete, verify at minimum:

1. Admin login is required for all internal website-management routes.
2. Page hierarchy can represent the actual BCB site.
3. Admin can edit homepage hero copy and publish it.
4. Admin can edit all four current service records.
5. Admin can edit global phone/email/service-area data.
6. Draft edits do not appear publicly before Publish.
7. Public quote form contains current required fields.
8. A valid submission is permanently recorded before downstream processing.
9. Exact email/phone duplicates are detected.
10. Duplicate logic never deletes the new raw submission.
11. New submissions can create temporary leads.
12. Lead alert recipient rules can target roles and users.
13. Email alert contains a working View Lead link.
14. Failed email delivery does not erase or roll back the lead.
15. AI failure does not prevent lead creation.
16. Uploaded lead files are private by default.
17. Public APIs cannot list leads or submissions.
18. A user without publish permission cannot publish.
19. Slug changes can create redirects.
20. Website works on common mobile widths.
21. Current website content can be represented without hard-coded page markup.
22. Integration providers are documented and swappable.

## 28. Test Data / Scenarios

Use realistic scenarios during development.

**Scenario A — Framing lead**
Name: Test Customer A; Service: Framing Construction; Address: Dickson, TN; Description: New detached garage framing request.
Expected: new submission, new lead, framing tag/service, alerts sent.

**Scenario B — Duplicate email**
Submit same email with a new project description.
Expected: preserve second submission and flag/link probable existing lead instead of silently creating duplicate or overwriting data.

**Scenario C — Email delivery failure**
Force notification-provider failure.
Expected: submission and lead remain saved; delivery status records failure/retry opportunity.

**Scenario D — Unauthorized publish**
Sales/Estimator user attempts publish.
Expected: server rejects action unless capability explicitly granted.

**Scenario E — AI unavailable**
Disable AI enrichment.
Expected: lead is still created and team is alerted.

## 29. Future Merge Into the Existing BCB App

The eventual BCB app should own the backend. The standalone build is a proving ground, not a permanent island.

### Expected future mapping

| Standalone Component | Future BCB Owner |
|---|---|
| Website admin UI | BCB App -> Website module |
| `temp_leads` | Existing Leads module |
| `team_users`/auth | Existing Team/Auth |
| lead assignments | Existing Leads/Team workflow |
| submission attachments | Existing Documents/File system where appropriate |
| notifications | Existing/future BCB notification center |
| client conversion | Existing Clients & Projects |
| estimate conversion | Existing Sales |
| website content | Website module remains in unified backend |

### Integration rule

Website-specific entities such as pages, page versions, navigation, SEO, forms, and site settings can remain as dedicated Website-module tables inside the unified BCB backend.

Business entities such as Leads, Clients, Projects, Team Users, Estimates, Invoices, and Documents should use existing BCB entities rather than parallel permanent copies.

## 30. Migration / Merge Checklist

When authorized to merge:

- Freeze schema changes in standalone branch.
- Inventory production/test website content.
- Map auth to existing BCB users.
- Replace AuthProvider.
- Replace TeamProvider.
- Replace LeadProvider.
- Replace FileProvider if existing BCB document storage should own lead uploads.
- Replace/merge NotificationProvider.
- Migrate website-specific CMS records into unified DB.
- Reconcile temporary leads against existing app leads before import.
- Do not bulk-create duplicates.
- Validate deep links from lead-alert emails.
- Re-run permission tests.
- Re-run public/private API tests.
- Verify public form submission end-to-end.
- Verify rollback plan before cutover.

## 31. Do-Not-Do List

Claude must not:

- Use Squarespace as a dependency.
- Make email forwarding the CRM.
- Send website forms only through email.
- Hard-code all recipients.
- Hard-code all website copy into React/components/templates.
- Expose admin APIs publicly.
- Put private uploads in public media storage.
- Delete raw submissions after lead creation.
- Make AI a required synchronous dependency.
- Auto-merge fuzzy duplicates without review.
- Give all users admin/publish access.
- Build a permanent second Leads/Clients/Projects system.
- Rewrite existing BCB app modules before the integration phase.
- Couple the standalone UI directly to temporary database queries where a provider/service boundary is appropriate.
- Claim the build is complete without running the acceptance tests.

## 32. Claude Execution Protocol

At the beginning of every coding session:

1. Read this entire specification.
2. Identify the current checkpoint.
3. Inspect the existing repository before creating new systems.
4. State which files/modules will be touched.
5. Reuse existing patterns where they do not violate this spec.
6. Implement only the current checkpoint unless dependency work is required.
7. Test before moving on.
8. Keep an integration-notes file updated when a temporary implementation will later need replacement.

### Required working files

Claude should maintain:

- `docs/website-backend/INTEGRATION_NOTES.md`
- `docs/website-backend/DECISIONS.md`
- `docs/website-backend/TEST_CHECKLIST.md`

The exact path may follow repository conventions, but these functions should exist.

## 33. Recommended Starter Prompt for Claude

Copy this with the roadmap file attached or available in the repository:

> Read `BCB_Website_Backend_Master_Build_Spec.md` completely before making any changes. Treat it as the source of truth for this build. We are building the website backend/admin portal separately before merging it into the existing BCB app. Do not modify the existing BCB application during this phase. Start with Checkpoint 0: inspect the current repository/stack, propose the modular architecture and provider interfaces, identify what can be reused, and document the plan. Do not work ahead into later checkpoints until Checkpoint 0 is reviewed and stable.

For later sessions:

> Read `BCB_Website_Backend_Master_Build_Spec.md` and the current integration/decision notes. Continue only with Checkpoint [NUMBER]. Preserve the standalone-first, adapter-based architecture so this can later merge into the existing BCB app without rebuilding the Website module.

## 34. Definition of Success

The standalone phase is successful when:

- Blue Collar Built can manage the real public website from a secure backend without Squarespace.
- Website content can be edited without code for normal changes.
- The current site structure/services are accurately represented.
- Website quote forms create durable submissions and temporary lead records.
- Team lead alerts are generated by the backend with configurable routing.
- `info@bcb.blue` can function as the public/shared company inbox without becoming the lead database.
- The public site and internal admin are securely separated.
- The CMS and lead-intake workflow are production-ready in isolation.
- The system has clean provider boundaries for authentication, leads, team users, files and notifications.
- Merging into the BCB app becomes an integration exercise rather than a rebuild.

## Source Notes

This roadmap is structured around the live Blue Collar Built website at https://bcb.blue/ as reviewed on September 1, 2026, including its current navigation, service categories, tagline, trust content, contact information and Get a Quote form fields. Future public-copy changes should be made through the CMS rather than hard-coded into the system.
