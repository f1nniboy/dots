{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.services.convoyeur;
  configFile = pkgs.writeTextFile {
    name = "convoyeur.hcl";
    text = import ./config.nix {
      inherit cfg vars;
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
