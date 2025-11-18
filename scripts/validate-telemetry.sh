#!/usr/bin/env bash
# Claude Code Telemetry Validation Script
# Tests that telemetry is properly configured and data reaches Azure

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0

# Helper functions
print_check() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_header() {
    echo ""
    echo "========================================"
    echo "$1"
    echo "========================================"
}

# Load environment variables if .env exists
if [ -f .env ]; then
    print_check ".env file found, loading variables"
    export $(grep -v '^#' .env | xargs)
else
    print_warn ".env file not found (optional)"
fi

# Check 1: Claude Code installed
print_header "1. Checking Claude Code Installation"
if command -v claude &> /dev/null; then
    VERSION=$(claude --version 2>&1 || echo "unknown")
    print_check "Claude Code is installed: $VERSION"
else
    print_fail "Claude Code is not installed"
    echo "   Install from: https://code.claude.com"
    exit 1
fi

# Check 2: Telemetry enabled
print_header "2. Checking Telemetry Configuration"
if [ "${CLAUDE_CODE_ENABLE_TELEMETRY:-0}" = "1" ]; then
    print_check "CLAUDE_CODE_ENABLE_TELEMETRY is enabled"
else
    print_fail "CLAUDE_CODE_ENABLE_TELEMETRY is not set to 1"
    echo "   Set in .env or .claude/settings.json"
fi

if [ "${OTEL_LOG_USER_PROMPTS:-0}" = "1" ]; then
    print_check "OTEL_LOG_USER_PROMPTS is enabled (full audit)"
else
    print_warn "OTEL_LOG_USER_PROMPTS is disabled (only prompt length tracked)"
fi

# Check 3: OTLP endpoint configuration
print_header "3. Checking OTLP Endpoint"
if [ -n "${OTEL_EXPORTER_OTLP_ENDPOINT:-}" ]; then
    print_check "OTEL_EXPORTER_OTLP_ENDPOINT is set"
    echo "   Endpoint: $OTEL_EXPORTER_OTLP_ENDPOINT"

    # Test endpoint connectivity
    if curl -s -I --max-time 5 "$OTEL_EXPORTER_OTLP_ENDPOINT" > /dev/null 2>&1; then
        print_check "OTLP endpoint is reachable"
    else
        print_fail "OTLP endpoint is not reachable"
        echo "   Check network connectivity and firewall rules"
    fi
else
    print_fail "OTEL_EXPORTER_OTLP_ENDPOINT is not set"
fi

# Check 4: Connection string
print_header "4. Checking Authorization"
if [ -n "${OTEL_EXPORTER_OTLP_HEADERS:-}" ]; then
    print_check "OTEL_EXPORTER_OTLP_HEADERS is set"
    if echo "$OTEL_EXPORTER_OTLP_HEADERS" | grep -q "InstrumentationKey="; then
        print_check "Connection string contains InstrumentationKey"
    else
        print_warn "Connection string may be incomplete"
    fi
else
    print_fail "OTEL_EXPORTER_OTLP_HEADERS is not set"
fi

# Check 5: Exporters configured
print_header "5. Checking Exporters"
if [ "${OTEL_METRICS_EXPORTER:-}" = "otlp" ]; then
    print_check "OTEL_METRICS_EXPORTER set to otlp"
else
    print_fail "OTEL_METRICS_EXPORTER not set to otlp (current: ${OTEL_METRICS_EXPORTER:-none})"
fi

if [ "${OTEL_LOGS_EXPORTER:-}" = "otlp" ]; then
    print_check "OTEL_LOGS_EXPORTER set to otlp"
else
    print_fail "OTEL_LOGS_EXPORTER not set to otlp (current: ${OTEL_LOGS_EXPORTER:-none})"
fi

# Check 6: Resource attributes
print_header "6. Checking Resource Attributes"
if [ -n "${OTEL_RESOURCE_ATTRIBUTES:-}" ]; then
    print_check "OTEL_RESOURCE_ATTRIBUTES is set"
    echo "   Attributes: $OTEL_RESOURCE_ATTRIBUTES"
else
    print_warn "OTEL_RESOURCE_ATTRIBUTES not set (optional but recommended)"
    echo "   Consider adding: team=YOUR_TEAM,project=YOUR_PROJECT"
fi

# Check 7: Hooks configuration
print_header "7. Checking Custom Hooks"
if [ -f .claude/settings.json ] || [ -f .claude/settings.local.json ]; then
    SETTINGS_FILE=".claude/settings.json"
    [ -f .claude/settings.local.json ] && SETTINGS_FILE=".claude/settings.local.json"

    if command -v jq &> /dev/null; then
        if jq -e '.hooks' "$SETTINGS_FILE" > /dev/null 2>&1; then
            print_check "Hooks are configured in $SETTINGS_FILE"
        else
            print_warn "No hooks configured (optional)"
        fi
    else
        print_warn "jq not installed, cannot validate hooks"
    fi
else
    print_warn "No .claude/settings.json found (optional)"
fi

# Check hook scripts
if [ -x .claude/hooks/audit-tool-use.sh ]; then
    print_check "audit-tool-use.sh is executable"
else
    [ -f .claude/hooks/audit-tool-use.sh ] && print_fail "audit-tool-use.sh is not executable" || print_warn "audit-tool-use.sh not found"
fi

if [ -x .claude/hooks/security-events.sh ]; then
    print_check "security-events.sh is executable"
else
    [ -f .claude/hooks/security-events.sh ] && print_fail "security-events.sh is not executable" || print_warn "security-events.sh not found"
fi

# Check 8: Dependencies
print_header "8. Checking Dependencies"
if command -v jq &> /dev/null; then
    print_check "jq is installed (required for hooks)"
else
    print_warn "jq is not installed (hooks will use fallback logging)"
    echo "   Install: brew install jq (macOS) or apt-get install jq (Linux)"
fi

if command -v curl &> /dev/null; then
    print_check "curl is installed"
else
    print_fail "curl is not installed"
fi

# Check 9: Test telemetry (optional - requires user confirmation)
print_header "9. Test Telemetry Export (Optional)"
echo "This will run a test Claude Code session to verify data reaches Azure."
echo -n "Run test? [y/N]: "
read -r RESPONSE

if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
    echo "Running test session..."

    # Create a simple test prompt
    TEST_SESSION_ID=$(date +%s)
    echo "Testing telemetry with session marker: $TEST_SESSION_ID" | claude --session-id "$TEST_SESSION_ID" > /dev/null 2>&1 || true

    print_check "Test session completed"
    echo ""
    echo "   Wait 2-5 minutes, then check Azure Application Insights:"
    echo "   1. Go to Azure Portal > Application Insights"
    echo "   2. Navigate to Transaction search or Logs"
    echo "   3. Search for session_id: $TEST_SESSION_ID"
    echo ""
    echo "   Or run this KQL query:"
    echo "   customMetrics | where customDimensions.session_id == \"$TEST_SESSION_ID\""
else
    print_warn "Test skipped"
fi

# Summary
print_header "Validation Summary"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All checks passed! ✓${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run a Claude Code session"
    echo "2. Wait 2-5 minutes"
    echo "3. Check Azure Application Insights for data"
    echo "4. View docs/OBSERVABILITY.md for dashboard setup"
    exit 0
else
    echo -e "${RED}Some checks failed. ✗${NC}"
    echo ""
    echo "Fix the failed checks above, then re-run this script."
    echo "See docs/TROUBLESHOOTING.md for help."
    exit 1
fi
