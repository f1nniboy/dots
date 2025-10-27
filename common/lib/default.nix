{
  inputs,
  ...
}:
inputs.nixpkgs.lib.extend (
  final: prev: {
    custom = import ./custom.nix {
      inherit (inputs.nixpkgs) lib;
    };
  }
)
