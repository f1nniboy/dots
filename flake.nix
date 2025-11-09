{
  description = "NixOS configurations for my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    declarative-jellyfin = {
      url = "github:Sveske-Juice/declarative-jellyfin";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    impermanence.url = "github:nix-community/impermanence";
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";

    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };

    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      flake = false;
    };

    blog = {
      url = "path:/home/me/Projects/blog";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
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
        hostname: system:
        let
          path = ./machines/${hostname};
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              lib
              inputs
              outputs
              vars
              system
              ;
          };
          modules = [
            {
              networking.hostName = hostname;
            }

            (path + "/configuration.nix")
            (path + "/hardware.nix")

            {
              nixpkgs.overlays = [
                nur.overlays.default
              ];
            }
          ];
        };

    in
    {
      nixosConfigurations = {
        desktop = mkSystem "desktop" "x86_64-linux";
        laptop = mkSystem "laptop" "x86_64-linux";
        lab = mkSystem "lab" "x86_64-linux";
        vps = mkSystem "lab" "x86_64-linux";

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
