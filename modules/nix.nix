{pkgs, ...}: {
  config = {
    # Nix build settings.
    nix.settings.substituters = [
      "https://cache.nixos.org"
    ];
    nix.settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    # Increase download buffer size to 1GB to speed up downloads of large derivations.
    nix.settings.download-buffer-size = 1073741824;

    # Enable distributed builds for all nix builds.
    nix.distributedBuilds = true;
    # User allowed to use distributed builds.
    nix.settings.trusted-users = ["root" "daniel"];

    # Nix and Nixpkgs configurations.
    nix.settings.experimental-features = [
      "flakes"
      "nix-command"
    ];

    # Packages for nix ecosystem.
    environment.systemPackages = with pkgs; [
      alejandra # Nixpkgs formatter.
      hydra-check # Hydra build status checker.
      nix-search-cli # CLI for searching nixpkgs.
      nix-prefetch # Nix fetcher for various sources.
      nix-prefetch-git # Nix fetcher for git repos.
      nix-serve # Simple Nix binary cache server.
      nix-tree # Visualize dependency graph of nix derivations.
      nixpkgs-fmt # Nix code formatter.
      nixpkgs-review # Tool to review nixpkgs pull requests.
      statix # Static analysis tool for nix code.
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
