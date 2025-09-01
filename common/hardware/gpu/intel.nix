{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.hardware.gpu.intel;
in
{
  options.custom.hardware.gpu.intel = {
    enable = mkEnableOption "Intel GPU acceleration";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # for Broadwell (2014) or newer processors
        libva-vdpau-driver # previously vaapiVdpau
        vpl-gpu-rt # qsv on 11th gen or newer
      ];
    };
  };
}
