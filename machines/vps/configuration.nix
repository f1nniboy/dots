{
  ...
}:
{
  imports = [
    ../../common
  ];

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
