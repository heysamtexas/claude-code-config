---
name: observability-status
description: Display current Claude Code observability configuration status
---

# Observability Configuration Status

Check and display the current state of Claude Code telemetry and observability configuration.

## Check Configuration Status

Gather and present the current configuration:

### 1. Telemetry Enablement

Check if telemetry is enabled:

```bash
echo "Telemetry Status: ${CLAUDE_CODE_ENABLE_TELEMETRY:-disabled}"
```

**Expected**: `1` (enabled) or `0`/empty (disabled)

**Status Indicators**:
- ✅ `CLAUDE_CODE_ENABLE_TELEMETRY=1` - Telemetry is **enabled**
- ❌ `CLAUDE_CODE_ENABLE_TELEMETRY=0` or unset - Telemetry is **disabled**

### 2. Prompt Logging

Check if full prompts are being logged:

```bash
echo "Prompt Logging: ${OTEL_LOG_USER_PROMPTS:-disabled}"
```

**Status Indicators**:
- ✅ `OTEL_LOG_USER_PROMPTS=1` - Full prompts logged (for audit compliance)
- ⚠️  `OTEL_LOG_USER_PROMPTS=0` or unset - Only prompt length logged (privacy mode)

### 3. Azure Configuration

Check Azure Application Insights endpoint:

```bash
echo "OTLP Endpoint: ${OTEL_EXPORTER_OTLP_ENDPOINT:-not configured}"
echo "Metrics Exporter: ${OTEL_METRICS_EXPORTER:-not configured}"
echo "Logs Exporter: ${OTEL_LOGS_EXPORTER:-not configured}"
```

**Expected Configuration**:
```
OTLP Endpoint: https://<region>.in.applicationinsights.azure.com/v1/traces
Metrics Exporter: otlp
Logs Exporter: otlp
```

### 4. Resource Attributes

Check team/project segmentation:

```bash
echo "Resource Attributes: ${OTEL_RESOURCE_ATTRIBUTES:-not configured}"
```

**Example**: `team=engineering,project=backend,env=production`

### 5. Export Intervals

Check how frequently data is sent to Azure:

```bash
echo "Metric Export Interval: ${OTEL_METRIC_EXPORT_INTERVAL_MILLIS:-60000}ms"
echo "Log Export Interval: ${OTEL_LOG_EXPORT_INTERVAL_MILLIS:-5000}ms"
```

### 6. Configuration Source

Determine where settings are coming from:

```bash
# Check for settings files
if [ -f ".claude/settings.json" ]; then
  echo "✓ Project settings: .claude/settings.json"
fi

if [ -f ".claude/settings.local.json" ]; then
  echo "✓ Local override: .claude/settings.local.json"
fi

if [ -f "$HOME/.claude/settings.json" ]; then
  echo "✓ User settings: ~/.claude/settings.json"
fi

if [ -f "/Library/Application Support/ClaudeCode/managed-settings.json" ]; then
  echo "✓ Enterprise managed settings (organization-wide)"
fi
```

**Settings Hierarchy** (highest to lowest precedence):
1. Enterprise managed settings
2. CLI `--settings` argument
3. `.claude/settings.local.json` (gitignored)
4. `.claude/settings.json` (version controlled)
5. `~/.claude/settings.json` (user-wide)

### 7. Plugin Status

Check if Azure Observability plugin is installed:

```bash
# Run /plugin list and look for azure-observability
```

**Status**:
- ✅ Plugin installed and enabled
- ⚠️  Plugin installed but disabled
- ❌ Plugin not installed

### 8. Hook Status

Check if custom hooks are configured:

```bash
if [ -x ".claude/hooks/audit-tool-use.sh" ]; then
  echo "✓ Audit hook: executable"
else
  echo "❌ Audit hook: not found or not executable"
fi

if [ -x ".claude/hooks/security-events.sh" ]; then
  echo "✓ Security hook: executable"
else
  echo "❌ Security hook: not found or not executable"
fi
```

### 9. Dependency Status

Check required dependencies:

```bash
command -v jq &> /dev/null && echo "✓ jq installed" || echo "❌ jq not installed (hooks use fallback logging)"
command -v curl &> /dev/null && echo "✓ curl installed" || echo "❌ curl not installed"
command -v az &> /dev/null && echo "✓ Azure CLI installed" || echo "⚠️  Azure CLI not installed (setup script unavailable)"
```

## Status Summary

Present a summary table:

```
====================================
Claude Code Observability Status
====================================

Telemetry:           [✅ Enabled / ❌ Disabled]
Prompt Logging:      [✅ Full / ⚠️  Length Only]
Azure Endpoint:      [✅ Configured / ❌ Not Set]
Plugin:              [✅ Installed / ❌ Not Installed]
Hooks:               [✅ Active / ⚠️  Partially / ❌ None]

Team/Project:        [team-name/project-name]
Data Destination:    [Azure Region]

====================================
```

## Interpretation Guide

### ✅ Fully Configured

All checks pass:
- Telemetry enabled
- Azure endpoint configured and reachable
- Prompt logging active
- Hooks executable
- Team/project attributes set

**Action**: None required. Observability is working.

### ⚠️  Partially Configured

Some components missing:
- Telemetry enabled but no Azure endpoint
- Hooks not executable
- Missing team/project attributes

**Action**: Run `/setup-observability` or fix specific issues.

### ❌ Not Configured

Telemetry disabled or minimal configuration:

**Action**:
1. Run `/setup-observability` to configure
2. Or manually enable: Set `CLAUDE_CODE_ENABLE_TELEMETRY=1`

### 🔒 Org-Wide Enforcement

If enterprise managed settings are detected:

**Note**: Telemetry is enforced organization-wide via managed settings. Local overrides may not work. Contact IT/Security if you need to opt out.

## Quick Actions

Based on status, suggest next steps:

**If not configured**:
```bash
/setup-observability
```

**If configured but not validated**:
```bash
/validate-telemetry
```

**If validation fails**:
```bash
cat docs/TROUBLESHOOTING.md
```

**If configured and working**:
- View metrics in Azure Portal
- Set up dashboards: `docs/AZURE_SETUP.md`
- Review privacy notice: `/view-privacy-notice`

## Advanced: View Full Configuration

For detailed configuration inspection:

```bash
# View all OTel environment variables
env | grep -E '(CLAUDE_CODE|OTEL_)'

# View settings.json OTel config
cat .claude/settings.json | jq '.env' 2>/dev/null || echo "settings.json not found or invalid JSON"

# View recent debug logs
ls -lt ~/.claude/debug/ | head -5

# Check local audit logs
ls -lh ~/.claude/audit-logs/ ~/.claude/security-logs/ 2>/dev/null
```

## Troubleshooting

If status shows unexpected values:

1. **Check environment variables**: May be set in shell profile
2. **Check settings files**: Multiple files can override each other
3. **Check enterprise settings**: Org-wide enforcement may be active
4. **Restart shell**: Environment changes require new shell session

For persistent issues: `docs/TROUBLESHOOTING.md`
