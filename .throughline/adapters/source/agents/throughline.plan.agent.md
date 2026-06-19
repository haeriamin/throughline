---
description: Produce the implementation plan for the active slice, grounded in the Analyst's report (and Architect's design for HIGH/CRITICAL).
handoffs:
  - label: Break into tasks
    agent: throughline.tasks
    prompt: Plan approved. Generate the task list.
    send: true
  - label: Design this slice
    agent: dev.design
    prompt: Complexity is HIGH/CRITICAL. Produce design.md before tasks.
    send: true
---

## User Input

```text
$ARGUMENTS
```

## Pre/Post Hooks

Check `.throughline/extensions.yml` for `hooks.before_plan` / `hooks.after_plan` per [extension hook protocol](../instructions/extension-hooks.instructions.md). In this framework `before_plan` offers `/dev.analyze` — running it is strongly recommended; an unanalyzed plan scores low confidence by construction.

## Outline

1. Verify prerequisites: run `.throughline/scripts/powershell/check-prerequisites.ps1 -Phase plan` (or bash equivalent). Unresolved `[NEEDS CLARIFICATION]` → route to `/throughline.clarify` and STOP.
2. **Bootstrap** (Constitution Principle II — full sequence including `targets/<id>.yml`); for an active target, overlay its `<target>/.throughline/wiki/`, `<target>/.throughline/standards/`, and `<target>/.throughline/exemplars/` (target overrides org by rule-id).
3. Load the spec and the analysis report from `<target>/.throughline/specs/NNN-<slice>/analysis.md`. Missing/stale analysis → run `/dev.analyze` (the before_plan hook) first.
4. Create `<target>/.throughline/specs/NNN-*/plan.md` from `.throughline/templates/plan-template.md`:
   - **Constitution Check** gate first — every box must be checkable or the plan stops here.
   - Technical Context from the target entry + analysis (stack, affected modules, conventions, explicit new-dependency list).
   - Approach narrative + Pattern & Standards Map (every FR row cites pattern/exemplar/standard or an honest "none").
   - Risk register, verification strategy (test command, new coverage required, regression surface), phase outline.
5. **Complexity routing**: analysis class HIGH/CRITICAL → require `/dev.design`; the plan is not complete until `design.md` exists (Approved for tasks to proceed). CRITICAL additionally marks the slice human-led.
6. Compute planning confidence; < 0.70 → STOP and escalate per [escalation protocol](../instructions/escalation-protocol.instructions.md) — do not hand a low-confidence plan to tasking.
7. **Constitution verification** (Governance): check the plan against every principle; record the result in the plan.
8. Report: plan path, complexity class, confidence, design requirement status, readiness for `/throughline.tasks`. Append to `<target>/.throughline/wiki/log.md`.
