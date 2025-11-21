# collide-devtools Plugin

Development workflow automation: pre-commit formatting and custom statusline.

## What's Included

### Pre-Commit Formatting Hook
Automatically formats Python code with `ruff format` before every commit.

**Requirements:**
- Project must have `src/` directory
- `uv` must be installed
- `ruff` must be available via `uv run ruff`

**How it works:**
When you run `git commit`, Claude Code will automatically:
1. Run `ruff format src/`
2. Stage the formatted changes
3. Proceed with the commit

### Custom Status Line
Shows model name, current directory, and git branch in your Claude Code status line.

**Display Format:** `[MODEL] 📁 directory | 🌿 branch`

**Requirements:**
- Git repository (for branch display)

## Manual Setup Required: Status Line

After installing this plugin, the statusline script will be located at:
`.claude/plugins/collide-devtools/statusline.sh`

Add this configuration to your `.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": ".claude/plugins/collide-devtools/statusline.sh",
    "padding": 0
  }
}
```

**Verification:** Restart Claude Code or reload settings to see the statusline appear.

## Customization

### Change Formatting Target
If your Python code is not in `src/`, edit the hook in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git commit:*)",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'cd $(git rev-parse --show-toplevel) && uv run ruff format YOUR_DIRECTORY/ && git add -u'"
          }
        ]
      }
    ]
  }
}
```

### Disable Pre-Commit Hook
If you want the statusline but not the pre-commit hook, disable or remove the hook configuration from your settings.
