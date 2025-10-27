{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.convoyeur;
  configFile = pkgs.writeTextFile {
    name = "convoyeur.hcl";
    text = import ../config/convoyeur.nix {
      inherit cfg;
    };
  };
in
{
  options.custom.services.convoyeur = {
    enable = custom.enableOption;

    port = mkOption {
      type = types.port;
      default = 8069;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.convoyeur = {
      description = "Convoyeur IRCv3 FILEHOST Adapter";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.convoyeur}/bin/convoyeur";
        Environment = [
          "CONVOYEUR_CONF=${configFile}"
        ];
        Restart = "always";
        DynamicUser = true;
      };
    };
  };
}
