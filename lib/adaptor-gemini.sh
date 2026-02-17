#!/usr/bin/env bash
# adaptor-gemini.sh — Generate .github/gemini-instructions.md from Claude rules.
#
# Usage:
#   ./lib/adaptor-gemini.sh [--out <dir>] <language> [<language> ...]
#
# Defaults to writing in the current working directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# --- Parse args ---
OUT_DIR="."
if [[ "${1:-}" == "--out" ]]; then
    OUT_DIR="${2:-.}"
    shift 2
fi

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [--out <dir>] <language> [<language> ...]"
    echo ""
    echo "Generates .github/gemini-instructions.md from Claude rules."
    echo ""
    echo "Available languages:"
    list_languages
    exit 1
fi

# --- Generate ---
TARGET_DIR="$OUT_DIR/.github"
TARGET_FILE="$TARGET_DIR/gemini-instructions.md"

mkdir -p "$TARGET_DIR"

{
    echo "# Gemini Code Assist Instructions"
    echo ""
    merge_rules "$@"
} > "$TARGET_FILE"

echo "Generated $TARGET_FILE"
