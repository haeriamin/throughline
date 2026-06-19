# /dev.target

**Agent**: Orchestrator
**Reads**: target path (external), `targets/**`, `.claude/settings.local.json`, installed-adapter footprints (`.claude/`, `.codex/`, `.cursor/`, `.agents/`, `.kimi/`, `.opencode/`, `.qwen/`, `.github/`, `AGENTS.md`), `.throughline/integrations/*.manifest.json`
**Writes**: `targets/<id>.yml`, `targets/<id>.code-workspace`, per-tool access config (see step 7); append to `wiki/log.md`
**Never writes**: `/standards/**`, `/exemplars/**`, target source files

## Subcommands

```
/dev.target register <path> [--id <id>] [--stack <csv>] [--new]
/dev.target inspect <id>
/dev.target update <id> <field>=<value> ...
/dev.target list
```

## Steps — register

1. **Bootstrap** (Principle II, steps 1–3; no target yet).
2. Validate `<path>`:
   - Existing project: path must exist and contain files. `--new` flag: path must NOT exist; create it and run `git init`.
   - Refuse paths inside this framework repo (the framework holds no product code).
3. Derive `<id>` (kebab-case of last path segment unless `--id` given). Refuse duplicate ids.
4. **Probe** the project (read-only):
   - VCS: `.git/` present → `vcs: git`, detect default branch; else `vcs: none`.
   - Stack: detect from manifests (`package.json`, `pyproject.toml`, `*.csproj`, `go.mod`, `Cargo.toml`, …).
   - Commands: detect `test_command` / `lint_command` / `build_command`. For npm-style stacks read `package.json` `scripts`; for other stacks read the conventional config — Python: `pyproject.toml`/`tox.ini`/`setup.cfg` (e.g. `pytest`, `ruff`, `tox`); Go: `go test`/`go build`; Rust: `cargo test`/`cargo build`; etc. Leave a field empty if genuinely ambiguous (do NOT guess).
   - **Flag configured-but-unwired tooling**: if the project configures a linter/formatter/SAST (e.g. `ruff`/`eslint`/`pre-commit`) you could not unambiguously map to `lint_command`, record it in `conventions` and note that tool-backed standards (ENG-03, DEL-02) degrade to manual judgement until a human sets `lint_command`. Never leave an available tool silently invisible.
   - **Target-local knowledge**: note whether the project already carries `<target>/.throughline/standards/` or `.throughline/exemplars/` (human-curated overrides). If so, report them and remind the human to run `/dev.ingest-standards <id>` / `/dev.ingest-exemplars <id>` to compile their target delta.
5. Write `targets/<id>.yml` from `.throughline/templates/target-template.yml` with probed values (including `throughline_dir`, default `.throughline`, and `commit_artifacts`, default `on`).
6. Generate `targets/<id>.code-workspace`:
   ```json
   { "folders": [ { "name": "framework", "path": ".." },
                  { "name": "<id>", "path": "<absolute-target-path>" } ] }
   ```
7. **Scaffold the target's provenance home** at `<target>/<throughline_dir>/` (default `.throughline/`) — where the target's SDD work and knowledge live (ARCHITECTURE §3/§4). Create it in the target working tree (do **not** commit — the human commits it, or it travels on the first slice branch):
   - `standards/` and `exemplars/` each with a `.gitkeep` — human-curated, target-local overrides of the org seeds (read-only to agents; the immutable-path hook guards them).
   - `wiki/` seeded with empty-inventory `standards-summary.md`, `pattern-library.md`, `decision-registry.md`, `exception-registry.md`, `log.md` (this target's slice log), and `concepts/.gitkeep`.
   - `specs/.gitkeep`, `review-reports/.gitkeep`, `work-queue/{completed,escalated,backups}/.gitkeep` (slice folders are created lazily by the lifecycle).
   - a short `README.md` explaining the layout, and a `CHANGELOG.md` stub.
   - if `commit_artifacts: off`: also write `<target>/.throughline/.gitignore` ignoring `specs/`, `review-reports/`, `work-queue/` (the generated SDD work) while keeping `standards/`, `exemplars/`, `wiki/`, `CHANGELOG.md`, `README.md` tracked.
   Report the created paths.
8. **Grant target access for each installed tool.** A tool is "installed" when its adapter footprint exists — its manifest (`.throughline/integrations/<tool>.manifest.json`) **or** its generated adapter config (several profiles deliberately emit no manifest, so never rely on the manifest alone): Claude → `.claude/`; Codex → `.codex/` + `AGENTS.md`; Copilot (VS Code) → `.github/copilot-instructions.md`; Copilot CLI → `.github/hooks/copilot-cli.json` + `AGENTS.md`; Cursor → `.cursor/`; Antigravity → `.agents/` + `GEMINI.md`; Kimi → `.kimi/`; OpenCode → `.opencode/` + `opencode.json`; Qwen → `.qwen/` + `QWEN.md`; Aider/Windsurf → their rules bundle. The target path is outside this repo, so each installed tool must be told it may read and write there. Apply only the entries for installed tools; report every change (and explicitly report any tool detected but left unwired).
   - **Claude Code**: add the absolute target path to `permissions.additionalDirectories` in `.claude/settings.local.json` (create with a `permissions` key if absent; merge, don't overwrite). Gitignored — machine paths never land in the shared `settings.json`.
   - **Codex**: Codex sandboxes writes to the workspace root. Add the absolute target path as a writable root in the user's Codex config (`~/.codex/config.toml` → `[sandbox_workspace_write] writable_roots`), or launch Codex with the target as an extra `--cd` root. User-level machine config — print the exact line to add rather than editing it silently.
   - **VS Code-based tools (Copilot in VS Code, Cursor)**: access comes from the multi-root workspace generated in step 6 — `targets/<id>.code-workspace` already lists the target folder. Tell the human to open that workspace. No per-path file is written.
   - **GitHub Copilot CLI**: the CLI reads/writes within the session's trusted directories, and the framework brain (`.github/`, `AGENTS.md`) lives in THIS repo. Tell the human to launch `copilot` from the framework repo root (so it loads the instructions + agents) and add the external target as a trusted/working directory for the session. No per-path file is written here; see `docs/runtimes/copilot-cli.md`.
   - **Antigravity, Kimi, OpenCode, Qwen**: these operate on the folder/workspace the human opens. Point the human at `targets/<id>.code-workspace` (or the tool's open-folder flow); if the tool documents a writable-roots/trusted-dir setting, print the exact line to add and reference the tool's `.<tool>/VERIFICATION.md`. No per-path file is written unless the tool documents one.
   - **Tier B tools (Aider, Windsurf)**: no access model to wire — they operate on whatever folder the human opens. Note this in the report.
9. Append to `wiki/log.md` (framework-level event: registration; record which tools were granted access and that the provenance home was scaffolded).

## Steps — inspect / update / list

- `inspect`: print the yml + live probe (git status, branch, dirty files). Read-only.
- `update`: rewrite only the named fields; log the change.
- `list`: table of id, path, vcs, stack, status.

## Exit Criteria

- `targets/<id>.yml` exists, parseable, with an absolute path that resolves.
- The target's `<throughline_dir>/` provenance home is scaffolded (step 7); workspace file generated; access granted for every installed tool (per step 8); framework log appended.

## Failure Modes

- **Path does not exist (without `--new`)** → report and stop; do not create directories implicitly.
- **Path is inside the framework** → refuse (standalone invariant).
- **Probe ambiguity** → leave fields empty and note them; never invent commands.
