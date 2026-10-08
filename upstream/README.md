# `upstream/` — vendored annex

These five files are **not written by CDD**. They are verbatim copies of skills from
[obra/superpowers](https://github.com/obra/superpowers), MIT licensed, pinned to one commit.

| Field | Value |
|---|---|
| Source | `https://github.com/obra/superpowers` |
| Commit | `8ca22dba9a94f28898bbce59f2537ff4d87c747d` (short: `8ca22db`, 2026-09-25) |
| Upstream path | `skills/<name>/…` |
| Local path | `upstream/<name>/…` (identical relative layout — re-sync is a copy, not a merge) |
| License | MIT (upstream `LICENSE`) |
| Verified | All five files SHA256-identical to that commit. Re-verify by cloning upstream at the pinned SHA and comparing hashes, not sizes. |

**Do not edit these files.** They are a mirror. If CDD needs different behaviour, change CDD's
own text (Part 1 or the constitution template) and say why — never patch the vendored copy,
because the next re-sync silently reverts it.

## Which CDD clauses each file backs

| File | Backs | Load it when |
|---|---|---|
| `test-driven-development/SKILL.md` | §5.3, E2, Article 6.1 | implementing anything under S5 |
| `test-driven-development/writing-good-tests.md` | §5.3 | writing or changing any test |
| `verification-before-completion/SKILL.md` | §5.3, E3, §6.5, Article 6.3 | about to state that anything is done, fixed, or passing |
| `requesting-code-review/SKILL.md` | §6.5 | dispatching the code-fitness review |
| `requesting-code-review/code-reviewer.md` | §6.5 | the prompt template for that review |

## The one place upstream contradicts CDD's situation — read this before applying TDD

`test-driven-development` states, deliberately and in capitals:

> Write code before the test? Delete it. Start over. … **Delete means delete.**

That rule assumes a **greenfield** task, where every line under discussion was written in the
current session. CDD is explicitly brownfield-aware (§1.3, S0.5), and a finished project handed
to CDD already contains production code that predates every test.

**Applying the rule literally to pre-existing code would delete the project.** So:

- The delete-and-restart rule governs **code written in this session**.
- For **pre-existing untested behaviour**, first pin the current behaviour with characterization
  tests that are observed to **pass** against the code as it stands. Those do not start red —
  they cannot, because the behaviour already exists and is presumed correct until an AC says
  otherwise. Only after a behaviour is pinned may it be changed, and that change follows the
  normal RED-GREEN-REFACTOR cycle.

This scoping is CDD's, not upstream's. It is recorded here so that a later session does not read
the vendored file and conclude that CDD endorses deleting the codebase.

## Re-syncing

```sh
git clone --depth 1 https://github.com/obra/superpowers.git /tmp/superpowers
git -C /tmp/superpowers rev-parse HEAD          # record the new SHA in the table above
cp -r /tmp/superpowers/skills/<name> upstream/<name>
```

Then update the commit in the table, re-verify each hash, and append a row to the version log in
`CDD-BOOT.md`. A new upstream commit that changes a skill's **behaviour** is a CDD change and
needs its own reason in the version log — not just a copy.
