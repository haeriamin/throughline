---
description: Create or update the feature specification from a natural language slice description.
handoffs:
  - label: Clarify Spec Requirements
    agent: throughline.clarify
    prompt: Clarify specification requirements
    send: true
  - label: Build Technical Plan
    agent: throughline.plan
    prompt: Create a plan for the spec.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre/Post Hooks

Check `.throughline/extensions.yml` for `hooks.before_specify` / `hooks.after_specify` per [extension hook protocol](../instructions/extension-hooks.instructions.md).

## Outline

The text after `/throughline` **is** the slice description. Do not ask the user to repeat it.

1. **Resolve the target** (this framework is standalone — code lives at registered external paths):
   - Extract the target id or path from the description.
   - If it names a registered target (`targets/<id>.yml` exists) → record the id.
   - If it names an unregistered path → instruct the user to run `/dev.target register <path>` first and STOP.
   - Greenfield with no path yet → proceed, but mark `**Target**: [NEEDS CLARIFICATION: target path]`.

2. **Generate a short name** (2–4 words, kebab-case, action-noun: "jwt-auth", "fix-payment-timeout").

3. **Create the feature directory** by running the helper script (pass the target id from step 1):
   - PowerShell: `.throughline/scripts/powershell/create-new-feature.ps1 -Target "<target-id>" -ShortName "<short-name>"`
   - Bash: `.throughline/scripts/bash/create-new-feature.sh <target-id> <short-name>`
   - The script resolves the target's path + `throughline_dir` from `targets/<target-id>.yml`, copies `.throughline/templates/spec-template.md` to `<target>/.throughline/specs/NNN-<short-name>/spec.md`, creates `checklists/`, and persists the absolute path + target to `.throughline/feature.json`. One feature per invocation. Slice numbers are per target (`<target>/.throughline/specs/` starts at 001).

4. **Write the spec** into SPEC_FILE preserving the template's section order:
   - Fill Target, User Scenarios, Functional Requirements (each testable), Success Criteria (measurable, technology-agnostic, user-focused), Scope & Boundaries, Assumptions.
   - Make informed guesses for gaps; document them in Assumptions.
   - Mark at most **3** `[NEEDS CLARIFICATION: specific question]` — only where scope/security/UX materially forks and no reasonable default exists.

5. **Validate** against `<target>/.throughline/specs/NNN-*/checklists/requirements.md` (create from `.throughline/templates/checklist-template.md`):
   - Content: no implementation details; user/business focused; all mandatory sections done.
   - Requirements: testable, unambiguous, measurable criteria, bounded scope, assumptions recorded.
   - Fix failures and re-validate (max 3 iterations); remaining `[NEEDS CLARIFICATION]` → present each as a question table (Option | Answer | Implications) and wait for answers; update spec.

6. **Report**: FEATURE_DIR, SPEC_FILE, target id, checklist results, readiness for `/throughline.clarify` or `/throughline.plan`. Append to `<target>/.throughline/wiki/log.md`.

## Guidelines

- WHAT and WHY only — no stack, APIs, or code structure (that's the plan/design).
- Good success criterion: "Users complete checkout in under 3 minutes". Bad: "API responds in 200ms".
