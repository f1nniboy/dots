{ pkgs, ... }:

{
  config = {
    nixpkgs.overlays = [
      # custom packages
      (self: super: {
        beammp-launcher = pkgs.callPackage ./beammp-launcher { };
      })
    ];
  };
}
