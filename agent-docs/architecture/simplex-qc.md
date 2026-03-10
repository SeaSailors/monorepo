# Simplex Quorum Certificates (QC)

Quorum Certificates (QCs) are the fundamental proof of consensus in Simplex. They represent the collective agreement of at least $2f+1$ participants (a quorum) on a specific protocol event.

Simplex utilizes three distinct types of certificates to drive the state machine forward.

## Certificate Types

### 1. Notarization Certificate
A **Notarization** proves that a specific `Proposal` (payload + metadata) has been endorsed by a quorum of validators.
- **Subject**: `Notarize { proposal }`
- **Purpose**: It indicates that a proposal is "valid" and "notarized" but not yet final. A notarized proposal is a candidate for finalization.
- **Formation**: Aggregate of individual `Notarize` votes.

### 2. Nullification Certificate
A **Nullification** proves that a quorum of validators has agreed to skip a specific view (typically because the leader was slow or unresponsive).
- **Subject**: `Nullify { round }`
- **Purpose**: It allows the network to safely advance to the next view without finalizing any block in the current view. This ensures liveness during periods of leader failure.
- **Formation**: Aggregate of individual `Nullify` votes.

### 3. Finalization Certificate
A **Finalization** is the strongest proof in the protocol. It confirms that a specific `Proposal` is now canonical and will never be reverted.
- **Subject**: `Finalize { proposal }`
- **Purpose**: Once a proposal is finalized, all preceding proposals in its chain are also implicitly finalized. The application (`Automaton`) can safely execute the payload.
- **Formation**: Aggregate of individual `Finalize` votes.

## Quorum and Safety ($2f+1$)

Simplex operates in a Byzantine Fault Tolerant (BFT) setting where $n = 3f + 1$. 
- A **Quorum** is defined as $2f + 1$ participants.
- The intersection of any two quorums is at least $f + 1$ participants.
- Since at most $f$ participants are Byzantine (malicious), every quorum contains at least one honest participant.

This property ensures that if a certificate is formed, at least one honest participant endorsed it, and no conflicting certificates of the same type can be formed (as that would require at least one honest node to vote for both, violating protocol rules).

## Certificate Construction

Certificates are constructed by the **Batcher** actor:
1.  **Vote Collection**: The Batcher collects individual votes (`Notarize`, `Nullify`, `Finalize`) from the network.
2.  **Signature Verification**: Signatures are verified in batches for performance.
3.  **Aggregation**: Once $2f+1$ valid votes are collected for a specific subject, the Batcher uses the cryptographic `Scheme` (e.g., BLS or Ed25519) to assemble the final `Certificate`.
4.  **Forwarding**: The completed certificate is forwarded to the **Voter** to advance the state machine.

## Domain Separation

To prevent cross-protocol or cross-phase signature reuse, every vote is domain-separated. The `Subject` enum defines how message bytes are derived for each type of vote, incorporating the `Epoch`, `View`, and (where applicable) the `Proposal` digest.

## Storage and Propagation

- **Persistence**: Certificates are stored in the Write-Ahead Log (WAL) to allow recovery after a crash.
- **Backfilling**: Lagging nodes can request missing certificates from peers using the `Backfiller` protocol (Request/Response). This ensures that a node can always synchronize with the latest canonical state.
