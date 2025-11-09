{
  lib,
  ...
}:
{
  imports = [
    ../../common
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  custom = {
    presets = {
      base.enable = true;
    };

    services = {
      tailscale.enable = true;
      openssh.enable = true;
    };

    system = {
      remoteUnlock.enable = true;
    };
  };
}
