# Azure Observability Plugin for Claude Code

Centralized observability for Claude Code using Azure Application Insights with OpenTelemetry integration.

## Features

- **Usage Metrics**: Sessions, tool calls, lines of code modified, PRs/commits created
- **Audit Logs**: Complete user prompts, tool execution, file modifications, git operations
- **Error Tracking**: Failed tool calls, API errors, timeouts
- **Cost Tracking**: Token consumption and USD costs per user/team/project
- **Privacy Controls**: Transparent disclosure with opt-out options

## Installation

### Via Marketplace (Recommended)

```bash
# 1. Add the marketplace (one-time)
/plugin marketplace add Digital-Wildcatters/claude-code-config

# 2. Install this plugin
/plugin install azure-observability

# 3. Run interactive setup
/setup-observability

# 4. Validate configuration
/validate-telemetry
```

### Manual Setup (Advanced)

If you prefer manual configuration:

1. Clone this repo
2. Copy templates: `cp plugins/azure-observability/templates/.env.example .env`
3. Run setup script: `./plugins/azure-observability/scripts/get-azure-credentials.sh`
4. Validate: `./plugins/azure-observability/scripts/validate-telemetry.sh`

## Quick Start

After installation, use these slash commands:

- **`/setup-observability`** - Interactive Azure setup wizard
- **`/validate-telemetry`** - Verify configuration and connectivity
- **`/observability-status`** - Show current telemetry status
- **`/view-privacy-notice`** - Display privacy disclosure
- **`/azure-dashboard`** - KQL query templates for dashboards

## What Gets Tracked

When telemetry is enabled:

### Automatic Collection
- Session counts and duration
- Tool execution (files modified, git operations)
- Token usage and costs (input/output/cache)
- Error rates and failed operations
- Model selection and performance

### Audit Logging (with `OTEL_LOG_USER_PROMPTS=1`)
- **Complete user prompts** (what you ask Claude to do)
- Command execution details
- Security-sensitive operation detection

## Documentation

- **[OBSERVABILITY.md](docs/OBSERVABILITY.md)** - Complete setup guide
- **[AZURE_SETUP.md](docs/AZURE_SETUP.md)** - Azure infrastructure provisioning
- **[PRIVACY_NOTICE.md](docs/PRIVACY_NOTICE.md)** - User disclosure & privacy policy
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## Privacy & Compliance

**Important**: This plugin enables **full prompt logging** by default for audit compliance.

### What's Logged
- ✅ Complete text of user prompts
- ✅ Tool execution details
- ✅ Git operations (commits, pushes)
- ✅ Cost and token usage

### What's NOT Logged
- ❌ File contents (unless in prompts)
- ❌ Passwords/secrets (unless in prompts)
- ❌ Activity outside Claude Code

### User Rights
- Access your own session data
- Request deletion (subject to retention policies)
- Opt out (if not org-enforced)

See [PRIVACY_NOTICE.md](docs/PRIVACY_NOTICE.md) for complete disclosure.

## Configuration

The plugin uses Azure Application Insights for telemetry collection:

### Required Environment Variables
```bash
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_LOG_USER_PROMPTS=1
OTEL_EXPORTER_OTLP_ENDPOINT=https://<region>.in.applicationinsights.azure.com/v1/traces
OTEL_EXPORTER_OTLP_HEADERS=Authorization=<connection-string>
OTEL_METRICS_EXPORTER=otlp
OTEL_LOGS_EXPORTER=otlp
```

### Optional Customization
```bash
OTEL_RESOURCE_ATTRIBUTES=team=<team-name>,project=<project-name>,env=production
OTEL_METRIC_EXPORT_INTERVAL_MILLIS=60000  # 1 minute
OTEL_LOG_EXPORT_INTERVAL_MILLIS=5000      # 5 seconds
```

## Architecture

### Plugin Structure
```
plugins/azure-observability/
├── .claude-plugin/
│   ├── plugin.json           # Plugin manifest
│   └── marketplace.json      # Local marketplace config
├── commands/                 # Slash commands (5 total)
│   ├── setup-observability.md
│   ├── validate-telemetry.md
│   ├── observability-status.md
│   ├── view-privacy-notice.md
│   └── azure-dashboard.md
├── skills/                   # Agent Skills
│   └── azure-observability/
│       └── SKILL.md         # Automated setup guidance
├── hooks/
│   └── hooks.json           # Hook definitions
├── templates/               # Configuration templates
│   ├── settings.example.json
│   └── .env.example
├── docs/                    # Documentation (4 files)
├── scripts/                 # Helper scripts (2 files)
└── README.md               # This file
```

### Custom Hooks

The plugin includes two custom hooks (scripts in repo root `.claude/hooks/`):

1. **audit-tool-use.sh** - Logs git operations (push, commit) for audit trail
2. **security-events.sh** - Scans prompts for security-sensitive keywords

Logs are saved locally in `~/.claude/audit-logs/` and `~/.claude/security-logs/`.

## Cost Estimation

Typical monthly costs for Azure infrastructure:

| Resource | Monthly Cost |
|----------|--------------|
| Application Insights (5 GB/month) | $10-25 |
| Log Analytics (10 GB/month) | $20-40 |
| Data retention (90 days) | $5-15 |
| **Total** | **$35-80/month** |

Costs scale with number of users and session frequency.

## Troubleshooting

**Telemetry not working?**
```bash
/observability-status  # Check configuration
/validate-telemetry   # Run diagnostics
```

**Common issues:**
- Endpoint not reachable → Check firewall allows HTTPS to Azure
- No data in Azure → Wait 5 minutes for ingestion
- Hooks not executing → Ensure scripts are executable (`chmod +x`)

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for detailed solutions.

## Support

- **Documentation**: See [docs/](docs/) directory
- **Issues**: Report via GitHub Issues
- **Questions**: Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## License

MIT License - See [LICENSE](../../LICENSE) file

---

**Part of the [Digital Wildcatters Claude Code Plugin Marketplace](https://github.com/Digital-Wildcatters/claude-code-config)**
