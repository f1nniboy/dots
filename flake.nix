{
  description = "NixOS configurations for my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    caddy.url = "github:vincentbernat/caddy-nix";
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";
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

    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nur,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      lib = import ./common/lib { inherit inputs; };
      vars = import ./vars.nix;

      mkSystem =
        hostname:
        let
          path = ./machines/${hostname};
        in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              lib
              inputs
              outputs
              vars
              ;
          };
          modules = [
            {
              networking.hostName = hostname;
            }

            (path + "/configuration.nix")
            (path + "/hardware.nix")

            {
              # TODO: what am I using NUR for again?
              nixpkgs.overlays = [
                nur.overlays.default
              ];
            }
          ];
        };

    in
    {
      nixosConfigurations = {
        desktop = mkSystem "desktop";
        laptop = mkSystem "laptop";
        lab = mkSystem "lab";

        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              lib
              inputs
              outputs
              vars
              ;
          };
          modules = [
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ./machines/iso/configuration.nix
          ];
        };
      };
    };
}
