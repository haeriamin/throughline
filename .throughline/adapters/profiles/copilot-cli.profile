# Profile: GitHub Copilot CLI. Consumed by tools/convert.{ps1,sh}.
# Copilot CLI reuses the shared .github/ surface that the framework already generates:
# .github/copilot-instructions.md, .github/instructions/, .github/agents/ (custom agents = the personas
# and the dev.*/throughline.* command agents) and skills come from the shared pass. This profile adds
# the CLI-format hook config AND emits root AGENTS.md (the shared Codex-peer root the CLI loads as
# instructions) so a copilot-cli-only install is self-sufficient.
# Preview: on the CLI a PreToolUse exit code 2 is a non-blocking warning (advisory), so the guards are
# ALSO wired under PermissionRequest where exit 2 denies (enforcing) -- see docs/runtimes/copilot-cli.md.
id = copilot-cli
display = GitHub Copilot CLI
status = preview
tier = A
slash_example = use the dev.feature agent
slash_sep = .
detect_path = ~/.copilot

emit_personas = false
emit_commands = false
emit_prompts = false

emit_hooks = true
hooks_file = .github/hooks/copilot-cli.json
hook_format = copilot-cli-json

emit_rules_file = true
rules_format = codex
rules_file = AGENTS.md
emit_global_rules = false
emit_skills = false
emit_manifest = false
