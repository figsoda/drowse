# drowse

Drowse is a thin wrapper around dynamic derivations to make it easier to use.
To use drowse, the following experimental features need to be enabled:
`ca-derivations`, `dynamic-derivations`, `recursive-nix`.

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
