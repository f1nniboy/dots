{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.services.gow;
  ports = {
    https = 47984;
    http = 47989;
    control = 47999;
    rtsp = 48010;
    video = 48100;
    audio = 48200;
  };
  wolf-config = pkgs.writeText "wolf-config" (
    import ../config/gow/config.nix {
      inherit config pkgs;
    }
  );
in
{
  options.custom.services.gow = {
    enable = mkEnableOption "Games on Whales";
    id = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      tmpfiles.settings."10-wolf-config"."/var/lib/wolf/cfg/config.toml"."C+" = {
        user = "root";
        group = "root";
        mode = "0700";
        argument = "${wolf-config}";
      };
    };

    # containers


    # root service
    systemd.targets."docker-compose-wolf-root" = {
      wantedBy = [ "multi-user.target" ];
    };

    networking.firewall = {
      allowedTCPPorts = [
        ports.https
        ports.http
        ports.rtsp
      ];
      allowedUDPPorts = [
        ports.control
        ports.video
        ports.audio
      ];
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/wolf";
          mode = "0700";
        }
      ];
    };
  };
}
