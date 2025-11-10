{
  config,
  lib,
  pkgs,
  vars,
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

    custom.system = {
      home = {
        extraOptions = {
          programs.halloy = {
            enable = true;
            settings = {
              # servers
              servers.bouncer = {
                server = "irc.${vars.net.domain}";
                nickname = vars.user.nick;
                port = 6697;
                sasl.plain = {
                  username = vars.user.nick;
                  password_file = custom.mkSecretPath config "soju/user/password" config.custom.system.user.name;
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
      sops.secrets = [
        {
          path = "soju/user/password";
          owner = config.custom.system.user.name;
          source = "common";
        }
      ];
    };
  };
}
