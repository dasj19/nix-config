{ pkgs, ... }:
{
  config = {
    # Required packages.
    environment.systemPackages = with pkgs; [
      # Binary and dependencies.
      fish
      fastfetch

      # Fish plugins.
      fishPlugins.done                # Notify when long tasks are done.          Docs: https://github.com/franciscolourenco/done
      fishPlugins.z                   # Pure-fish z directory jumping.            Docs: https://github.com/jethrokuan/z
      fishPlugins.fzf-fish            # Augment the CLI with key bindings.        Docs: https://github.com/PatrickF1/fzf.fish
      fishPlugins.autopair            # Navigate the matching pairs.              Docs: https://github.com/jorgebucaran/autopair.fish
      fishPlugins.sponge              # Cleans unwanted cli entries from history. Docs: https://github.com/meaningful-ooo/sponge
      fishPlugins.colored-man-pages   # Brings color to man pages.                Docs: https://github.com/PatrickF1/colored_man_pages.fish
    ];

    # Enable fish as the default shell.
    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;

    # Fish customizations.
    programs.fish.interactiveShellInit = ''
      # Forcing true colors.
      set -g fish_term24bit 1
      # Empty fish greeting. @TODO: make it a fish option upstream.
      set -g fish_greeting ""
      # System information and current date.
      fastfetch
      echo (date "+%T - %F")
    '';
  };  
}