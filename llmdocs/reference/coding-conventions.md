# Coding Conventions

This document outlines the high-level coding conventions and repository-wide rules for the Commonware Monorepo.

## Rust Formatting & Imports

- **Imports**: Grouped by crate and sorted.
  - `imports_granularity = "Crate"`
  - `group_imports = "One"`
- **Nightly Format**: Formatting is enforced using a specific nightly toolchain (defined in `.github/workflows/fast.yml`).
- **Just Commands**: Use `just fix-fmt` (or `just f`) to auto-format the entire workspace.

## Linting Posture

Commonware maintains a strict linting posture enforced via `cargo clippy` and workspace-wide settings:

- **Deny**:
  - `unused-must-use`: All results must be handled.
  - `rust-2018-idioms`: Enforce modern Rust idioms.
  - `undocumented_unsafe_blocks`: Every `unsafe` block must have a `// SAFETY:` comment.
- **Warn**:
  - `missing-const-for-fn`: Prefer `const` where possible.
  - `use-self`: Use `Self` instead of the type name in impl blocks.
  - `redundant-clone`: Avoid unnecessary cloning.
- **Allow**:
  - `suspicious_op_assign_impl`: Allowed due to false positives in specific implementations.
- **Documentation**: All public items must be documented. `just check-docs` enforces `-D warnings` for rustdoc.

## Feature Flags & Propagation

- **Zepter**: Used for feature propagation and formatting.
  - `just check-features` to verify.
  - `just fix-features` to auto-propagate features across workspace dependencies.
- **Default Features**: Many crates default to `false` for standard features to support `no_std` environments.

## Testing Patterns

Commonware uses `cargo-nextest` for high-performance test execution.

- **Profiles** (defined in `nextest.toml`):
  - **default**: Skips slow and conformance tests.
  - **slow**: Runs tests ending in `_slow_$`.
  - **conformance**: Runs tests ending in `_conformance_$`.
  - **all**: Runs all tests in the workspace.
- **Deterministic Runtime**: Tests involving async/concurrency should use the deterministic runtime (`commonware-runtime/src/deterministic.rs`) to ensure reproducibility.
- **Overflow Checks**: Enabled in ALL profiles (including `release` and `bench`) to ensure adversarial safety.
- **Miri**: Use `just miri <module>` for memory safety verification of unsafe code.
- **Fuzzing**: Fuzz targets are located in `<crate>/fuzz` and can be run via `just fuzz <path>`.

## Cross-Platform & No_Std

- **WASM**: Core crates (`cryptography`, `utils`, `runtime`, `consensus`, `storage`) must maintain `wasm32-unknown-unknown` compatibility.
- **no_std**: Verified via `.github/scripts/check_no_std.sh` in CI.
- **io_uring**: Linux-only features (`iouring-storage`, `iouring-network`) are tested specifically in Ubuntu environments.

## MCP (Node/TS) Conventions

Located in `mcp/`:

- **Runtime**: Cloudflare Workers (Wrangler).
- **Tooling**:
  - **Formatting**: Prettier (`npm run format`).
  - **Linting**: ESLint (`npm run lint`).
  - **Type Safety**: TypeScript (`tsc --noEmit` during build).
  - **Testing**: Vitest (`npm test`).
- **Module System**: ESM (`"type": "module"`).
- **Standards**: Uses the official `@modelcontextprotocol/sdk`.
