---
phase: 02-planning-pipeline
plan: 01
subsystem: planning-pipeline
tags: [skill-development, ep-generation, knowledge-embedding]
dependency_graph:
  requires: []
  provides:
    - EP generation skill with embedded template knowledge
    - Reference files for EP template, review patterns, OSAC conventions
  affects: []
tech_stack:
  added:
    - SKILL.md format for Claude Code skill definition
  patterns:
    - Progressive disclosure with references/ directory
    - Embedded domain knowledge via reference files
    - Interactive clarification loop workflow
key_files:
  created:
    - plugins/osac-ep-generator/skills/generate-ep/SKILL.md
    - plugins/osac-ep-generator/skills/generate-ep/references/ep_template.md
    - plugins/osac-ep-generator/skills/generate-ep/references/review_patterns.md
    - plugins/osac-ep-generator/skills/generate-ep/references/osac_conventions.md
  modified: []
decisions:
  - Embedded full EP template content in references/ep_template.md with section completion guide
  - Created review_patterns.md based on analysis of existing OSAC EP PRs (networking, bare-metal, vmaas)
  - Used absolute paths in SKILL.md to avoid path resolution issues
  - 6-phase workflow: input detection, codebase exploration, interactive clarification (mandatory), drafting, semi-automatic PR submission, review feedback iteration
metrics:
  duration_minutes: 7
  tasks_completed: 2
  files_created: 4
  lines_added: 1274
  commits: 2
completed_date: 2026-04-23
---

# Phase 02 Plan 01: Core EP Generation Skill Summary

**One-liner:** Created OSAC EP generation skill with embedded template knowledge, interactive clarification workflow, and semi-automatic PR submission following D-01 through D-04, D-09 through D-12.

## What Was Built

A complete OSAC-specific skill for generating enhancement proposals from requirements or meeting notes. The skill acts as a "Senior Staff Engineer" by embedding deep knowledge of the OSAC EP template, review expectations, and conventions.

### Key Components

1. **SKILL.md** (341 lines): Main skill definition with 6-phase workflow
   - Phase 1: Input mode detection (conversational vs file-based, including Jira ticket fetching)
   - Phase 2: Targeted codebase exploration for the specific feature
   - Phase 3: **Interactive clarification loop (mandatory)** — agent stops and asks about unknowns before drafting
   - Phase 4: EP drafting with ALL template sections filled (substantive placeholders where details depend on implementation)
   - Phase 5: Semi-automatic PR submission with user confirmation
   - Phase 6: Review feedback iteration loop

2. **references/ep_template.md** (933 lines): Full enhancement_template.md content PLUS section completion guide
   - Embedded knowledge of template structure, required sections, YAML frontmatter
   - Section-by-section guidance based on analysis of 3 reference EPs (Networking: 818 lines, Bare Metal, VMaaS)
   - Eliminates runtime template discovery (per D-03)

3. **references/review_patterns.md** (186 lines): Common reviewer expectations and feedback themes
   - Patterns from analysis of merged OSAC EP PRs (#19, #27, #24, #21, #14)
   - Common pitfalls: vague non-goals, insufficient user stories, missing risk analysis
   - Review interaction patterns and iteration best practices

4. **references/osac_conventions.md** (226 lines): OSAC-specific conventions
   - Directory structure: `enhancement-proposals/enhancements/<feature-slug>/README.md`
   - PR format: `MGMT-XXXXX: Add <feature-name> enhancement proposal`
   - Jira integration: tracking-link format, ticket lifecycle
   - Reference library of 8 existing EPs with descriptions

## Decisions Implemented

| Decision | Implementation |
|----------|----------------|
| D-01: Agent accepts conversational and file-based input | Phase 1 auto-detects mode; Jira ticket fetching via `jira issue view` |
| D-02: Interactive clarification loop is thorough | Phase 3 is mandatory; agent stops and enumerates all unknowns before drafting |
| D-03: Skill embeds EP template knowledge | references/ep_template.md contains full template + section completion guide |
| D-04: Agent fills out full EP template | Phase 4 workflow requires ALL sections; substantive placeholders for deferred details |
| D-09: Semi-automatic PR creation with user confirmation | Phase 5 shows preview and asks "Push and create PR? (yes/no)" |
| D-10: EP directory structure follows existing pattern | Hardcoded path: `enhancements/<feature-slug>/README.md` |
| D-11: PR format matches OSAC convention | Title: `MGMT-XXXXX: Add <feature-name> enhancement proposal` |
| D-12: Review feedback loop included | Phase 6 fetches reviews via `gh pr view`, applies changes, commits, pushes |

## How It Works

### Typical Workflow

1. **User trigger**: "Draft an EP for the Storage Network API based on these meeting notes"
2. **Phase 1**: Agent reads meeting notes file, captures requirements
3. **Phase 2**: Agent explores `fulfillment-service/proto/` to find NetworkClass pattern, checks `enhancement-proposals/enhancements/` for related EPs
4. **Phase 3**: Agent stops and asks:
   - "Should StorageNetwork follow the NetworkClass pattern or is it always CSI-based?"
   - "Which personas are primary users: tenants, providers, or both?"
   - "Do you have a Jira tracking ticket? If so, what's the number?"
5. **User answers**: Provides clarifications
6. **Phase 4**: Agent reads `ep_template.md`, drafts full EP with all sections at `enhancement-proposals/enhancements/storage-network/README.md`
7. **Phase 5**: Agent creates branch, commits, shows PR preview, waits for user confirmation, then pushes and creates PR
8. **Phase 6** (later): When reviews arrive, agent fetches feedback via `gh pr view`, proposes changes, updates EP, commits, pushes

### Knowledge Embedding Strategy

The skill uses **progressive disclosure** to manage context:
- **SKILL.md**: Compact workflow instructions (341 lines)
- **references/**: Detailed reference material loaded as needed during execution
  - `ep_template.md`: Loaded in Phase 4 (drafting)
  - `review_patterns.md`: Loaded in Phase 6 (review iteration)
  - `osac_conventions.md`: Loaded in Phase 2 (codebase exploration)

This avoids re-discovering the EP template structure at runtime (D-03) while keeping the SKILL.md readable.

## Deviations from Plan

None — plan executed exactly as written. All must-haves and acceptance criteria met.

## Verification

### Self-Check: PASSED

**Files created (all exist):**
- ✓ plugins/osac-ep-generator/skills/generate-ep/SKILL.md (14866 bytes)
- ✓ plugins/osac-ep-generator/skills/generate-ep/references/ep_template.md (25702 bytes)
- ✓ plugins/osac-ep-generator/skills/generate-ep/references/review_patterns.md (7329 bytes)
- ✓ plugins/osac-ep-generator/skills/generate-ep/references/osac_conventions.md (8690 bytes)

**Commits exist:**
- ✓ 6a7ee97: feat(02-planning-pipeline): add EP generator reference files with embedded knowledge
- ✓ dbd3a36: feat(02-planning-pipeline): add EP generation SKILL.md with complete workflow

**Must-haves verified:**
- ✓ SKILL.md has YAML frontmatter with `name: generate-ep` and multiline `description`
- ✓ EP template knowledge embedded in references/ep_template.md (not discovered at runtime)
- ✓ Interactive clarification phase is mandatory (Phase 3 says "CRITICAL: This phase is mandatory. Do NOT skip to drafting.")
- ✓ Skill handles conversational and file-based input (Phase 1 detects mode)
- ✓ All EP template sections represented (Phase 4 lists all 13 sections from template)
- ✓ Semi-automatic PR flow with confirmation (Phase 5 asks "Push and create PR? (yes/no)")
- ✓ Review feedback loop enables reading PR comments and pushing updates (Phase 6)

**Artifacts meet minimum line requirements:**
- ✓ SKILL.md: 341 lines (min 150)
- ✓ ep_template.md: 933 lines (min 50)
- ✓ review_patterns.md: 186 lines (min 30)
- ✓ osac_conventions.md: 226 lines (min 20)

**Key links verified:**
- ✓ SKILL.md references `references/ep_template.md` (line: "Read `references/ep_template.md` for full template structure")
- ✓ SKILL.md references `references/review_patterns.md` (line: "Read `references/review_patterns.md` to anticipate reviewer expectations")
- ✓ SKILL.md references `references/osac_conventions.md` (line: "Read `references/osac_conventions.md` for repo layout")
- ✓ SKILL.md includes `gh pr create` command pattern (Phase 5)

## Known Issues

None identified. The skill is ready for local testing in osac-workspace.

## Next Steps

1. **Plan 02-02**: Create EP decomposition skill (Jira epic/sub-task creation with dependency mapping and complexity analysis)
2. **Plan 02-03**: Package skill for marketplace (manifest.json, README.md, schema validation)
3. **Plan 02-04**: Marketplace registration and integration checkpoint

## Performance Notes

- **Duration**: 7 minutes (450 seconds)
- **Tasks**: 2 tasks completed
- **Files**: 4 files created
- **Lines**: 1,274 lines added
- **Commits**: 2 commits (per-task atomic commits as required)

Execution was efficient — reference file creation involved copying enhancement_template.md verbatim plus adding section completion guide based on analysis of 3 reference EPs. No context overflow issues.

---

**PLAN-01 Addressed:** A developer can invoke this skill to generate a structured EP from requirements or meeting notes. ✓
