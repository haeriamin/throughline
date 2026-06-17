# Throughline

**An unbroken line from spec to reviewed code — every change cites its rule, test, and reason.**

Give one request. Get back a tested, **independently reviewed** feature on a branch that only
*you* merge — using the AI coding tool you already have (**GitHub Copilot**, **Claude Code**, or
**Codex**). Your code stays where it is; Throughline holds the process, your standards, and the
shared memory. Works on any codebase, any language.

```bash
/dev.target register path/to/my-app
/dev.feature my-app "Add cursor pagination to the orders endpoint"
# → spec → plan → tasks → implement → tests → review → branch sdd/<slice>.   You do the merge.
```

> **v0.1, experimental.** For an honest look at what is *enforced* vs. only *instructed*, read
> **[STATUS.md](STATUS.md)**.
>
> Ask for auth, payments, or personal-data work and Throughline marks it **CRITICAL** — then you
> lead and the agents only assist. That limit is on purpose.

---

## What it is

Throughline is a **spec-driven, multi-agent layer** for your AI coding tool, built on
[spec-kit](https://github.com/github/spec-kit). You describe a change; a team of eight
role-separated agents specs it, plans it, implements it on a branch, tests it, and an
**independent reviewer** gates it against *your* standards before it's called done. Nothing
merges without you. The process and knowledge live in this repo; your product code never does.

## Why — LLMs forget the boring bugs, and more tests don't fix it

Frontier models nail the happy path but reliably skip **specification-completeness** bugs:
forgotten input validation, edge cases, and error handling. Asking for *more* or *"thorough"*
tests barely helps — the model just writes more happy-path tests.

**What does help is grounding** — tying each test to a rule in an enumerated spec, and having an
independent reviewer check the result against the source standards. We measured it in a
controlled study of LLM code generation:

- **+38 points** more correct code than a strong baseline that was *already* told to probe edge
  cases and invalid inputs — driven by **grounding, not test quantity** (doubling the test budget
  barely moved the needle).
- **The effect replicated across three model families** — Claude (+38), GPT-5.3-codex (+28), and
  Gemini (+19); it never reversed.
- **Fewer false alarms too:** grounded testing wrongly rejected correct code **0%** of the time,
  vs **33%** for ungrounded "test the edges" prompting.
- **A weaker model + this discipline beat a stronger model without it.**
- *Honest scope:* on clean, well-specified algorithmic tasks where models rarely slip, it neither
  helps nor hurts — the gain is on the spec-completeness bugs that dominate real one-shot failures.

Throughline puts that discipline on rails: the **Tester** derives tests from your spec's rules,
and an **independent Reviewer** verifies every change against your standards' source text.

## How it works

```mermaid
flowchart LR
  R([request]) --> SP[specify] --> PL[plan] --> IM[implement] --> TS[test] --> G{review}
  G -- fail · max 2 --> IM
  G -- unsure --> HX[ask the human]
  G -- pass --> BR[branch sdd/slice]
  BR --> HM([human merges])
```

- **One brain, many hands.** Eight single-purpose agents — Orchestrator, Analyst, Architect,
  Implementer, Tester, Reviewer, Archivist, Auditor — hand off through artifacts, never reaching
  into each other's lane.
- **An independent review gate.** The Reviewer re-reads your standards *from source* (not the
  implementer's summary) and issues **PASS / CONDITIONAL_PASS / FAIL** on a confidence score.
  Both sides are the same kind of model, so it's a strong check, not a second human — your merge
  is the final check.
- **Standards as law.** Every change cites its spec requirement, the standard clause it follows,
  and an example when one exists. *Cite or don't ship.*
- **Safe by construction.** Work happens on `sdd/<slice>` branches (or with backups); agents never
  merge or push; `/standards/` are read-only (hook-enforced); risky work is escalated to you.
- **Knowledge compounds.** Your standards, code examples, and past decisions live in a shared wiki
  that every later task builds on.

### Does the review actually catch real bugs? A side-by-side says yes.

We built the same 3 tasks two ways — plain (one quick pass) and through Throughline, same model
both times. Each plain version passed its own tests and looked done. The review step caught a real
bug in **all three**:

| Task | Plain version (tests passed) | What the review caught |
|------|------------------------------|------------------------|
| Compare versions | exit 0 | `1.0.0-rc.1` treated as **newer** than `1.0.0` (+3 more) |
| Split money | exit 0 | `$10 ÷ 3` → parts add up to **$9.99**, not $10 |
| Pagination | exit 0 | `page = -1` quietly returns **wrong rows**, no error |

*Honest limit:* these tasks had tricky edges on purpose — that's where the check pays off; on a
simple task done right it catches nothing. → [full run](docs/validation-runs/2026-06-13-ab-suite.md)

**On a recognized benchmark:** Throughline solved a real **SWE-bench Lite** issue end-to-end
(`pytest-dev/pytest`) from the bug report alone — its one-line root-cause fix passes the benchmark's
own hidden test with no regressions (115 passing), and the Tester independently generalized the
coverage beyond the gold case. → [full run](docs/validation-runs/2026-06-16-swebench-pytest-11143.md)

## How to use it

### 1. Pick your host — same framework, three adapters

Throughline is thin adapters over one shared brain. Use whichever tool you already have; the
commands are identical, only the slash punctuation differs.

| Host | Slash syntax | Status | Step-by-step guide |
|------|--------------|--------|--------------------|
| **GitHub Copilot** (VS Code) | `/dev.feature` | Supported | **[docs/runtimes/copilot.md](docs/runtimes/copilot.md)** |
| **Claude Code** | `/dev:feature` | Supported | **[docs/runtimes/claude-code.md](docs/runtimes/claude-code.md)** |
| **Codex** | `/dev.feature` | Preview | **[docs/runtimes/codex.md](docs/runtimes/codex.md)** |

→ Overview + comparison: **[docs/runtimes/](docs/runtimes/)**

### 2. Quick start

```bash
git clone <repo-url> && cd throughline
# open in VS Code (Copilot) · run `claude` (Claude Code) · run `codex` (Codex)
/speckit.constitution && /dev.ingest-standards && /dev.ingest-exemplars   # one-time: load the rules
/dev.target register path/to/my-app                                       # point at your code
/dev.feature my-app "Add cursor pagination to the orders endpoint"        # build it
```

### 3. The five ways to use it

1. **One command, whole lifecycle** — `/dev.feature` runs specify → … → review.
2. **Cheaper modes** — `--micro` (implement→test→review) or `--express` (skip optional pauses).
3. **Phase-by-phase** — drive `/speckit.specify → clarify → plan → tasks → implement` yourself.
4. **Single commands** — `/dev.analyze`, `/dev.test`, `/dev.review`, `/dev.audit` out of band.
5. **Knowledge only** — ingest your standards + examples and use the skills ad hoc.

Each is shown in your host's exact syntax in the **[runtime guides](docs/runtimes/)**.

## For teams

A better model makes each agent better. It does **not** fix consistency, audit trails, or trust
across a team — Throughline does. It turns one request into a change that is reviewed, recorded,
and easy to undo:

| Problem on a team | How it helps |
|-------------------|--------------|
| Agents write code differently each time | Your rules + an independent review step |
| No record of *why* code changed | Each change links spec → task → rule → result, all saved |
| Agents could break things | Hooks block risky writes and merges; only humans merge |
| Lessons get forgotten | A shared wiki keeps rules, examples, and decisions |

**Will it save tokens?** Per task, no — it runs more steps, so it costs more. Over time it pays
off like **insurance**: a little extra on every task, returned on the ones where it catches a bug
that would be expensive to find later. Worth it for important code; for throwaway changes use
`--micro` or plain Copilot.

## Layout

| Folder | What is inside |
|--------|----------------|
| `.specify/` | The engine — constitution, command runbooks, templates, workflows |
| `.github/` · `.claude/` · `.codex/` | Copilot, Claude Code, and Codex adapters + hooks (CI in `.github/`) |
| `standards/` · `exemplars/` | Your rules + example code — read-only inputs you write |
| `wiki/` | Knowledge the agents keep + an append-only log of everything they do |
| `specs/` · `work-queue/` · `review-reports/` | Per-task files and status |
| `targets/` | The list of outside projects the agents work on |
| `tools/dashboard/` | VS Code extension — a live view of the work queue |
| `docs/` | The user guide (incl. the per-host runtime guides) |

## Learn more

**[→ User Guide](docs/README.md)** · [Runtime guides](docs/runtimes/) · [Commands](COMMANDS.md) ·
[Architecture](ARCHITECTURE.md) · [Status](STATUS.md) · [Contributing](CONTRIBUTING.md) ·
[Constitution](.specify/memory/constitution.md)

---

MIT — see [LICENSE](LICENSE). The standards and examples that ship are starter seeds; replace them
with your own.
