# Guide: Using Journals for Persistence

Journals are the primary way to persist ordered data in Commonware. This guide covers how to initialize, append to, and recover data from a journal.

## 1. Initialization

To use a journal, you first need a runtime `Context`. Journals are typically initialized with a configuration that specifies the partition name and items per blob.

```rust
use commonware_storage::journal::contiguous::fixed;
use commonware_utils::{NZUsize, NZU64};

let journal_cfg = fixed::Config {
    partition: "my_log".to_string(),
    items_per_blob: NZU64!(1024),
    write_buffer: NZUsize!(1 << 16),
    buffer_pool: my_pool,
};

let mut journal = fixed::Journal::init(context.with_label("journal"), journal_cfg).await?;
```

## 2. Appending Items

Items are appended to the end of the log. Each append returns the unique position of the item.

```rust
let pos = journal.append(my_item).await?;
println!("Item stored at position: {}", pos);
```

## 3. Durability (Commit and Sync)

Appends are buffered. You must call `commit` or `sync` to ensure data is persisted to disk.

- **commit**: Fast, guarantees data survives a crash.
- **sync**: Slower, guarantees data survives a crash AND no recovery is needed on restart.

```rust
journal.sync().await?;
```

## 4. Replay and Recovery

Upon restart, you can recover state by replaying the journal. You typically replay from a known "commit" or "checkpoint" operation.

```rust
use futures::StreamExt;

// Replay from the beginning (position 0)
let stream = journal.replay(0, NZUsize!(1024)).await?;
pin_mut!(stream);

while let Some(result) = stream.next().await {
    let (pos, item) = result?;
    // Apply item to in-memory state
}
```

## 5. Pruning

To save disk space, you can prune old items that are no longer needed for recovery.

```rust
// Prune everything before position 500
journal.prune(500).await?;
```

Note: Pruning is often aligned to blob boundaries, so the `oldest_retained_pos` might be slightly less than the requested prune position.

## 6. Authenticated Proofs

If you use an `AuthenticatedJournal`, you can generate proofs for specific items.

```rust
let (proof, items) = authenticated_journal.proof(start_loc, max_ops).await?;
// proof can now be sent to a peer along with items for verification
```
