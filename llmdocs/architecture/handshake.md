# Handshake & Stream Protocol

The `commonware-stream` crate implements a secure, mutually authenticated handshake and encrypted transport protocol designed for peer-to-peer communication.

## The Handshake Process
Commonware uses a 3-way handshake (`Syn` -> `SynAck` -> `Ack`) to establish a secure connection.

### 1. Identity Exchange
Peers identify themselves using their static public keys. A `bouncer` function is used by the listener to authorize incoming connections based on their public key.

### 2. Ephemeral Key Exchange
Each peer generates an ephemeral X25519 key pair. These ephemeral keys are used to derive the shared secret for transport encryption, ensuring forward secrecy.

### 3. Transcript Binding
A `Transcript` is used to bind all messages in the handshake. This protects against Man-In-The-Middle (MITM) attacks by ensuring both peers have a consistent view of the entire exchange.
*   The `Syn` message includes the initiator's ephemeral public key.
*   The `SynAck` message includes the responder's ephemeral public key and a signature over the handshake transcript.
*   The `Ack` message includes the initiator's signature over the updated handshake transcript.

### 4. Mutual Authentication
Signatures are generated using the peers' static private keys over the handshake transcript. This proves that the party holding the ephemeral key also holds the static identity key.

## Transport Encryption
Once the handshake is complete, the ephemeral shared secret is used to initialize `ChaCha20-Poly1305` for authenticated encryption of all subsequent stream data.

### Key Derivation
The shared secret is passed through the `Transcript` to derive independent encryption and decryption keys for each direction of the stream.

### Framing
Data is sent in frames. Each frame is encrypted and includes a message authentication code (MAC) to ensure integrity and authenticity.
