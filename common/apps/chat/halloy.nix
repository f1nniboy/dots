{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.halloy;
in
{
  options.custom.apps.halloy = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.halloy ];

    custom.system.home = {
      extraOptions = {
        programs.halloy = {
          enable = true;
          settings = {
            # servers
            servers.bouncer = {
              nickname = "f1nn";
              server = "irc.f1nn.space";
              port = 6697;
              sasl.plain = {
                # TODO: use username specified in sops secrets (halloy doesnt have an option to read username from file)
                username = "finn";
                password_file = config.sops.secrets."halloy-common/soju/user/password".path;
              };
            };

            # security
            ctcp = {
              ping = false;
              source = false;
              time = false;
              version = false;
            };

            # ui
            font = {
              family = "Adwaita Mono";
              size = 16;
            };
            buffer = {
              backlog_separator = {
                hide_when_all_read = true;
              };
              text_input = {
                auto_format = "markdown";
              };
              chathistory = {
                infinite_scroll = true;
              };
            };
          };
        };
      };
    };

    sops = {
      secrets = {
        "halloy-common/soju/user/username" = {
          key = "common/soju/user/username";
          owner = config.custom.system.user.name;
        };
        "halloy-common/soju/user/password" = {
          key = "common/soju/user/password";
          owner = config.custom.system.user.name;
        };
      };
    };
  };
}
