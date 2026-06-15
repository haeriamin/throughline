# Profile: Google Antigravity (Gemini agent IDE). Consumed by tools/convert.{ps1,sh}.
# Antigravity reads GEMINI.md (Antigravity-specific, highest priority), AGENTS.md (cross-tool),
# .agent/rules/*.md, and .agents/hooks.json. This profile does NOT overwrite root AGENTS.md
# (that file is the Codex adapter peer). Use GEMINI.md + .agent/rules/ for Antigravity.
id = antigravity
display = Antigravity
status = preview
tier = A
slash_example = /dev.review
slash_sep = .
detect_path = GEMINI.md

emit_personas = true
personas_dir = .agents/personas
persona_format = md-antigravity
persona_ext = .md
persona_ref = .agents/personas/{persona}.md

emit_commands = true
commands_dir = .agent/rules/commands
command_layout = flat
command_ext = .md
command_format = antigravity-rule
spawn_note = delegate to the matching persona in .agents/personas/ so the Reviewer stays in an independent context.

emit_prompts = false

emit_hooks = true
hooks_file = .throughline/adapters/generated/antigravity/hooks.template.json
hook_format = antigravity-json
hooks_live = .agents/hooks.json

emit_rules_file = true
rules_file = GEMINI.md
rules_format = gemini
rules_extra_file = .agent/rules/throughline.md

emit_global_rules = false
emit_skills = false

emit_manifest = true
manifest_path = .throughline/integrations/antigravity.manifest.json
