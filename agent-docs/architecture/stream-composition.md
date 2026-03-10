# Stream Composition

The Stream layer is designed to be runtime-agnostic and composable with other Commonware primitives.

## Runtime Integration

The `stream` crate depends on the `commonware-runtime` traits rather than a specific implementation.

- **Transport**: Operates on types implementing `commonware_runtime::Stream` and `commonware_runtime::Sink`. This allows it to work over TCP (Tokio), io_uring, or in-memory channels for testing.
- **Time**: Uses `commonware_runtime::Clock` to enforce handshake timeouts and validate message timestamps within the `synchrony_bound`.
- **RNG**: Handshake ephemeral key generation requires `rand_core::CryptoRngCore`.

## Cryptography Composition

Stream relies heavily on `commonware-cryptography`:

- **Identities**: Uses `Signer` and `PublicKey` for peer identification and authentication.
- **Handshake Logic**: Wraps the lower-level `commonware_cryptography::handshake` modules (`dial_start`, `dial_end`, `listen_start`, `listen_end`).
- **Transcripts**: Uses `Transcript` for domain separation and binding keys to the session state.

## Layering in the Monorepo

```
+-----------------------------------+
|      High-Level Application       |
+-----------------------------------+
|           P2P Overlay             |
+-----------------------------------+
|         Stream (Encrypted)        |  <-- commonware-stream
+-----------------------------------+
|        Runtime (Network)          |
+-----------------------------------+
```

1.  **Runtime** provides the raw byte-stream (e.g., a TCP socket).
2.  **Stream** upgrades this to an authenticated, encrypted, and framed channel.
3.  **P2P** uses these streams to manage connections to many peers, offering higher-level abstractions like identity-based addressing and rate limiting.
