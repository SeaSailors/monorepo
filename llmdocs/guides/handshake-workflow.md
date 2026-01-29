# Establishing Secure Connections

This guide demonstrates how to use `commonware-stream` to establish encrypted, mutually authenticated connections between peers.

## Initiating a Connection (Dialer)

To connect to a remote peer, use the `dial` function. You must provide your identity (Signer) and the public key of the peer you wish to connect to.

```rust
use commonware_stream::dial;
use commonware_cryptography::ed25519;

async fn connect_to_peer(context: Context, socket: TcpStream, signer: Signer, peer_public_key: PublicKey) {
    let (mut sender, mut receiver) = dial(
        context,
        socket,
        signer,
        peer_public_key,
    ).await.expect("Handshake failed");

    // Send and receive encrypted messages
    sender.send(b"Hello!").await.unwrap();
    let msg = receiver.recv().await.unwrap();
}
```

## Accepting Connections (Listener)

To accept connections, use the `listen` function. You must provide your identity and a `bouncer` function to authorize incoming public keys.

```rust
use commonware_stream::listen;

fn bouncer(public_key: PublicKey) -> bool {
    // Implement authorization logic (e.g., check against a whitelist)
    is_authorized(public_key)
}

async fn handle_incoming(context: Context, socket: TcpStream, signer: Signer) {
    let (mut sender, mut receiver, peer_public_key) = listen(
        context,
        socket,
        signer,
        bouncer,
    ).await.expect("Handshake failed");

    println!("Connected to authorized peer: {:?}", peer_public_key);
}
```

## Key Considerations

### Bouncer Implementation
The `bouncer` is critical for security in adversarial environments. It should only return `true` for public keys that are part of the active validator set or otherwise authorized to communicate.

### Context Management
The handshake is an asynchronous process. Use the `Context` to manage timeouts and cancellation. If the handshake takes too long (e.g., due to a malicious peer), the context will ensure resources are reclaimed.

### Error Handling
The `dial` and `listen` functions return errors if the handshake fails (e.g., signature mismatch, transcript inconsistency, or unauthorized identity). Applications should handle these errors by closing the underlying connection.
