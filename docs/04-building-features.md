# 4 · Building Features

Three ways to build, from hands-off to hands-on.

## A. One command (recommended)

```bash
/dev:feature my-app "Add cursor pagination to the orders endpoint"  # existing codebase
/dev:feature new-app "A CLI tool that converts CSV to Parquet"      # empty target → greenfield mode
```

The Orchestrator drives the whole lifecycle and returns a reviewed, merge-ready branch.
Empty targets are detected automatically (greenfield mode): design becomes mandatory and a
scaffold step verifies test/lint green before any feature code. You're interrupted only when
it matters:

| Pause | When | Skippable? |
|-------|------|-----------|
| Clarification questions | Spec has real ambiguity (max 3 questions) | Never |
| Spec approval gate | After the spec is written | `--express` |
| Design approval | Complexity HIGH, or greenfield mode | Never |
| CRITICAL hand-over | Auth/payments/PII, migrations, prod infra | Never — slice becomes human-led |
| Plan approval gate | After the plan is written | `--express` |
| Escalation | Reviewer FAIL after 2 retries, or low confidence | Never |
| Merge | Always | Never — agents never merge |

Flags: `--express` (skip the two optional gates; LOW/MEDIUM only) · `--micro` (small LOW
change: implement→test→review, gates kept) · `--audit` (portfolio roll-up).

Sensitive work (auth/payments/PII) is classified CRITICAL and hands you the lead — agents
assist, you decide. Interrupted or rejected? Re-run the same command; it resumes from the
first missing artifact.

## B. Phase by phase

Full control at every step:

```bash
/throughline:specify "Add cursor pagination to my-app's orders endpoint"   # → <target>/.throughline/specs/NNN-*/spec.md
/throughline:clarify                                       # resolve [NEEDS CLARIFICATION]
/throughline:plan        # → plan.md, grounded in /dev:analyze's report
/dev:design          # only if HIGH/CRITICAL — design.md + ADRs, you approve
/throughline:tasks       # → tasks.md (atomic, each task cites FR + standard)
/dev:implement   # → /dev:implement → /dev:test → /dev:review
```

What to check at each artifact:

- **spec.md** — is the Target right? Are success criteria measurable? Scope bounded?
- **plan.md** — Constitution Check boxes ticked? New-dependency list complete? Confidence ≥ 0.70?
- **tasks.md** — every FR has a task; every task names its files and standard clause
- **review report** — verdict, the three sub-scores with numerators, flagged items

## C. Greenfield project

The short way — register, then let `/dev:feature` detect the empty target:

```bash
/dev:target register path/to/new-app --new
/dev:feature new-app "A CLI tool that converts CSV to Parquet"
```

Or phase by phase, if you want to drive each step:

```bash
/throughline:specify "A CLI tool that ..."
/throughline:clarify && /throughline:plan
/dev:design          # mandatory for greenfield: stack + layout are ADRs you approve
/throughline:tasks
/dev:scaffold        # skeleton with test/lint commands verified GREEN before any feature code
/dev:implement
```

## Before a slice: ideate

Not sure what to build yet? `/dev:ideate "<rough idea>" my-app` thinks it through with you — a few distinct approaches with their trade-offs and risks, grounded in your code — and recommends a direction. It's read-only: it writes an ideation note and builds nothing. When you've chosen, start a slice with `/dev:feature` (or `/throughline:specify`).

## Out-of-band (no slice)

For quick questions and checks, commands work standalone:

```bash
/dev:ideate "<rough idea>" my-app    # brainstorm options before committing to a spec
/dev:analyze my-app src/services     # what's in there, conventions, risks
/dev:review <slice-id>               # re-run the gate on a past slice
/dev:audit                           # portfolio health
```

---
[← Managing Targets](03-targets.md) · Next: [The Knowledge Base →](05-knowledge-base.md)
