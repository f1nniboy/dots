{
  description = "NixOS configurations for my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    namescale = {
      url = "github:sinanmohd/namescale";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";

    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };

    blog = {
      # TODO: change to github source
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
      colmena,
      nur,
      systems,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      lib = import ./common/lib { inherit inputs; };
      vars = import ./vars.nix;

      eachSystem = nixpkgs.lib.genAttrs (import systems);
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };

      mkMachine =
        {
          hostname,
        }:
        let
          path = ./hosts/${hostname};
        in
        {
          deployment = lib.mkMerge [
            {
              targetUser = "me";
            }
            (import (path + "/deployment.nix") {
              inherit vars;
            })
          ];

          nixpkgs.system = system;
          networking.hostName = hostname;

          nixpkgs.overlays = [
            nur.overlays.default
          ];

          imports = [
            ./common

            (path + "/configuration.nix")
            (path + "/hardware.nix")
          ];
        };
    in
    {
      colmenaHive = colmena.lib.makeHive self.outputs.colmena;
      colmena = {
        meta = {
          nixpkgs = pkgs;

          specialArgs = {
            inherit
              lib
              inputs
              outputs
              vars
              system
              ;
          };
        };

        # personal
        diana = mkMachine { hostname = "diana"; }; # desktop
        pluto = mkMachine { hostname = "pluto"; }; # laptop

        # servers
        jupiter = mkMachine { hostname = "jupiter"; }; # vps
        apollo = mkMachine { hostname = "apollo"; }; # lab
      };

      nixosConfigurations = {
        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
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
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ./hosts/iso/configuration.nix
          ];
        };
      };

      devShells = eachSystem (system: {
        default = pkgs.callPackage ./shell.nix { inherit inputs pkgs; };
      });
    };
}
