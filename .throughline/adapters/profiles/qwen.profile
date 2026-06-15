# Profile: Qwen Code CLI. Consumed by tools/convert.{ps1,sh}.
# Qwen reads QWEN.md and AGENTS.md for context. Root AGENTS.md is the Codex peer; use QWEN.md for Qwen.
id = qwen
display = Qwen Code
status = preview
tier = A
slash_example = /dev.review
slash_sep = .
detect_path = QWEN.md

emit_personas = true
personas_dir = .qwen/agents
persona_format = md-qwen
persona_ext = .md
persona_ref = .qwen/agents/{persona}.md

emit_commands = true
commands_dir = .qwen/commands
command_layout = subdir
command_ext = .md
command_format = qwen
spawn_note = delegate to the matching subagent in .qwen/agents/ so the Reviewer stays in an independent context.

emit_prompts = false
emit_hooks = false

emit_rules_file = true
rules_file = QWEN.md
rules_format = qwen

emit_config = true
config_file = .qwen/settings.json
config_format = qwen-json

emit_global_rules = false
emit_skills = false

emit_manifest = true
manifest_path = .throughline/integrations/qwen.manifest.json
