{

  description = "The dasj-lab flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.stylix.url = "github:danth/stylix";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs = { self, nixpkgs, nixos-hardware, sops-nix, stylix, ... }:

  let
    gitSecrets = builtins.fromJSON(builtins.readFile "${self}/secrets/git-secrets.json");
    sopsSecrets = ./secrets/variables.yaml;
  in

  {
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
  };
}
