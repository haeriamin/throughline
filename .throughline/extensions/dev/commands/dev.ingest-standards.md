# /dev.ingest-standards

**Agent**: Archivist
**Reads**: `/standards/**`, `wiki/**` (with a `[target-id]`: also `<target>/.throughline/standards/**` and `<target>/.throughline/wiki/**`)
**Writes**: global mode → `wiki/standards-summary.md`, `wiki/concepts/*`, `wiki/index.md`; target mode (`[target-id]`) → the target delta under `<target>/.throughline/wiki/` (never the global wiki); append to `wiki/log.md` (framework)
**Never writes**: `/standards/**`, `/exemplars/**` (framework or any target's `.throughline/standards|exemplars`)

## Arguments

```
/dev.ingest-standards [target-id]      # omit for the org-wide standards
```

Without a target, this compiles the org `/standards/` into the global wiki (behavior unchanged).
With a `target-id`, it compiles **only** that target's local `<target>/.throughline/standards/**`
into a delta under `<target>/.throughline/wiki/` (target rules override org rules by rule id); the
global wiki is untouched.

## Preconditions

- At least one `.md` file exists under `/standards/` (or, with a `target-id`, under `<target>/.throughline/standards/`).

## Steps

1. **Bootstrap** (Principle II, steps 1–3).
2. Inventory `/standards/*.md` (target mode: `<target>/.throughline/standards/*.md`). For each,
   use the `standards-retrieval` skill to extract:
   Standard ID, effective date, applicability, and every Rule (id, severity, description, check).
3. **Diff against prior state**: compare with the existing `wiki/standards-summary.md`
   (target mode: the target delta `<target>/.throughline/wiki/standards-summary.md`)
   (rule added / removed / severity changed / check changed).
4. Rewrite `wiki/standards-summary.md` (target mode: `<target>/.throughline/wiki/standards-summary.md`):
   - One section per standard doc, one table row per rule:
     `| Rule | Severity | Applies To | Check | Source |` with source as `standards/<file>.md §<RULE-ID>` (target mode: `.throughline/standards/<file>.md §<RULE-ID>`).
   - Header records ingest timestamp + source file list.
5. For substantial topics, create/update `wiki/concepts/<topic>.md` (target mode: `<target>/.throughline/wiki/concepts/<topic>.md`) via `wiki-writer`.
6. **Change propagation**: for each changed rule, list completed slices that cited it
   (search each target's `<target>/.throughline/review-reports/` and
   `<target>/.throughline/specs/`); record the list in the log entry so the
   Auditor can surface re-validation candidates via `/dev.audit`.
7. Update `wiki/index.md` links (target mode: `<target>/.throughline/wiki/index.md`). Append to the framework `wiki/log.md`.

## Exit Criteria

- Every rule in `/standards/` appears in the summary with a precise source citation.
- Diff summary reported (added/removed/changed counts).

## Failure Modes

- **Malformed standard doc** (missing Rule structure) → ingest what parses; list the
  malformed sections in the log and report them to the human. Never guess rule content.
- **Conflicting rules across docs** → record both, flag the conflict in
  `wiki/exception-registry.md` (target mode: `<target>/.throughline/wiki/exception-registry.md`)
  as PENDING-HUMAN, and report. Do not pick a winner.
