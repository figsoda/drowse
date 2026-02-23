{
  super,
  lib,
  path,
}:

lib.extendMkDerivation {
  constructDrv = super.instantiate;

  excludeDrvArgNames = [
    "args"
    "src"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      src,
      args ? { },
      passAsFile ? [ ],
      env ? { },
      ...
    }:
    let
      args' = super.mkArgs "callPackageArgs" args;
    in
    {
      passAsFile = passAsFile ++ [ "callPackageArgs" ];
      callPackageSrc = src;
      callPackageArgs = args'.value;

      expr = /* nix */ ''
        let
          args = ${args'.load};
          drv = (import <nixpkgs> { }).callPackage (builtins.getEnv "callPackageSrc") args;
        in
        (drv.overrideAttrs or (attrs: drv // attrs)) {
          name = "${finalAttrs.passthru.outName}";
        }
      '';

      env = {
        NIX_PATH = "nixpkgs=${path}";
      }
      // env;

      dontUnpack = true;
    };
}
