{ config, lib, ... }:
with lib;
let
  cfg = config.custom.presets.iso;
in
{
  options.custom.presets.iso = {
    enable = custom.enableOption;
  };

  imports = [
    ../system/dev.nix
    ../system/nix.nix
    ../system/packages.nix
  ];

  config = mkIf cfg.enable {
    custom = {
      system = {
        dev.enable = true;
        nix.enable = true;
        packages.enable = true;
      };
    };

    users.users.nixos = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = config.custom.cfg.ssh.authorizedKeys;
    };

    security.sudo.wheelNeedsPassword = false;
    services.openssh.enable = true;
  };
}
