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
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.beammp-launcher
    ];

    # fix certificate issues
    security.pki.certificateFiles = [
      (pkgs.stdenvNoCC.mkDerivation {
        name = "beammp-cert";
        nativeBuildInputs = [ pkgs.curl ];
        builder = pkgs.writeScript "beammp-cert-builder" "curl -w %{certs} https://auth.beammp.com/userlogin -k > $out";
        outputHash = "sha256-8qyV7wLQBcpNUKasJFRb5BuPD87Orbpy3E5KFeWAkr0=";
      })
    ];
  };
}
