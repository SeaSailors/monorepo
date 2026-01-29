# P2P Reference

## Addressing
- **Public Key**: All addresses are cryptographic public keys (e.g., Ed25519, Secp256r1).
- **Ingress**: A combination of `PublicKey` and a multi-address (IP/Port) for bootstrap discovery.

## Wire Format
Commonware uses length-prefixed framing for all P2P messages:
- `Length`: Varint-encoded (UInt).
- `Channel ID`: Varint-encoded (UInt) if multiplexed.
- `Payload`: Opaque bytes (usually encoded via `commonware-codec`).

## Standard Channels
While arbitrary, the following channel patterns are common:
- `0`: Handshake/Discovery.
- `1`: Consensus.
- `2`: State Sync.

## Rate Limiting (Quota)
Rate limits are defined using `commonware-runtime::Quota`:
- `Quota::per_second(N)`: Allow N messages per second with bursting.
- Enforced per-peer, per-channel.

## Multiplexing (Muxer)
The `Muxer` prepends a `Channel` ID to outgoing messages and routes incoming messages to the corresponding `SubReceiver`.
- **Head-of-Line Blocking**: Sub-channels use `try_send`. If a sub-channel's internal buffer is full, incoming messages for that channel are dropped to avoid blocking other sub-channels.
