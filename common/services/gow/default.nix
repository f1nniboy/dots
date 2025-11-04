{
  config,
  lib,
  vars,
  ...
}:
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
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    virtualisation.arion.projects."wolf".settings = {
      project.name = "wolf";

      services = {
        backend.service = {
          container_name = "wolf-backend";
          image = custom.mkDockerImage vars "ghcr.io/games-on-whales/wolf";
          volumes = [
            "${paths.backend}:/etc/wolf:rw"
            "/var/run/wolf:/var/run/wolf"
            "/dev:/dev:rw"
            "/run/udev:/run/udev:rw"
            "/var/run/docker.sock:/var/run/docker.sock:rw"
          ];
          environment = {
            WOLF_SOCKET_PATH = "/var/run/wolf/wolf.sock";
            WOLF_HTTP_PORT = toString ports.http;
            WOLF_HTTPS_PORT = toString ports.https;
            WOLF_CONTROL_PORT = toString ports.control;
            WOLF_RTSP_SETUP_PORT = toString ports.rtsp;
            WOLF_VIDEO_PING_PORT = toString ports.video;
            WOLF_AUDIO_PING_PORT = toString ports.audio;
          };
          devices = [
            "/dev/dri:/dev/dri:rwm"
            "/dev/uhid:/dev/uhid:rwm"
            "/dev/uinput:/dev/uinput:rwm"
          ];
          network_mode = "host";
        };
        manager.service = {
          container_name = "wolf-manager";
          image = custom.mkDockerImage vars "ghcr.io/games-on-whales/wolfmanager/wolfmanager";
          depends_on = [ "backend" ];
          ports = [
            "${toString ports.manager}:3000"
          ];
          environment = {
            NODE_ENV = "production";
            NEXTAUTH_URL = "http://localhost:${toString ports.manager}";
          };
          volumes = [
            "/var/run/wolf:/var/run/wolf"
            "/var/run/docker.sock:/var/run/docker.sock:rw"
            "${paths.manager}:/app/config"
          ];
        };
      };
    };

    networking.firewall =
      let
        p = builtins.attrValues (builtins.removeAttrs ports [ "manager" ]);
      in
      {
        allowedTCPPorts = p;
        allowedUDPPorts = p;
      };

    systemd.tmpfiles.rules = [
      "d /fun/games 0700 ${config.custom.system.user.name} users - -"
    ];

    custom.system.persistence.config = {
      directories = [
        {
          directory = "/var/lib/wolf";
          mode = "0700";
        }
      ];
    };
  };
}
