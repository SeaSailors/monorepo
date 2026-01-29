# Storage Overview: Journals and Persistence

Commonware provides a suite of storage primitives designed for high-performance distributed systems. The architecture centers around append-only logs (Journals), authenticated data structures (MMR), and a persistent database model (QMDB).

## Core Philosophy

Storage in Commonware follows the "The Simpler The Better" principle. Primitives are optimized for high throughput, low latency, and adversarial safety. All storage components are designed to work within the Commonware abstract runtime, ensuring they are portable and deterministically testable.

## Journals (Append-Only Logs)

Journals are the foundational persistence mechanism. They provide a sequentially ordered log of arbitrary data with fast replay and historical pruning.

### Journal Variants

- **Contiguous Journals**: Items are stored consecutively and indexed by a 0-based position.
  - **Fixed-size**: Optimized for items with a uniform, known size.
  - **Variable-size**: Supports items of differing lengths.
- **Segmented Journals**: Designed for large-scale logging, splitting data into multiple blobs (files) to facilitate easier management and pruning.
- **Authenticated Journals**: Combines a contiguous journal with a Merkle Mountain Range (MMR). Every item added to the journal is hashed into the MMR, allowing for efficient inclusion proofs.

### Write-Ahead Log (WAL) Pattern

Higher-level primitives, such as Consensus, use Journals as a Write-Ahead Log. Operations are first appended to the journal to ensure durability before being applied to in-memory state. Upon restart, the state can be reconstructed by replaying the journal from the last known checkpoint.

## Persistence Model

Commonware defines a `Persistable` trait for structures that manage their own durability.

### Persistence Lifecycle

1. **append / put**: Modifies the in-memory state or appends to un-synced buffers.
2. **commit**: Durably persists the structure to ensure it survives a crash. This may involve background syncs or metadata updates.
3. **sync**: The strongest guarantee. Guarantees the state survives a crash and that no complex recovery is needed upon startup.
4. **rewind**: Reverts the structure to a previous state, discarding more recent entries.
5. **prune**: Removes historical data before a certain boundary to reclaim space.

## Authenticated Data Structures

Commonware emphasizes authenticated storage to ensure data integrity in adversarial environments.

- **Merkle Mountain Range (MMR)**: Used in authenticated journals and QMDB for efficient inclusion proofs and state root computation.
- **Authenticated BitMap**: Used for tracking active/inactive operations in databases.
- **QMDB (Quick Merkle Database)**: An authenticated database that derives its state from an append-only log of operations.

## Runtime Interaction

All storage primitives interact with the filesystem through the `commonware_runtime::Storage` and `Blob` traits. This abstraction allows the same storage logic to run on real filesystems (Tokio/io_uring) or in-memory simulations (Deterministic Runtime).

- **Partitions**: Storage is organized into partitions (e.g., "journal", "mmr"). Partition names must be ASCII alphanumeric.
- **Blobs**: Individual data units within a partition.
- **Magic Headers**: Every storage blob begins with a standard header (`CWIC`) and versioning information to prevent corruption and ensure compatibility.
