{
  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, haumea, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          lib = import ./. {
            inherit pkgs;
            haumea = haumea.lib;
          };
          checks = import ./tests {
            inherit lib pkgs;
            drowse = config.lib;
          };
        };

      transposition.lib.adHoc = true;

      flake.templates = {
        crate2nix = {
          path = ./templates/crate2nix;
          description = "A Cargo package with drowse and crate2nix";
        };
      };
    };
}
