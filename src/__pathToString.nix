# avoid copying stuff to the store when possible

{ lib }:

path:

if !lib.isDerivation path && lib.isStorePath path then
  let
    str = toString path;
  in
  builtins.appendContext str {
    ${str}.path = true;
  }
else
  "${path}"
