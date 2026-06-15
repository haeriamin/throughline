# Profile: Aider. Consumed by tools/convert.{ps1,sh}.
# Tier B (rules-only): Aider reads a single CONVENTIONS.md and has no subagents and no hooks. The
# read-only guard and merge safety are INSTRUCTED here, not enforced. The installer warns about this.
id = aider
display = Aider
status = rules-only
tier = B
slash_example = (no slash commands; reference personas in chat)
slash_sep = .
detect_path = .aider.conf.yml

emit_personas = false
emit_commands = false
emit_prompts = false
emit_hooks = false

emit_rules_file = true
rules_file = .throughline/adapters/generated/aider/CONVENTIONS.md
rules_format = bundle

emit_global_rules = false
emit_skills = false

emit_manifest = true
manifest_path = .throughline/integrations/aider.manifest.json
