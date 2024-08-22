{

  description = "The xps13-9380 flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, sops-nix, stylix, ... }:

  let
    gitSecrets = builtins.fromJSON(builtins.readFile "${self}/secrets/git-secrets.json");
  in

  {
    nixosConfigurations.xps13-9380 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
      ];
    };
  };
}
