#!/bin/bash
# gsd-phase-boundary.sh - Detect phase boundary crossings
# Called after Write/Edit operations to detect when work crosses phase boundaries

# Read stdin (hook input JSON with file paths)
INPUT=$(cat)

# Extract file path from the write/edit operation
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // empty')

# Check if we're working in .planning directory (phase work)
if [[ "$FILE_PATH" == *".planning/phases/"* ]]; then
    # Extract phase number from path (e.g., .planning/phases/01-name/...)
    PHASE_DIR=$(echo "$FILE_PATH" | grep -oP '\.planning/phases/\K[^/]+')

    if [ -n "$PHASE_DIR" ]; then
        # Write current phase to temp file for context monitoring
        echo "$PHASE_DIR" > /tmp/current_gsd_phase.txt
    fi
fi

# No output - this hook runs silently
exit 0
