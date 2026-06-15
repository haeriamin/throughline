# Profile: Codex CLI. Consumed by tools/convert.{ps1,sh}.
id = codex
display = Codex
status = preview
tier = A
slash_example = /dev.review
slash_sep = .
detect_path = ~/.codex

emit_personas = true
personas_dir = .codex/agents
persona_format = toml
persona_ext = .toml
persona_ref = .codex/agents/{persona}.toml

emit_commands = true
commands_dir = .codex/prompts
command_layout = flat
command_ext = .md
command_format = codex
spawn_note = spawn it as a separate Codex subagent (Codex has no declarative handoffs; name the agent explicitly so each persona stays independent).

emit_prompts = false
emit_hooks = false
emit_rules_file = true
rules_format = codex
rules_file = AGENTS.md
emit_global_rules = false
emit_skills = false
emit_manifest = false
