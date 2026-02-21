{
  inputs = {
    drowse = {
      url = "github:figsoda/drowse";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ drowse, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        {
          lib,
          system,
          ...
        }:
        let
          fs = lib.fileset;
          manifest = lib.importTOML ./Cargo.toml;
        in
        {
          packages.default = drowse.lib.${system}.crate2nix {
            pname = manifest.package.name;
            inherit (manifest.package) version;
            src = fs.toSource {
              root = ./.;
              fileset = fs.unions [
                ./Cargo.lock
                ./Cargo.toml
                ./src
                (fs.maybeMissing ./build.rs)
              ];
            };
          };
        };
    };
}
