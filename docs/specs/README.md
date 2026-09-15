# BCB Build Specifications

Source-of-truth build specs for Blue Collar Built, transcribed from Google Docs
into the repository so coding sessions can read them as files.

Each spec instructs Claude to read it at the start of every session; the website
backend spec (§33) names its filename directly. Keeping them in Drive alone made
that unreliable — see `../website-backend/DECISIONS.md` D-001.

| File | Scope | Entry point | Started |
|---|---|---|---|
| [`BCB_Website_Backend_Master_Build_Spec.md`](./BCB_Website_Backend_Master_Build_Spec.md) | CMS, public site, forms, lead intake for bcb.blue | Checkpoint 0 | **yes** — see [`../website-backend/`](../website-backend/) |
| [`BCB_Builders_Module_Spec.md`](./BCB_Builders_Module_Spec.md) | Builder-partnerships CRM (pipeline, opportunities, AI prospecting) | Phase 1 Foundation | no |
| [`BCB_Accounting_Module_Spec.md`](./BCB_Accounting_Module_Spec.md) | Bookkeeping, job costing, QuickBooks reconciliation, tax center | Milestone 1 Foundation | no |
| [`BCB_Dark_Mode_Spec.md`](./BCB_Dark_Mode_Spec.md) | Global light/dark theme tokens for BCB Command Center | n/a — extends the existing app | no |

## Drive sources

Re-transcribe rather than hand-patching when a Drive doc changes, and note it in
`DECISIONS.md`.

| Spec | Drive doc | File ID |
|---|---|---|
| Website Backend | "Bcb config" | `1-3saRtUXmpUtxBa06jMpeFEJAhT7YxNWCWYZYyJ5-IU` |
| Builders Module | "Bcb builder" | `1-BuCGq7DLqEhI0m8GYmnYs2vPNpAWZsVMyK9k_bbZEc` |
| Accounting Module | "Bcb accounting module" | `11YA2A07MGr8yhomM0Pgsz2E1tIoAhSy5izL49fAc7Fk` |
| Dark Mode | "ADD GLOBAL LIGHT / DARK MODE TO BCB COMMAND CENTER" | `14uSUaCzdscXLBIXL9VUmy9oeOv3-ASyOuG0ztbhsPzw` |

## Shared foundation

The three large specs each independently require authentication, a role/capability
model, file storage, notifications, an AI provider abstraction, and a design-token
system. Building those three separate times is the main avoidable cost across this
roadmap.

Whichever module ships first should own that foundation and expose it through
contracts. See `../website-backend/CHECKPOINT_0.md` OPEN-2 and
`../website-backend/INTEGRATION_NOTES.md` § "Cross-module overlap".
