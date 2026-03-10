# Commonware Library

## 1. Identity
- **What it is:** A Rust workspace monorepo for the Commonware Library, plus companion tooling and documentation surfaces.
- **Purpose:** Provide production-oriented distributed systems primitives, example applications, and supporting infrastructure for adversarial environments.

## 2. High-Level Description
The repository centers on a Cargo workspace that groups the core primitives (`broadcast`, `codec`, `coding`, `collector`, `conformance`, `consensus`, `cryptography`, `deployer`, `math`, `p2p`, `parallel`, `resolver`, `runtime`, `storage`, `stream`), helper crates, fuzz targets, and example applications (`Cargo.toml:1-45`, `README.md:11-55`). Workspace-level versioning, edition, lint policy, dependency pins, and profile settings are defined at the root so the member crates share one build and quality contract (`Cargo.toml:47-196`). The README frames the primitives as adversarial-environment building blocks and marks examples as ALPHA-stability reference applications rather than production APIs (`README.md:13-29`, `README.md:57-79`).

The workspace also includes non-Rust companion surfaces: `mcp/` is a separate TypeScript/Cloudflare Workers service with its own build, lint, test, and deploy scripts (`mcp/package.json:1-33`), and `docs/` publishes site content plus MCP-facing documentation and indexing assets (`README.md:45-55`, `README.md:91-115`).
