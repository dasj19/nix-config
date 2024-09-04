{

  description = "The dasj-lab flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  #inputs.nixpkgs.url = "path:/home/daniel/workspace/projects/nixpkgs";

  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.stylix.url = "github:danth/stylix";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.home-manager.follows = "home-manager";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

  inputs.simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
  inputs.simple-nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nixos-hardware, sops-nix, simple-nixos-mailserver, stylix, home-manager, ... }:

  let
    gitSecrets = builtins.fromJSON(builtins.readFile "${self}/secrets/git-secrets.json");
    sopsSecrets = ./secrets/variables.yaml;
  in

  {
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
      ];
    };
    nixosConfigurations.xps13-9310 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
        inherit sopsSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/xps13-9310/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        nixos-hardware.nixosModules.dell-xps-13-9310
      ];
    };
    nixosConfigurations.xps13-9380 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
        inherit sopsSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/xps13-9380/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        nixos-hardware.nixosModules.dell-xps-13-9380
        home-manager.nixosModules.home-manager
        # TODO: Move inside machines folder.
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./machines/xps13-9380/home.nix;

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
        }
      ];
    };
    nixosConfigurations.tuxedo-xa15 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
        inherit sopsSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./machines/tuxedo-xa15/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        #nixos-hardware.nixosModules.tuxedo-xa15 # does not exist yet.
      ];
    };
  };
}
