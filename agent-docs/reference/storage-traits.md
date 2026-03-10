# Reference: Storage Traits and Specs

This document defines the critical traits and specifications for implementing or consuming storage primitives in Commonware.

## The `Persistable` Trait

The `Persistable` trait is the primary interface for stateful storage structures that need to survive restarts.

```rust
pub trait Persistable {
    type Error;

    /// Durably persist the structure. Guarantees survival after a crash.
    fn commit(&mut self) -> Future<Output = Result<(), Self::Error>>;

    /// Durably persist the structure and eliminate recovery on startup.
    fn sync(&mut self) -> Future<Output = Result<(), Self::Error>>;

    /// Destroy the structure and remove all associated storage.
    fn destroy(self) -> Future<Output = Result<(), Self::Error>>;
}
```

### Invariants:
- Errors returned by `commit` or `sync` are treated as unrecoverable.
- A caller must not use a persistable object after a mutable operation returns an error.

## Runtime `Storage` and `Blob` Traits

Lower-level I/O is performed through the runtime's storage abstractions.

### `Storage` Trait
- `open(partition, name)`: Opens a `Blob` in the specified partition.
- Partition names must match `[A-Za-z0-9_-]+`.

### `Blob` Trait
- `read_at(buf, offset)`: Reads data into `buf` starting at `offset`.
- `write_at(buf, offset)`: Writes `buf` starting at `offset`.
- `sync()`: Flushes all writes to disk.
- `resize(size)`: Resizes the blob.

## Commonware Storage Header (CWIC)

All persisted blobs in Commonware begin with a 16-byte header:

| Offset | Size | Name | Description |
|--------|------|------|-------------|
| 0      | 4    | Magic | Fixed `CWIC` (0x43574943) |
| 4      | 4    | Runtime Version | Current version of the storage runtime. |
| 8      | 4    | Blob Version | Version of the blob format. |
| 12     | 4    | Reserved | Reserved for future use. |

### Header Invariants:
- Magic bytes must match exactly.
- Runtime version must be compatible with the current implementation.
- Blob version must fall within the requested version range upon opening.

## Journaling Invariants

- **Sequentiality**: Journals must guarantee that items are assigned strictly increasing positions.
- **Stable Positions**: Once assigned, an item's position is immutable even if earlier items are pruned.
- **Alignment**: Pruning and segmented journals align to blob boundaries. A request to prune at position `X` may result in an actual pruning boundary `Y <= X`.
- **Rewind Safety**: Rewinding is not guaranteed to survive a crash until `commit` or `sync` is called.
