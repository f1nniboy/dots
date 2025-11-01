{ pkgs, ... }:
{
  config = {
    nixpkgs.overlays = [
      # custom packages
      (_: _: {
        convoyeur = pkgs.callPackage ./convoyeur { };
      })
    ];
  };
}
