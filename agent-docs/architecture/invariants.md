# System Invariants

To ensure compatibility across different runtime implementations and maintain system stability, several technical invariants are enforced.

## Storage Invariants

The `Storage` trait manages data in **Partitions** containing multiple **Blobs**.

### Partition Naming
- **Constraint**: Partition names must be ASCII and match the regex `[A-Za-z0-9_-]`.
- **Rationale**: This ensures filesystem compatibility across all supported operating systems (Linux, macOS, Windows) and simplifies path construction in the deterministic simulator.

### Blob Format
- **Header**: Every blob starts with a fixed 8-byte header.
- **Magic Number**: The first 4 bytes are the magic number `CWIC` (Commonware Integrated Container).
- **Version**: The next 4 bytes represent the storage format version.
- **Verification**: Runtime implementations verify this header on `open` to prevent loading incompatible or corrupted data.

### Write Atomicity
- Mutable storage operations (`write_at`, `sync`) are considered fatal on error.
- If a write or sync fails, the database/blob may be in an inconsistent state. The caller must not continue using that handle and should generally trigger a shutdown/recovery sequence.

## Metric Invariants

Commonware uses a structured metric system based on Prometheus concepts.

### Namespace Reservations
- **Reserved Prefix**: The prefix `runtime` is reserved for internal runtime metrics.
- **Usage**: Actors should use their own labels to namespace their metrics (e.g., `consensus_votes_total`).

### Deterministic Metrics
In the deterministic dialect, metrics are collected into an internal registry that can be encoded and verified (via `context.encode()`). This allows tests to assert that specific events occurred (e.g., "verify that 5 messages were sent").

## Networking Invariants

### Port Constraints (Deterministic)
- **Ephemeral Ranges**: The deterministic network simulator uses ephemeral port ranges.
- **Manual Binding**: Binding to specific ephemeral ports is forbidden to prevent conflicts during parallel simulation runs.
- **Simulated Latency**: Links in the deterministic network must be explicitly configured with `latency`, `jitter`, and `success_rate` using the `oracle`.

## Supervision Invariants

- **Context Uniqueness**: While contexts can be cloned, each clone represents a unique branch in the supervision tree.
- **Abort Propagation**: Aborting a context is an irreversible operation that recursively kills all children.
- **Task Isolation**: Tasks should communicate via channels (provided by `Spawner`) rather than shared mutable state to maintain the integrity of the supervision model.
