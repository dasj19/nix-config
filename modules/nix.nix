{ pkgs, lib, ... }:

let

  # @todo: update with stock nil when a release newer than 03-11-2025 occurs.
  nil-master = pkgs.nil.overrideAttrs (prev: rec {
    version = "2025-11-03";
    src = pkgs.fetchFromGitHub {
      owner = "oxalica";
      repo = "nil";
      rev = "master";
      hash = "sha256-ImGN436GYd50HjoKTeRK+kWYIU/7PkDv15UmoUCPDUk=";
    };

    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-LS2IW4gZ1k6Xl5weMNwxvVA2z56r4rPkjqrkROZTmBw=";
    };
  });

in

{
  config = {
    # Nix build settings.
    nix.settings.substituters = [
      "https://cache.nixos.org"
    ];
    nix.settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    nix.settings.download-buffer-size = 1073741824; # 1GB

    nix.distributedBuilds = true;
    nix.settings.trusted-users = [ "root" "daniel" ];

    # Nix and Nixpkgs configurations.
    nix.settings.experimental-features = [
      "flakes"
      "nix-command"
    ];

    # Packages for nix ecosystem.
    environment.systemPackages = with pkgs; [
      hydra-check
      nil-master # @todo: change to stock nil once a new release is available.
      nix-search-cli
      nix-prefetch
      nix-prefetch-git
      nix-serve
      nix-tree
      nixos-option # This: https://github.com/NixOS/nixpkgs/pull/313497 will work with flakes.
      nixpkgs-fmt
      nixpkgs-review
      statix # code linter for nix.
    ];

    # Nix store optimizations.
    nix.settings.auto-optimise-store = true;

    nix.extraOptions = ''
      # Useful when the builder has a faster internet connection than yours
      builders-use-substitutes = true
      
      # Do not warn when dirty git repo is used.
      warn-dirty = false
    '';

    # Provides hints for commands that are missing from the system.
    # Loads an index of all available nix packages.
    programs.nix-index.enable = true;
    programs.nix-index.enableFishIntegration = true;

    # Activate the nh nix helper and use its cleanup options.
    programs.nh.enable = true;
    programs.nh.clean.enable = true;
    programs.nh.clean.extraArgs = "--keep-since 10d --keep 5";
  };
}