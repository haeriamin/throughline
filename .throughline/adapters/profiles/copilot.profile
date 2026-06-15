# Profile: GitHub Copilot (VS Code). Consumed by tools/convert.{ps1,sh}.
# The rich persona/command bodies live in .github/agents/*.agent.md and are CANONICAL hand-authored
# content (they also hold the lifecycle runbooks), so this profile does NOT regenerate them. It emits
# the thin prompt pointers and the committed, cross-OS hook config.
id = copilot
display = GitHub Copilot
status = supported
tier = A
slash_example = /dev.review
slash_sep = .
detect_path = .github/agents

emit_personas = false
emit_commands = false

emit_prompts = true
prompts_dir = .github/prompts

emit_hooks = true
hooks_file = .github/hooks/hooks.json
hook_format = github-json

emit_rules_file = false
emit_global_rules = false
emit_skills = false
emit_manifest = false
