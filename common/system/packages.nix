{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.system.packages;
in
{
  options.custom.system.packages = {
    enable = mkEnableOption "common system packages";
  };

  config = mkIf cfg.enable {
    environment.defaultPackages = lib.mkForce [ ];

    environment.systemPackages = with pkgs; [
      efibootmgr
      git
      bottom
      just
      neovim
      statix
      fd
    ];
  };
}
