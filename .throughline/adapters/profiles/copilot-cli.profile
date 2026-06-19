# Profile: GitHub Copilot CLI. Consumed by tools/convert.{ps1,sh}.
# Copilot CLI reuses the shared .github/ surface that the framework already generates:
# .github/copilot-instructions.md, .github/instructions/, .github/agents/ (custom agents = the personas
# and the dev.*/throughline.* command agents), AGENTS.md, and skills. So this profile only adds the
# CLI-format hook config; everything else is emitted by the shared pass and the copilot/codex profiles.
# Preview: on the CLI a preToolUse exit code 2 is a non-blocking warning, so guard ENFORCEMENT is
# advisory until verified -- see docs/runtimes/copilot-cli.md.
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

emit_rules_file = false
emit_global_rules = false
emit_skills = false
emit_manifest = false
