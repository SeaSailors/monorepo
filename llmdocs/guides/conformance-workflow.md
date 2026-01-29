# Managing Conformance Tests

Conformance tests ensure that changes to your code do not unintentionally break
serialized formats or existing mechanisms.

## Workflow: Adding Conformance to a New Type

Most conformance tests verify the stable encoding of a type using the
`commonware-codec::conformance::CodecConformance` wrapper.

### 1. Requirements
Your type must implement:
- `commonware_codec::Encode`: To generate the bytes to be hashed.
- `arbitrary::Arbitrary`: To generate deterministic test data from a seed.

### 2. Implement Arbitrary
Implement `Arbitrary` for your type, typically gated by the `arbitrary` feature:

```rust
#[cfg(feature = "arbitrary")]
impl<'a> arbitrary::Arbitrary<'a> for MyType {
    fn arbitrary(u: &mut arbitrary::Unstructured<'a>) -> arbitrary::Result<Self> {
        // Construct your type deterministically
        Ok(Self { ... })
    }
}
```

### 3. Add to conformance_tests!
In your `#[cfg(test)]` module (or a submodule), invoke the macro:

```rust
#[cfg(test)]
mod tests {
    #[cfg(feature = "arbitrary")]
    mod conformance {
        use crate::MyType;
        use commonware_codec::conformance::CodecConformance;
        use commonware_conformance::conformance_tests;

        conformance_tests! {
            CodecConformance<MyType>,
        }
    }
}
```

### 4. Generate Initial Hash
Run the test to automatically add the new type to your crate's `conformance.toml`:

```bash
just test-conformance -p <your-crate-name>
```

Verify that `conformance.toml` now contains a new entry. Commit this file with
your changes.

## Workflow: Updating Existing Formats

If you intentionally change a format (e.g., adding a field to a struct), existing
conformance tests will fail.

### 1. Regenerate Hashes
Use the regeneration command to update the `conformance.toml` file with the new
hashes:

```bash
just regenerate-conformance -p <your-crate-name>
```

**WARNING**: This is a manual approval of a breaking change. Verify that the
logic change was intentional before running this.

### 2. Label your PR
Because you modified existing entries in `conformance.toml`, CI will block your
PR unless you add one of the following labels:
- `breaking-format`
- `breaking-api`

## Common Commands

| Task | Command |
| :--- | :--- |
| Run all conformance tests | `just test-conformance` |
| Run for specific crate | `just test-conformance -p <crate>` |
| Update hashes (Breaking) | `just regenerate-conformance` |
| Check for breaking changes | `just test-conformance && git diff --exit-code` |
