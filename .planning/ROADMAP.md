# Roadmap: OSAC Agentic SDLC

## Overview

This roadmap delivers an end-to-end agentic software development lifecycle for OSAC. It starts by closing out the foundational CLAUDE.md templates (already in review), then builds the planning pipeline (enhancement proposals, Jira integration, codebase analysis), the execution engine (parallelized agents with specialized skills and built-in verification), and finally the review layer (local pre-flight swarm with CLI enforcement, then remote CodeRabbit integration). Each phase delivers a complete, independently valuable capability.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation** - Standardize CLAUDE.md across all OSAC repos as the agent source of truth
- [ ] **Phase 2: Planning Pipeline** - Agents generate enhancement proposals, create Jira tasks, and analyze codebase impacts
- [ ] **Phase 3: Execution Engine** - Parallelized agents execute work with specialized skills and built-in verification
- [ ] **Phase 4: Local Review Gate** - Pre-flight review swarm with CLI enforcement blocks PRs that fail local checks
- [ ] **Phase 5: Remote Review Integration** - CodeRabbit configured per-repo with OSAC rules ingesting local findings

## Phase Details

### Phase 1: Foundation
**Goal**: Every OSAC repo has a standardized CLAUDE.md that agents can rely on as their source of truth for conventions, build commands, and skill references
**Depends on**: Nothing (first phase)
**Requirements**: EXEC-01
**Success Criteria** (what must be TRUE):
  1. Every OSAC component repo (fulfillment-service, osac-operator, osac-aap, osac-installer, osac-test-infra, docs) has a CLAUDE.md file checked in
  2. Each CLAUDE.md encodes that repo's build commands, test commands, and project conventions accurately
  3. A developer cloning any OSAC repo can point Claude Code at it and get correct build/test behavior without manual setup
**Plans**: TBD

### Phase 2: Planning Pipeline
**Goal**: Developers can go from high-level requirements or meeting notes to a structured enhancement proposal with linked Jira tasks, informed by automated codebase analysis
**Depends on**: Phase 1
**Requirements**: PLAN-01, PLAN-02, PLAN-03, PLAN-04
**Success Criteria** (what must be TRUE):
  1. Developer provides rough requirements or meeting notes and receives a structured enhancement proposal following the OSAC EP template
  2. Developer approves a proposal and a Jira epic with linked sub-tasks is created automatically under the correct project
  3. As part of decomposition, agent performs dependency mapping identifying impacted repos/modules and cross-repo breaking changes
  4. As part of decomposition, agent produces a complexity assessment rating architectural impact and flags high-risk areas
**Plans:** 4 plans

Plans:
- [x] 02-01-PLAN.md -- Core EP generation skill (SKILL.md + reference files with embedded template knowledge)
- [x] 02-02-PLAN.md -- EP decomposition skill (Jira epic/sub-task creation with dependency mapping and complexity analysis)
- [x] 02-03-PLAN.md -- Plugin packaging (manifest.json, README.md, marketplace schema validation)
- [x] 02-04-PLAN.md -- Marketplace registration and integration checkpoint (human verification)

### Phase 3: Execution Engine
**Goal**: Agents execute sub-tasks in parallel across git worktrees using domain-specialized skills, with verification built into the execution loop
**Depends on**: Phase 1
**Requirements**: EXEC-02, EXEC-03, EXEC-04, EXEC-05
**Success Criteria** (what must be TRUE):
  1. GSD workflow can spawn multiple agent instances working in separate git worktrees on independent sub-tasks simultaneously
  2. Specialized skills exist and are invocable for at least: Go controller debugging, networking domain, bare-metal provisioning, Ansible playbook development
  3. Agents generate tests (unit or integration) as part of executing a coding task, not as a separate step
  4. Agents enforce OSAC coding standards (proto linting, Go conventions, Ansible best practices) during execution and fail fast on violations
  5. Pre-flight testing runs automatically before an agent marks a task complete
  6. Team has evaluated workflow options (GSD, Speckit, etc.) and the chosen workflow is customized for OSAC's multi-repo environment
**Plans**: TBD

### Phase 4: Local Review Gate
**Goal**: A local review swarm catches security and performance issues before code leaves the developer's machine, enforced by a CLI gatekeeper
**Depends on**: Phase 3
**Requirements**: REVW-01, REVW-02, REVW-04
**Success Criteria** (what must be TRUE):
  1. Running the review swarm produces a report covering security vulnerabilities and performance concerns for the staged changes
  2. Specialized review skills for security scanning and performance analysis are invocable independently and produce actionable findings
  3. Running `gh pr create` is blocked by the CLI gatekeeper if mandatory local checks have not passed
  4. Developer can see exactly which checks failed and what needs to be fixed before re-attempting PR submission
**Plans**: TBD

### Phase 5: Remote Review Integration
**Goal**: CodeRabbit is configured per-repo with OSAC-specific review rules and ingests local pre-flight findings to avoid duplicate flagging
**Depends on**: Phase 4
**Requirements**: REVW-03
**Success Criteria** (what must be TRUE):
  1. Each OSAC repo has a CodeRabbit configuration file with repo-specific review rules (Go conventions for Go repos, Ansible conventions for AAP, proto rules for fulfillment-service)
  2. CodeRabbit reviews reference local pre-flight findings so it does not re-flag issues already caught and resolved locally
  3. A PR submitted through the gatekeeper receives a CodeRabbit review that applies OSAC-specific rules within the normal GitHub PR workflow
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5

| Phase | Plans Complete | Status | Completed |
|-------|---------------|--------|-----------|
| 1. Foundation | 0/0 | Not started | - |
| 2. Planning Pipeline | 0/4 | Planned | - |
| 3. Execution Engine | 0/0 | Not started | - |
| 4. Local Review Gate | 0/0 | Not started | - |
| 5. Remote Review Integration | 0/0 | Not started | - |
