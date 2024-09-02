{

  description = "The dasj-lab flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  #inputs.nixpkgs.url = "path:/home/daniel/workspace/projects/nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.stylix.url = "github:danth/stylix";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";

  outputs = { self, nixpkgs, nixos-hardware, sops-nix, simple-nixos-mailserver, stylix, ... }:

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
        # todo: setup sops on this host.
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
