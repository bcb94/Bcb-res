# Bcb-res

Blue Collar Built — build specifications and standalone-module planning.

## What's here

```
docs/
├── specs/                # source-of-truth build specs (from Google Drive)
│   ├── BCB_Website_Backend_Master_Build_Spec.md
│   ├── BCB_Builders_Module_Spec.md
│   ├── BCB_Accounting_Module_Spec.md
│   └── BCB_Dark_Mode_Spec.md
└── website-backend/      # active build: Website Backend
    ├── CHECKPOINT_0.md   # architecture & repository review  ← current state
    ├── DECISIONS.md      # architecture decision log
    ├── INTEGRATION_NOTES.md
    └── TEST_CHECKLIST.md
```

## Current state

**Website Backend — Checkpoint 0 complete, Checkpoint 1 blocked.**

Checkpoint 0 (spec §26) is done: architecture, module layout, the seven provider
contracts from spec §21, environment variables, and the three working files the
spec requires.

Checkpoint 1 is blocked on one question — **where is the existing BCB app?**
The spec refers throughout to its framework, styling system, auth model, database
conventions, and existing Leads/Team/Documents modules. None of that is in this
repository, which contained only a README before this work. The stack proposed in
`CHECKPOINT_0.md` §1 is therefore provisional and deliberately confined to the
edges of the architecture so it is cheap to replace.

See `docs/website-backend/CHECKPOINT_0.md` § "Open questions".

## Starting a session

Per spec §32, at the start of every coding session:

1. Read `docs/specs/BCB_Website_Backend_Master_Build_Spec.md` in full.
2. Read `docs/website-backend/CHECKPOINT_0.md`, `DECISIONS.md`, `INTEGRATION_NOTES.md`.
3. Identify the current checkpoint from `TEST_CHECKLIST.md`.
4. Implement only that checkpoint.
5. Test before moving on.
