{ inputs, ... }:
inputs.nixpkgs.lib.extend (
  _: _: {
    custom = import ./custom.nix {
      inherit (inputs.nixpkgs) lib;
    };
  }
)
