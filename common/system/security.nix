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
    enable = custom.enableOption;
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
        # net.ipv4.conf.all.forwarding=0 breaks the 'docker0' network bridge
        compatibility.allow-ip-forward = true;

        desktop.tmp-exec = true;
      };
    };

    # nix-mineral filesystem settings are incompatible with impermanence
    fileSystems =
      let
        d = mkForce { enable = false; };
      in
      {
        "/home" = d;
        "/root" = d;
        "/var" = d;
        "/srv" = d;
        "/etc" = d;
      };
  };
}
