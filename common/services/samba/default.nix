{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.samba;
in
{
  options.custom.services.samba = {
    enable = custom.enableOption;
    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    services.samba = {
      enable = true;
      openFirewall = true;
    };

    # declaratively set samba account passwords
    system.activationScripts = {
      init-smbpasswd.text = builtins.concatStringsSep "\n" (
        map (
          user:
          let
            secretPath = custom.mkSecretPath config "samba/users/${user}" "root";
            catCmd = "$(${pkgs.coreutils-full}/bin/cat ${secretPath})";
          in
          ''
            ${pkgs.coreutils-full}/bin/printf "${catCmd}\n${catCmd}\n" | ${pkgs.samba}/bin/smbpasswd -sa ${user}
          ''
        ) cfg.users
      );
    };

    custom.system = {
      sops.secrets =
        let
          mkUserSecret = name: {
            path = "samba/users/${name}";
            owner = "root";
          };
        in
        map mkUserSecret cfg.users;

      persistence.config = {
        directories = [
          {
            directory = "/var/lib/samba";
            mode = "0700";
          }
        ];
      };
    };
  };
}
