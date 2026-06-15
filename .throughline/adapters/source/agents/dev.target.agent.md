---
description: Register, inspect, or update an external target project (Orchestrator).
handoffs:
  - label: Specify a slice on this target
    agent: throughline.specify
    prompt: Target registered. Write the spec for the slice described above.
---

<!-- Extension: dev | Persona: Orchestrator -->

# Manage Targets (Orchestrator)

## User Input

```text
$ARGUMENTS
```

You are the **Orchestrator**. Targets are the framework's only bridge to external code — `targets/<id>.yml` entries are written by this command alone, and target paths must be OUTSIDE this framework repo (§Write-Boundary Invariants).

Runbook: `.throughline/extensions/dev/commands/dev.target.md` — follow step-by-step (subcommands, preconditions, exit criteria, failure modes).
