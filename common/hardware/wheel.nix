{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.hardware.wheel;
in
{
  options.custom.hardware.wheel = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    hardware.usb-modeswitch.enable = true;
  };
}
