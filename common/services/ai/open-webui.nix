{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.ollama;
in
{
  options.custom.services.ollama = {
    enable = mkEnableOption "Self-hosted AI platform";
    port = mkOption {
      type = types.port;
      default = 8090;
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.open-webui = {
        isSystemUser = true;
        group = "open-webui";
      };
      groups.open-webui = { };
    };

    systemd.services.open-webui = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "open-webui";
        Group = "open-webui";
      };
    };

    services.open-webui = {
      enable = true;
      inherit (cfg) port;
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/open-webui";
          user = "open-webui";
          group = "open-webui";
          mode = "0700";
        }
      ];
    };
  };
}
