# How to Add a Codec Conformance Test for a New Type

Add a conformance test when a codec type needs a stable encoded form checked against the crate's `conformance.toml`.

1. **Make the type generatable.** Confirm the type implements `arbitrary::Arbitrary` under `#[cfg(feature = "arbitrary")]` or can derive values through an existing wrapper (`codec/src/conformance.rs:1-92`).
2. **Reuse the codec adapter.** Import `crate::conformance::CodecConformance` in the type's test module, following the pattern in `codec/src/types/primitives.rs:520-588` and `codec/src/types/btree_map.rs:239-252`.
3. **Add a `conformance` test module.** Create or extend `#[cfg(feature = "arbitrary")] mod conformance` and call `commonware_conformance::conformance_tests! { ... }` with `CodecConformance<YourType>`.
4. **Choose the case count only when needed.** Omit `=> n_cases` to use the default from `commonware_conformance::DEFAULT_CASES`; specify a smaller number only for intentionally bounded coverage (`conformance/macros/src/lib.rs:94-152`).
5. **Run the verification target.** Execute `just test-conformance -p commonware-codec` to compare the generated digest against the committed fixture (`justfile:103-108`).
6. **Regenerate only for intentional format changes.** If the encoding change is expected, run `RUSTFLAGS="--cfg generate_conformance_tests" just test-conformance -p commonware-codec`, then rerun the test command to confirm the new hash is stable (`conformance/src/lib.rs:1-228`).
