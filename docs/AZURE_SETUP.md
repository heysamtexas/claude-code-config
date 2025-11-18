# Azure Infrastructure Setup Guide

This guide walks you through provisioning the Azure resources needed for Claude Code observability.

## Overview

You will create:

1. **Resource Group** - Container for all Claude Code observability resources
2. **Application Insights** - OpenTelemetry endpoint for metrics and logs
3. **Log Analytics Workspace** - Long-term storage and KQL queries
4. **Azure Key Vault** - Secure storage for connection strings (optional but recommended)
5. **Workbooks** - Pre-built dashboards for visualizations
6. **Alert Rules** - Automated notifications for thresholds

**Estimated Time**: 30-60 minutes
**Cost Estimate**: ~$50-200/month (depending on usage volume)

## Prerequisites

- Azure subscription with permissions to create resources
- Azure CLI installed (`az --version` to verify) or access to Azure Portal
- Contributor or Owner role on the subscription

## Option 1: Azure Portal (GUI)

### Step 1: Create Resource Group

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Click **Resource groups** > **+ Create**
3. Fill in details:
   - **Subscription**: Your subscription
   - **Resource group name**: `rg-claude-code-observability`
   - **Region**: Choose closest to your location (e.g., `East US`, `West Europe`)
4. Click **Review + create** > **Create**

### Step 2: Create Log Analytics Workspace

1. Search for **Log Analytics workspaces** in Azure Portal
2. Click **+ Create**
3. Fill in details:
   - **Subscription**: Your subscription
   - **Resource group**: `rg-claude-code-observability`
   - **Name**: `log-claude-code`
   - **Region**: Same as resource group
4. Click **Review + create** > **Create**
5. Once deployed, note the **Workspace ID** (under Properties)

### Step 3: Create Application Insights

1. Search for **Application Insights** in Azure Portal
2. Click **+ Create**
3. Fill in details:
   - **Subscription**: Your subscription
   - **Resource group**: `rg-claude-code-observability`
   - **Name**: `appi-claude-code`
   - **Region**: Same as resource group
   - **Workspace**: Select `log-claude-code` (created in Step 2)
4. Click **Review + create** > **Create**
5. Once deployed, go to the resource and copy:
   - **Connection String** (under Configure > Properties)
   - **Instrumentation Key** (under Configure > Properties)

### Step 4: Enable OpenTelemetry Ingestion

By default, Application Insights supports OpenTelemetry. No additional configuration needed, but verify:

1. Go to your Application Insights resource
2. Navigate to **Configure** > **API Access**
3. Confirm **OpenTelemetry** is listed under supported protocols

### Step 5: Configure Data Retention (Optional)

1. In Application Insights, go to **Configure** > **Usage and estimated costs**
2. Click **Data Retention**
3. Set retention period (90 days default, up to 730 days)
4. Click **Apply**

**Note**: Longer retention increases costs. Consider archiving to cheaper storage.

### Step 6: Create Azure Key Vault (Optional)

For secure credential storage:

1. Search for **Key Vaults** in Azure Portal
2. Click **+ Create**
3. Fill in details:
   - **Resource group**: `rg-claude-code-observability`
   - **Name**: `kv-claude-code` (must be globally unique)
   - **Region**: Same as resource group
4. Click **Review + create** > **Create**
5. Once deployed, add secrets:
   - Secret name: `AppInsightsConnectionString`
   - Value: [Your Application Insights connection string]

---

## Option 2: Azure CLI (Automated)

### Prerequisites

```bash
# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "Your Subscription Name"

# Verify
az account show
```

### Automated Deployment Script

```bash
#!/bin/bash
# Azure resources for Claude Code observability

# Configuration
RESOURCE_GROUP="rg-claude-code-observability"
LOCATION="eastus"  # Change to your preferred region
LOG_WORKSPACE="log-claude-code"
APP_INSIGHTS="appi-claude-code"
KEY_VAULT="kv-claude-code-$(date +%s)"  # Append timestamp for uniqueness

# Create Resource Group
echo "Creating resource group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Log Analytics Workspace
echo "Creating Log Analytics workspace..."
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_WORKSPACE \
  --location $LOCATION

# Get Workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_WORKSPACE \
  --query id -o tsv)

# Create Application Insights
echo "Creating Application Insights..."
az monitor app-insights component create \
  --app $APP_INSIGHTS \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --workspace $WORKSPACE_ID

# Get Connection String
CONNECTION_STRING=$(az monitor app-insights component show \
  --app $APP_INSIGHTS \
  --resource-group $RESOURCE_GROUP \
  --query connectionString -o tsv)

# Get Instrumentation Key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
  --app $APP_INSIGHTS \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey -o tsv)

# Create Key Vault (optional)
echo "Creating Key Vault..."
az keyvault create \
  --name $KEY_VAULT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --enable-rbac-authorization false

# Store connection string in Key Vault
az keyvault secret set \
  --vault-name $KEY_VAULT \
  --name "AppInsightsConnectionString" \
  --value "$CONNECTION_STRING"

# Output credentials
echo ""
echo "========================================="
echo "Azure Resources Created Successfully!"
echo "========================================="
echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "Application Insights: $APP_INSIGHTS"
echo "Log Analytics Workspace: $LOG_WORKSPACE"
echo "Key Vault: $KEY_VAULT"
echo ""
echo "Connection String:"
echo "$CONNECTION_STRING"
echo ""
echo "OTLP Endpoint:"
echo "https://${LOCATION}.in.applicationinsights.azure.com/v1/traces"
echo ""
echo "Save these values to your .env file!"
echo "========================================="
```

Save this as `scripts/provision-azure-resources.sh`, make it executable, and run:

```bash
chmod +x scripts/provision-azure-resources.sh
./scripts/provision-azure-resources.sh
```

---

## Step 7: Configure Access Control (RBAC)

Restrict who can view telemetry data:

### Portal Method

1. Go to Application Insights resource
2. Click **Access control (IAM)**
3. Click **+ Add** > **Add role assignment**
4. Assign roles:
   - **Monitoring Reader**: View metrics and logs (engineering managers)
   - **Monitoring Contributor**: Modify dashboards (DevOps team)
   - **Log Analytics Reader**: Query logs (security team)

### CLI Method

```bash
# Grant security team access to logs
az role assignment create \
  --assignee user@yourcompany.com \
  --role "Log Analytics Reader" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/rg-claude-code-observability/providers/Microsoft.Insights/components/appi-claude-code"

# Grant engineering managers metric access
az role assignment create \
  --assignee eng-managers@yourcompany.com \
  --role "Monitoring Reader" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/rg-claude-code-observability"
```

---

## Step 8: Create Dashboards (Workbooks)

### Quick Start Dashboard

1. Go to Application Insights > **Workbooks**
2. Click **+ New**
3. Add sections:

**Section 1: Usage Overview**
- Query type: Metrics
- Metric: `customMetrics/claude_code.session.count`
- Aggregation: Count
- Time range: Last 30 days

**Section 2: Cost Tracking**
- Query type: Metrics
- Metric: `customMetrics/claude_code.cost.usage`
- Aggregation: Sum
- Split by: `cloud.resource_id` (or custom dimension for team)

**Section 3: Error Rate**
- Query type: Logs
- Query:
```kql
traces
| where message contains "error" or severityLevel >= 3
| summarize ErrorCount = count() by bin(timestamp, 1h)
| render timechart
```

4. Click **Save** and name it "Claude Code - Executive Dashboard"

### Pre-built Workbook Templates

Coming soon: Downloadable workbook JSON templates for common dashboards.

---

## Step 9: Configure Alerts

### Budget Alert

1. Go to Application Insights > **Alerts** > **+ Create alert rule**
2. Condition:
   - Signal: `customMetrics/claude_code.cost.usage`
   - Aggregation: Sum
   - Threshold: $1000 (adjust to your budget)
   - Evaluation frequency: 1 hour
3. Action: Email or Slack notification
4. Save as "Claude Code - Monthly Budget Alert"

### Error Rate Alert

1. Condition:
   - Signal: `traces` where `severityLevel >= 3`
   - Aggregation: Count
   - Threshold: 100 errors in 15 minutes
2. Action: Email security team
3. Save as "Claude Code - High Error Rate"

---

## Cost Estimation

Based on typical usage:

| Resource | Monthly Cost (Estimate) |
|----------|------------------------|
| Application Insights (5 GB/month) | $10-25 |
| Log Analytics (10 GB/month) | $20-40 |
| Key Vault (1000 operations/month) | $0.50 |
| Data retention (90 days) | $5-15 |
| **Total** | **$35-80/month** |

**Scaling**: Costs increase with:
- Number of users
- Frequency of usage
- Retention period
- Custom alert complexity

Use the [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) for precise estimates.

---

## Verification

Test that everything is working:

### 1. Test OTLP Endpoint

```bash
curl -I https://eastus.in.applicationinsights.azure.com/v1/traces
# Expected: HTTP/1.1 405 Method Not Allowed (endpoint exists)
```

### 2. Send Test Telemetry

```bash
# Set environment variables
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_EXPORTER_OTLP_ENDPOINT="https://eastus.in.applicationinsights.azure.com/v1/traces"
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=YOUR_CONNECTION_STRING"
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp

# Run Claude Code
claude "print hello world"
```

### 3. Verify Data in Azure

Wait 2-5 minutes, then:

1. Go to Application Insights > **Transaction search**
2. Look for telemetry events
3. Check **Metrics** for custom metrics like `claude_code.session.count`

---

## Next Steps

1. ✅ Save credentials to `.env` file
2. ✅ Configure `.claude/settings.json` with Azure credentials
3. ✅ Test with validation script: `./scripts/validate-telemetry.sh`
4. ✅ Share setup instructions with team
5. ✅ Create team-specific dashboards
6. ✅ Set up alerts for budget and errors

---

## Troubleshooting

**Issue**: "Application Insights not receiving data"
- Verify connection string is correct
- Check OTLP endpoint URL format
- Enable `OTEL_DEBUG=1` for verbose logging
- Ensure firewall allows outbound HTTPS to Azure

**Issue**: "Key Vault access denied"
- Add your user to Key Vault access policies
- Grant "Get" permission for secrets
- Use Azure RBAC if "Enable RBAC authorization" is set

**Issue**: "High costs"
- Reduce log sampling rate
- Decrease retention period
- Archive old data to blob storage
- Set up budget alerts

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for more help.

---

## Resources

- [Azure Application Insights Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [OpenTelemetry in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/app/opentelemetry-enable)
- [KQL Query Language](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
