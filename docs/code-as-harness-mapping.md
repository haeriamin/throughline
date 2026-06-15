# Throughline as a "Code-as-Agent-Harness" System

**What this is.** A design map, not a behavior change. It places Throughline's parts on the
taxonomy from the survey *Code as Agent Harness: Toward Executable, Verifiable, and Stateful Agent
Systems* (Ning et al., arXiv:2605.18747, 2026). The goal is a shared vocabulary and an honest read
of what Throughline already does, what it does differently, and where it stops. Nothing here changes
how the framework runs.

**The survey's frame in one breath.** Code is not only what an agent produces; it is the *harness* —
the executable, inspectable, stateful substrate the agent reasons over, acts through, and verifies
against. The survey splits the field into three layers: the harness **interface** (code for
reasoning, acting, and environment modeling), harness **mechanisms** (planning, memory, tool use, a
Plan–Execute–Verify control loop, and harness self-improvement), and **scaling** to multi-agent
orchestration over shared code. Throughline is a working instance of all three, with one twist: its
harness is grounded in **specifications and standards**, not only in execution.

Jargon used below, defined once: *harness* = the software layer around the model (tools, state,
permissions, validators) that turns it into an agent; *substrate* = the shared state agents read and
write; *PEV* = Plan–Execute–Verify, the survey's control loop; *AHE* = Agentic Harness Engineering,
the survey's name for improving the harness itself.

---

## Layer 1 — Harness interface (survey §2)

| Survey role | Throughline mechanism | Where |
|---|---|---|
| Code for reasoning (machine-checkable artifacts the agent reasons over) | Specs, plans, tasks, and standards are the checkable artifacts; the Reviewer re-derives its verdict from the source of truth, not from prose summaries | `<target>/.throughline/specs/`, `/standards/` |
| "Executable contracts that constrain, certify, and audit behavior" | **Cite or Don't Ship**: every change cites a spec clause + a standard clause (+ exemplar basis when one exists) | constitution; citations in each diff |
| Code for environment modeling (inspectable world state) | The registered target repo (source + tests) plus `targets/<id>.yml` (test/lint/build commands) is the inspectable environment | `targets/` |

---

## Layer 2 — Harness mechanisms (survey §3)

### Planning (§3.1)
Throughline uses **structure-grounded** and **orchestration-based** planning. The lifecycle
(specify → clarify → plan → tasks) externalizes intent into a filesystem-backed plan — the survey's
"planning as a filesystem-backed control object" (its `PLAN.md` / status-log example). Structure
grounding is the mandatory **bootstrap** (wiki → standards-summary → pattern-library →
exception-registry → target delta) before any code, i.e. planning conditioned on explicit project
structure rather than a free-form prompt.

### Memory and context (§3.2)

| Survey memory type | Throughline |
|---|---|
| Working memory | the active slice's `spec.md` / `plan.md` / `tasks.md` / analysis |
| Semantic memory | `/standards/`, `/exemplars/`, target-local rules |
| Experiential / long-term | `wiki/pattern-library.md`, `decision-registry.md`, `exception-registry.md` |
| Append-only telemetry | `wiki/log.md` and each target's `<target>/.throughline/wiki/log.md` |
| Context compaction / offloading | the "bootstrap economy" (work from the slice's analysis, not the whole wiki); per-target wiki *delta* |
| "Quality over scale" (MemGovern) | memory is **human-curated** into `/standards/` + `/exemplars/`, not auto-accumulated |

### Tool use (§3.3)
Verification-driven (`test_command`, `lint_command`, `build_command`), environment-interaction
(edits on the target repo), and workflow-orchestration via **lifecycle hooks**. The
`validate-immutable-paths` hook is a pre-use permission boundary that denies writes to `/standards/`
and `/exemplars/` at the tool-call boundary — exactly the survey's "permissioned state transition"
(§3.4.3).

### The Plan–Execute–Verify loop (§3.4) — the closest single match
- **Plan as contract formation** → `spec.md` + `plan.md` + `tasks.md` declare the files, acceptance
  criteria, and validation commands for the change.
- **Sandboxed, permissioned execution** → the Implementer works only on branch `sdd/<slice>`;
  immutable-path hooks block protected writes; merging and pushing are always human (**Reversible
  Changes Only**).
- **Verification through deterministic sensors + an independent gate** → the Tester runs real tests
  and files an evidence report; the **Reviewer is a separate agent** that re-reads the rules from
  source and scores them.
- **Human-in-the-loop** → the escalation lane; **Annotate, Never Silently Skip** leaves a
  `DEV-STATUS` block and an exception-registry entry.

### Harness self-improvement / AHE (§3.5)
The **Auditor + human-curation loop is a governed harness-mutation loop**: observe (read each
target's `review-reports/`) → diagnose (roll the cross-target signal into
`audit/portfolio-summary.md`) → propose (`recommendations.md`) → **human-gated** mutation (a human
curates durable rules into `/standards/` + `/exemplars/`; the Archivist folds recurring patterns
into `wiki/`). This is the survey's "Evolution Agent," carried out with the governance §5.2.3 asks
for: the change is reviewed and reversible, not autonomous.

---

## Layer 3 — Scaling: multi-agent over shared code (survey §4)

### Role specialization (§4.1.1)

| Throughline persona | Survey role |
|---|---|
| Orchestrator | manager / planning |
| Analyst | program understanding |
| Architect | planning + design |
| Implementer | program synthesis |
| Tester | verification (execution-grounded) |
| Reviewer | verification (independent oracle audit) |
| Archivist | memory / knowledge |
| Auditor | harness evolution (telemetry roll-up) |

The Reviewer is the survey's **anti-mode-collapse** design made explicit — "the agent that writes
the code is never the agent that approves it." The survey praises the same idea in AgentCoder's
independent Test Designer and CANDOR's independent panelists, who judge oracle correctness against
the specification rather than against the code.

### The shared substrate (§4.2–4.3) — where Throughline is ahead of the field
The survey's "central gap" is that most multi-agent systems keep shared state **implicit /
file-only**, so an agent cannot tell when its belief has diverged from the true state. Throughline's
substrate is **explicit and persistent**: specs, the `work-queue/`, `review-reports/`, and the
registries form a queryable, version-controlled blackboard, and agents communicate **only through
these artifacts, never by direct call**. The slice branch + spec + registries give read/write sets,
provenance, and rollback — the ingredients §5.2.4 ("transactional shared program state") asks for.

### Convergence (§4.3.2)
```
confidence = 0.40·test_evidence + 0.35·standards_compliance + 0.25·spec_alignment
PASS ≥ 0.85 · CONDITIONAL_PASS 0.70–0.84 · FAIL < 0.70 → max 2 retries → escalate
```
This is a **score-based + consensus** convergence with an explicit threshold — precisely the
harness-level acceptance signal the survey says most systems lack (they stop on a fixed iteration
budget, which §4.3.2 calls "implicit convergence" and names as the field's biggest gap).

---

## Open problems Throughline already engages (survey §5.2)
- **Oracle adequacy (§5.2.1) and verification beyond executable feedback (§5.2.2).** The Reviewer
  judges against the source-of-truth standards, not the tests alone; the confidence formula weights
  `standards_compliance` (0.35) almost as high as `test_evidence` (0.40). This is the same lever the
  companion sdd-study paper isolates empirically: grounding the checker in the spec keeps the oracle
  accurate.
- **Self-evolving harness without regression (§5.2.3).** Governed, human-gated curation (Auditor →
  `recommendations.md` → `/standards/` + `/exemplars/`).
- **HITL safety as durable state (§5.2.5).** The escalation lane, `DEV-STATUS` blocks, and the
  exception-registry are persistent records, not one-off prompts.
- **Harness-level metrics (§5.2.1).** The confidence gate *is* a harness-level acceptance metric,
  which most surveyed systems do not have.

## Where Throughline differs or stops (honest gaps)
- **Text and code only** — no multimodal harness (§5.2.6).
- **Serialized, not concurrent** — the queue runs slices in order, so Throughline sidesteps rather
  than solves concurrent semantic merge and belief divergence at scale (§5.2.4).
- **Branch isolation, not containers** — reversibility + immutable-path hooks rather than
  microVM/WASM sandboxes (§3.4.3).
- **Human-gated evolution, not autonomous** — by design; it is not the learned self-evolution
  (AutoHarness, Meta-Harness) the survey also covers.
- **Structured logs, not deep traces** — `log.md` + review-reports, not token/latency/decision-tree
  trace stores; failure attribution is human-mediated.

## Vocabulary crosswalk

| Survey term | Throughline term |
|---|---|
| Harness substrate | `wiki/` + `work-queue/` + specs + registries |
| Plan–Execute–Verify loop | specify … → implement → test → review |
| Deterministic sensors | test/lint/build commands + the Reviewer |
| Executable contract | spec clause + standard clause (Cite or Don't Ship) |
| Evidence bundle | review-report + citations |
| Governed harness mutation | Auditor → human curation |
| Implicit convergence (the gap) | replaced by the confidence gate |
| HITL gate | escalation lane |

---

**Bottom line.** Throughline is a code-as-harness system whose distinctive bet is *grounding the
harness in human-curated specs and standards*, and whose explicit shared substrate and confidence
gate already address two of the survey's headline open problems — oracle adequacy and principled
convergence. The sdd-study result is the empirical "why": a checker grounded in the spec stays
accurate, which is exactly what Throughline's independent, standards-reading Reviewer and its
`standards_compliance` weight are built on.

*Source: Ning et al., "Code as Agent Harness: Toward Executable, Verifiable, and Stateful Agent
Systems," arXiv:2605.18747v1 (2026).*
