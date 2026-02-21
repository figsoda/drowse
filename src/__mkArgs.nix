_:

env: args:

if builtins.isString args then
  {
    load = /* nix */ ''(import (builtins.getEnv "${env}Path"))'';
    value = args;
  }
else
  {
    load = /* nix */ ''(builtins.fromJSON (builtins.readFile (builtins.getEnv "${env}Path")))'';
    value = builtins.toJSON args;
  }
