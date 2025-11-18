---
name: validate-telemetry
description: Validate Claude Code telemetry configuration and test Azure connectivity
---

# Validate Telemetry Setup

Run comprehensive checks to verify that Claude Code observability is properly configured and data is reaching Azure Application Insights.

## Validation Process

Execute the validation script and interpret results for the user:

```bash
./scripts/validate-telemetry.sh
```

## What Gets Checked

Explain that the validation script verifies:

### 1. Claude Code Installation
- ✓ Claude Code is installed and accessible
- ✓ Version information displayed

### 2. Telemetry Configuration
- ✓ `CLAUDE_CODE_ENABLE_TELEMETRY=1` (telemetry enabled)
- ✓ `OTEL_LOG_USER_PROMPTS=1` (full prompt logging for audit)
- ✓ Exporter types set to `otlp`

### 3. Azure Connectivity
- ✓ `OTEL_EXPORTER_OTLP_ENDPOINT` is set and reachable
- ✓ Azure Application Insights endpoint responds
- ✓ Connection string format is valid

### 4. Hook Configuration
- ✓ Hooks are defined in settings or plugin
- ✓ Hook scripts are executable
- ✓ `audit-tool-use.sh` and `security-events.sh` permissions correct

### 5. Dependencies
- ✓ `jq` installed (required for JSON parsing in hooks)
- ✓ `curl` available for connectivity tests

### 6. Optional: Test Telemetry Export
- User can choose to run a test Claude Code session
- Data should appear in Azure within 2-5 minutes
- Provides session ID for Azure query verification

## Interpreting Results

### All Checks Passed
```
✓ All checks passed!

Next steps:
1. Run a Claude Code session
2. Wait 2-5 minutes
3. Check Azure Application Insights for data
4. View docs/OBSERVABILITY.md for dashboard setup
```

Congratulate the user and suggest:
- Run actual Claude Code session to generate telemetry
- Check Azure Portal > Application Insights > Transaction search
- Set up dashboards using docs/AZURE_SETUP.md

### Some Checks Failed

If validation fails, guide user through fixes:

**Telemetry not enabled:**
```
Set in .claude/settings.json:
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  }
}
```

**Endpoint not reachable:**
- Check network/firewall (outbound HTTPS to Azure required)
- Verify endpoint URL format: `https://<region>.in.applicationinsights.azure.com/v1/traces`
- Test DNS resolution: `nslookup <region>.in.applicationinsights.azure.com`

**Hooks not executable:**
```bash
chmod +x .claude/hooks/audit-tool-use.sh
chmod +x .claude/hooks/security-events.sh
```

**Dependencies missing:**
```bash
# macOS
brew install jq

# Linux (Ubuntu/Debian)
sudo apt-get install jq
```

## Manual Verification

If automated validation fails or user wants manual checks:

### Check Environment Variables
```bash
echo $CLAUDE_CODE_ENABLE_TELEMETRY
echo $OTEL_EXPORTER_OTLP_ENDPOINT
echo $OTEL_METRICS_EXPORTER
```

### Test Azure Endpoint
```bash
curl -I "$OTEL_EXPORTER_OTLP_ENDPOINT"
# Expected: HTTP/1.1 405 Method Not Allowed (endpoint exists)
```

### View Current Settings
```bash
cat .claude/settings.json | jq '.env'
```

## Troubleshooting

If validation continues to fail, direct user to:

1. **Troubleshooting Guide**: `docs/TROUBLESHOOTING.md`
2. **Check Status**: `/observability-status`
3. **Re-run Setup**: `/setup-observability`
4. **Azure Logs**: Check Azure Portal for ingestion errors

## Generate Diagnostic Report

For persistent issues, collect diagnostic info:

```bash
{
  echo "Claude Code Version:"
  claude --version

  echo -e "\nTelemetry Status:"
  echo $CLAUDE_CODE_ENABLE_TELEMETRY

  echo -e "\nOTel Config:"
  env | grep OTEL_

  echo -e "\nEndpoint Test:"
  curl -I "$OTEL_EXPORTER_OTLP_ENDPOINT" 2>&1

  echo -e "\nRecent Debug Logs:"
  ls -lt ~/.claude/debug/ | head -5 2>&1
} > claude-telemetry-diagnostics.txt

cat claude-telemetry-diagnostics.txt
```

Save this for troubleshooting or support requests.

## Success Indicators

Validation is successful when:
- All checks show ✓ (green checkmarks)
- Azure endpoint is reachable
- Hooks are executable
- Test session ID can be queried in Azure

After successful validation, telemetry data should flow to Azure Application Insights automatically.
