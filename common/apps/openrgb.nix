{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.openrgb;

  no-rgb-script = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)

    for i in $(seq 0 $(($NUM_DEVICES - 1))); do
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --device $i --mode static --color 000000
    done
  '';
in
{
  options.custom.apps.openrgb = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    services = {
      udev.packages = [ pkgs.openrgb ];
      hardware.openrgb.enable = true;
    };

    boot.kernelModules = [ "i2c-dev" ];
    hardware.i2c.enable = true;

    systemd.services.openrgb-no-rgb = {
      serviceConfig = {
        ExecStart = "${no-rgb-script}/bin/no-rgb";
        Type = "oneshot";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
