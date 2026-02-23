{
  super,
  lib,
  nix,
}:

lib.extendMkDerivation {
  constructDrv = super.mkDynamicDerivation;

  excludeDrvArgNames = [
    "expr"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      expr,
      nativeBuildInputs ? [ ],
      passAsFile ? [ ],
      ...
    }:
    {
      nativeBuildInputs = nativeBuildInputs ++ [
        nix
      ];

      passAsFile = passAsFile ++ [
        "instantiateExpr"
      ];
      instantiateExpr = expr;

      buildPhase = ''
        runHook preBuild
        drv=$(nix-instantiate - < "$instantiateExprPath")
        install -Dm444 "$drv" "$out"
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        install -Dm444 "$drv" "$out"
        runHook postInstall
      '';
    };
}
