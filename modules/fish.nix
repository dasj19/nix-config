{ pkgs, ... }:
{
  # Enable fish as the default shell.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Fish customizations.
  programs.fish.interactiveShellInit = ''
    # Forcing true colors.
    set -g fish_term24bit 1
    # Empty fish greeting. @TODO: make it a fish option upstream.
    set -g fish_greeting ""
    # Pasting hostname and current date.
    echo "xps13-9380"
    echo (date "+%T - %F")
  '';
}