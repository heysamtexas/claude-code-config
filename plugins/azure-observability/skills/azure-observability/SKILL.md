---
name: azure-observability
description: Guide users through setting up and managing Claude Code observability with Azure Application Insights, including full audit logging, cost tracking, error monitoring, and compliance requirements
---

# Azure Observability for Claude Code

Specialized skill for helping users configure, validate, and manage centralized observability for Claude Code using Azure Application Insights with OpenTelemetry.

## When to Invoke This Skill

Activate when users ask about:
- Setting up monitoring, telemetry, or observability for Claude Code
- Tracking Claude Code usage, costs, or token consumption
- Audit logging or compliance requirements for Claude Code
- Azure Application Insights integration
- Troubleshooting telemetry configuration
- Understanding what data is collected and privacy implications
- Viewing dashboards or metrics for Claude Code usage

## What This Skill Provides

### 1. Comprehensive Observability Setup

- **Usage Metrics**: Sessions, tool calls, lines of code modified, PRs/commits
- **Audit Logs**: Complete user prompts, tool execution, file modifications, git operations
- **Error Tracking**: Failed tool calls, API errors, timeouts
- **Cost Tracking**: Token consumption and USD costs per user/team/project

### 2. Privacy & Compliance

- Full transparency about what's logged
- User disclosure requirements (PRIVACY_NOTICE.md)
- Opt-out mechanisms
- GDPR/compliance considerations

### 3. Azure Infrastructure

- Application Insights provisioning
- Log Analytics Workspace configuration
- OpenTelemetry endpoint setup
- Dashboard and alert configuration

## Setup Workflow

When user requests observability setup, follow this sequence:

### Step 1: Understand Requirements

Ask clarifying questions:
- **Existing infrastructure?** "Do you already have Azure Application Insights set up?"
- **Scope?** "Is this for personal use, team-wide, or organization-wide deployment?"
- **Privacy concerns?** "Are you aware this will log complete user prompts for audit purposes?"
- **Budget?** "Estimated monthly cost is $35-80. Is this acceptable?"

### Step 2: Privacy Disclosure

**Critical**: Inform user about data collection BEFORE setup:

- Full user prompts are logged (what users ask Claude to do)
- Tool execution details (files modified, commands run)
- Git operations (commits, pushes, PRs)
- Token costs per session/user/team
- 90-day retention in Azure (default)

Direct them to privacy notice:
```bash
/view-privacy-notice
```

Confirm: "Do you want to proceed with full prompt logging enabled?"

### Step 3: Choose Setup Method

Offer options based on technical comfort:

**Option A: Automated Setup (Recommended)**
```bash
/setup-observability
```
- Runs interactive setup script
- Provisions Azure resources
- Configures OpenTelemetry automatically
- Validates configuration

**Option B: Manual Setup**
- Guide through `docs/AZURE_SETUP.md`
- User creates Azure resources via Portal
- Manual configuration of settings.json
- More control, more complex

### Step 4: Azure Infrastructure

**If user has Azure CLI**:
```bash
./scripts/get-azure-credentials.sh
```

**If using Portal**:
1. Create Resource Group: `rg-claude-code-observability`
2. Create Application Insights: `appi-claude-code`
3. Enable OpenTelemetry ingestion (automatic)
4. Copy connection string

Provide step-by-step from `docs/AZURE_SETUP.md`.

### Step 5: Configuration

Help user configure OpenTelemetry:

**Environment variables needed**:
```bash
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_LOG_USER_PROMPTS=1
OTEL_EXPORTER_OTLP_ENDPOINT=https://<region>.in.applicationinsights.azure.com/v1/traces
OTEL_EXPORTER_OTLP_HEADERS=Authorization=<connection-string>
OTEL_METRICS_EXPORTER=otlp
OTEL_LOGS_EXPORTER=otlp
OTEL_RESOURCE_ATTRIBUTES=team=<team>,project=<project>
```

**Configuration methods**:
1. Copy `templates/settings.example.json` to `.claude/settings.json`
2. Copy `templates/.env.example` to `.env`
3. Fill in Azure credentials

### Step 6: Validation

Run validation after setup:
```bash
/validate-telemetry
```

Checks:
- ✓ Telemetry enabled
- ✓ Azure endpoint reachable
- ✓ Connection string valid
- ✓ Hooks executable
- ✓ Dependencies installed (jq, curl)

### Step 7: Test & Verify

1. Run a Claude Code session
2. Wait 2-5 minutes for data ingestion
3. Check Azure Portal > Application Insights > Transaction search
4. Look for session metrics and events

Query to find test session:
```kql
customMetrics
| where name == "claude_code.session.count"
| where timestamp > ago(10m)
```

### Step 8: Dashboards & Alerts

Help user set up visualizations:
```bash
/azure-dashboard
```

Provides:
- KQL query templates
- Dashboard configuration
- Alert setup instructions
- Portal deep links

## Troubleshooting Guide

When users report issues:

### Issue: "No data in Azure"

**Check**:
1. Is telemetry enabled? `/observability-status`
2. Is endpoint correct? Format: `https://<region>.in.applicationinsights.azure.com/v1/traces`
3. Network connectivity? `curl -I $OTEL_EXPORTER_OTLP_ENDPOINT`
4. Wait 5 minutes (ingestion delay)

**Solution**: Run `/validate-telemetry` for detailed diagnostics

### Issue: "Hooks not executing"

**Check**:
1. Are scripts executable? `chmod +x .claude/hooks/*.sh`
2. Is `jq` installed? `brew install jq` (macOS) or `apt install jq` (Linux)
3. Are hooks defined in settings.json or plugin?

**Solution**: Check `docs/TROUBLESHOOTING.md` section "Hooks Not Executing"

### Issue: "High Azure costs"

**Check**:
1. Data ingestion volume (Azure Portal > Usage and estimated costs)
2. Prompt logging enabled? (`OTEL_LOG_USER_PROMPTS=1` adds significant data)
3. Retention period (90 days default)

**Solution**:
- Reduce log sampling: Increase `OTEL_LOG_EXPORT_INTERVAL_MILLIS`
- Disable full prompts: Set `OTEL_LOG_USER_PROMPTS=0` (loses audit detail)
- Reduce retention: Azure Portal > Data Retention > 30 days

### Issue: "Connection refused / timeout"

**Check**:
1. Firewall allows outbound HTTPS to `*.in.applicationinsights.azure.com`
2. Corporate proxy configured? Set `HTTPS_PROXY`
3. Correct Azure region in endpoint URL?

**Solution**: See `docs/TROUBLESHOOTING.md` section "Connection Errors"

## Privacy & Compliance Guidance

### Before Organizational Deployment

**Legal Review**:
- [ ] Privacy notice reviewed by legal team
- [ ] Data protection officer approved
- [ ] Aligned with company privacy policy
- [ ] GDPR/CCPA compliance verified

**Communication**:
- [ ] Announce to all users before enabling
- [ ] Include in onboarding materials
- [ ] Provide opt-out instructions (if allowed)
- [ ] Document data retention and access policies

**Technical**:
- [ ] Azure RBAC configured (restrict audit log access)
- [ ] Data retention policies set
- [ ] Opt-out mechanism tested
- [ ] Security team has restricted access to prompts

### User Disclosure

Always inform users:
1. **What's logged**: Full prompts, tool usage, costs
2. **Why**: Audit compliance, security, cost management
3. **Who has access**: Security team only for full prompts
4. **Retention**: 90 days default
5. **Opt-out**: Available if not org-enforced

Direct to: `/view-privacy-notice`

## Cost Estimation

Typical costs for Azure infrastructure:

| Resource | Monthly Cost |
|----------|--------------|
| Application Insights (5 GB/month) | $10-25 |
| Log Analytics (10 GB/month) | $20-40 |
| Data retention (90 days) | $5-15 |
| **Total** | **$35-80/month** |

Scales with:
- Number of users
- Session frequency
- Prompt verbosity (longer prompts = more data)
- Retention period

## Commands Reference

Provide these slash commands as appropriate:

| Command | Purpose |
|---------|---------|
| `/setup-observability` | Interactive Azure setup wizard |
| `/validate-telemetry` | Verify configuration and test connectivity |
| `/observability-status` | Show current telemetry configuration |
| `/view-privacy-notice` | Display privacy disclosure |
| `/azure-dashboard` | KQL queries and dashboard templates |

## Key Documentation

Direct users to relevant docs:

- **Setup Guide**: `docs/OBSERVABILITY.md`
- **Azure Infrastructure**: `docs/AZURE_SETUP.md`
- **Privacy Notice**: `docs/PRIVACY_NOTICE.md`
- **Troubleshooting**: `docs/TROUBLESHOOTING.md`

## Best Practices

### For Individual Users

1. Start with `/setup-observability`
2. Review privacy notice first
3. Test with personal projects before team deployment
4. Validate setup with `/validate-telemetry`
5. Set up budget alerts in Azure

### For Team Deployment

1. Provision Azure infrastructure (single App Insights for team)
2. Review privacy notice with legal
3. Communicate to team before enabling
4. Use `OTEL_RESOURCE_ATTRIBUTES` for team/project segmentation
5. Restrict audit log access via Azure RBAC
6. Set up team dashboards and cost tracking
7. Document opt-out process for team

### For Organization-Wide

1. Use enterprise managed settings (organization-wide enforcement)
2. Legal review and approval required
3. Privacy notice in employee handbook
4. Security team access only to full prompts
5. Finance team access to cost metrics
6. Chargeback model for cost allocation
7. Regular compliance audits

## Edge Cases & Advanced Topics

### Multi-Team Setup

Use `OTEL_RESOURCE_ATTRIBUTES` for segmentation:
```bash
OTEL_RESOURCE_ATTRIBUTES="team=engineering,project=backend,env=production"
```

Query by team in Azure:
```kql
customMetrics
| where customDimensions.team == "engineering"
```

### Hybrid Cloud (Azure + Other Platforms)

OpenTelemetry is platform-agnostic. Users can:
- Export to multiple backends (Azure + Datadog, etc.)
- Use different exporters: `OTEL_METRICS_EXPORTER=prometheus` for Grafana

### Opt-Out for Specific Users

If not org-enforced, users can disable locally:

Create `.claude/settings.local.json`:
```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0"
  }
}
```

(gitignored file, won't affect team)

### Custom Hook Scripts

Users can extend audit logging:
- Add custom patterns to `security-events.sh`
- Send data to additional systems (Splunk, Elasticsearch)
- Integrate with existing SIEM tools

## Success Metrics

Observability setup is successful when:

- ✅ User can see sessions in Azure within 5 minutes
- ✅ Cost tracking shows USD per session
- ✅ Dashboards display team usage patterns
- ✅ Alerts trigger on budget thresholds
- ✅ Audit logs available for compliance reviews
- ✅ Users understand privacy implications
- ✅ Team adoption tracked via metrics

## Summary

This skill provides end-to-end guidance for:
1. Azure infrastructure provisioning
2. OpenTelemetry configuration
3. Privacy disclosure and compliance
4. Validation and troubleshooting
5. Dashboard and alert setup
6. Team/organizational deployment

Always prioritize user awareness of privacy implications before enabling full audit logging.
