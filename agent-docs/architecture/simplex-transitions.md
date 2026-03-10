# Simplex View Transitions and Timeouts

This document describes how the Simplex consensus protocol manages view advancement, handles network delays via timeouts, and ensures liveness through retry mechanisms.

## View Advancement

In Simplex, the network progresses through a sequence of **Views**. Each view has a designated leader (elected from the participant set). A node advances its local view state under the following conditions:

1.  **Certification Success**: When a node is the leader and successfully certifies its proposal (via the `Automaton` interface), it advances to `view + 1`.
2.  **Observed Finalization/Nullification**: If a node receives a `Finalization` or `Nullification` certificate for its current view, it immediately enters `view + 1`.
3.  **Observed Notarization**: If a node receives a `Notarization` certificate, it prepares the leader for `view + 1`. If the node is not the proposer or if the proposal is already certified, it may advance.

The `Voter` actor manages this state in `State::enter_view(view)`. Entering a new view resets the leader and advance deadlines.

## Protocol Timeouts

Simplex uses three primary timeouts to ensure progress in the face of slow leaders or network partitions:

### 1. Leader Timeout (`leader_timeout`)
This timeout triggers if the designated leader of the current view fails to produce a valid proposal within the configured duration. 
- **Effect**: If the timeout expires before a proposal is received and verified, the node casts a `Nullify` vote for the current view.
- **Optimization**: This timeout can be skipped if the leader is known to be inactive (see [Leader Inactivity](#leader-inactivity)).

### 2. Notarization Timeout (`notarization_timeout`)
Even if a leader proposes, the network might fail to reach a quorum for notarization (e.g., due to equivocation or network issues).
- **Effect**: If notarization is not achieved within this window, the node casts a `Nullify` vote.

### 3. Nullify Retry (`nullify_retry`)
Once a node has voted to `Nullify` a view, it enters a retry state.
- **Effect**: If the node does not observe a certificate (Notarization, Nullification, or Finalization) to exit the view, it will rebroadcast its `Nullify` vote after every `nullify_retry` interval (typically with exponential backoff).
- **Convergence**: During retries, nodes also attach an "entry certificate" for the *previous* view. This helps lagging peers catch up to the current view so they can also cast `Nullify` votes, facilitating the formation of a `Nullification` quorum.

## Leader Inactivity

To minimize latency when leaders are known to be offline, Simplex implements a "Leader Inactivity" check within the `Batcher`.

- **Mechanism**: The `Batcher` tracks the participation of leaders over a sliding window of `skip_timeout` views.
- **Heuristic**: If a leader has not participated (signed any votes or certificates) in the last `N` views, the `Batcher` notifies the `Voter` that the leader is "inactive."
- **Result**: The `Voter` skips the `leader_timeout` and immediately votes to `Nullify` the view, effectively skipping the offline leader without waiting.

## View Transition Logic Flow

1.  **Start View**: Set `leader_deadline` and `advance_deadline`.
2.  **Proposal Received**: If a valid proposal arrives, clear `leader_deadline`.
3.  **Timeout**: If either deadline expires, cast `Nullify` vote.
4.  **Retry**: If stuck in `Nullify` state, periodically rebroadcast `Nullify` + entry certificate for `view - 1`.
5.  **Certificate Arrival**:
    - **Notarization**: If the node is not waiting on certification, prepare for `view + 1`.
    - **Nullification**: Advance to `view + 1`.
    - **Finalization**: Advance to `view + 1` and update `last_finalized`.

## Persistence

Every view transition and vote cast is recorded in the Write-Ahead Log (WAL). Upon restart, the `Voter` replays these artifacts to restore its exact position in the view transition state machine, ensuring that it never double-votes or forgets its progress toward a quorum.
