ns = dev
cmd = feature
persona = orchestrator
description = Single entry point — run the full lifecycle on any target, existing or greenfield, from one request
argument_hint = <target-id> "<description>" [--express] [--micro] [--audit]
persona_action = you drive the pipeline; the phase commands do the work. An empty target is detected as **greenfield mode**: design becomes mandatory and scaffold runs before implement.
runbook_steps = resume + mode detection, pipeline, constitutional pauses, final report
runbook_tail =  Constitutional pauses (clarifications, HIGH/greenfield design approval, CRITICAL hand-over, escalations, merge) are never skipped — `--express` only drops the optional spec/plan gates.
