# Guide: Working with QMDB

QMDB is the high-level authenticated database in Commonware. This guide explains the typical workflow for a keyed database (KV store).

## 1. Initializing the Database

To start using QMDB, you typically initialize a "current" implementation, which provides the standard KV interface.

```rust
use commonware_storage::qmdb::current::ordered::fixed;

let mut db = fixed::Database::init(context, db_cfg).await?;
```

## 2. Transitioning to Mutable State

Updates can only be performed in the `Mutable` state.

```rust
let mut mutable_db = db.into_mutable();
```

## 3. Modifying Data

In the mutable state, you can update or delete keys.

```rust
// Update a key
mutable_db.update(key, value).await?;

// Delete a key
mutable_db.delete(key).await?;
```

## 4. Finalizing Changes (Merkleize and Sync)

To compute the new root and persist changes, you transition the database back to a clean state.

```rust
// Compute the Merkle root
let merkleized_db = mutable_db.into_merkleized();
let root = merkleized_db.root();

// Sync to disk
let mut db = merkleized_db.sync().await?;
```

## 5. Querying and Proving

Once the database is synced (Clean state), you can query values and generate proofs.

```rust
// Get a value
let value = db.get(key).await?;

// Generate an inclusion proof
let proof = db.proof(key).await?;
```

## 6. Syncing with Peers

If your local database is behind, you can use the sync engine to catch up to a target root provided by a peer.

```rust
use commonware_storage::qmdb::sync;

let db = sync::sync(sync_config).await?;
```

The sync engine will automatically fetch missing operations, verify them against the Merkle tree, and rebuild the local state to match the target root.
