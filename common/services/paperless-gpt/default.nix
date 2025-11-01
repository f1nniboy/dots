{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.services.paperless-gpt;
in
{
  options.custom.services.paperless-gpt = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "ai.${config.custom.services.paperless.subdomain}";
    };

    port = mkOption {
      type = types.port;
      default = 8088;
    };
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
        image = "icereed/paperless-gpt:${vars.docker.images.paperless-gpt}";
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
        content =
          let
            serviceUrl = "https://${custom.mkServiceDomain config "paperless"}";
          in
          ''
            LISTEN_INTERFACE=:${toString cfg.port}
            PAPERLESS_BASE_URL=${serviceUrl}
            PAPERLESS_PUBLIC_URL=${serviceUrl}

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

    custom = {
      services.caddy.hosts = {
        paperless-gpt = {
          target = ":${toString cfg.port}";
          import = [ "auth" ];
        };
      };

      system.persistence.config = {
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
  };
}
