# Profile: OpenCode. Consumed by tools/convert.{ps1,sh}.
# OpenCode reads AGENTS.md at project root by default; root AGENTS.md here is the Codex peer.
# This adapter uses .opencode/throughline.md via opencode.json instructions instead.
id = opencode
display = OpenCode
status = preview
tier = A
slash_example = /dev.review
slash_sep = .
detect_path = .opencode

emit_personas = true
personas_dir = .opencode/agents
persona_format = md-opencode
persona_ext = .md
persona_ref = .opencode/agents/{persona}.md

emit_commands = true
commands_dir = .opencode/commands
command_layout = flat
command_ext = .md
command_format = opencode
spawn_note = invoke as a subagent (@mention or agent field) so the Reviewer stays in an independent context.

emit_prompts = false
emit_hooks = false

emit_rules_file = true
rules_file = .opencode/throughline.md
rules_format = opencode-index

emit_config = true
config_file = opencode.json
config_format = opencode-json

emit_global_rules = false
emit_skills = false

emit_manifest = true
manifest_path = .throughline/integrations/opencode.manifest.json
