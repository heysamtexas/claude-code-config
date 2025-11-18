# Claude Code Observability Setup Guide

This guide explains how to enable centralized observability for Claude Code using Azure Application Insights and OpenTelemetry.

## Overview

Claude Code has native OpenTelemetry (OTel) support that exports metrics and logs to Azure Application Insights, providing:

- **Usage metrics**: Sessions, tool calls, lines of code modified, PRs/commits created
- **Audit logs**: Complete user prompts, tool execution, file modifications, git operations
- **Error tracking**: Failed tool calls, API errors, timeouts
- **Cost tracking**: Token consumption and USD costs per user/team

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Configuration](#configuration)
4. [What Gets Tracked](#what-gets-tracked)
5. [Privacy & Security](#privacy--security)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

Before setting up observability, you need:

1. **Azure Application Insights instance** (see [AZURE_SETUP.md](./AZURE_SETUP.md))
2. **Application Insights connection string** (from Azure Portal)
3. **Claude Code** installed (`claude --version` to verify)

## Quick Start

### Method 1: Install as Plugin (Recommended)

```bash
# 1. Add this repo as a marketplace (one-time)
/plugin marketplace add https://github.com/Digital-Wildcatters/claude-code-config

# 2. Install the Azure Observability plugin
/plugin install azure-observability@Digital-Wildcatters

# 3. Run interactive setup
/setup-observability

# 4. Validate configuration
/validate-telemetry
```

**Benefits**: Automatic hooks, slash commands, guided setup, easy team distribution.

---

### Method 2: Manual Setup

### 1. Get Azure Credentials

Obtain your Application Insights connection string from the Azure Portal:

```bash
# Use helper script
./scripts/get-azure-credentials.sh

# Or manually:
# Azure Portal > Application Insights > Properties
# Copy "Connection String"
```

### 2. Configure Environment Variables

Copy the example environment file and fill in your Azure credentials:

```bash
cp templates/.env.example .env
```

Edit `.env` and set:

```bash
AZURE_OTLP_ENDPOINT=https://YOUR_REGION.in.applicationinsights.azure.com/v1/traces
AZURE_APP_INSIGHTS_CONNECTION_STRING=InstrumentationKey=...;IngestionEndpoint=...
TEAM_NAME=your-team-name
PROJECT_NAME=your-project-name
```

### 3. Enable Telemetry

Option A: **Project-level** (recommended for shared team config)

```bash
cp templates/settings.example.json .claude/settings.json
# Edit settings.json and replace placeholder values with actual credentials
```

Option B: **User-level** (personal configuration)

```bash
cp templates/settings.example.json ~/.claude/settings.json
# Edit ~/.claude/settings.json with your credentials
```

Option C: **Local project only** (gitignored, for testing)

```bash
cp templates/settings.example.json .claude/settings.local.json
# Edit settings.local.json - this file won't be committed
```

### 4. Validate Setup

Test that telemetry is working:

```bash
./scripts/validate-telemetry.sh
```

This will run a test Claude Code session and verify data appears in Azure.

## Configuration

### Settings Hierarchy

Claude Code uses a hierarchical settings system (highest to lowest precedence):

1. **Enterprise managed**: `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS)
2. **CLI arguments**: `claude --settings /path/to/settings.json`
3. **Local project**: `.claude/settings.local.json` (gitignored)
4. **Shared project**: `.claude/settings.json` (version controlled)
5. **User settings**: `~/.claude/settings.json`

### Environment Variables

Key environment variables for telemetry:

| Variable | Description | Required |
|----------|-------------|----------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OTel export (1=on, 0=off) | Yes |
| `OTEL_LOG_USER_PROMPTS` | Include full prompt text (1=on, 0=off) | Yes (for audit) |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Azure OTLP endpoint URL | Yes |
| `OTEL_EXPORTER_OTLP_HEADERS` | Authorization header with connection string | Yes |
| `OTEL_METRICS_EXPORTER` | Metrics exporter type (otlp/prometheus/console) | Yes |
| `OTEL_LOGS_EXPORTER` | Logs exporter type (otlp/console) | Yes |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes (team, project, env) | Optional |
| `OTEL_METRIC_EXPORT_INTERVAL_MILLIS` | Metrics export frequency (default: 60000) | Optional |
| `OTEL_LOG_EXPORT_INTERVAL_MILLIS` | Logs export frequency (default: 5000) | Optional |

### Custom Hooks

Two custom hooks are included for enhanced audit logging:

**1. Audit Tool Use** (`.claude/hooks/audit-tool-use.sh`)
- Triggered on git operations (push, commit)
- Logs tool execution details
- Creates local audit logs in `~/.claude/audit-logs/`

**2. Security Events** (`.claude/hooks/security-events.sh`)
- Triggered on every user prompt
- Scans for security-sensitive keywords
- Logs potential security events in `~/.claude/security-logs/`

## What Gets Tracked

### Native OpenTelemetry Metrics (8 total)

| Metric | Description |
|--------|-------------|
| `claude_code.session.count` | Number of sessions initiated |
| `claude_code.lines_of_code.count` | Lines of code modified |
| `claude_code.pull_request.count` | Pull requests created |
| `claude_code.commit.count` | Git commits made |
| `claude_code.cost.usage` | Session expenses in USD |
| `claude_code.token.usage` | Token consumption (input/output/cache) |
| `claude_code.code_edit_tool.decision` | Tool permission decisions |
| `claude_code.active_time.total` | Active usage duration |

### Native OpenTelemetry Events (5 types)

1. **User Prompt** - User prompt submissions (full text when `OTEL_LOG_USER_PROMPTS=1`)
2. **Tool Result** - Tool execution outcomes with duration and success
3. **API Request** - Model API calls with token/cost data
4. **API Error** - Failed requests with error details
5. **Tool Decision** - Permission choices (accept/reject/ask)

### Standard Attributes (included with all metrics/events)

- `session.id` - Unique session identifier
- `app.version` - Claude Code version
- `organization.id` - Anthropic organization ID
- `user.account_uuid` - User identifier
- `terminal.type` - Terminal environment
- `model` - Claude model used (e.g., claude-sonnet-4-5)
- Custom: `team`, `project`, `env` (from OTEL_RESOURCE_ATTRIBUTES)

## Privacy & Security

### What's Logged

**With `OTEL_LOG_USER_PROMPTS=1` enabled:**
- ✅ Complete user prompts (what users ask Claude to do)
- ✅ Tool execution details (commands run, files modified)
- ✅ Git operations (commits, pushes, PRs)
- ✅ File paths and names (but not file contents)
- ✅ Error messages and stack traces
- ✅ Token usage and costs

**NOT logged:**
- ❌ File contents (unless user explicitly puts them in prompts)
- ❌ Passwords or secrets (unless user includes in prompts)
- ❌ Screenshots or binary data

### Data Retention

- **Application Insights**: 90 days by default
- **Log Analytics**: Configurable (30-730 days)
- **Local audit logs**: Indefinite (manual cleanup required)

### Access Control

- Azure RBAC controls who can view telemetry data
- Security/compliance teams should have restricted access to audit logs
- Users can query their own session data via session ID

### User Disclosure

All users must be informed that Claude Code usage is monitored. See [PRIVACY_NOTICE.md](./PRIVACY_NOTICE.md) for the disclosure document.

### Opting Out

Users can disable telemetry locally (if not enforced via managed settings):

```bash
# In .claude/settings.local.json or ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0"
  }
}
```

Or via environment variable:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=0
```

## Troubleshooting

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues and solutions.

### Quick Checks

**Is telemetry enabled?**

```bash
claude --print --output-format json <<< "test" | jq '.env.CLAUDE_CODE_ENABLE_TELEMETRY'
```

**Test OTLP endpoint connectivity:**

```bash
curl -I "$OTEL_EXPORTER_OTLP_ENDPOINT"
```

**Enable debug logging:**

```bash
OTEL_DEBUG=1 claude
```

**Check local audit logs:**

```bash
ls -lh ~/.claude/audit-logs/
tail -f ~/.claude/audit-logs/tool-usage-$(date +%Y-%m).log
```

## Next Steps

1. **View dashboards**: Log into Azure Portal > Application Insights > Workbooks
2. **Set up alerts**: Configure budget thresholds and anomaly detection
3. **Share with team**: Distribute this config to other team members
4. **Monitor adoption**: Track usage metrics to measure Claude Code adoption

## Resources

- [Azure Setup Guide](./AZURE_SETUP.md) - Provision Azure infrastructure
- [Privacy Notice](./PRIVACY_NOTICE.md) - User disclosure document
- [Troubleshooting Guide](./TROUBLESHOOTING.md) - Common issues
- [Claude Code Documentation](https://code.claude.com/docs/)
- [OpenTelemetry Specification](https://opentelemetry.io/docs/)
