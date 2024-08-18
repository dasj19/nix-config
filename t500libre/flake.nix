{

  description = "The t500libre flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, sops-nix, ... }:

  let
    gitSecrets = builtins.fromJSON(builtins.readFile "${self}/secrets/git-secrets.json");
  in

  {
    nixosConfigurations.t500libre = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitSecrets;
      };
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        sops-nix.nixosModules.sops
      ];
    };
  };
}
