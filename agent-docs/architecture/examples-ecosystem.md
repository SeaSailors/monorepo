# Examples Ecosystem

## 1. Identity

- **What it is:** A set of runnable Rust applications and libraries that compose the primitives into end-to-end workflows.
- **Purpose:** Provide reference integrations for consensus, networking, storage, cryptography, and runtime composition.

## 2. Core Components

- `README.md:31-55` (Examples): Lists the supported example applications and their intended roles.
- `Cargo.toml:23-29` (workspace members): Includes `examples/bridge`, `examples/chat`, `examples/estimator`, `examples/flood`, `examples/log`, `examples/reshare`, and `examples/sync` as workspace members.
- `examples/*/Cargo.toml`: Declares example package metadata, workspace-versioned dependencies, and binary/library entrypoints.
- `examples/*/README.md`: Documents each example's runtime behavior, setup, and command-line usage.
- `examples/bridge/src/lib.rs:1-171` (`Scheme`, namespace constants): Shows a consensus bridge built on `commonware_consensus` and `commonware_cryptography`.
- `examples/chat/src/main.rs:1-201` (`main`, `APPLICATION_NAMESPACE`): Shows authenticated encrypted chat on top of `commonware_p2p` and `commonware_runtime`.
- `examples/estimator/src/lib.rs` and `examples/sync/src/net/wire.rs`: Additional example surfaces for simulation and synchronization.

## 3. Execution Flow (LLM Retrieval Map)

- **1. Compose primitives:** Example crates import workspace primitives and runtime helpers from `commonware-*` crates.
- **2. Declare package shape:** Each example's `Cargo.toml` sets the crate name, workspace-managed metadata, dependencies, and bin targets.
- **3. Configure namespaces and peers:** Example code defines application namespaces, peer sets, and transport settings (`examples/chat/src/main.rs:70-167`, `examples/bridge/src/lib.rs:151-171`).
- **4. Run the system:** Each example starts a runtime, instantiates its network or consensus engine, and drives an application-specific loop.
- **5. Observe integration boundaries:** The examples show which primitives are intended to be combined together and which assumptions each integration makes.

## 4. Design Rationale

The examples act as executable documentation. They stay close to the primitives so they show supported composition patterns without introducing another abstraction layer.
