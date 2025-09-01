{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.system.flatpak;
in
{
  imports = [
    inputs.flatpaks.nixosModule
  ];

  options.custom.system.flatpak = {
    enable = mkEnableOption "flatpak support";
  };

  config = mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/flatpak";
          group = "users";
        }
      ];
    };

    custom.system.persistence.userConfig = {
      directories = [ ".var/app" ];
    };
  };
}
