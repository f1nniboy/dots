{ config, lib, ... }:
with lib;
let
  cfg = config.custom.presets.desktop;
in
{
  options.custom.presets.desktop = {
    enable = mkEnableOption "Preset for GNOME desktop";
  };

  imports = [
    ../../common
  ];

  config = mkIf cfg.enable {
    custom = {
      desktop = {
        gnome.enable = true;
      };

      apps = {
        # gui
        firefox.enable = true;
        ptyxis.enable = true;
        vesktop.enable = true;
        vscode.enable = true;
        spicetify.enable = true;

        # cli
        #helix.enable = true;
        yazi.enable = true;
        git.enable = true;
      };

      services = {
        printing.enable = true;
        #openssh.enable = true;
        #tailscale.enable = true;
      };

      system = {
        nix.enable = true;
        boot.enable = true;
        env.enable = true;
        fonts.enable = true;
        locale.enable = true;
        packages.enable = true;
        home.enable = true;
        sops.enable = true;
        security.enable = true;
        flatpak.enable = true;
        persistence.enable = true;
        networking.enable = true;

        xdg = {
          enable = true;
          persistUserDirs = true;
        };
      };

      hardware = {
        network.enable = true;
        audio.enable = true;
      };
    };
  };
}
