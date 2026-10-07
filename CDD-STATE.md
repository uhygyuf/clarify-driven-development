# CDD-STATE.md — Project State

> This file is the memory hub across sessions. **Update it immediately after every stage transition, every required output line, and every artifact change.**
> From session 2 onward: paste this file together with `CDD-BOOT.md` and the agent can pick up where it left off.
>
> **Durability rule**: a later session can only trust what reached this file. But record **findings**, not assertions — see the Findings Log below and CDD-BOOT.md §0.2. Storing every printed line was measured and it made this file unusable.
>
> **Growth rule**: never delete history — **archive** it. Past 400 lines or 10 sessions, move the older material into `CDD-HISTORY.md`. See the Archived History section below; this rule was ignored in real use and must be enforced.
>
> **What this file cannot do**: it cannot detect that the user edited or omitted rows. It is the only record, and it is trusted. If you have reason to suspect it is incomplete, say so and re-confirm the top decisions rather than proceeding silently.

---

## Current State (live)

| Item | Value |
|---|---|
| Current stage | **S0 Intake** |
| Cost gate mode | full CDD / lightweight (decide at §2.0, record it) |
| Last updated | — |
| Blockers | none |
| Next action | Output UA-1 (S0 folds into S1 unless the intent is too vague to write any items) |
| Integrity warning | none |

---

## Session Configuration (live)

> Decisions that govern *how* the work happens rather than *what* is built. A later session cannot re-derive these, so they must be written down.

| Setting | Value | Decided in | Notes |
|---|---|---|---|
| Cost gate mode | — | S0 | full CDD / lightweight (§2.0) |
| Fast-path result | — | each UA | the three yes/no values from `[FAST PATH CHECK]` |
| Pacing decision | — | S4 | (a) per task / (b) to first prototype / (c) phase boundaries (§5.1) |
| Verification mandatory? | — | S4 | yes/no, and why (§6.1) |
| Verification path | committed / performed | S4, S5 exit | (a) clean session / (b) self-verification / none (§6.2) |
| Refactor or match existing structure | — | S0.5 | brownfield only (§1.3) |

---

## Artifact Register (live)

> status: `not started` / `draft` / `pending confirmation` / **`locked`** / `expired`
> **Only artifacts marked `locked` may serve as input downstream.**
> **Integrity**: when you lock an artifact, record its size and a weak hash. On any later session, if the pasted artifact does not match, stop and say so before using it.
> **Uniform weak hash** (use exactly this form so records are comparable across sessions): `<sha256 first 12 hex chars>` if a hash tool is available, otherwise `chars=<n>;first=<first 40 chars>;last=<last 40 chars>`. State which form you used.

### Feature index

> One row per feature. The register below is per-feature; copy the block for each new feature number. Never reuse a number.

| Feature | Directory | Status | Opened | Closed | One-line goal |
|---|---|---|---|---|---|
| 001 | `specs/001/` | not started | — | — | — |

### Register — feature 001

| Artifact | Path | status | Locked at | Upstream dependencies | Weak hash |
|---|---|---|---|---|---|
| Project constitution (global) | `CONSTITUTION.md` | not started | — | — | — |
| Requirements doc | `requirement.md` | not started | — | constitution | — |
| Glossary | `glossary.md` | not started | — | requirements doc | — |
| Feature spec | `specs/001/spec.md` | not started | — | requirements doc, glossary | — |
| Technical plan | `specs/001/plan.md` | not started | — | feature spec | — |
| Contracts | `specs/001/contracts/` | not started | — | technical plan | — |
| Verification report | `specs/001/verification.md` | not started | — | technical plan | — |
| Delivery note | `specs/001/delivery-1.md` | not started | — | verification report | — |

> **Constitution scope**: `CONSTITUTION.md` is global and persists across features. A new feature after S9 re-enters at S1 with the **same** constitution — do not create a second one. Amend it via Article 8 if a feature genuinely needs different rules.
>
> **Partial progress inside a continuous run**: the plan's task list is not enough. Record which task was last completed in the Artifact Register notes or in Session History, or a later session will restart the plan from task 1.

---

## Findings Log (live)

> **Only findings go here — decisions, rejections, violations, defects, transitions.** Not assertions.
>
> An earlier version of this file required every required output line to be appended verbatim. Real use produced ~290 lines / ~43,000 characters of log with no reader, and grew this file past 105,000 characters. The rule is now: **if a later session would not do something differently because of the line, do not append it.**

| Type | What | Why it matters later | Date |
|---|---|---|---|
| deviation / anti-pattern / defect / decision / rejection / transition | — | — | — |

> Print `[COST FILTER]`, `[FAST PATH CHECK]`, `[REF RESOLVED]` and the §10.3 `[STAGE GATE]` one-liner in the chat **every time** — that is what keeps them executed. Store them **only when something was found.**

---

## Archived History

> **Enforce this. It is the only thing standing between you and an unpasteable file.**
>
> When this file passes **400 lines** or **10 sessions**, move the older material into `CDD-HISTORY.md` (create it): Findings Log entries older than the last session, Confirmed Decision Log rows older than the current feature, Rejected Options older than the current feature, and Session History rows beyond the last three. Keep the live tables and the row below.
>
> In real use this rule existed in v1.5 and was **never executed** — the file reached 634 lines. A rule nobody runs is not a rule (§0.1).
>
> Paste order once it exists: `CDD-BOOT.md` → `CDD-STATE.md` → `CDD-HISTORY.md` (the last only when a "why did we decide X" question needs it).

| Archive file | Covers sessions | Archived on |
|---|---|---|
| `CDD-HISTORY.md` | not yet created | — |

---



## Confirmed Decision Log

> Anything the user has confirmed must not be changed by a later session without their say-so.

| # | Decision | Basis (user's words or UA number) | Blast radius | Time |
|---|---|---|---|---|
| — | — | — | — | — |

---

## Pending Confirmation Queue

> Must be empty at the end of every round, or explicitly labeled "handled by default".

| # | Item pending confirmation | Cost | Times asked | Status |
|---|---|---|---|---|
| — | — | — | — | — |

---

## Open Questions

| # | Question | Raised in stage | What it blocks | Status |
|---|---|---|---|---|
| — | — | — | — | — |

---

## Change Request Queue (S7 input)

> All user feedback after a prototype delivery enters this queue. **It must never be acted on directly.**

| # | Raw feedback | Classification | Converted into | Status |
|---|---|---|---|---|
| — | — | defect / new requirement / subjective evaluation / change / unclear | AC number or new feature | — |

---

## Rule Writeback Log (S8)

| # | Defect | Missing kind | Where added | Applied |
|---|---|---|---|---|
| — | — | unclear semantics / missing executable constraint / missing criterion / missing environment capability | — | — |

---

## Scope Freeze Log

> Report at every S3 lock and every return to S1. See CDD-BOOT.md §1.2.

| Lock | Total user stories | Added since last lock | Traced to original goal? | Out-of-scope list changed? |
|---|---|---|---|---|
| — | — | — | — | — |

---

## Overturned Artifacts

> When the user reverses a locked decision. See CDD-BOOT.md §1.1. Never delete rows.

| # | Artifact overturned | Decisions discarded | Downstream marked expired | Reason | Date |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

---

## Defaults Awaiting Confirmation (live)

> Reversible defaults adopted under H6, including safety-net items resolved under H9. Surface these at the next prototype, not in the next question batch.
> **`Isolation path` is mandatory and must be copied verbatim from the printed `[SAFETY-NET DEFAULT]` line.** Without it, a later session cannot find where to reverse the decision and must search the codebase or guess.

| # | Category (of the nine?) | Default adopted | Isolation path (file or function) | Surfaced at | Reversed? |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

---

## Rejected Options (live)

> Options the user was offered and declined. Record them so a later session does not re-propose a choice the user already turned down. This list is what makes the process feel like it remembers.

| # | Option declined | Where offered | Stage | Date |
|---|---|---|---|---|
| — | — | — | — | — |

---

## Constitution Conflicts (live)

> Resolutions under CDD-BOOT.md Article 9. A generic decision-log row is not enough; the choice determines whether the constitution text changed.

| # | Article | What the user wanted | Option chosen (a/b/c) | Article amended? | Date |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

---

## Independent Verification (live)

> Decided at S4, recorded in Session Configuration. Kept here as the single place a later session checks before allowing S5 to exit. See CDD-BOOT.md §6.1, §6.2.

| Mandatory? | Committed | Actually performed | Evidence location | Date |
|---|---|---|---|---|
| — | (a)/(b)/none | (a)/(b)/none | — | — |

> If `committed` is (a) and `performed` is not (a), S5 may not exit. If `performed` is `none`, the verification report does not exist and the ACs are unverified — say so in the delivery note rather than implying otherwise.

---

## Release Status (live)

> S9 is skipped entirely when the answer is "prototype only".

| Runs beyond dev machine? | Build command | Where it runs | Rollback steps | Recorded |
|---|---|---|---|---|
| — | — | — | — | — |

---

## Session History (keep the last 3 rows here; archive the rest)

| Session | Stage | Output | Artifacts locked | Last completed task | Open items |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

> **`Last completed task`** exists because continuous pacing (b) leaves no other progress trace. Without it, a later session restarts the plan from task 1.

