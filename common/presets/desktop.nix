{ config, lib, ... }:
with lib;
let
  cfg = config.custom.presets.desktop;
in
{
  options.custom.presets.desktop = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    custom = {
      desktop = {
        gnome.enable = true;
      };

      apps = {
        # gui
        firefox.enable = true;
        #epiphany.enable = true;
        ptyxis.enable = true;
        halloy.enable = true;
        vesktop.enable = true;
        notesnook.enable = true;
        rnote.enable = true;
        zed.enable = true;
        monero.enable = true;
        bitwarden.enable = true;
        gimp.enable = true;
        spicetify.enable = true;
      };

      services = {
        printing.enable = true;
        tailscale.enable = true;
        syncthing.enable = true;
      };

      system = {
        dev.enable = true;
        flatpak.enable = true;
        fonts.enable = true;
        home.enable = true;
        ld.enable = true;
        git.user.enable = true;
        firewall.backend = "nftables";
      };

      hardware = {
        audio.enable = true;
        bluetooth.enable = true;
      };
    };
  };
}
