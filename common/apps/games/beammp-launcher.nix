{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.beammp-launcher;
in
{
  options.custom.apps.beammp-launcher = {
    enable = mkEnableOption "Launcher for the BeamNG.drive multiplayer mod";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.beammp-launcher
    ];

    custom.system.persistence.userConfig = {
      #directories = [ ".local/share/supertux2" ];
    };

    # fix certificate issues
    security.pki.certificateFiles = [
      (pkgs.stdenvNoCC.mkDerivation {
        name = "beammp-cert";
        nativeBuildInputs = [ pkgs.curl ];
        builder = pkgs.writeScript "beammp-cert-builder" "curl -w %{certs} https://auth.beammp.com/userlogin -k > $out";
        outputHash = "sha256-tM8bPFcTP8L1SyqCEz0Y0UvQKiNK6ieptnQRA+k4cV4=";
      })
    ];
  };
}
