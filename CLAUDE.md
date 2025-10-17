# Repository Structure
- `.claude/agents/` - Custom subagents for specialized tasks
- `.claude/commands/` - Slash commands for quick actions
- `.claude/settings.json` - Hooks and configuration

# Subagents

Use these specialized subagents proactively when their expertise is needed:

## gilfoyle
**When to use:** Code review, complexity reduction, architectural guidance, performance problems, mentoring
**Trigger:** MUST BE USED when code needs divine intervention. Use proactively when reviewing significant code changes.
**File:** `.claude/agents/gilfoyle.md`

## copywriter
**When to use:** Documentation, README files, error messages, API documentation, user-facing content
**Trigger:** MUST BE USED when reviewing or creating any documentation, error messages, or text that could cause confusion for humans or AI agents.
**File:** `.claude/agents/copywriter_subagent.md`

## coverage-enforcer
**When to use:** Django test coverage analysis, coverage enforcement, coverage improvement planning
**Trigger:** MUST BE USED for any coverage-related tasks, Django test analysis, or coverage improvement requests.
**File:** `.claude/agents/coverage_subagent.md`

## spyros
**When to use:** SOC 2 compliance review, audit preparation, control gap analysis for code and infrastructure
**Trigger:** Explicit invocation when assessing compliance implications. Use when touching access controls, secrets management, logging, encryption, or other SOC 2-relevant controls.
**File:** `.claude/agents/spyros.md`

# Slash Commands

## /catchmeup
Get a conversational summary of recent commits and current work status. Perfect for returning to a project after time away.

## /auditclaudemd
Review this CLAUDE.md file against current Claude Code best practices. Searches for latest docs, evaluates content, removes cruft.

# Hooks

## Pre-Commit Formatting
**Trigger:** Any `git commit` command
**Action:** Runs `ruff format src/` and stages changes automatically
**Config:** `.claude/settings.json`

# Guidelines

## Code Style
- Use ATX-style headers (# ##) in markdown files
- Subagent files follow naming pattern: descriptive-kebab-case.md
- Documentation goes in README.md, not inline comments

## Documentation
- Human-facing documentation belongs in README.md
- Claude-facing instructions belong in this file
- New subagents must include clear descriptions and proactive usage triggers
