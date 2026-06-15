# /dev.ideate

**Agent**: Analyst
**Reads**: target source (read-only, path from `targets/<id>.yml` — optional; ideation may precede a target), framework `wiki/**` (+ `<target>/.throughline/wiki/**` when a target is given), `/standards/**` (+ `<target>/.throughline/standards/**`) (via skill), `/exemplars/**` (+ `<target>/.throughline/exemplars/**`) (via skill), any existing analysis note (`<target>/.throughline/specs/NNN-*/analysis.md`)
**Writes**: `work-queue/pending/<topic>-ideation.md` (global backlog; target-qualified when a target is given); append to the framework `wiki/log.md`
**Never writes**: target source, `/standards/**`, `/exemplars/**`, `specs/**` (framework or any target's `.throughline/specs/**`) — ideation commits to nothing

## Purpose

A conversational, read-only thinking step that runs **before** there is a spec. You bring a
rough idea or a problem; the Analyst explores the shape of it — options, trade-offs, risks,
prior art in the target — asks the questions worth answering, and recommends a direction. It
writes an ideation note you can carry into `/throughline`, but it never writes a spec, a branch,
or code. This is the framework-native alternative to "let me think out loud in plain chat":
same freedom, but grounded in your standards and your codebase, and captured as an artifact.

## Arguments

```
/dev.ideate "<rough idea or problem statement>" [target-id]
```
`target-id` is optional. With it, the Analyst grounds ideas in how that codebase actually works;
without it, ideation proceeds from the idea alone (useful before you've even picked a target).

## Preconditions

- None hard. If a `target-id` is given it must be registered (`targets/<id>.yml`, status active).
- Bootstrap is lightweight here (read the constitution + relevant standards for constraints); a
  full fingerprinted analysis is **not** required — that is `/dev.analyze`'s job, run later.

## Steps

1. **Bootstrap** (Principle II, light): load the constitution and the standards/exemplars that
   bear on the idea, so options respect real constraints from the start.
2. **Frame the problem.** Restate the idea as the problem to solve and the outcome wanted.
   Name what is explicitly *out* of scope for this thinking session.
3. **Ground (if a target is given).** Run `codebase-mapper` over the plausibly-affected area
   and `pattern-matcher` for relevant prior art — enough to make options realistic, not a full
   analysis. Note existing conventions that would constrain any approach.
4. **Generate 2–4 distinct approaches.** For each: a one-paragraph sketch, the main pros and
   cons, the risks (especially security/contract/data — flag CRITICAL domains early), a rough
   complexity class and effort, the standards/patterns it would lean on, and its open questions.
   Options should be genuinely different, not three flavors of one idea.
5. **Ask the questions that matter.** Surface the unknowns whose answers would change the choice
   (users, constraints, scale, existing commitments). This step is a dialogue — expect to iterate.
6. **Recommend.** State which option you'd pursue and why, with the trade-off you're accepting.
   If the idea touches auth, payments, or personal data, say plainly that it will route CRITICAL
   (human-led) once specced.
7. **Write the ideation note** (`work-queue/pending/<topic>-ideation.md`, target-qualified `work-queue/pending/<target>-<topic>-ideation.md` when a target is given):

   ```markdown
   ## Ideation: <topic>
   **Target**: <id or "none yet"> | **Date**: ... | **Status**: exploring
   - Problem / desired outcome: ...
   - Out of scope (for now): ...
   - Option A — <name>: sketch · pros · cons · risks · ~complexity · patterns/standards · open Qs
   - Option B — ...
   - (Option C/D ...)
   - Open questions for the human: ...
   - Recommendation: <option> — rationale + accepted trade-off
   - Suggested next step: /throughline "<recommended direction>" (target: <id>)
   ```
8. Append to `wiki/log.md`.

## Exit Criteria

- An ideation note exists with at least two distinct options, their trade-offs and risks, the
  open questions, and a recommended direction with an explicit next-step pointer.
- Nothing was written outside `work-queue/` and the log — no spec, no branch, no target edits.

## Handoff

Ideation deliberately stops at a recommendation. When you've chosen, start the lifecycle with
`/throughline "<direction>" (target: <id>)` (or `/dev.feature`), which will re-derive a proper
fingerprinted `/dev.analyze` and a real spec. The ideation note is grounding input, not a spec.

## Failure Modes

- **Idea is actually a question, not a change** ("what does X do?") → answer it directly and note
  that no slice is warranted; don't manufacture options.
- **Idea is already well-specified and small** → say so and point straight to `/dev.feature`
  (optionally `--micro`); don't pad it into a multi-option study.
- **Target path unreachable** (when an id is given) → proceed idea-only and note that grounding
  was skipped, rather than reasoning over a stale local copy.
