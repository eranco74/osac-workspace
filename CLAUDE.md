# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this workspace.

## How to Use This File

This is a **workspace-level** CLAUDE.md for cross-component guidance. Each component repository has its own CLAUDE.md:

- **This file**: Cross-component architecture, multi-repo workflows, workspace-level conventions
- **Component CLAUDE.md files**: Component-specific build commands, testing, patterns, conventions

**When working on a component**: Always read that component's CLAUDE.md file first (e.g., `fulfillment-service/CLAUDE.md`, `osac-operator/CLAUDE.md`).

**When working across components**: Use this file for architecture context and cross-repo coordination patterns.

## Project Context

Primary languages: Go, YAML, Python, Markdown. Primary tools: kubectl, jira CLI, gh CLI, gws CLI. When debugging Kubernetes operators, check for stale vendor directories and cached images before rebuilding.

## Project Overview

OSAC (OpenShift-as-a-Service-in-a-Container) is a fulfillment system for provisioning Kubernetes clusters and compute instances with networking capabilities. The project consists of multiple components that work together to provide a complete infrastructure management platform.

### Repository Structure

This is a **meta-workspace** that uses `bootstrap.sh` to clone all OSAC component repositories as independent Git repos:

- **fulfillment-service**: gRPC server implementation with REST gateway, PostgreSQL backend, and integrated API definitions
- **osac-operator**: Kubernetes operator for deploying OpenShift clusters via Hosted Control Planes
- **osac-aap**: Ansible Automation Platform roles and playbooks for network provisioning
- **osac-installer**: Installation manifests and prerequisites
- **osac-test-infra**: Integration testing infrastructure
- **enhancement-proposals**: Design documents and enhancement proposals
- **docs**: Architecture documentation, diagrams, and design guides (see `docs/architecture/` for system design)

**Getting the repos**: Run `./bootstrap.sh` from the workspace root to clone or update all repos to latest `main`.

Note: `fulfillment-api` and `fulfillment-common` were merged into `fulfillment-service`.

### Working with Component Repositories

**IMPORTANT**: Each component repo is an independent Git repository with its own CLAUDE.md file containing component-specific instructions. When working on a specific component:

1. **Check component CLAUDE.md first**: Before making changes in any component repo (e.g., `fulfillment-service/`, `osac-operator/`), read that repo's `CLAUDE.md` file for component-specific build commands, conventions, and patterns.

2. **Use Git worktrees for feature work**: When implementing features that span multiple commits, use git worktrees to isolate the work:
   ```bash
   cd fulfillment-service
   git worktree add ../fulfillment-service-feature-branch feature-branch
   cd ../fulfillment-service-feature-branch
   # Work here, then remove worktree when done
   ```

3. **Cross-component changes**: When a feature requires changes across multiple repos (e.g., API changes in `fulfillment-service` + operator changes in `osac-operator`):
   - Read both component CLAUDE.md files
   - Create feature branches in each affected repo
   - Use git worktrees if the changes require multiple commits
   - Coordinate PRs (mention related PRs in descriptions)

4. **Navigation pattern**:
   ```bash
   # From workspace root
   cd fulfillment-service      # Enter component repo
   cat CLAUDE.md               # Read component instructions
   # Make changes following component-specific guidance
   ```

5. **Component-specific context**: This workspace CLAUDE.md provides **cross-component** context (architecture, multi-repo workflows). Component CLAUDE.md files provide **component-specific** context (build commands, testing, conventions).

### Architecture Documentation

For system architecture, design patterns, and component interactions, refer to:
- `docs/architecture/` - High-level architecture diagrams and design documents
- `docs/getting-started/` - Setup guides and tutorials
- `enhancement-proposals/` - Detailed enhancement proposals and RFCs

When explaining architectural decisions or designing new features, check these directories first.

### Current Project State

The project recently completed v1.0 of the OSAC Networking API (see `.planning/PROJECT.md`), which provides:
- VirtualNetwork, Subnet, SecurityGroup, and NetworkClass resources
- Full gRPC and REST/JSON API surface
- OpenAPI v2/v3 specifications
- Protocol Buffer schemas for all networking primitives

## Development Commands

### fulfillment-service (Go backend with integrated API)

```bash
cd fulfillment-service

# Build the binary
go build

# Run unit tests (excludes integration tests in it/)
ginkgo run -r internal

# Run integration tests (requires kind)
ginkgo run it

# Run integration tests with specific deployment mode
IT_DEPLOY_MODE=kustomize ginkgo run it

# Preserve kind cluster after integration tests (for debugging)
IT_KEEP_KIND=true ginkgo run it

# Run only setup phase (creates cluster without running tests)
IT_KEEP_KIND=true ginkgo run --label-filter setup it
```

**Running the service locally:**

```bash
# Start PostgreSQL in a container
podman run -d --name postgresql_database \
  -e POSTGRESQL_USER=user -e POSTGRESQL_PASSWORD=pass -e POSTGRESQL_DATABASE=db \
  -p 127.0.0.1:5432:5432 quay.io/sclorg/postgresql-15-c9s:latest

# Start gRPC server
./fulfillment-service start grpc-server \
  --log-level=debug \
  --grpc-listener-address=localhost:8000 \
  --db-url=postgres://user:pass@localhost:5432/db

# Start REST gateway (in another terminal)
./fulfillment-service start rest-gateway \
  --log-level=debug \
  --http-listener-address=localhost:8001 \
  --grpc-server-address=localhost:8000 \
  --grpc-server-plaintext
```

**Testing the API:**

```bash
# Test gRPC with grpcurl
grpcurl -plaintext localhost:8000 list
grpcurl -plaintext localhost:8000 fulfillment.v1.VirtualNetworks/List

# Test REST with curl
curl http://localhost:8001/api/fulfillment/v1/virtual_networks | jq
```

### osac-operator (Kubernetes operator)

```bash
cd osac-operator

# Build and push container image
make image-build image-push IMG=<registry>/osac-operator:tag

# Install CRDs
make install

# Deploy operator
make deploy IMG=<registry>/osac-operator:tag

# Uninstall
make uninstall

# Undeploy operator
make undeploy
```

## Architecture Patterns

### API Design Pattern (Protocol Buffers)

The fulfillment-service follows a consistent pattern:

```
fulfillment-service/proto/public/osac/public/v1/    # Public API
fulfillment-service/proto/private/osac/private/v1/  # Private API
Each resource has:
├── <resource>_type.proto         # Resource schema definition
└── <resource>s_service.proto     # CRUD service operations
```

**Type files** define:
- Resource message with metadata (id, name, labels, annotations)
- Status enum (Pending, Ready, Failed)
- Spec fields (resource-specific configuration)
- Status fields (observed state)

**Service files** define:
- Create/Get/List/Update/Delete RPC methods
- Request/Response messages for each operation
- HTTP annotations for REST gateway (google.api.http)
- OpenAPI annotations for documentation

### Public vs Private API Split

Some resources (e.g., NetworkClass, HostClass) exist in both APIs:

- **Public API** (`fulfillment-service/proto/public/osac/public/v1/`): User-facing, read-only operations
  - Get and List methods available
  - Create/Update/Delete marked as "system-only"

- **Private API** (`fulfillment-service/proto/private/osac/private/v1/`): Admin/controller operations
  - Full CRUD operations
  - Additional Signal RPC for controller reconciliation (no HTTP endpoint)
  - Schema duplicated (follows HostClass pattern)

### Multi-tenancy

All resources include tenant isolation metadata:
- `metadata.annotations["osac.io/tenant-id"]` for tenant scoping
- `metadata.annotations["osac.io/owner-reference"]` for resource hierarchy
- OPA (Open Policy Agent) policies enforce isolation at runtime

### Resource Hierarchy

Parent-child relationships use owner references:
```
VirtualNetwork (parent)
├── Subnet (child, references VirtualNetwork via annotations)
└── SecurityGroup (child, references VirtualNetwork via annotations)
```

### Service Implementation Pattern

The fulfillment-service uses:
- PostgreSQL for persistent storage
- gRPC with grpc-gateway for REST/JSON support
- Controller-runtime for Kubernetes integration
- OPA for authorization policies
- Prometheus for metrics

### Integration Testing

Integration tests use:
- Kind clusters (named "fulfillment-service-it")
- TLS with SNI routing via Envoy Gateway
- Keycloak for authentication
- Requires `/etc/hosts` entries for:
  - `127.0.0.1 keycloak.keycloak.svc.cluster.local`
  - `127.0.0.1 fulfillment-api.innabox.svc.cluster.local`

## Protocol Buffer Conventions

### Naming Conventions

- **Files**: `snake_case` (e.g., `virtual_network_type.proto`)
- **Messages**: `PascalCase` (e.g., `VirtualNetwork`)
- **Fields**: `snake_case` (e.g., `ipv4_cidr`)
- **Enums**: `SCREAMING_SNAKE_CASE` (e.g., `STATE_PENDING`)
- **Services**: `PascalCase` (e.g., `VirtualNetworks`)
- **RPCs**: `PascalCase` (e.g., `CreateVirtualNetwork`)

### Field Validation

Use buf.build validation annotations:
- CIDR validation: Use `string` type with validation comments
- Enums: Define explicit values (tcp, udp, icmp, all)
- Required fields: Mark as non-optional in comments
- References: Use `string` fields for resource IDs

### Optional vs Required Fields

- Use `optional` keyword for fields that may not be set (e.g., IPv6 CIDR in dual-stack configs)
- Omit `optional` for fields that should always have values (even if empty string/0)
- Optional CIDR fields enable IPv4-only, IPv6-only, and dual-stack modes

### Update Operations

Use `google.protobuf.FieldMask` for partial updates:
```protobuf
message UpdateVirtualNetworkRequest {
  VirtualNetwork virtual_network = 1;
  google.protobuf.FieldMask update_mask = 2;
}
```

### List Operations

Include SQL-like filtering:
```protobuf
message ListVirtualNetworksRequest {
  int32 page = 1;
  int32 size = 2;
  string filter = 3;  // SQL WHERE clause syntax
  string order = 4;   // SQL ORDER BY syntax
}
```

## OpenAPI Generation Pipeline

The fulfillment-service includes proto files and OpenAPI generation:

```bash
cd fulfillment-service

# Validate proto files with buf lint
buf lint

# Generate Go code from protos
buf generate
```

OpenAPI specs are located at:
- `fulfillment-service/openapi/v2/openapi.json`
- `fulfillment-service/openapi/v3/openapi.yaml`

## Git Workflow Best Practices

### When to Use Git Worktrees

**Use worktrees for**:
- Feature branches requiring multiple commits
- Long-running development that needs isolation from main
- Parallel work on different features in the same repo
- PR development where you want to keep main clean

**Example**:
```bash
cd fulfillment-service
git worktree add ../fulfillment-service-add-network-api feature/add-network-api
cd ../fulfillment-service-add-network-api
# Make commits here, push when ready
git worktree remove ../fulfillment-service-add-network-api  # Clean up when PR is merged
```

**Work directly on main for**:
- Quick fixes (1-2 commits)
- Documentation updates
- Exploration and investigation
- Running tests without committing

### Cross-Repo Feature Development

When a feature spans multiple repos (e.g., API change + operator update):

1. **Plan the dependency order**: Which repo change must land first?
2. **Create branches in each repo**: Use consistent branch names (e.g., `feature/add-storage-api`)
3. **Use worktrees if needed**: Isolate multi-commit work in each repo
4. **Link PRs**: Mention related PRs in descriptions (e.g., "Depends on osac-project/fulfillment-service#123")
5. **Merge order**: Merge foundation changes first, then dependent changes

**Example**:
```bash
# Scenario: Add storage API (requires changes in fulfillment-service and osac-operator)

# Step 1: Create API in fulfillment-service
cd fulfillment-service
git worktree add ../fulfillment-service-storage feature/add-storage-api
cd ../fulfillment-service-storage
# Implement API, commit, push, create PR

# Step 2: Update operator to use new API
cd ../../osac-operator
git worktree add ../osac-operator-storage feature/add-storage-api
cd ../osac-operator-storage
# Implement operator changes, commit, push, create PR with note "Depends on fulfillment-service#X"
```

## GSD Workflow Integration

This project uses the GSD (Get Stuff Done) workflow system:

- **Planning**: `.planning/PROJECT.md` tracks project state, milestones, and requirements
- **Phases**: `.planning/phases/<phase-number>-<name>/` contains phase plans and summaries
- **Verification**: Each phase has a VERIFICATION.md documenting completion
- **State**: `.planning/STATE.md` tracks performance metrics and trends

When working on this project:
- Check `.planning/PROJECT.md` for current milestone and requirements
- Use `/gsd:progress` to check project status
- Use `/gsd:plan-phase` when planning new work
- Use `/gsd:execute-phase` to implement planned phases
- GSD workflows operate at the workspace level but can coordinate work across component repos

## Key Technologies

- **Protocol Buffers**: API definition language (proto3 syntax)
- **gRPC**: RPC framework for service-to-service communication
- **grpc-gateway**: HTTP/JSON to gRPC transcoding
- **Buf**: Proto linting and code generation
- **PostgreSQL**: Persistent storage for fulfillment-service
- **Kubernetes**: Deployment platform (OpenShift required for operator)
- **Ginkgo**: BDD testing framework for Go
- **gomock**: Mock generation for unit tests
- **Kind**: Kubernetes-in-Docker for integration tests
- **OPA**: Open Policy Agent for authorization

## Common Pitfalls

### Proto File Changes

- Always run `buf lint` before committing proto changes
- Regenerate code with `buf generate` after proto changes
- Ensure `SERVICE_SUFFIX` lint rule is excluded in buf.yaml

### Integration Tests

- Integration tests require `/etc/hosts` entries (see Architecture Patterns section)
- Use `IT_KEEP_KIND=true` to preserve cluster for debugging
- Clean up preserved clusters with: `kind delete cluster --name fulfillment-service-it`
- Default deployment mode is Helm, use `IT_DEPLOY_MODE=kustomize` to switch

### OpenAPI Generation

- OpenAPI specs are generated from proto files via buf generate
- Both v2 (JSON) and v3 (YAML) specs are generated and committed

### Multi-tenant Resources

- Never skip tenant isolation metadata in new resources
- Use annotations for owner references, not separate fields
- Test with different tenant IDs to verify isolation
- OPA policies are enforced at runtime, not at schema level


## Development Environment Setup

The recommended setup uses `direnv` to manage environment variables:

```bash
# Create project directory
mkdir ~/osac-project
cd ~/osac-project

# Create .envrc
cat > .envrc << 'EOF'
# Configure Go:
export GOROOT="${HOME}/go"
export GOPATH="${PWD}/.local"
export GOBIN="${PWD}/.local/bin"
PATH_add "${GOROOT}/bin"
PATH_add "${PWD}/.local/bin"
EOF

# Allow direnv
direnv allow

# Clone repository
git clone <repo-url> repository
cd repository
```

## Testing Against OpenShift Cluster

When deploying to OpenShift:

```bash
# Enable HTTP/2 for gRPC
kubectl annotate ingresses.config/cluster ingress.operator.openshift.io/default-enable-http2=true

# Deploy with kustomize
kubectl apply -k fulfillment-service/manifests

# Get service account token
export token=$(kubectl create token -n innabox client)

# Get route host
export route=$(kubectl get route -n innabox fulfillment-api -o json | jq -r '.spec.host')

# Test gRPC
grpcurl -insecure -H "Authorization: Bearer ${token}" \
  ${route}:443 fulfillment.v1.VirtualNetworks/List

# Test REST
curl --silent --insecure --header "Authorization: Bearer ${token}" \
  https://${route}:443/api/fulfillment/v1/virtual_networks | jq
```

## Git & PR Workflow

When creating PRs, always target the `origin` remote unless explicitly told otherwise. Never push to a fork remote by default.
