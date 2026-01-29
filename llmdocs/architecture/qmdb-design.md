# QMDB Design and Sync Flow

QMDB (Quick Merkle Database) is an authenticated database family implemented in Commonware. It is inspired by the QMDB research and optimized for high-performance distributed state reconciliation.

## State Derivation

A QMDB state is derived entirely from an append-only log of operations (updates and deletes). This design makes the database naturally compatible with distributed systems that already use logs for agreement (e.g., consensus).

### Key Concepts

- **Active Operation**: An update operation is "active" if its key has a value and this is the most recent operation for that key.
- **Snapshot**: An in-memory or persisted index that maps keys to the location of their most recent active operation in the log.
- **Inactivity Floor**: A moving boundary in the log. All operations below this floor are guaranteed to be inactive.

## Database States

A QMDB instance transitions through four logical states based on its Merkleization and Durability:

1. **Mutable**: (Unmerkleized, NonDurable). The only state where keys can be updated or deleted.
2. **Merkleized**: (Merkleized, NonDurable). The root hash has been computed, but changes are not yet synced to disk.
3. **Durable**: (Unmerkleized, Durable). Changes are persisted to the log, but the Merkle root is not yet finalized.
4. **Clean**: (Merkleized, Durable). Both Merkleized and synced to disk. This is the starting state after `init()`.

## Authenticated Proofs

QMDB provides efficient proofs for state inclusion and exclusion:

- **Inclusion Proof**: Proves that a specific key-value pair is part of the database state at a given root.
- **Multi-Proof**: Efficiently proves multiple keys at once.
- **Keyless Proof**: Proves properties of the log itself without referencing specific keys.

## Sync Protocol

The QMDB sync protocol allows a node to catch up to a target state root by fetching missing operations and Merkle nodes from peers.

### Sync Workflow

1. **Target Identification**: The node identifies a target root digest it wants to reach.
2. **Gap Detection**: The sync engine identifies "gaps" in its local log where operations are missing relative to the target state.
3. **Resolution**: The engine uses a `Resolver` (typically integrated with P2P) to fetch the missing operations from peers.
4. **Verification**: As operations are received, they are appended to the local log and the Merkle root is updated. The final root must match the target.
5. **Snapshot Rebuilding**: Once the log is complete, the snapshot is updated to reflect the new state.

### Inactivity Floor Management

To prevent the log from growing indefinitely, QMDB raises the inactivity floor. Active operations below the floor are "moved" to the tip of the log, and the old sections are pruned. This process is orchestrated using an Authenticated BitMap to efficiently track operation status.
