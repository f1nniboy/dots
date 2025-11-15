{
  imports = [
    ../../common/presets/iso.nix
  ];

  networking.hostName = "iso";

  custom = {
    presets.iso.enable = true;
  };
}
