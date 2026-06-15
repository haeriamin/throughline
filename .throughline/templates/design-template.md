# Design: [FEATURE NAME]

**Slice ID**: [NNN-short-name]
**Target**: [target-id]
**Author**: ArchitectAgent
**Status**: Draft | Approved
**Created**: [DATE]

> Required for HIGH and CRITICAL complexity slices (ARCHITECTURE.md §12.1).
> Must be human-approved before /throughline.tasks.

## Context

[Problem restated from the spec; constraints from analysis; why design attention is warranted]

## Component Design

### Components

| Component | Responsibility | Module/Path (target-relative) | New/Modified |
|-----------|----------------|-------------------------------|--------------|
| [...] | [...] | [...] | [...] |

### Interfaces & Contracts

```
[signatures / API shapes / schemas — the contracts tasks will implement against]
```

### Data Flow

```
[diagram or ordered narrative of how data moves through the components]
```

## Architecture Decision Records

### ADR-[NNN]: [Decision title]

- **Status**: Proposed | Accepted | Superseded by ADR-NNN
- **Context**: [forces at play]
- **Decision**: [what we chose]
- **Alternatives considered**: [and why rejected]
- **Consequences**: [positive and negative]
- **Standard basis**: standards/<file>.md §<RULE-ID>

*(Each accepted ADR is indexed by the Archivist in the target's
`<target>/.throughline/wiki/decision-registry.md`; an ADR with global scope is also promoted to
the framework `wiki/decision-registry.md`.)*

## Security & Failure Analysis *(mandatory for HIGH/CRITICAL)*

- **Trust boundaries crossed**: [...]
- **Failure modes & handling**: [...]
- **Data sensitivity**: [PII? credentials? — CRITICAL class triggers human-led mode]

## Open Questions

- [items requiring /throughline.clarify or human decision before tasks]
