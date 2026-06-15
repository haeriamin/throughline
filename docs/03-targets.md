# 3 · Managing Targets

Targets are the registered external codebases agents work on — the framework's only
bridge to your code.

## Register an existing project

```bash
/dev:target register path/to/my-app
```

The Orchestrator probes the project (stack, git state, test/lint/build commands from its
manifest — never guessed) and creates:

- `targets/my-app.yml` — the registry entry (path, stack, commands, conventions, status)
- `targets/my-app.code-workspace` — a multi-root VS Code workspace (framework + target);
  **open this when using Copilot** so the target folder is editable
- an `additionalDirectories` entry in `.claude/settings.local.json` (gitignored,
  machine-local) so **Claude Code** can edit the target
- `<target>/.throughline/` — the target's **SDD provenance home**, scaffolded on
  registration: its `specs/`, `review-reports/`, `work-queue/` history, target-scoped
  `wiki/`, and `CHANGELOG.md` live here and travel with the code on the slice branch. You
  can also add target-local `standards/` and `exemplars/` under it — human-curated like the
  org seeds — to override the framework rules by rule-id (matching ids win for this target,
  new ids append).

Options: `--id <name>` to override the derived id, `--stack <csv>` to declare the stack.

## Register a greenfield project

```bash
/dev:target register path/to/new-app --new
```

Creates the directory and runs `git init`. From there, `/dev:feature <id> "<description>"`
detects the empty target and runs greenfield mode automatically — design approval, then
scaffold, then implementation (see [Building Features](04-building-features.md)).

## Inspect, update, list

```bash
/dev:target inspect my-app          # entry + live probe (branch, dirty files)
/dev:target update my-app test_command="npm test"
/dev:target list
```

## The target entry

`targets/<id>.yml` fields worth knowing:

| Field | Meaning |
|-------|---------|
| `test_command` / `lint_command` | What the Tester and Implementer actually run — keep these accurate |
| `complexity_class` | Default complexity for slices on this target |
| `changelog` | `on` (default) / `off` — whether to maintain `<target>/.throughline/CHANGELOG.md` |
| `throughline_dir` | Where the target's SDD provenance lives, relative to the target root (default `.throughline`) |
| `commit_artifacts` | `on` (default) / `off` — commit the `.throughline/` SDD files on the slice branch, or keep them gitignored in the target |
| `conventions` | Free-text notes; the Implementer follows these where standards are silent |
| `exceptions` | Exception-registry ids (EXC-NNN) that apply to this target |
| `status` | `active` / `paused` / `archived` |

Unless `changelog: off`, each slice leaves a human-readable entry in `<target>/.throughline/CHANGELOG.md` — written on the slice branch, so it merges with the change and the codebase keeps its own record of what the framework did and why.

## Safety rules

- Target paths must be **outside** the framework repo.
- Git targets: all agent work happens on branch `sdd/<slice>`; agents never commit to
  your default branch and never push.
- Non-git targets: originals are copied to `<target>/.throughline/work-queue/backups/<slice>/` before any
  modification.
- Personal target entries contain absolute paths — fine for a private fork, don't commit
  them to a shared public repo.

---
[← Core Concepts](02-concepts.md) · Next: [Building Features →](04-building-features.md)
