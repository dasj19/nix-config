{ pkgs, ... }:
{
  # Nix build settings. @TODO: consider hosting a hydra.
  nix.settings.substituters = [
    "https://cache.nixos.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];

  nix.distributedBuilds = true;
  # Useful when the builder has a faster internet connection than yours
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
  nix.settings.trusted-users = [ "root" "daniel" ];

  # Nix and Nixpkgs configurations.
  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];

  # Packages for nix ecosystem.
  environment.systemPackages = with pkgs; [
    hydra-check
    nil
    nix-search-cli
    nix-prefetch
    nix-prefetch-git
    nix-serve
    nix-tree
    nixos-option # This: https://github.com/NixOS/nixpkgs/pull/313497 will work with flakes.
    nixpkgs-fmt
    nixpkgs-review
  ];

  # Nix store and garbage collection.
  nix.settings.auto-optimise-store = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 10d";

  # Provides hints for missing commands.
  programs.command-not-found.enable = true;
}