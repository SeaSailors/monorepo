# Codec & Formats Architecture

Commonware provides a robust, safety-first serialization framework designed for adversarial environments. The `commonware-codec` primitive is the foundation for all wire formats, ensuring that data can be safely exchanged between peers with different architectures and varying levels of trust.

## Design Philosophy

1.  **Hardened by Design**: All decoding operations are configuration-driven, enforcing strict limits on memory allocation and processing time for untrusted inputs.
2.  **Architecture Agnostic**: All fixed-size integers use Big-Endian encoding. `usize` is restricted to `u32` bounds on the wire to ensure 32-bit/64-bit compatibility.
3.  **Stability First**: Wire formats are locked using the `conformance` crate, which hashes encoded outputs to detect breaking changes.
4.  **Trait-Oriented**: A hierarchy of traits (`Write`, `Read`, `Encode`, `Decode`) allows for flexible yet type-safe serialization.

## Trait Hierarchy

### Core Serialization Traits

*   **`Write`**: An abstraction over a destination buffer. It provides methods for writing primitives (fixed and varint).
*   **`Read`**: An abstraction over a source buffer. Crucially, it defines a `Cfg` associated type, enabling "Config-Driven Decoding."
*   **`Encode`**: Implemented by types that can be serialized. It requires `encode_size` to be known upfront, enabling single-allocation serialization.
*   **`Decode`**: Implemented by types that can be deserialized. It uses the `Cfg` from the `Read` trait to enforce limits during reconstruction.

### Specialization Traits

*   **`EncodeSize`**: Provides the size of the encoded data.
*   **`FixedSize`**: A marker trait for types that always have the same encoded length (e.g., cryptographic keys).
*   **`Codec`**: A convenience trait that combines `Encode`, `Decode`, and `EncodeSize`.

## Hardening Mechanism: Config-Driven Decoding

To prevent memory exhaustion attacks (e.g., sending a `Vec` header with a massive length), `commonware-codec` employs `Cfg` propagation.

### `RangeCfg<T>`
Types like `Vec<T>`, `Bytes`, and `String` require a `RangeCfg` during decoding. This configuration specifies the `min` and `max` allowable elements/bytes.

```rust
// Example: Decoding a Vec of u64 with a limit of 100 elements
let cfg = RangeCfg::<usize>::new(0, 100);
let my_vec = Vec::<u64>::decode(&mut reader, &cfg).await?;
```

### Decoupled Verification
The `Read` trait includes `at_least(n)` checks, ensuring the underlying buffer contains enough data before attempting a decode, preventing "partial read" state machines from being exploited.

## Integer Encoding

### Fixed-Size
All fixed-size integers (`u8` through `u128`, and signed equivalents) are encoded as **Big-Endian**.

### Variable-Length (Varints)
Commonware uses Google Protocol Buffers-style varints (Base-128) to save space for small values.
*   **Unsigned**: LEB128 encoding.
*   **Signed**: ZigZag encoding (mapping signed values to unsigned) followed by LEB128.
*   **`usize`**: Always encoded as a `u32` varint. This enforces a 4GB limit on sequences and ensures portability.

## Stability and Conformance

To prevent accidental breaking changes to wire formats, types are wrapped in `CodecConformance<T>` and tested in the `conformance` crate. This process:
1.  Generates deterministic instances using `Arbitrary`.
2.  Encodes them and hashes the resulting bytes.
3.  Compares the hash against a stored value in `conformance.toml`.

## Interaction Points

*   **`cryptography`**: Public keys and signatures implement `FixedSize`, ensuring they can be embedded directly in larger structures with constant offsets.
*   **`stream`**: Uses `codec` for framing (u32 BE length prefix) and handshake message serialization.
*   **`p2p`**: Leverages `codec` for all protocol-level messages, ensuring peers can negotiate capabilities and exchange data safely.
