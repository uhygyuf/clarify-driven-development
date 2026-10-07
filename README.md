# CDD — Clarify-Driven Development

**A solo full-stack development model for AI agent harnesses: the agent clarifies before it builds, and every decision survives the end of the chat session.**

Two files. Paste both. Describe what you want in one vague sentence.

```
CDD-BOOT.md    the behaviour specification, pasted at the start of every session
CDD-STATE.md   the state file the agent fills in; you carry it to the next session
```

---

## Built for one specific situation

> **One developer. An AI agent harness. The whole stack.**

If that is not you, this model will feel like overhead. It is designed around three constraints that only appear when those three things combine:

| The situation | What it forces |
|---|---|
| **Solo** — no colleague, no reviewer, no one to catch your mistakes | Verification must be *manufactured*: a separate context, deliberately constructed counterexamples, and a machine-checkable constitution. There is no one else to disagree with you. |
| **AI harness** — the agent is fast, tireless, and amnesiac | The chat is not storage. Anything that must survive to the next session has to reach a file, or it does not exist. Twenty minutes of unbounded agent work can produce a diff you cannot review; the pacing, the scope freeze and the "stop when done" rules exist only because of this. |
| **Full-stack** — you own the domain, the API, the UI and the deployment | The contract between layers is the highest-frequency source of silent drift, so contracts are frozen before implementation and types are derived, never written twice. No specialist is coming to catch the mismatch. |

**What this model is not**: a team process, an agent-orchestration framework, a code generator, or a tool. It is a paste-in behaviour specification plus a state file. Everything else follows from those three constraints.

**The shape of the work it produces**: you answer questions and correct the agent's understanding; the agent writes, tests and verifies. The human's job moves from *producing artifacts* to *defining what done means and refusing to accept unverified work* — which is the only role that does not become the bottleneck once an agent can write faster than you can read.

---

## Table of contents

- [Built for one specific situation](#built-for-one-specific-situation)
- [The problem](#the-problem)
- [The model in one screen](#the-model-in-one-screen)
- [Quick start](#quick-start)
- [What makes it different](#what-makes-it-different)
- [Field evidence](#field-evidence)
- [What did not survive contact with real use](#what-did-not-survive-contact-with-real-use)
- [Repository layout](#repository-layout)
- [Honest limitations](#honest-limitations)
- [Design lineage](#design-lineage)
- [中文说明](#中文说明)
- [License](#license)

---

## The problem

An AI agent is fast, tireless, and confident — and it has no memory between sessions. Three consequences follow, and they are the whole reason this model exists:

1. **The chat is not storage.** Anything you agreed on in a previous session does not exist unless it reached a file.
2. **Self-verification is structurally unsound.** An agent checking its own work reproduces the reasoning that produced the work. Independence is not about using a different model; it is about what the verifier can see.
3. **An agent guesses silently, and never says it guessed.** Unverifiable criteria are worse than no criteria, because they look like agreement.

Classical process models — waterfall, V-model, RAD — were designed around a different set of assumptions: that the executor is a human, that human time is expensive, and that documents are a medium for communication *between people*. When the executor becomes an agent, those assumptions fail and the model has to be re-derived rather than adapted.

## The model in one screen

```
S0 Intake → S1 Requirements & Terminology → S3 Spec Lock → S4 Design → S5 Implementation → S6 Prototype Delivery
                                                          ↑                                      │
                                                          └──── S7 Incremental Alignment ◄───────┘
                                                                            ↓
                                                                      S8 Rule Writeback
```

Three things do the actual work:

**1. The understanding gate (UA).** Before writing any artifact, the agent emits a numbered table of what it believes, each row marked `confirmed` or `inferred`, plus the questions whose wrong answer would cause rework. You reply in one line: *"delete 3, change 7, rest is correct."* Your job is reduced from *writing a good prompt* to *spotting what is wrong* — which is the only part humans are actually good at.

**2. Decidable acceptance criteria.** Every requirement becomes a predicate that a test can execute. A criterion that cannot be written as a predicate is explicitly quarantined rather than dressed up as testable.

**3. Verification in a separate context, with deliberately constructed counterexamples.** For every criterion: the exact assertion that covers it, the command that ran it, and one counterexample that was observed to fail before the fix and pass after.

Around these sit a project constitution (checkable clauses, not slogans), a confirmed-decision log, a rejected-options list, and a rule-writeback step that converts every defect into a change in the rules rather than a patch in the code.

## Quick start

**First session.** Paste `CDD-BOOT.md`, then `CDD-STATE.md`, then one sentence:

```
My need: an Android app for hotel management.
```

**Every later session.** Paste `CDD-BOOT.md` + your saved `CDD-STATE.md`, then:

```
Above are the spec and last session's progress. Continue, and first tell me where we are.
```

**Before ending every session**, save the updated `CDD-STATE.md`. It is the only memory you have.

The agent opens by deciding one thing — whether the project involves money, shared inventory or concurrency — and either runs the full process or a three-step lightweight mode. Most projects should get the lightweight mode.

## What makes it different

| Mechanism | Why it exists |
|---|---|
| **Cost gate** (§2.0) | Most projects do not justify a heavyweight process. The agent decides in one line, and you can override. |
| **Fast-path check** (§2.1) | If your opening message already contains goal + platform + ≥3 acceptance criteria, the agent must draft immediately instead of running a confirmation round first. Written as a mandatory computation with a printed result, because a rule phrased as "may" was measured to be skipped. |
| **Abstract → concrete** (§2.6) | "The UI has no polish" is not implementable. The agent must decompose it into at most 3 dimensions × 2 concrete options, with a mandatory third option: *defer and judge from the next prototype*. It is never allowed to answer "what do you want it to look like?" |
| **Safety net** (§2.4) | Nine categories — auth, money, inventory semantics, idempotency, state machines, retention, timezones, external contracts, platform limits — may never be decided *silently*. When you say "I don't know" twice, the agent adopts a disclosed default that must name the single file that would change to reverse it. |
| **Narrow invalidation** (§5.2) | A technical constraint discovered during implementation is not the same event as a change of mind, and must not cost the same. |
| **Rule writeback** (§8 backmatter) | A defect is not closed until it maps to one of: unclear semantics, a missing executable constraint, a missing criterion, or a missing environment capability. Fixing the code without fixing the rule means the defect returns in another form. |

## Field evidence

CDD v1.5 was used for one complete real project before this repository existed — a solo developer building an Android rogue-software cleaner for an elderly user's phone, in an empty chat harness, over two days.

| | |
|---|---|
| Output | signed release APK, 4.57 MB; 51 Kotlin files, 8,205 lines |
| Tests | 197 passing, 0 failures |
| End-to-end verification | passed on device, in both English and Chinese locales: `★识别到卸载框 … 按钮=确定` → `PURGED` |
| Sessions | 18 rounds |
| Decisions recorded | 45 (`D-1` … `D-45`), 13 declined options (`R-1` … `R-13`) |

**What the process actually caught**, which is the only reason to trust it:

- **A core assumption was refuted by device testing.** `ACTION_PACKAGE_ADDED` is never delivered to the app on Android 15 (four clean tests, zero log lines), while `ACTION_PACKAGE_CHANGED` arrived 3/3. The entire trigger design was built on the wrong broadcast. Unit tests stayed green throughout — this was only findable end-to-end.
- **The agent disclosed an unimplemented P0 criterion** instead of treating "we recorded the path" as "we support restore."
- **The agent retracted its own overstated technical claim** after checking the evidence.
- **The agent found a hole in its own constitution** — the rules named the rule library as the sole source of delete authority but never said who may *write* it, so a runtime module could have bypassed the whole section without violating any clause. It raised this as an amendment rather than patching it silently.
- **A verification counterexample caught a failure class no unit test could**: commenting out the outcome-backfill call left every unit test green while records silently degraded to `INCOMPLETE` even though the app *had* been removed.
- **A human judgement was replaced by a machine check.** "A forum post is not evidence" became a `throw` in the rule-pack generator, and was proven to reject by deliberately substituting a forum link.

## What did not survive contact with real use

The versions before v1.6 were built through five review rounds — static reading, simulated sessions, agent self-assessment, cross-session simulation. All five were reasoning; none was usage. Real use then contradicted the most confident review finding and exposed a cost the reviews had underestimated.

**v1.6 changes, all from measured data:**

| Change | The measurement behind it |
|---|---|
| **Log findings, not assertions** | The rule "append every required output line to the state file" produced ~290 lines / ~43,000 characters of log with no reader, and grew the state file to 105,000 characters — larger than the entire specification. Printing the lines stays mandatory (that is what keeps them executed); storing them does not. |
| **Full stage gate, one-line output** | Every line of the gate block was either derivable from the artifacts or an assertion nobody revisits. The check still runs in full; only failures are recorded. |
| **Archive rule made enforceable** | It existed in v1.5 and was **never executed** — the file reached 634 lines against a 500-line threshold. Lowered to 400 lines / 10 sessions, with a concrete procedure. |
| **Removed a false durability claim** | v1.5 asserted that a missing gate block makes an artifact "unconfirmed" for a later session. That was false while the block lived only in chat. Confirmation is now judged by `locked` status and hash. |

A sixth review round concluded *"abandon it — the accumulation has made it self-defeating."* The field data says otherwise: the user completed the project. But the same round was directionally right about the cost, which is why v1.6 exists. **A review is not a test.**

## Repository layout

```
CDD-BOOT.md    the specification to paste — self-contained: behaviour spec, constitution
               template, artifact templates, question bank
CDD-STATE.md   the state template the agent fills in and you carry between sessions
tools/         (reserved)
docs/          (reserved)
```

`CDD-BOOT.md` is self-contained on purpose: nothing else needs pasting for a first session.

## Honest limitations

- **Lightweight mode is unvalidated.** The field project ran in full mode. The interaction between the cost gate and the safety-net list, in lightweight mode, has never been exercised. If you use it, that is the part to report back on.
- **The state file is trusted, not verified.** Nothing detects a row the user edited out or forgot to paste. A weak hash covers the artifacts, not the state file itself.
- **This is designed for a single developer.** The state file is carried by hand; it does not scale to a team, and it does not try to.
- **It is not validated by controlled study.** One real project, two days, one domain. Treat the field evidence as existence proof — that it *can* work — rather than as a general result.
- **The document is long.** 1,172 lines. Most of it is templates and a question bank that the agent consults selectively; the behavioural core is Parts 1 and 5.

## Design lineage

CDD stands on work that came before it:

- **Spec-Driven Development** — [GitHub Spec Kit](https://github.com/github/spec-kit), whose constitution/specify/plan/tasks structure and treatment of specifications as the primary artifact directly shaped Part 1 and the artifact templates here.
- **Harness engineering** — [OpenAI's account of building a million-line codebase agent-first](https://openai.com/index/harness-engineering/) and Mitchell Hashimoto's rule of *"whenever an agent makes a mistake, engineer a solution such that it never makes that mistake again"*, which is the source of the rule-writeback step.
- **Guides and sensors** — [Martin Fowler's framing of the harness as feedforward and feedback control](https://martinfowler.com/articles/harness-engineering.html).
- **On-the-loop** — [Kief Morris's distinction](https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html) between fixing a bad artifact and fixing the harness that produced it, which is why defects here are attributed to rules rather than patched in code.
- **Cognitive debt** — [Thoughtworks Technology Radar v34](https://www.thoughtworks.com/en-ec/about-us/news/2026/combat-ai-cognitive-debt-radar-v34), the argument that AI raises complexity faster than human comprehension, which motivates the complexity ledger and the "can you explain this change in one paragraph" test.

The contribution here is not any of those ideas. It is the assembly: a clarification gate that survives a user who cannot write a good prompt, decidable criteria, verification separated by context rather than by model, and an explicit accounting of which mechanisms were kept because they worked and which were removed because they were measured not to.

## 中文说明

**CDD（Clarify-Driven Development，澄清驱动开发）** 是给「**单人 × AI harness × 全栈**」这一种特定处境用的开发模型。

### 它只为这一种处境设计

| 你的处境 | 它带来的强制约束 |
|---|---|
| **单人**——没有同事、没有评审、没人接住你的错 | 验证必须被「制造」出来：独立上下文、刻意构造的反例、可被机器检查的章程。没有第二个人来反对你，所以规则必须替你反对你自己 |
| **AI harness**——agent 快、不累、但会失忆 | 聊天不是存储：跨会话要用的东西必须落到文件，否则等于不存在。二十分钟不设边界的 agent 工作能产出你无法审查的 diff——节奏决策、范围冻结、"做完就停"都只因为这个原因存在 |
| **全栈**——领域、接口、界面、部署全是你一个人 | 层与层之间的契约是静默漂移的最高频来源：契约先冻结，类型只能派生不能两边各写一份。没有专家会来接住这个不一致 |

**它不是**：团队流程、多 agent 编排框架、代码生成器或工具。它是一份可粘贴的行为规范 + 一个状态文件，其余全部由上面三条约束推出。

### 核心只有两条

1. **agent 必须先问清楚再动手**——产出任何制品之前，先用带编号的「理解声明」说出它理解了什么、哪些是推断的，你只需要回一句"删 3、改 7、其余对"。你的工作从"写一个好提示词"降级为"挑错"——**后者才是人真正擅长的事**。
2. **验证必须换上下文**——同一个会话里 agent 检查自己写的代码，复现的是它生成时的偏见，不是事实。独立性取决于验证者**能看到什么**，不取决于换不换模型。

附带：可判定的验收标准（写不成谓词的需求会被显式隔离，而不是伪装成可测）、项目章程（可检查的条款而非口号）、决策日志、拒绝选项表，以及「每修一个 bug 必须同时补一条规则」的回写机制。

### 用法

**第一次**：把 `CDD-BOOT.md` + `CDD-STATE.md` 一起粘贴，末尾写一句你的需求（可以很模糊）：

```
我的需求：我要开发一个 Android 软件，是 hotel 管理系统。
```

**之后每次**：粘贴 `CDD-BOOT.md` + 你保存的 `CDD-STATE.md`，加一句：

```
以上是规范和上次的进度，接着做，先告诉我当前在哪一步。
```

**每次会话结束前务必保存状态文件**，那是唯一的记忆。agent 开场的第一个动作是判断一件事——项目是否涉及钱、共享库存或并发——然后走完整流程或三步轻量模式。**大多数项目应该拿到轻量模式。**

### 实测

v1.5 被用于一个真实项目：单人用空 chat harness，两天 18 轮，给老人手机做流氓软件清理工具。

| | |
|---|---|
| 产出 | 签名 release APK 4.57 MB；51 个 Kotlin 文件 / 8205 行 |
| 测试 | 197 个通过，0 失败 |
| 端到端验证 | 中英文环境真机通过：`★识别到卸载框 … 按钮=确定` → `PURGED` |
| 记录 | 45 条决策（D-1…D-45）、13 个被否方案（R-1…R-13） |

**流程真正抓到的东西**：一个核心假设被真机推翻（`ACTION_PACKAGE_ADDED` 在 Android 15 上根本不投递，而单元测试全程是绿的）；agent 主动披露一条未实现的 P0 验收标准；agent 收回自己一次夸大的技术论断；agent 发现**自己章程里的漏洞**（规定了规则库是唯一删除权威，却没说谁可以写规则库）并作为修正案提出而非自己打补丁。

### v1.6：改动全部来自实测而非评审

v1.6 之前有**五轮评审**——静态读、模拟会话、agent 自评、跨会话模拟。五轮全是推理，没有一次真实使用。真实使用随后推翻了最自信的那条评审结论，也暴露了评审低估的成本：

| 改动 | 背后的实测数据 |
|---|---|
| **只记发现，不记断言** | 原规则要求每条输出行都追加进状态文件，实测产出 290 行 / 4.3 万字符的日志、状态文件涨到 10.5 万字符（比整份规范还大）、**读者为零**。打印照旧（那才是让检查被执行的原因），存储取消 |
| **阶段闸门照跑，只输出一行** | 闸门块里每一行要么能从制品推出，要么是没人回看的断言 |
| **归档规则变成可执行的** | 它在 v1.5 就存在，但**从未被执行过**——文件涨到 634 行，阈值是 500 |
| **删掉一句假的持久性声称** | v1.5 说"缺失闸门块会让制品未确认"——只要块只存在于聊天里，这句就是假的 |

第六轮评审的结论是「**放弃它**——五轮修补已使它自我抵消」。实测数据说不是：用户把项目做完了。但那一轮对**成本**的判断是对的，v1.6 就是因此而生。**评审不等于测试。**

### 已知局限

- **轻量模式从未被验证过**。实测项目走的是完整模式，成本闸门与安全网清单在轻量模式下的交互一次都没跑过。你如果用，这就是最值得反馈回来的部分。
- **状态文件是被信任而非被校验的**——没有任何东西能发现用户删掉或漏粘了一行。
- **为单人设计**，不适合团队：状态文件是手工携带的。
- **没有对照实验**：一个项目、两天、一个领域。把实测当作存在性证明（它**能**work），而不是普适结论。

## License

MIT — see [LICENSE](LICENSE).
