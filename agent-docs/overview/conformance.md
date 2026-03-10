# Conformance System Overview

The Commonware Conformance System is a suite of tools and conventions used to
automatically assert the stability of encodings, data structures, and protocol
mechanisms over time.

## Why Conformance?

In distributed systems, particularly those operating in adversarial or
decentralized environments, maintaining backward compatibility is critical.
A small change in how a message is serialized or how a cryptographic transcript
is generated can lead to network partitions, fork failures, or security
vulnerabilities.

The Conformance System provides a "living" specification of all stable formats
in the repository, enforced by the CI pipeline.

## How it Works

1. **Commit**: Types implement the `Conformance` trait to produce a deterministic
   byte representation (commitment) for a given seed.
2. **Snapshot**: These commitments are hashed together across thousands of
   generated cases and stored as SHA-256 digests in `conformance.toml` files.
3. **Verify**: Every PR runs these tests. If the code changes such that the
   commitment for a seed changes, the hash will mismatch and the test will fail.
4. **Govern**: Breaking changes (modifying existing hashes) are protected by
   GitHub labels, ensuring they receive appropriate scrutiny during review.

## Key Primitives

* **`commonware-conformance`**: The core library providing the `Conformance` trait
  and the testing harness.
* **`commonware-conformance-macros`**: Procedural macros (`conformance_tests!`) to
  simplify adding tests.
* **`conformance.toml`**: Per-crate fixture files containing the ground-truth
  hashes.
