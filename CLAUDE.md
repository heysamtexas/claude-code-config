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
