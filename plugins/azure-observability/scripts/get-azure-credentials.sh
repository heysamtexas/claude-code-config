#!/usr/bin/env bash
# Helper script to retrieve Azure Application Insights credentials
# Requires Azure CLI (az) to be installed and authenticated

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Azure CLI is not installed."
    echo ""
    echo "Install from:"
    echo "  macOS: brew install azure-cli"
    echo "  Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    echo "  Windows: https://aka.ms/installazurecliwindows"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    echo "Not logged into Azure. Running 'az login'..."
    az login
fi

print_success "Logged into Azure"

# Get current subscription
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
print_info "Using subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
echo ""

# List available resource groups
echo "Available resource groups:"
az group list --query "[].{Name:name, Location:location}" -o table
echo ""

# Prompt for resource group
echo -n "Enter resource group name (or press Enter for 'rg-claude-code-observability'): "
read -r RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-rg-claude-code-observability}

# Check if resource group exists
if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo ""
    echo "Resource group '$RESOURCE_GROUP' does not exist."
    echo ""
    echo "Would you like to create it now? [y/N]: "
    read -r CREATE_RG

    if [[ "$CREATE_RG" =~ ^[Yy]$ ]]; then
        echo -n "Enter Azure region (e.g., eastus, westeurope): "
        read -r LOCATION
        LOCATION=${LOCATION:-eastus}

        az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
        print_success "Resource group created"
    else
        echo "Cannot proceed without a resource group. Exiting."
        exit 1
    fi
fi

# List Application Insights in the resource group
print_header "Application Insights Resources"
APP_INSIGHTS_LIST=$(az monitor app-insights component list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{Name:name, Location:location}" -o tsv)

if [ -z "$APP_INSIGHTS_LIST" ]; then
    echo "No Application Insights resources found in '$RESOURCE_GROUP'."
    echo ""
    echo "See docs/AZURE_SETUP.md for instructions on creating Application Insights."
    echo "Or run the automated setup script: scripts/provision-azure-resources.sh"
    exit 1
fi

echo "$APP_INSIGHTS_LIST"
echo ""

# Prompt for App Insights name
echo -n "Enter Application Insights name (or press Enter for 'appi-claude-code'): "
read -r APP_INSIGHTS
APP_INSIGHTS=${APP_INSIGHTS:-appi-claude-code}

# Check if exists
if ! az monitor app-insights component show \
    --app "$APP_INSIGHTS" \
    --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo ""
    echo "Application Insights '$APP_INSIGHTS' not found."
    echo "Available resources:"
    az monitor app-insights component list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" -o tsv
    exit 1
fi

# Retrieve credentials
print_header "Retrieving Credentials"

CONNECTION_STRING=$(az monitor app-insights component show \
    --app "$APP_INSIGHTS" \
    --resource-group "$RESOURCE_GROUP" \
    --query connectionString -o tsv)

INSTRUMENTATION_KEY=$(az monitor app-insights component show \
    --app "$APP_INSIGHTS" \
    --resource-group "$RESOURCE_GROUP" \
    --query instrumentationKey -o tsv)

LOCATION=$(az monitor app-insights component show \
    --app "$APP_INSIGHTS" \
    --resource-group "$RESOURCE_GROUP" \
    --query location -o tsv)

# Map Azure location to OTLP region subdomain
# Azure location names (e.g., "eastus") map to OTLP subdomains (e.g., "eastus")
OTLP_REGION="$LOCATION"

print_success "Credentials retrieved"

# Display credentials
print_header "Azure Application Insights Credentials"

echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "App Insights: $APP_INSIGHTS"
echo "Location: $LOCATION"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Connection String:"
echo "$CONNECTION_STRING"
echo ""
echo "Instrumentation Key:"
echo "$INSTRUMENTATION_KEY"
echo ""
echo "OTLP Endpoint:"
echo "https://${OTLP_REGION}.in.applicationinsights.azure.com/v1/traces"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Offer to save to .env
if [ -f .env ]; then
    echo ".env file already exists."
    echo -n "Overwrite with these credentials? [y/N]: "
    read -r OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "Credentials NOT saved. Copy manually from above."
        exit 0
    fi
fi

echo -n "Save to .env file? [Y/n]: "
read -r SAVE_ENV
SAVE_ENV=${SAVE_ENV:-Y}

if [[ "$SAVE_ENV" =~ ^[Yy]$ ]]; then
    cat > .env <<EOF
# Azure Application Insights Configuration
# Generated: $(date)

# Azure Application Insights OTLP endpoint
AZURE_OTLP_ENDPOINT=https://${OTLP_REGION}.in.applicationinsights.azure.com/v1/traces

# Application Insights Connection String
AZURE_APP_INSIGHTS_CONNECTION_STRING=$CONNECTION_STRING

# Instrumentation Key (for reference)
AZURE_INSTRUMENTATION_KEY=$INSTRUMENTATION_KEY

# Team and Project Identification
TEAM_NAME=your-team-name
PROJECT_NAME=your-project-name

# Environment
ENVIRONMENT=production

# Export intervals (milliseconds)
OTEL_METRIC_EXPORT_INTERVAL_MILLIS=60000
OTEL_LOG_EXPORT_INTERVAL_MILLIS=5000
EOF

    print_success "Credentials saved to .env"
    echo ""
    echo "Next steps:"
    echo "1. Edit .env and set TEAM_NAME and PROJECT_NAME"
    echo "2. Copy .claude/settings.example.json to .claude/settings.json"
    echo "3. Replace placeholders in settings.json with values from .env"
    echo "4. Run: ./scripts/validate-telemetry.sh"
else
    echo "Credentials NOT saved. Copy manually from above."
fi

# Offer to create settings.json
if [ ! -f .claude/settings.json ]; then
    echo ""
    echo -n "Create .claude/settings.json with these credentials? [Y/n]: "
    read -r CREATE_SETTINGS
    CREATE_SETTINGS=${CREATE_SETTINGS:-Y}

    if [[ "$CREATE_SETTINGS" =~ ^[Yy]$ ]]; then
        mkdir -p .claude

        cat > .claude/settings.json <<EOF
{
  "\$schema": "https://cdn.jsdelivr.net/gh/anthropics/claude-code@main/schema/settings.schema.json",
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_LOG_USER_PROMPTS": "1",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "https://${OTLP_REGION}.in.applicationinsights.azure.com/v1/traces",
    "OTEL_EXPORTER_OTLP_HEADERS": "Authorization=${CONNECTION_STRING}",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_METRIC_EXPORT_INTERVAL_MILLIS": "60000",
    "OTEL_LOG_EXPORT_INTERVAL_MILLIS": "5000",
    "OTEL_RESOURCE_ATTRIBUTES": "team=YOUR_TEAM_NAME,project=YOUR_PROJECT_NAME,env=production"
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash(git push:*)",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/audit-tool-use.sh",
            "description": "Log git push operations for audit trail"
          }
        ]
      }
    ]
  }
}
EOF

        print_success ".claude/settings.json created"
        echo ""
        echo "⚠️  Remember to update OTEL_RESOURCE_ATTRIBUTES with your team/project name"
    fi
fi

echo ""
print_header "Setup Complete!"
echo ""
echo "Run validation: ./scripts/validate-telemetry.sh"
echo "Read docs: docs/OBSERVABILITY.md"
