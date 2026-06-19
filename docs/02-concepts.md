# 2 · Core Concepts

Five ideas explain the rest.

## 1. The framework holds none of your code

This repo has **no product code** in it. Your projects stay where they are. You add each one
as a **target** (a file `targets/<id>.yml` that points to its folder). The framework only
holds the process, the shared knowledge, and the records — and that knowledge grows as you
use it on more projects.

## 2. Every job is a "slice"

A **slice** is one piece of work — a feature, a fix, a refactor, or a new project. Each slice
goes through the same steps and gets its own folder under the target, `<target>/.throughline/specs/NNN-<name>/`:

```
specify → clarify → plan → tasks → implement → test → review
(WHAT+WHY)  (resolve   (HOW,      (atomic    (code on    (evidence) (gate:
             ambiguity) grounded   steps)     sdd/<slice>             PASS/FAIL)
                        in analysis)          branch)
```

`/dev:feature` runs the whole chain from one request. You can also run each step on its own.
No code change happens outside a slice.

## 3. Eight agents, each with one job

| Agent | Does | Never |
|-------|------|-------|
| Orchestrator | The entry point: manages targets, the queue, and hands work to the others | Edits code |
| Archivist | Keeps the wiki; reads in your standards and examples | Makes up content |
| Analyst | Reads the target code and writes an analysis | Edits code |
| Architect | Writes the design + key decisions for big/risky slices | Edits code; approves its own work |
| Implementer | Writes the code, with a reason for each change | Merges or pushes |
| Tester | Writes tests, runs them for real, reports the results | Touches non-test code |
| Reviewer | The check: re-reads the rules from the source and judges the change | Trusts summaries; fixes code |
| Auditor | Summaries across projects; spots repeated problems | Writes wiki content |

Agents talk through files (queue items, reports), never directly. This is the safety idea:
the agent that writes the code is never the agent that approves it.

## 4. The constitution is law

`.throughline/memory/constitution.md` — seven principles every agent obeys:

1. **Immutable Source of Truth** — `/standards/` and `/exemplars/` are read-only (hook-enforced)
2. **Knowledge Before Action** — mandatory bootstrap reads before touching target code
3. **Cite or Don't Ship** — every change cites its spec requirement + standard clause
4. **Annotate, Never Silently Skip** — unresolved work gets a `DEV-STATUS` block
5. **Confidence-Gated Autonomy** — act above the threshold, escalate below it
6. **Reversible Changes Only** — branch `sdd/<slice>`; merging is always human
7. **Append-Only Operations Log** — `wiki/log.md` (framework events) and each target's `<target>/.throughline/wiki/log.md` (its slice events) record everything

Conflicts between any file and the constitution resolve in favor of the constitution.
Changing it is a formal amendment with a version bump.

## 5. Confidence gates autonomy

```
confidence = 0.40·test_evidence + 0.35·standards_compliance + 0.25·spec_alignment
```

| Confidence | Verdict | What happens |
|-----------|---------|--------------|
| ≥ 0.85 | PASS | Merge-ready branch presented to you |
| 0.70–0.84 | CONDITIONAL_PASS | Merge-ready + flagged items to spot-check |
| < 0.70 | FAIL | Back to the Implementer (max 2 retries), then escalation |

Escalation is a success path: when an agent isn't confident, it asks you a specific,
decidable question instead of guessing.

## Repository layout

```
.throughline/        lifecycle engine: constitution, templates, runbooks, workflows, scripts
.github/         GitHub Copilot adapters: agents, prompts, instructions, skills, hooks, CI
.claude/ + CLAUDE.md   Claude Code adapters: commands, subagents, skills, hooks
standards/       IMMUTABLE — your engineering rules (human-curated)
exemplars/       IMMUTABLE — curated reference code + anti-patterns
wiki/            shared knowledge: standards summary, pattern library, global registries, framework log
targets/         registry of external project paths
work-queue/      live cross-target queue: pending / in-progress (+ the escalated lane)
audit/           portfolio audit roll-ups (per-slice evidence lives with each target)
tools/dashboard/ VS Code extension showing all of the above live
docs/            this guide

<target>/.throughline/   each target's own SDD provenance, committed on the slice branch:
  specs/NNN-<slice>/   spec, plan, design, tasks, analysis, implementation
  review-reports/      test + review evidence for the target's slices
  work-queue/          completed / escalated records (+ backups)
  standards/ exemplars/ optional target-local rules + examples (override org by rule-id)
  wiki/                target-scoped log, registries, and knowledge deltas
  CHANGELOG.md         human-readable record of what shipped
```

**The rule behind the split:** anything the framework uses *globally* — across every target —
lives at the root; anything tied to one project lives under that project's `<target>/.throughline/`.
That is why specs and per-slice review reports sit with the target, while the live queue and the
portfolio roll-up stay shared. The split is not a wall: the audit step rolls each target's review
reports up into the global `audit/portfolio-summary.md`, and the lessons get curated into
the shared `standards/`, `exemplars/`, and `wiki/` — so what the framework learns on one project
helps the next.

---
[← Getting Started](01-getting-started.md) · Next: [Managing Targets →](03-targets.md)
