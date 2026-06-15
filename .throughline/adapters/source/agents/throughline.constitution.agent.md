---
description: Ratify or amend the framework constitution with semantic versioning and an audit trail.
---

## User Input

```text
$ARGUMENTS
```

## Outline

1. Read the current `.throughline/memory/constitution.md` in full.
2. **No arguments** → ratification review: walk the principles, the write-boundary table, and the thresholds; confirm they match the framework's actual layout (paths exist, hooks present, agents listed). Report drift; if `Ratified` is `[TBD]`, propose today's date and **wait for explicit human approval** before filling it.
3. **With arguments** (amendment request):
   - Classify the change: MAJOR (principle removed/redefined), MINOR (new principle/section), PATCH (clarification).
   - Draft the amended text; show a before/after diff of affected sections only.
   - **Wait for explicit human approval** (constitution §Governance — agents never self-amend).
   - On approval: apply the edit, bump the version, set `Last Amended` to today.
4. Propagate: list every file that quotes the amended content (`.github/copilot-instructions.md`, `CLAUDE.md`, instructions files, extension config defaults) and update the quotes to match.
5. Append a `wiki/log.md` entry citing the amendment, version change, and approver.

## Rules

- Confidence thresholds and formula weights live HERE — config files quoting them are mirrors, never sources.
- A human approval is required for any change; absence of objection is not approval.
