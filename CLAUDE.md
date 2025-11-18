# Repository Structure

This repository serves dual purposes:
1. **Local development:** `.claude/` directory for direct use
2. **Plugin marketplace:** `plugins/` directory for distribution

## Plugin Architecture
- `plugins/gilfoyle/` - Code review agent plugin
- `plugins/copywriter/` - Documentation agent plugin
- `plugins/coverage-enforcer/` - Django coverage agent plugin
- `plugins/spyros/` - SOC 2 compliance agent plugin
- `plugins/sam-texas-commands/` - Slash commands plugin
- `plugins/sam-texas-devtools/` - Hooks and statusline plugin
- `marketplace.json` - Marketplace configuration

## Local Development Structure
- `.claude/agents/` - Custom subagents for local testing
- `.claude/commands/` - Slash commands for local testing
- `.claude/settings.json` - Hooks and configuration for local testing

# Subagents

Use these specialized subagents proactively when their expertise is needed:

## gilfoyle
**When to use:** Code review, complexity reduction, architectural guidance, performance problems, mentoring
**Trigger:** MUST BE USED when code needs divine intervention. Use proactively when reviewing significant code changes.
**Plugin:** `gilfoyle`
**Files:** `.claude/agents/gilfoyle.md` (local), `plugins/gilfoyle/` (distribution)

## copywriter
**When to use:** Documentation, README files, error messages, API documentation, user-facing content
**Trigger:** MUST BE USED when reviewing or creating any documentation, error messages, or text that could cause confusion for humans or AI agents.
**Plugin:** `copywriter`
**Files:** `.claude/agents/copywriter_subagent.md` (local), `plugins/copywriter/` (distribution)

## coverage-enforcer
**When to use:** Django test coverage analysis, coverage enforcement, coverage improvement planning
**Trigger:** MUST BE USED for any coverage-related tasks, Django test analysis, or coverage improvement requests.
**Plugin:** `coverage-enforcer`
**Files:** `.claude/agents/coverage_subagent.md` (local), `plugins/coverage-enforcer/` (distribution)

## spyros
**When to use:** SOC 2 compliance review, audit preparation, control gap analysis for code and infrastructure
**Trigger:** Explicit invocation when assessing compliance implications. Use when touching access controls, secrets management, logging, encryption, or other SOC 2-relevant controls.
**Plugin:** `spyros`
**Files:** `.claude/agents/spyros.md` (local), `plugins/spyros/` (distribution)

# Slash Commands

**Plugin:** `sam-texas-commands`

## /catchmeup
Get a conversational summary of recent commits and current work status. Perfect for returning to a project after time away.

## /auditclaudemd
Review this CLAUDE.md file against current Claude Code best practices. Searches for latest docs, evaluates content, removes cruft.

# Hooks

**Plugin:** `sam-texas-devtools`

## Pre-Commit Formatting
**Trigger:** Any `git commit` command
**Action:** Runs `ruff format src/` and stages changes automatically
**Requirements:** Project must have `src/` directory with Python files
**Config:** `.claude/settings.json` (local), `plugins/sam-texas-devtools/hooks/hooks.json` (distribution)

## Custom Status Line
**Display:** Shows model name, current directory, and git branch
**Script:** `.claude/statusline.sh` (local), `plugins/sam-texas-devtools/statusline.sh` (distribution)
**Note:** Statusline configuration must be manually added to `.claude/settings.json` after installing the plugin

## Audit Tool Use
**Trigger:** Git operations (`git push`, `git commit`)
**Action:** Logs tool execution details for audit trail
**Output:** Local logs in `~/.claude/audit-logs/`
**Config:** `.claude/hooks/audit-tool-use.sh`

## Security Events Detection
**Trigger:** Every user prompt submission
**Action:** Scans for security-sensitive keywords and logs potential security events
**Output:** Local logs in `~/.claude/security-logs/`
**Config:** `.claude/hooks/security-events.sh`

# Observability & Telemetry

This repository is structured as a Claude Code plugin providing Azure Application Insights integration for centralized observability.

## Plugin Installation

Install this as a plugin for easy team-wide distribution:

```bash
/plugin marketplace add https://github.com/Digital-Wildcatters/claude-code-config
/plugin install azure-observability@Digital-Wildcatters
```

After installation, use slash commands:
- `/setup-observability` - Interactive Azure setup
- `/validate-telemetry` - Verify configuration
- `/observability-status` - Check current status
- `/view-privacy-notice` - Privacy disclosure
- `/azure-dashboard` - Dashboard queries and templates

## Configuration Files

- `templates/settings.example.json` - Example OpenTelemetry configuration template
- `templates/.env.example` - Environment variable template for Azure credentials
- `docs/OBSERVABILITY.md` - Complete setup guide
- `docs/PRIVACY_NOTICE.md` - User disclosure and privacy policy

## What Gets Tracked

When telemetry is enabled (`CLAUDE_CODE_ENABLE_TELEMETRY=1`):

**Usage Metrics:**
- Sessions initiated, active time, model selection
- Tool calls, lines of code modified, PRs/commits created

**Audit Logs** (with `OTEL_LOG_USER_PROMPTS=1`):
- Complete user prompts (what users ask Claude to do)
- Tool execution details (commands run, files modified)
- Git operations (commits, pushes, pull requests)

**Error Tracking:**
- Failed tool calls, API errors, timeouts
- Hook execution failures

**Cost Tracking:**
- Token consumption (input/output/cache)
- USD costs per session, aggregated by team/project

## Setup Quick Reference

**As Plugin:**
1. `/plugin install azure-observability@Digital-Wildcatters`
2. `/setup-observability`
3. `/validate-telemetry`

**Manual:**
1. Provision Azure resources: `./scripts/get-azure-credentials.sh`
2. Configure settings: Copy `templates/settings.example.json` to `.claude/settings.json`
3. Validate: `./scripts/validate-telemetry.sh`

See `docs/OBSERVABILITY.md` for detailed setup instructions.

# Guidelines

## Code Style
- Use ATX-style headers (# ##) in markdown files
- Subagent files follow naming pattern: descriptive-kebab-case.md
- Documentation goes in README.md, not inline comments

## Documentation
- Human-facing documentation belongs in README.md
- Claude-facing instructions belong in this file
- New subagents must include clear descriptions and proactive usage triggers

## Plugin Development
- Each plugin lives in `plugins/<plugin-name>/`
- Plugin manifest required: `.claude-plugin/plugin.json`
- Maintain parallel structure in `.claude/` for local development/testing
- Update `marketplace.json` when adding new plugins
- Test plugins locally with `/plugin marketplace add /path/to/repo`
