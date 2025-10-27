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
    inputs.flatpaks.nixosModules.default
  ];

  options.custom.system.flatpak = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      };
    };

    custom.system.persistence.config = {
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
