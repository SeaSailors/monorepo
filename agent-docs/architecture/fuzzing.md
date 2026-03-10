# Fuzzing Infrastructure Architecture

Commonware employs a decentralized fuzzing architecture where each core primitive maintains its own fuzzing crate. This ensures that fuzz tests are co-located with the logic they verify and can be run independently or as part of a workspace-wide audit.

## Directory Structure

Fuzzing infrastructure is organized into standalone crates within each primitive's directory:

```text
<primitive>/
├── src/            # Primitive source code
├── fuzz/           # Fuzzing crate
│   ├── Cargo.toml  # Fuzzing dependencies (cargo-fuzz = true)
│   ├── fuzz_targets/
│   │   ├── target1.rs
│   │   └── target2.rs
│   └── corpus/     # (Optional) Seed inputs for fuzzer
└── ...
```

### Workspace Integration

Fuzzing crates are first-class members of the Cargo workspace, allowing for unified dependency management and linting. They typically depend on their parent primitive crate with the `arbitrary` feature enabled to leverage structured input generation.

## Fuzzing Engine

Commonware uses `cargo-fuzz` (libFuzzer) as the primary fuzzing engine. 

### Key Components

1.  **Arbitrary Inputs**: Primitives implement the `Arbitrary` trait (gated by an `arbitrary` feature flag) for core types. This allows the fuzzer to generate structured, valid-looking data rather than raw bytes.
2.  **Deterministic Execution**: Fuzz targets often utilize the `commonware-runtime`'s deterministic executor to ensure that found issues are reproducible.
3.  **Roundtrip Testing**: A common pattern where data is encoded and then decoded to ensure symmetry and lack of panics.

## Storage and Artifacts

*   **Corpus**: Per-target seed inputs live in `*/fuzz/corpus/<target_name>/`.
*   **Artifacts**: Crashes and regressions are saved as files by libFuzzer for local debugging.
*   **Coverage**: Coverage data is generated using `llvm-cov` and stored in `*/fuzz/coverage/`.
