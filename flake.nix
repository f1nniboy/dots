{
  description = "NixOS configurations for my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    caddy.url = "github:vincentbernat/caddy-nix";
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/v3.1.0";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    piped.url = "github:squalus/piped-flake";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    declarative-jellyfin = {
      url = "github:Sveske-Juice/declarative-jellyfin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      piped,
      declarative-jellyfin,
      nix-minecraft,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      vars = import ./vars.nix;

      mkNixOSConfig =
        path:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs vars; };
          modules = [
            {
              nixpkgs.overlays = [
                nix-minecraft.overlay
              ];
            }
            nix-minecraft.nixosModules.minecraft-servers
            sops-nix.nixosModules.sops
            piped.nixosModules.default
            declarative-jellyfin.nixosModules.default
            path
            (dirOf path + "/hardware.nix")
          ];
        };

    in
    {
      nixosConfigurations = {
        desktop = mkNixOSConfig ./machines/desktop/configuration.nix;
        laptop = mkNixOSConfig ./machines/laptop/configuration.nix;
        lab = mkNixOSConfig ./machines/lab/configuration.nix;
        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs vars; };
          modules = [
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ./machines/iso/configuration.nix
          ];
        };
      };
    };
}
