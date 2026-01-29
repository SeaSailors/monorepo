# Wire Formats

This document specifies the wire formats for low-level Commonware primitives, ensuring interoperability and stability.

## Fundamental Types

### Fixed-Size Integers
All fixed-size integers are encoded as **Big-Endian**.

| Type | Length (Bytes) |
| :--- | :--- |
| u8 / i8 | 1 |
| u16 / i16 | 2 |
| u32 / i32 | 4 |
| u64 / i64 | 8 |
| u128 / i128 | 16 |

### Variable-Length Integers (Varints)
Commonware uses Base-128 varint encoding (similar to Protocol Buffers).

#### Unsigned Varints (u64, usize)
The value is split into 7-bit chunks. Each chunk is stored in a byte, with the most significant bit (MSB) set to 1 if there are more bytes to follow.
*   **Note**: `usize` is always encoded as a `u32` varint (max 5 bytes).

#### Signed Varints (i64)
Signed values are mapped to unsigned values using **ZigZag encoding** before being stored as varints:
`unsigned = (signed << 1) ^ (signed >> 63)`

| Signed | Unsigned (ZigZag) |
| :--- | :--- |
| 0 | 0 |
| -1 | 1 |
| 1 | 2 |
| -2 | 3 |
| 2 | 4 |

## Sequences and Collections

### Vec<T> / Bytes / String
Sequences are encoded as a length prefix (Unsigned Varint) followed by the concatenated encoded elements.

| Field | Type | Description |
| :--- | :--- | :--- |
| Length | Varint (u32) | Number of elements (for Vec) or bytes (for Bytes/String) |
| Elements | T[] | The actual data |

## Transcript Framing
The `Transcript` uses length-prefixing for committed data to ensure that `append(A) + append(B)` is distinguishable from `append(AB)`.

| Field | Type | Description |
| :--- | :--- | :--- |
| Length | Varint (u64) | Length of the subsequent data |
| Data | Bytes | The actual data bytes |

## Handshake Messages
Handshake messages are exchanged during the establishment of a `stream`.

### Syn (Initiator -> Responder)
| Field | Type | Description |
| :--- | :--- | :--- |
| Public Key | Bytes | Static public key of initiator |
| Ephemeral Key | Bytes | Ephemeral X25519 public key |

### SynAck (Responder -> Initiator)
| Field | Type | Description |
| :--- | :--- | :--- |
| Public Key | Bytes | Static public key of responder |
| Ephemeral Key | Bytes | Ephemeral X25519 public key |
| Signature | Bytes | Signature over current transcript |

### Ack (Initiator -> Responder)
| Field | Type | Description |
| :--- | :--- | :--- |
| Signature | Bytes | Signature over updated transcript |

## Stream Frames
Once the handshake is complete, data is sent in encrypted frames.

| Field | Type | Description |
| :--- | :--- | :--- |
| Length | u32 (Big Endian) | Length of the encrypted payload |
| Payload | Bytes | ChaCha20-Poly1305 encrypted data |
| Tag | Bytes (16) | Poly1305 authentication tag |

### Maximum Message Size
The maximum size of a single stream frame is typically configured by the application but defaults to 1MB to prevent memory exhaustion attacks.
