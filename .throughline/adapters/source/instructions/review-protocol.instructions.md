# Review Protocol
> Loaded by ReviewerAgent at runtime. These rules govern ALL review verdicts.

---

## What this gate is (and isn't)

The Reviewer and Implementer are the same model class, so this is **not** human four-eyes
review — two invocations share priors and blind spots. What makes it more than self-grading:
(a) re-reading primary sources instead of trusting summaries, (b) consuming *executed*
test evidence rather than claims, (c) deterministic tools deciding the rules they can
decide, (d) a fixed structural-fail list that no confidence score can override, and
(e) running in a **fresh context** — invoke the Reviewer as a separate agent/session, not a
continuation of the Implementer's window, on any adapter that supports subagents (Claude, Codex,
Copilot agents, …) so the review does not inherit the builder's working state. Carrying one
unbroken chat from implement to review is the weakest form of this gate. Treat
it as a strong lint-plus-traceability gate, not as a guarantee of correctness — the
human-only merge is the real final check.

## Independence Rule (non-negotiable)

Re-read every cited standard clause from its source — framework `/standards/**` or, for a target-local rule, the target's `.throughline/standards/**` — and every cited exemplar from `/exemplars/**` or the target's `.throughline/exemplars/**` directly. A target rule overrides the org rule with the same id (target wins). NEVER verify a citation against `wiki/standards-summary.md`, a target's `.throughline/wiki/` delta, or the Implementer's paraphrase — the wiki is a convenience layer and may drift; the review gate is the framework's defense against that drift.

## Deterministic Tools Win

When a rule names a `**Tool**` (linter rule, SAST check, dependency audit, type check),
**run it and use its result** — do not substitute judgment for a check a machine can make
exactly. Record the command and outcome. Judgment applies only to rules with no executable
check. A BLOCKING rule whose tool was not run scores as unsatisfied, not as passed.

---

## Pre-Review Checks

1. Bootstrap (Principle II, full sequence)
2. Implementation report present, with Decision Records for every task
3. Test report present AND fresh (source fingerprint matches branch state) — else run `/dev.test`; if it cannot run, `test_evidence = 0`
4. Diff reconstructable (branch vs base, or backups vs current)

## Three Layers

**Layer 1 — Structural (any failure → FAIL regardless of score)**
- Lint clean (target's `lint_command` if configured)
- Naming + file organization per standards and detected conventions
- No merge-conflict markers, no stray debug output, no commented-out code dumps
- Every DEV-STATUS annotation has a matching exception-registry/escalation entry
- **Plain English** (constitution §Output Language): the slice's prose artifacts (spec, plan, report, comments) use short sentences and common words, with jargon explained. Writing a non-native English speaker could not easily follow is a finding. Ids, citations, and code are exempt — they stay exact.

**Layer 2 — Behavioral**
- Test report verdicts; changed-behavior coverage table complete
- Pre-existing suites: no new failures attributable to the slice

**Layer 3 — Standards Compliance**
- `compliance-checker` over the diff against active BLOCKING/WARNING rules
- Citation validity: each cited clause exists AND actually mandates/permits the change (apposite, not just real)

## Scoring (Constitution Principle V — fixed)

```
confidence = 0.40·test_evidence + 0.35·standards_compliance + 0.25·spec_alignment
```

Report each sub-score WITH its numerator/denominator (e.g., `standards_compliance = 11/12 = 0.92`) AND the itemized disposition behind it — one line per clause/requirement/behavior with its verdict and evidence (tool output, file:line, or the judgment made). A bare ratio with no disposition list is not an acceptable review. Unverifiable → score that item 0,

## Verdicts

| Verdict | Condition | Routing |
|---------|-----------|---------|
| PASS | Layer 1 clean; confidence ≥ 0.85 | Orchestrator → completed; merge stays human |
| CONDITIONAL_PASS | Layer 1 clean; 0.70–0.84 | As PASS + flagged items list for human spot-check |
| FAIL | Any Layer-1 fail; or < 0.70; or CITATION-INVALID | Back to Implementer with itemized findings; max 2 retries → escalate |

## Findings Format

Each finding: `| ID | Severity | file:line | What | Standard clause | Fix guidance |`. Findings without a citation or location are not findings.
