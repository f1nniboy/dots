{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.presets.iso;
in
{
  options.custom.presets.iso = {
    enable = custom.enableOption;
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
      openssh.authorizedKeys.keys = vars.ssh.authorizedKeys;
    };

    security.sudo.wheelNeedsPassword = false;
    services.openssh.enable = true;
  };
}
