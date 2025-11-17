# sam-texas-devtools Plugin

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

The statusline is included in this plugin but requires manual configuration in your `.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "statusline.sh",
    "padding": 0
  }
}
```

**Note:** The path may vary depending on where the plugin installs the script. You might need to adjust the path to the statusline.sh script.

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
