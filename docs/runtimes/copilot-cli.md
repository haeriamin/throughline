# Throughline with GitHub Copilot CLI (preview)

GitHub Copilot CLI (the `copilot` terminal agent) reuses the same `.github/` surface the framework already generates — so the knowledge and lifecycle work with no new wiring:

- **Custom instructions**: `.github/copilot-instructions.md` + `.github/instructions/**/*.instructions.md` + root `AGENTS.md` (Copilot CLI loads and combines all three).
- **Custom agents**: `.github/agents/*.agent.md` — the eight personas and the `dev.*` / `throughline.*` command agents. Copilot CLI auto-delegates to them, or you invoke one explicitly.
- **Skills**: the framework's `.github/skills/`.

> **Preview.** Two differences from the VS Code Copilot adapter:
> 1. Copilot CLI has **no custom slash commands**, so you drive the lifecycle through the **agents** (below), not `/dev.feature`.
> 2. On the CLI a `preToolUse` hook exit code `2` is a non-blocking **warning** (a denial needs a `permissionDecision` response or a non-zero exit ≠ 2). The shared guard scripts `exit 2`, so the read-only `/standards/` guard and the no-push rule are **instructed** (via `AGENTS.md` / `.github/copilot-instructions.md`) but **not yet hook-enforced** on the CLI. See [Verification](#verification-why-this-is-preview).

## Setup

```bash
bash tools/install.sh --tool copilot-cli
powershell -ExecutionPolicy Bypass -File tools/install.ps1 -Tool copilot-cli
```

This emits `.github/hooks/copilot-cli.json` (the CLI hook config — cross-OS in one file, with both `bash` and `powershell` commands) and regenerates the shared `.github/` content + `AGENTS.md`.

Install Copilot CLI itself with `npm install -g @github/copilot` (or see GitHub's docs), then run `copilot` in the repo and accept the trusted-directory prompt.

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

Confirm these on a live Copilot CLI before treating the guards as enforced:

1. **`PreToolUse` denial.** The shared guard scripts `exit 2` to block, which Copilot CLI treats as a *warning*, not a denial. Real denial needs the hook to emit `{"permissionDecision":"deny", "permissionDecisionReason":"…"}` on stdout (or exit non-zero ≠ 2, which is fail-closed). Until a deny-translation is wired and tested, treat the read-only `/standards/` guard and the no-push rule as **instructed, not enforced** on the CLI.
2. **`PostToolUse` logging/lint** (`log-tool-use`, `check-code-quality`) run after edits and should work as-is.

The hook config (`.github/hooks/copilot-cli.json`) uses PascalCase event names (`PreToolUse` / `PostToolUse`) so the payload uses the VS Code-compatible `tool_name` / `tool_input` fields the shared scripts already parse, and Claude-style matchers (`Bash`, `Edit|Write|Create`).

More: [GitHub Copilot CLI docs](https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli) · [hooks reference](https://docs.github.com/en/copilot/reference/hooks-reference).
