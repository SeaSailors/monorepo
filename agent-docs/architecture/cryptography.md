# Cryptography

Commonware provides a suite of cryptographic primitives designed for adversarial environments, emphasizing domain separation, pluggable signature schemes, and secure transcript-based hashing.

## Core Concepts

### Identity
Identity is managed through the `Signer` and `Verifier` traits.
*   **Signer**: Represents a private key capable of signing messages.
*   **Verifier**: Represents a public key capable of verifying signatures.
*   **Public Key**: Must implement `Verifier`, `Encode`, `PartialEq`, and `Array`.

### Domain Separation
To prevent cross-domain attacks (where a signature for one purpose is used for another), all operations in Commonware are namespaced. Namespaces follow the pattern: `_COMMONWARE_<CRATE>_<OPERATION>`.

### Transcripts
The `Transcript` abstraction (based on `blake3`) is the foundation for secure hashing and domain separation.
*   **Commit**: Appends a labeled piece of data to the transcript.
*   **Append**: Appends raw data.
*   **Fork**: Creates a new transcript branching from the current state.
*   **Noise**: Derives secure randomness bound to the transcript's history.

## Signature Schemes
Commonware supports a pluggable `Scheme` system for certificates and attestations.

### Attributable Schemes
These schemes allow identifying the specific signer(s).
*   **Ed25519**: Standard Schnorr signatures on Edwards25519.
*   **Secp256r1**: ECDSA on the NIST P-256 curve.
*   **BLS12-381 (Multisig)**: Supports signature aggregation where the set of signers remains attributable.

### Non-Attributable Schemes
*   **BLS12-381 (Threshold)**: Produces a single constant-size signature that proves a quorum of signers reached consensus without revealing which specific members signed.

## Certificate System
The `Certificate` system facilitates the assembly of threshold or multisig proofs.
*   **Attestation**: A signed statement by a validator.
*   **Quorum**: Defined by `commonware-utils::Faults` (typically 2f+1).
*   **Assembly**: The process of collecting attestations and producing a `Certificate` or `BitVec`-backed aggregate signature.
