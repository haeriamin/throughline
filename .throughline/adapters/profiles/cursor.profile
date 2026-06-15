# Profile: Cursor. Consumed by tools/convert.{ps1,sh}.
# Cursor reads .cursor/agents (and natively .claude/agents), .cursor/commands (plain markdown,
# filename = command), .cursor/rules/*.mdc, and .cursor/hooks.json (preToolUse + beforeShellExecution
# can block). Tier A: the read-only guard is hook-enforced.
id = cursor
display = Cursor
status = preview
tier = A
slash_example = /dev.review
slash_sep = .
detect_path = .cursor

emit_personas = true
personas_dir = .cursor/agents
persona_format = md-cursor
persona_ext = .md
persona_ref = .cursor/agents/{persona}.md

emit_commands = true
commands_dir = .cursor/commands
command_layout = flat
command_ext = .md
command_format = cursor
spawn_note = delegate to it as a subagent so its context stays independent.

emit_prompts = false

# Hooks are NOT emitted live into .cursor/hooks.json by convert: Cursor loads that file the moment
# it appears, and a fail-closed guard pointing at a .sh script with no interpreter would lock the
# session. convert stages the OS-neutral template; tools/setup-hooks wires the real per-OS
# .cursor/hooks.json (PowerShell on Windows, bash on Unix), same as it does for .codex/hooks.json.
emit_hooks = true
hooks_file = .throughline/adapters/generated/cursor/hooks.template.json
hook_format = cursor-json

emit_rules_file = true
rules_file = .cursor/rules/throughline.mdc
rules_format = mdc

emit_global_rules = false
emit_skills = false

emit_manifest = true
manifest_path = .throughline/integrations/cursor.manifest.json
