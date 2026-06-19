# /dev.implement

**Agent**: Implementer
**Reads**: `<target>/.throughline/specs/NNN-*/{spec,plan,design,tasks}.md`, the analysis report (`<target>/.throughline/specs/NNN-*/analysis.md`), `targets/<id>.yml`, framework `wiki/**` + `<target>/.throughline/wiki/**`, `/standards/**` + `<target>/.throughline/standards/**` and `/exemplars/**` + `<target>/.throughline/exemplars/**` (via skills)
**Writes**: target source on branch `sdd/<slice-id>` (or with backups under `<target>/.throughline/work-queue/backups/<slice-id>/` for non-git targets); `<target>/.throughline/CHANGELOG.md` (the target-side change record, on the slice branch); `<target>/.throughline/specs/NNN-*/implementation.md` (Decision Records); append to `<target>/.throughline/wiki/log.md`
**Never writes**: `/standards/**`, `/exemplars/**` (framework or any target's `.throughline/standards|exemplars`), target CI/CD config or secrets, the target's default branch

## Preconditions

- Plan exists; tasks exist; analysis report exists and is not stale
  (re-run `/dev.analyze` if the source hash no longer matches).
- HIGH/CRITICAL → `design.md` exists with status `Approved`.
- Analysis confidence ≥ 0.70 (Principle V). Below → escalate, don't implement.
- Reversibility prepared (Principle VI): git target → on branch `sdd/<slice-id>`;
  non-git target → `<target>/.throughline/work-queue/backups/<slice-id>/` ready.

## Steps

1. **Bootstrap** (Principle II) — within this slice, work from the analysis report + plan (they embed the relevant standards/patterns/exceptions) + the target entry; re-read full wiki summaries only if the analysis fingerprint is stale (bootstrap economy).
2. Load `tasks.md`. Execute tasks **in order** (parallel only where marked `[P]`),
   one task = one logical unit (atomicity, ARCHITECTURE.md §12.2).
3. Per task:
   - Fetch the matched pattern + top-ranked exemplars (`pattern-matcher`, `exemplar-retrieval`).
   - Follow the target's detected conventions (from the analysis) wherever standards are silent.
   - For non-git targets: back up each existing file before first modification.
   - Apply the change. Record an **Implementation Decision Record**:
     ```markdown
     ### Task: T00N <name>
     - Spec requirement: <target>/.throughline/specs/NNN-<slice>/spec.md §FR-X
     - Design basis: <target>/.throughline/specs/NNN-<slice>/design.md §<n> (or "n/a — LOW/MEDIUM")
     - Standard clause: standards/<file>.md §<RULE-ID> (org) or .throughline/standards/<file>.md §<RULE-ID> (target-local)
     - Exemplar basis: exemplars/<path> (org) or .throughline/exemplars/<path> (target-local) (or "none exists — pattern-matcher confirmed")
     - Files changed: [...]
     - Confidence: 0.XX
     ```
     The standard clause MUST be a real rule id that exists in the source file (e.g.
     `standards/engineering-standards.md §ENG-02`, or `.throughline/standards/<file>.md §<ID>`
     for a target-local rule), copied from the file — never a
     paraphrased or invented label. The Reviewer re-reads the clause from source and
     issues an automatic **FAIL for citation fraud** if it does not exist or does not
     apply (Principle III). If no clause governs the change, say so explicitly
     (`Standard clause: none — convention-only, see analysis`) rather than inventing one.
   - Mark the task checkbox done in `tasks.md`.
   - Cannot complete confidently → leave safe state + `DEV-STATUS: PARTIAL` annotation
     (Principle IV), entry in `<target>/.throughline/wiki/exception-registry.md` (global-scoped
     entries promote to the framework `wiki/exception-registry.md`), continue with independent tasks.
4. Run the target's `lint_command` (if set); fix violations introduced by this slice.
5. Forbidden at all times (ARCHITECTURE.md §12.5): behavior changes outside spec scope,
   new dependencies not named in the plan, test-surface reduction, comment/doc removal,
   CI/secrets edits.
6. Write `<target>/.throughline/specs/NNN-<slice>/implementation.md`: all Decision Records,
   files-changed list, per-task confidence, rollback procedure, PARTIAL count.
7. **Record the change in the target.** Create or append to `<target>/.throughline/CHANGELOG.md`
   (on the slice branch, so the entry merges atomically with the change). Newest entry first:

   ```markdown
   ## <slice-id> — <short title>
   **Date**: <UTC> | **Branch**: sdd/<slice-id> | **Status**: PENDING REVIEW
   - What changed: <1–3 lines, human-readable>
   - Files: <paths touched>
   - Spec: <target>/.throughline/specs/NNN-<slice>/spec.md · Standards: <RULE-IDs cited>
   ```
   Create the `.throughline/` directory if absent (with a one-line `README` noting it is a
   framework-maintained record). This file is committed in the target — it is the change record
   that travels with the code. The Orchestrator stamps the final verdict here at slice close
   (see `dev.feature.md`); a standalone `/dev.implement` leaves it `PENDING REVIEW`. Skip only if
   the target sets `changelog: off` in `targets/<id>.yml`.
8. Append to `<target>/.throughline/wiki/log.md`. **Do not merge, do not push.** Hand off to `/dev.test`.

## Exit Criteria

- All tasks done or explicitly PARTIAL-annotated; Decision Record per task
  (Principle III); implementation report written; lint clean.
- `<target>/.throughline/CHANGELOG.md` carries an entry for this slice (unless `changelog: off`).

## Failure Modes

- **Task needs an unplanned dependency** → STOP that task; annotate; escalate (plan
  amendment is a human/Architect decision).
- **Pattern has no exemplar and standards underdetermine the approach** → implement the
  minimal compliant version, flag the exemplar gap, lower the task confidence accordingly.
- **>30% of tasks end PARTIAL** → halt the slice and escalate (systemic plan failure).
