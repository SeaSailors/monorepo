# Stream Protocol Specification

This document defines the wire format and state machine for the Stream layer.

## Wire Format

All frames are prefixed with a varint length.

### Handshake Frames

1.  **Dialer Identity**: `VarintLen(PublicKey)`
2.  **Syn**: `VarintLen(SynMessage)`
3.  **SynAck**: `VarintLen(SynAckMessage)`
4.  **Ack**: `VarintLen(AckMessage)`

### Data Frames

`VarintLen(Ciphertext)`

Where `Ciphertext` is `ChaCha20Poly1305(Plaintext, Nonce, Key)`.
The `Ciphertext` includes a 16-byte Poly1305 MAC overhead.

## Cryptographic Parameters

- **Key Exchange**: X25519
- **Encryption**: ChaCha20-Poly1305
- **Nonce**: 12 bytes, starting at 0 and incrementing for each message.
- **Transcript**: SHA-256 hash of all previous handshake messages.

## Framing Details

- **Length Prefix**: Encoded as a `commonware-codec::varint`.
- **Maximum Message Size**: Configurable via `max_message_size`. Frames exceeding this limit (plus MAC overhead) are rejected.

## State Machine

### Dialer
1.  **START**: Send identity.
2.  **SYN_SENT**: Send `Syn`.
3.  **SYN_ACK_RECV**: Receive `SynAck`. Verify signature.
4.  **ACK_SENT**: Send `Ack`. Transition to **ESTABLISHED**.

### Listener
1.  **IDENTITY_RECV**: Receive dialer identity. Call bouncer.
2.  **SYN_RECV**: Receive `Syn`.
3.  **SYN_ACK_SENT**: Send `SynAck`.
4.  **ACK_RECV**: Receive `Ack`. Verify signature. Transition to **ESTABLISHED**.

## Security Invariants

- **Namespace Isolation**: The handshake transcript is initialized with a unique namespace to prevent cross-app replay.
- **Timestamp Validation**: `Syn` and `SynAck` include timestamps that must be within `synchrony_bound` of the local clock.
- **Nonce Uniqueness**: Directional counters ensure no nonce is ever reused for the same key.
