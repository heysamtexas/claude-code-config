#!/usr/bin/env bash
# Claude Code Hook: Audit Tool Use
# Logs git operations and other critical tool usage for audit trail
#
# This hook receives JSON via stdin from Claude Code containing:
# - session_id, user info, timestamp
# - tool name, inputs, outputs
# - working directory, git branch
#
# The script extracts relevant audit information and can send it to:
# - Local log file (for development)
# - Azure Application Insights (for production)
# - Custom audit system

set -euo pipefail

# Configuration
AUDIT_LOG_DIR="${HOME}/.claude/audit-logs"
AUDIT_LOG_FILE="${AUDIT_LOG_DIR}/tool-usage-$(date +%Y-%m).log"

# Create audit log directory if it doesn't exist
mkdir -p "${AUDIT_LOG_DIR}"

# Read JSON input from Claude Code
INPUT=$(cat)

# Extract key fields using jq (if available) or fallback to basic logging
if command -v jq &> /dev/null; then
    # Parse JSON with jq
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"')
    USER=$(whoami)

    # Extract tool-specific details
    TOOL_INPUT=$(echo "$INPUT" | jq -c '.input // {}')
    TOOL_OUTPUT=$(echo "$INPUT" | jq -c '.output // {}' | head -c 500)  # Truncate long outputs

    # Create audit log entry
    AUDIT_ENTRY=$(jq -n \
        --arg timestamp "$TIMESTAMP" \
        --arg user "$USER" \
        --arg session_id "$SESSION_ID" \
        --arg tool "$TOOL_NAME" \
        --arg cwd "$CWD" \
        --argjson input "$TOOL_INPUT" \
        --arg output "$TOOL_OUTPUT" \
        '{
            timestamp: $timestamp,
            user: $user,
            session_id: $session_id,
            tool: $tool,
            cwd: $cwd,
            input: $input,
            output: $output
        }')

    # Write to local audit log
    echo "$AUDIT_ENTRY" >> "${AUDIT_LOG_FILE}"

    # Optional: Send to Azure Application Insights Custom Events API
    # Uncomment and configure if you want real-time audit event ingestion
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
    #                     \"name\": \"ClaudeCodeToolUse\",
    #                     \"properties\": $(echo "$AUDIT_ENTRY")
    #                 }
    #             }
    #         }" > /dev/null 2>&1 || true
    # fi

else
    # Fallback: Simple logging without jq
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[${TIMESTAMP}] $(whoami) - Tool executed - Raw data: ${INPUT}" >> "${AUDIT_LOG_FILE}"
fi

# Always exit successfully to not block Claude Code workflow
exit 0
