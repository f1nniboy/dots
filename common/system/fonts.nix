{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.system.fonts;
in
{
  options.custom.system.fonts = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      noto-fonts
    ];
  };
}
