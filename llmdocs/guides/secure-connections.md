# Establishing Secure Connections

This guide demonstrates how to establish a secure, authenticated connection between two peers using the Stream layer.

## Setup Configuration

Both the dialer and listener must agree on certain configuration parameters to successfully communicate.

```rust
use commonware_stream::Config;
use std::time::Duration;

let config = Config {
    signing_key: my_private_key,
    namespace: b"my_app_namespace".to_vec(),
    max_message_size: 1024 * 1024, // 1MB
    synchrony_bound: Duration::from_secs(5),
    max_handshake_age: Duration::from_secs(30),
    handshake_timeout: Duration::from_secs(10),
};
```

## Listening for Connections

The listener waits for incoming connections and can optionally "bounce" peers based on their public key.

```rust
use commonware_stream::listen;

let (peer_pk, mut sender, mut receiver) = listen(
    context,
    |public_key| async move {
        // Return true to accept, false to reject
        is_authorized(public_key)
    },
    config,
    inbound_stream,
    outbound_sink,
)
.await?;
```

## Dialing a Peer

The dialer initiates a connection to a specific peer's public key.

```rust
use commonware_stream::dial;

let (mut sender, mut receiver) = dial(
    context,
    config,
    target_public_key,
    inbound_stream,
    outbound_sink,
)
.await?;
```

## Sending and Receiving Messages

Once the handshake is complete, use the returned `Sender` and `Receiver` to exchange messages.

```rust
// Sending
sender.send(Bytes::from("Hello, peer!")).await?;

// Receiving
let msg = receiver.recv().await?;
println!("Received: {:?}", msg);
```

## Error Handling

Common errors include:
- `HandshakeTimeout`: Peer did not complete the handshake in time.
- `PeerRejected`: The listener's bouncer function returned `false`.
- `RecvTooLarge`: Peer sent a message exceeding `max_message_size`.
- `HandshakeError`: Cryptographic verification failed.
