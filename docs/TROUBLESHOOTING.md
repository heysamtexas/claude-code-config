# Claude Code Observability - Troubleshooting Guide

Common issues and solutions for Claude Code telemetry and Azure integration.

## Table of Contents

1. [Telemetry Not Sending](#telemetry-not-sending)
2. [No Data in Azure](#no-data-in-azure)
3. [Hooks Not Executing](#hooks-not-executing)
4. [High Costs](#high-costs)
5. [Connection Errors](#connection-errors)
6. [Debugging Tools](#debugging-tools)

---

## Telemetry Not Sending

### Symptom

Claude Code runs normally, but no telemetry appears in Azure Application Insights.

### Diagnosis

Check if telemetry is enabled:

```bash
# Method 1: Check environment variable
echo $CLAUDE_CODE_ENABLE_TELEMETRY
# Expected: 1

# Method 2: Check Claude Code config
claude --print --output-format json <<< "test" | jq '.env.CLAUDE_CODE_ENABLE_TELEMETRY'
# Expected: "1"
```

### Solutions

**Solution 1: Enable telemetry explicitly**

```bash
# In .claude/settings.json or ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  }
}
```

**Solution 2: Check settings precedence**

Claude Code uses hierarchical settings. Higher precedence settings override lower ones:

1. Enterprise managed settings (highest)
2. CLI `--settings` argument
3. `.claude/settings.local.json`
4. `.claude/settings.json`
5. `~/.claude/settings.json` (lowest)

Check if a higher-precedence setting is disabling telemetry:

```bash
# Check for managed settings (macOS)
ls "/Library/Application Support/ClaudeCode/managed-settings.json"

# Check local override
cat .claude/settings.local.json | jq '.env.CLAUDE_CODE_ENABLE_TELEMETRY'
```

**Solution 3: Verify no traffic block**

Check that non-essential traffic isn't disabled:

```bash
echo $CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
# Should NOT be "true" if you want telemetry
```

---

## No Data in Azure

### Symptom

Telemetry is enabled (`CLAUDE_CODE_ENABLE_TELEMETRY=1`), but Azure shows no data.

### Diagnosis

**Check OTLP endpoint configuration:**

```bash
echo $OTEL_EXPORTER_OTLP_ENDPOINT
# Expected: https://<region>.in.applicationinsights.azure.com/v1/traces

echo $OTEL_EXPORTER_OTLP_HEADERS
# Expected: Authorization=InstrumentationKey=...;IngestionEndpoint=...
```

**Test endpoint connectivity:**

```bash
curl -I "$OTEL_EXPORTER_OTLP_ENDPOINT"
# Expected: HTTP/1.1 405 Method Not Allowed (endpoint exists)
# If timeout or connection refused, there's a network issue
```

### Solutions

**Solution 1: Fix endpoint URL**

The OTLP endpoint URL must match this format:

```bash
https://<REGION>.in.applicationinsights.azure.com/v1/traces
```

Common regions:
- `eastus` (East US)
- `westus2` (West US 2)
- `westeurope` (West Europe)
- `northeurope` (North Europe)

**Incorrect** ❌:
- `https://appinsights.azure.com/v1/traces` (missing region)
- `https://eastus.applicationinsights.azure.com` (wrong subdomain)
- HTTP instead of HTTPS

**Correct** ✅:
- `https://eastus.in.applicationinsights.azure.com/v1/traces`

**Solution 2: Fix connection string format**

The Authorization header must be the **full connection string**:

```bash
OTEL_EXPORTER_OTLP_HEADERS="Authorization=InstrumentationKey=xxx;IngestionEndpoint=https://eastus.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus.livediagnostics.monitor.azure.com/"
```

**Don't use just the instrumentation key** - use the full connection string from Azure Portal.

**Solution 3: Check exporter configuration**

Verify exporters are set to OTLP:

```bash
echo $OTEL_METRICS_EXPORTER  # Should be: otlp
echo $OTEL_LOGS_EXPORTER     # Should be: otlp
```

**Solution 4: Wait for data ingestion**

Azure Application Insights has a delay:
- **Metrics**: 1-2 minutes
- **Logs/Traces**: 2-5 minutes

Wait 5-10 minutes after running Claude Code before checking Azure.

**Solution 5: Enable debug mode**

See detailed telemetry export logs:

```bash
OTEL_DEBUG=1 claude "test prompt"
```

Look for errors like:
- `Failed to export metrics`
- `Connection refused`
- `Invalid endpoint`

---

## Hooks Not Executing

### Symptom

Custom hooks (`.claude/hooks/audit-tool-use.sh`, `security-events.sh`) are not running.

### Diagnosis

**Check hook configuration:**

```bash
cat .claude/settings.json | jq '.hooks'
```

**Check hook file permissions:**

```bash
ls -lh .claude/hooks/
# Should show: -rwxr-xr-x (executable)
```

**Check hook logs:**

```bash
# Hooks should create log files
ls -lh ~/.claude/audit-logs/
ls -lh ~/.claude/security-logs/
```

### Solutions

**Solution 1: Make hooks executable**

```bash
chmod +x .claude/hooks/audit-tool-use.sh
chmod +x .claude/hooks/security-events.sh
```

**Solution 2: Fix hook path**

Hooks must use absolute paths or relative to project root:

```json
{
  "hooks": {
    "PostToolUse": [{
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/audit-tool-use.sh"  // ✅ Relative to project
      }]
    }]
  }
}
```

**Solution 3: Check hook dependencies**

Hooks use `jq` for JSON parsing:

```bash
# Install jq if missing
# macOS:
brew install jq

# Linux (Ubuntu/Debian):
sudo apt-get install jq

# Verify:
jq --version
```

**Solution 4: Test hook manually**

```bash
# Create test JSON input
echo '{"session_id": "test", "tool_name": "Bash", "input": {}}' | .claude/hooks/audit-tool-use.sh

# Check for errors
echo $?  # Should be 0 (success)
```

**Solution 5: Check hook matcher**

Matchers must match exactly:

```json
{
  "PostToolUse": [{
    "matcher": "Bash(git push:*)",  // Only matches "git push" commands
    "hooks": [...]
  }]
}
```

To run hook on **all** tools, use `*`:

```json
{
  "PostToolUse": [{
    "matcher": "*",  // Matches everything
    "hooks": [...]
  }]
}
```

---

## High Costs

### Symptom

Azure bill is higher than expected for Claude Code telemetry.

### Diagnosis

**Check ingestion volume:**

```bash
# In Azure Portal > Log Analytics > Usage and estimated costs
# Look for data volume by table
```

**Identify cost drivers:**

| Cost Driver | Typical Impact |
|-------------|----------------|
| Data ingestion (per GB) | $2-3/GB |
| Data retention (90 days) | $0.10/GB/month |
| Query execution | Minimal (usually free tier) |
| Alerts | $0.10/alert/month |

### Solutions

**Solution 1: Reduce log sampling**

Send fewer events by increasing export intervals:

```json
{
  "env": {
    "OTEL_METRIC_EXPORT_INTERVAL_MILLIS": "300000",  // 5 minutes instead of 1
    "OTEL_LOG_EXPORT_INTERVAL_MILLIS": "30000"       // 30 seconds instead of 5
  }
}
```

**Solution 2: Disable full prompt logging**

Prompts are often the largest data source:

```json
{
  "env": {
    "OTEL_LOG_USER_PROMPTS": "0"  // Log only prompt length, not full text
  }
}
```

This reduces ingestion by 50-70% but loses audit trail detail.

**Solution 3: Reduce retention period**

```bash
# In Azure Portal > Application Insights > Usage and estimated costs
# Set Data Retention to 30 days instead of 90
```

**Solution 4: Archive old data**

Export old logs to cheaper blob storage:

```bash
# Set up continuous export to Azure Storage Account
# Cost: $0.02/GB/month (vs $0.10/GB in Log Analytics)
```

**Solution 5: Filter noisy events**

Add sampling to reduce volume:

```bash
# In Application Insights > Configure > Sampling
# Set to 20% (only process 1 in 5 events)
```

---

## Connection Errors

### Symptom

Errors like:
- `Connection refused`
- `Timeout`
- `SSL certificate verification failed`

### Diagnosis

**Test basic connectivity:**

```bash
# Test DNS resolution
nslookup eastus.in.applicationinsights.azure.com

# Test HTTPS connection
curl -v https://eastus.in.applicationinsights.azure.com/v1/traces

# Test with proxy (if applicable)
curl -x http://proxy.company.com:8080 https://eastus.in.applicationinsights.azure.com/v1/traces
```

### Solutions

**Solution 1: Check firewall rules**

Azure Application Insights requires outbound HTTPS (port 443) to:
- `*.in.applicationinsights.azure.com`
- `*.livediagnostics.monitor.azure.com`

Add these to your firewall allowlist.

**Solution 2: Configure proxy**

If behind corporate proxy:

```bash
export HTTPS_PROXY=http://proxy.company.com:8080
export NO_PROXY=localhost,127.0.0.1
```

Or in settings.json:

```json
{
  "env": {
    "HTTPS_PROXY": "http://proxy.company.com:8080"
  }
}
```

**Solution 3: Fix SSL certificate issues**

If using corporate SSL inspection:

```bash
# Add company CA certificate
export SSL_CERT_FILE=/path/to/company-ca.pem
```

**Solution 4: Use gRPC instead of HTTP**

Some networks work better with gRPC:

```json
{
  "env": {
    "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc"  // Instead of http/protobuf
  }
}
```

---

## Debugging Tools

### Enable Verbose Logging

**Claude Code debug mode:**

```bash
claude --debug "test prompt"
```

Logs to `~/.claude/debug/session-<id>.log`

**OpenTelemetry debug:**

```bash
OTEL_DEBUG=1 claude "test"
```

Shows detailed telemetry export attempts.

**Anthropic API debug:**

```bash
ANTHROPIC_LOG=debug claude "test"
```

Shows API request/response details.

### Check Session History

```bash
# View recent sessions
cat ~/.claude/history.jsonl | jq '.' | tail -20

# Find session by ID
cat ~/.claude/history.jsonl | jq 'select(.session_id == "abc123")'
```

### Query Azure Logs

In Azure Portal > Application Insights > Logs, run KQL queries:

**Check if data is arriving:**

```kql
traces
| where timestamp > ago(1h)
| summarize count() by bin(timestamp, 5m)
| render timechart
```

**Find your session:**

```kql
customMetrics
| where name == "claude_code.session.count"
| where customDimensions.session_id == "YOUR_SESSION_ID"
```

**Check for errors:**

```kql
traces
| where severityLevel >= 3  // Error or higher
| project timestamp, message, severityLevel
| order by timestamp desc
```

### Validate Configuration

Run validation script:

```bash
./scripts/validate-telemetry.sh
```

This checks:
- ✅ Telemetry enabled
- ✅ OTLP endpoint reachable
- ✅ Connection string valid
- ✅ Exporters configured
- ✅ Hooks executable
- ✅ Data arriving in Azure

---

## Still Having Issues?

### Collect Diagnostic Info

```bash
# Save this output for support
{
  echo "Claude Code Version:"
  claude --version

  echo -e "\nTelemetry Status:"
  echo $CLAUDE_CODE_ENABLE_TELEMETRY

  echo -e "\nOTel Config:"
  env | grep OTEL_

  echo -e "\nEndpoint Test:"
  curl -I "$OTEL_EXPORTER_OTLP_ENDPOINT"

  echo -e "\nRecent Debug Logs:"
  ls -lt ~/.claude/debug/ | head -5
} > claude-telemetry-diagnostics.txt
```

### Get Help

- **Internal support**: [SLACK CHANNEL / EMAIL]
- **Claude Code docs**: https://code.claude.com/docs/
- **Azure support**: https://learn.microsoft.com/en-us/azure/azure-monitor/
- **File issue**: [GITHUB REPO or INTERNAL ISSUE TRACKER]

Include:
- Diagnostic output (above)
- Error messages
- Steps to reproduce
- Expected vs actual behavior
