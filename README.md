# claude-wezterm-notifier

Desktop notifications for Claude Code permission requests and task completion, with actions to focus the Wezterm pane or approve directly from the notification.

## Overview

Claude Code supports hooks that run on specific events. This project provides two hooks:

- `PermissionRequest` (`permission-notify.sh`) - fires whenever Claude Code needs user approval before executing a tool. Sends a desktop notification with two actions: one to bring the Wezterm pane into focus, and one to approve the request without switching windows.
- `Stop` (`stop-notify.sh`) - fires when Claude Code finishes a task. Sends a desktop notification with one action to bring the Wezterm pane into focus.

## Requirements

- Linux (may work on Windows, see below)
- [Wezterm](https://wezfurlong.org/wezterm/)
- [Claude Code](https://claude.ai/code)
- `jq`
- `notify-send` (package `libnotify-bin` on Debian/Ubuntu)
- A D-Bus notification daemon that supports action callbacks (`dunst`, GNOME Shell 43+, KDE Plasma, etc.)

### Windows Support
While not yet tested, this may work on Windows when using something like [wsl-notify-send](https://github.com/stuartleeks/wsl-notify-send). Let me know if that (or any other setup) works for you.


## Installation

1. Create the hooks directory:

   ```sh
   mkdir -p ~/.claude/hooks
   ```

2. Copy the scripts:

   ```sh
   cp permission-notify.sh ~/.claude/hooks/permission-notify.sh
   cp stop-notify.sh ~/.claude/hooks/stop-notify.sh
   ```

3. Make them executable:

   ```sh
   chmod +x ~/.claude/hooks/permission-notify.sh ~/.claude/hooks/stop-notify.sh
   ```

4. Merge the hook configuration into `~/.claude/settings.json`. If you have no existing settings file:
   ```sh
   cp settings.json.example ~/.claude/settings.json
   ```
   Otherwise, merge the `hooks` block from `settings.json.example` into your existing `~/.claude/settings.json`.

## Configuration

The hooks are registered in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/permission-notify.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/stop-notify.sh"
          }
        ]
      }
    ]
  }
}
```

The empty `matcher` causes each hook to fire for all matching events regardless of tool name.

## How it works

### Permission requests

1. Claude Code invokes `permission-notify.sh` with the permission request as JSON on stdin.
2. The script parses the tool name, working directory, and tool-specific fields using `jq`.
3. If the Wezterm pane running Claude Code is already focused, the script exits silently.
4. Otherwise, a desktop notification is sent with two actions:
   - **Open** - calls `wezterm cli activate-pane` to bring the pane into focus.
   - **Allow** - writes a JSON approval response to stdout, which Claude Code reads to grant the permission without the user switching windows.
5. The notification expires after 30 seconds.

### Task completion

1. Claude Code invokes `stop-notify.sh` when a task finishes.
2. If the Wezterm pane running Claude Code is already focused, the script exits silently.
3. Otherwise, a desktop notification is sent with one action:
   - **Open** - calls `wezterm cli activate-pane` to bring the pane into focus.
4. The notification expires after 30 seconds.

## Limitations

- Linux only. No macOS or Windows support (*).
- Wezterm only. No support for other terminal emulators.
- Requires a notification daemon that supports `notify-send` action callbacks. Basic daemons that only display notifications will show the notification but actions will not work.
- The pane focus check reads only the first connected Wezterm client.
