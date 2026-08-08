{ pkgs, ... }:

{
  # Enable fish as the default shell.
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;
  # Translates bash to fish.
  programs.fish.useBabelfish = true;

  # Handles environment variables per directory.
  programs.direnv.enable = true;
  programs.direnv.enableFishIntegration = true;

  # Disable automatic man page cache generation.
  documentation.man.cache.enable = false;

  # Fish customizations.
  programs.fish.interactiveShellInit = ''
    # Forcing true colors.
    set -g fish_term24bit 1
    # Empty fish greeting.
    set -g fish_greeting ""

    # Increase sponge delay.
    # Keeps the history of the last x commands no matter the exit status.
    set -g sponge_delay 5
    # System information.
    fastfetch
  '';

  # Required packages.
  environment.systemPackages = with pkgs; [
    # Binary and dependencies.
    fish # The fish shell.
    grc # Command colorizer.
    fzf # Fuzzy finder.

    # Fish plugins.
    fishPlugins.z # Pure-fish z directory jumping.                 Docs: https://github.com/jethrokuan/z
    fishPlugins.fzf-fish # Augment the CLI with key bindings.      Docs: https://github.com/PatrickF1/fzf.fish
    fishPlugins.autopair # Navigate the matching pair.             Docs: https://github.com/jorgebucaran/autopair.fish
    fishPlugins.sponge # Cleans unwanted cli entries from history. Docs: https://github.com/meaningful-ooo/sponge
    fishPlugins.puffer # Nice expander autocomplete improvement.   Docs: https://github.com/nickeb96/puffer-fish
    fishPlugins.grc # Command colorizer.
    fishPlugins.bass # Run bash commands in fish.                  Docs: https://github.com/edc/bass

    # Local fish plugins. @todo submit upstream.
    # Brings colors to man pages, this works better than colored-man-pages.
    (pkgs.callPackage ../pkgs/fish-colored-man.nix { inherit (pkgs.fishPlugins) buildFishPlugin; })
  ];
}
