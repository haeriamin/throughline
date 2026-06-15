# /dev.scaffold

**Agent**: Implementer
**Reads**: `<target>/.throughline/specs/NNN-*/{spec,plan,design,tasks}.md`, `targets/<id>.yml`, framework `wiki/**` + `<target>/.throughline/wiki/**`, `/exemplars/**` + `<target>/.throughline/exemplars/**` (via skill)
**Writes**: target project skeleton at the registered path; `<target>/.throughline/specs/NNN-*/scaffold.md`; append to `<target>/.throughline/wiki/log.md`
**Never writes**: `/standards/**`, `/exemplars/**`, anything outside the target root

## Preconditions

- Greenfield target registered with `--new` (or empty directory), `vcs: git` initialized.
- Slice planned and tasked (scaffold tasks appear in `tasks.md` Phase 1).
- Working on branch `sdd/<slice-id>` (create from default branch if absent — Principle VI).
  Use the target's absolute path: `git -C <target-path> checkout -b sdd/<slice-id>`; never `cd` into
  the target (Implementation Rule 9 — keep the shell's cwd at the framework repo root).

## Steps

1. **Bootstrap** (Principle II — full sequence).
2. Create the project skeleton per the plan: directory layout, manifest
   (`package.json`/`pyproject.toml`/…), formatter/linter config, test runner config,
   `.gitignore`, `README.md` stub — each choice citing its standard clause
   (e.g., `standards/engineering-standards.md §ENG-04`).
3. Wire the quality loop FIRST: the target's `test_command` and `lint_command` must
   exit 0 on the empty skeleton before any feature code exists. Update
   `targets/<id>.yml` with the verified commands via `/dev.target update`.
4. Record an Implementation Decision Record per scaffold choice (Principle III).
5. Write `<target>/.throughline/specs/NNN-*/scaffold.md`: tree created, commands
   verified, Decision Records, rollback note (branch name).
6. Append to `<target>/.throughline/wiki/log.md`. **Do not merge** — scaffold goes through `/dev.review`
   like any other implementation.

## Exit Criteria

- Skeleton exists; `test_command` and `lint_command` verified green; report written.

## Failure Modes

- **Target directory not empty** → stop and report (never overwrite an existing project).
- **No standard covers a scaffold choice** (e.g., unconfigured stack) → make the minimal
  choice, annotate `DEV-STATUS: PARTIAL`, and flag the standards gap for the Archivist.
