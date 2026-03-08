#!/bin/bash

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
PROJECT=$(basename "$CWD")

FOCUSED_PANE=$(wezterm cli list-clients --format json 2>/dev/null | jq -r '.[0].focused_pane_id // ""')
[ "$FOCUSED_PANE" = "$WEZTERM_PANE" ] && exit 0

CLICKED=$(notify-send "Claude Code" "[$PROJECT] Done" -A "default=Open" -t 10000 2>/dev/null)
if [ "$CLICKED" = "default" ] && [ -n "$WEZTERM_PANE" ]; then
    wezterm cli activate-pane --pane-id "$WEZTERM_PANE" 2>/dev/null
fi
