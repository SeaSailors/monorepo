# Commonware Project Overview

Commonware is a library of high-performance, production-ready distributed systems primitives designed for adversarial environments. It provides a composable stack for building decentralized applications, blockchains, and peer-to-peer systems with an emphasis on deterministic testing and performance.

## Core Purpose

Commonware aims to be the "anti-framework" for distributed systems, providing modular primitives that can be composed as needed rather than forcing a rigid application structure. Every component is designed to operate safely in adversarial (Byzantine) environments.

## Key Crates and Modules

The project is organized as a Cargo workspace with first-class primitives:

- **`commonware-p2p`**: Authenticated, encrypted per-peer messaging substrate. Includes both real and simulated network backends.
- **`commonware-consensus`**: Leader-based BFT ordering (Simplex) and ordered broadcast. Pluggable signature schemes (Ed25519, BLS12-381).
- **`commonware-cryptography`**: Core identities, signing (Ed25519, Secp256r1, BLS12-381), multi-sig/threshold certificates, and handshakes.
- **`commonware-storage`**: Authenticated data structures (QMDB, MMR), journals (WAL), and persistent blob storage.
- **`commonware-runtime`**: Abstract runtime traits for I/O, time, and task supervision.
- **`commonware-codec`**: Safe binary serialization with explicit decoding limits for untrusted input.
- **`commonware-stream`**: Framed, encrypted message streams over arbitrary transports.

### Composition

Primitives build on each other to form a complete stack:
1. **`codec`** + **`cryptography`** define identities and wire formats.
2. **`stream`** + **`p2p`** provide the networking substrate.
3. **`storage`** + **`consensus`** provide durability and agreement over the network.
4. **`conformance`** ensures all primitives maintain stable formats over time.

## Supported Runtimes

Commonware uses a "1 trait, 2 dialects" approach to ensure portability and testability:

- **Tokio (Production)**: Multi-threaded, high-performance runtime for production deployments. Supports `io_uring` for optimized network and storage I/O on Linux.
- **Deterministic (Testing)**: A single-threaded simulation runtime that provides:
    - Seeded, reproducible task scheduling.
    - Simulated time and network conditions.
    - Checkpoint/recovery to simulate unclean shutdowns and restarts.
    - Auditor state hashing to verify determinism across runs.

**Invariant**: Primitives must be runtime-agnostic and never depend on Tokio directly (only the `runtime` crate and deployment tools may use Tokio).

## Developer Resources

- **Documentation**: Hosted at [commonware.xyz](https://commonware.xyz), including technical deep-dives into algorithms like Simplex and QMDB.
- **MCP Server**: A Model Context Protocol (MCP) server at `mcp.commonware.xyz` allows LLMs (Claude, Cursor) to search code, fetch versioned files, and understand the library.
- **Examples**: Reference implementations like `alto` (blockchain), `chat`, and `sync` demonstrate how to compose primitives.

## Workflow and Quality Assurance

The project maintains high standards via a rigorous CI/CD pipeline and specialized testing:

- **Build/Test**: Driven by `just`. Use `just lint`, `just test`, and `just pre-pr` for local verification.
- **Conformance**: Uses `commonware-conformance` to hash protocol commitments against stored snapshots in `conformance.toml`, preventing accidental breaking changes to wire/storage formats.
- **Fuzzing**: Extensive fuzz targets for every primitive using `cargo-fuzz` and `libFuzzer` to identify edge cases in untrusted input handling.
- **Miri**: Targeted memory safety verification for unsafe code (e.g., storage indexers).
- **no_std**: CI verifies that core crates (`codec`, `cryptography`, etc.) remain compatible with bare-metal targets.
