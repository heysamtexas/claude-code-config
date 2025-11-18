---
name: setup-observability
description: Interactive Azure Application Insights setup wizard for Claude Code observability
---

# Azure Observability Setup

Guide the user through setting up centralized observability for Claude Code using Azure Application Insights.

## Prerequisites Check

First, verify the user has:
1. Azure subscription with permissions to create resources
2. Azure CLI installed (`az --version`) or access to Azure Portal
3. Understanding that this will enable full prompt logging for audit compliance

## Setup Steps

### 1. Explain What Will Be Set Up

Inform the user that this process will configure:
- **Azure Application Insights** - OpenTelemetry endpoint for metrics and logs
- **Full audit logging** - Complete user prompts, tool usage, costs
- **Custom hooks** - Audit trail for git operations and security events
- **Privacy notice** - Transparent disclosure of what's tracked

### 2. Run Automated Setup Script

Execute the helper script:

```bash
./scripts/get-azure-credentials.sh
```

This script will:
- Check if Azure CLI is installed and authenticated
- Guide user through creating/selecting Azure resources
- Retrieve Application Insights connection string
- Optionally save credentials to `.env` file
- Optionally create `.claude/settings.json` with OTel configuration

### 3. Manual Setup Alternative

If the user prefers manual setup or doesn't have Azure CLI:

1. **Read Azure Setup Guide**:
   ```bash
   cat docs/AZURE_SETUP.md
   ```

2. **Copy Templates**:
   ```bash
   cp templates/.env.example .env
   cp templates/settings.example.json .claude/settings.json
   ```

3. **Direct user to**:
   - Azure Portal: https://portal.azure.com
   - Follow docs/AZURE_SETUP.md step-by-step
   - Fill in `.env` with Azure credentials manually

### 4. Configure Team/Project Details

Remind user to update:
- `TEAM_NAME` in `.env` (for cost allocation)
- `PROJECT_NAME` in `.env` (for metrics segmentation)
- `OTEL_RESOURCE_ATTRIBUTES` in settings.json if using custom approach

### 5. Privacy Notice

**Important**: Display privacy notice location:

```
See docs/PRIVACY_NOTICE.md for user disclosure requirements.

Before rolling out to your team:
- Review privacy notice with legal team
- Communicate to all users that usage is monitored
- Include opt-out instructions
```

### 6. Validation

Once setup is complete, run:

```bash
/validate-telemetry
```

This will verify:
- Telemetry is enabled
- OTLP endpoint is reachable
- Connection string is valid
- Hooks are executable

## Next Steps

After successful setup:

1. **Test locally**: Run Claude Code and verify data appears in Azure (2-5 minute delay)
2. **View dashboards**: Navigate to Azure Portal > Application Insights > Workbooks
3. **Set up alerts**: Configure budget thresholds and error rate alerts
4. **Share with team**: Distribute this plugin for team-wide adoption

## Troubleshooting

If setup fails, direct user to:
- `docs/TROUBLESHOOTING.md` - Common issues and solutions
- `/observability-status` - Check current configuration
- `./scripts/validate-telemetry.sh` - Detailed diagnostics

## Important Notes

- **Full prompt logging is enabled** by default (`OTEL_LOG_USER_PROMPTS=1`)
- Users must be informed via PRIVACY_NOTICE.md before deployment
- Azure costs: ~$35-80/month for typical usage (see docs/AZURE_SETUP.md)
- Data retention: 90 days default in Application Insights
