# Workspace and Primitive Architecture

## 1. Identity

- **What it is:** A Cargo workspace monorepo that groups the Commonware primitives, helper crates, examples, fuzz targets, and companion tooling.
- **Purpose:** Provide shared crate boundaries, shared dependency pins, and a consistent build contract for production-oriented distributed systems primitives.

## 2. Core Components

- `Cargo.toml:1-45` ([workspace], [workspace.package], [workspace.dependencies], [workspace.lints]): Defines workspace members, shared metadata, pinned internal dependencies, and workspace-wide lint policy.
- `README.md:11-55` (Primitives, Examples, Miscellaneous): Describes the high-level roles of the primitives, example applications, and companion tooling.
- `macros/Cargo.toml`, `macros/impl/Cargo.toml` (`commonware-macros`, `commonware-macros-impl`): Split public macro APIs from proc-macro implementation details.
- `conformance/Cargo.toml`, `conformance/macros/Cargo.toml` (`commonware-conformance`, `commonware-conformance-macros`): Split the conformance API from its macro generator.
- `runtime/Cargo.toml`, `consensus/Cargo.toml`: Show target-specific dependency blocks and crate-local composition on top of the workspace aliases.
- `examples/*/Cargo.toml`: Workspace example crates that compose the primitives into runnable systems.
- `*/fuzz/Cargo.toml`: Fuzz crates that exercise primitive APIs under cargo-fuzz.

## 3. Execution Flow (LLM Retrieval Map)

- **1. Workspace Definition:** The root manifest enumerates the members and shared dependency aliases in `Cargo.toml:1-109`.
- **2. Crate Composition:** Individual primitive manifests pull from workspace aliases and add target-specific dependencies as needed.
- **3. Integration Surfaces:** The README and example crates show how primitives are composed into applications and tooling (`README.md:31-55`, `examples/bridge/src/lib.rs:1-171`, `examples/chat/src/main.rs:1-201`).
- **4. Auxiliary Surfaces:** MCP and docs live beside the workspace rather than inside it, but they consume the same crate and version model (`mcp/package.json:1-33`, `docs/makefile:11-40`).

## 4. Design Rationale

The workspace keeps shared policy at the root so all crates inherit the same versioning, dependency, and lint contract. This reduces drift between primitives, examples, and fuzz targets.
