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
      # language servers
      nil
      nixd

      nixfmt-rfc-style # formatter
      statix # linter

      just
    ];
  };
}
