{ pkgs, ... }:
{
  config = {
    # Required packages.
    environment.systemPackages = with pkgs; [
      # Binary and dependencies.
      fish
      fastfetch
      grc
      fzf

      # Fish plugins.
      fishPlugins.done                # Notify when long tasks are done.          Docs: https://github.com/franciscolourenco/done
      fishPlugins.z                   # Pure-fish z directory jumping.            Docs: https://github.com/jethrokuan/z
      fishPlugins.fzf-fish            # Augment the CLI with key bindings.        Docs: https://github.com/PatrickF1/fzf.fish
      fishPlugins.autopair            # Navigate the matching pairs.              Docs: https://github.com/jorgebucaran/autopair.fish
      fishPlugins.sponge              # Cleans unwanted cli entries from history. Docs: https://github.com/meaningful-ooo/sponge
      #fishPlugins.colored-man-pages   # Brings color to man pages.                Docs: https://github.com/PatrickF1/colored_man_pages.fish
      fishPlugins.puffer              # Nice expander autocomplete improvement.   Docs: https://github.com/nickeb96/puffer-fish
      fishPlugins.grc                 # Command colorizer.
      fishPlugins.fish-you-should-use # Reminder to use present aliases.          Docs: https://github.com/paysonwallach/fish-you-should-use
      fishPlugins.bass                # Run bash commands in fish.                Docs: https://github.com/edc/bass
      #fishPlugins.async-prompt        # Make the prompt asynchronous thus faster. Docs: https://github.com/acomagu/fish-async-prompt

      # Local fish plugins. @todo submit upstream.
      # Brings colors to man pages, this works better than colored-man-pages.
      (pkgs.callPackage ../pkgs/fish-colored-man.nix {buildFishPlugin = pkgs.fishPlugins.buildFishPlugin; } )
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