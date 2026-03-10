# Coding Conventions

## 1. Core Summary

This repository uses workspace-level Rust formatting, linting, testing, and stability rules, plus a separate TypeScript style contract for `mcp/`. The conventions emphasize crate-level imports, denied warnings, runtime isolation outside `runtime/`, explicit stability annotations on public items, and deterministic/controlled async patterns.

## 2. Source of Truth

- **Primary Code:** `Cargo.toml` - workspace package metadata, dependency aliases, lint settings, and release/dev/test overflow-checking profiles.
- **Primary Code:** `clippy.toml` - disallowed Rust types, macros, and methods that encode repository-specific API preferences.
- **Primary Code:** `rustfmt.toml` - import grouping and granularity rules for Rust formatting.
- **Primary Code:** `justfile` - canonical developer commands for formatting, linting, tests, conformance, docs, and stability checks.
- **Primary Code:** `mcp/package.json` - TypeScript build/lint/test/format command contract for the MCP subproject.
- **Configuration:** `mcp/eslint.config.js` - TS lint rules for `src/**/*.ts`, Cloudflare globals, `eqeqeq`, `curly`, and unused-variable handling.
- **Configuration:** `mcp/.prettierrc` - TS formatting defaults (`semi`, double quotes, 2-space tabs, 100-column width).
- **Related Architecture:** `README.md` - repository-level summary of primitives, stability policy, and development workflow.

## 3. High-Level Rules

- Prefer workspace imports and keep Rust import groups collapsed by crate.
- Treat warnings as failures in workspace Rust code; avoid introducing new clippy violations.
- Prefer `commonware_utils::sync`, `commonware_utils::channel`, and `commonware_macros::select!` over direct `std::sync`, `futures::channel`, or `futures::select*` usage.
- Avoid `tokio` outside of the `runtime/` primitive; other crates should remain runtime-agnostic.
- Keep public Rust APIs stability-annotated and use the repository's stability gates when changing exported items.
- Use `just` recipes as the authoritative local workflow for fmt, lint, tests, conformance, and stability validation.
- In `mcp/`, follow ESLint and Prettier defaults: TypeScript modules, `eqeqeq`, block `curly`, no-console allowed, and explicit unused-argument underscores.
