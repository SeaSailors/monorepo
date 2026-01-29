# Simplex Safety & Blocker Mechanism

The Simplex consensus protocol ensures BFT safety (consistency and liveness) through rigorous parent chain verification, equivocation detection, and a reputation-based network blocker.

## Parent Chain Verification

Every proposal in Simplex must build upon a valid chain of certificates. When a leader proposes a new block, or when a validator verifies a proposal, they must ensure the "parent" reference is valid.

### Finding a Valid Parent
When the `Voter` prepares to propose (via `find_parent`), it identifies the most recent certified payload by:
1. Looking at the immediate previous view ($V-1$).
2. If $V-1$ is **certified** (notarized or finalized), its payload is the parent.
3. If $V-1$ was **nullified**, the `Voter` skips it and checks $V-2$.
4. This "walk back" continues until a certified payload is found. If a view is encountered that is neither certified nor nullified, the node has a "gap" in its chain and cannot propose until it syncs.

### Verification Rules
The `parent_payload` function in `state.rs` enforces strict invariants on any incoming proposal:
*   **Monotonicity:** The parent view must be strictly less than the proposal view.
*   **Finality Respect:** The parent view must be greater than or equal to the node's `last_finalized` view.
*   **Continuity:** All views between the claimed `parent` and the current `proposal.view` **must** have valid `Nullification` certificates. This proves that the network explicitly skipped those views.
*   **Certification:** The claimed parent must have a valid `Notarization` or `Finalization` certificate.

## Equivocation Detection

Equivocation occurs when a leader signs two different proposals for the same view. Simplex detects this in the `Slot` state of a `Round`.

### Detection Logic
1.  **Proposal Arrival:** When a node receives a proposal, it stores it in a `Slot`.
2.  **Conflict Check:** If a second proposal arrives for the same view with a different payload hash:
    *   If the new proposal is "recovered" (arrives via a Quorum Certificate), it **overrides** the existing proposal because $2f+1$ nodes have already agreed on it.
    *   The `Slot` status is set to `Equivocated`.
3.  **Vote Suppression:** Once a slot is marked `Equivocated`, the node **refuses to vote** (Notarize or Finalize) for any proposal in that view. This prevents the local node from contributing to a potentially malicious fork.

## The Blocker Mechanism

The `Batcher` acts as a firewall for the `Voter`. It uses a `Blocker` trait (provided by the P2P layer) to disconnect and ban peers that violate protocol rules.

### Triggering a Block
The `Batcher` calls `blocker.block(peer)` when:
*   **Signature Failure:** A peer sends a vote or certificate with a signature that fails cryptographic verification.
*   **Protocol Malice:** A peer sends a certificate for a view that doesn't match the current `Epoch`.
*   **Mangled Data:** A peer sends messages that fail to decode or violate the `codec` constraints.
*   **Equivocation Evidence:** If the `Batcher` identifies a leader signing conflicting payloads, the reporter identifies the peer for blocking.

By blocking at the P2P layer, Simplex ensures that malicious or buggy nodes cannot consume CPU cycles for signature verification or clog the `Batcher`'s ingress channels.

## Safety Invariants

Simplex enforces core BFT invariants within the `Round` state machine to prevent double-voting:

1.  **Notarize vs. Nullify:** A node cannot vote to `Notarize` a proposal if it has already voted to `Nullify` the view (and vice versa).
2.  **Finalize vs. Nullify:** A node cannot vote to `Finalize` a proposal if it has already voted to `Nullify` the view.
3.  **Nullify vs. Finalize:** If a node has already broadcast a `Finalize` vote, it is prohibited from constructing a `Nullify` vote for that view (`construct_nullify` returns `None`).
4.  **Certification Required:** A node will not vote to `Finalize` a proposal unless it has first **Certified** the notarization (notifying the application automaton) and verified the notarization has quorum.

These checks ensure that even if a leader is malicious, an honest quorum cannot be coerced into certifying conflicting states for the same view.
