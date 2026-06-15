# Profile: Claude Code. Consumed by tools/convert.{ps1,sh}.
id = claude
display = Claude Code
status = supported
tier = A
slash_example = /dev:review
slash_sep = :
detect_path = ~/.claude

emit_personas = true
personas_dir = .claude/agents
persona_format = md
persona_ext = .md
persona_ref = .claude/agents/{persona}.md

emit_commands = true
commands_dir = .claude/commands
command_layout = subdir
command_ext = .md
command_format = claude
spawn_note = delegate to it via the Agent tool when running as a top-level conversation.

emit_prompts = false
emit_hooks = false
emit_rules_file = true
rules_format = claude
rules_file = CLAUDE.md
emit_global_rules = false
emit_skills = false
emit_manifest = false
