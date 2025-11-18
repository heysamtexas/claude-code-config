---
name: azure-dashboard
description: Generate KQL queries and links for Azure Application Insights dashboards
---

# Azure Application Insights Dashboards

Provide KQL (Kusto Query Language) queries and Azure Portal links for viewing Claude Code observability data.

## Azure Portal Access

Direct user to Azure Portal Application Insights:

```
https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/~/applicationInsights
```

Then navigate to your Application Insights resource and go to **Logs** for running queries.

## Quick KQL Query Templates

Provide these ready-to-use queries for common observability tasks:

### 1. Session Activity (Last 24 Hours)

View all Claude Code sessions:

```kql
customMetrics
| where name == "claude_code.session.count"
| where timestamp > ago(24h)
| project timestamp, session_id=tostring(customDimensions.session_id), user=tostring(customDimensions.user_account_uuid)
| order by timestamp desc
```

### 2. Cost Tracking (Last 30 Days)

View total costs by team/project:

```kql
customMetrics
| where name == "claude_code.cost.usage"
| where timestamp > ago(30d)
| summarize TotalCost = sum(value) by team=tostring(customDimensions.team), project=tostring(customDimensions.project)
| order by TotalCost desc
```

### 3. Token Usage (Last 7 Days)

Track token consumption:

```kql
customMetrics
| where name == "claude_code.token.usage"
| where timestamp > ago(7d)
| summarize Tokens = sum(value) by bin(timestamp, 1h), token_type=tostring(customDimensions.token_type)
| render timechart
```

### 4. Tool Usage Patterns

Most-used tools:

```kql
traces
| where message contains "tool_name"
| where timestamp > ago(7d)
| extend tool = tostring(customDimensions.tool_name)
| summarize count() by tool
| order by count_ desc
| take 20
```

### 5. Error Rate

Failed operations over time:

```kql
traces
| where severityLevel >= 3  // Error or higher
| where timestamp > ago(24h)
| summarize ErrorCount = count() by bin(timestamp, 1h)
| render timechart
```

### 6. User Activity Heatmap

Sessions by hour of day:

```kql
customMetrics
| where name == "claude_code.session.count"
| where timestamp > ago(7d)
| extend hour = hourofday(timestamp)
| summarize Sessions = count() by hour
| render columnchart
```

### 7. Lines of Code Modified

Productivity metric:

```kql
customMetrics
| where name == "claude_code.lines_of_code.count"
| where timestamp > ago(30d)
| summarize LinesChanged = sum(value) by bin(timestamp, 1d), user=tostring(customDimensions.user_account_uuid)
| render timechart
```

### 8. Git Operations Audit

Commits and pushes:

```kql
customMetrics
| where name in ("claude_code.commit.count", "claude_code.pull_request.count")
| where timestamp > ago(7d)
| summarize Operations = count() by operation=name, user=tostring(customDimensions.user_account_uuid)
| order by Operations desc
```

### 9. Search Specific Session

Find data for a specific session:

```kql
union customMetrics, traces
| where customDimensions.session_id == "YOUR_SESSION_ID"
| project timestamp, itemType, name, message, customDimensions
| order by timestamp asc
```

### 10. User Prompts (If Enabled)

View user prompts (requires `OTEL_LOG_USER_PROMPTS=1`):

```kql
traces
| where customDimensions.event_type == "user_prompt"
| where timestamp > ago(24h)
| project timestamp, prompt=tostring(customDimensions.prompt), session_id=tostring(customDimensions.session_id)
| order by timestamp desc
```

**Warning**: This query returns sensitive audit data. Ensure you have proper authorization before running.

## Creating Custom Dashboards

Guide user through creating a Workbook dashboard:

### 1. Navigate to Workbooks

In Azure Portal > Application Insights > **Workbooks** > **+ New**

### 2. Add Query Tiles

For each metric you want to visualize:

1. Click **Add** > **Add query**
2. Paste a KQL query from above
3. Choose visualization type (chart, table, etc.)
4. Set time range and refresh interval
5. Add title and description

### 3. Example Dashboard Layout

**Executive Dashboard**:
- **Tile 1**: Total cost (last 30 days)
- **Tile 2**: Sessions by team (bar chart)
- **Tile 3**: Token usage trend (line chart)
- **Tile 4**: Top users by activity (table)

**Team Dashboard**:
- **Tile 1**: Team-specific cost breakdown
- **Tile 2**: Lines of code modified (heatmap)
- **Tile 3**: Tool usage patterns (pie chart)
- **Tile 4**: Error rate (line chart with threshold)

**Audit Dashboard**:
- **Tile 1**: Recent user prompts (table, restricted access)
- **Tile 2**: Git operations by user (table)
- **Tile 3**: Security events (if hooks active)
- **Tile 4**: Tool permission decisions

### 4. Save and Share

- Click **Done Editing**
- **Save As** > Name your workbook
- Set **Sharing**: Private or Shared
- **Pin to Dashboard** for quick access

## Setting Up Alerts

Configure automated alerts for important thresholds:

### Budget Alert

Navigate to **Alerts** > **+ Create alert rule**:

**Condition**:
```kql
customMetrics
| where name == "claude_code.cost.usage"
| summarize TotalCost = sum(value)
| where TotalCost > 1000  // $1000 threshold
```

**Action**: Email team lead when monthly budget exceeds threshold.

### Error Rate Alert

**Condition**:
```kql
traces
| where severityLevel >= 3
| summarize ErrorCount = count()
| where ErrorCount > 100  // 100 errors in 15 minutes
```

**Action**: Slack notification to on-call team.

### Anomaly Detection

Use Azure's built-in anomaly detection:

**Condition**: Detect unusual spikes in session count
**Sensitivity**: Medium
**Action**: Email security team for investigation

## Pre-built Workbook Templates

For detailed dashboard templates with KQL queries, see:

```bash
cat docs/AZURE_SETUP.md
```

Section "Step 8: Create Dashboards (Workbooks)" contains:
- Quick Start Dashboard configuration
- Executive, Team, and Audit dashboard templates
- Alert rule templates

## Quick Links

Generate portal deep links for common views:

**Application Insights Overview**:
```
https://portal.azure.com/#@YOUR_TENANT/resource/subscriptions/YOUR_SUBSCRIPTION/resourceGroups/rg-claude-code-observability/providers/microsoft.insights/components/appi-claude-code/overview
```

**Logs (Query Editor)**:
```
https://portal.azure.com/#@YOUR_TENANT/resource/subscriptions/YOUR_SUBSCRIPTION/resourceGroups/rg-claude-code-observability/providers/microsoft.insights/components/appi-claude-code/logs
```

**Workbooks**:
```
https://portal.azure.com/#@YOUR_TENANT/resource/subscriptions/YOUR_SUBSCRIPTION/resourceGroups/rg-claude-code-observability/providers/microsoft.insights/components/appi-claude-code/workbooks
```

(Replace `YOUR_TENANT`, `YOUR_SUBSCRIPTION` with actual values)

## Next Steps

After viewing dashboards:

1. **Refine queries** - Adjust time ranges and filters for your needs
2. **Schedule reports** - Export dashboard data on recurring schedule
3. **Share with stakeholders** - Provide view-only access to management
4. **Set up alerts** - Proactive monitoring for budget and errors
5. **Archive data** - Export old data to blob storage for long-term retention

## Resources

- **KQL Tutorial**: https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/
- **Workbooks Documentation**: https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview
- **Alert Rules**: https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview

For more dashboard examples and setup instructions:
```bash
cat docs/AZURE_SETUP.md
```
