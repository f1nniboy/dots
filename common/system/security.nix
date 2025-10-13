{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.system.security;
in
{
  options.custom.system.security = {
    enable = mkEnableOption "security tweaks";
  };

  imports = [
    "${inputs.nix-mineral}/nix-mineral.nix"
  ];

  config = mkIf cfg.enable {
    security.sudo.wheelNeedsPassword = false;
    networking.firewall.enable = true;

    nix-mineral = {
      enable = true;
      overrides = {
        desktop.tmp-exec = true;
      };
    };

    # nix-mineral filesystem settings are incompatible with impermanence
    fileSystems = {
      "/home" = mkForce { enable = false; };
      "/root" = mkForce { enable = false; };
      "/var" = mkForce { enable = false; };
      "/srv" = mkForce { enable = false; };
      "/etc" = mkForce { enable = false; };
    };
  };
}
