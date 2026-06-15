# Tasks: [FEATURE NAME]

**Slice ID**: [NNN-short-name]
**Target**: [target-id]
**Plan**: [link to plan.md]
**Created**: [DATE]

> This task list lives at `<target>/.throughline/specs/[NNN-short-name]/tasks.md`, beside its
> `spec.md` and `plan.md`.
>
> Rules (constitution + ARCHITECTURE.md §12.2):
> - Each task = one logical unit of behavior, independently testable and reversible.
> - Order: scaffolding → interfaces/contracts → core logic → integration → tests hardening → docs.
> - Every task names its spec requirement and standard clause up front (Principle III).
> - Mark [P] for tasks safe to parallelize (no shared files, no ordering dependency).

## Phase 1: Setup

- [ ] **T001** [description] — *FR-XXX; standards/<file>.md §<RULE-ID>; files: [...]*

## Phase 2: Interfaces & Contracts

- [ ] **T002** [description] — *FR-XXX; standard §; files: [...]*

## Phase 3: Core Logic

- [ ] **T003** [description] — *FR-XXX; standard §; files: [...]*
- [ ] **T004** [P] [description] — *FR-XXX; standard §; files: [...]*

## Phase 4: Integration

- [ ] **T005** [description] — *FR-XXX; standard §; files: [...]*

## Phase 5: Tests Hardening

- [ ] **T006** Cover [behavior] with [test layer] — *SC-XXX; standards/testing-standards.md §<RULE-ID>*

## Phase 6: Documentation

- [ ] **T007** [docs to update in the target] — *FR-XXX*

## Dependency Notes

- T003 blocks T005; [...]

## Definition of Done (per task)

- Implementation Decision Record written (Principle III)
- Target test command exits 0
- No DEV-STATUS: PARTIAL annotations left unlogged
