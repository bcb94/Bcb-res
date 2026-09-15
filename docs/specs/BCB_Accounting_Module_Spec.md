# Blue Collar Built — Standalone Accounting Module

**Claude Build Roadmap — Version 1.0 — Standalone First, Merge Later**

> Source: Google Doc "Bcb accounting module" (`11YA2A07MGr8yhomM0Pgsz2E1tIoAhSy5izL49fAc7Fk`).
> Transcribed into the repository so coding sessions can read it as a file.

---

## 1. Purpose

Build a standalone internal accounting application for Blue Collar Built ("BCB") that can be developed, tested, and perfected independently before being merged into the main BCB operating app.

The standalone system should function as BCB's internal:

- accounting workspace
- bookkeeping review center
- transaction classification system
- job-costing engine
- receipt/document intake center
- tax-minimization review system
- QuickBooks reconciliation layer
- owner/admin financial dashboard
- tax-professional reporting system

This standalone build must be production-minded from the start. Do not build this as a disposable prototype.

The core architecture, database structure, services, APIs, components, and workflows should be reusable when this feature is later merged into the primary BCB app.

## 2. Primary Objective

The system should help BCB:

1. understand where every dollar came from and where it went
2. connect legitimate business expenses to the correct project
3. identify legitimate business deductions that may have been missed
4. reconcile internal accounting against QuickBooks and bank activity
5. maintain supporting documentation for expenses
6. separate direct project costs from company overhead
7. identify assets and depreciation opportunities
8. surface tax-planning opportunities for professional review
9. create reliable project profitability reports
10. create a professional year-end package for BCB's CPA/tax professional

The tax objective is:

> Minimize BCB's lawful tax liability by identifying and documenting every legitimate business expense and tax-planning opportunity while avoiding fabricated, unsupported, or intentionally misleading positions.

## 3. Build Strategy

### Phase 1 — Standalone

Build this module as its own application. Suggested working name: **BCB ACCOUNTING**

It should have: its own frontend; its own backend; its own database; its own authentication; its own document storage abstraction; its own API layer; its own QuickBooks integration layer; its own AI accounting services.

However, design everything with later BCB app integration in mind.

### Phase 2 — Test & Perfect

Operate the standalone system with real BCB data. Use it to identify: missing workflows; accounting edge cases; job-costing problems; UI problems; inaccurate AI assumptions; QuickBooks synchronization issues; document classification errors; reporting improvements; permissions requirements.

Do not merge until the standalone module is stable.

### Phase 3 — Merge Into Main BCB App

Once approved, move the module into the primary BCB app as **Accounting**.

The merged version should use the main BCB: user accounts; admin permissions; project database; clients; vendors; subcontractors; document center; estimates; invoices; scheduling data where useful.

The accounting module should not need to be rewritten. Only replace standalone adapters with shared BCB app services.

## 4. Modular Architecture Requirement

Use clear boundaries. Recommended structure:

```text
/accounting
    /components
    /pages
    /services
    /api
    /ai
    /quickbooks
    /documents
    /reports
    /job-costing
    /transactions
    /tax
    /assets
    /vendors
    /reconciliation
    /permissions
```

Keep accounting-specific business logic inside the accounting module. Do not tightly couple the standalone system to temporary UI code.

## 5. Adapter-First Design

Anything that will later come from the main BCB app should use an adapter/interface. Examples:

```text
ProjectProvider
ClientProvider
VendorProvider
UserProvider
DocumentProvider
AccountingProvider
QuickBooksProvider
NotificationProvider
```

Standalone mode can use local/database-backed providers. Merged mode can swap those providers for the main BCB app services.

```text
StandaloneProjectProvider
        v later replaced by
BCBProjectProvider
```

The UI and accounting logic should not need major changes.

## 6. User Access

This is a sensitive module. Default access: **ADMIN ONLY**

The full accounting area should only be accessible to authorized admins.

Future role possibilities: Owner; Accounting Admin; Bookkeeper; CPA / Tax Professional; Project Manager Limited View; Read Only.

For the initial standalone build:

- **Owner/Admin** — full access.
- **CPA/Tax Professional** — optional read-only access plus report/download capability.

Do not expose accounting information to general team members.

## 7. Main Navigation

```text
Dashboard
Transactions
Banking
Receipts
Projects
Job Costing
Vendors
Subcontractors
Assets
Tax Center
Reports
QuickBooks
Documents
Review Queue
Settings
```

Keep the interface professional, clean, and similar in usability philosophy to modern accounting platforms. Do not visually clone QuickBooks. Use BCB branding and a simple, premium interface.

## 8. Dashboard

### Top cards

Cash Balance; Revenue YTD; Direct Job Costs YTD; Gross Profit YTD; Gross Margin; Overhead YTD; Net Income/Loss YTD; Accounts Receivable; Accounts Payable.

### Secondary cards

Missing Receipts; Transactions Needing Review; Uncategorized Transactions; Unassigned Job Costs; QuickBooks Mismatches; Tax Opportunities; Potential Assets; Subcontractor Compliance Items; Possible 1099 Issues.

### Project profitability

Display: highest-margin jobs; lowest-margin jobs; projects missing costs; projects with expenses but no revenue; projects with revenue but unusually low recorded costs.

## 9. Transaction Center

Create a master transaction ledger.

Columns:

```text
Date
Vendor
Original Description
Amount
Account
Type
Business Status
Category
Project
Receipt
QuickBooks Status
Tax Treatment
Confidence
Risk
Review Status
```

Filters: date; account; project; vendor; category; status; missing receipt; QuickBooks mismatch; tax review; personal/mixed; direct cost; overhead.

Bulk actions should eventually support: assign project; assign category; mark reviewed; request documentation; change vendor; add note.

**Never silently overwrite original imported values.**

## 10. Banking / Statement Intake

Allow upload of: PDF bank statements; CSV bank exports; credit-card statements; check images; transaction exports.

Workflow:

```text
Upload
   v
Extract Transactions
   v
Normalize Vendors
   v
Detect Transfers
   v
Classify
   v
Match QuickBooks
   v
Assign Projects
   v
Flag Missing Documentation
   v
Human Review
```

Display statement-level reconciliation:

```text
Beginning Balance
+ Deposits
- Withdrawals
= Calculated Ending Balance
vs
Statement Ending Balance
```

Flag differences.

## 11. Receipts Center

Allow: single receipt upload; multiple receipt upload; folder upload; drag-and-drop; phone photo upload later; PDF invoice upload.

Extract: vendor; date; total; tax; line items where useful; payment method; project/address clues; invoice number.

Then attempt to match the receipt to an existing transaction. Matching logic should use: amount; vendor; date; payment source; invoice number.

Statuses: Matched; Likely Match; Duplicate; No Match; Needs Review.

## 12. Project / Job-Costing Engine

Every direct construction expense should be linked to a project whenever possible.

Project summary:

```text
Project Name
Client
Contract Amount / Revenue
Materials
Subcontractor Labor
Internal Labor
Equipment/Rental
Permits
Other Direct Costs
Total Direct Costs
Gross Profit
Gross Margin
```

Allow drill-down into every cost.

## 13. Project Matching Logic

Use evidence in this order:

1. exact project selection
2. invoice project/address
3. receipt project note
4. QuickBooks customer/project
5. vendor invoice
6. project document
7. estimate/purchase order
8. date range
9. vendor/material association
10. owner/admin confirmation

Confidence: Confirmed; Strong Match; Probable; Needs Review.

**Never auto-post a low-confidence project assignment.**

## 14. Project Cost Categories

Suggested direct-cost groups:

```text
Framing            Roof Framing        Roofing
Siding             Windows             Exterior Doors
Garage Doors       Concrete            Masonry
Insulation         Plumbing            Electrical
HVAC               Metal               Soffit / Fascia
Grade Work         Equipment           Dumpster
Permits            Engineering         Surveying
Temporary Utilities   Subcontract Labor   Other Direct Cost
```

This structure should be customizable later.

## 15. Business Overhead Categories

Examples:

```text
Advertising     Accounting      Legal           Bank Fees
Merchant Fees   Software        AI Tools        Website
Hosting         Domains         Business Email  SEO
Lead Generation Office          Phone           Internet
Insurance       Workers Compensation            Commercial Auto
Licensing       Education       Recruiting      Storage
Rent            Utilities       Vehicle Expense Fuel
Repairs         Tools           Small Equipment Travel
Meals           Professional Services           Miscellaneous Review
```

Do not force a transaction into a category when facts are unclear.

## 16. QuickBooks Integration

Build the integration as its own service. The standalone accounting system should not depend on QuickBooks for its internal UI. QuickBooks is an accounting source/sync target.

### Read mode

Initial integration should prioritize reading: chart of accounts; customers; projects; vendors; bank transactions; expenses; bills; invoices; payments; products/services; journal entries; reports; contractor information.

### Matching engine

For every BCB transaction show:

```text
QuickBooks Match:
Exact
Likely
No Match
Possible Duplicate
Category Mismatch
Amount Mismatch
Project Missing
```

### Write mode

Do not enable destructive or automatic writes by default. Create an approval queue. Example:

```text
Current QB Category:
Supplies

Proposed:
COGS > Framing Materials

Project:
Smith Residence

Confidence:
96%

Reason:
Lumber supplier invoice references project address.

[Approve]
[Edit]
[Reject]
```

Only approved changes should be pushed to QuickBooks. Maintain a permanent audit log.

## 17. QuickBooks Sync Log

Track:

```text
Sync Date
Entity Type
BCB Record
QuickBooks ID
Action
Old Value
New Value
User
Status
Error
```

The standalone system must be able to explain what was changed.

## 18. AI Accounting Agent

Create an AI service inside the module. The AI must use the separate **BCB AI Accounting / CPA / Tax-Minimization Roadmap** as its operating rules.

The AI's job is to: classify transactions; normalize vendors; identify possible project matches; identify potential business deductions; detect likely assets; identify duplicate transactions; detect suspicious classifications; identify missing documentation; identify tax-planning opportunities; prepare CPA questions; explain classifications; create reports.

**The AI should never silently make irreversible accounting changes.**

## 19. Confidence-Based Automation

Use confidence thresholds:

- **95–100%** — allow recommended category/project to be prefilled.
- **80–94%** — show strong recommendation but require review.
- **60–79%** — place in review queue.
- **Below 60%** — do not guess.

Thresholds should be configurable.

## 20. Review Queue

Create one central review area. Tabs:

```text
Needs Category          Needs Project       Missing Receipt
Potential Personal Expense                  Mixed Use
Possible Asset          QuickBooks Mismatch Possible Duplicate
Tax Review              Subcontractor Issue 1099 Review
Unreconciled
```

Each item should allow: approve; edit; reject; add note; attach documentation; assign project; assign vendor; ask AI for explanation.

## 21. Tax Center

The Tax Center is not a tax-filing engine. It is a tax-preparation and planning workspace.

Sections:

```text
Tax Summary
Deduction Review
Assets / Depreciation
Vehicles
Owner-Paid Expenses
Tax Strategy
1099 Review
Missing Documentation
CPA Questions
Year-End Package
```

## 22. Deduction Review

Show totals by category. Each category should display: amount; support level; documentation status; project association; QuickBooks status; tax review status.

Allow drill-down to individual transactions.

## 23. Tax Strategy Queue

Flag opportunities such as: Section 179 review; bonus depreciation review; equipment treatment; vehicle treatment; repair vs capitalize; owner reimbursement opportunities; retirement plan opportunities; home-office review where applicable; health-insurance treatment where applicable; entity structure questions; QBI review; estimated tax planning; state/local tax items.

Every strategy should show:

```text
Potential Impact
Requirements
Documentation Needed
Deadline
Risk Level
CPA Approval Needed
```

Do not present tax planning as guaranteed.

## 24. Asset Center

Create asset records for potential capital purchases.

Fields:

```text
Asset Name        Vendor            Purchase Date
Placed In Service Purchase Price    Financed?
Loan              Business Use %    Project
Serial Number     VIN               Current QB Treatment
Suggested Review  Disposed?         Disposal Date
```

Categories: Vehicle; Trailer; Heavy Equipment; Power Equipment; Computer; Office Equipment; Furniture; Building/Improvement; Other Asset.

## 25. Vehicle Center

For each vehicle track:

```text
Vehicle       Ownership      Purchase Date   Purchase Price
Loan          Business Use % Fuel            Maintenance
Insurance     Registration   Repairs         Interest
Mileage Documentation        Tax Treatment Review
```

**Do not generate artificial mileage.**

## 26. Vendor Center

Vendor profile:

```text
Vendor Name   Category   Contact   Total Spend
Projects      QuickBooks Vendor    W-9 Status
1099 Review   Insurance Status     Documents   Notes
```

Vendor categories may include: supplier; subcontractor; professional service; software; insurance; utility; equipment; other.

## 27. Subcontractor Center

For subcontractors track:

```text
Company/Person   Trade         W-9            TIN Status
1099 Status      General Liability            Workers Comp
Expiration Dates Projects      Total Paid     Documents   Notes
```

Do not make worker-classification legal conclusions solely from these records.

## 28. Document Center

The standalone accounting module should maintain accounting documents. Folder logic:

```text
Accounting
    /2026
        /Bank Statements
        /Credit Cards
        /Receipts
        /Vendor Invoices
        /Subcontractors
        /Assets
        /Vehicles
        /Tax
        /Reports
        /Projects
```

Project-related accounting documents should also link to the project. Later, this can merge with the main BCB document center. Avoid duplicated files when possible. Use references/links where architecture allows.

## 29. Reporting

### Financial

Profit & Loss; Balance Sheet summary; Cash Flow summary; Expenses by Vendor; Expenses by Category; Revenue by Project; Job Profitability; Overhead Summary.

### Accounting cleanup

Uncategorized Transactions; Missing Receipts; QuickBooks Mismatches; Duplicate Transactions; Reconciliation Exceptions; Owner/Personal Review.

### Tax

Deduction Summary; Tax Strategy Queue; Asset Review; Vehicle Review; Owner-Paid Expense Review; 1099 Review; Missing Documentation; CPA Question List.

## 30. Year-End CPA Package

Create one action: **Generate CPA Package**

The system should generate:

```text
BCB_Tax_Professional_Report_[YEAR].pdf
BCB_Tax_Professional_Report_[YEAR].md
BCB_Transaction_Review_[YEAR].csv
BCB_Proposed_QB_Adjustments_[YEAR].csv
BCB_Job_Cost_Summary_[YEAR].csv
BCB_Asset_Depreciation_Review_[YEAR].csv
BCB_Subcontractor_1099_Review_[YEAR].csv
BCB_Missing_Documentation_[YEAR].csv
BCB_Tax_Strategy_Queue_[YEAR].csv
```

Provide a ZIP download option later.

## 31. Monthly Close Workflow

Add a guided workflow: **Close Month**

```text
 1. Import Bank Activity
 2. Import Credit Cards
 3. Reconcile Accounts
 4. Match Receipts
 5. Review Uncategorized Transactions
 6. Assign Job Costs
 7. Review QuickBooks Differences
 8. Review Potential Assets
 9. Review Subcontractors
10. Review Owner-Paid Expenses
11. Review Missing Documentation
12. Review Tax Opportunities
13. Finalize Monthly Report
```

Display completion percentage.

## 32. Data Model

At minimum create the following core entities:

```text
User        Role        Account      Statement    Transaction
Vendor      Subcontractor            Client       Project
Receipt     Document    Category     Asset        Vehicle
Loan        QuickBooksConnection     QuickBooksRecord
QuickBooksSync          Reconciliation           TaxReview
TaxStrategy ReviewItem  AuditLog     Report
```

Use stable unique IDs. Do not rely on display names as relational keys.

## 33. Transaction Data Model

Recommended fields:

```text
id                  sourceAccountId     statementId
transactionDate     postedDate          originalDescription
normalizedVendorId  amount              direction
transactionType     businessStatus      accountingClass
categoryId          projectId           clientId
receiptId           documentIds         businessPurpose
deductibilityPercent                    taxTreatment
confidenceScore     riskLevel           quickbooksRecordId
quickbooksStatus    reviewStatus        createdAt    updatedAt
```

## 34. Project Data Model

Recommended:

```text
id          name        clientId    address     status
contractAmount          startDate   endDate
quickbooksProjectId     createdAt   updatedAt
```

The standalone system should allow manual projects initially. Later these records can map to the main BCB project system.

## 35. Audit Log

Any manual or AI-assisted accounting action should be traceable. Track:

```text
timestamp   user        record      action
before      after       AI recommendation
confidence  approval status
```

**Never permanently hide historical changes.**

## 36. Security

Because this system contains sensitive financial information:

- use secure authentication
- use server-side authorization
- encrypt secrets
- never expose QuickBooks tokens client-side
- never expose banking credentials
- restrict files by authorization
- use secure upload handling
- log sensitive administrative actions
- never store plaintext API secrets in source code
- use environment variables/secrets management

## 37. Backups

The standalone system should support: database backups; document backup strategy; export of accounting data; export before major migrations.

Before the final merge into BCB: create a complete migration snapshot.

## 38. Merge-Readiness Requirements

Before the module is considered ready to merge:

- [ ] transactions function correctly
- [ ] bank statement upload works
- [ ] CSV upload works
- [ ] receipt matching works
- [ ] project assignment works
- [ ] job-cost reporting works
- [ ] QuickBooks read integration works
- [ ] QuickBooks proposal queue works
- [ ] QuickBooks write actions require approval
- [ ] audit log works
- [ ] asset center works
- [ ] subcontractor center works
- [ ] tax center works
- [ ] year-end reports work
- [ ] monthly close works
- [ ] permissions work
- [ ] backup/export works
- [ ] data migration plan is documented

## 39. Final Merge Plan

When merging, replace:

```text
StandaloneUserProvider
StandaloneProjectProvider
StandaloneClientProvider
StandaloneDocumentProvider
```

with:

```text
BCBUserProvider
BCBProjectProvider
BCBClientProvider
BCBDocumentProvider
```

Keep:

```text
Accounting Engine       Transaction Engine      QuickBooks Service
Job Costing Engine      Tax Review Engine       Reporting Engine
Asset Engine            Reconciliation Engine   AI Accounting Agent
```

Do not rebuild these systems.

## 40. Future Integration With Other BCB Features

Once merged, the Accounting module should eventually communicate with:

**Projects** — accounting receives project name, client, address, contract value, status; accounting returns actual cost, committed cost, gross profit, gross margin.

**Estimates** — when an estimate becomes a project, preserve estimated cost structure and compare estimate vs actual costs. Future report: *Estimated vs Actual*.

**Invoices** — accounting should recognize invoices; payments; outstanding balances; deposits.

**Documents** — project receipts/invoices should be visible from Accounting and Project Documents without unnecessary duplicate uploads.

**Subcontractors** — accounting should connect payment totals with subcontractor records.

**Future AI Accounting Feature** — the final merged Accounting area can eventually act like an internal bookkeeper, controller, job-cost analyst, accounting assistant and tax-strategy assistant, while still requiring professional review where appropriate.

## 41. UI Direction

BCB Accounting should feel: professional; premium; clean; modern; easy to scan; financially serious.

Avoid: clutter; overly bright colors; consumer-finance appearance; dense spreadsheet-only interfaces.

Use: clean cards; organized tables; expandable details; subtle BCB navy; strong hierarchy; smooth transitions; clear status badges; light/dark mode compatibility if practical.

The accounting module should feel like it belongs inside the BCB operating system even while standalone.

## 42. First Build Priority

Do not attempt every advanced feature simultaneously. Build in this order:

**Milestone 1 — Foundation:** authentication; admin permissions; database; navigation; dashboard shell.

**Milestone 2 — Transactions:** transaction ledger; CSV import; manual transactions; classification; vendor normalization.

**Milestone 3 — Projects / Job Costing:** project records; transaction-to-project assignment; project profitability.

**Milestone 4 — Receipts / Documents:** receipt upload; OCR/extraction where available; transaction matching; missing receipt queue.

**Milestone 5 — QuickBooks:** connection; read; matching; discrepancy detection; approval queue.

**Milestone 6 — AI Accounting:** classification recommendations; project recommendations; deduction review; asset detection; review explanations.

**Milestone 7 — Tax Center:** tax review; assets; vehicles; owner-paid expenses; 1099 review; tax strategy queue.

**Milestone 8 — Reports:** monthly reports; job-cost reports; CPA package.

**Milestone 9 — Hardening:** security; audit logging; backups; error handling; performance; testing.

**Milestone 10 — Merge Preparation:** adapters; migration scripts; shared IDs; integration documentation.

## 43. Claude Development Rule

When coding this feature:

Do not create placeholder features that appear functional but are not connected.

- If a button exists, it should work.
- If a report exists, it should use real stored data.
- If AI provides a recommendation, store the recommendation and confidence.
- If QuickBooks is not yet connected, clearly display: *QuickBooks Not Connected*

Do not fake sync status.

## 44. Standalone Success Criteria

The standalone BCB Accounting module is successful when BCB can:

1. upload bank statements
2. upload transactions
3. upload receipts
4. review AI classifications
5. assign costs to jobs
6. see project profitability
7. compare transactions with QuickBooks
8. clean up accounting records
9. identify missed legitimate business expenses
10. track assets
11. monitor subcontractor payments
12. maintain tax documentation
13. build a year-end tax package
14. give a CPA a clean, traceable report
15. later merge the feature without rebuilding its accounting engine

## 45. Starting Command for Claude

Use this document as the master build roadmap. Start by creating the standalone architecture and foundation. Do not merge this into the existing BCB app yet. Treat the standalone module as a production-quality independent application that is intentionally designed for future integration.

Before moving to each major milestone:

1. confirm the current milestone works
2. fix errors
3. preserve existing functionality
4. document architectural decisions
5. keep the module merge-ready

Primary goal:

> Build BCB Accounting correctly once, perfect it independently, then merge the finished system into the main BCB app with minimal rework.
