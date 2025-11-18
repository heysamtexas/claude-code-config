#!/usr/bin/env bash
# Claude Code Hook: Security Events Detection
# Scans user prompts for security-sensitive operations and logs them
#
# This hook runs on UserPromptSubmit and checks for:
# - Production deployments
# - Secrets/credentials access
# - Database operations
# - Privileged operations
# - Sensitive file access

set -euo pipefail

# Configuration
SECURITY_LOG_DIR="${HOME}/.claude/security-logs"
SECURITY_LOG_FILE="${SECURITY_LOG_DIR}/security-events-$(date +%Y-%m).log"

# Create security log directory if it doesn't exist
mkdir -p "${SECURITY_LOG_DIR}"

# Read JSON input from Claude Code
INPUT=$(cat)

# Security-sensitive keywords to detect
SENSITIVE_PATTERNS=(
    "production"
    "prod"
    "deploy"
    "secret"
    "password"
    "credential"
    "api.?key"
    "token"
    "database"
    "db"
    "drop table"
    "delete from"
    "truncate"
    "rm -rf"
    "sudo"
    "chmod 777"
    ".env"
    "private.?key"
    "certificate"
    "ssl"
    "tls"
)

# Extract user prompt if available
if command -v jq &> /dev/null; then
    USER_PROMPT=$(echo "$INPUT" | jq -r '.user_prompt // ""')
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
    CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"')
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    USER=$(whoami)

    # Check if prompt contains any sensitive patterns
    MATCHED_PATTERNS=()
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        if echo "$USER_PROMPT" | grep -iEq "$pattern"; then
            MATCHED_PATTERNS+=("$pattern")
        fi
    done

    # If sensitive patterns detected, log security event
    if [ ${#MATCHED_PATTERNS[@]} -gt 0 ]; then
        PATTERNS_JSON=$(printf '%s\n' "${MATCHED_PATTERNS[@]}" | jq -R . | jq -s .)

        SECURITY_EVENT=$(jq -n \
            --arg timestamp "$TIMESTAMP" \
            --arg user "$USER" \
            --arg session_id "$SESSION_ID" \
            --arg cwd "$CWD" \
            --arg prompt "${USER_PROMPT:0:500}" \
            --argjson patterns "$PATTERNS_JSON" \
            '{
                timestamp: $timestamp,
                event_type: "sensitive_operation_detected",
                user: $user,
                session_id: $session_id,
                cwd: $cwd,
                prompt_excerpt: $prompt,
                matched_patterns: $patterns,
                severity: "medium"
            }')

        # Write to security log
        echo "$SECURITY_EVENT" >> "${SECURITY_LOG_FILE}"

        # Optional: Send to Azure Application Insights as custom event
        # Uncomment to enable real-time security event alerting
        # if [[ -n "${AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY:-}" ]]; then
        #     curl -s -X POST \
        #         "https://dc.services.visualstudio.com/v2/track" \
        #         -H "Content-Type: application/json" \
        #         -d "{
        #             \"name\": \"Microsoft.ApplicationInsights.Event\",
        #             \"time\": \"$TIMESTAMP\",
        #             \"iKey\": \"$AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY\",
        #             \"data\": {
        #                 \"baseType\": \"EventData\",
        #                 \"baseData\": {
        #                     \"name\": \"ClaudeCodeSecurityEvent\",
        #                     \"properties\": $(echo "$SECURITY_EVENT")
        #                 }
        #             }
        #         }" > /dev/null 2>&1 || true
        # fi
    fi
fi

# Always exit successfully to not block user workflow
# This is a monitoring hook, not an enforcement mechanism
exit 0
