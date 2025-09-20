{ config, lib, ... }:
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
    import ../config/gow/config.nix
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
    virtualisation.oci-containers.containers."wolf" = {
      image = "ghcr.io/games-on-whales/wolf:stable";
      volumes = [
        "/dev/:/dev:rw"
        "/var/lib/wolf/:/etc/wolf:rw"
        "/run/udev:/run/udev:rw"
        "/var/run/docker.sock:/var/run/docker.sock:rw"
      ];
      extraOptions = [
        "--device=/dev/dri:/dev/dri:rwm"
        "--device=/dev/uhid:/dev/uhid:rwm"
        "--device=/dev/uinput:/dev/uinput:rwm"
        "--network=host"
      ];
    };
    systemd.services."docker-wolf" = {
      partOf = [
        "docker-compose-wolf-root.target"
      ];
      wantedBy = [
        "docker-compose-wolf-root.target"
      ];
    };

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
