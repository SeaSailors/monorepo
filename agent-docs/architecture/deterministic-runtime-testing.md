# Deterministic Runtime and Adversarial Testing

## 1. Identity

- **What it is:** A seeded runtime and simulation stack for reproducible async execution, network behavior, and recovery testing.
- **Purpose:** Make adversarial and distributed tests replayable so failures can be debugged from a seed.

## 2. Core Components

- `runtime/src/deterministic.rs:1-260,522-580` (`Config`, `Runner`, `Runner::seeded`, `Runner::timed`, `Runner::start_and_recover`, `Auditor`): Seeded scheduler, runtime auditing, and recovery controls.
- `p2p/src/simulated/mod.rs:1-260` (`Network`, `Link`, `Oracle`, tests): Deterministic network simulator with dynamic links, bandwidth, and ordered delivery.
- `p2p/src/simulated/ingress.rs:1-240` (`Control`, `Oracle`, `Link`, `Message`): Peer registration, bandwidth limits, link mutation, and blocked-peer queries.
- `runtime/fuzz/fuzz_targets/blob_integrity.rs` and `p2p/fuzz/fuzz_targets/simulated.rs`: Fuzz targets that reuse deterministic runtime semantics.
- `invariants/src/minifuzz.rs:1-220` (`Builder`, `Builder::test`): Lightweight reproducible invariant fuzzing.

## 3. Execution Flow (LLM Retrieval Map)

- **1. Start:** Tests construct `deterministic::Runner` with `Runner::seeded`, `Runner::timed`, or a custom `Config` in `runtime/src/deterministic.rs:500-550`.
- **2. Execute:** Tasks run under the seeded scheduler; the `Auditor` records state transitions in `runtime/src/deterministic.rs:145-190`.
- **3. Simulate:** Network tests create `p2p::simulated::Network` and mutate `Oracle` links, bandwidth, and peer sets in `p2p/src/simulated/mod.rs:220-260` and `p2p/src/simulated/ingress.rs:135-240`.
- **4. Recover or verify:** Tests compare `context.auditor().state()`, replay outputs, or checkpoints returned by `Runner::start_and_recover` to validate determinism and recovery.

## 4. Design Rationale

The runtime and simulator are designed to make concurrency and network nondeterminism observable without making tests flaky. Seeded execution plus state auditing keeps failures reproducible.
