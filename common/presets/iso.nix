{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.presets.iso;
in
{
  options.custom.presets.iso = {
    enable = mkEnableOption "Preset for ISO images";
  };

  imports = [
    ../system/nix.nix
    ../system/packages.nix
  ];

  config = mkIf cfg.enable {
    custom = {
      system = {
        nix.enable = true;
        packages.enable = true;
      };
    };

    users.users.nixos = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = config.custom.ssh.authorizedKeys;
    };

    security.sudo.wheelNeedsPassword = false;
    services.openssh.enable = true;
  };
}
