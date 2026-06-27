Throughline is a standalone, spec-driven, multi-agent development platform. The constitution at
`.throughline/memory/constitution.md` is supreme law; the rules below are operational refinements. When
anything conflicts with the constitution, the constitution wins.

## Non-Negotiables

1. **No product code in this repo.** Code lives at external paths registered in `targets/<id>.yml`
   (register with the `dev.target` command). Never act on an unregistered path.
2. **`/standards/` and `/exemplars/` are READ ONLY.** They are human-curated. Never write, rename,
   move, or delete files there. On tools with hooks this is blocked automatically; on tools without
   hooks it is your responsibility to honor.
3. **Bootstrap before touching target code** (Principle II): read `wiki/index.md`, then
   `wiki/standards-summary.md`, then `wiki/pattern-library.md`, then `wiki/exception-registry.md`,
   then the active target's `.throughline/wiki/**` delta and `targets/<id>.yml`. Use the
   `standards-retrieval` and `exemplar-retrieval` skills against `/standards/**` + `/exemplars/**`
   plus the target's `.throughline/standards/**` + `.throughline/exemplars/**` (a target rule
   overrides the org rule with the same id); never rely on model-trained convention knowledge.
   Within an active slice, work from the slice's analysis and plan instead of re-reading the full
   wiki (bootstrap economy); the Reviewer still re-reads the standards source (framework or
   target-local).
4. **Cite or don't ship** (Principle III): every change cites its spec requirement
   (`<target>/.throughline/specs/NNN-<slice>/spec.md §FR-X`), its standard clause (`standards/<file>.md §<RULE-ID>`), and an
   exemplar basis when one exists.
5. **Reversible only** (Principle VI): work on branch `sdd/<slice>` (git targets) or back up
   originals first. NEVER merge, push, or commit to a target's default branch without explicit
   human instruction.
6. **Annotate, never silently skip** (Principle IV): unresolved work gets a `DEV-STATUS` block and
   an exception-registry entry.
7. **Log everything** (Principle VII): after any state-changing operation, append slice-phase
   events to the active target's `.throughline/wiki/log.md` and framework operations (ingest,
   audit, register, amendments) to the framework `wiki/log.md`.
8. **Write in plain, simple English** (constitution §Output Language): short sentences, common
   words, explain jargon. Keep ids, citations, paths, and code exact; only the prose is plain.

## Confidence Gates (Principle V)

`confidence = 0.40·test_evidence + 0.35·standards_compliance + 0.25·spec_alignment`

PASS ≥ 0.85 · CONDITIONAL_PASS 0.70–0.84 · FAIL < 0.70 → return to Implementer (max 2 retries),
then escalate. Escalation is a success path — never guess to avoid it.

## Structure

- Lifecycle commands use the `/throughline:*` namespace (specify → clarify → plan → tasks → implement → analyze). Agent commands use `/dev:*`.
- One-shot pipeline: the `dev.feature` command runs the full lifecycle from a single request (empty
  target → greenfield mode: it adds design and scaffold). Full command reference: `COMMANDS.md`.
- Canonical procedure lives in `.throughline/extensions/dev/commands/*.md` runbooks — commands and
  personas are thin adapters. Change behavior in the runbook, never in an adapter.
- Delegate phase work to the matching persona; personas communicate through artifacts (queue files,
  reports), never direct calls.
- Behavioral protocols: `.github/instructions/*.instructions.md` (runtime-neutral; they apply here).
