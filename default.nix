let
  inherit (builtins.fromJSON (builtins.readFile ./flake.lock)) nodes;

  getFlake =
    name:
    let
      pin = nodes.${name}.locked;
    in
    fetchTarball {
      url = "https://github.com/${pin.owner}/${pin.repo}/archive/${pin.rev}.tar.gz";
      sha256 = pin.narHash;
    };
in

{
  pkgs ? import (getFlake "nixpkgs") { },
  haumea ? import (getFlake "haumea") { },
}:

haumea.load {
  src = ./src;
  inputs = removeAttrs pkgs [
    "root"
    "self"
    "super"
  ];
  loader = haumea.loaders.callPackage;
}
