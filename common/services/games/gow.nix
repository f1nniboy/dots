{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.gow;
in
{
  options.custom.services.gow = {
    enable = mkEnableOption "Games on Whales";
  };

  config = mkIf cfg.enable {
    # containers
    virtualisation.oci-containers.containers."wolf" = {
      image = "ghcr.io/games-on-whales/wolf:stable";
      volumes = [
        "/dev/:/dev:rw"
        "/etc/wolf/:/etc/wolf:rw"
        "/run/udev:/run/udev:rw"
        "/var/run/docker.sock:/var/run/docker.sock:rw"
      ];
      log-driver = "journald";
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
  };
}
