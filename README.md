# Bcb-res

Blue Collar Built — build specifications and standalone-module planning.

## What's here

```
docs/
├── specs/                # source-of-truth build specs (from Google Drive)
│   ├── BCB_Website_Backend_Master_Build_Spec.md
│   ├── BCB_Builders_Module_Spec.md
│   ├── BCB_Accounting_Module_Spec.md
│   ├── BCB_Dark_Mode_Spec.md
│   └── README.md
└── website-backend/      # active build: Website Backend
    ├── CHECKPOINT_0.md   # architecture & repository review  ← current state
    ├── DECISIONS.md      # architecture decision log
    ├── INTEGRATION_NOTES.md
    └── TEST_CHECKLIST.md

proposals/
└── checkpoint-4-raw-submissions/   # ready to review, NOT applied
```

## Current state

**Website Backend — Checkpoint 0 complete and revised. Checkpoint 1 gated on a
decision, not on a missing fact.**

The blocker that stopped Checkpoint 1 — *where is the existing BCB app?* — is
resolved. It is **`bcb94/bcb-command-center`** (private): Next 14 App Router as a
**static export**, React 18, Tailwind over CSS-variable tokens, Supabase
(Postgres 17 + RLS + Storage + Deno edge functions), deployed to Netlify by hand
with no CI. `CHECKPOINT_0.md` §§0–2, 5 and 6 are rewritten against it.

Three findings changed the plan:

1. **`output: 'export'` means there is no server.** Server-side permission
   checks live in RLS policies and edge functions, not route guards — so
   acceptance tests 1, 17 and 18 are written against Postgres, not middleware
   (DECISIONS D-008).
2. **A website intake pipeline is already in production.** `website-intake`
   already does the public form POST, an HMAC-verified Netlify Forms webhook,
   spam controls, lead creation, round-robin assignment and the team alert.
   Building §10/§11 as written would create a second path to the same table
   (D-009).
3. **The design-token system already exists**, and `BCB_Dark_Mode_Spec.md` is
   substantially already built (D-007).

The largest real gap is not the CMS — it is that the live pipeline **preserves no
raw submission and detects no duplicates**, which is what the spec repeats most
and what acceptance tests 8, 9, 10 and 11 are about.

### Open, in order

| | Question | Blocks |
|---|---|---|
| OPEN-6 | Build this module standalone here, or inside `bcb-command-center`? | any Checkpoint 1 code |
| OPEN-5 | Extend the live intake pipeline, or build a parallel one? | Checkpoint 4 |
| OPEN-4 | Where does `bcb.blue`, the marketing site, live? | Checkpoints 2, 7, 8 |

See `docs/website-backend/CHECKPOINT_0.md` § "Open questions".

### Ready to review

`proposals/checkpoint-4-raw-submissions/` closes the largest gap — a migration
and an edge-function change plan that make the live pipeline keep what the
customer actually sent. Additive, separately shippable, and **not applied**: it
carries a three-query preflight because it was written without live database
access. See its `README.md`.

## Starting a session

Per spec §32, at the start of every coding session:

1. Read `docs/specs/BCB_Website_Backend_Master_Build_Spec.md` in full.
2. Read `docs/website-backend/CHECKPOINT_0.md`, `DECISIONS.md`, `INTEGRATION_NOTES.md`.
2a. Attach `bcb94/bcb-command-center` and read its `CLAUDE.md` and
   `AGENT_HANDOFF.md`. The handoff explains most of the surprises that codebase
   produces — the RLS chain especially. Its *mechanisms* are current; its
   *counts* are stale (it says 32 migrations and 11 edge functions; there are
   now 90 and 72).
3. Identify the current checkpoint from `TEST_CHECKLIST.md`.
4. Implement only that checkpoint.
5. Test before moving on.
