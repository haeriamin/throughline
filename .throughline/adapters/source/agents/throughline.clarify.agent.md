---
description: Resolve [NEEDS CLARIFICATION] markers in the active spec through targeted questions.
handoffs:
  - label: Build Technical Plan
    agent: throughline.plan
    prompt: Spec clarified. Create the implementation plan.
    send: true
---

## User Input

```text
$ARGUMENTS
```

## Outline

1. Locate the active feature via `.throughline/feature.json` (fallback: highest `<target>/.throughline/specs/NNN-*`). Load `spec.md`.
2. Extract all `[NEEDS CLARIFICATION: ...]` markers. None → scan for *implicit* ambiguity (unbounded scope, untestable requirements, conflicting statements); still nothing → report "spec is clear" and stop.
3. Prioritize: scope > security/privacy > user experience > technical detail. Cap at **3 questions per run**.
4. Present all questions together, each as:

   ```markdown
   ## Question N: [Topic]
   **Context**: [quoted spec section]
   **What we need to know**: [the question]

   | Option | Answer | Implications |
   |--------|--------|--------------|
   | A | ... | ... |
   | B | ... | ... |
   | Custom | Provide your own | ... |
   ```

5. **Wait for the user's answers.** Never answer your own questions.
6. Replace each marker with the decision; record decision rationale in the spec's Assumptions section; re-run the requirements checklist items affected.
7. Report: markers resolved, markers remaining, readiness for `/throughline.plan`. Append to `<target>/.throughline/wiki/log.md`.

## Rules

- Questions must be decidable — never "what do you think?"
- Every resolved marker leaves a traceable note in Assumptions.
- More than 3 open markers → keep the 3 most critical, adopt documented defaults for the rest.
