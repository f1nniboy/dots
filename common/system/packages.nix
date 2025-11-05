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
    enable = custom.enableOption;
    unfreePackages = mkOption {
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (getName pkg) cfg.unfreePackages;

    environment = {
      defaultPackages = mkForce [ ];
      systemPackages = with pkgs; [
        # utilities
        efibootmgr
        just
        fd
      ];
    };
  };
}
