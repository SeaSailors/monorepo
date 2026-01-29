# Guide: Implementing Codecs

This guide explains how to implement serialization and deserialization for custom types in Commonware using the `commonware-codec` primitive.

## Overview

Implementing `Codec` for a type involves:
1.  Defining the structure.
2.  Implementing `EncodeSize` to calculate the buffer size.
3.  Implementing `Encode` to write the data.
4.  Implementing `Decode` to read the data safely.
5.  (Optional) Implementing `FixedSize` if the type has a constant length.

## Step 1: Define the Type

Ensure your type derives necessary traits. If you plan to use conformance testing, you should also implement `Arbitrary`.

```rust
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct MyMessage {
    pub id: u64,
    pub payload: Vec<u8>,
}
```

## Step 2: Implement `EncodeSize`

The `encode_size` method must return the exact number of bytes the type will occupy on the wire.

```rust
impl EncodeSize for MyMessage {
    fn encode_size(&self) -> usize {
        // u64 is fixed at 8 bytes
        // payload is length-prefixed (varint) + actual bytes
        8 + varint::len(self.payload.len() as u64) + self.payload.len()
    }
}
```

## Step 3: Implement `Encode`

Use the `Write` trait methods to serialize your data.

```rust
impl Encode for MyMessage {
    fn encode(&self, sink: &mut impl Write) {
        sink.put_u64(self.id);
        sink.put_vec(&self.payload);
    }
}
```

## Step 4: Implement `Decode`

The `decode` method must be `async` and use the `Cfg` from the `Read` trait to enforce limits.

```rust
impl Decode for MyMessage {
    type Cfg = RangeCfg<usize>; // Limit for the payload Vec

    async fn decode(reader: &mut impl Read, cfg: &Self::Cfg) -> Result<Self, Error> {
        let id = reader.get_u64().await?;
        // Decodes a Vec using the provided configuration
        let payload = Vec::<u8>::decode(reader, cfg).await?;
        Ok(Self { id, payload })
    }
}
```

## Best Practices

### Use `FixedSize` where possible
If your type always encodes to the same length (like a public key or a hash), implement `FixedSize`. This allows other types to optimize their own `encode_size` calculations.

```rust
impl FixedSize for MyFixedType {
    const ENCODED_LEN: usize = 32;
}
```

### Choosing Integer Encodings
*   **Use Fixed-Size (`put_u64`)**: For fields where the distribution of values is uniform (e.g., timestamps, IDs, hashes).
*   **Use Varints (`put_varint`)**: For fields where small values are common (e.g., sequence lengths, counts, small enums).

### Propagating Configuration
If your struct contains multiple nested types that require configuration, define a custom `Cfg` struct.

```rust
pub struct MyMessageCfg {
    pub payload_limit: RangeCfg<usize>,
    pub metadata_limit: RangeCfg<usize>,
}

impl Decode for MyComplexMessage {
    type Cfg = MyMessageCfg;
    
    async fn decode(reader: &mut impl Read, cfg: &Self::Cfg) -> Result<Self, Error> {
        let payload = Vec::<u8>::decode(reader, &cfg.payload_limit).await?;
        let metadata = String::decode(reader, &cfg.metadata_limit).await?;
        Ok(Self { payload, metadata })
    }
}
```

## Conformance Testing

Always add a conformance test to ensure your wire format doesn't change accidentally.

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[cfg(feature = "arbitrary")]
    mod conformance {
        use commonware_codec::conformance::CodecConformance;
        commonware_conformance::conformance_tests! {
            CodecConformance<MyMessage>,
        }
    }
}
```
Run `just test-conformance` to generate and verify the wire-format hash.
