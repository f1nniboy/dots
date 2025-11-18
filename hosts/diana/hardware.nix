{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "ahci"
        "usbhid"
      ];
      luks = {
        reusePassphrases = true;
        devices = {
          "cryptroot" = {
            device = "/dev/disk/by-uuid/ba4aa3b9-5926-4161-846c-3c32c50aaec1";
            allowDiscards = true;
          };
          "fun" = {
            device = "/dev/disk/by-uuid/61a8995e-7d0b-47da-b529-af5884a64859";
          };
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=2G"
        "mode=0755"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
    "/nix" = {
      device = "/dev/disk/by-label/nix";
      fsType = "ext4";
    };
    "/fun" = {
      device = "/dev/disk/by-label/fun";
      fsType = "ext4";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
