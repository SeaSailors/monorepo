# Build, CI, and Quality Gates

## 1. Core Summary

The workspace uses `just` as the canonical local command surface, and CI mirrors those recipes across Rust, TypeScript, docs, fuzzing, coverage, stability, and conformance jobs. The fast lane checks formatting, docs, tests, stability annotations, dependency hygiene, and workspace lockfile state; the slow lane adds longer partitions, benchmarks, fuzzing, Miri, and conformance verification. Separate workflows cover coverage upload, MCP TypeScript checks, and Quint validation.

## 2. Source of Truth

- **Primary Code:** `justfile:17-177` - Local recipes for build, fmt, clippy, docs, tests, fuzzing, udeps, Miri, stability, and conformance. `pre-pr` runs `lint`, `test-docs`, and `test`.
- **Primary Code:** `.github/workflows/fast.yml:1-260` - Fast CI lane with lint, docs, tests, subset tests, stability, unstable-public, dependency, lock, docs, build, WASM, no_std, publish-order, zepter, and gate jobs.
- **Primary Code:** `.github/workflows/slow.yml:1-260` - Slow CI lane with eight-way test partitions, benchmarks, fuzzing, Miri, conformance, and gate jobs.
- **Primary Code:** `.github/workflows/coverage.yml:1-95` - Coverage generation and Codecov upload.
- **Primary Code:** `.github/workflows/mcp.yml:1-147` - Node/TypeScript CI for the MCP service.
- **Primary Code:** `.github/workflows/quint.yml:1-29` - Quint checks for `pipeline/minimmit/quint`.
- **Related Architecture:** `Cargo.toml:54-72,173-196` - Workspace lint policy, stability cfg checking, and overflow-check settings.
- **Related Architecture:** `codecov.yml:1-14` - Coverage threshold settings for patch and project status.
- **Related Architecture:** `mcp/package.json:6-17` - MCP-local build/lint/test/format command contract.
