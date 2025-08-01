{

  description = "The dasj-lab flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  #inputs.nixpkgs.url = "path:///home/daniel/workspace/projects/nixpkgs";

  inputs.flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.1.0.tar.gz";

  inputs.nixos-artwork.url = "github:NixOS/nixos-artwork";
  inputs.nixos-artwork.flake = false;

  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.stylix.url = "github:danth/stylix";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.systems.follows = "systems";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  inputs.nix-alien.url = "github:thiagokokada/nix-alien";
  inputs.nix-alien.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix-alien.inputs.flake-compat.follows = "flake-compat";

  inputs.simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
  inputs.simple-nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";
  inputs.simple-nixos-mailserver.inputs.flake-compat.follows = "flake-compat";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  inputs.nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix-vscode-extensions.inputs.flake-utils.follows = "flake-utils";

  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  inputs.vscode-server.inputs.flake-utils.follows = "flake-utils";

  inputs.systems.url = "github:nix-systems/x86_64-linux";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  inputs.awesome-linux-templates.url = "github:dasj19/awesome-linux-templates";
  inputs.awesome-linux-templates.flake = false;

  outputs = {
    self,
    nixpkgs,
    awesome-linux-templates,
    nixos-artwork,
    nixos-hardware,
    nix-alien,
    nix-vscode-extensions,
    sops-nix,
    simple-nixos-mailserver,
    stylix,
    home-manager,
    vscode-server,
    ... 
  }:

  let
    gitSecrets = builtins.fromJSON(builtins.readFile "${self}/secrets/git-secrets.json");
    sopsSecrets = ./secrets/variables.yaml;
  in

  {
    nixosConfigurations.contabo1 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
        inherit sopsSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/contabo1/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        simple-nixos-mailserver.nixosModule
        home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./home/server.nix;

          # Pass arguments to home.nix
          home-manager.extraSpecialArgs = {
            inherit gitSecrets;
          };
        }
      ];
    };
    nixosConfigurations.contabo2 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
        inherit sopsSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/contabo2/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        #nixos-hardware.nixosModules.lenovo-thinkpad
        simple-nixos-mailserver.nixosModule
        home-manager.nixosModules.home-manager
        {
          #home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./home/server.nix;

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
          home-manager.extraSpecialArgs = {
            inherit gitSecrets;
          };
        }
      ];
    };
    nixosConfigurations.linodenix1 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
        inherit sopsSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/linodenix1/configuration.nix
        simple-nixos-mailserver.nixosModule
        sops-nix.nixosModules.sops
      ];
    };
    nixosConfigurations.linodenix2 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
        inherit sopsSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/linodenix2/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        simple-nixos-mailserver.nixosModule
        home-manager.nixosModules.home-manager
        {
          #home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./home/server.nix;

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
          home-manager.extraSpecialArgs = {
            inherit gitSecrets;
          };
        }
      ];
    };
    nixosConfigurations.t500libre = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
        inherit sopsSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/t500libre/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        nixos-hardware.nixosModules.lenovo-thinkpad
        simple-nixos-mailserver.nixosModule
        home-manager.nixosModules.home-manager
        {
          #home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./home/server.nix;

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
          home-manager.extraSpecialArgs = {
            inherit gitSecrets;
          };
        }

        # Extend nixpkgs with VSCode extensions.
        #{
        #  nixpkgs.overlays = [
        #    nix-vscode-extensions.overlays.default # Also have a look at https://github.com/nix-community/nix-vscode-extensions/issues/29
        #  ]; 
        #}
      ];
    };
    nixosConfigurations.xps13-9380 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit awesome-linux-templates;
        inherit gitSecrets;
        inherit nixos-artwork;
        inherit sopsSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/xps13-9380/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        nixos-hardware.nixosModules.dell-xps-13-9380

        # These are not yet used by the xps13-9380 machine.
        vscode-server.nixosModules.default
        ({ config, pkgs, ... }: {
          services.vscode-server.enable = true;
          services.vscode-server.enableFHS = true;
        })

        # Extend nixpkgs with VSCode extensions.
        #{
        #  nixpkgs.overlays = [
        #    nix-vscode-extensions.overlays.default # Also have a look at https://github.com/nix-community/nix-vscode-extensions/issues/29
        #  ]; 
        #}

        home-manager.nixosModules.home-manager
        {
          #home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./home/laptop.nix;
          home-manager.extraSpecialArgs = {
            inherit awesome-linux-templates;
            inherit gitSecrets;
          };
        }
      ];
    };
    nixosConfigurations.tuxedo-xa15 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit awesome-linux-templates;
        inherit gitSecrets;
        inherit nixos-artwork;
        inherit sopsSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/tuxedo-xa15/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        #nixos-hardware.nixosModules.tuxedo-xa15 # does not exist yet.

        # Extend nixpkgs with VSCode extensions.
        {
          nixpkgs.overlays = [
            nix-vscode-extensions.overlays.default # Also have a look at https://github.com/nix-community/nix-vscode-extensions/issues/29
          ]; 
        }
        home-manager.nixosModules.home-manager
        {
          #home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./home/laptop.nix;
          home-manager.extraSpecialArgs = {
            inherit awesome-linux-templates;
            inherit gitSecrets;
          };
        }
        ({ self, system, ... }: {
          environment.systemPackages = [
            nix-alien
          ];
          # Optional, needed for `nix-alien-ld`
          programs.nix-ld.enable = true;
        })
      ];
    };
    nixosConfigurations.cm4-nas = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
        inherit sopsSecrets;
      };
      system = "aarch64-linux";
      modules = [
        ./machines/cm4-nas/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
      ];
    };
    nixosConfigurations.devbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./machines/devbox/configuration.nix
      ];
    };

    nixosConfigurations.t14 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit awesome-linux-templates;
        inherit gitSecrets;
        inherit nixos-artwork;
        inherit sopsSecrets;
      };
      modules = [
        ./machines/t14/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix

        nixos-hardware.nixosModules.lenovo-thinkpad-t14

        home-manager.nixosModules.home-manager
        {
          #home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./home/laptop.nix;
          home-manager.extraSpecialArgs = {
            inherit awesome-linux-templates;
            inherit gitSecrets;
          };
        }
      ];
    };

  };
}
