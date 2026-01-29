#!/bin/bash
# Test script for marketplace installation and plugin functionality

set -e

echo "================================"
echo "Marketplace Installation Test"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Validate marketplace structure
echo "Test 1: Validating marketplace structure..."
if claude plugin validate .; then
    echo -e "${GREEN}✓${NC} Marketplace validation passed"
else
    echo -e "${RED}✗${NC} Marketplace validation failed"
    exit 1
fi
echo ""

# Test 2: Check all plugin directories exist
echo "Test 2: Checking plugin directories..."
PLUGINS=("gilfoyle" "copywriter" "coverage-enforcer" "spyros" "sam-texas-commands" "sam-texas-devtools")
for plugin in "${PLUGINS[@]}"; do
    if [ -d "plugins/$plugin" ]; then
        echo -e "${GREEN}✓${NC} Found plugins/$plugin"
    else
        echo -e "${RED}✗${NC} Missing plugins/$plugin"
        exit 1
    fi
done
echo ""

# Test 3: Check each plugin has a manifest
echo "Test 3: Checking plugin manifests..."
for plugin in "${PLUGINS[@]}"; do
    if [ -f "plugins/$plugin/.claude-plugin/plugin.json" ]; then
        echo -e "${GREEN}✓${NC} Found manifest for $plugin"
        # Validate JSON syntax
        if jq empty "plugins/$plugin/.claude-plugin/plugin.json" 2>/dev/null; then
            echo -e "${GREEN}  ✓${NC} Valid JSON syntax"
        else
            echo -e "${RED}  ✗${NC} Invalid JSON syntax"
            exit 1
        fi
    else
        echo -e "${RED}✗${NC} Missing manifest for $plugin"
        exit 1
    fi
done
echo ""

# Test 4: Check required plugin components
echo "Test 4: Checking plugin components..."
# Gilfoyle should have agents
if [ -f "plugins/gilfoyle/agents/gilfoyle.md" ]; then
    echo -e "${GREEN}✓${NC} Gilfoyle has agent definition"
else
    echo -e "${YELLOW}⚠${NC} Gilfoyle missing agent definition"
fi

# Copywriter should have agents
if [ -f "plugins/copywriter/agents/copywriter.md" ]; then
    echo -e "${GREEN}✓${NC} Copywriter has agent definition"
else
    echo -e "${YELLOW}⚠${NC} Copywriter missing agent definition"
fi

# Commands plugin should have commands
if [ -d "plugins/sam-texas-commands/commands" ] && [ "$(ls -A plugins/sam-texas-commands/commands)" ]; then
    echo -e "${GREEN}✓${NC} sam-texas-commands has command definitions"
else
    echo -e "${YELLOW}⚠${NC} sam-texas-commands missing command definitions"
fi

echo ""
echo "================================"
echo -e "${GREEN}All tests passed!${NC}"
echo "================================"
echo ""
echo "To test installation:"
echo "1. Add marketplace: /plugin marketplace add heysamtexas/claude-code-config"
echo "2. Install a plugin: /plugin install gilfoyle@sam-texas-marketplace"
echo "3. Verify it works: Ask Claude to use Gilfoyle for code review"
echo ""
echo "For local testing:"
echo "1. Add locally: /plugin marketplace add $(pwd)"
echo "2. Install: /plugin install gilfoyle"
