{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.spicetify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  imports = [
    inputs.spicetify-nix.nixosModules.spicetify
  ];

  options.custom.apps.spicetify = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblockify
        hidePodcasts
        beautifulLyrics
      ];
    };

    custom.system.persistence.userConfig = {
      directories = [ ".config/spotify" ];
    };
  };
}
