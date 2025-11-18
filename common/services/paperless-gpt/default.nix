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
        image = custom.mkDockerImage vars "icereed/paperless-gpt";
        user = custom.mkDockerUser config "paperless-gpt";
        volumes =
          let
            mkDir = path: "/var/lib/paperless-gpt/${path}:/app/${path}";
          in
          [
            (mkDir "prompts")
            (mkDir "config")
            (mkDir "db")
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

            PAPERLESS_API_TOKEN=${custom.mkSecretPlaceholder config "paperless/api-token" "paperless-gpt"}
            OPENAI_API_KEY=${custom.mkSecretPlaceholder config "paperless-gpt/openai-api-key" "paperless-gpt"}

            MANUAL_TAG=ai
            AUTO_TAG=ai-auto

            LLM_LANGUAGE=German/Deutsch
            LLM_PROVIDER=openai
            LLM_MODEL=gpt-4o
          '';
        owner = "paperless-gpt";
      };
    };

    custom = {
      system = {
        sops.secrets = [
          {
            path = "paperless/api-token";
            owner = "paperless-gpt";
          }
          {
            path = "paperless-gpt/openai-api-key";
            owner = "paperless-gpt";
          }
        ];
        persistence.config = {
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
      services.caddy.hosts = {
        paperless-gpt = {
          target = ":${toString cfg.port}";
          import = [ "auth" ];
        };
      };
    };
  };
}
