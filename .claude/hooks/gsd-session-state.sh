#!/bin/bash
# gsd-session-state.sh - Track session state for GSD workflows
# Called by SessionStart hook

# Read stdin (hook input JSON)
INPUT=$(cat)

# Extract session ID
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# If session ID exists, write to temp file for other hooks to use
if [ -n "$SESSION_ID" ]; then
    echo "$SESSION_ID" > /tmp/current_claude_session.txt
fi

# No output - this hook runs silently
exit 0
