{
  description = "Commonware Rust workspace dev shell (build examples)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          (import rust-overlay)
        ];

        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # Matches `[workspace.package] rust-version` in Cargo.toml
        rustToolchain = pkgs.rust-bin.stable."1.91.1".default;

        # Common native dependencies for building Rust crates in this repo and examples.
        nativeTools = with pkgs; [
          pkg-config
          clang
          llvmPackages.libclang
          protobuf
        ];

        libs = with pkgs; [
          openssl
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            rustToolchain
          ] ++ nativeTools ++ libs;

          # Ensure libclang is discoverable for bindgen-based crates.
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

          shellHook = ''
            echo "Commonware dev shell"
            echo "- Rust: $(rustc --version)"
            echo "Try: cargo build -p bridge (or any crate in examples/)"
          '';
        };
      }
    );
}
