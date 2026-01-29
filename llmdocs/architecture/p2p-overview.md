# P2P & Networking

Commonware provides a robust, identity-addressed peer-to-peer networking layer designed for adversarial environments. It leverages cryptographic identities, authenticated/encrypted streams, and an abstract runtime to remain portable and testable.

## Core Concepts

### Identity-Based Addressing
In Commonware, every peer is identified by their `PublicKey`. This identity is verified during the connection handshake (via `commonware-stream`) and is persistent across sessions.

### Substrate Trait Architecture
Higher-level primitives interact with the network through a set of traits defined in `commonware-p2p`:
- `Sender`: Sends messages to a set of `Recipients` (`All`, `Some`, `One`).
- `Receiver`: Receives messages from any authenticated peer.
- `Manager`: Manages sets of peers, typically aligned with consensus epochs.
- `Blocker`: Provides identity-based filtering and disconnection.

### The Supervision Tree
The P2P layer is built using the `commonware-runtime` supervision model. Every actor (dialer, listener, peer router) is a task in the tree. If a parent primitive (e.g., Consensus) shuts down, its networking substrate is automatically and gracefully terminated.

## Networking Stack

The stack is composed of several layers:
1. **Transport**: Abstracted by `commonware-runtime`.
2. **Stream**: Handshake and encryption (ChaCha20-Poly1305) provided by `commonware-stream`.
3. **P2P Layer**: Authenticated messaging and peer management.
4. **Utilities**: Multiplexing, rate limiting, and message framing.

## Runtime Integration
The networking layer uses the `Network` trait from `commonware-runtime` to perform I/O. This allows the same code to run:
- **In Production**: Using the `tokio` dialect (standard TCP/IP or Linux-optimized `io_uring`).
- **In Tests**: Using the `deterministic` dialect with in-memory channels and simulated network conditions.
