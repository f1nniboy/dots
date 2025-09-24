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
    enable = mkEnableOption "GUI IRC client";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.halloy ];

    custom.system.home = {
      extraOptions = {
        programs.halloy = {
          enable = true;
          settings = {
            # servers
            servers.f1 = {
              nickname = "f1nn";
              server = "irc.f1nn.space";
              port = 6697;
            };
            servers.f1.sasl.plain = {
              username = "finn";
              password_file = config.sops.secrets."common/halloy/password".path;
            };

            # ui
            font = {
              family = "Adwaita Mono";
              size = 16;
            };
            buffer.backlog_separator = {
              hide_when_all_read = true;
            };
            buffer.text_input = {
              auto_format = "markdown";
            };
            buffer.chathistory = {
              infinite_scroll = true;
            };
          };
        };
      };
    };

    sops = {
      secrets = {
        "common/halloy/password".owner = config.custom.system.user.name;
      };
    };
  };
}
