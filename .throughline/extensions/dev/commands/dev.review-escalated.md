# /dev.review-escalated

**Agents**: Orchestrator (drives) + human (decides) + Archivist (records)
**Reads**: the global `work-queue/escalated/**` live items and each target's escalation reports (`<target>/.throughline/work-queue/escalated/<slice>-escalation.md`), related `<target>/.throughline/specs/**` and reports, `wiki/exception-registry.md` + `<target>/.throughline/wiki/exception-registry.md`
**Writes**: `<target>/.throughline/wiki/exception-registry.md` for this-target/this-slice decisions (global-scoped decisions go to the framework `wiki/exception-registry.md`) (Archivist), global live-queue moves (Orchestrator); append to the framework `wiki/log.md`
**Never writes**: target source, `/standards/**`, `/exemplars/**`

## Preconditions

- At least one escalation pending — a live item in the global `work-queue/escalated/` (with its report at `<target>/.throughline/work-queue/escalated/<slice>-escalation.md`). None → report empty state and stop.

## Steps

1. **Bootstrap** (Principle II, steps 1–3).
2. List escalation artifacts oldest-first. For each:
   - Present the artifact's structured content: slice, target, trigger
     (per `.github/instructions/escalation-protocol.instructions.md`), the specific
     question(s), options considered, and the agent's recommendation with confidence.
   - **Wait for the human decision.** Never decide on the human's behalf — that is the
     entire point of escalation (Principle V).
3. Record each decision in `<target>/.throughline/wiki/exception-registry.md` (a `global`-scoped
   decision is promoted to the framework `wiki/exception-registry.md`):
   ```markdown
   ## EXC-NNN: <title>
   **Date**: ... | **Slice**: NNN-<slice> | **Target**: <id>
   **Trigger**: <escalation trigger>
   **Human decision**: <verbatim or faithful summary>
   **Scope**: this-slice-only | this-target | global
   **Follow-up**: <exemplar to curate / standard to amend / none>
   ```
4. Resume the pipeline per decision: move the global live work item (escalated → in-progress;
   or, when the decision closes the slice, clear the live item and write the durable record to
   `<target>/.throughline/work-queue/completed/<slice>.md`; or abandoned), re-invoke the blocked
   command with the decision as context.
5. If the decision implies a standards change or new exemplar → create the follow-up
   entry in `audit/recommendations.md` for human curation.
6. Append to `wiki/log.md` (one entry per resolved escalation).

## Exit Criteria

- Every presented escalation has a recorded decision (or an explicit DEFERRED status),
  a registry entry, and a queue move.

## Failure Modes

- **Human unavailable** → mark items DEFERRED with date; never auto-resolve.
- **Decision contradicts the constitution** → surface the conflict explicitly; the
  resolution path is a constitutional amendment, not a silent exception.
