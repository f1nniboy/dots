{ pkgs, ... }:
{
  config = {
    nixpkgs.overlays = [
      # custom packages
      (_: _: {
        beammp-launcher = pkgs.callPackage ./beammp-launcher { };
        convoyeur = pkgs.callPackage ./convoyeur { };
      })
    ];
  };
}
