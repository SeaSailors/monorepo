# Conformance Specification

This document defines the technical specifications for the Commonware
Conformance System, including the hash algorithm and file format.

## Hash Algorithm

The conformance hash is a SHA-256 digest computed over a sequence of
deterministic commitments.

### Inputs
- `C`: An implementation of the `Conformance` trait.
- `n_cases`: The number of test cases to generate (default: 65,536).

### Procedure
1. Initialize a SHA-256 hasher.
2. For each `seed` in the range `0` to `n_cases - 1` (inclusive):
   - Call `C::commit(seed)` to obtain a byte vector `committed`.
   - Compute `len` as the length of `committed` in bytes.
   - Append `len` as a 64-bit unsigned integer in little-endian format to the
     hasher.
   - Append all bytes of `committed` to the hasher.
3. Finalize the hasher to obtain the 32-byte digest.
4. Encode the digest as a lowercase hex string.

## File Format (conformance.toml)

The `conformance.toml` file is a TOML document storing the mapping from type
identifiers to their corresponding conformance entries.

### Key Format
The key is a stringified type identifier. For tests generated via the
`conformance_tests!` macro, the key follows the pattern:
`<module_path>::<TypeWithoutSpaces>`

Example: `commonware_codec::types::vec::Vec<u8>`

### Entry Schema
Each entry is a table with the following fields:

- `n_cases` (Integer): The number of test cases included in the hash.
- `hash` (String): The hex-encoded SHA-256 digest.

### Example
```toml
["commonware_cryptography::ed25519::PublicKey"]
n_cases = 65536
hash = "7f8e...a1b2"
```

## Conformance Trait Requirements

- **Determinism**: The `commit` function MUST return the same bytes for the same
  seed regardless of the execution environment (OS, CPU architecture, endianness).
- **Independence**: Each call to `commit` for a different seed MUST be
  independent.
- **Async Safety**: The trait uses `Future`, allowing implementations to perform
  asynchronous operations (e.g., simulating a network exchange).
