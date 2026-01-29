# Conformance System Architecture

The Conformance System is a repository-wide mechanism designed to ensure backward
compatibility of serialized data (wire formats), persisted data (storage formats),
and protocol mechanisms. It detects accidental breaking changes by comparing
deterministic outputs against known-good hashes.

## Core Components

### 1. The Conformance Trait

Located in `commonware-conformance`, the `Conformance` trait is the foundation
of the system. Any type or mechanism that requires stability must implement it.

```rust
pub trait Conformance: Send + Sync {
    fn commit(seed: u64) -> impl Future<Output = Vec<u8>> + Send;
}
```

* Determinism: Implementations MUST be deterministic. The same seed must always
  produce the same output across all platforms and runs.
* Scope: While frequently used for Codec (serialization), it can be used for any
  byte-committable process (e.g., protocol transcript logs).

### 2. Hash Computation

The system computes a single SHA-256 hash for a set of test cases:
1. Generate `n_cases` commitments (using seeds 0..n_cases).
2. For each commitment:
   - Append the length (u64, little-endian).
   - Append the commitment bytes.
3. SHA-256 hash the entire stream.

This ensures that any change to any of the generated cases, or their order,
results in a different hash.

### 3. Conformance Macros

The `commonware-conformance-macros` crate provides the `conformance_tests!` macro
to automate test generation.

```rust
conformance_tests! {
    MyType,             // Uses default (65,536) cases
    AnotherType => 100, // Custom case count
}
```

* Function Naming: Generates test functions like `test_my_type`.
* Key Generation: Uses `module_path!() + "::" + TypeName` as the unique identifier
  in the TOML file.
* Grouping: Annotates tests with `#[test_group("conformance")]` for selective
  execution via `nextest`.

## Data Storage (conformance.toml)

Hashes are stored in `conformance.toml` files located in the manifest directory
of each crate.

```toml
["commonware_codec::types::vec::Vec<u8>"]
n_cases = 65536
hash = "7f8e...a1b2"
```

## Enforcement and Stability

### Additive Changes
Adding a new type to `conformance_tests!` is considered additive. When the test
runs, if the key is missing from `conformance.toml`, the system automatically
computes the hash and appends it to the file.

### Breaking Changes
Modifying an existing implementation that changes its `commit` output will cause
the hash to mismatch, failing the test.

### CI Guardrails
The `.github/scripts/check_conformance_label.sh` script enforces safety:
* Additive changes: Permitted without special labels.
* Modifications/Deletions: Blocked unless the PR has one of the following labels:
    - `breaking-format`
    - `breaking-api`

This ensures that breaking changes to stable formats are intentional and visible
during code review.
