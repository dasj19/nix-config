# nix: Nix daemon and nix-related configuration.
# scope: all machines
#
# Provides Nix settings, substituters, distributed builds, and nix ecosystem tools.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Nix build settings.
  nix.settings.substituters = [
    "https://cache.nixos.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];

  # Increase download buffer size to 1GB to speed up downloads of large derivations.
  # Servers lower it in profiles/server.nix, the buffer is held in memory.
  nix.settings.download-buffer-size = lib.mkDefault 1073741824;

  # Users allowed to use distributed builds.
  nix.settings.trusted-users = lib.mkForce [
    "root" # do not remove while using mkForce.
    config.users.primaryUser
  ];

  # Build the max amount of jobs (amount of cpu cores) using 1 core per job.
  nix.settings.max-jobs = lib.mkDefault "auto";
  nix.settings.cores = lib.mkDefault 1;

  # Nix store optimizations.
  nix.settings.auto-optimise-store = true;

  nix.extraOptions = ''
    # Useful when the builder has a faster internet connection than yours
    builders-use-substitutes = true

    # Do not warn when dirty git repo is used.
    warn-dirty = false
  '';

  # Enable distributed builds for all nix builds.
  nix.distributedBuilds = true;

  nix.buildMachines = [
    {
      hostName = "hostup1";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      protocol = "ssh";
      maxJobs = 4;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
    }
  ];

  # Nix and Nixpkgs configurations.
  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];

  # Packages for nix ecosystem.
  environment.systemPackages = with pkgs; [
    hydra-check # Hydra build status checker.
    nix-prefetch # Nix fetcher for various sources.
    nix-prefetch-git # Nix fetcher for git repos.
    nix-search-cli # CLI for searching nixpkgs.
    nix-tree # Visualize dependency graph of nix derivations.
    nixfmt # Nix code formatter following the rfc style.
  ];

  # Provides hints for commands that are missing from the system.
  # Loads an index of all available nix packages.
  # Use 'nix-locate' to search the index manually.
  programs.nix-index.enable = true;
  programs.nix-index.enableFishIntegration = true;

  # Activate the nh nix helper and use its cleanup options.
  programs.nh.enable = true;
  programs.nh.clean.enable = true;
  programs.nh.clean.extraArgs = "--keep-since 10d --keep 5";
}
