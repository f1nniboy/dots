{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.apps.neovim;
in
{
  options.custom.apps.neovim = {
    enable = mkEnableOption "Neovim text editor";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (lib.hiPrio (pkgs.runCommand "nvim.desktop-hide" { } ''
        mkdir -p "$out/share/applications"
        cat "${config.programs.neovim.finalPackage}/share/applications/nvim.desktop" > "$out/share/applications/nvim.desktop"
        echo "Hidden=1" >> "$out/share/applications/nvim.desktop"
      ''))
    ];

    programs.neovim.enable = true;
  };
}
