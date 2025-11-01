{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.docker;
in
{
  options.custom.services.docker = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    virtualisation = {
      docker = {
        enable = true;
        autoPrune.enable = true;
      };
      oci-containers.backend = "docker";
    };

    custom.system = {
      user.extraGroups = [ "docker" ];
      persistence.config = {
        directories = [ "/var/lib/docker" ];
      };
    };
  };
}
