{ config, lib, ... }:
with lib;
let
  cfg = config.custom.presets.base;
in
{
  options.custom.presets.base = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    custom = {
      apps = {
        # cli
        neovim = {
          enable = true;
          defaultEditor = true;
        };
        yazi.enable = true;
        bottom.enable = true;
        mosh.enable = true;
      };

      services = {
        step-ca = {
          enable = true;
          role = mkDefault "client";
        };
      };

      system = {
        boot.enable = true;
        firewall.enable = true;
        locale.enable = true;
        nix.enable = true;
        packages.enable = true;
        persistence.enable = true;
        security.enable = true;
        sops.enable = true;
        ssh.enable = true;
        swap.enable = true;
        xdg.enable = true;
      };

      hardware = {
        network.enable = true;
      };
    };
  };
}
