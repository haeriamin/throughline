# dev — Software Development Agent Commands

Turns the generic Throughline SDD cycle into a gated software-development pipeline operating on external
target codebases: analyze, design, scaffold, implement, test, review, and audit against standards and
curated exemplars.

Lifecycle phases live under `/throughline.*`; this extension provides `/dev.*` agent commands and
hooks them into the lifecycle via `.throughline/extensions.yml`.
