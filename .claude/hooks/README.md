# GSD Workflow Hooks

This directory contains hook scripts for the GSD (Get Stuff Done) workflow system.

## Installation

Hooks were installed from `~/.claude/hooks/` and `~/.claude/get-shit-done/`.

## Hook Files

### JavaScript Hooks (from global hooks)
- `gsd-check-update.js` - Checks for GSD workflow system updates
- `gsd-context-monitor.js` - Monitors context usage during operations
- `gsd-prompt-guard.js` - Validates prompts before Write/Edit operations
- `gsd-workflow-guard.js` - Guards workflow state transitions
- `gsd-statusline.js` - Generates status line display

### Bash Hooks (project-specific)
- `gsd-session-state.sh` - Tracks session state for GSD workflows
- `gsd-phase-boundary.sh` - Detects phase boundary crossings
- `gsd-validate-commit.sh` - Validates git commits follow GSD conventions

### Node.js Hooks (project-specific)
- `gsd-read-guard.js` - Validates reads before writes

## Hook Configuration

Hooks are configured in `.claude/settings.json`:

- **SessionStart**: Runs when Claude Code session starts
  - `gsd-check-update.js` - Check for updates
  - `gsd-session-state.sh` - Initialize session tracking

- **PostToolUse**: Runs after tool execution
  - `gsd-context-monitor.js` - Monitor context after Bash/Edit/Write/Agent/Task
  - `gsd-phase-boundary.sh` - Track phase changes after Write/Edit

- **PreToolUse**: Runs before tool execution
  - `gsd-prompt-guard.js` - Validate before Write/Edit
  - `gsd-read-guard.js` - Check reads before Write/Edit
  - `gsd-workflow-guard.js` - Validate workflow before Write/Edit
  - `gsd-validate-commit.sh` - Validate before git commit Bash commands

- **StatusLine**: Custom status line
  - `gsd-statusline.js` - Generate GSD status display

## Updating Hooks

To update hooks from the global installation:

```bash
# Copy updated JavaScript hooks
cp -v ~/.claude/hooks/*.js .claude/hooks/

# Make executable
chmod +x .claude/hooks/*.sh .claude/hooks/*.js
```

## Troubleshooting

If you see hook errors:
1. Check that all scripts are executable: `ls -la .claude/hooks/`
2. Verify Node.js is available: `which node`
3. Check for jq (required by bash hooks): `which jq`
4. Review hook logs in Claude Code output
