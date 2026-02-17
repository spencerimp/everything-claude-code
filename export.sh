#!/usr/bin/env bash
# export.sh — Save a project's Claude configs as a reusable preset.
#
# Usage:
#   ./export.sh <preset-name> [--from <project-dir>]
#
# Reads native Claude files from a project and saves them to presets/<name>/.
# If --from is not specified, reads from the current working directory.

set -euo pipefail

# Resolve repo root
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
    link_dir="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
    [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$link_dir/$SCRIPT_PATH"
done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
PRESETS_DIR="$SCRIPT_DIR/presets"

# --- Parse args ---
PRESET_NAME=""
PROJECT_DIR="."

while [[ $# -gt 0 ]]; do
    case "$1" in
        --from)
            PROJECT_DIR="${2:-.}"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$PRESET_NAME" ]]; then
                PRESET_NAME="$1"
            else
                echo "Error: unexpected argument '$1'" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$PRESET_NAME" ]]; then
    echo "Usage: $0 <preset-name> [--from <project-dir>]"
    echo ""
    echo "Saves a project's Claude configs as a reusable preset."
    echo ""
    echo "What gets exported:"
    echo "  ./CLAUDE.md"
    echo "  ./.claude/commands/*.md"
    echo "  ./.claude/settings.json"
    echo "  ./.claude/mcp.json"
    exit 1
fi

# Validate preset name
if [[ ! "$PRESET_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: preset name must be alphanumeric, dash, or underscore." >&2
    exit 1
fi

# Resolve project dir
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
DEST="$PRESETS_DIR/$PRESET_NAME"

if [[ -d "$DEST" ]]; then
    echo "Note: preset '$PRESET_NAME' already exists. Files will be overwritten."
fi

mkdir -p "$DEST"

FOUND=0

# CLAUDE.md
if [[ -f "$PROJECT_DIR/CLAUDE.md" ]]; then
    cp "$PROJECT_DIR/CLAUDE.md" "$DEST/CLAUDE.md"
    echo "  Exported CLAUDE.md"
    FOUND=1
fi

# .claude/commands/
if [[ -d "$PROJECT_DIR/.claude/commands" ]]; then
    mkdir -p "$DEST/commands"
    cp "$PROJECT_DIR/.claude/commands"/*.md "$DEST/commands/" 2>/dev/null && {
        echo "  Exported .claude/commands/"
        FOUND=1
    }
fi

# .claude/settings.json
if [[ -f "$PROJECT_DIR/.claude/settings.json" ]]; then
    cp "$PROJECT_DIR/.claude/settings.json" "$DEST/settings.json"
    echo "  Exported .claude/settings.json"
    FOUND=1
fi

# .claude/mcp.json
if [[ -f "$PROJECT_DIR/.claude/mcp.json" ]]; then
    cp "$PROJECT_DIR/.claude/mcp.json" "$DEST/mcp.json"
    echo "  Exported .claude/mcp.json"
    FOUND=1
fi

if [[ $FOUND -eq 0 ]]; then
    rmdir "$DEST" 2>/dev/null
    echo "No Claude config files found in $PROJECT_DIR"
    exit 1
fi

echo ""
echo "Preset saved to $DEST/"
