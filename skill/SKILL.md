---
name: clarify-driven-development
description: Run software-engineering work under the CDD (Clarify-Driven Development) model from CDD-BOOT.md — clarify before building, emit a Understanding Acknowledgment (UA) gate before any artifact, write decidable acceptance criteria, freeze contracts, verify in a separate context, and persist decisions to CDD-STATE.md so they survive session death. Use ONLY when the user explicitly invokes CDD for a software project — "用 CDD", "按 CDD 开发", "走走流程", "CDD 流程", "用澄清驱动开发", or names CDD-BOOT.md / CDD-STATE.md. Do NOT auto-start for ordinary coding, editing, debugging, scripting, or non-software tasks.
whenToUse: Explicit invocation only. Applies when the user asks for CDD by name (or by the state-file pair) on a software project — a new project, a new feature, or a requirements change on work already under CDD. Not for ordinary coding, debugging, quick scripts, config edits, or non-software tasks; those proceed without this process.
metadata:
  version: "1.8"
  source: clarify-driven-development repository (CDD-BOOT.md v1.8)
  spec_copy: references/CDD-BOOT.md
---

# CDD — Clarify-Driven Development

CDD is a collaborative development model for an AI harness: **the agent clarifies before it
builds, and every decision must reach a file or it does not exist.** You are not a code
generator under CDD; you are a process partner with hard gates.

Invoked here: the user explicitly asked to run software engineering under CDD.

## The three rules that matter most

If you remember nothing else from the spec:

1. **Never treat unconfirmed content as settled.** You may write a `draft`; you may never treat
   it as `locked`, and you may not write implementation code before S3/S4 lock.
2. **Label every inference** `inferred`. Never present a guess as `confirmed`.
3. **Never push a decision back to the user without options.** "What do you want it to look
   like?" is forbidden. Give 2–4 options with costs plus your recommendation.

## Mechanism: rules must print

A rule with no observable output does not get executed under length pressure. These rules are
therefore expressed as **required output lines**. Omitting one is a protocol violation, not an
oversight.

| Line | When |
|---|---|
| `[COST GATE] ... → FULL CDD \| LIGHTWEIGHT` | your first substantive line, before anything else |
| `[FAST PATH CHECK] goal: y/n \| platform: y/n \| ≥3 ACs: y/n → fast path: y/n` | before emitting any UA |
| `[COST FILTER] HIGH: n \| MEDIUM: n \| LOW auto-decided: <list>` | before every question batch |
| `[REF RESOLVED] "<user's phrase>" → <exact item or file> \| confirm?` | before acting on an ambiguous reference |
| `[STAGE GATE] <from> → <to> \| ...` (one-liner only) | before writing any artifact **and** before any stage transition |
| `[INTERJECTION] defect \| new-req \| subjective \| change \| unclear → <action>` | the moment the user speaks mid-implementation |
| `[FITNESS REVIEW] performed <a\|b\|none> \| Critical: <n> \| Important: <n> \| Minor: <n>` | at S5 exit, with the verification result |

The spec's own list of six is the `[FAST PATH CHECK]`, `[COST FILTER]`, `[REF RESOLVED]`,
`[INTERJECTION]`, `[STAGE GATE]` and `[FITNESS REVIEW]` lines. `[COST GATE]` is added here because §2.0 requires
you to *state which mode you are using* before anything else, and that statement is otherwise
unobservable — it follows the repository's own documented form and is printed in its quickstart.

Print them every time. **Store them only when something was found** — see "findings vs
assertions" below. In lightweight mode these lines may be skipped (CDD-BOOT §2.0.1).

Also mandatory on every reply while CDD is active:

```
[CURRENT STAGE] <stage>
[LOCKED ARTIFACTS] <list; "none" if empty>
[THIS ROUND I WILL ASK] <question IDs, or "UA first">
```

## Stage machine

```
S0 Intake → S1 Requirements & Terminology → S3 Spec Lock → S4 Design → S5 Implementation → S6 Prototype Delivery
                                                ↑                                            │
                                                └──── S7 Incremental Alignment ◄─────────────┘
                                                                     ↓
                                                              S8 Rule Writeback          (S9 Release, optional)
```

| Stage | Lock (exit) condition | Artifact |
|---|---|---|
| S0 Intake | folds into S1 when the opening message carries the intent — do not add a round for its own sake | state file |
| S0.5 Structure Discovery | brownfield only (§1.3) | structure map |
| S1 Requirements & Terminology | user confirms UA-1, no pending items | `requirement.md` + `glossary.md` |
| S3 Spec Lock | user confirms UA-3, every AC decidable | `spec.md` |
| S4 Design | user confirms UA-4, three gates passed | `plan.md` + contracts |
| S5 Implementation | tests + static checks green, verification per §6 | code + tests + raw evidence |
| S6 Prototype Delivery | user actually ran it | `delivery-N.md` |
| S7 Incremental Alignment | feedback classified and converted into spec | updated spec |
| S8 Rule Writeback | every defect mapped to a rule addition | rule diff |
| S9 Release | **ask once**: does this need to run anywhere but your machine? If no → record "prototype only" and skip S9 entirely | release plan |

**Crossing stages is forbidden**: no implementation code before S3 locks; no S5 before S4 locks.
Rollback: requirement change → S1; ambiguous term → S1; untestable AC → S3; design flaw → S4;
feedback implying a new user story → S1.

## Boot sequence (run in order on invocation)

```
0. COST GATE (§2.0). Infer, do not ask a separate question:
   does this involve money, shared inventory/quota, or concurrent access to the same
   resource — i.e. could a bug cost real money or ~2 days of rework?
   Yes → FULL CDD. No → LIGHTWEIGHT (§2.0.1: one batch of ≤8 questions, short AC-only
   spec, implement + test + deliver, self-verification default). Say which and why in
   one line; the user will correct you if wrong.
1. Read CDD-STATE.md if one exists for this project.
   Absent → do NOT silently start from S0. Ask whether there is prior state or this is fresh.
   Present → report current stage, locked artifacts, open items.
2. Integrity check: compare recorded weak hashes (<sha256 first 12> or the
   chars/first/last form) against what you actually have. On mismatch, say so and ask which
   decisions changed — do not guess. Check the Findings Log is not discontinuous while
   artifacts are marked locked. Run scripts/cdd-hash.ps1 <artifact> to produce the hash.
3. Session re-anchor: state the top three confirmed decisions, one line each, and ask
   "anything changed in your thinking?" Cheap, and it catches mental-model drift.
4. Brownfield? If the repo already contains code, S0.5 applies — say so before asking
   requirements questions.
5. Print the [FAST PATH CHECK] line. If goal + platform + ≥3 concrete ACs are all present,
   you MUST write requirement.md immediately as `draft` and emit the UA in the same reply.
6. Emit the UA (§2.2 format). Stop and wait. Under the fast path the draft rides along with
   the UA; the draft is never authoritative.
7. Proceed one stage at a time after confirmation, reporting the stage header every reply.
```

## UA format (fixed)

```markdown
## UA-<n> <stage name> Understanding Acknowledgment

| # | My understanding | Source | Status |
|---|---|---|---|
| 1 | <a decidable statement> | confirmed / inferred | locked / pending / auto-decided |

### Needs your confirmation (affects downstream rework)
- Q1 <question>?
  Options: (a) <option and its cost>  (b) <option and its cost>  (c) I don't know, decide for me

### I decided these automatically (low impact — say so if you disagree)
- D1 <decision> — Reason: <one sentence>

**How to confirm**: reply "delete <number>, change <number> to <content>, rest is correct".
**Until you confirm, I will not LOCK <artifact>, and I will not write any code.**
```

**Never re-list confirmed items.** Between UAs show only `Changed: / Added: / Answered: /
Still open:`. Re-printing an answered table is the largest single source of confirmation
fatigue. If nothing changed, emit no UA at all.

## Question discipline

```
rework cost = blast radius × irreversibility
HIGH (must ask):  data model, external integration, state machine, billing, compliance,
                  platform capability limits
MEDIUM (should ask): module boundaries, interface shape, performance targets
LOW (decide yourself): naming, directory layout, code style, library versions
```

At most **8 questions per batch**, then stop and wait. Never chain batches. State why each
question is asked. Never ask what an existing artifact already answers.

**Safety net — nine categories that are never decided *silently***: auth/authorization; money
(pricing, rounding, refund, tax, currency); inventory/quota/occupancy semantics; idempotency
and duplicate submission; state machines; data retention and deletion; timezone/date
semantics; external contracts; platform capability limits. If one stays unanswered after two
asks, adopt a disclosed default using all four lines — the `isolation:` line is mandatory:

```
[SAFETY-NET DEFAULT] category: <which of the nine>
  decision: <the concrete decision, not "a reasonable default">
  isolation: <the single file or function that changes if this is later reversed>
  recorded: CDD-STATE.md → Defaults Awaiting Confirmation (marked "default, reversible, safety-net")
```

**Patience signals bind to a behavior change**, not to acknowledgment: "just decide" / "stop
asking" → adopt disclosed defaults for everything open and proceed; "I don't care" →
auto-decide that item and never raise it again; "keep going" → switch pacing to continuous;
"this is taking too long" → re-run the cost gate and drop to lightweight if low-cost;
"forget it" → stop, record state, do not argue. H6: ask the same question at most twice, then
default. H9: a disclosed default overrides the safety-net list — never deadlock.

## Abstract feedback → concrete (§2.6, mandatory)

When the user says "no polish" / "too slow" / "hard to use": **do not start editing, and do
not ask "what do you want it to look like?"** Decompose into ≤3 dimensions, give ≤2 concrete
options per dimension plus a mandatory third ("defer — judge from the next prototype"), state
the current state of each dimension, give one recommendation with a reason, and cap the turn
at 6 concrete choices. Put the rest under "not addressed yet".

## Implementation discipline (S5)

- **E1 pacing** — the pacing decision is made **once at S4**, not per task:
  (a) stop after each task, (b) run to the first runnable prototype then hand over [default],
  (c) stop at phase boundaries. Record it in the plan.
- **E2** test first, confirm it fails, then implement.
- **E3** done = commands actually executed, with raw output attached. "Tests pass" is not
  evidence. If you cannot run something, write `HARNESS UNAVAILABLE — manual check follows`.
- **E4** never modify or delete a passing test; changing one requires an explicit request.
- **E5** freeze contracts first; frontend and backend types are derived, never written twice.
- **E6** the pure-logic layer must not import IO. **E7** occupancy checks complete inside one
  transaction. **E8** new dependencies need name + reason + alternatives, confirmed first — that
  gates on *confirmation*, not on a bias against reuse. **Article 5.6: reusing a verified
  high-star implementation is the default**, and the written reason 5.1 asks for is the evidence
  (`<repo> (<stars>, <license>, <version/commit>)`). Do not screen with "we could have written it
  ourselves"; do screen on license, activity, maintenance and dependency weight.
- **E9** do not modify `.env*`, CI config, migration files, or production config without
  confirmation. **E10** report format: files changed / commands run / raw output / failures /
  open questions.
- If a locked task looks wrong: stop and say "Task T<k> as written conflicts with <AC or
  clause>. Confirm the change or amend the plan." Never deviate silently.

**E2 and E3 have operational detail in `references/upstream/`** (spec §5.3) — load
`test-driven-development/SKILL.md` before implementing, `writing-good-tests.md` before writing or
changing any test, and `verification-before-completion/SKILL.md` before claiming anything is done.
The annex is vendored verbatim from [obra/superpowers](https://github.com/obra/superpowers) (MIT).

**Scope rule that overrides the annex's letter on existing code**: its "write code before the
test? delete it" rule governs code *you* write in this session. Never delete pre-existing project
code to satisfy it. For existing untested behaviour, first pin it with characterization tests
observed to **pass**, then change behaviour under RED-GREEN-REFACTOR.

## Verification (S5 exit)

Mandatory when the project involves **money, inventory, quota, concurrent occupancy, auth,
permissions, or personal data**; otherwise a self-verification report suffices.

At S4, for a mandatory case, ask which path will actually be taken: (a) a clean session pasted
only with the four allowed items, or (b) the self-verification report. Record the answer —
**an unrecorded verification path is a FAIL regardless of what the tests say.**

Independence comes from what the verifier can see. Paste only: the locked ACs, the diff, the
raw test output, and the relevant plan/constitution clauses. Never paste conversation history,
your reasoning, your summary, or "I think this part is fine". The verifier must be the first
thing that session sees. The implementer must never declare success on its own.

**Ask the second question too.** The verifier above answers *"does it meet the ACs?"* — that is
not the same as *"is it fit to ship?"*, and an all-green AC verdict is not shippability. At S5
exit, optionally run a code-fitness review with `references/upstream/requesting-code-review/`
(template: `code-reviewer.md`): plan alignment, code quality, architecture, security, production
readiness, findings by severity. The review is **not mandatory** and has no trigger condition —
but reporting it is:

```
[FITNESS REVIEW] performed <a|b|none> | Critical: <n> | Important: <n> | Minor: <n>
```

`none` is a valid answer. Silence is not. If the review was done, Critical findings block the S5
exit exactly as a `violated` AC does, and Important findings are fixed or recorded as declined
with a reason. The §10 gate is deliberately unchanged — the printed line is the enforcement.

**Findings vs assertions (§0.2)** — print the required lines every time; persist only
findings. The test before writing anything into the state file: *"would a later session do
something differently because this line is here?"* If no, print it and move on. Never persist
a clean `[COST FILTER]` / `[FAST PATH CHECK]` / `[STAGE GATE]`.

## Brownfield (S0.5)

Map the existing structure, locate (or deny) the pure-logic layer, list external contracts
that must not break, list existing tests and how to run them, identify dependency directions
including violations, and propose constitution Articles 1 and 5 based on what **exists**, not
on what would be ideal. Do not propose a refactor unless asked — record the gap and continue.
Any change touching an existing contract needs its own UA. The first spec must include
"existing tests still pass" as a regression criterion.

## Where the work lives on disk

CDD is a file-based model: the artifacts are the deliverable's spine, and the chat is not
storage. **There is no state file in this session yet.**

**Location is undecided** — the user deferred it. Ask once, when a project actually starts,
and never invent a location. Recommended default: project root as
`<project>/CDD-STATE.md` + `<project>/specs/<NNN>/`, mirroring the upstream repository.

At project start, copy `references/CDD-STATE.md` from this skill to the chosen location (or run
`scripts/cdd-init.ps1`). **A blank
state file with `Current stage: S0 Intake` is genuine unknown state, not a silent reset** —
say so, and confirm the top decisions rather than starting fresh.

Project layout once initialized:

```
CONSTITUTION.md          global, persists across features — never create a second one
requirement.md           T1
glossary.md              T2
specs/001/spec.md        T3
specs/001/plan.md        T4
specs/001/contracts/
specs/001/verification.md
specs/001/delivery-1.md  T5
CDD-STATE.md             T6, the memory hub — update on every transition
CDD-HISTORY.md           created only by the archive rule
```

**Archive rule (enforce it, it was ignored in real use)**: when the state file passes 400
lines or 10 sessions, move older Findings Log rows, older Confirmed Decision rows, older
Rejected Options rows, and Session History beyond the last three into `CDD-HISTORY.md`. Never
delete history — archive it.

**End of session**: emit the full updated state file only when the user says they are ending
the session, when a stage transition completes, or when asked; between those moments say
"recorded" without reprinting. Then tell the user to save it — it is the only memory.

## Reference files

| File | Load it when |
|---|---|
| `references/CDD-BOOT.md` | **the authoritative specification — read it before running S1 questions or writing any artifact.** Stages, hard constraints, artifact templates T1–T6, question bank A–H, anti-patterns, full stage-gate checklist |
| `references/CDD-STATE.md` | the canonical empty state-file template (T6) — copy it per project |
| `references/CONSTITUTION.md` | drafting the project constitution (Part 2 of the spec, pre-filled template) |
| `references/example-project/` | you want a worked example of a real CDD project's artifacts (Android cleaner, 197 tests, 18 rounds) |
| `references/upstream/` | **vendored verbatim — never edit these.** The operational detail behind E2/E3 and §6.5: `test-driven-development/` (RED-GREEN-REFACTOR + `writing-good-tests.md`), `verification-before-completion/`, `requesting-code-review/` (with the `code-reviewer.md` dispatch template). Provenance, pinned commit, hashes and the brownfield scope rule are in its `README.md` |
| `scripts/cdd-hash.ps1 <path>` | locking an artifact — produces `<sha256 first 12>` for the register |
| `scripts/cdd-init.ps1 -Project <dir>` | scaffolding a project: constitution, empty state file, specs dir |

This bundle is a **mirror** of the upstream CDD repository
(`github.com/uhygyuf/clarify-driven-development`, v1.8). If the user says the CDD spec has a
newer version, re-sync rather than editing `references/` in place. `references/upstream/` is a
mirror of a mirror — it is vendored from `obra/superpowers`, not from the CDD repository.

## Anti-patterns checked at every stage gate

| Anti-pattern | Violates |
|---|---|
| Writing or locking an artifact before confirmation | H3 |
| Presenting an inference as confirmed | H2 |
| Declaring tests passed without raw output | E3, §6 |
| Reporting AC-green as release-ready without saying whether a fitness review ran | §6.5 |
| Silently absorbing a new requirement into the current implementation | §4 |
| Auto-deciding a safety-net item without the isolation line | §2.4 |

The full 17-item reference is in the spec's §9.1. Consult it when something feels wrong; do
not try to hold it in working memory.
