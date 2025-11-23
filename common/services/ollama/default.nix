{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.ollama;
in
{
  options.custom.services.ollama = {
    enable = custom.enableOption;
    port = mkOption {
      type = types.port;
      default = 11434;
    };
    models = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ollama = {
      serviceConfig = {
        ExecStart = mkForce "${lib.getExe pkgs.ollama-vulkan} serve";
        DynamicUser = mkForce false;
      };
    };

    services.ollama = {
      enable = true;
      # TODO: why does this not work??? it just doesn't change the ExecStart attr
      package = mkForce pkgs.ollama-vulkan;
      user = "ollama";
      group = "ollama";
      host = "0.0.0.0";
      environmentVariables = {
        # TODO: wait for https://github.com/NixOS/nixpkgs/pull/463430
        OLLAMA_VULKAN = "1";
      };
      inherit (cfg) port;
      loadModels = cfg.models;
    };

    custom = {
      services = {
        caddy.hosts = {
          ollama = {
            target = ":${toString cfg.port}";
            # clients (paperless-gpt, open-webui) interfacing
            # with ollama don't like self-signed certificates
            # TODO: fix in the future
            httpOnly = true;
          };
        };
      };
      system.persistence.config = {
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
  };
}
