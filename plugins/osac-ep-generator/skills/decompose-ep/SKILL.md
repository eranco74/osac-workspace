---
name: decompose-ep
description: |
  Decompose an approved OSAC enhancement proposal into a Jira epic with linked sub-tasks.
  Performs dependency mapping and complexity analysis as part of decomposition.
  Trigger when: "create tasks from this EP", "decompose this proposal", "ep to jira",
  "create a Jira epic from this enhancement", "break down this EP into tasks",
  or user has an approved EP and wants actionable Jira tickets.
---

# EP to Jira — Decompose Enhancement Proposals

Take an approved Enhancement Proposal and turn it into a Jira epic with
ordered sub-tasks, informed by dependency mapping and complexity analysis.

## Modes

- `/ep-to-jira <slug>` — decompose EP at `enhancement-proposals/enhancements/<slug>/`
- `/ep-to-jira <path/to/README.md>` — decompose EP from explicit path

## Workflow

### 1. Read the EP

Extract from `enhancement-proposals/enhancements/<slug>/README.md`:
- Frontmatter: title, tracking-link, authors
- Content: Summary, Proposal, API Extensions, Implementation Details, Test Plan, Risks

Present overview and confirm with user before proceeding.

### 2. Map Dependencies

Read `references/decomposition_guide.md` for the full checklist. For each proposed
resource or API change:

```bash
rg --type proto "<resource>" --files-with-matches      # proto impact
rg "reconcile.*<Resource>" --type go -l                 # controller impact
rg "import.*fulfillment.*v1" osac-operator/ --type go -l # cross-repo imports
```

Build a dependency table: repo, impact level, affected files, breaking changes.

### 3. Assess Complexity

Rate 5 dimensions from the dependency findings (LOW / MEDIUM / HIGH):

| Dimension | LOW | MEDIUM | HIGH |
|-----------|-----|--------|------|
| Repos touched | 1 | 2-3 | 4+ |
| API surface | None | Additive | Breaking |
| Data migration | None | New tables | Breaking schema |
| Cross-service | Independent | Consumes API | Coordinated release |
| Testing | Unit only | Integration | E2E across services |

**Overall = highest individual rating.** Present table to user.

### 4. Decompose into Tasks

Extract tasks by category, ordered for implementation:

1. **Proto/Schema** — one per new message or service
2. **Backend/Handler** — one per CRUD service or reconciler
3. **Integration** — one per cross-repo touchpoint
4. **Tests** — separate unit and integration tasks
5. **Documentation** — CLAUDE.md, README, API docs updates

Present task list. Wait for user confirmation before creating Jira tickets.

### 5. Create Jira Epic

```bash
jira epic create \
  --project MGMT \
  --name "<EP Title>" \
  --summary "Implement <EP Title> enhancement proposal" \
  --label OSAC \
  --no-input
```

Link to tracking ticket if one exists in EP frontmatter.

### 6. Create Sub-Tasks

For each confirmed task:

```bash
jira issue create \
  --project MGMT \
  --type Task \
  --parent "$EPIC_KEY" \
  --summary "<task summary>" \
  --body "<repo, files, acceptance criteria>" \
  --label OSAC \
  --no-input
```

### 7. Report

Present: epic key + URL, sub-task list, complexity assessment, dependency map,
and recommended task ordering.

## Prerequisites

| Tool | Check | Fix |
|------|-------|-----|
| jira | `jira me` | `jira init` |
| gh | `gh auth status` | `gh auth login` |
| rg | `rg --version` | install ripgrep |
| EP file | `ls enhancement-proposals/enhancements/<slug>/` | `./bootstrap.sh` |

## Reference Files

- `references/decomposition_guide.md` — task extraction strategies, complexity framework, dependency checklist
