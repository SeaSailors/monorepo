# Commonware Documentation Index

This index is a retrieval map for the Commonware Library. Start with the overview, then follow the architecture, guides, and reference documents for the area you need.

## Overview
- [Project Overview](overview/project-overview.md): Repository purpose, core primitives, examples, and companion tooling.

## Architecture
- [Workspace and Primitive Architecture](architecture/workspace-primitive-architecture.md): Cargo workspace layout, crate boundaries, and composition model.
- [Deterministic Runtime and Testing](architecture/deterministic-runtime-testing.md): Seeded runtime, deterministic execution, and simulated networking.
- [Stability and Conformance Workflow](architecture/stability-conformance-workflow.md): Stability annotations, conformance hashes, and fixture regeneration.
- [MCP Service Architecture](architecture/mcp-service-architecture.md): Cloudflare Workers MCP service, indexing model, and retrieval flow.
- [Examples Ecosystem](architecture/examples-ecosystem.md): Runnable example applications built from the core primitives.
- [Docs Publishing Pipeline](architecture/docs-publishing-pipeline.md): Static-site generation, code mirroring, sitemap generation, and docs delivery.

## Guides
- [Add a Workspace Crate](guides/add-workspace-crate.md): Register a new workspace crate and verify it.
- [Add an Example Crate](guides/add-example-crate.md): Add and wire an example crate into the workspace.
- [Add a Codec Conformance Test for a New Type](guides/add-conformance-test-for-new-type.md): Add codec conformance coverage and verify fixtures.
- [How to Run Local Quality Checks](guides/local-quality-checks.md): Pre-PR format, lint, test, stability, and conformance workflow.
- [Regenerate Docs Sitemap and Code Mirror](guides/regenerate-docs-sitemap-and-mirror.md): Rebuild docs HTML, code mirror, and sitemap artifacts.
- [Run the MCP Service Locally](guides/run-mcp-service-locally.md): Start and validate the MCP service.
- [Write a Deterministic Async Test](guides/write-deterministic-async-test.md): Reproduce async tests with the deterministic runtime and simulated network.

## Reference
- [Build, CI, and Quality Gates](reference/build-ci-gates.md): Local command surface and CI validation model.
- [Coding Conventions](reference/coding-conventions.md): Rust and TypeScript style, lint, formatting, and runtime-isolation rules.
- [Git Conventions](reference/git-conventions.md): Commit-message style, branch topology, and lore-based commit guidance.
