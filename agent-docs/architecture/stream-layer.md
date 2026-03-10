# Stream Layer Architecture

The Stream layer provides an authenticated and encrypted communication channel over an arbitrary transport. It ensures that peers can securely exchange framed messages while maintaining mutual authentication and forward secrecy.

## Overview

The Stream layer sits between the raw transport (provided by the Runtime) and higher-level messaging protocols (like P2P). It handles:

1.  **Mutual Authentication**: Proven via cryptographic signatures during the handshake.
2.  **Encryption**: All post-handshake traffic uses ChaCha20-Poly1305.
3.  **Framing**: Messages are length-prefixed with varints to preserve boundaries.
4.  **Forward Secrecy**: Ephemeral X25519 keys ensure past sessions remain secure even if static keys are compromised.

## Core Components

### Handshake
The handshake establishes a shared secret and confirms identities. It is integrated with `commonware-cryptography::handshake` and bound to an application-specific namespace.

- **Dialer**: Initiates the connection, providing its public key first.
- **Listener**: Accepts connections, with an optional "bouncer" function to reject unauthorized peers early.
- **Transcript Binding**: The shared secret is bound to the handshake transcript to prevent MitM and substitution attacks.

### Encryption & Rekeying
- **Cipher**: ChaCha20-Poly1305 with 12-byte nonces.
- **Nonce Management**: Derived from a counter incremented per message. This saves bandwidth by not transmitting nonces.
- **Overflow Protection**: The connection terminates if the counter overflows (though this is practically impossible given its size).

### Framing
- **Varint Prefix**: Each message (and handshake frame) is prefixed with its length encoded as a varint.
- **Limits**: `max_message_size` is enforced to prevent memory-exhaustion DoS.

## Data Flow

1.  **Handshake**: `dial` or `listen` is called with a `Stream` and `Sink`.
2.  **Establishment**: Ephemeral keys are exchanged, signatures verified, and ciphers initialized.
3.  **Encrypted Stream**: The handshake returns a `Sender` and `Receiver`.
4.  **Messaging**:
    - `Sender::send`: Encrypts the payload, adds the overhead, and sends the frame.
    - `Receiver::recv`: Reads the frame, decrypts the payload, and returns the original bytes.
