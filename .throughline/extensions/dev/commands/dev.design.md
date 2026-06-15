# /dev.design

**Agent**: Architect
**Reads**: `<target>/.throughline/specs/NNN-*/spec.md`, the analysis report (`<target>/.throughline/specs/NNN-*/analysis.md`), framework `wiki/**` + `<target>/.throughline/wiki/**`, `/standards/**` + `<target>/.throughline/standards/**` (via skill), target source (read-only)
**Writes**: `<target>/.throughline/specs/NNN-*/design.md`; this-target ADR index entries in `<target>/.throughline/wiki/decision-registry.md` (global-scoped ADRs in the framework `wiki/decision-registry.md`; via Archivist-format `wiki-writer`); append to `<target>/.throughline/wiki/log.md`
**Never writes**: target source, `/standards/**`, `/exemplars/**`

## Preconditions

- Spec exists and is clarified (no `[NEEDS CLARIFICATION]` markers).
- Analysis report exists at `<target>/.throughline/specs/NNN-*/analysis.md` (run `/dev.analyze` first).
- Required for HIGH/CRITICAL complexity; optional otherwise.

## Steps

1. **Bootstrap** (Principle II — full sequence).
2. Load spec + analysis. Restate constraints; identify the design-relevant forces
   (contracts, data flow, trust boundaries, failure modes).
3. Produce `design.md` from `.throughline/templates/design-template.md`:
   - Component table (target-relative paths, new/modified).
   - Interfaces & contracts — concrete signatures/schemas tasks will implement against.
   - Data flow.
   - One ADR per consequential decision (alternatives + consequences + standard basis).
   - Security & failure analysis (mandatory at this complexity).
4. Index each accepted ADR in `<target>/.throughline/wiki/decision-registry.md` (promote a
   global-scoped ADR to the framework `wiki/decision-registry.md`):
   `| ADR-NNN | <title> | <slice> | <target> | Accepted | <date> | .throughline/specs/NNN-*/design.md |`
5. List Open Questions; if any block tasking, mark the design `Draft` and route to
   `/throughline.clarify` or human review.
6. Append to `<target>/.throughline/wiki/log.md`.

## Exit Criteria

- `design.md` complete; every ADR cites a standard basis; CRITICAL slices explicitly
  mark which parts are human-led (constitution §Agent Boundaries).
- Design status `Approved` requires explicit human approval — the Architect never
  self-approves for HIGH/CRITICAL.

## Failure Modes

- **Spec ambiguity discovered** → do not design around it; emit `[NEEDS CLARIFICATION]`
  back into the spec flow and stop.
- **No compliant design exists under current standards** → escalate with the conflicting
  clauses cited; candidate for `<target>/.throughline/wiki/exception-registry.md` (or the framework registry if global-scoped).
