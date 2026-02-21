{
  lib,
  runCommand,
  stdenvNoCC,
}:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  extendDrvArgs =
    finalAttrs: args:

    assert
      args ? name && (args ? pname || args ? version) -> throw "name cannot be set with pname or version";

    assert
      (args ? pname) != (args ? version)
      -> throw "either both or none of pname and version have to be set";

    let
      name =
        if args ? name then
          args.name
        else if args ? pname && args ? version then
          "${args.pname}-${args.version}"
        else
          "drowsy-derivation";
    in

    {
      name = "${name}.drv";
      __contentAddressed = true;
      outputHashAlgo = "sha256";
      outputHashMode = "text";
      requiredSystemFeatures = [ "recursive-nix" ];
      passthru.outName = name;
    };

  transformDrv =
    drv:
    let
      args = {
        passthru = { inherit drv; };
      }
      // lib.optionalAttrs (drv ? pname && drv ? version) {
        inherit (drv) pname version;
      };
    in
    runCommand drv.outName args ''
      ln -s ${builtins.outputOf "${drv}" "out"} "$out"
    '';
}
