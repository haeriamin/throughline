# Extension Hook Protocol
> Shared by all throughline.* lifecycle agents. Defines how to check and surface extension hooks.

Every Throughline lifecycle command checks `.throughline/extensions.yml` at two points: **before** starting its phase (`hooks.before_<phase>`) and **after** reporting completion (`hooks.after_<phase>`).

## Procedure

1. Check if `.throughline/extensions.yml` exists in the project root. Missing → skip silently.
2. Read entries under the relevant `hooks.<key>` (e.g., `before_plan`, `after_implement`).
3. If the YAML cannot be parsed, skip hook checking silently and continue normally.
4. Filter out hooks where `enabled` is explicitly `false`. Hooks without an `enabled` field are enabled by default.
5. Do **not** interpret or evaluate hook `condition` expressions:
   - No `condition` field, or null/empty → treat the hook as executable.
   - Non-empty `condition` → skip it and leave evaluation to the HookExecutor implementation.
6. For each executable hook, output based on its `optional` flag:

**Optional hook** (`optional: true`):
```
## Extension Hooks

**Optional Hook**: {extension}
Command: `/{command}`
Description: {description}

Prompt: {prompt}
To execute: `/{command}`
```

**Mandatory hook** (`optional: false`):
```
## Extension Hooks

**Automatic Hook**: {extension}
Executing: `/{command}`
EXECUTE_COMMAND: {command}

Wait for the result of the hook command before proceeding.
```

7. No hooks registered → skip silently.

## Phase keys in this framework

| Phase | before | after |
|-------|--------|-------|
| specify | `before_specify` | `after_specify` |
| plan | `before_plan` (→ /dev.analyze, optional) | `after_plan` |
| tasks | `before_tasks` | `after_tasks` |
| implement | `before_implement` (→ /dev.review drift check, optional) | `after_implement` (→ /dev.review, **mandatory**) |
| analyze | `before_analyze` | `after_analyze` (→ /dev.audit, optional) |
