# What works today, and what does not

**v0.1 — experimental.** Try it, measure it, and tell us what breaks. Please read this before you use it for real work.

## What it is

It is a self-contained spec-driven development platform: lifecycle commands (`/throughline.*`), agent commands (`/dev.*`), standards, and multi-agent review gates — all in one repo. It drives your AI coding tool. Canonical content lives under `.throughline/adapters/source/`; after clone, run `tools/install.sh` (or `install.ps1`) to generate your tool's wiring locally — generated adapter folders are not committed to git.

Only a small part of the framework is executable code (the write-safety hooks, the helper
scripts, the dashboard). Most of the framework is written instructions that the model follows. So how
well it works depends on how well the model follows instructions — helped by an independent
review step and by hooks that block unsafe actions, not by a program that forces every rule.

## Which tools work today

Adapters are generated from `.throughline/adapters/source/`, so the list grows by adding a profile, not
by hand-porting. Tiers describe how much the tool can *enforce* (see
[`docs/runtimes/README.md`](docs/runtimes/README.md)).

| Tool | Tier | Status |
|------|------|--------|
| GitHub Copilot | A (enforced) | **Supported** |
| GitHub Copilot CLI | A (enforced) | Preview — reuses the `.github/` surface; `preToolUse` guard enforcement advisory until verified (`docs/runtimes/copilot-cli.md`) |
| Claude Code | A (enforced) | **Supported** |
| Codex | A (enforced) | Preview — one delegation behaviour to verify (`.codex/VERIFICATION.md`) |
| Cursor | A (enforced) | Preview — hooks ship fail-open until verified (`.cursor/VERIFICATION.md`) |
| Antigravity | A (enforced) | Preview — hook matchers best-effort until verified (`.agents/VERIFICATION.md`) |
| OpenCode | A (enforced) | Preview — declarative permissions until verified (`.opencode/VERIFICATION.md`) |
| Qwen Code | A (enforced) | Preview — settings permissions until verified (`.qwen/VERIFICATION.md`) |
| Kimi Code | A (enforced) | Preview — hook matchers best-effort until verified (`.kimi/VERIFICATION.md`) |
| Aider | B (rules-only) | Rules-only — guards are advisory |
| Windsurf | B (rules-only) | Rules-only — guards are advisory |

## What is enforced vs. only instructed

Before you rely on something, check which row it is in.

| Part | How strong |
|------|------------|
| `/standards/` and `/exemplars/` are read-only (file + shell hooks) | **Enforced** — blocked by a hook; a determined agent could still find a way, but not by accident. Works on Windows, macOS, and Linux with no Python (`tools/install` or `tools/setup-hooks.{ps1,sh}` once; the declarative read-only guard is on even before that) |
| Agents cannot `git push` or `merge` (shell hook + you merge) | **Enforced** — on every OS, for Tier A tools |
| Rules that name a `Tool:` (linter, security scan, audit) | **Enforced** — uses the real tool's output |
| Rules without a `Tool:` | **Only instructed** — the model judges them; results can vary |
| Confidence score, startup reads, citations, notes | **Only instructed** — backed by the review step, not by a program |
| Builder ≠ reviewer | Real but limited — it is the same model on both sides, not two people |

## What is proven, and what is not

- **Proven**: it runs from start to finish (two example tasks). In a 3-task side-by-side test
  against a plain one-shot, the review step caught **a real bug in all three** — including a
  release candidate treated as newer than the final release, and a money split that loses a
  cent. Each plain version had passed its own tests. See [`docs/validation-runs/`](docs/validation-runs/).
- **Not proven**: three tasks is not a large test, and all three had tricky edge cases on
  purpose (a simple task gives the review step nothing to find). We have not measured speed
  or cost. And the "two checkers catch more" idea is untested, because it was one model
  playing every role.

## When it is worth it

Use it when a clear record and a strong review matter more than raw speed: regulated work,
several developers using agents, or code that will be audited. It is too heavy for throwaway
scripts — there, use `--micro`, the single-step commands, or plain Copilot.

## Measure it yourself

The value is just a claim until you test it on your own work. [`docs/10-validation.md`](docs/10-validation.md)
shows how to run a fair side-by-side test. Sharing your results is the most useful thing you can give this project.
