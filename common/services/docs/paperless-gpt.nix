{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.paperless-gpt;
  port = 8088;
in
{
  options.custom.services.paperless-gpt = {
    enable = mkEnableOption "Scrobble plays from multiple sources to multiple clients";
  };

  config = mkIf cfg.enable {
    users = {
      users.paperless-gpt = {
        isSystemUser = true;
        group = "paperless-gpt";
        uid = 1105;
      };
      groups.paperless-gpt = {
        gid = 1105;
      };
    };

    virtualisation.oci-containers.containers = {
      "paperless-gpt" = {
        image = "icereed/paperless-gpt:latest";
        # TODO: level=fatal msg="Failed to create db directory: mkdir db: permission denied"
        #user = "${toString config.users.users.paperless-gpt.uid}:${toString config.users.groups.paperless-gpt.gid}";
        volumes = [
          "/var/lib/paperless-gpt/prompts:/app/prompts"
        ];
        environmentFiles = [
          config.sops.templates.paperless-gpt-env.path
        ];
        extraOptions = [ "--network=host" ];
      };
    };

    sops = {
      templates.paperless-gpt-env = {
        content = ''
          LISTEN_INTERFACE=:${toString port}
          PAPERLESS_BASE_URL=https://${config.custom.services.caddy.hosts.paperless.subdomain}.${config.custom.services.caddy.domain}
          PAPERLESS_PUBLIC_URL=https://${config.custom.services.caddy.hosts.paperless.subdomain}.${config.custom.services.caddy.domain}

          PAPERLESS_API_TOKEN=${
            config.sops.placeholder."${config.networking.hostName}/paperless-gpt/paperless-api-token"
          }
          OPENAI_API_KEY=${
            config.sops.placeholder."${config.networking.hostName}/paperless-gpt/openai-api-key"
          }

          MANUAL_TAG=ai
          AUTO_TAG=ai-auto

          LLM_LANGUAGE=German/Deutsch
          LLM_PROVIDER=openai
          LLM_MODEL=gpt-4o
        '';
        owner = "paperless-gpt";
      };
      secrets = {
        "${config.networking.hostName}/paperless-gpt/paperless-api-token".owner = "paperless-gpt";
        "${config.networking.hostName}/paperless-gpt/openai-api-key".owner = "paperless-gpt";
      };
    };

    custom.services.caddy.hosts = {
      paperless-gpt = {
        subdomain = "ai.${config.custom.services.caddy.hosts.paperless.subdomain}";
        target = ":${toString port}";
        import = [ "auth" ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/paperless-gpt";
          user = "paperless-gpt";
          group = "paperless-gpt";
          mode = "0700";
        }
      ];
    };
  };
}
