# CONSTITUTION.md — Project Constitution

> **Scope**: global and persistent across features. A new feature after S9 re-enters at S1 with
> the **same** constitution — do not create a second one. Amend via Article 8 if a feature
> genuinely needs different rules.
>
> **Rules for this file** (CDD-BOOT.md Part 2): write only principles that **can be checked or
> explicitly declared**. No slogans. Keep it under one page. Any clause that cannot be checked
> automatically must say `verified by human review`.
>
> This is the template. Replace every `<...>` placeholder; delete Articles that genuinely do not
> apply and say why in the amendment log rather than leaving them as dead text.

---

## Article 0: Project Identity

| Item | Content |
|---|---|
| Project name | `<TBD>` |
| One-sentence goal | `<TBD>` |
| Target platform | `<Web / Android / iOS / Desktop / CLI / Server>` |
| Primary users | `<TBD>` |
| Data sensitivity | `<public / internal / contains personal data / contains payment data>` |

---

## Article 1: Architecture Boundaries

> Brownfield note (§1.3): propose these based on what **exists**, not on what would be ideal,
> and note where the current code violates the proposal. Do not propose a refactor unless asked.

- **1.1** The pure logic layer (`<directory>`) must not import databases, HTTP clients,
  framework APIs, or UI frameworks. *Check: architecture test.*
- **1.2** Dependency direction is one-way: `UI → application → domain`. Reverse dependencies are
  forbidden. *Check: architecture test.*
- **1.3** The UI layer must not access the database or external services directly; it goes
  through the application layer. *Check: architecture test + code review.*
- **1.4** Do not introduce new architectural layers or abstraction layers without confirmation.
  *Check: human review (S4 gate).*

---

## Article 2: Data Consistency

- **2.1** Money is stored only as integer minor units. Floating point is forbidden.
  *Check: type constraints + architecture test.*
- **2.2** Rounding rules must be explicitly defined and implemented in exactly one place.
  *Check: unit tests covering rounding boundaries.*
- **2.3** Any check involving resource occupancy (inventory, balance, quota, unique slots) must
  complete within a single transaction. Read-then-write is forbidden. *Check: concurrency test.*
- **2.4** Every repeatable write operation must define an idempotency key.
  *Check: contract + idempotency test.*
- **2.5** Entity states and legal transitions must be listed explicitly. Illegal transitions must
  return an error, never be silently ignored. *Check: state machine test.*

---

## Article 3: Time Semantics

- **3.1** Plain dates use timezone-free DATE semantics. Timestamps must carry an explicit
  timezone. *Check: type constraints + schema check.*
- **3.2** Any cross-timezone scenario must state which timezone the business operates in,
  recorded in the glossary. *Check: human review.*
- **3.3** Domain-layer time access must be injectable. Calling the system clock directly is
  forbidden. *Check: unit test with an injected fixed clock.*

---

## Article 4: Security and Boundaries

- **4.1** Sensitive paths must not be modified without confirmation: `.env*`, CI config,
  migration files, production config, signing keys. *Check: write allowlist.*
- **4.2** Keys and tokens are read from environment variables only. Never written into code or
  committed. *Check: secret scanning.*
- **4.3** All external input must be validated; all output must be escaped for its context.
  *Check: validation layer + tests.*
- **4.4** Authorization must be enforced server-side. Hiding things in the client is UX, not
  security. *Check: privilege-escalation API tests.*
- **4.5** Personal-data fields must be listed with their storage and display rules.
  *Check: human review.*

---

## Article 5: Complexity Ceiling

- **5.1** Do not add dependencies without a written reason. Every new dependency must be listed
  in the plan with name, reason, and alternatives. *Check: S4 gate.*
- **5.2** Do not introduce an abstraction layer or interface without ≥2 real consumers.
  *Check: S4 gate + human review.*
- **5.3** No speculative features. Every feature must trace to at least one user story.
  *Check: S4 gate.*
- **5.4** No file exceeds `<N>` lines; no function exceeds `<M>` lines. *Check: linter.*
- **5.5** Frontend and backend type definitions must be derived from the contract. Writing them
  twice is forbidden. *Check: contract consistency test.*
- **5.6** Reuse of a verified high-star implementation is the **default**, not an exception that has
  to be justified. 5.1's written reason is satisfied by the evidence — `<repo> (<stars>, <license>,
  <version/commit>)` and why it beat the alternatives. Two symmetric errors to avoid: "we could have
  written it ourselves" is not a reason to reject a dependency, and "it saved us code" is not a
  reason to accept one. Screen on four things before adopting: license (MIT/Apache-2.0 usable as-is;
  GPL / none / custom is the user's decision), activity (pushed within ~6 months — a dormant repo is
  a reference implementation to read, not a dependency to take), maintenance (issues and PRs are
  answered), dependency weight (pulling in a tree for one function is worse than writing the
  function). *Check: S4 gate.*

---

## Article 6: Testing and Verification

- **6.1** Test-first: write the test, confirm it fails, then implement.
  *Check: commit order review.*
- **6.2** Passing tests must not be deleted or skipped (ratchet). Changing one requires an
  explicit request. *Check: CI comparison + human review.*
- **6.3** Verification must run in an independent context. The implementer must never declare
  success. *Check: process enforcement.*
- **6.4** Acceptance criteria that cannot be automated must be explicitly flagged as manual
  acceptance items. *Check: S3 checklist.*

---

## Article 7: Project-Specific Clauses

> Filled in after S1 clarifies requirements. Directions: compliance, offline capability, i18n,
> accessibility, performance ceilings, data retention, third-party constraints.
>
> Brownfield work adds clause **7.x "existing external contracts must not break"** (§1.3).

- **7.1** `<TBD>`

---

## Article 8: Amendment Process

1. Propose the amendment: state the reason and the list of affected artifacts.
2. User confirms.
3. Update this file and append a row to the amendment log.
4. Mark all affected downstream artifacts as expired.

| Date | Clause | Change | Reason | Affected artifacts |
|---|---|---|---|---|
| — | — | — | — | — |

---

## Article 9: When the User Insists on Something This Constitution Forbids

Saying no forever and quietly complying are both wrong. Do this instead, in order:

```
1. Print the conflict plainly:
   [CONSTITUTION CONFLICT] Article <n> forbids <what>. You are asking for <what>.

2. Print the impact table:
   | What breaks | How you would find out | Cost to undo later |
   (be concrete — "money rounding drifts in reports", not "quality suffers")

3. Offer exactly three options:
   (a) Do it anyway; I amend Article <n> and record why. — fastest, and the
       constitution stays honest.
   (b) Do it behind an explicit exception that I record in the plan, leaving
       the article intact. — use when it is genuinely one-off.
   (c) Don't do it; find another way. — give one alternative if you have one.

4. Do nothing until the user picks. Then record the choice in the state file's
   confirmed-decision log with the date and the reason.
```

**Never silently violate the constitution**, and never refuse without offering (a). The
constitution exists to make the cost of deviation visible, not to win the argument. A user who
repeatedly picks (a) is telling you the article is wrong — say so.
