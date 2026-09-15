# Test Checklist — BCB Website Backend

Required working file per spec §32. Tracks the 22 acceptance tests (§27), the 5
test scenarios (§28), and the per-checkpoint exit criteria (§26).

Spec §31: *"Claim the build is complete without running the acceptance tests"* is
forbidden. A box is ticked only when the test has actually been run and passed —
not when the code that should satisfy it has been written.

**Legend:** `[ ]` not started · `[~]` implemented, not verified · `[x]` verified passing

---

## Checkpoint exit criteria (§26)

| # | Checkpoint | Exit criterion | Status |
|---|---|---|---|
| 0 | Architecture & repository review | Architecture documented, supports adapter-based integration | [x] — see `CHECKPOINT_0.md` |
| 1 | Standalone shell, auth & permissions | Unauthorized users cannot access admin pages | [ ] |
| 2 | Pages & content editor | Admin can recreate/edit current homepage structure without code | [ ] |
| 3 | Services & navigation | Current four service categories manageable from admin | [ ] |
| 4 | Forms & submissions | Test customer submits a quote; admin sees preserved submission | [ ] |
| 5 | Temporary lead creation & duplicates | Submission reliably creates/links a lead without losing raw data | [ ] |
| 6 | Notifications & routing | Configured recipients get a test alert linking to the correct lead | [ ] |
| 7 | Media, SEO, contact info, settings | Common content/settings changeable without source edits | [ ] |
| 8 | Public website connection | Public site renders CMS content; form submissions reach backend | [ ] |
| 9 | QA, security & production readiness | No critical security, data-loss, or publish-state defects | [ ] |
| 10 | BCB app integration package | A future session can merge using the documented plan | [ ] |

Checkpoint 0 is marked verified on the narrow basis that its exit criterion is
documentary. Its two substantive findings — no BCB app code in this repo, stack
unconfirmable — are recorded as OPEN-1 and must be resolved before Checkpoint 1.

---

## Acceptance tests (§27)

Each maps to the checkpoint that should make it pass.

### Auth & permissions

- [ ] **1.** Admin login is required for all internal website-management routes. *(CP1)*
      Verify server-side, per route group — not by hiding nav links.
- [ ] **18.** A user without publish permission cannot publish. *(CP2)*
      Assert on the API response, not the UI. Pairs with Scenario D.

### Content management

- [ ] **2.** Page hierarchy can represent the actual BCB site. *(CP2)*
      Target shape is §7: Home / Services (3 children) / Barns / Why Us / Get a Quote.
- [ ] **3.** Admin can edit homepage hero copy and publish it. *(CP2)*
- [ ] **6.** Draft edits do not appear publicly before Publish. *(CP2)*
      Check the public API/render path directly, not just the admin preview.
- [ ] **21.** Current website content can be represented without hard-coded page markup. *(CP2/CP8)*
      Falsified by any §3 trust statement or service blurb living in a component.
- [ ] **4.** Admin can edit all four current service records. *(CP3)*
      Framing Construction; Remodeling & Renovations; Additions & New Builds; Barns & Barndominiums.
- [ ] **5.** Admin can edit global phone/email/service-area data. *(CP7)*
      One edit must propagate everywhere it is referenced (§18).
- [ ] **19.** Slug changes can create redirects. *(CP7)*

### Forms, submissions & leads

- [ ] **7.** Public quote form contains current required fields. *(CP4)*
      Exactly §3: First Name, Last Name, Email, Phone, Service Needed, Project Address, Project Description.
- [ ] **8.** A valid submission is permanently recorded before downstream processing. *(CP4)*
      The ordering guarantee from D-003. Test by failing every downstream step.
- [ ] **9.** Exact email/phone duplicates are detected. *(CP5)*
      Normalize first (§11): casing, `+1`, punctuation, whitespace.
- [ ] **10.** Duplicate logic never deletes the new raw submission. *(CP5)*
- [ ] **11.** New submissions can create temporary leads. *(CP5)*
- [ ] **16.** Uploaded lead files are private by default. *(CP4/CP7)*
      Fetch the object URL unauthenticated and require a denial.

### Notifications

- [ ] **12.** Lead alert recipient rules can target roles and users. *(CP6)*
- [ ] **13.** Email alert contains a working View Lead link. *(CP6)*
      Must deep-link to the exact lead, using `ADMIN_BASE_URL`.
- [ ] **14.** Failed email delivery does not erase or roll back the lead. *(CP6)*
      Pairs with Scenario C.
- [ ] **15.** AI failure does not prevent lead creation. *(CP5/CP6)*
      Pairs with Scenario E.

### Security & platform

- [ ] **17.** Public APIs cannot list leads or submissions. *(CP8/CP9)*
      Enumerate every `/api/public/*` route against the §22 forbidden list.
- [ ] **20.** Website works on common mobile widths. *(CP8/CP9)*
      360 / 390 / 414 / 768 px minimum.
- [ ] **22.** Integration providers are documented and swappable. *(CP10)*
      `INTEGRATION_NOTES.md` matches `grep -rn "TEMPORARY(website-backend)" src/`.

---

## Test scenarios (§28)

- [ ] **Scenario A — Framing lead.**
      Test Customer A · Framing Construction · Dickson, TN · "New detached garage framing request".
      Expect: new submission, new lead, framing tag/service, alerts sent.

- [ ] **Scenario B — Duplicate email.**
      Resubmit the same email with a different project description.
      Expect: second submission preserved; probable existing lead flagged or linked.
      Must **not** silently create a duplicate or overwrite the first lead.

- [ ] **Scenario C — Email delivery failure.**
      Force `NotificationProvider` to fail.
      Expect: submission and lead saved; delivery status records the failure with retry available.

- [ ] **Scenario D — Unauthorized publish.**
      Sales/Estimator user attempts publish.
      Expect: server rejects unless `website.publish` is explicitly granted.

- [ ] **Scenario E — AI unavailable.**
      `ENRICHMENT_ENABLED=false`.
      Expect: lead still created, team still alerted.

---

## Standing regression checks

Re-run before closing any checkpoint from 4 onward — these are the constraints
most likely to erode quietly.

- [ ] No secret in source control (`.env.example` values all blank).
- [ ] No `/api/public/*` route returns lead, submission, user, or permission data.
- [ ] `form_submissions.raw_values` has no update path anywhere in the codebase (D-006).
- [ ] Deleting a temp lead leaves its submissions intact (§20).
- [ ] No call site branches on a role name instead of a capability (D-004).
- [ ] Nothing outside `providers/registry.ts` imports from `providers/` or `db/` (D-005).
- [ ] Public form is rate-limited and spam-protected (§23).
- [ ] Every visible primary control works — no dead-end UI.
