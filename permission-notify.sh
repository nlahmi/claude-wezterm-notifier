#!/bin/bash
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
PROJECT=$(basename "$CWD")

# Brief description based on tool type
case "$TOOL" in
Bash)
    DESC=$(echo "$INPUT" | jq -r '.tool_input.description // .tool_input.command // ""' | head -c 80)
    ;;
Write | Edit)
    DESC=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' | xargs basename 2>/dev/null)
    ;;
*)
    DESC="$TOOL"
    ;;
esac

BODY="[$PROJECT] $TOOL"
[ -n "$DESC" ] && BODY="[$PROJECT] $DESC"

FOCUSED_PANE=$(wezterm cli list-clients --format json 2>/dev/null | jq -r '.[0].focused_pane_id // ""')
[ "$FOCUSED_PANE" = "$WEZTERM_PANE" ] && exit 0

CLICKED=$(notify-send "Claude Code" "$BODY" -A "default=Open" -A "allow=Allow" -t 30000 2>/dev/null)
if [ "$CLICKED" = "default" ] && [ -n "$WEZTERM_PANE" ]; then
    wezterm cli activate-pane --pane-id "$WEZTERM_PANE" 2>/dev/null
elif [ "$CLICKED" = "allow" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
fi
