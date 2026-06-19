# Throughline with GitHub Copilot CLI (preview)

GitHub Copilot CLI (the `copilot` terminal agent) reuses the same `.github/` surface the framework already generates — so the knowledge and lifecycle work with no new wiring:

- **Custom instructions**: `.github/copilot-instructions.md` + `.github/instructions/**/*.instructions.md` + root `AGENTS.md` (Copilot CLI loads and combines all three).
- **Custom agents**: `.github/agents/*.agent.md` — the eight personas and the `dev.*` / `throughline.*` command agents. Copilot CLI auto-delegates to them, or you invoke one explicitly.
- **Skills**: the framework's `.github/skills/`.

> **Preview.** Two differences from the VS Code Copilot adapter:
> 1. Copilot CLI has **no custom slash commands**, so you drive the lifecycle through the **agents** (below), not `/dev.feature`.
> 2. A CLI `preToolUse` exit code `2` is only a **warning**, but a `permissionRequest` exit `2` is a **deny**. The hook config therefore wires the read-only `/standards/`+`/exemplars/` guard and the git push/merge guard under **both** events — advisory on `PreToolUse`, enforcing on `PermissionRequest` — with the same `exit 2` scripts (a non-violation exits `0` and falls through). This is **wired but not yet live-verified** on the CLI; until you confirm it (below), also rely on the instructed rules in `AGENTS.md` / `.github/copilot-instructions.md`. See [Verification](#verification-why-this-is-preview).

## Setup

```bash
bash tools/install.sh --tool copilot-cli
powershell -ExecutionPolicy Bypass -File tools/install.ps1 -Tool copilot-cli
```

This emits `.github/hooks/copilot-cli.json` (the CLI hook config — cross-OS in one file, with both `bash` and `powershell` commands) and regenerates the shared `.github/` content **and root `AGENTS.md`** (the `copilot-cli` profile emits it, so a `--tool copilot-cli` install is self-sufficient — you don't also need `--tool codex`).

Then install the CLI itself and authenticate — a real prerequisite, not a one-liner:

```bash
npm install -g @github/copilot     # the actual CLI binary (the VS Code-bundled `copilot` shim only bootstraps this)
copilot                            # first run: complete the GitHub sign-in, then accept the trusted-directory prompt
```

On a locked-down Windows host the bundled shim can be blocked by PowerShell execution policy; install `@github/copilot` directly as above and run it from a normal shell.

> **Co-installing with the VS Code Copilot adapter.** Copilot CLI loads **every** `.github/hooks/*.json` and combines them. If you also installed `--tool copilot` (which emits `.github/hooks/hooks.json` in the VS Code `command`/`windows` schema, with no `version` field), the CLI may ignore that file (missing `version`) or mis-read it. For a CLI-first checkout, prefer installing `--tool copilot-cli` alone; if you need both, verify on a live CLI that only `copilot-cli.json` is honored.

## First run

Copilot CLI has no `/dev.*` slash commands; drive the lifecycle by asking for the agent by name, or with the `/agent` picker:

```
Use the dev.feature agent for orders-api: "Add cursor pagination to GET /orders"
```

or run a single phase:

```
Use the dev.review agent to review the orders-pagination slice
```

The constitution, runbooks, and standards are all reachable from `.github/` and `AGENTS.md`, so the agents follow the same lifecycle they do on every other host.

## Verification (why this is preview)

The guards are **wired** for enforcement; confirm them on a live Copilot CLI before relying on them:

1. **`PermissionRequest` denial (the enforcement path).** On `permissionRequest` a command-hook `exit 2` is treated as a **deny**, so `validate-immutable-paths` and `validate-bash-safety` (wired under `PermissionRequest`) should block a write to `/standards/` or a `git push`/`merge` outright. Confirm a real attempt is denied, and that ordinary edits (which exit `0`) still pass through.
2. **`PreToolUse` is advisory.** The same scripts under `PreToolUse` only `exit 2` = *warning* on the CLI — that layer surfaces the reason but does not block. (It is also what a Copilot **cloud agent** run sees, where `permissionRequest` does not fire.)
3. **`PostToolUse` logging/lint** (`log-tool-use`, `check-code-quality`) run after edits and should work as-is.

The hook config (`.github/hooks/copilot-cli.json`) uses PascalCase event names (`PreToolUse` / `PermissionRequest` / `PostToolUse`) so the payload carries the VS Code-compatible `tool_name` / `tool_input` fields the shared scripts already parse, with Claude-style matchers (`Bash`, `Edit|Write`).

More: [GitHub Copilot CLI docs](https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli) · [hooks reference](https://docs.github.com/en/copilot/reference/hooks-reference).
