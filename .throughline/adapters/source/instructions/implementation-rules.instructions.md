# Implementation Rules
> Loaded by ImplementerAgent at runtime. These rules govern ALL code-writing decisions.

---

## Cardinal Rules

1. ❌ NEVER implement without a completed Analyst report (and an Approved design.md for HIGH/CRITICAL)
2. ✅ ALWAYS cite spec requirement + standard clause for every change; exemplar basis when one exists (Principle III)
3. ✅ ALWAYS work on branch `sdd/<slice>` (git targets) or back up originals to `<target>/.throughline/work-queue/backups/<slice>/` first (non-git) — Principle VI
4. ❌ NEVER produce a change with confidence < 0.70 without flagging it for review
5. ❌ NEVER modify target CI/CD config, secrets, `.git/` internals, or files outside the target root
6. ❌ NEVER add a dependency not named in the plan — stop the task and escalate instead
7. ❌ NEVER delete code, reduce test surface, or remove comments/docs — annotate instead
8. ✅ ALWAYS follow the target's detected conventions where standards are silent
9. ✅ ALWAYS address the target by its absolute path — run git as `git -C <target-path> …` and read/write target files by absolute path. Your working directory is the **framework repo root**; never `cd` into the target. On a single persistent shell (e.g. Copilot CLI) a `cd` into the target silently breaks every later framework-repo path (`work-queue/`, `wiki/log.md`).

---

## Change Application Order (within a slice)

1. **Scaffolding** (directories, config — lowest coupling)
2. **Interfaces & contracts** (types, schemas, signatures)
3. **Core logic**
4. **Integration** (wiring, composition roots)
5. **Tests hardening** (with the Tester)
6. **Documentation**

---

## Unresolved Work (Principle IV)

When a task cannot be completed at confidence ≥ 0.70:

1. Leave the code in a SAFE state (compiles, tests run, no half-wired behavior)
2. Wrap with a DEV-STATUS annotation (comment syntax of the target language; structure fixed):

```text
/* ============================================================
   DEV-STATUS: PARTIAL | UNRESOLVED
   Requirement: <target>/.throughline/specs/NNN-<slice>/spec.md §FR-X
   Reason: <specific reason>
   Confidence: 0.XX (below threshold)
   Standard: standards/<file>.md §<RULE-ID> applies
   Wiki: [[wiki/concepts/<relevant-page>]]
   Action Required: Human review before finalizing
   Logged: <target>/.throughline/work-queue/escalated/<slice>-escalation.md
   ============================================================ */
```

3. Add the entry to `<target>/.throughline/wiki/exception-registry.md` (global-scoped entries promote to the framework `wiki/exception-registry.md`) and (if BLOCKING) the escalation artifact
4. Continue with independent tasks; >30% PARTIAL → halt the slice and escalate

---

## Atomicity

One task = one logical unit of behavior, independently testable and reversible. Never merge two concerns into one task's change; never split one behavior across tasks in a way that leaves intermediate states broken.

---

## Confidence Calculation (per task)

```
confidence = 0.40·test_evidence + 0.35·standards_compliance + 0.25·spec_alignment
```

At implementation time, `test_evidence` is the Implementer's estimate of coverage achievable; the Reviewer replaces it with measured evidence from the Tester's report. Tasks below 0.70 are individually flagged even if the slice overall passes.

---

## Pre-Handoff Self-Check

- [ ] Every task is done or explicitly PARTIAL-annotated — nothing silently skipped
- [ ] Every task has an Implementation Decision Record
- [ ] Lint command (if configured) exits 0
- [ ] Branch/backup rollback path documented in the implementation report
- [ ] `tasks.md` checkboxes reflect reality
