{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.ollama;
in
{
  options.custom.services.ollama = {
    enable = mkEnableOption "LLM backend";
    port = mkOption {
      type = types.port;
      default = 11434;
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.ollama = {
        isSystemUser = true;
        group = "ollama";
      };
      groups.ollama = { };
    };

    systemd.services.ollama = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "ollama";
        Group = "ollama";
      };
    };

    services.ollama = {
      enable = true;
      inherit (cfg) port;
      acceleration = null;
      loadModels = [
        "mistral-nemo"
      ];
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/ollama";
          user = "ollama";
          group = "ollama";
          mode = "0700";
        }
      ];
    };
  };
}
