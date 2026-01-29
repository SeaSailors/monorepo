# Git Conventions

This document outlines the Git and CI/CD conventions used in the Commonware repository.

## Branching Model

* **Default Branch**: `main`.
* All feature development and bug fixes should be performed on feature branches and merged into `main` via Pull Requests.

## Commit Message Conventions

Based on repository history, the following patterns are preferred:

* **Prefixes**: Standard tags like `[release]` are used for automated or significant administrative commits.
* **PR Numbers**: Commits merged via GitHub typically include the PR number in the subject line (e.g., `Description (#123)`).
* **Conciseness**: Subjects should be concise and descriptive.
* **History**: Note that the local checkout has limited history (1 commit), restricting deep inference of individual contributor styles.

## Release Process

* **Versioning**: SemVer-like versioning (e.g., `v0.0.65`).
* **Tags**: Releases are tagged with the version number.
* **Release Commits**: Automated or semi-automated commits with the subject `[release] vX.Y.Z (#PR)`.

## Pull Request Expectations (CI Enforced)

The `Fast` and `Slow` CI workflows enforce the following on every PR:

### Code Quality
* **Formatting**: `just check-fmt` must pass (uses nightly `rustfmt`).
* **Linting**: `just clippy` must pass across multiple platforms and feature sets (e.g., `iouring-storage`, `iouring-network`).
* **Documentation**: `just check-docs` and `just test-docs` ensure documentation is valid and examples are correct.

### Testing
* **Workspace Tests**: `just test --workspace` must pass across Ubuntu, macOS, and Windows.
* **Feature Matrices**: Tests are run with various feature flags and `--no-default-features`.
* **MIRI**: Unsafe code must pass MIRI checks.
* **Benchmarks**: Performance regressions are monitored via `benchmark.yml`.

### Conformance
* **Labels**: PRs modifying code that affects serialized formats or deterministic behavior require a specific conformance label. This is enforced by `conformance-label.yml`.
* **Lockfiles**: `Cargo.lock` must be clean and up-to-date. `just udeps` is used to verify dependency hygiene.

## CI Workflow Overview
* **Fast**: Runs on every push to `main` and all Pull Requests. Includes fmt, clippy, and partitioned tests.
* **Slow**: Runs on `main` and Pull Requests. Includes more exhaustive testing.
* **Publish**: Automatically publishes crates to crates.io upon pushing to `main` (if versions are bumped).
