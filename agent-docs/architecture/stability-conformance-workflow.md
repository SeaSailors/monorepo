# Stability and Conformance Workflow

## 1. Identity

- **What it is:** The repository's policy layer for public API stability, conformance hashing, and fixture regeneration.
- **Purpose:** Prevent accidental breaking changes and lock format behavior across code, storage, and wire-level outputs.

## 2. Core Components

- `README.md:57-79` (Stability): Documents stability levels and the `commonware_stability_<level>` cfg flow.
- `Cargo.toml:54-58` (`[workspace.lints.rust]`): Enables `check-cfg` for stability-related cfg values.
- `justfile:103-113,115-177` (`test-conformance`, `regenerate-conformance`, `check-stability`, `unstable-public`): Canonical local validation entry points.
- `conformance/src/lib.rs:1-228` (`Conformance`, `compute_conformance_hash`, `run_conformance_test`): Shared hashing and fixture verification engine.
- `conformance/macros/src/lib.rs:94-152` (`conformance_tests!`): Generates test cases tied to `conformance.toml`.
- `codec/src/conformance.rs:1-92` (`generate_value`, `CodecConformance<T>`): Bridges `Encode` and `Arbitrary` into the conformance system.
- `codec/src/types/*` (`conformance` modules): Shows how codec types opt into `CodecConformance<T>` inside `#[cfg(feature = "arbitrary")]` test modules.

## 3. Execution Flow (LLM Retrieval Map)

- **1. Annotate:** Public items receive stability annotations in the crate source and are checked by `just check-stability` and `just unstable-public`.
- **2. Verify:** `check-stability` builds the workspace at each stability level and then runs the missing-public check (`justfile:115-177`).
- **3. Hash:** Conformance tests generate deterministic commitments and hash them in `conformance/src/lib.rs:176-228`.
- **4. Regenerate:** When an intentional format change is approved, `RUSTFLAGS="--cfg generate_conformance_tests" just test-conformance ...` rewrites fixture hashes in the crate's `conformance.toml`.

## 4. Design Rationale

The repo treats stability as a build-time policy, not a comment-only convention. Conformance hashes then make wire/storage-format changes visible as test failures instead of silent drift.
