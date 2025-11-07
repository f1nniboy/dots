{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.system.dev;
in
{
  options.custom.system.dev = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nixfmt-rfc-style # formatter
      nixd # language server
      statix # linter

      just
    ];
  };
}
