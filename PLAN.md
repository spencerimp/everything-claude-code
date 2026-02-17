# agentkit — Implementation Plan (v1)

Fork of `everything-claude-code` (ECC). Scope: adaptors + export only.

## Deliverables

### 1. Adaptor scripts — generate Copilot/Gemini from Claude rules

```
lib/
├── common.sh             # Shared helpers (path resolution, markdown merge)
├── adaptor-copilot.sh    # Merges Claude rules → .github/copilot-instructions.md
└── adaptor-gemini.sh     # Merges Claude rules → .github/gemini-instructions.md
```

**Adaptor logic:**
- Concatenate `rules/common/*.md` + `rules/<lang>/*.md` into a single Markdown file
- Prepend header: `<!-- Generated from everything-claude-code -->`
- Write to target path (`.github/copilot-instructions.md` or `.github/gemini-instructions.md`)

### 2. Export script — save current Claude configs as a reusable preset

```bash
./export.sh <preset-name> [--from <project-dir>]
```

Reads from a project's native Claude files and saves to `presets/<name>/`:
- `./CLAUDE.md` → `presets/<name>/CLAUDE.md`
- `./.claude/commands/*.md` → `presets/<name>/commands/`
- `./.claude/settings.json` → `presets/<name>/settings.json`
- `./.claude/mcp.json` → `presets/<name>/mcp.json`

## New files

| File | Purpose |
|------|---------|
| `lib/common.sh` | Shared helpers |
| `lib/adaptor-copilot.sh` | Claude → Copilot |
| `lib/adaptor-gemini.sh` | Claude → Gemini |
| `export.sh` | Save project configs as preset |

## Implementation order

1. `lib/common.sh`
2. `lib/adaptor-copilot.sh` + `lib/adaptor-gemini.sh`
3. `export.sh`
