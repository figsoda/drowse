{
  super,
  lib,
  crate2nix,
  nix,
  path,
  rustPlatform,
  writeText,
}:

lib.extendMkDerivation {
  constructDrv = super.mkDynamicDerivation;

  excludeDrvArgNames = [
    "args"
    "dynamicCargoDeps"
    "select"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      args ? { },
      dynamicCargoDeps ? true,
      select ? "project: project.rootCrate.build",
      ...
    }:
    let
      args' = super.mkArgs "crate2nixArgs" args;
    in
    {
      cargoDeps =
        if dynamicCargoDeps then
          super.callPackage {
            name = "cargo-vendor-dir";
            src = writeText "cargo-deps.nix" /* nix */ ''
              { rustPlatform }:
              rustPlatform.importCargoLock {
                lockFile = "${finalAttrs.src}/Cargo.lock";
              }
            '';
          }
        else
          rustPlatform.importCargoLock {
            lockFile = finalAttrs.src + "/Cargo.lock";
          };

      nativeBuildInputs = [
        crate2nix
        nix
        rustPlatform.cargoSetupHook
      ];

      passAsFile = [
        "crate2nixArgs"
        "crate2nixExpr"
        "crate2nixSelect"
      ];
      crate2nixArgs = args'.value;
      crate2nixExpr = /* nix */ ''
        let
          args = ${args'.load};
          project = import ./Cargo.nix args;
          select = import (builtins.getEnv "crate2nixSelectPath");
          drv = select project;
        in
        (drv.overrideAttrs or (attrs: drv // attrs)) {
          name = "${finalAttrs.passthru.outName}";
        }
      '';
      crate2nixSelect = select;

      env = {
        NIX_PATH = "nixpkgs=${path}";
      };

      buildPhase = ''
        runHook preBuild
        crate2nix generate
        drv=$(nix-instantiate - < "$crate2nixExprPath")
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        install -Dm444 "$drv" "$out"
        runHook postInstall
      '';
    };
}
