# /dev.analyze

**Agent**: Analyst
**Reads**: target source (read-only, path from `targets/<id>.yml`), framework `wiki/**` + the active target's `<target>/.throughline/wiki/**`, `/standards/**` + `<target>/.throughline/standards/**` (via skill), `/exemplars/**` + `<target>/.throughline/exemplars/**` (via skill), active `<target>/.throughline/specs/NNN-*/spec.md`
**Writes**: slice mode → `<target>/.throughline/specs/NNN-<slice>/analysis.md`; bulk discovery → `work-queue/pending/` (global backlog); append to `<target>/.throughline/wiki/log.md` (slice mode) or the framework `wiki/log.md` (bulk discovery)
**Never writes**: target source, `/standards/**`, `/exemplars/**`, `wiki/**` content (framework or target) except the applicable log

## Arguments

```
/dev.analyze <target-id> [scope]     # scope: path glob, module, or "full"
```
Inside a slice, target and scope come from the active `spec.md`.

## Preconditions

- Target registered (`targets/<id>.yml` exists, status active).
- For slice analysis: spec exists.

## Steps

1. **Bootstrap** (Principle II — full sequence including target context). Bootstrap economy governs
   *wiki* re-reads only — reading the target's own source to learn its real patterns is a separate,
   expected cost this phase pays in full (it is exactly what the analysis report then captures so
   later phases needn't repeat it).
2. Run the `codebase-mapper` skill over the scope → module inventory JSON.
3. For the slice requirements (or the whole scope in bulk mode):
   - Identify affected modules + dependency fan-out.
   - Detect existing conventions (naming, structure, error handling) — these constrain the Implementer.
   - Run `compliance-checker` for pre-existing standards violations (informational; out of slice scope unless the spec says otherwise).
   - Run `pattern-matcher` for each implementation need → matched PAT entries + exemplars.
4. Classify complexity (LOW/MEDIUM/HIGH/CRITICAL per ARCHITECTURE.md §12.1). HIGH/CRITICAL → note that `/dev.design` is required before tasks.
5. Compute analysis confidence (coverage of requirements by matched patterns + clarity of the codebase map).
6. Write the report:

   ```markdown
   ## Analysis: <target-id> / <scope>
   **Slice**: NNN-<slice> | **Date**: ... | **Source hash**: <git rev or file-count+mtime fingerprint>
   - Complexity Class: ... (rationale)
   - Affected Modules: ...
   - Dependency Map: ...
   - Existing Conventions Detected: ...
   - Standards Violations (pre-existing): ...
   - Matched Patterns: PAT-NNN → exemplars/...
   - Unmatched Needs: ... (exemplar gaps — Auditor concern)
   - Risk Register: ...
   - Recommended Approach: ...
   - Confidence: 0.XX
   ```
7. Append to the log: `<target>/.throughline/wiki/log.md` in slice mode, the framework `wiki/log.md` in bulk-discovery mode.

## Exit Criteria

- Report exists with all sections populated; complexity class justified; confidence stated.

## Failure Modes

- **Target path unreachable** → stop; report; do not analyze stale local copies.
- **Scope matches nothing** → report empty scope rather than widening it silently.
- **Confidence < 0.70** → still write the report, but mark `ESCALATION-RECOMMENDED` and create the escalation report `<target>/.throughline/work-queue/escalated/<slice>-escalation.md` per the escalation protocol (the lightweight live work item stays in the global `work-queue/`).
