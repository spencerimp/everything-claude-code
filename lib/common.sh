#!/usr/bin/env bash
# common.sh — Shared helpers for adaptors and scripts.

set -euo pipefail

# Resolve the repo root from this script's location
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
    link_dir="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
    [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$link_dir/$SCRIPT_PATH"
done
LIB_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
REPO_ROOT="$(cd "$LIB_DIR/.." && pwd)"
RULES_DIR="$REPO_ROOT/rules"

# merge_rules <lang> [<lang> ...]
# Concatenates common/*.md + lang/*.md into stdout.
merge_rules() {
    local header="<!-- Generated from everything-claude-code ($(date -u +%Y-%m-%dT%H:%M:%SZ)) -->"
    echo "$header"
    echo ""

    # Common rules first
    if [[ -d "$RULES_DIR/common" ]]; then
        for f in "$RULES_DIR/common"/*.md; do
            [[ -f "$f" ]] || continue
            echo ""
            cat "$f"
            echo ""
        done
    fi

    # Language-specific rules
    for lang in "$@"; do
        if [[ ! "$lang" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            echo "Warning: invalid language name '$lang', skipping." >&2
            continue
        fi
        local lang_dir="$RULES_DIR/$lang"
        if [[ ! -d "$lang_dir" ]]; then
            echo "Warning: rules/$lang/ does not exist, skipping." >&2
            continue
        fi
        for f in "$lang_dir"/*.md; do
            [[ -f "$f" ]] || continue
            echo ""
            cat "$f"
            echo ""
        done
    done
}

# list_languages — print available language rule directories
list_languages() {
    for dir in "$RULES_DIR"/*/; do
        local name
        name="$(basename "$dir")"
        [[ "$name" == "common" ]] && continue
        echo "$name"
    done
}
