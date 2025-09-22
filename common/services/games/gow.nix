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

    manager = 3000;
  };
  paths = {
    backend = "/var/lib/wolf/backend";
    manager = "/var/lib/wolf/manager";
  };
in
{
  options.custom.services.gow = {
    enable = mkEnableOption "Games on Whales";
  };

  config = mkIf cfg.enable {
    systemd = {
      services = {
        "docker-wolf" = {
          partOf = [
            "docker-compose-wolf-root.target"
          ];
          wantedBy = [
            "docker-compose-wolf-root.target"
          ];
        };
        "docker-wolf-manager" = {
          partOf = [
            "docker-compose-wolf-root.target"
          ];
          wantedBy = [
            "docker-compose-wolf-root.target"
          ];
        };
      };

      # root service
      targets."docker-compose-wolf-root" = {
        wantedBy = [ "multi-user.target" ];
      };
    };

    # containers
    virtualisation.oci-containers.containers = {
      "wolf" = {
        image = "ghcr.io/games-on-whales/wolf:stable";
        environment = {
          "WOLF_SOCKET_PATH" = "/var/run/wolf/wolf.sock";
        };
        volumes = [
          "${paths.backend}:/etc/wolf:rw"
          "/var/run/wolf:/var/run/wolf:rw"
          "/dev:/dev:rw"
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
      "wolf-manager" = {
        image = "ghcr.io/games-on-whales/wolfmanager/wolfmanager:latest";
        ports = [
          "${toString ports.manager}:3000"
        ];
        environment = {
          "NODE_ENV" = "production";
          "NEXTAUTH_URL" = "http://localhost:${toString ports.manager}";
        };
        volumes = [
          "/var/run/wolf:/var/run/wolf"
          "/var/run/docker.sock:/var/run/docker.sock:rw"
          "${paths.manager}:/app/config"
        ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        ports.https
        ports.http
        ports.rtsp
        ports.control
        ports.video
        ports.audio
      ];
      allowedUDPPorts = [
        ports.https
        ports.http
        ports.rtsp
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

    systemd.tmpfiles.rules = [
      "d /fun/games 0770 me users - -"
    ];
  };
}
