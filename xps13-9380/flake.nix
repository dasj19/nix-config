{

  description = "The xps13-9380 flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, agenix, sops-nix, ... }:

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
        agenix.nixosModules.default
        sops-nix.nixosModules.sops
      ];
    };
  };
}
