# drowse

A thin wrapper around dynamic derivations to make it easier to use

## Why

Tools like [crate2nix] allow for the fine-grain caching of dependencies.
However they rely on either import-from-derivation (IFD),
which nukes the evaluation time by sequentializing the process,
or code generation, which clutters git history, and still might have negative
impact on evaluation time due to how big some generated files are.

Dynamic derivations is an experimental feature of Nix that allows you to
get the best of both worlds: fine-grained caching without IFD or code generation.
Drowse aims to reduce the boilerplate that dynamic derivations require,
and integrates with tools like [crate2nix] to provide a mkDerivation-like experience.

## Usage

The following experimental features need to be enabled:
`ca-derivations`, `dynamic-derivations`, `recursive-nix`.

The easiest way to use drowse is as a flake

```nix
{
  inputs.drowse.url = "github:figsoda/drowse";
}
```

The following functions will be available under `drowse.lib.${system}`.
You can also import the same functions from [default.nix](default.nix) without flakes.

### callPackage

Type (finalAttrs-compatible):

```nix
{
  src, # path to the Nix file
  args ? { }, # arguments passed to pkgs.callPackage
  ...
} -> derivation
```

Roughly equivalent to `pkgs.callPackage src args`,
but contents of `src` are only evaluated at build time.
It is also recommended to a specify `name`, or `pname` and `version`,
that is the same as the ones provided in `src`.

```nix
drowse.callPackage {
  pname = "hello";
  version = "2.12.2";
  src = ./hello.nix;
  args.withFoo = true; # or
  # args = "{ withFoo = true; }"
};

# hello.nix
{
  lib,
  stdenv,
  withFoo ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hello";
  version = "2.12.2";
  src = <...>;
  postInstall = lib.optionalString withFoo <...>;
})
# hello.nix
```

### crate2nix

You can create a Rust project with drowse and [crate2nix] with the provided template:

```bash
nix flake init -t github:figsoda/drowse#crate2nix
```

Type (finalAttrs-compatible):

```nix
{
  src,
  args ? { }, # arguments passed to import ./Cargo.nix
  dynamicCargoDeps ? true, # wrap cargoDeps in a dynamic derivation
  select ? "project: project.rootCrate.build",
  ...
} -> derivation
```

Similar to [crate2nix]'s `appliedCargoNix`, but without the need for IFD.

```nix
drowse.crate2nix {
  pname = "hello";
  version = "0.1.0";

  src = ./.; # filter with lib.fileset to reduce rebuilds
  # src = fetchFromGitHub <...> # this can also be fetched

  args.rootFeatures = [ "fancy" ]; # or
  # args = ''{ rootFeatures = [ "fancy" ]; }'';

  select = ''
    project: project.rootCrate.build.override { features = [ "fancy" ]; }
  '';
};
```

### mkDynamicDerivation

A lower level wrapper around the regular `mkDerivation` for building dynamic derivations

```nix
drowse.mkDynamicDerivation {
  pname = "nix-init";
  version = "0.3.3";

  nativeBuildInputs = [ nix ];
  env.NIX_PATH = "nixpkgs=${path}";

  buildCommand = ''
    drv=$(nix-instantiate --expr "(import <nixpkgs> { }).nix-init")
    install -Dm444 "$drv" "$out"
  '';
}
```

## Resources

Dynamic derivations is a rather experimental and undocumented feature of Nix.
These resources have helped me a lot learning about this feature,
and it might be helpful for you too if you run into issues with drowse,
or if you just want to learn more about dynamic derivations.

- [nix-ninja's introduction to dynamic derivations](https://github.com/pdtpartners/nix-ninja/blob/main/docs/dynamic-derivations.md)

- [@fzakaria](https://github.com/fzakaria)'s blog series:
  - [An early look at Nix Dynamic Derivations](https://fzakaria.com/2025/03/10/an-early-look-at-nix-dynamic-derivations)
  - [Nix Dynamic Derivations: A practical application](https://fzakaria.com/2025/03/11/nix-dynamic-derivations-a-practical-application)
  - [Nix Dynamic Derivations: A lang2nix practicum](https://fzakaria.com/2025/03/12/nix-dynamic-derivations-a-lang2nix-practicum)

- [Tracking issue for dynamic derivations](https://github.com/NixOS/nix/issues/6316)

[crate2nix]: https://github.com/nix-community/crate2nix
