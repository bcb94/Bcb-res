# BCB Builders Module — Standalone Feature Build Specification

**Company:** Blue Collar Built
**Feature:** Builder Partnerships / Builders CRM
**Build Mode:** Standalone First — Merge Only After BCB Approval

> Source: Google Doc "Bcb builder" (`1-BuCGq7DLqEhI0m8GYmnYs2vPNpAWZsVMyK9k_bbZEc`).
> Transcribed into the repository so coding sessions can read it as a file.

**Purpose:** Build a complete standalone Builders / Builder Partnerships feature for Blue Collar Built before it is merged into the main BCB app.

**Primary objective:** Create a working builder-business-development operating system for identifying, qualifying, contacting, tracking, estimating, and converting Middle Tennessee builders into recurring Blue Collar Built Envelope Package clients.

**Important:** This is a standalone build. Do not merge it into the existing BCB app yet. Build it so it can be tested independently and later integrated cleanly into the app with minimal rework.

---

## 1. Product Vision

Blue Collar Built is developing a Builder Envelope Program for builders and general contractors in Middle Tennessee.

The core offer is:

> **One contractor. One scope. One point of accountability.**

The BCB envelope package may include:

- Structural framing
- Roof framing
- Roofing
- Siding / exterior cladding
- Furnished exterior windows
- Exterior doors
- Garage doors
- Other compatible exterior-envelope scopes when approved by BCB

BCB's internal estimating can remain highly detailed, but builder-facing proposals should consolidate related line items into logical package pricing so the client evaluates the complete value of the envelope package rather than picking apart every internal unit cost.

This Builders feature should function as the CRM and operating hub for this entire sales channel.

## 2. Standalone Build Requirements

Build this feature as its own isolated module/application first.

**Do not:**

- Modify the production BCB app
- Modify current Projects, Clients, Estimates, Accounting, Scheduling, Documents, or other production modules
- Create dependencies that require the main app to function
- Hard-code production database IDs
- Expose internal estimating or financial data to external users
- Automatically send AI-generated outreach without human approval

**Do:**

- Match the visual language of the BCB app
- Build reusable components
- Use a clean service/data layer so the feature can later connect to the primary app database
- Keep builder records separate from actual construction project records
- Include mock/demo data for testing
- Clearly mark any temporary standalone adapters so they are easy to replace during integration

## 3. Brand / Design System

The feature must feel like part of Blue Collar Built, not a generic SaaS CRM.

Brand direction: rugged; premium; professional; structural; clean; blue-collar without looking cheap; modern construction software aesthetic.

Use the existing BCB app's current light-mode visual direction and QuickBooks-inspired interaction style:

- Clean white / very light backgrounds
- Navy-tinted accordion and card surfaces
- BCB blue accents
- Smooth transitions
- Rounded but professional cards
- Clear information hierarchy
- Subtle borders and shadows
- Spacious layouts
- Strong typography
- High information density without clutter

Use the official Blue Collar Built logo supplied with the project where appropriate.

Brand phrase:

> **Built on Grit. Powered by Trust.**

Support the existing dark-mode system if the standalone environment already contains it; otherwise architect styles so dark mode can be added later without redesigning the feature.

## 4. Primary Navigation

1. Dashboard
2. Pipeline
3. Builders
4. Opportunities
5. Follow-Ups
6. AI Prospecting
7. Reports
8. Settings

Primary top-right action: **+ Add Builder**
Secondary quick action: **+ Add Opportunity**

## 5. Dashboard

Create a polished executive dashboard with live calculated metrics.

### Top KPI cards

Total Prospects; Contacted; Engaged; Qualified Builders; Plans Received; Active Estimates; Proposals Sent; Won; Lost; Total Pipeline Value; Won Contract Value; Estimated Gross Profit; Estimated Commission.

### Pipeline Funnel

Show: Prospect -> Contacted -> Engaged -> Qualified -> Plans Received -> Estimating -> Proposal Sent -> Won / Lost

The funnel should be clickable and filter the builder/opportunity lists.

### Today's Work

- Calls due today
- Emails due today
- Follow-ups due today
- Proposals awaiting response
- Plans awaiting estimate
- Builders with no activity in X days

### Recent Activity

Timeline of: builder added; call logged; email logged; note added; status changed; plans uploaded; estimate started; proposal sent; opportunity won/lost.

### Leaderboard / Rep Performance

Future-ready for multiple business development reps. Include: qualified leads generated; plans received; won opportunities; won gross profit; commission earned.

## 6. Pipeline

Create a Kanban-style builder sales pipeline.

Columns: Prospect; Contacted; Engaged; Qualified; Plans Received; Estimating; Proposal Sent; Won; Lost.

Requirements:

- Drag-and-drop cards
- Smooth transitions
- Save status immediately
- Filter by rep, territory, builder tier, last activity, lead score
- Search
- Sort by opportunity value / priority / newest / oldest

Each pipeline card should show, at minimum: builder company; primary contact; territory; estimated annual build volume; builder tier; lead score; current opportunity; expected project start; last activity; next follow-up; assigned rep.

Use subtle visual flags for overdue follow-ups and hot opportunities.

## 7. Builders Directory

This is the master account list.

Builder list/table fields: Company Name; Primary Contact; Phone; Email; Website; City; County; Service Area; Builder Type; Approximate Annual Builds; Builder Tier; Lead Score; Pipeline Status; Assigned Rep; Last Contact; Next Follow-Up; Open Opportunities; Active Projects; Lifetime Awarded Revenue; Lifetime Estimated Gross Profit.

Support: search; sorting; filters; saved views; bulk selection; CSV import; CSV export; duplicate detection.

Suggested saved views: Hot Prospects; Needs Follow-Up; Plans Received; Proposal Outstanding; Active Partners; Dormant Accounts; High-Volume Builders; New This Week.

## 8. Builder Profile

Clicking a builder opens a detailed builder account page.

**Header area:** builder company name; logo if available; builder tier; lead score; relationship status; assigned rep; main contact; phone; email; website; service area; approximate annual builds.

**Primary action buttons:** Log Call; Log Email; Add Note; Schedule Follow-Up; Add Opportunity; Upload Plans; Run AI Research.

### Tabs

**Overview** — company summary; builder type; typical project type; territory; annual volume estimate; current subcontractor/vendor notes; known pain points; BCB opportunity summary; relationship history.

**Contacts** — allow multiple contacts (Owner; Purchasing; Project manager; Superintendent; Estimator; Office manager; Other). Fields: name; role; phone; email; preferred contact method; notes.

**Opportunities** — display every potential project/package tied to the builder.

**Activity** — chronological timeline of all interactions.

**Documents** — plans; specifications; bid invitations; scope sheets; proposal PDFs; builder documents; relevant correspondence attachments.

**Notes** — internal only.

**Financial Summary** — internal only: total opportunity value; awarded revenue; estimated gross profit; collected gross profit; commission paid / pending.

## 9. Opportunities

A builder account can have unlimited opportunities.

Opportunity fields: Opportunity Name; Builder; Project Name; Project Address; City / County; Project Type; Approximate Square Footage; Estimated Start Date; Bid Due Date; Plans Received Date; Scope Requested; Envelope Package Type; Status; Estimated Contract Value; Estimated Cost; Estimated Gross Profit; Gross Margin; Probability of Close; Weighted Pipeline Value; Assigned Estimator; Assigned Sales Rep; Next Action; Next Follow-Up.

Scope selection should allow: Structural Framing; Roof Framing; Roofing; Siding / Exterior Cladding; Windows; Exterior Doors; Garage Doors; Complete Envelope Package; Custom Scope.

## 10. Qualified Lead Definition

The system must distinguish a random contact from a real qualified builder opportunity. A builder should not automatically be labeled "Qualified" just because contact information was found.

Create qualification fields for:

- Operates in target service area
- Actively builds residential projects
- Controls or influences subcontractor/vendor selection
- Has upcoming work
- Willing to consider BCB
- Has an identifiable decision maker
- Has shared plans OR agreed to allow BCB to price an upcoming project

Strongest qualification milestone:

> **Plans Received**

This should be treated as a major conversion event in reporting.

## 11. Builder Tier System

Create configurable builder tiers. Default:

- **Tier A** — approximately 10+ projects/homes annually or strategically significant recurring volume.
- **Tier B** — approximately 4-10 projects/homes annually.
- **Tier C** — lower annual volume but potentially high-value custom homes/projects or strategically valuable relationships.

Do not automatically reject lower-volume custom builders. Value and project type matter.

## 12. Lead Scoring

Create a 0-100 builder lead score. Suggested weighted criteria: service area fit; estimated annual build volume; custom / semi-custom project fit; upcoming project evidence; decision-maker identified; contact information completeness; fit for bundled envelope scopes; current relationship strength; recent engagement; plans available.

Allow Admin to edit scoring weights later.

Display: score; score category; explanation of why the score was assigned.

Suggested categories: 80-100 Priority / Hot; 60-79 Strong Fit; 40-59 Nurture; Under 40 Low Priority / Research Needed.

AI may recommend the score, but users must be able to override it.

## 13. AI Prospecting Center

This is one of the most important features. Build a dedicated AI Prospecting workspace to help the rep find and research target builders efficiently.

The AI should assist with: builder discovery; company research; contact research; qualification; lead scoring; territory research; personalized outreach preparation; follow-up drafting; objection preparation; builder summaries; opportunity recommendations.

### Important AI behavior

AI is an assistant, not an autonomous salesperson.

AI **may**: research; rank; summarize; draft; suggest; analyze.

AI **may not** automatically send outreach without explicit user approval.

## 14. AI Prospect Search Workflow

Create a guided search interface. Input options: City; County; Radius / Territory; Builder Type; Approximate Annual Volume; Custom / Semi-Custom / Production; Keywords; Minimum Lead Score.

Primary target geography should support Middle Tennessee, including but not limited to: Nashville; Franklin; Brentwood; Spring Hill; Thompson's Station; Columbia; Murfreesboro; Lebanon; Mt. Juliet; Gallatin; Hendersonville; Nolensville; Fairview; Dickson; Clarksville; surrounding Middle Tennessee markets.

### Target builder profile

Focus primarily on growing custom and semi-custom residential builders and small-to-mid-sized residential GCs that can benefit from consolidating several envelope scopes.

Do not prioritize giant national production builders during the initial phase unless specifically requested.

## 15. AI Research Sources / Strategy

Architect the AI prospecting layer so it can use approved public-web research tools/APIs when available.

Potential research categories: local home builder association directories; Home Builders Association of Middle Tennessee; builder websites; Google / map search results; Houzz; LinkedIn/company pages when permitted by the selected integration; Parade of Homes / showcase builder lists; permit-related public sources when legally accessible; local development/project announcements; search engine results; county/city planning and development sources.

Do not build brittle scraping that violates website terms. Prefer APIs, search services, permitted public data, or user-assisted web research.

Store source URLs and research timestamps where possible so a user can verify AI findings.

## 16. AI Builder Research Output

When the user selects "Run AI Research" on a builder, return a structured report:

**Company Snapshot** — company name; website; headquarters / primary territory; builder type; apparent project types; approximate annual activity if reasonably inferable.

**Key Contacts** — name; role; publicly available business contact information; confidence level.

**Fit Analysis** — why this builder may fit BCB; likely envelope-package opportunity; potential objections; suggested opening angle.

**Lead Score** — score out of 100; explanation.

**Recommended Next Step** — e.g. call owner; email purchasing contact; request one upcoming plan set; nurture; research further.

**Suggested Personalized Outreach** — call opener; voicemail; email; follow-up message.

All generated communication must require human review before sending.

## 17. AI Copy/Paste Prompts

Include an internal prompt library in the AI Prospecting area.

### Find Builders Prompt

> Find custom and semi-custom residential builders operating in [CITY/COUNTY], Tennessee that appear to build approximately 3-30 homes or projects per year. Prioritize locally owned or regional companies where the owner, purchasing manager, project manager, or estimator is likely accessible. Exclude giant national production builders unless they have a locally autonomous purchasing structure. For each company, return company name, website, location, apparent project type, estimated fit for Blue Collar Built's framing + roofing + siding + windows + exterior doors + garage doors envelope package, and publicly available decision-maker information. Rank the best prospects first and explain why.

### Qualify Builder Prompt

> Analyze this builder as a potential Blue Collar Built Builder Envelope Program client. Determine service-area fit, builder type, likely project volume, whether they appear to control subcontractor/vendor selection, likely pain points, possible benefit from consolidating framing/roofing/siding/windows/doors under one contractor, probable objections, and recommended next action. Assign a 0-100 lead score and explain the score.

### Personalized Outreach Prompt

> Using the research we have on this builder, draft a short personalized outreach email from Blue Collar Built. Do not sound like a mass marketing email. Our goal is not to pressure them to replace good subcontractors. We want an opportunity to price one upcoming project so they can compare our consolidated envelope package against how they currently buy those scopes. Keep the tone confident, professional, local, and direct.

### Call Preparation Prompt

> Prepare me for a 3-minute cold call with this builder. Give me a natural opener, one sentence explaining the BCB envelope program, three discovery questions, likely objections based on this builder's profile, concise responses, and the single best CTA to obtain a plan set or permission to price an upcoming project.

### Follow-Up Prompt

> Draft a concise follow-up based on our previous activity notes. Reference the actual conversation and next step. Do not use generic phrases like "just checking in" unless necessary. The goal is to move toward receiving plans or securing an opportunity to price one upcoming project.

## 18. Outreach Scripts

Build an accessible Scripts drawer/modal or section within builder records.

### Core Phone Script

> Hey [Name], this is [Rep] with Blue Collar Built here in Middle Tennessee. I'll keep it quick. We're a GC/structural contractor and we're starting to partner with a select group of builders on complete envelope packages.
>
> Instead of having separate contracts for framing, roofing, siding, windows and exterior doors, we can package those scopes together through one contractor.
>
> We've also established some aggressive direct purchasing relationships, particularly on windows, which is allowing us to get very competitive on the complete package.
>
> I'm not calling expecting you to change anything that's already working. I mainly wanted to see if you've got an upcoming project you'd be willing to let us price so you can compare our package against how you're currently buying those scopes.

### Discovery Question

> How are you currently buying your envelope?

### Follow-Up Question

> If we could consolidate those scopes and come in competitively, would you be open to trying us on one project?

### Existing Subs Objection

Builder: *We're happy with our subs.*

Response:

> That's actually what we like hearing. We're not asking you to replace somebody who's doing a great job. We'd just like an opportunity to price one upcoming project. That gives you another qualified option, and you can compare the numbers for yourself.

### Pricing Question

Builder: *How much are your packages?*

Response:

> Everything is plan-specific because framing complexity, roof design, openings and exterior selections can change quite a bit. If you send us a set of plans, our estimating team can price the package and show you exactly where we'd land.

CTA:

> What's the best email for us to send the plan request to?

## 19. Follow-Up System

Create a dedicated Follow-Ups page.

Views: Due Today; Overdue; Tomorrow; This Week; Proposal Follow-Up; Plans Requested; No Response; Dormant.

Follow-up record fields: Builder; Contact; Opportunity; Due Date; Due Time; Method; Reason; Notes; Assigned Rep; Completed; Outcome; Next Action.

Allow one-click completion followed by immediate creation of the next follow-up.

## 20. Activity Logging

Create quick actions for: Call; Email; Text / Message; Meeting; Note; Plan Request; Proposal Sent; Follow-Up.

Each activity stores: timestamp; user; contact; builder; opportunity if applicable; activity type; notes; outcome; next action.

Do not delete historical activity when statuses change.

## 21. Plan Upload / Plan Received Workflow

"Plans Received" is a critical sales milestone. When plans are uploaded:

1. Attach documents to builder + opportunity
2. Automatically set Plans Received Date
3. Offer to update pipeline status to Plans Received
4. Notify assigned estimator/user within the standalone feature
5. Create an estimating task
6. Capture bid due date if known
7. Capture project address
8. Capture requested scopes

Support multiple files and folder-style uploads where technically feasible.

Accepted common types should include: PDF; ZIP; images; common office documents; CAD references when supported by the environment.

Do not attempt to fully parse unsupported CAD formats unless an approved parser exists.

## 22. Estimating Handoff

Because this feature is standalone, do not recreate the full BCB estimating system.

Instead create a clean Estimate Handoff object/status that stores: Opportunity; Plans; Requested scopes; Estimator; Date assigned; Bid due date; Estimate status; Estimated contract value; Estimated cost; Estimated gross profit; Margin; Proposal file/link.

Later, when merged into the main app, this should map into the existing Estimate module. Create a clearly separated integration adapter/service for this future connection.

## 23. Builder-Facing Package Structure

Internally, estimates may use detailed line items. Externally, support consolidated package presentation such as: Structural Framing Package; Roofing / Dry-In Package; Exterior Envelope Package; Window + Exterior Opening Package; Complete BCB Envelope Package.

Detailed inclusions/exclusions should be shown in scope descriptions rather than exposing every internal labor/material cost.

The system should never automatically expose: internal labor rates; subcontractor rates; vendor costs; material markup; internal margin calculations; internal gross profit; commission data.

## 24. Commission Tracking

Add commission tracking but make percentages/settings configurable by Admin.

Recommended logic:

- Commission is based on collected gross profit, not raw contract revenue.
- Track account originator.
- Track first-project commission separately from repeat-business commission.
- Do not mark commission "earned/paid" solely because a contract was signed.

Fields: Originating Rep; Commission Plan; Eligible Gross Profit; Commission %; Estimated Commission; Collected Gross Profit; Earned Commission; Paid Commission; Status.

Suggested statuses: Projected; Pending Collection; Earned; Paid; Disputed / Review.

Keep all commission information internal and permission-controlled.

## 25. Reports

Create useful reporting, not vanity charts.

**Sales Funnel** — Prospect -> Qualified conversion; Qualified -> Plans conversion; Plans -> Proposal conversion; Proposal -> Won conversion.

**Rep Activity** — calls; emails; follow-ups; conversations; qualified leads; plans received.

**Builder Acquisition** — new builders by week/month; source; territory; builder tier.

**Opportunity Economics** — pipeline value; weighted pipeline; won contract value; estimated gross profit; gross margin; commission.

**Account Value** — lifetime awarded revenue by builder; lifetime estimated / collected gross profit; active opportunities; active projects.

Allow date filters.

## 26. Daily Rep Workflow

Build a "My Day" experience into the dashboard. Recommended daily targets should be configurable.

Default launch targets:

- Research 20 new builders/day
- 15 outbound calls/day
- 10 personalized emails/day
- 10 follow-ups/day
- Aim for 5 meaningful conversations/day

Do not use these as punitive employee metrics. They are an operating baseline for launching the channel and should be editable.

Daily workflow:

1. **Research** — use AI Prospecting to identify builders.
2. **Qualify** — review AI findings and manually confirm the highest-value targets.
3. **Contact** — call first where appropriate.
4. **Log** — every meaningful interaction goes into the builder record.
5. **Follow Up** — never rely on memory.
6. **Get Plans** — primary conversion objective:

> Get permission to price one project and receive the plans.

## 27. 30-Day Launch Tracker

Add an optional launch tracker widget.

**Week 1** — learn offer; build first 100 prospects; verify data quality; start calls; start email outreach.

**Week 2** — continue outbound; improve target profile; track objections; generate first qualified opportunities.

**Week 3** — aggressive follow-up; push for plan sets; begin estimates.

**Week 4** — send proposals; follow up on proposals; measure conversion rates; refine scripts and target profile.

Dashboard should compare actual results against configurable targets.

## 28. Data Model

Create clean normalized entities suitable for later merger into the primary BCB app.

**User** — id; name; email; role; active

**Builder** — id; company_name; website; phone; email; address; city; state; zip; county; service_area; builder_type; estimated_annual_builds; tier; lead_score; relationship_status; pipeline_status; assigned_rep_id; source; notes; created_at; updated_at

**BuilderContact** — id; builder_id; first_name; last_name; title; role_type; phone; email; preferred_contact_method; notes

**Opportunity** — id; builder_id; name; project_name; project_address; city; county; project_type; square_footage; estimated_start_date; bid_due_date; plans_received_date; scope_json; status; estimated_contract_value; estimated_cost; estimated_gross_profit; gross_margin; close_probability; assigned_rep_id; assigned_estimator_id; next_action; next_followup_at; won_at; lost_at; loss_reason

**Activity** — id; builder_id; opportunity_id; contact_id; user_id; type; notes; outcome; created_at

**FollowUp** — id; builder_id; opportunity_id; contact_id; assigned_user_id; due_at; method; reason; status; outcome; completed_at

**Document** — id; builder_id; opportunity_id; filename; file_type; category; storage_path; uploaded_by; uploaded_at

**AIResearch** — id; builder_id; opportunity_id; query_type; prompt_version; result_json; source_json; confidence; created_by; created_at

**Commission** — id; builder_id; opportunity_id; rep_id; plan_type; commission_rate; estimated_eligible_gp; collected_eligible_gp; estimated_commission; earned_commission; paid_commission; status

**EstimateHandoff** — id; opportunity_id; assigned_estimator_id; status; bid_due_date; estimated_contract_value; estimated_cost; estimated_gross_profit; margin; proposal_document_id

## 29. Relationship Between Builders and Projects

This distinction is critical.

- **Builders** — represents the long-term business relationship/account.
- **Opportunities** — represents a potential project or envelope package being pursued.
- **Projects** — represents actual awarded construction work in the main BCB app.

Do not create a full production project inside this standalone feature.

When an opportunity becomes Won, provide a future-ready action:

> **Create / Link Project**

For standalone testing, this can create a mock project-link record or display a clear integration placeholder. When eventually merged, it should create/link the real BCB Project.

## 30. Website / Future Lead Integration

Prepare for future connection to a public builder landing page such as:

> **bcb.blue/builders**

Future website flow:

1. Builder enters company/contact information
2. Builder enters project information
3. Builder uploads plans
4. Website sends data to BCB backend
5. Builders module creates or matches Builder account
6. Creates new Opportunity
7. Sets status to Plans Received when appropriate
8. Alerts assigned BCB user

Do not build the public website page in this task unless needed as a simple mocked integration test. Create an API endpoint/interface specification so the website can connect later.

## 31. Notifications

Standalone notifications should include: follow-up due; follow-up overdue; plans received; new opportunity; bid due approaching; proposal follow-up due; no activity on hot builder; opportunity won.

Use in-app notifications first. Architect so email/push notifications can be connected later.

## 32. Permissions

Create role-based access. Minimum roles:

- **Admin** — full access including settings, financials, commissions, AI configuration, deletion, reporting.
- **Management** — full builder/opportunity access, estimates/GP visibility as permitted, reporting.
- **Business Development / Sales** — builder accounts, contacts, activities, opportunities, AI prospecting, follow-ups, personal commission view where approved.
- **Estimator** — opportunity details, plans, estimate handoff, scopes, bid dates. No unnecessary commission access.

Internal financial fields must never be exposed outside authorized roles.

## 33. Settings

Admin settings should include: builder tiers; pipeline stages; lead scoring weights; daily activity targets; territories; opportunity statuses; lost reasons; commission plans; AI prompt templates; AI provider/configuration adapters; notification rules.

Do not hard-code business logic that should reasonably be configurable.

## 34. Search / Command Experience

Add a global search that can find: builders; contacts; opportunities; addresses; phone numbers; emails.

If the current BCB UI supports command palettes, build this feature so it can later plug into that system.

## 35. Responsive Design

Primary use is desktop/laptop, but the feature must work well on tablet and mobile.

Mobile priorities: call builder; view builder; log call; add note; schedule follow-up; update pipeline status; view opportunity; upload document/photo.

Do not simply shrink desktop tables onto mobile. Use responsive cards or stacked record views.

## 36. Performance / Quality

Requirements: fast loading; optimistic UI where safe; loading states; empty states; error states; confirmation for destructive actions; autosave where sensible; prevent accidental duplicate builders; form validation; accessible labels; keyboard-friendly desktop interactions.

Do not use fake buttons or dead-end UI. Every visible primary control must work.

## 37. Demo / Seed Data

Populate the standalone build with realistic fictional/demo builders and opportunities so all states can be tested.

Include examples for: new prospect; contacted; qualified; plans received; estimating; proposal sent; won; lost; overdue follow-up; multiple opportunities under one builder; active repeat builder.

Clearly mark demo data so it cannot be confused with real leads. Do not fabricate real-company contact data as production truth.

## 38. Initial User Experience

On first launch, show a concise welcome state:

> **Builder Partnerships**
>
> Build relationships. Win envelope packages. Create recurring work.

Primary actions: Add Builder; Find Builders with AI; Import Prospects; View Pipeline.

Do not force a tutorial, but provide contextual helper text and tooltips.

## 39. Acceptance Criteria

The standalone feature is not complete until all of the following work:

- [ ] Dashboard loads calculated metrics
- [ ] Builder can be created
- [ ] Builder can have multiple contacts
- [ ] Builder can be edited
- [ ] Duplicate warning exists
- [ ] Builder can move through pipeline stages
- [ ] Drag-and-drop pipeline works
- [ ] Opportunity can be created under builder
- [ ] Multiple opportunities can exist under one builder
- [ ] Activities can be logged
- [ ] Follow-ups can be created and completed
- [ ] Overdue follow-ups display correctly
- [ ] Plans/documents can be uploaded
- [ ] Plans Received milestone updates correctly
- [ ] Estimate handoff can be created
- [ ] AI Research interface works with provider adapter or clearly functioning mock mode
- [ ] AI research saves structured results
- [ ] AI-generated communication requires user approval
- [ ] Lead scoring works and can be manually overridden
- [ ] Builder tiers work
- [ ] Commission records calculate from eligible gross profit inputs
- [ ] Reports reflect underlying records
- [ ] Role permissions work
- [ ] Mobile layouts are usable
- [ ] Demo data is clearly marked
- [ ] No existing production BCB feature was modified
- [ ] Integration boundaries are documented

## 40. Merge-Readiness Requirements

At completion, create an internal integration document explaining:

1. Standalone architecture
2. Database schema
3. API/service interfaces
4. Authentication assumptions
5. File-storage assumptions
6. How Builders should connect to existing Clients & Projects
7. How won Opportunities should create/link Projects
8. How Estimate Handoff should connect to BCB Estimates
9. How Documents should map to the existing Documents module
10. How notifications should connect to the primary app
11. How the website builder intake endpoint should connect
12. Any environment variables/secrets required
13. Migration steps
14. Known limitations

Keep the actual feature isolated until Blue Collar Built approves the merge.

## 41. Build Order

Use this order to avoid unnecessary rework:

**Phase 1 — Foundation:** standalone shell; BCB theme; navigation; database/schema; users/roles.

**Phase 2 — Core CRM:** builders; contacts; activities; follow-ups; pipeline.

**Phase 3 — Opportunities:** opportunity records; scope selection; plans/documents; estimate handoff.

**Phase 4 — AI Prospecting:** AI workspace; provider abstraction; research output; lead scoring; prompt library; outreach drafting.

**Phase 5 — Economics:** pipeline values; gross profit fields; commissions; reports.

**Phase 6 — Polish:** responsive/mobile; smooth animations; empty/loading/error states; search; saved views; demo data.

**Phase 7 — QA / Handoff:** test every acceptance criterion; fix dead ends; document integration points; deliver standalone build for BCB review.

## 42. Development Principles

Use the existing project stack and conventions where possible so eventual integration is easy.

If the standalone environment requires new choices: prefer mature, maintainable libraries; keep dependencies minimal; separate UI, business logic, data access, and AI services; centralize types/models; centralize API calls; centralize permissions; centralize feature configuration.

Do not over-engineer microservices for this feature. Do not create an entirely different design framework from the main BCB app.

## 43. Claude Execution Instructions

Claude: treat this document as the product specification for the Builders standalone module.

**Before coding:**

1. Inspect the existing BCB codebase and identify its framework, styling system, component patterns, authentication model, database conventions, and reusable UI components.
2. Do not alter production features.
3. Create the Builders feature in an isolated standalone location/environment.
4. Reuse the BCB visual system where practical.
5. Document assumptions before making irreversible architecture decisions.

**During coding:**

- Work systematically through the Build Order.
- Keep the feature runnable after each major phase.
- Do not leave visible buttons nonfunctional.
- Do not substitute placeholder UI for core required behavior.
- Use realistic demo data only where real integrations are unavailable.
- Keep AI calls behind a provider/service abstraction.
- Never place API keys directly in frontend code.

**Before declaring completion:**

1. Test the entire user journey from new prospect to won opportunity.
2. Test a builder with multiple opportunities.
3. Test plans received and estimate handoff.
4. Test follow-up reminders and overdue states.
5. Test permissions.
6. Test mobile layout.
7. Test AI research and draft-approval workflow.
8. Verify no production feature was unintentionally changed.
9. Produce the Merge-Readiness integration document.

## 44. End-to-End Success Scenario

The feature should support this exact flow:

1. BCB rep opens AI Prospecting.
2. Searches for custom/semi-custom builders in Williamson County.
3. AI returns researched prospects with sources and lead scores.
4. Rep reviews results and adds a strong prospect to Builders.
5. Builder appears in Prospect stage.
6. Rep calls the builder and logs the call.
7. Builder is interested; rep moves account to Engaged.
8. Rep schedules a follow-up.
9. Builder agrees to allow BCB to price one project.
10. Opportunity is created.
11. Builder sends plans.
12. Plans are uploaded to the opportunity.
13. Status becomes Plans Received.
14. Estimate Handoff is created.
15. Estimated contract value and gross profit are entered when available.
16. Proposal is sent.
17. Follow-up is scheduled.
18. Builder awards BCB the envelope package.
19. Opportunity moves to Won.
20. Commission projection updates.
21. Feature presents Create / Link Project as the future integration handoff.
22. Builder remains a long-term account for future opportunities.

That is the core operating loop this feature must make simple, fast, and professional.

---

**BLUE COLLAR BUILT — Built on Grit. Powered by Trust.**
