# /dev.feature

**Agent**: Orchestrator (drives; delegates every phase to its owning persona)
**Reads/Writes**: only through the phase commands it invokes, plus global `work-queue/**` live-work-item state moves, `<target>/.throughline/wiki/log.md` appends (slice lifecycle), and the verdict stamp on `<target>/.throughline/CHANGELOG.md` at slice close (step 11)
**Never**: performs analysis/design/implementation/testing/review itself; merges or pushes (Principle VI)

Single point of input for building software — a feature on an existing codebase, or a
brand-new project on an empty target. Inline runner for the `dev-feature` workflow
(auto-switching to the `dev-greenfield` shape when the target is empty) — one request
in, a reviewed, merge-ready branch out.

## Arguments

```
/dev.feature <target-id> "<feature description>" [--express] [--micro] [--audit]
```

- `--express` — skip the optional spec/plan approval gates (LOW/MEDIUM complexity only).
- `--micro` — collapsed lane for genuinely small changes (see below).
- `--audit` — run `/dev.audit` after completion.

**Default autonomy.** A plain `/dev.feature` (no flags) runs the whole pipeline autonomously
**except** the constitutional human pauses listed below — it still stops at the spec gate (step 3)
and plan gate (step 6) for an approve/reject. `--express` drops *only those two* gates (LOW/MEDIUM
only); it never drops clarification, HIGH/greenfield design approval, CRITICAL hand-over,
escalations, or the merge. So "one request in, merge-ready branch out" means *unattended between
gates*, not *zero checkpoints*. For a single hands-off run on a small change, combine `--express`
(or `--micro`) with a description detailed enough to pre-answer the gates.

## Choosing a lane (ceremony should match risk)

The full pipeline is overkill for a one-line fix and essential for a payments change.
After bootstrap + analysis, the Orchestrator picks — or the user forces — a lane:

| Lane | When | Pipeline |
|------|------|----------|
| **micro** | Analysis class LOW, single file, no *breaking* contract/schema/security surface (a small additive export is fine), no new dependency. Forced with `--micro`; auto-offered when criteria met. | Tiny inline spec (one paragraph in the work item, not a `specs/` folder) → `/dev.implement` → `/dev.test` → `/dev.review`. Skips clarify/plan/design/tasks. |
| **standard** | Default. LOW/MEDIUM. | The full pipeline below, gates per `--express`. |
| **deep** | HIGH (design) or CRITICAL (human-led). | Full pipeline; design mandatory; CRITICAL stops for human lead. |

micro still produces a cited Decision Record, real test evidence, an independent review,
and a `sdd/<slice>` branch — it drops the *planning paperwork*, never the *gates or the
audit trail*. If a micro slice turns out to make a breaking contract change or touch a
security surface mid-flight, the Orchestrator aborts micro and restarts it in the standard
lane. `--micro` is refused for anything analysis classes MEDIUM or above.

## Preconditions

- Target registered and active (`targets/<id>.yml`). Not registered → STOP and instruct:
  `/dev.target register <path>`. Never register implicitly.
- Parallelism cap: < 3 slices in-progress (constitution-aligned; check `work-queue/in-progress/`).

## Resume Detection (idempotent)

Before starting, check for an in-flight slice matching this target + description
(`work-queue/in-progress/` work items + `.throughline/feature.json`). If found, report its
state and continue from the first missing artifact (spec → plan → design → tasks →
implementation → test report → review) instead of re-specifying.

## Mode Detection

After bootstrap, classify the target:

- **Feature mode** — the target contains source code.
- **Greenfield mode** — the target path is empty or contains only `.git/` and dotfiles
  (typically registered via `/dev.target register <path> --new`).

Record the mode in the work item. Greenfield mode changes the pipeline in exactly two
ways: design becomes mandatory (step 5) and scaffold runs before implementation (step 8).

## Pipeline

0. **Bootstrap** (Principle II — full sequence). Create the work item in
   `work-queue/pending/` from `.throughline/templates/work-item-template.md` (status: PENDING),
   then move to `in-progress/` as phases start.
1. **Specify** — `/throughline.specify "<description> (target: <id>)"`. Slice numbers are
   **per target**: allocate as **max(existing `<target>/.throughline/specs/NNN-*` and this
   target's `<target>-NNN-*` live items across every `work-queue/` lane) + 1**, zero-padded —
   scan both the target's `.throughline/specs/` and the global `work-queue/` lanes (filtered to
   this target's qualifier) so a concurrent in-progress slice can't grab the same `NNN` (the
   parallelism cap allows up to 3). If the chosen `<target>/.throughline/specs/NNN-*` already
   exists, bump and retry. The global live work item is target-qualified `<target>-NNN-<slice>`.
2. **Clarify** — `[NEEDS CLARIFICATION]` markers present → `/throughline.clarify` and **wait
   for the user's answers**. Constitutional; `--express` cannot skip it.
3. **Spec gate** *(skipped by `--express`)* — present a 5-line spec summary
   (target, scope, FR count, success criteria, out-of-scope); wait for approve/reject.
4. **Plan** — `/throughline.plan` (its `before_plan` hook runs `/dev.analyze`).
5. **Design routing** — analysis class HIGH **or greenfield mode** (stack and project
   layout are ADRs) → `/dev.design` then **wait for human approval** of `design.md`
   (never skipped, `--express` included). Class CRITICAL → STOP the pipeline entirely:
   report that the slice is human-led (constitution §Agent Boundaries) and hand over
   with the artifacts produced so far.
6. **Plan gate** *(skipped by `--express`)* — present plan confidence + risk register;
   wait for approve/reject/escalate.
7. **Tasks** — `/throughline.tasks`.
8. **Scaffold** *(greenfield mode only)* — `/dev.scaffold`: project skeleton with the
   target's test and lint commands verified green before any feature code.
9. **Implement** — `/throughline.implement`, which chains `/dev.implement` → `/dev.test` →
   `/dev.review` (mandatory `after_implement` hook).
   - Reviewer FAIL → return findings to `/dev.implement`; **max 2 retry cycles**, then
     `/dev.review-escalated` and STOP (Principle V).
10. **Audit** *(only with `--audit`)* — `/dev.audit <target-id>`.
11. **Stamp the target change record.** Update this slice's entry in
    `<target>/.throughline/CHANGELOG.md` (created by `/dev.implement`): set `Status` to the
    terminal verdict (`PASS` / `CONDITIONAL_PASS` / `FAIL`, with confidence) and add the merge
    note. On a clean FAIL after retries, record `FAIL — escalated`. **Commit this update onto the
    `sdd/<slice>` branch.** Stage new **and** modified files first — the `.throughline/CHANGELOG.md`
    and `README.md` created during the slice are untracked, so `commit -am` would silently drop
    them: `git -C <target> add -A && git -C <target> commit -m "throughline: <slice> <verdict>"`.
    The stamped verdict then travels with the branch into the human's merge — an uncommitted stamp
    would be lost and the merged record would read `PENDING REVIEW`. This is a target write on the slice
    branch; it is lifecycle bookkeeping, so the Orchestrator owns it (the Reviewer stays read-only
    on the target). Never push or merge. Skip if the target sets `changelog: off`.
12. **Final report** (single message):
    - Verdict + confidence with the three sub-scores
    - Branch name (`sdd/<slice>`) + exact human merge instructions + rollback procedure
    - Artifact links: spec, plan, design (if any), tasks, scaffold report (greenfield),
      implementation report, test report, review report
    - PARTIAL/escalation count; flagged items if CONDITIONAL_PASS
    - `<target>/.throughline/wiki/log.md` entries appended

## Human Pauses (constitutional — never skipped)

Clarification answers (step 2) · HIGH/greenfield design approval (step 5) · CRITICAL
hand-over (step 5) · escalations (step 9) · merge/push (always).

## Failure Modes

- **Any phase fails or stops** → report the exact state, what completed, and the resume
  path (re-run `/dev.feature` — resume detection picks up where it left off).
- **Spec/plan gate rejected** → record the reason in the work item, move it to
  `work-queue/escalated/` only if the user asks for rework via escalation; otherwise
  leave in-progress for a revised run.
- **>3 slices in-progress** → refuse with the list of active slices.
