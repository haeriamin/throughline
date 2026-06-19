# Escalation Protocol
> Loaded by all agents. Defines WHEN to escalate, WHAT artifact to produce, and what happens after.

---

## Triggers (any one suffices)

1. Reviewer FAIL after 2 implementer retry cycles
2. Analysis or task confidence < 0.60
3. \>30% of a slice's tasks end PARTIAL
4. CRITICAL complexity class detected (auth/payments/PII, data migrations, prod infra)
5. A required change conflicts with a standard, or two standards conflict
6. An unplanned dependency is needed
7. Security-class rule violation detected in existing target code
8. Any write-boundary hook block (the agent attempted a forbidden write — stop entirely)

## Escalation Artifact

Write `<target>/.throughline/work-queue/escalated/<slice>-escalation.md`:

```markdown
# Escalation: <slice>
**Date**: ISO-8601 | **Agent**: <persona> | **Target**: <id>
**Trigger**: <one of the triggers above, verbatim>
**State**: <exactly what is done, partial, untouched; branch/backup status>

## Question(s) for the human
1. <specific, decidable question — never "what should I do?">

## Options considered
| Option | Consequence | Agent's assessment |

## Recommendation
<option + confidence 0.XX>

## Resume instructions
<exact command(s) to continue once decided>
```

## Rules

- Escalation is a SUCCESS path (Principle V) — never frame it as failure, never guess to avoid it.
- Move the live work item to the global `work-queue/escalated/`; append the escalation event to `<target>/.throughline/wiki/log.md`.
- Work that can proceed independently of the blocked item continues; everything touching it freezes.
- Resolution happens ONLY through `/dev.review-escalated` (human decision, recorded in `<target>/.throughline/wiki/exception-registry.md`; global-scoped decisions go to the framework `wiki/exception-registry.md`).

## Post-Resolution

1. Orchestrator moves the item back to `in-progress` (or `completed`/abandoned per decision)
2. The blocked command re-runs with the registry entry as added context
3. If the decision implies a new exemplar or standards change → follow-up entry in `audit/recommendations.md`
