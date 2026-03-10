# Fuzzing Guide

This guide covers the common workflows for running and managing fuzzers in the Commonware repository.

## Prerequisites

Install the necessary tools:

```bash
cargo install cargo-fuzz
rustup component add llvm-tools-preview  # For coverage reports
```

## Running Fuzzers

### Using `just` (Recommended)

The `justfile` provides a high-level command to run all fuzz targets in a specific directory for a set amount of time:

```bash
# Run all fuzzers in the codec crate for 60 seconds each
just fuzz codec/fuzz 60
```

### Manual Execution

For more control, use `cargo-fuzz` directly:

```bash
cd codec/fuzz
cargo +nightly fuzz run codec_roundtrip -- -max_total_time=60
```

## Handling Crashes

When a fuzzer finds a crash, it saves the input to an artifact file.

1.  **Reproduce**: Run the fuzzer with the crash file:
    ```bash
    cargo +nightly fuzz run <target> <path_to_crash_file>
    ```
2.  **Minimize**: Reduce the crash case to the smallest possible input:
    ```bash
    cargo +nightly fuzz tmin <target> <path_to_crash_file>
    ```

## Coverage Reports

Generate a coverage report to see which parts of the code are being exercised:

```bash
# 1. Run fuzzer to collect coverage data
cargo +nightly fuzz coverage <target>

# 2. View report
llvm-cov report \
    -instr-profile=fuzz/coverage/<target>/coverage.profdata \
    target/x86_64-unknown-linux-gnu/release/<target>
```

## CI/CD Expectations

Fuzzers are automatically run in the **Slow** CI workflow (`.github/workflows/slow.yml`) on:
*   Pushes to `main`
*   Pull Requests

Each fuzz directory is tested for 60 seconds per target to catch regressions. If your changes introduce new primitives or complex logic, you are expected to add corresponding fuzz targets.
