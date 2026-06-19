#!/usr/bin/env bash
# create-new-feature.sh — create <target>/.throughline/specs/NNN-<short-name>/ from the spec template.
# Usage: ./create-new-feature.sh <target-id> <short-name> [template]
# Outputs JSON: { "FEATURE_DIR": <abs>, "SPEC_FILE": <abs>, "FEATURE_NUM": NNN, "TARGET": <id> }
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

TARGET_ID="${1:?usage: create-new-feature.sh <target-id> <short-name> [template]}"
SHORT_NAME="${2:?usage: create-new-feature.sh <target-id> <short-name> [template]}"
TEMPLATE="${3:-spec-template.md}"

if ! [[ "$SHORT_NAME" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "ERROR: short-name must be kebab-case (got '$SHORT_NAME')" >&2
  exit 1
fi

ROOT="$(get_repo_root)"
SPECS_DIR="$(get_target_specs_dir "$TARGET_ID")"
NUM="$(get_next_feature_number "$TARGET_ID")"
FEATURE_DIR="$SPECS_DIR/$NUM-$SHORT_NAME"
mkdir -p "$FEATURE_DIR/checklists"

TEMPLATE_PATH="$ROOT/.throughline/templates/$TEMPLATE"
[ -f "$TEMPLATE_PATH" ] || { echo "ERROR: template not found: $TEMPLATE_PATH" >&2; exit 1; }
cp "$TEMPLATE_PATH" "$FEATURE_DIR/spec.md"

printf '{\n  "target": "%s",\n  "feature_directory": "%s"\n}\n' "$TARGET_ID" "$FEATURE_DIR" > "$ROOT/.throughline/feature.json"
printf '{"FEATURE_DIR":"%s","SPEC_FILE":"%s/spec.md","FEATURE_NUM":"%s","TARGET":"%s"}\n' "$FEATURE_DIR" "$FEATURE_DIR" "$NUM" "$TARGET_ID"
