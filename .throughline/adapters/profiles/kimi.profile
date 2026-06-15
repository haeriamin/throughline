# Profile: Kimi Code CLI. Consumed by tools/convert.{ps1,sh}.
# Kimi merges root AGENTS.md with .kimi/AGENTS.md. Root AGENTS.md is the Codex peer; use .kimi/AGENTS.md for Kimi.
id = kimi
display = Kimi Code
status = preview
tier = A
slash_example = /dev.review
slash_sep = .
detect_path = .kimi

emit_personas = true
personas_dir = .kimi/personas
persona_format = md-kimi
persona_ext = .md
persona_ref = .kimi/personas/{persona}.md

emit_commands = true
commands_dir = .kimi/workflows
command_layout = flat
command_ext = .md
command_format = antigravity-rule
spawn_note = delegate via the Agent tool to the matching persona in .kimi/personas/ so the Reviewer stays in an independent context.

emit_prompts = false

emit_hooks = true
hooks_file = .throughline/adapters/generated/kimi/hooks.template.toml
hook_format = kimi-toml
hooks_live = .kimi/config.toml

emit_rules_file = true
rules_file = .kimi/AGENTS.md
rules_format = kimi

emit_global_rules = false
emit_skills = false

emit_manifest = true
manifest_path = .throughline/integrations/kimi.manifest.json
