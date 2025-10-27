{ config, lib, ... }:
with lib;
let
  cfg = config.custom.system.nix;
in
{
  options.custom.system.nix = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    system.stateVersion = "25.05";

    documentation.nixos.enable = false;

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      settings = {
        allowed-users = [ "@wheel" ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };
    };
  };
}
