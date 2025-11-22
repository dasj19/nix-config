{
  description = "The dasj-lab flake";

  # Tracking 'nixpkgs-unstable' branch which is usually a couple days behind master.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  #inputs.nixpkgs.url = "path:///home/daniel/workspace/projects/linux/nixpkgs";

  # Assures compatibility with older version of nix before the version 2.4.
  inputs.flake-compat.url = "github:NixOS/flake-compat/v1.1.0";

  # Archived repo that provides background pictures for the nix project.
  inputs.nixos-artwork.url = "github:NixOS/nixos-artwork";
  inputs.nixos-artwork.flake = false;

  # Security tool to encrypt-decrypt secrets.
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  # Project that seeks to apply uniform styles for NixOS systems.
  inputs.stylix.url = "github:danth/stylix";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.systems.follows = "systems";

  # Hardware configurations for NixOS.
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  # A mail server stack.
  inputs.simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
  inputs.simple-nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";
  inputs.simple-nixos-mailserver.inputs.flake-compat.follows = "flake-compat";

  # Manage user environment with nix.
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  # Collection of pure Nix functions that don't depend on nixpkgs.
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  # Collection of new file templates for the user environment.
  inputs.awesome-linux-templates.url = "github:dasj19/awesome-linux-templates";
  inputs.awesome-linux-templates.flake = false;

  # Latest ulauncher.
  inputs.ulauncher.url = "github:Ulauncher/Ulauncher/main";
  inputs.ulauncher.inputs.nixpkgs.follows = "nixpkgs";

  inputs.systems.url = "github:nix-systems/x86_64-linux";

  outputs =
    {
      self,
      nixpkgs,
      awesome-linux-templates,
      nixos-artwork,
      nixos-hardware,
      sops-nix,
      simple-nixos-mailserver,
      stylix,
      home-manager,
      ulauncher,
      ...
    }:
    let
      gitSecrets = builtins.fromJSON (builtins.readFile "${self}/secrets/git-secrets.json");
      sopsSecrets = ./secrets/variables.yaml;

      # A function to create a default system configuration that can be extended.
      mkDefaultSystem =
        cfg:
        let
          defaults = {
            system = "x86_64-linux";
            # Common special arguments for all systems.
            specialArgs = {
              inherit awesome-linux-templates;
              inherit gitSecrets;
              inherit nixos-artwork;
              inherit sopsSecrets;
            };
            # Common modules for all systems.
            modules = [
              sops-nix.nixosModules.sops
              stylix.nixosModules.stylix
              home-manager.nixosModules.home-manager
            ];
          };
          # Merge defaults with custom configuration.
          config =
            defaults
            // cfg
            // {
              specialArgs = defaults.specialArgs // (cfg.specialArgs or { });
              modules = defaults.modules ++ (cfg.modules or [ ]);
            };
        in
        nixpkgs.lib.nixosSystem config;

      # A function to create laptop systems with common configuration.
      mkLaptopSystem =
        cfg:
        mkDefaultSystem {
          modules = [
            {
              home-manager.useUserPackages = true;
              home-manager.users.daniel = import ./home/laptop.nix;
              home-manager.extraSpecialArgs = {
                inherit awesome-linux-templates;
                inherit gitSecrets;
              };
            }
          ]
          ++ (cfg.modules or [ ]);
        };

      # A function to create server systems with common configuration.
      mkServerSystem =
        cfg:
        mkDefaultSystem {
          modules = [
            simple-nixos-mailserver.nixosModule
            {
              home-manager.useUserPackages = true;
              home-manager.users.daniel = import ./home/server.nix;
              home-manager.extraSpecialArgs = {
                inherit gitSecrets;
              };
            }
          ]
          ++ (cfg.modules or [ ]);
        };
    in
    {
      nixosConfigurations.contabo1 = mkServerSystem {
        modules = [
          ./machines/contabo1/configuration.nix
        ];
      };
      nixosConfigurations.contabo2 = mkServerSystem {
        modules = [
          ./machines/contabo2/configuration.nix
        ];
      };
      nixosConfigurations.linodenix1 = mkServerSystem {
        modules = [
          ./machines/linodenix1/configuration.nix
        ];
      };
      nixosConfigurations.linodenix2 = mkServerSystem {
        modules = [
          ./machines/linodenix2/configuration.nix
        ];
      };
      nixosConfigurations.t500libre = mkServerSystem {
        modules = [
          ./machines/t500libre/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad
        ];
      };
      nixosConfigurations.xps13-9380 = mkLaptopSystem {
        modules = [
          ./machines/xps13-9380/configuration.nix
          nixos-hardware.nixosModules.dell-xps-13-9380
        ];
      };
      nixosConfigurations.tuxedo-xa15 = mkLaptopSystem {
        modules = [
          ./machines/tuxedo-xa15/configuration.nix
        ];
      };
      nixosConfigurations.cm4-nas = mkServerSystem {
        system = "aarch64-linux";
        modules = [
          ./machines/cm4-nas/configuration.nix
          # @todo Include hardware support for the compute module 4.
        ];
      };

      nixosConfigurations.rpi4-tv = mkServerSystem {
        system = "aarch64-linux";
        modules = [
          ./machines/rpi4-tv/configuration.nix
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };

      nixosConfigurations.devbox = mkServerSystem {
        modules = [
          ./machines/devbox/configuration.nix
        ];
      };

      nixosConfigurations.t14 = mkLaptopSystem {
        modules = [
          ./machines/t14/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t14-intel-gen1
          # Provides the newer ulauncher version 6.
          {
            environment.systemPackages = [
              ulauncher.packages.x86_64-linux.ulauncher6
            ];
          }
        ];
      };
    };
}
