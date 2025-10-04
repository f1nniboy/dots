{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.upsnap;
in
{
  options.custom.services.upsnap = {
    enable = mkEnableOption "Wake-on-LAN web app";

    port = mkOption {
      type = types.port;
      default = 8090;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      "upsnap" = {
        image = " ghcr.io/seriousm4x/upsnap:5";
        volumes = [
          "/var/lib/upsnap:/app/pb_data"
        ];
        environment = {
          "TZ" = config.time.timeZone;
        };
        extraOptions = [ "--network=host" ];
      };
    };

    custom.services.caddy.hosts = {
      upsnap = {
        subdomain = "wake";
        target = ":${toString cfg.port}";
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/upsnap";
          mode = "0700";
        }
      ];
    };

    sops = {
      secrets = {
        "${config.networking.hostName}/oidc/upsnap/secret-hash".owner = "authelia-main";
        "authelia-${config.networking.hostName}/oidc/upsnap/id" = {
          key = "${config.networking.hostName}/oidc/upsnap/id";
          owner = "authelia-main";
        };
      };
    };
  };
}
