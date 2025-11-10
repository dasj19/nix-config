{

  description = "The dasj-lab flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  #inputs.nixpkgs.url = "path:///home/daniel/workspace/projects/linux/nixpkgs";

  inputs.flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.1.0.tar.gz";

  inputs.nixos-artwork.url = "github:NixOS/nixos-artwork";
  inputs.nixos-artwork.flake = false;

  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.stylix.url = "github:danth/stylix";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.systems.follows = "systems";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  inputs.simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
  inputs.simple-nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";
  inputs.simple-nixos-mailserver.inputs.flake-compat.follows = "flake-compat";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
    sops-nix,
    simple-nixos-mailserver,
    stylix,
    home-manager,
    ... 
  }:

  let
    gitSecrets = builtins.fromJSON(builtins.readFile "${self}/secrets/git-secrets.json");
    sopsSecrets = ./secrets/variables.yaml;

    # A function to create a default system configuration that can be extended.
    mkDefaultSystem = cfg: let
      defaults = {
        system = "x86_64-linux";
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
      config = defaults // cfg // {
        specialArgs = defaults.specialArgs // (cfg.specialArgs or {});
        modules = defaults.modules ++ (cfg.modules or []);
      };
    in
      nixpkgs.lib.nixosSystem config;

    # A function to create laptop systems with common configuration.
    mkLaptopSystem = cfg: mkDefaultSystem {
      modules = [
        {
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./home/laptop.nix;
          home-manager.extraSpecialArgs = {
            inherit awesome-linux-templates;
            inherit gitSecrets;
          };
        }
      ] ++ (cfg.modules or []);
    };

    # A function to create server systems with common configuration.
    mkServerSystem = cfg: mkDefaultSystem {
      modules = [
        simple-nixos-mailserver.nixosModule
        {
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./home/server.nix;
          home-manager.extraSpecialArgs = {
            inherit gitSecrets;
          };
        }
      ] ++ (cfg.modules or []);
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
        #nixos-hardware.nixosModules.tuxedo-xa15 # does not exist yet.
      ];
    };
    nixosConfigurations.cm4-nas = mkServerSystem {
      system = "aarch64-linux";
      modules = [
        ./machines/cm4-nas/configuration.nix
      ];
    };

    nixosConfigurations.rpi4-tv = mkServerSystem {
      system = "aarch64-linux";
      modules = [
        ./machines/rpi4-tv/configuration.nix
        nixos-hardware.nixosModules.raspberry-pi-4
      ];
    };


    nixosConfigurations.devbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./machines/devbox/configuration.nix
      ];
    };

    nixosConfigurations.t14 = mkLaptopSystem {
      modules = [
        ./machines/t14/configuration.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-intel-gen1-nvidia
      ];
    };
  };
}
