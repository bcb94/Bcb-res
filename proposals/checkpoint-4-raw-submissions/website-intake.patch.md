# `website-intake` — writing the submission first

Change plan for `supabase/functions/website-intake/index.ts` in
`bcb94/bcb-command-center`, against `b4bb8a7` (420 lines).

Not applied, and deliberately not a `.patch` file: the deployed function is the
authority here, not the one in the repo (`AGENT_HANDOFF.md` §1 — 41 of the live
functions have no source committed, and some deployed bodies differ). **Diff the
deployed function against the repo copy before touching either.**

Pairs with `0001_website_form_submissions.sql`. Deploy the migration first; this
function keeps working unchanged in between, because the migration is additive.

---

## The ordering that matters

Spec §11 fixes the order and D-003 explains why. The function already gets the
hard half right — assignment, the todo and the email are all after the insert and
all independently caught. Only one step is missing, and it goes at the front:

```
  write raw submission ───┐   NEW. must succeed.
  normalize + dedupe      ├── the part that must not lose data
  create or link lead     ─┘
          │
          v
  round-robin ─── follow-up todo ─── team email   (each best-effort, unchanged)
```

The submission write is the one new step that is allowed to fail the request. If
we cannot record what the customer sent, we have not received it. Everything
after the lead insert stays exactly as it is.

---

## 1. Record the submission before the lead

Both entry paths converge on `admin.from("leads").insert(...)`. Insert this
immediately before, in each:

```ts
// The payload as received, before anything is mapped onto leads columns. This
// is the spec's most repeated constraint (§10, §20, §27.10, §31) and the only
// step here allowed to fail the request: if we cannot record what the customer
// sent, we have not received it.
async function recordSubmission(admin: any, input: {
  rawValues: Record<string, unknown>;
  intakeIp: string | null;
  externalSource: string | null;
  externalId: string | null;
  sourcePage: string | null;
  referrer: string | null;
}): Promise<{ id: string } | { duplicate: true }> {
  const { data, error } = await admin
    .from("website_form_submissions")
    .insert({
      form_key: "quote",
      form_version: 1,
      raw_values: input.rawValues,
      intake_ip: input.intakeIp,
      external_source: input.externalSource,
      external_id: input.externalId,
      source_page: input.sourcePage,
      referrer: input.referrer,
    })
    .select("id")
    .single();

  // 23505 on website_form_submissions_external_key means this exact Netlify
  // submission was already recorded. That IS the idempotency check -- the
  // database now owns it, so the pre-insert SELECT on internal_notes goes away.
  if (error?.code === "23505") return { duplicate: true };
  if (error) throw error;
  return { id: data.id };
}
```

`rawValues` must be the **whole** body, not the fields we happen to map:

```ts
// JSON path -- the parsed body, minus the honeypot.
const { _hp, ...rawValues } = body;

// Netlify path -- the submission's own data object.
const rawValues = (sub && typeof sub.data === "object" && sub.data) || {};
```

Then link it after the lead insert succeeds:

```ts
await admin.from("lead_submission_links").insert({
  submission_id: submissionId,
  lead_id: newLead.id,
  link_reason: "created",
});
```

Best-effort and caught, like the other post-insert steps: the submission and the
lead both exist by this point, and a missing link is repairable from either side.

## 2. Move the rate limit off `leads`

Today:

```ts
const { count } = await admin
  .from("leads")
  .select("id", { count: "exact", head: true })
  .eq("lead_source", "website")
  .eq("internal_notes", `intake_ip:${ip}`)
  .gte("created_at", tenMinAgo);
```

That counts *saved leads*, so a bot whose submissions fail validation is never
throttled, and it reads a column staff can edit. Count submissions instead —
which also means the limit now applies to attempts, which is what a rate limit is
for:

```ts
const { count } = await admin
  .from("website_form_submissions")
  .select("id", { count: "exact", head: true })
  .eq("intake_ip", ip)
  .gte("created_at", tenMinAgo);
```

**Ordering subtlety:** the check has to stay *before* `recordSubmission`, or every
request increments its own counter and the limit is off by one per caller. Check,
then record, then insert the lead.

## 3. Stop writing keys into `internal_notes`

Drop both assignments. `internal_notes` goes back to meaning "a note somebody
typed", and the rate-limit and idempotency keys live in their own columns.

```ts
// JSON path:   internal_notes: `intake_ip:${ip}`,       ← delete
// Netlify path: internal_notes: `netlify_form:${...}`,  ← delete
```

And delete the pre-insert duplicate SELECT in `handleNetlifyWebhook` — the unique
index does that job now, without a round trip:

```ts
const sub = await recordSubmission(admin, { /* … externalSource: "netlify" … */ });
if ("duplicate" in sub) return json({ success: true, duplicate: true });
```

### Backfill, or rather: don't

Existing rows keep their `intake_ip:` / `netlify_form:` strings in
`internal_notes`. Leave them. They are historical, nothing reads them once this
ships, and a migration that rewrites a staff-editable notes column across every
website lead is a worse trade than a few dozen rows of harmless legacy text.

Worth one pass by hand: any website lead whose `internal_notes` does **not** match
`^(intake_ip|netlify_form):` is a row where somebody typed a real note and
silently broke the rate limit or the idempotency check for it. That query is the
evidence for whether the trap in §2.5 of `CHECKPOINT_0.md` ever actually fired.

```sql
select id, lead_no, created_at, internal_notes
  from public.leads
 where lead_source = 'website'
   and internal_notes is not null
   and internal_notes !~ '^(intake_ip|netlify_form):'
 order by created_at desc;
```

---

## Verifying

`AGENT_HANDOFF.md` §6: test the real thing, and verify the end state rather than
the return value.

1. **Test 8.** Post a valid submission with an extra field `leads` has no column
   for. Assert the row in `website_form_submissions` contains that field in
   `raw_values`, and that a lead exists and is linked.
2. **Test 8, harder.** Make the `leads` insert fail (a bad `stage` value). Assert
   the submission survives alone — that is the guarantee, and it is the reverse
   of what the function does today.
3. **Test 10.** Delete the lead. Assert the submission is untouched and the link
   row remains with `lead_id` null.
4. **Scenario C.** Break the email step. Assert submission, lead and link all
   persist and the failure is recorded.
5. **Rate limit.** Six posts from one IP inside ten minutes: the sixth is 429, and
   there are five submissions, not six.
6. **Webhook idempotency.** Replay one signed Netlify body twice. Assert one
   submission, one lead, one round of emails.

Deploy the function, then confirm the public site still submits end-to-end
(`AGENT_HANDOFF.md` §2 — "deploy is live" means the upload succeeded, not that
the site works).
