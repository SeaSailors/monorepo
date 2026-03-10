# Implementing P2P Protocols

This guide covers how to build a new protocol or "primitive" that communicates over the Commonware P2P layer.

## 1. Define Message Types
Protocol messages should implement `commonware-codec` traits for stable, length-prefixed serialization.

```rust
#[derive(Encode, Decode)]
struct MyMessage {
    payload: Vec<u8>,
}
```

## 2. Initialize the Substrate
Use the `Muxer` to create isolated sub-channels for your protocol. This prevents different protocols (e.g., Consensus vs. Sync) from interfering with each other's message flow.

```rust
let (mux, mut handle) = Muxer::new(context, sender, receiver, mailbox_size);
mux.start();

// Register a dedicated channel
let (mut sub_tx, mut sub_rx) = handle.register(MY_PROTOCOL_CHANNEL).await.unwrap();
```

## 3. Handle Communication
Protocols should be implemented as actors that loop over incoming messages.

```rust
loop {
    select! {
        message = sub_rx.recv() => {
            let (from, bytes) = message?;
            // Handle protocol logic
        }
        _ = context.sleep(Duration::from_secs(1)) => {
            // Heartbeat / Periodic tasks
            sub_tx.send(Recipients::All, heartbeat_bytes, false).await?;
        }
    }
}
```

## 4. Applying Rate Limits
If your protocol is high-bandwidth, wrap the sender in a `LimitedSender`.

```rust
// Use CheckedSender to filter recipients who are over their limit
match sub_tx.check(Recipients::All).await {
    Ok(checked) => {
        checked.send(large_payload, false).await?;
    }
    Err(retry_at) => {
        // Handle backpressure
    }
}
```

## 5. Peer Discovery & Membership
Integrate with the `Manager` trait to stay updated on the current "active" peer set. Your actor should subscribe to the manager to handle node rotation gracefully.
