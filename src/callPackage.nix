{
  super,
  lib,
  nix,
  path,
}:

lib.extendMkDerivation {
  constructDrv = super.mkDynamicDerivation;

  excludeDrvArgNames = [ "args" ];

  extendDrvArgs =
    finalAttrs:
    {
      src,
      args ? { },
      ...
    }:
    let
      args' = super.mkArgs "callPackageArgs" args;
    in
    {
      nativeBuildInputs = [ nix ];

      passAsFile = [
        "callPackageArgs"
        "callPackageExpr"
      ];
      callPackageArgs = args'.value;
      callPackageExpr = /* nix */ ''
        let
          args = ${args'.load};
          drv = (import <nixpkgs> { }).callPackage (builtins.getEnv "src") args;
        in
        (drv.overrideAttrs or (attrs: drv // attrs)) {
          name = "${finalAttrs.passthru.outName}";
        }
      '';

      env = {
        NIX_PATH = "nixpkgs=${path}";
      };

      buildCommand = /* bash */ ''
        drv=$(nix-instantiate - < "$callPackageExprPath")
        install -Dm444 "$drv" "$out"
      '';
    };
}
