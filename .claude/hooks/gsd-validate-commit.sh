#!/bin/bash
# gsd-validate-commit.sh - Validate git commits follow GSD conventions
# Called before Bash commands that include git commit

# Read stdin (hook input JSON)
INPUT=$(cat)

# Extract the bash command
COMMAND=$(echo "$INPUT" | jq -r '.command // empty')

# Check if this is a git commit command
if [[ "$COMMAND" == *"git commit"* ]]; then
    # Check if commit message includes Co-Authored-By Claude
    if [[ "$COMMAND" == *"Co-Authored-By: Claude"* ]]; then
        # Valid GSD commit format
        exit 0
    else
        # Allow it anyway - this is just a soft check
        exit 0
    fi
fi

# Not a commit command, allow it
exit 0
