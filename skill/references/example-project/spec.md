> **Worked-format example, not a verbatim original artifact.** Reconstructed from the CDD repository's field
> evidence for v1.6 (an Android rogue-software cleaner for an elderly user's phone; 18 rounds; 197 passing
> tests; device-verified in two locales) and written to CDD-BOOT.md Part 3, template **T3**. Wording is the
> template's, not the original project's. **Status is shown as `locked` because that is the state T3 expects
> at spec lock; here it is illustrative** — the original project's files are not in this repository. Upstream:
> `requirement.md` v1.3 in this folder; the glossary is referenced, not reproduced.

# spec.md — 001 Removal detection, confirmed purge, and outcome recording

## 1. Metadata

| Field | Value |
|---|---|
| Feature number | 001 |
| Feature name | Removal detection, confirmed purge, and outcome recording |
| Related user stories | US-1, US-2, US-3, US-4, US-5, US-6 (US-7 deliberately excluded — see §4 N-1) |
| Upstream requirements version | `requirement.md` v1.3 |
| Upstream glossary | `glossary.md` v1.3 |
| Status | `locked` (illustrative — see the note above) |

## 2. Goal

- **One-sentence goal**: an approved app that the owner removes is detected on the owner's own device, completed by one owner confirmation tap, and closed with a terminal recorded outcome.
- **Why now**: the owner's phone already carries unwanted apps, and the last irreversible step of removing one currently has no safe single-tap path and leaves no record that it happened.
- **What the user can do when done**: the owner removes one approved app by confirming one dialog and reads a plain line afterwards saying it is gone; the maintainer reads, without technical tooling, whether every attempt ended and how.
- **Explicitly out of scope**: restore or reinstall of a removed app (a record is kept, nothing more); deciding which apps are unwanted; removing anything without the owner's confirmation; a second device, a server, or any network function; Android versions other than the tested one.

## 3. Acceptance criteria

Given / when / then, each with its verification method and priority. `automated` = a test in the suite; `device` = end-to-end on the owner's real phone; `manual` = a person observes. **The set below is consistent with the device finding that on Android 15 `ACTION_PACKAGE_ADDED` is never delivered (four clean trials, zero log lines) while `ACTION_PACKAGE_CHANGED` arrived 3/3: no criterion here requires `ACTION_PACKAGE_ADDED`, and no criterion below may be accepted on unit tests alone.**

### 3.1 Detection

- **AC-1.1** (P0 · device): Given an approved package is present and the app is watching, when that package is removed, then the attempt is detected and closed as `PURGED` with no person reporting anything.
- **AC-1.2** (P0 · device, four clean removal trials + architecture test on the trigger path): Given the app is watching and an approved package is removed, when this happens in four clean trials on Android 15, then every trial is detected, the signal named in the log is `ACTION_PACKAGE_CHANGED`, and `ACTION_PACKAGE_ADDED` appears in zero lines and feeds no decision.
- **AC-1.3** (P0 · automated + device): Given an approved package is changed but still installed (an update or a permission change), when the change is observed, then no removal is attempted and the attempt ends `FAILED`, never `PURGED`.
- **AC-1.4** (P0 · automated on a fixed device snapshot + device): Given the app was not watching when an approved package disappeared, when the app starts, then within one pass an attempt exists for it and is closed as `PURGED`.

### 3.2 Confirmation and purge

- **AC-1.5** (P0 · device, Chinese and English locales): Given the system's uninstall confirmation dialog for an approved package is on screen, when the owner taps the confirmation button, then the evidence line `★识别到卸载框 … 按钮=确定` is present and the attempt is `PURGED` — in both locales.
- **AC-1.6** (P0 · automated): Given that dialog is on screen, when no owner tap occurs, then nothing is removed and no terminal status is written; the attempt stays `INCOMPLETE`.
- **AC-1.7** (P0 · automated + device observation): Given the app has identified a confirmation button, when the confirmation step runs, then the app taps nothing itself — the tap that completes the removal is reachable only from an owner action.

### 3.3 Outcome recording and backfill

- **AC-1.8** (P0 · automated): Given an attempt whose package is gone from the device, when the attempt closes, then its status is `PURGED` and it is never left as `INCOMPLETE`.
- **AC-1.9** (P0 · automated, with the counterexample the self-verification report requires): Given the same case, when the outcome-backfill step is commented out, then at least one automated test fails; that test is shown red with the step disabled and green with it restored.
- **AC-1.10** (P0 · automated on a fixed snapshot + device): Given a stored attempt whose status is `INCOMPLETE` and a snapshot in which its package is no longer installed, when the app starts, then the status becomes `PURGED` within one pass and the record names the check that produced it.
- **AC-1.11** (P0 · automated): Given the same case but a snapshot in which the package is still installed, when the app starts, then the status does not become `PURGED`.

### 3.4 Invalid input and refusal

- **AC-1.12** (P0 · automated): Given a removal report for a package that no rule-library entry names, when it is processed, then an explicit error is recorded and there are no side effects — no attempt is created, nothing is removed, no screen is acted on.
- **AC-1.13** (P0 · automated, with the substituted input): Given a proposed rule-library entry whose attached evidence is not acceptable, when the library is generated, then generation ends with an explicit error and no library is written; a forum post substituted as evidence was rejected by that same check.
- **AC-1.14** (P0 · automated on captured screen text + device observation): Given a screen whose text does not match the expected uninstall-dialog pattern for the current locale, when it is inspected, then an explicit error is recorded and no tap is issued.

### 3.5 Idempotency and concurrency

- **AC-1.15** (P1 · automated, duplicate submission with the same key): Given an attempt already closed as `PURGED`, when the same removal is reported again, then no new record is created and the stored result is unchanged.
- **AC-1.16** (P1 · automated, two reports submitted simultaneously): Given two reports of the same removal submitted at the same time, when both are processed, then exactly one terminal record exists and exactly one outcome write is counted.

### 3.6 Boundaries and precision

- **AC-1.17** (P1 · automated, precision): Given rule-library entries `com.a.b` and `com.a.bc`, when `com.a.bc` is removed, then only the `com.a.bc` entry matches — a package name matches whole and never as a prefix.
- **AC-1.18** (P1 · automated, precision): Given a removal reported with a package name differing from the entry only in letter case or trailing whitespace, when it is matched, then it is refused as unknown, with an explicit error and no side effects.
- **AC-1.19** (P1 · automated, boundary — repeated reconciliation): Given an attempt opened and never confirmed, when the app starts twice with no package change in between, then the status after the second start is identical to the status after the first.

### 3.7 Regression

- **AC-1.20** (P0 · automated, ratchet): Given the delivered change set, when the full suite runs, then zero tests fail (197 passing at delivery) and no previously passing test has been removed or skipped.

## 4. Non-decidable items

Kept out of §3 entirely.

| ID | Content | Acceptance method | Handling process (§2.6) |
|---|---|---|---|
| N-1 | whether a removed app can be put back — proposed as a P0 criterion, still unimplemented | none: no definition of "restore" exists, so no predicate can be written | deferred to D-2; the release keeps only a record (E4) and the delivery states that recording a location is not supporting restore — it is not claimed |
| N-2 | who may write the rule library (amendment C-1) | not testable; it is a rule about authority, not behavior | raised as a constitution amendment rather than patched silently; until ruled, no runtime part writes the library (BR-10 proposed) |
| N-3 | whether dialog detection holds on device makers other than the tested one | only one device is available and no fixture exists | recorded as an evidence limit; every claim stays marked device-specific |
| N-4 | the wording and tone of the owner's screen in a locale other than Chinese or English | no speaker of such a locale is available to judge it | the language shown stays open (D-4); the part that *is* testable — never guessing dialog text — is AC-1.14 |

## 5. Non-functional requirements (feature-specific)

| Category | Requirement | Verification method |
|---|---|---|
| Latency | detection within 30 s while watching | device end-to-end timing |
| Language | this feature's strings exist in Chinese and English and print the same marker | device end-to-end in both locales |
| Privacy | no information about the owner's apps leaves the device; no network use in this feature | architecture test |
| Size | the signed release build stays within 5 MB (delivered: 4.57 MB) | build output |
| Regression | full suite zero failures; no passing test removed or skipped | run the suite, attach raw output |

## 6. Business rules involved

BR-1, BR-2, BR-3, BR-4, BR-5, BR-6, BR-7, BR-8, BR-9, and BR-10 *(proposed, pending D-3)*. Not restated here.

## 7. Terms involved

Defined in `glossary.md`, not repeated here: removal attempt · terminal status · `PURGED` · `FAILED` · `INCOMPLETE` (never a final answer) · rule-library entry · approved package · confirmation tap · evidence marker.

## 8. Open questions

| ID | Question | Blocks | Status |
|---|---|---|---|
| D-2 | What must "restore" mean, and is it in scope? | whether scope 002 exists at all | open — carried from `requirement.md` §9 |
| D-3 | Which component may write the rule library (C-1)? | whether BR-10 is checkable | open — carried from `requirement.md` §9 |
| D-4 | Must a locale beyond Chinese/English be supported? | the last row of the exception table | open — no dialog text is guessed meanwhile |
| Q-1 | Is a second device available for dialog-matching evidence? | the strength of every N-3 claim | open; recommended default: test only the available device, and say so |
| Q-2 | Is 30 s the right detection ceiling for the owner's expectations? | the latency requirement | default adopted: 30 s, reversible — isolation: the single place that sets the check interval |

## 9. Conversion log for non-decidable items

| Original feedback | Dimensions decomposed | Option chosen | Which AC it became |
|---|---|---|---|
| "I should be able to get a removed app back" | (1) what is kept after a removal, (2) what may be done afterwards, (3) who may trigger it | keep a record only; defer any action to D-2 — no promise is made | none yet; AC-1.8 covers only the record's terminal status |
| "it must not remove anything I didn't approve" | (1) where authority is written, (2) who may write it, (3) what happens on a miss | the rule library is the sole authority; a miss is refused with an explicit error | AC-1.12; BR-10 proposed for (2) → N-2 |
| "the app missed the removal on my phone" | (1) which platform signal is reliable, (2) what happens if it never arrives, (3) whether unit tests can see it | re-base the trigger on `ACTION_PACKAGE_CHANGED`; reconcile at start; accept that only device testing can see it | AC-1.2, AC-1.4 |
| "records still say `INCOMPLETE` although the app is gone" | (1) who writes the final status, (2) when, (3) how it is proven to matter | backfill at start, plus a test that must go red when the backfill step is removed | AC-1.9, AC-1.10, AC-1.11 |
