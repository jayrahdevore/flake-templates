# Nix flake template, adapted from https://github.com/nix-community/naersk templates and documentation
{
  description = "Nix flake for rust using cargo";
  inputs = {
    fenix.url = "github:nix-community/fenix";
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    naersk,
    fenix,
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = (import nixpkgs) {inherit system;};

      toolchain = with fenix.packages.${system};
        combine [
          default.rustc
          default.cargo
          default.clippy
          targets.x86_64-unknown-linux-musl.latest.rust-std
          targets.x86_64-unknown-linux-gnu.latest.rust-std
        ];

      naersk' = naersk.lib.${system}.override {
        cargo = toolchain;
        rustc = toolchain;
        clippy = toolchain;
      };

      naerskBuildPackage = target: args:
        naersk'.buildPackage
        (args // {CARGO_BUILD_TARGET = target;} // cargoConfig);

      # All of the CARGO_* configurations which should be used for all
      # targets.
      #
      # Only use this for options which should be universally applied or which
      # can be applied to a specific target triple.
      #
      # This is also merged into the devShell.
      cargoConfig = {
        # Tells Cargo to enable static compilation.
        # (https://doc.rust-lang.org/cargo/reference/config.html#targettriplerustflags)
        #
        # Note that the resulting binary might still be considered dynamically
        # linked by ldd, but that's just because the binary might have
        # position-independent-execution enabled.
        # (see: https://github.com/rust-lang/rust/issues/79624#issuecomment-737415388)
        CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS = "-C target-feature=+crt-static";
      };
    in rec {
      packages.default = packages.x86_64-unknown-linux-gnu;

      packages.x86_64-unknown-linux-musl = naerskBuildPackage "x86_64-unknown-linux-musl" {
        src = ./.;
        doCheck = true;
        nativeBuildInputs = [];
      };

      packages.x86_64-unknown-linux-gnu = naerskBuildPackage "x86_64-unknown-linux-gnu" {
        src = ./.;
        doCheck = true;
        nativeBuildInputs = with pkgs; [
          pkgsStatic.stdenv.cc
        ];
      };

      devShells.default = pkgs.mkShell ({
          inputsFrom = [packages.default];
          nativeBuildInputs = with pkgs; [rust-analyzer toolchain];
          CARGO_BUILD_TARGET = packages.default.CARGO_BUILD_TARGET;
        }
        // cargoConfig);
    });
}
