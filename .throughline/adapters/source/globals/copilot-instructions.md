# Throughline — Global Copilot Instructions

Standalone, spec-driven, multi-agent development platform. **The constitution at `.throughline/memory/constitution.md` is supreme law**; these rules are operational refinements.

<!-- THROUGHLINE START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
at `<target>/.throughline/specs/<active-feature>/plan.md` and the constitution at
`.throughline/memory/constitution.md` before answering.
<!-- THROUGHLINE END -->

## Non-Negotiables

1. **No product code in this repo.** Code lives at external paths registered in `targets/<id>.yml` (register via `/dev.target` — it generates `targets/<id>.code-workspace`; open that workspace to edit the target). Never operate on an unregistered path.
2. **`/standards/` and `/exemplars/` are READ ONLY** (PreToolUse hook enforced). Human curation only.
3. **Bootstrap before touching target code** (Principle II): read `wiki/index.md` → `wiki/standards-summary.md` → `wiki/pattern-library.md` → `wiki/exception-registry.md` → the active target's `.throughline/wiki/**` delta → `targets/<id>.yml`. Never rely on model-trained convention knowledge — use the `standards-retrieval`/`exemplar-retrieval` skills against `/standards/**` + `/exemplars/**` plus the target's `.throughline/standards/**` + `.throughline/exemplars/**` (a target rule overrides the org rule with the same id). *Within an active slice, work from the slice's analysis + plan instead of re-reading the full wiki (bootstrap economy); the Reviewer still re-reads the standards source (framework or target-local).*
4. **Cite or don't ship** (Principle III): every change cites its spec requirement (`<target>/.throughline/specs/NNN-<slice>/spec.md §FR-X`) + standard clause (`standards/<file>.md §<RULE-ID>`) + exemplar basis when one exists.
5. **Reversible only** (Principle VI): work on branch `sdd/<slice>` (git targets) or back up originals first. NEVER merge, push, or commit to a target's default branch without explicit human instruction.
6. **Annotate, never silently skip** (Principle IV): unresolved work gets a `DEV-STATUS` block + exception-registry entry.
7. **Log everything** (Principle VII): after any state-changing operation, append slice-phase events to the active target's `.throughline/wiki/log.md` and framework operations (ingest, audit, register, amendments) to the framework `wiki/log.md`.
8. **Write in plain, simple English** (constitution §Output Language): every spec, plan, report, review, wiki page, and code comment uses short sentences and common words. Explain any jargon. Many readers are not native English speakers. Keep ids, citations, paths, and code exact; only the prose is plain.

## Confidence Gates (Principle V)

`confidence = 0.40·test_evidence + 0.35·standards_compliance + 0.25·spec_alignment`

PASS ≥ 0.85 · CONDITIONAL_PASS 0.70–0.84 · FAIL < 0.70 → return to Implementer (max 2 retries), then `/dev.review-escalated`. Escalation is a success path — never guess to avoid it.

## Command Index

- One-shot pipeline: `/dev.feature <target> "<description>"` — full lifecycle from a single request (empty target → greenfield mode: +design +scaffold)
- Lifecycle: `/throughline.constitution` · `/throughline.specify` · `/throughline.clarify` · `/throughline.plan` · `/throughline.tasks` · `/throughline.implement` · `/throughline.analyze` · `/throughline.checklist`
- Dev extension: `/dev.target` · `/dev.ingest-standards` · `/dev.ingest-exemplars` · `/dev.ideate` · `/dev.analyze` · `/dev.design` · `/dev.scaffold` · `/dev.implement` · `/dev.test` · `/dev.review` · `/dev.audit` · `/dev.lint-wiki` · `/dev.review-escalated`
- Full reference (arguments, writes, gates): `COMMANDS.md`

Each command's agent file (`.github/agents/`) carries its description and persona; `/dev.*` hooks into the lifecycle per `.throughline/extensions.yml` (protocol: `.github/instructions/extension-hooks.instructions.md`).

## Personas

Orchestrator (entry point, targets, queue) · Archivist (only wiki writer) · Analyst (read-only analysis) · Architect (design + ADRs) · Implementer (code at target, never merges) · Tester (evidence reports) · Reviewer (independent gate) · Auditor (portfolio). Definitions in `.github/agents/<persona>.agent.md`; cross-agent communication flows through artifacts, never direct calls.

## Structure

- Canonical procedure lives in `.throughline/extensions/dev/commands/*.md` runbooks — agent/prompt files are thin adapters. Change behavior in the runbook, never in an adapter.
- Behavioral protocols: `.github/instructions/*.instructions.md`. Skills: `.github/skills/<name>/SKILL.md` (byte-identical mirror in `.claude/skills/` — this framework is dual-wired for Claude Code via `CLAUDE.md`).
