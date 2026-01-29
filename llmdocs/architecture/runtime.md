# Runtime & Determinism

The `commonware-runtime` primitive provides a unified interface for asynchronous operations, resource management, and observability. It is designed around the principle of **Runtime Agnosticism**, ensuring that all other primitives in the repository remain independent of specific executor implementations (like `tokio`).

## Core Abstraction

The runtime is exposed through a set of traits that define the capabilities available to an actor:

- **Spawner**: Ability to spawn and manage asynchronous tasks.
- **Clock**: Access to system time and sleep functionality.
- **Network**: Low-level networking operations (TCP/UDP).
- **Storage**: Persistent data management through partitions and blobs.
- **Metrics**: Recording and exporting application-level telemetry.

### The Runtime Agnosticism Rule
**CRITICAL**: All code outside the `runtime/` crate is forbidden from importing or using `tokio` directly. Instead, they must accept an implementation of the `runtime` traits. This allows the same code to run in a high-performance multi-threaded environment (Production) or a single-threaded, reproducible simulation (Deterministic).

## Runtime Dialects

Commonware supports two primary "dialects" of the runtime:

### 1. Production Dialect (Tokio-based)
- **Executor**: Multi-threaded `tokio` runtime.
- **Timing**: Real system clock.
- **I/O**: Standard Linux/macOS/Windows asynchronous I/O (with optional `io_uring` support on Linux).
- **Concurrency**: True parallel execution across CPU cores.

### 2. Deterministic Dialect (Simulation)
- **Executor**: Single-threaded, custom scheduler.
- **Timing**: Discrete "cycle" increments. Time only advances when all tasks are pending.
- **Reproducibility**: Uses a seeded RNG to determine task polling order and provide entropy.
- **Verification**: Maintains an `Auditor` that computes a rolling SHA-256 digest of all deterministic events (task polls, RNG calls, etc.). If two runs with the same seed produce different digests, a non-determinism bug is present.

## Mandatory Supervision Tree

Resource management in Commonware is built on a strict **Supervision Tree** model:

1. **Context-Driven**: All tasks are spawned from a `Context`.
2. **Lifecycle Linking**: When a `Context` is cloned, it creates a child node in the tree.
3. **Automatic Termination**: If a parent `Context` is dropped or its task finishes/aborts, all descendant tasks in its subtree are automatically aborted.
4. **Ownership**: This ensures that no "zombie" tasks are left running and that resources (like open network connections or storage handles) are cleanly released when their supervisor terminates.

### Labeling
Every node in the supervision tree can be assigned a label (via `context.with_label("name")`). These labels are used for:
- Structured logging (`tracing`).
- Metric namespacing.
- Debugging task hierarchies in the deterministic runner.
