> **Worked-format example, not a verbatim original artifact.** This file was reconstructed from the CDD
> repository's field evidence for v1.6 — a solo developer who built an Android rogue-software cleaner for
> an elderly user's phone over 18 rounds / two days — and written to the section order of CDD-BOOT.md
> Part 3, template **T1**. The wording is the template's, not the original project's. Details the evidence
> does not determine are kept generic and deliberately minimal. Its companion `spec.md` is in this folder;
> the glossary it references is not reproduced here. WHAT and WHY only.

# requirement.md — Rogue-app cleaner for one elderly user's phone

Version 1.3 · drafted in S1, re-locked after each change-log row below

## 1. Overview

- **One-sentence description**: an app that lets an elderly owner remove unwanted apps from their own phone by confirming a single dialog, and that tells the maintainer afterwards what actually happened.
- **Problem being solved**: the owner cannot judge which apps are unwanted, and the system's own confirmation dialog is the last irreversible step — a wrong tap either removes something needed or leaves the unwanted app in place. The maintainer is not present for every removal and cannot read a technical log to find out what happened.
- **Success criteria**: (a) an approved app is removed with one owner tap and the attempt ends in a terminal recorded outcome; (b) detection works on the owner's actual device, not only in tests; (c) nothing outside the maintainer's written list can ever be removed; (d) every owner-facing string exists in Chinese and English; (e) the full test suite passes with zero failures.
- **Explicitly out of scope**: restoring or reinstalling a removed app (only a record is kept — §9 D-2); deciding by itself which apps are unwanted; removing anything without the owner's confirmation; a second device, a server, or any network function; Android versions other than the owner's device.

## 2. Roles and scenarios

| Role | Description | Core scenarios |
|---|---|---|
| ROLE-1 Phone owner | elderly, non-technical, prefers Chinese and may also use English; owns the device and the decision | notices an unwanted app; completes the removal by one confirmation tap; must be able to answer "did it work?" from the screen alone |
| ROLE-2 Maintainer | the developer / family helper, acts between sessions; writes the removable-app list and reads the outcome records | installs the build; records which packages may be removed; checks afterwards what happened; investigates an attempt that never finished |
| Participant (not a role) | the platform's own uninstall confirmation UI | its wording is drawn by the system, not by this app, and differs by locale and device maker |

## 3. User stories

| ID | Story | Priority | Owning feature |
|---|---|---|---|
| US-1 | As the phone owner, I need the app to notice by itself that an unwanted app has been removed, so that I never have to check or report anything. | P0 | 001 |
| US-2 | As the phone owner, I need to finish a removal with one confirmation tap on the dialog the system shows, so that the last irreversible step is mine and is easy. | P0 | 001 |
| US-3 | As the maintainer, I need every removal attempt to end in a terminal recorded outcome, so that I can tell what happened without reading a technical log. | P0 | 001 |
| US-4 | As the phone owner, I need everything the app says to be in my language, Chinese or English, so that I can read it without help. | P1 | 001 |
| US-5 | As the maintainer, I need the rule library to be the only thing that authorizes a removal, so that the app can never remove something I did not approve. | P0 | 001 |
| US-6 | As the phone owner, I need the app to do nothing when the screen is not the dialog it expects, so that a misread screen cannot cost me an app. | P0 | 001 |
| US-7 | As the phone owner, I need to be able to get a removed app back, so that a mistake is recoverable. | P0 | 002 — **not built**; disclosed, not claimed (§9 D-2, §11 R3) |

## 4. Business rules

| ID | Rule ("when …, then …") | Source | Testability |
|---|---|---|---|
| BR-1 | when an approved app is removed while the app is watching, then the removal is detected with no action by any person | owner's words ("I shouldn't have to check") | device end-to-end |
| BR-2 | when a removal signal is taken from the platform, then it is taken from `ACTION_PACKAGE_CHANGED`; `ACTION_PACKAGE_ADDED` must never be treated as a signal that an app appeared or disappeared on Android 15 | device evidence: `ACTION_PACKAGE_ADDED` never delivered in four clean trials (zero log lines), `ACTION_PACKAGE_CHANGED` arrived 3/3 | device end-to-end only — unit tests stayed green while this was wrong |
| BR-3 | when a package is not named by a rule-library entry, then no removal path may act on it | US-5 / constitution, delete authority | architecture test + unit test |
| BR-4 | when the system's confirmation dialog is on screen for an approved package, then the removal completes only after the owner's single confirmation tap | US-2 | device end-to-end, both locales |
| BR-5 | when the screen text does not match the expected uninstall-dialog pattern for the current locale, then an explicit error is recorded, no tap is issued, and the attempt stays open | US-6 | automated test on captured screen text + device end-to-end |
| BR-6 | when an attempt reaches a final result, then its record is written with a terminal status, `PURGED` or `FAILED`; `INCOMPLETE` is legal only while the attempt is still open | verification counterexample (records silently degraded to `INCOMPLETE` although the app had been removed) | automated test, with a deliberately constructed counterexample |
| BR-7 | when the app starts and finds an attempt that is not terminal, then it reconciles that attempt against the device's installed apps within one pass and rewrites the status if the package is gone | BR-6's counterexample | automated test on a fixed snapshot + device end-to-end |
| BR-8 | when the same removal is reported more than once, then exactly one terminal record exists for it | maintainer requirement (a readable history) | automated test, duplicate submission |
| BR-9 | when the confirmation step is shown in any supported locale, then the same marker text `★识别到卸载框` is printed and the identified button is named, so one evidence line is comparable across languages | device evidence recorded in both locales | device end-to-end |
| BR-10 | *(proposed)* when the rule library is changed, then the change comes from the maintainer's build-time tooling and no runtime part of the app may write it | constitution gap found during implementation: the rules named the library as the sole source of delete authority but never said who may write it — raised as amendment C-1, not patched silently | architecture test (proposed) |

## 5. Core flows

Main flow — an approved removal:
1. The maintainer adds the unwanted app to the rule library before the build.
2. The build is signed and installed on the owner's phone; the app starts watching for package changes.
3. The owner removes the unwanted app; the system shows its own confirmation dialog asking for a final confirmation.
4. The app recognises the dialog as an uninstall confirmation for a package the rule library names, and prints `★识别到卸载框 … 按钮=确定`.
5. The owner taps that one button (`确定`).
6. The app observes that the package is gone and closes the attempt with the terminal outcome `PURGED`.
7. The app shows the owner one plain line that the app was removed; the maintainer can read the same result from the record.

Branches: B1 the screen does not match the expected pattern (BR-5) · B2 the package is not in the rule library (BR-3) · B3 a removal is noticed with no attempt open, so a record is created from what is observed (BR-7) · B4 the app was not running when the package disappeared (BR-7 on the next start) · B5 the owner taps something other than the identified button — the attempt stays open and the app does not guess again.

| Exception path | Required behavior | Observable outcome |
|---|---|---|
| screen text unrecognised | no tap, explicit error (BR-5) | attempt stays `INCOMPLETE`; maintainer sees the error |
| package not approved | refuse, no side effects (BR-3) | explicit refusal line; nothing removed |
| the same removal reported twice | one record only (BR-8) | a second report changes nothing |
| attempt interrupted by the process ending | reconciled at next start (BR-7) | status reaches a terminal value within one pass |
| locale is neither Chinese nor English | never guess dialog text (BR-5); the language to show is open — §9 D-4 | explicit error rather than a blind tap |

## 6. Data entities (business view)

| Entity | Business meaning | Key attributes | Relationships |
|---|---|---|---|
| E1 Rule-library entry | the maintainer's written permission for exactly one package to be removed | which package it names; the evidence that it is unwanted; who wrote it | an attempt is legal only if its package is named by an entry |
| E2 Removal attempt | one recorded try at removing one app | which package; when it started; its current status; where the app had been; what the owner saw | belongs to one package; carries exactly one current status |
| E3 Outcome status (value set) | how an attempt ended | `INCOMPLETE` = still open, never a final answer; `PURGED` = the app is gone; `FAILED` = the attempt ended and the app is still there | `INCOMPLETE` may only be replaced by a terminal value |
| E4 Removal record | what is kept after a removal; **not** a way to put the app back (§9 D-2) | which package; where it had been; when it went | belongs to one terminal attempt |

## 7. Non-functional requirements

| Category | Requirement | How verified |
|---|---|---|
| Latency | an approved removal is detected within 30 s while the app is watching | device end-to-end timing |
| Language | every owner-facing string exists in Chinese and English, and the same evidence marker is printed in both | device end-to-end in both locales |
| Privacy | no information about the owner's apps leaves the device, and no network access is requested | architecture test + static check |
| Regression | the full existing suite passes with zero failures (197 passing at delivery) | run the suite and attach raw output |
| Size | the signed release build does not exceed 5 MB (delivered: 4.57 MB) | build output |
| Accessibility | the single owner screen stays readable at the owner's system font scale | manual check on the owner's device |

## 8. Constraints

- **Platform capability limit**: the only device available for testing runs Android 15, and notification behaviour differs by version — this is what refuted BR-2's first form and cannot be settled generally here.
- **External contract**: the uninstall confirmation dialog is drawn by the platform. Its text varies by locale and by device maker and cannot be changed by this app.
- **Distribution**: one sideloaded, signed build for one phone; no store review, no update channel to lean on.
- **Organizational**: one developer, two days, 18 working rounds; no second engineer available.
- **User capability**: the owner must never be asked to perform a technical step, and cannot be relied on to report what happened.
- The list of removable apps is maintained by hand before the build; the app cannot invent it.

## 9. Decisions pending from the user

| ID | Question | What it blocks | Status |
|---|---|---|---|
| D-2 | What must "restore" mean — putting the app back, or only keeping a record of what was removed? | whether a restore feature exists at all, and the wording of any promise made to the owner | open; this release keeps only a record and does not claim restore |
| D-3 | Which component is allowed to write the rule library (amendment C-1, BR-10)? | whether rule-write authority can be checked at all | open; meanwhile no runtime part may write the library |
| D-4 | Must a locale other than Chinese or English be supported, and which language is shown when dialog text is unrecognised? | the last row of the exception table in §5 | open; no dialog text is guessed in the meantime |

## 10. Non-automatable items

| Item | Why not automatable | How it will be handled |
|---|---|---|
| whether the owner understands the single screen unaided | comprehension, not behavior | the owner performs one removal alone on their own phone while the maintainer watches and says nothing |
| whether the confirmation step feels calm rather than alarming | subjective tone | judged in that same unaided run and recorded as a judgement, not as a test |
| whether dialog detection holds on other device makers | only one device is available | recorded as an evidence limit; no claim is made beyond the tested device |

## 11. Requirements change log

| # | Change | Reason (evidence) | Affected items | Version |
|---|---|---|---|---|
| R1 | the removal signal was moved from `ACTION_PACKAGE_ADDED` to `ACTION_PACKAGE_CHANGED` | device testing: `ACTION_PACKAGE_ADDED` never arrived in four clean trials (zero log lines) while `ACTION_PACKAGE_CHANGED` arrived 3/3; unit tests were green throughout and could not show it | BR-2, and only the acceptance criteria that rested on it (narrow invalidation, not a full re-lock) | 1.1 |
| R2 | "an attempt must end in a terminal status" was added, with reconciliation of open attempts at start | a deliberately constructed counterexample: removing the outcome-backfill step left every unit test green while records silently stayed `INCOMPLETE` although the app had in fact been removed | BR-6, BR-7, E3 | 1.2 |
| R3 | restore was downgraded from an assumed capability to an open decision | the app records where a removed app had been; recording a location is not supporting restore, and the delivery said so instead of claiming support | US-7, E4, D-2 | 1.2 |
| R4 | a rule about who may write the rule library was proposed | the rules made the library the sole source of delete authority but never named a writer, so a runtime part could have bypassed that section without breaking a clause | BR-10, D-3 | 1.3 |
| R5 | supported languages fixed to Chinese and English | device verification passed end-to-end in both locales with an identical evidence marker | BR-9, the language requirements, D-4 | 1.3 |
